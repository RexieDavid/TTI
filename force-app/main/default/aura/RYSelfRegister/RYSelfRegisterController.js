({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({ "qsToEvent": helper.qsToEventMap }).fire();
        component.set('v.extraFields', helper.getExtraFields(component));
        helper.initializeCustomSettings(component);
        helper.checkCountry(component);
    },

    handleSelfRegister: function(component, event, helper) {
        helper.handleSelfRegister(component);
    },

    setStartUrl: function(component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    onKeyUp: function(component, event, helper) {
        if (event.getParam('keyCode') === 13) {
            helper.handleSelfRegister(component, event, helper);
        }
    },

    subscribe: function(component, event, helper) {
        var subscribed = component.get('v.subscribed');
        component.set('v.subscribed', subscribed === false);
    },

    handleMobileChange: function(component, event, helper) {
        let mobile = component.get('v.mobileNum');

        if (isNaN(mobile) || mobile.includes(' ')) {
            component.set('v.mobileNum', mobile.substring(0, mobile.length - 1));
        }
    }
})