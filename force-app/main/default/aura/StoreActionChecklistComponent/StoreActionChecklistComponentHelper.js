({
    setFileUpload: function(component) {
        component.set('v.FileUpload', true)
    },

    closeDialogBox: function(component) {
        component.set("v.confirmDialog", false)
    },

    apexCallPromise: function(action) {
        return new Promise((resolve, reject) => {
            /*const action = component.get("c.getChecklist");
            const eventId = component.get("v.recordId")[;]
            action.setParams({ eventId });*/
            action.setCallback(this, function(response) {
                const returnList = response.getReturnValue();
                const state = response.getState();
                if (state === "SUCCESS") {
                    resolve(returnList);
                } else {
                    reject(state);
                }
            });
            $A.enqueueAction(action);
        })
    },

    fetchRecords: function(component) {
        const action = component.get("c.getChecklist");
        const eventId = component.get("v.recordId");
        action.setParams({ eventId });
        this.apexCallPromise(action)
            .then(returnList => {
                component.set("v.checklistRecords", returnList);
                console.log('returnList1: ' + JSON.stringify(returnList));
                if (returnList.length > 0) {
                    //Lock State
                    const islockedstate = returnList[0].IsLocked__c;
                    component.set('v.lockState', islockedstate)
                    component.set('v.lockStateNext', islockedstate);
                    component.set('v.lockStateOther', islockedstate);
                    //set account Id
                    component.set("v.accId", returnList[0].AccountId__c);
                } else {
                    component.set('v.lockStateNext', true);
                }
                const action = component.get("c.getOffLocation");
                action.setParams({ "accId": component.get("v.accId"),
                                    "recordId": eventId});
                return this.apexCallPromise(action)
            })
            .then(returnList => {
                const data = returnList.map(record => {
                    const updatedRec = record;
                    updatedRec.locationProduct = record.Off_Location_Product__r ? record.Off_Location_Product__r.Name : null;
                  return updatedRec;
                });
                console.log('offLocs: ' + JSON.stringify(data));
                component.set('v.rawData', data);
                component.set("v.dataSize", data.length);
                //call for filter of columns
                this.updateBooks(component);

                this.getColumnDefinitions(component);

                const action = component.get("c.getDeptDetails");
                action.setParams({ "eventId" : eventId});
                return this.apexCallPromise(action)
            })
            .then(returnList => {
                console.log(JSON.stringify(returnList));
                var departmentDetails = [];
                departmentDetails.push({
                    "name" : "Builders",
                    "timeTaken" : returnList[0].Tools_Department_Time__c
                },{
                    "name" : "Floorcare",
                    "timeTaken" : returnList[0].Floorcare_Department_Time__c
                },{
                    "name" : "Power Garden",
                    "timeTaken" : returnList[0].Garden_Department_Time__c
                },{
                    "name" : "Others",
                    "timeTaken" : returnList[0].Other_Department_Time__c
                });
                component.set("v.departmentDetails", departmentDetails);
                component.set("v.deptId", returnList[0].Id);
            })
            .catch(state => {
                this.handleErrorShowToast(component, `Action failed with state: ${state}`);
                console.log('error:' + state);
            })
    },

    /*fetchRecords: function(component) {
        const action = component.get("c.getChecklist");
        const eventId = component.get("v.recordId")
        action.setParams({ eventId });
        action.setCallback(this, function(response) {
            const returnedChecklistItems = response.getReturnValue();
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.checklistRecords", returnedChecklistItems);
                if (returnedChecklistItems.length > 0) {
                    //Lock State
                    const islockedstate = returnedChecklistItems[0].IsLocked__c;
                    component.set('v.lockState', islockedstate)
                    component.set('v.lockStateNext', islockedstate);
                    component.set('v.lockStateOther', islockedstate);
                    //set account Id
                    component.set("v.accId", returnedChecklistItems[0].AccountId__c);
                } else {
                    component.set('v.lockStateNext', true);
                }
            }
            else {
                this.handleErrorShowToast(component, `Action failed with state: ${state}`);
            }
        });
        $A.enqueueAction(action);
    },*/

    fetchTotalTime: function(component) {
        const action = component.get("c.getTotalTime");
        const eventId = component.get("v.recordId")
        const departmentDetails = [];
        action.setParams({ eventId });
        action.setCallback(this, function(response) {
            const returnedTime = response.getReturnValue();
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.totalTime", returnedTime.split(',')[0]);
                component.set("v.totalTimeInMinutes", returnedTime.split(',')[1]);
            }
            else {
                this.handleErrorShowToast(component, `Action failed with state: ${state}`);
            }
        });
        $A.enqueueAction(action);
    },

    handleSave: function(component, event) {
        component.set("v.showSpinner", true);
        const action = component.get("c.doSaveChecklistActionItems");
        const inputParam = {
            "otherItems": component.get("v.otherChecklistRecords"),
            "savedchecklist": component.get("v.checklistRecords")
        };
        const deptDetails = {
            "deptId" : component.get("v.deptId"),
            "departmentDetails" : component.get("v.departmentDetails")
        };
        console.log('deptDetails: ' + JSON.stringify(deptDetails));
        console.log('inputParam: ' + JSON.stringify(inputParam));
        action.setParams({ "inputArgument": JSON.stringify(inputParam),
        "deptDetails" : JSON.stringify(deptDetails)});
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                this.handleSuccessShowToast(component, "Checklist updated successfully.");
                this.fetchRecords(component);
            }
            else if (state === "ERROR") {
                component.set("v.showSpinner", false);
            }
        });

        $A.enqueueAction(action)
    },

    handleOtherClick: function(component) {
        const otherChecklistRecords = component.get("v.otherChecklistRecords");
        if (otherChecklistRecords.length > 0) {
            if (this.validateTotalOtherItems(otherChecklistRecords)) {
                this.handleErrorShowToast(component, "Cannot add more than 3 other checklist items");
                return;
            }
        }
        otherChecklistRecords.push({
            "title": "Other",
            "summary": "",
            "timeTaken": 0,
            "isDeleted": false,
        });
        component.set("v.otherChecklistRecords", otherChecklistRecords);
    },

    validateTotalOtherItems: function(otherChecklistRecords) {
        const otherItems = otherChecklistRecords.filter(el => !el.isDeleted);
        return otherItems.length == 3;
    },

    handleSuccessShowToast: function(component, message) {
        console.log("component: " + component);
        component.find('notifLib').showToast({
            "title": "Success",
            "message": message,
            "mode": "dismissable",
            "variant": "success"
        });
    },

    handleErrorShowToast: function(component, message) {
        component.find('notifLib').showToast({
            "title": "Error",
            "message": message,
            "mode": "dismissable",
            "variant": "error"
        });
    },

    isTotalTimeExceeded: function(component, calledFrom, childName) {
        console.log('calledFrom: ' + calledFrom);
        console.log('childName: ' + childName);
        var offLocationTime = 0;
        let totalcalculatedtime = 0;
        let totalDeptTime = 0;
        let checklistRecords = component.get("v.checklistRecords");
        var departmentDetails = component.get("v.departmentDetails");
        if(calledFrom == 'FromParent' || (calledFrom == 'FromChild' && childName == 'header')) {
            checklistRecords.forEach((item) => { 
                totalcalculatedtime += parseInt(item.TimeTaken__c);
                if(item.Title__c == $A.get("$Label.c.OffLocationLabel")) {
                    offLocationTime += parseInt(item.TimeTaken__c);
                    console.log("offLocTime: " + offLocationTime);
                }
            });

            let otherChecklistRecords = component.get("v.otherChecklistRecords");
            otherChecklistRecords.forEach((item) => { totalcalculatedtime += parseInt(item.timeTaken) });

            component.set("v.totalcalculatedtime", totalcalculatedtime);
            console.log('checklistTime: ' + totalcalculatedtime);

            if (calledFrom == 'FromChild') {
                let firedFrom = component.get("v.firedFrom");
                if (firedFrom == 'HourIncrement') {
                    totalcalculatedtime += 60;
                } else if (firedFrom == 'MinuteIncrement') {
                    totalcalculatedtime += 15;
                }
            }
        }
        if(calledFrom == 'FromParent' || (calledFrom == 'FromChild' && childName == 'dept')) {
            console.log('dept from parent');
            departmentDetails.forEach((record) => {
                console.log('record: ' + JSON.stringify(record));
                totalDeptTime += parseInt(record.timeTaken);
                console.log('totalcalculatedtime dept: ' + totalDeptTime);
            });
            component.set("v.totalTimeDept", totalDeptTime);

            if (calledFrom == 'FromChild') {
                let firedFrom = component.get("v.firedFrom");
                if (firedFrom == 'HourIncrement') {
                    totalDeptTime += 60;
                } else if (firedFrom == 'MinuteIncrement') {
                    totalDeptTime += 15;
                }
            }
        }
        console.log('totalDeptTime: ' + component.get("v.totalTimeDept"));

        let eventTotalTimeInMinutes = component.get("v.totalTimeInMinutes");

        component.set("v.eventTotalTimeInMinutes", eventTotalTimeInMinutes);

        console.log('totalcalculatedtime: ' + totalcalculatedtime);

        var offLocScenario = 'first';
        if(calledFrom == 'FromParent') {
            var dataSize = component.get("v.dataSize");
            var data = component.get("v.rawData").length;
            console.log("dataSize: " + dataSize);
            console.log("data: " + data);

            if(offLocationTime == 0 && dataSize == 0) {
                // no off locations to process => completed = true
                offLocScenario = 'first';
            } else if(offLocationTime > 0 && dataSize > 0 && data == 0) {
                // off locations processed, time logged => completed = true
                offLocScenario = 'first';
            } else if(offLocationTime == 0 && dataSize > 0 && data == 0) {
                // off locations processed, time not logged => completed = false
                offLocScenario = 'third';
            } else if(offLocationTime == 0 && dataSize > 0 && data > 0) {
                // off locations not processed => completed = false
                offLocScenario = 'fourth';
            /*} else if(offLocationTime > 0 && dataSize == 0 && data == 0) {
                // no off locations to process, time logged => completed = false
                offLocScenario = 'second';*/
            } else if(offLocationTime > 0 && dataSize > 0 && data > 0) {
                // off locations not processed, time logged => completed = false
                offLocScenario = 'fourth';
            }
            console.log('offlocScenario: ' + offLocScenario);
        }

        /*var deptTime = 0;
        var toolsTime = 0;
        var floorTime = 0;
        var gardenTime = 0;
        var otherTime = 0;
        console.log('toolsHour: ' + component.get("v.toolsHour"));
        if(parseInt(component.get("v.toolsHour")) > 0) {
            console.log('toolsHour if in');
            toolsTime = parseInt(toolsTime) + (parseInt(component.get("v.toolsHour")) * 60);
        }
        if(parseInt(component.get("v.toolsMin")) > 0) {
            toolsTime = parseInt(toolsTime) + parseInt(component.get("v.toolsMin"));
        }
        console.log('toolsTime: ' + toolsTime);
        console.log('floorHour: ' + component.get("v.floorHour"));
        if(parseInt(component.get("v.floorHour")) > 0) {
            console.log('floorHour if in');
            floorTime = parseInt(floorTime) + (parseInt(component.get("v.floorHour")) * 60);
        }
        if(parseInt(component.get("v.floorMin")) > 0) {
            floorTime = parseInt(floorTime) + parseInt(component.get("v.floorMin"));
        }
        console.log('floorTime: ' + floorTime);
        console.log('gardenHour: ' + component.get("v.gardenHour"));
        if(parseInt(component.get("v.gardenHour")) > 0) {
            console.log('gardenHour if in');
            gardenTime = parseInt(gardenTime) + (parseInt(component.get("v.gardenHour")) * 60);
        }
        if(parseInt(component.get("v.gardenMin")) > 0) {
            gardenTime = parseInt(gardenTime) + parseInt(component.get("v.gardenMin"));
        }
        console.log('gardenTime: ' + gardenTime);
        console.log('otherHour: ' + component.get("v.otherHour"));
        if(parseInt(component.get("v.otherHour")) > 0) {
            console.log('otherHour if in');
            otherTime = parseInt(otherTime) + (parseInt(component.get("v.otherHour")) * 60);
        }
        if(parseInt(component.get("v.otherMin")) > 0) {
            otherTime = parseInt(otherTime) + parseInt(component.get("v.otherMin"));
        }
        console.log('otherTime: ' + otherTime);
        deptTime = parseInt(toolsTime) + parseInt(floorTime) + parseInt(gardenTime) + parseInt(otherTime);
        if(deptTime == 0) {
            deptError = 'noTime';
        } else if(eventTotalTimeInMinutes != deptTime) {
            console.log('deptTime Error: ' + eventTotalTimeInMinutes + ' != ' + deptTime);
            deptError = 'notEqual';
        }
        */


        
        if (totalcalculatedtime == eventTotalTimeInMinutes && offLocScenario == 'first' && totalDeptTime == eventTotalTimeInMinutes) {
            console.log('first if');
            component.set("v.isTimeIncrease", true);
        } else if ((totalcalculatedtime > eventTotalTimeInMinutes) || (totalDeptTime > eventTotalTimeInMinutes)) {
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'You are exceeding the Total Time, please correct it and then proceed');
            component.set("v.headerOnDialogBox", "Warning");
        } else if(offLocScenario == 'fourth') { 
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'You still have active Off Locations remaining to be reviewed');
            component.set("v.headerOnDialogBox", "Warning");
        } else if(offLocScenario == 'third' && calledFrom == 'FromParent') {
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'Please allocate time spent on Key Off Location Management validation activity');
            component.set("v.headerOnDialogBox", "Warning");
        } else if ((((totalcalculatedtime < eventTotalTimeInMinutes) || (totalDeptTime < eventTotalTimeInMinutes)) && calledFrom == 'FromParent')) {
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'Your submitted time does not match with the Total Time');
            component.set("v.headerOnDialogBox", "Warning");
        } else if(totalDeptTime <= 0 && calledFrom == 'FromParent') {
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'You have not allocated any time to the Department.');
            component.set("v.headerOnDialogBox", "Warning");
        } else if (totalDeptTime < eventTotalTimeInMinutes && calledFrom == 'FromParent') {
            component.set("v.isTimeIncrease", false);
            component.set("v.messageOnDialogBox", 'Your Department Allocated time does not match the Total Event Time.');
            component.set("v.headerOnDialogBox", "Warning");
        }
    },

    /* START OF OFF LOCATION LOGIC */
    fetchData: function (component, actionDone) {
        var dataPromise;
        const action = component.get("c.getOffLocation");
        const accId = component.get("v.accId");
        const recordId = component.get("v.recordId");
        action.setParams({ accId,
                            recordId});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            console.log('state: ' + JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                const data = response.getReturnValue().map(record => {
                    const updatedRec = record;
                    updatedRec.locationProduct = record.Off_Location_Product__r ? record.Off_Location_Product__r.Name : null;
                  return updatedRec;
                });
                component.set('v.rawData', data);
                console.log("set from Fetch");
                //call for filter of columns
                this.updateBooks(component);

                this.getColumnDefinitions(component);
                if(actionDone != null) {
                    this.checkForExistingRecords(component);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    getColumnDefinitions: function (component) {
        console.log('getColumnDefinitions');
        this.getOffLocations(component);
        var activeFilter = component.get("v.activeFilter");
        var offLocations = component.get("v.offLocationList");
        var headerActions = offLocations.map(offLocation => ({
            label: offLocation,
            checked: offLocation === activeFilter,
            name: offLocation
        }));
        headerActions.unshift({
            label: 'All',
            checked: activeFilter === "all",
            name:'all'
        });

        var columns = [
            /*{label: 'Off Location Reference', 
                fieldName: 'Name', 
                type: 'text',
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true
            },*/
            {label: 'SAP Material Number', 
                fieldName: 'SAP_Material_Number__c', 
                type: 'text',
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true },
            {label: 'Product Name', 
                fieldName: 'locationProduct', 
                type: 'text', 
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true },
            {label: 'Bunnings Fineline', 
                fieldName: 'Bunnings_Fineline__c', 
                type: 'text', 
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true },
            {label: 'Store Location', 
                fieldName: 'In_store_Location__c', 
                type: 'text', 
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true,
                actions: headerActions
            },
            {label: 'Account Type', 
                fieldName: 'Trade_Area__c', 
                type: 'text', 
                hideDefaultActions: true,
                sortable: true, 
                wrapText: true }
        ];
        component.set("v.columns", columns);
        return columns;
    },

    saveOffLocation: function(component, event, actionDone) {
        console.log("actionDone: " + actionDone);
        component.set("v.showSpinner", true);
        const action = component.get("c.doSaveOffLocationChanges");
        var data = component.get("v.data");
        var selectedRows = component.get("v.selectedRows");
        var selectedData = data.filter(record => selectedRows.includes(record.Id));
        console.log(JSON.stringify(selectedData));
        action.setParams({ "inputArgument": JSON.stringify(selectedData),
                            "action": actionDone,
                            "recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            console.log('state: ' + JSON.stringify(response.getState()));
            // console.log('return: ' + JSON.stringify(response.getError));
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                this.handleSuccessShowToast(component, "Off Locations updated successfully.");
                component.set("v.selectedRows", []);
                this.fetchData(component, actionDone);
                console.log("selectedRows: " + component.get("v.selectedRowsCount"));
            }
            else if (state === "ERROR") {
                component.set("v.showSpinner", false);
            }
            this.showChecklist(component);
        });

        $A.enqueueAction(action);
    },

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    updateBooks: function (component) {
        var rows = component.get("v.rawData");
        var activeFilter = component.get("v.activeFilter");
        var filteredRows = rows;
        if (activeFilter !== "all") {
            // var regex = new RegExp(activeFilter);
            // filteredRows = rows.filter(row => regex.test(row.In_store_Location__c));
            filteredRows = rows.filter(row => row.In_store_Location__c === activeFilter);
        }
        component.set("v.data", filteredRows);
    },

    getOffLocations: function (component) {
        var rows = component.get("v.rawData");
        var offLocations = rows.reduce((offLocations, row) => {
            if(!offLocations.includes(row.In_store_Location__c)){
                offLocations.push(row.In_store_Location__c);
            }
            return offLocations;
        }, []);
        component.set("v.offLocationList", offLocations);

    },

    showChecklist: function (component) {
        component.set("v.showChecklistSection", true);
        component.set("v.showOffLocationSection", false);
    },

    checkForExistingRecords: function (component) {
        console.log("rawData: " + component.get("v.rawData").length);
        if(component.get("v.rawData").length == 0) {
            this.showChecklist(component);
            this.handleSuccessShowToast(component, "Off Locations check completed.");
        }
    }
    /* END OF OFF LOCATION LOGIC */
})