({  
    getSiteDetails: function(component) {
        return new Promise($A.getCallback(( resolve , reject ) => {
            var getDetails = component.get("c.getDetails");

            getDetails.setCallback(this, response => {
                resolve(response.getReturnValue());
            });
            
            $A.enqueueAction(getDetails);
        }));
    },

    populateLabels: function(component) {
        const conFields = [     
            {id : "title", field: "Title", required: true, mapTo: 'Salutation', isDisplayed: true},
            {id : "firstName", field: "FirstName", required: true, mapTo: 'FirstName', isDisplayed: true},
            {id : "lastName", field: "LastName", required: false, mapTo: 'LastName', isDisplayed: true},
            {id : "mobilePhone", field: "MobilePhone", required: true, mapTo: 'PersonMobilePhone', isDisplayed: true},
            {id : "phone", field: "Phone", required: true, mapTo: 'PersonHomePhone', isDisplayed: true},
            {id : "email", field: "Email", required: false, mapTo: 'PersonEmail', isDisplayed: true},
            {id: "customerType", field: "Customer_type__c", required: false, mapTo: 'Type', isDisplayed: true},
            {id: "username", field: "Username", required: false, mapTo: null, isDisplayed: false}
        ];

        const addressFields = [
            {id : "street", label: "Street", field: "Street", required: true, mapTo: 'PersonMailingStreet', isDisplayed: true},
            {id : "city", label: "Suburb", field: "City", required: true, mapTo: 'PersonMailingCity', isDisplayed: true},
            {id : "state", label: "State", field: "State", required: true, mapTo: 'PersonMailingState', isDisplayed: true},
            {id : "postcode", label: "PostalCode", field: "PostalCode", required: true, mapTo: 'PersonMailingPostalCode', isDisplayed: true},
            {id : "country", label: "Country", field: "Country", required: true, mapTo: ['PersonMailingCountry','Country__pc'], isDisplayed: true},
        ];

        component.set("v.conctactLabels", conFields);
        component.set("v.addressLabels", addressFields);
    },

    getPicklistValues: function(component, utilityMethods) {
        return new Promise($A.getCallback(function(resolve, reject) {
            utilityMethods.getPicklistValues({
                'Account' : ['Profession__c','Salutation','Type','Employee_Size__c'],
                'User' : ['Customer_type__c']
            }, resolve, reject);
        }));
    },

    handlePicklistValues: function(component, value) {
        let responseVal = JSON.parse(value);

        // iterate through objects
        for (let objName of Object.keys(responseVal.value)) {  
            let picklists = responseVal.value[objName];

            // iterate through picklist fields
            for(let picklist of Object.keys(picklists)) {
                let picklistValues = picklists[picklist];
                let hasDefaultVal = false;

                // iterate through picklist values to check for default value
                for(let i = 0; i < picklistValues.length; i++) {
                    if(picklistValues[i].defaultValue == true) {
                        hasDefaultVal = true;
                        break;
                    }
                }

                // add --Select-- value to the picklist
                picklistValues.unshift({
                    active: true,
                    defaultValue: !hasDefaultVal,
                    label: "--Select--",
                    validFor: null,
                    value: null
                });

                // populate picklists
                if (objName == 'Account') {
                    if (picklist == 'Profession__c') 
                        component.set("v.professionOptions", picklistValues);
                    if (picklist == 'Salutation') 
                        component.set("v.titleOptions", picklistValues);
                    if (picklist == 'Employee_Size__c') 
                        component.set("v.employeeSizeOptions", picklistValues);

                } else if (objName == 'User') {
                    if (picklist == 'Customer_type__c') {
                        
                        let tempPicklistvalues = [];           
                        for(let i = 0; i < picklistValues.length; i++)  {
                            if (i == 0) {
                                tempPicklistvalues.push(picklistValues[i]);
                                continue;
                            }

                            if (picklistValues[i].label.includes('Individual') || picklistValues[i].label.includes('Business')) 
                                tempPicklistvalues.push(picklistValues[i]);                                     
                        }
                        picklistValues = tempPicklistvalues;                            

                        component.set("v.customerTypeOptions", picklistValues);                      
                        
                    }
                }
            }                    
        }
    },

    constructFormObj: function(component) {
        var simpleUser = component.get("v.simpleUser");
        const fields = component.get("v.conctactLabels");
        fields.push(...component.get("v.addressLabels"));
        let formObj = {};

        for (var key in fields) {
            var el = fields[key];
            formObj[el.id] = {
                value: simpleUser[el.field],
                field: el.field,
                required: el.required,
                mapTo: el.mapTo,
                isDisplayed: el.isDisplayed
            };
        }
        return formObj;
    },

    validateForm: function(component) {
        return component.find('formField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
    },

    populateAccount: function(component, formObj) {
        var simpleAcc = JSON.parse(JSON.stringify(component.get("v.simpleAcc")));
        var simpleUser = JSON.parse(JSON.stringify(component.get("v.simpleUser")));
        
        for (var key in formObj) {
            const field = formObj[key].field;
            const val = simpleUser[field];

            if (formObj[key].mapTo === null) continue; 
            
            if (Array.isArray(formObj[key].mapTo)) {            
    
                formObj[key].mapTo.forEach(el => {
                    if (el.includes('.')) {
                        const field = el.split('.');
                        simpleAcc[field[0]][field[1]] = val;
                    } else {
                        simpleAcc[formObj[key].mapTo] = val;
                    }
                });             
            } else {            
                if (formObj[key].mapTo.includes('.')) {
                    const field = formObj[key].mapTo.split('.');
                    simpleAcc[field[0]][field[1]] = val;
                } else {
                    simpleAcc[formObj[key].mapTo] = val;
                }
            }
        }

        component.set("v.simpleAcc", simpleAcc);
    },

    showEditForm: function(component) {
        const self = this;

        $A.util.addClass(component.find('shipViewDetails'), 'slds-hide');
        $A.util.removeClass(component.find('shipEditDetails'), 'slds-hide');
        $A.util.addClass(component.find('conViewDetails'), 'slds-hide');
        $A.util.removeClass(component.find('conEditDetails'), 'slds-hide');

        self.hideComponent(component.find('editBtn'));
        self.showComponent(component.find('conDetailsButtons'));
    },

    populateEditForm: function(component) {
        component.find("userRecordCreator").reloadRecord();
        component.find('formField').forEach(function (el) {
            el.showHelpMessageIfInvalid();
        });
    },

    showViewForm: function(component) {
        const self = this;

        $A.util.removeClass(component.find('shipViewDetails'), 'slds-hide');
        $A.util.addClass(component.find('shipEditDetails'), 'slds-hide');
        $A.util.removeClass(component.find('conViewDetails'), 'slds-hide');
        $A.util.addClass(component.find('conEditDetails'), 'slds-hide');

        self.showComponent(component.find('editBtn'));
        self.hideComponent(component.find('conDetailsButtons'));
    },

    hideComponent : function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },
    
    showComponent : function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    displayPredictions: function (component, searchString) {
        
        var selectedCountry = '';
        const siteObj = component.get("v.siteObj");
        if (siteObj.siteLabel.toUpperCase().includes('NZ')) {
            selectedCountry = 'nz';
        } else {
            selectedCountry = 'au';
        }

        var action = component.get("c.getAddressAutoComplete");   
        action.setParams({   
            "input": searchString,
            "countryname": selectedCountry
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());                
                var predictions = options.predictions;                
                var addresses = [];
                
                if (predictions.length > 0) {                    
                    for (var i = 0; i < predictions.length; i++) {                        
                        addresses.push(
                            {
                                value: predictions[i].types[0],
                                label: predictions[i].description,
                                PlaceId: predictions[i].place_id,
                            });
                    }
                    
                    component.set("v.predictions", addresses);
                    
                }                
            }            
        });        
        $A.enqueueAction(action);
        
    },
    
    displaySelectionDetails: function(component, placeId) {        
        var action = component.get("c.getAddressDetails");
        
        action.setParams({            
            "PlaceId": placeId            
        });
        
        action.setCallback(this, function (response) {
            
            var state = response.getState();

            if (state === "SUCCESS") {
                var option = JSON.parse(response.getReturnValue());                
                var address = option.result;                
                var key = "address_components";                
                var selection = address[key];
                this.insertRecords(component, selection);                
            }            
        });
        $A.enqueueAction(action);
        
        
    },
    
    insertRecords:function(component, data, phone, company){  
        var pattern = /^([0-9])*\/(\d)*$/g;    
        var hasStreetNumber = false;
        var hasSubpremise = false;
        var streetNumberVal = 'subpremise/street_number';
        var simpleUser = component.get("v.simpleUser");
        var userInput = component.find('googleInput').get("v.value").split(',')[0];

        var fullstreetname = '';
        for(var prop in data) {            
            if (data[prop].types[0] == "locality") {
                simpleUser.City = data[prop].long_name;
            }
            
            if (data[prop].types[0] == "postal_code") {
                simpleUser.PostalCode = data[prop].long_name;
            }
            
            if (data[prop].types[0] == "country") {
                simpleUser.Country = data[prop].long_name;
            }
            
            if (data[prop].types[0] == "administrative_area_level_1") {
                simpleUser.State = data[prop].long_name;
            }

            if (data[prop].types[0] == 'subpremise' || data[prop].types[0] == 'street_number') {
                if(data[prop].types[0] == 'subpremise') hasSubpremise = true;
                if(data[prop].types[0] == 'street_number') hasStreetNumber = true;

                if (data[prop].long_name == '') {
                    if (data[prop].types[0] == 'subpremise') streetNumberVal = streetNumberVal.replace("subpremise", '');
                    if (data[prop].types[0] == 'street_number') streetNumberVal = streetNumberVal.replace("street_number", '');
                } else {
                    if (data[prop].types[0] == 'subpremise') streetNumberVal = streetNumberVal.replace("subpremise", data[prop].long_name);
                    if (data[prop].types[0] == 'street_number') streetNumberVal = streetNumberVal.replace("street_number", data[prop].long_name);
                }
            }

            streetNumberVal = (streetNumberVal.includes('subpremise')) ? streetNumberVal.replace("subpremise", "") : streetNumberVal;
            streetNumberVal = (streetNumberVal.includes('street_number')) ? streetNumberVal.replace("street_number", "") : streetNumberVal;
            if (streetNumberVal.charAt(0) == '/' || streetNumberVal.charAt(streetNumberVal.length - 1) == '/') {
                streetNumberVal = streetNumberVal.replace('/', '');
            }

            if(hasSubpremise || hasStreetNumber) {
                if(userInput.includes(streetNumberVal)) {
                    streetNumberVal = userInput;
                }
            }

            simpleUser.Street = streetNumberVal;
        }

        component.set("v.simpleUser", simpleUser);
        component.find('formField').forEach(function (el) {
            el.showHelpMessageIfInvalid();
        });
        
    },
    
    openListbox: function (component, searchString) {
        const self = this;
        
        var searchLookup = component.find("searchLookup");
        
        if (typeof searchString === 'undefined' || searchString.length < 3) {
            
            $A.util.addClass(searchLookup, 'slds-combobox-lookup');            
            $A.util.removeClass(searchLookup, 'slds-is-open');
            return;
        }
        
        $A.util.addClass(searchLookup, 'slds-is-open');        
        $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
        
    },
    
    clearComponentConfig: function (component) {
        $A.util.addClass(component.find("searchLookup"), 'slds-combobox-lookup');

        $A.util.removeClass(component.find("iconPosition"), 'slds-input-has-icon_right');
        $A.util.addClass(component.find("iconPosition"), 'slds-input-has-icon_right');

        var simpleUser = component.get("v.simpleUser");
        var addressEl = component.get("v.addressLabels");
        for (var key in addressEl) {
            var field = addressEl[key].field;
            simpleUser[field] = '';
        }
        
        component.set("v.selectedOption", null);
        component.set("v.searchString", null);
        component.set("v.simpleUser", simpleUser);
        
    }
    
})