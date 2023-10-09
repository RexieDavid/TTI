({
    init: function (component) {
        var flow = component.find("flowData");
        flow.startFlow("AEG_Lead_Submission_Screen");
    },

    exitForm: function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
    }

})