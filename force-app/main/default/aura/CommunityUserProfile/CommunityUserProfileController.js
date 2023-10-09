({
    
    doInit : function(component, event, helper) {
        let utilityMethods = component.find('utilityMethods');

        helper.getSiteDetails(component)
        .then(response => {
            component.set("v.siteObj", response);

            return helper.getPicklistValues(component, utilityMethods);
        })
        .then(response => {

            helper.handlePicklistValues(component, response);

            component.find("userRecordCreator").reloadRecord(true, () => {
                helper.populateLabels(component);       
                component.set("v.isRecordLoaded", true);

                component.set("v.oldFormObj", helper.constructFormObj(component));
            }); 
        });     
    },

    /**
     * Control the component behavior here when record is changed (via any component)
     */
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            
            var changedFields = eventParams.changedFields;
            // record is changed, so refresh the component (or other component logic)
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "message": "The record was updated."
            });
            resultsToast.fire();

            component.find("userRecordCreator").reloadRecord(true);
        } else if(eventParams.changeType === "LOADED") {
            component.find("accRecordCreator").reloadRecord(true);
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log(JSON.stringify(eventParams));
            console.log(component.get("v.accountError"));
            // there’s an error while loading, saving or deleting the record
        }
    },

    handleAccUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            
            var changedFields = eventParams.changedFields;
            // record is changed, so refresh the component (or other component logic)
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "message": "The record was updated."
            });
            resultsToast.fire();

            component.find("accRecordCreator").reloadRecord();
        } else if(eventParams.changeType === "LOADED") {
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log(JSON.stringify(eventParams));
            console.log(component.get("v.userError"));
            // there’s an error while loading, saving or deleting the record
        }
    },

    handleSuccess: function(component, event, helper) {
        var updateUsername = component.get("c.updateUsername");

        $A.enqueueAction(updateUsername);
    },

    handleSaveRecord: function(component, event, helper) {

        if (helper.validateForm(component)) {
            const disAddress = component.get("v.disAddress");
            const formObj = helper.constructFormObj(component);

            helper.populateAccount(component, formObj);

            component.find("userRecordCreator").saveRecord(() => {
                component.find("accRecordCreator").saveRecord();
            });
            component.set('v.contactEdit', false);
            helper.showViewForm(component);
        } else {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "",
                "message": "Please update the invalid form entries and try again."
            });
            resultsToast.fire();
        }
    },

    toggleView : function(component, event, helper) {
        var oldFormObj = component.get("v.oldFormObj");
        oldFormObj = JSON.parse(JSON.stringify(oldFormObj));
        var target = event.getSource().getLocalId();

        if(target == 'cancelBtn' || target == 'editBtn') {
            if(component.get('v.contactEdit') == true) {
                component.set('v.contactEdit', false);
                helper.showViewForm(component);

                if (target == 'cancelBtn') {
                debugger;
                    helper.populateEditForm(component, oldFormObj);
                }
            } else {
                component.set('v.contactEdit', true);
                helper.showEditForm(component);
            }           
        }
    },

    keyUpHandler: function (component, event, helper) {
        
        var searchString = component.get("v.searchString");
        if(searchString != '' && searchString != null){
            helper.openListbox(component, searchString);
            helper.displayPredictions(component, searchString);
        } else {            
            helper.clearComponentConfig(component);        
        }
        
    },
    
    selectOption: function (component, event, helper) {  
        
        var list = component.get("v.predictions");        
        var placeId = component.get("v.placeId");        
        var searchLookup = component.find("searchLookup");        
        var iconPosition = component.find("iconPosition");        
        var selection  = event.currentTarget.dataset.record;      

        for (var i =0; i < list.length; i++) {         
            if (list[i].label == selection ) {  
                
                placeId = (list[i].PlaceId);                
            }            
        }
        
        component.set("v.selectedOption ", selection);        
        component.set("v.searchString", selection);        
        
        $A.util.removeClass(searchLookup, 'slds-is-open');        
        $A.util.removeClass(iconPosition, 'slds-input-has-icon_left');        
        $A.util.addClass(iconPosition, 'slds-input-has-icon_right');
   
        helper.displaySelectionDetails(component, placeId);
        
        
    },
    
    clear: function (component, event, helper) {        
        helper.clearComponentConfig(component);        
    },
    onCheck:function (component, event, helper) {
        var checkdisAdd = component.get("v.disAddress");
        
        if(checkdisAdd == true){
            component.set("v.disAddress",false);
        }else{
            component.set("v.disAddress",true);
        }
        helper.clearComponentConfig(component); 
    },
})