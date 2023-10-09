({
    doInit: function(component, event, helper) {
        helper.initializeCustomSettings(component);
    },

    navigateToRegisterProduct: function(component, event, helper) {
        helper.navigateTo(component.get('v.registerProductURL'));
    },

    navigateToToolbag: function(component, event, helper) {
        helper.navigateTo(component.get('v.toolBagURL'));
    },

    navigateToRedemptions: function(component, event, helper) {
        helper.navigateTo(component.get('v.redemptionsURL'));
    }
})