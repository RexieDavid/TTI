({
    doInit: function(component, event, helper) {
        helper.initializeCustomSettings(component);
        helper.getUserDetails(component);
        helper.convertCountryNameToCode(component);
    },

    navigateToRegisterProduct: function(component, event, helper) {
        helper.navigateTo('/register-new-product/');
    },

    navigateToToolbag: function(component, event, helper) {
        helper.navigateTo('/my-tool-bag/');
    },

    navigateToProfile: function(component, event, helper) {
        helper.navigateToProfile('/profile/');
    }
})