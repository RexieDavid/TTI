({
	init: function (component, event, helper) {
        const flowName = component.get('v.TrainingManagementFlowName');
        const flowContainer = component.find('offLocation');
        
        flowContainer.startFlow(flowName);
    },
    
    handleStatusChange: function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            event.preventDefault();

            const sObjectName = component.get('v.sObjectName');
            var navService = component.find("navService");
            var pageReference;

            component.find('notifLib').showToast({
                "title": "Training Modules created successfully",
                "mode": "pester",
                "variant": "success",
            }); 
            navService.navigate(pageReference);
        }
    },

    closeQuickAction: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})