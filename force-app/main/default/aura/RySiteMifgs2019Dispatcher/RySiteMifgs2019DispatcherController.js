({
    initialize : function(component, event, helper) {
        component.set("v.isSegmentationSectionShown", true);
        component.set("v.isSessionMgmtSectionShown", false);
    },

    handleStateUpdatedEvent : function(component, event, helper) {
        var state = event.getParam("state");
        var paId = event.getParam("personAccountId");

        console.log('DBG: stateUpdated event received. current state > ', state);

        if (state === "segmentationFinished") {
            component.set("v.isSegmentationSectionShown", false);

            component.set("v.personAccountId", paId);
            component.set("v.isSessionMgmtSectionShown", true);
        } else if (state === "sessionSelectionFinished") {
            component.set("v.isSegmentationSectionShown", true);

            component.set("v.personAccountId", null);
            component.set("v.isSessionMgmtSectionShown", false);
        } else {
            // modalToSessionMgmtCancelled
            component.set("v.isSegmentationSectionShown", false);
            component.set("v.isSegmentationSectionShown", true);
            // helper.showSnackbar(component);
            component.set('v.openSnacks', true);
        }

    },

    showSnackbar : function(component) {
        helper.showSnackbar(component);
    }
})