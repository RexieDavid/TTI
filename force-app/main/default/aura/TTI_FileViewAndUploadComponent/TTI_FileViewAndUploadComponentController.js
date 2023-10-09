({
    doInit : function(component, event, helper) {
		helper.onuploadfinished(component, event, helper);
	},
	handleUploadFinished : function(component, event, helper) {
		helper.onuploadfinished(component, event, helper);
	},
    removeDocument : function(component, event, helper) {
		helper.removeDocument(component, event, helper);
	},
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    }
})