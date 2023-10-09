({
    onuploadfinished : function(component, event, helper) {
        component.set("v.showSpinnerBlock", true);
        var action = component.get("c.handleOnuploadfinished");
        action.setParams
        ({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinnerBlock", false);
                component.set("v.listOfFiles", response.getReturnValue());
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()) && 
                   response.getReturnValue().length > 0){
                    component.set("v.isFileAttached", true);
                }
                else{
                    component.set("v.isFileAttached", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    removeDocument : function(component, event, helper) {
        component.set("v.showSpinnerBlock", true);
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        var listOfFiles = component.get("v.listOfFiles");
        var documentId = listOfFiles[index].ContentDocument.Id;
        var action = component.get("c.handleRemoveDocument");
        action.setParams
        ({
            "recordId" : component.get("v.recordId"),
            "documentId" : documentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinnerBlock", false);
                component.set("v.listOfFiles", response.getReturnValue());
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()) && 
                   response.getReturnValue().length > 0){
                    component.set("v.isFileAttached", true);
                }
                else{
                    component.set("v.isFileAttached", false);
                }
            }
        });
        $A.enqueueAction(action);
    }
})