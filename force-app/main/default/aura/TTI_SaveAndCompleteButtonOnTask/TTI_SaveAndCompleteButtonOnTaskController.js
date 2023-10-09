({
    updateStatus : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateStatusOfTask");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire(); 
            var updateStatusOfTaskState = response.getState();
            var updateStatusOfTaskValue = response.getReturnValue();
            if (updateStatusOfTaskState === "SUCCESS" && updateStatusOfTaskValue===null) {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
            }
            if(updateStatusOfTaskState === "SUCCESS" && !$A.util.isUndefinedOrNull(updateStatusOfTaskValue) && updateStatusOfTaskValue.includes("You must specify an outcome if you wish to complete this task")){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message": "You must specify an outcome if you wish to complete this task."
                });
                toastEvent.fire(); 
            }
            
        });
        $A.enqueueAction(action);  
    }
})