({
    doInit: function(component, event, helper) {

    },
    doSearch: function(component, event, helper) {
        // Francis Nasalita - Added throttling mechanism this will prevent the search from occurring while the user is still typing 
        // Cancel previous timeout if any
        let searchTimeout = component.get('v.searchTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }

        // Set new timeout
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                // Send search request
                helper.searchHandler(component, event);

                // Clear timeout
                component.set('v.searchTimeout', null);
            }),
            1000 // Wait for 1000ms/1sec before sending search request
        );
        
        component.set('v.searchTimeout', searchTimeout);            
    },
    getRecordJS: function(component, event, helper) {
        var SelectedItemName = component.get("v.SelectedItemName");
        console.log('DBG: SelectedItemName > ', SelectedItemName);
        if(SelectedItemName != null && SelectedItemName != '' ) {
            if(component.get("v.hasSelected")) return;
            if(SelectedItemName.length < 3) return;

            /* commented out SP-848
            var sobjectName = component.get("v.SobjectName");
            var dynamicValueObject = component.get("v.dynamicValueObject");
            var dynamicValueObject2 = component.get("v.dynamicValueObject2");
            var SelectedItemName = component.get("v.SelectedItemName")
            var sparePart = 'Spare Part'
            var whereQueryString = component.get("v.whereQueryString");
            console.log("DBG: whereQueryString1 >>> ", whereQueryString);

            if (dynamicValueObject != undefined) {
                console.log('DBG: dynamicValueObject >>> ', dynamicValueObject);
                whereQueryString = whereQueryString.replace("dynamicValueObject", "'" + dynamicValueObject + "'");
            }
            if (dynamicValueObject2 != undefined) {
                console.log('DBG: dynamicValueObject2 >>> ', dynamicValueObject2);
                whereQueryString = whereQueryString.replace("dynamicValueObject2", "'" + dynamicValueObject2 + "'");
            }
            if (SelectedItemName != undefined) {
                whereQueryString = whereQueryString.replace(":searchString", "'%" + SelectedItemName + "%'");
            }

            // whereQueryString = whereQueryString.replace("Spare Part", "'" + sparePart + "'");

            console.log('DBG: qs');
            console.log("DBG: whereQueryString2 >>> ", whereQueryString);

            var searchAction = component.get("c.getRecord");
                searchAction.setParams({
                    "whereQuery": whereQueryString,
                    "objName": sobjectName,
                    "ParentFieldsToQuery": component.get("v.ParentFieldsToQuery")
                });
                searchAction.setCallback(this, function(response) {

                    var result = response.getReturnValue();
                    var selectedItemObj = component.get("v.SelectedItemObject");

                    $A.util.addClass(component.find("searchinprogressbox"), 'slds-hide');
                    if (response.getState() == 'SUCCESS' && !($A.util.isEmpty(response.getReturnValue()))) {
                        component.set("v.listObj", response.getReturnValue());
                        var selectedObjectApiName = sobjectName;
                        var selectedObject = response.getReturnValue()[0];
                        component.set("v.SelectedItemObject", selectedObject);
                        var currSelection = selectedObject.Name;
                        if (component.get("v.displayProdCode")) {
                            currSelection = selectedObject.ProductCode;
                        }
                        var currentAdress = '';
                        component.set("v.SelectedItemName", currSelection);
                        component.set("v.SelectedItemId", selectedObject.Id);

                        var compEvent = component.getEvent("getSelectedObjectFromSearch");
                        compEvent.setParams({
                            "sObject": selectedObject,
                            "selectedObjectApiName": selectedObjectApiName,
                            "SobjectLabel": component.get("v.SobjectLabel"),
                            "objectIndexInList": component.get("v.objectIndexInList")
                        });
                        compEvent.fire();
                    }

                    if(response.getReturnValue() != null && response.getReturnValue().length != 0) {
                        component.set("v.hasSelected", true);
                        $A.util.removeClass(component.find("lookup"), 'errorBox');
                        $A.util.addClass(component.find("lookuplist"), 'slds-hide');
                    } else {
                        component.set("v.hasSelected", false);
                        $A.util.addClass(component.find("lookup"), 'errorBox');
                    }

                });

            $A.enqueueAction(searchAction);*/
        }  
    },
    select: function(component, event, helper) {
        component.set("v.hasSelected", true);
        var lstobject = component.get("v.listObj");
        var selectedObjectApiName = component.get("v.SobjectName");
        var currSelectionIndex = event.currentTarget.id;
        var selectedObject = lstobject[currSelectionIndex];
        component.set("v.SelectedItemObject", selectedObject);
        var currSelection = selectedObject.Name;
        if (component.get("v.displayProdCode")) {
            currSelection = selectedObject.ProductCode;
        }
        
        var currentAdress = '';
        component.set("v.SelectedItemName", currSelection);
        component.set("v.SelectedItemId", selectedObject.Id);
        $A.util.addClass(component.find("lookuplist"), 'slds-hide');        
        
        var disableNextBtnEvent = component.getEvent("disableNxtBtnEvt");
        disableNextBtnEvent.setParams({
            "isDisabled": false
        });
        disableNextBtnEvent.fire();
        
        var compEvent = component.getEvent("getSelectedObjectFromSearch");
        compEvent.setParams({
            "sObject": selectedObject,
            "selectedObjectApiName": selectedObjectApiName,
            "SobjectLabel": component.get("v.SobjectLabel"),
            "objectIndexInList": component.get("v.objectIndexInList")
        });
        compEvent.fire();

    },
    serviceAgentvalidation: function(component, event, helper) {
        var currSelection = component.get("v.SelectedItemName");
        var ServiceAgentID = component.find("lookup");
        if ($A.util.isUndefinedOrNull(currSelection)) {
            ServiceAgentID.set("v.errors", [{ message: "You cannot proceed to the next step until you select a service agent" }]);
            return false;
        } else {
            ServiceAgentID.set("v.errors", [{ message: "" }]);
            return true;
        }
    },
    disableBtn: function(component, event, helper) {
       var compEvent = component.getEvent("disableNxtBtnEvt");
            compEvent.setParams({
                "isDisabled": true
            });
            compEvent.fire();
    }
})