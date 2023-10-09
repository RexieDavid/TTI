({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({ "qsToEvent": helper.qsToEventMap }).fire();
        helper.getIsUsernamePasswordEnabled(component);
        helper.getIsSelfRegistrationEnabled(component);
        helper.getCommunityForgotPasswordUrl(component);
        helper.getCommunitySelfRegisterUrl(component)
    },

    handleLogin: function(component, event, helper) {
        helper.handleLogin(component, event, helper);
    },

    setStartUrl: function(component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    onKeyUp: function(component, event, helper) {
        const enterKey = 13;
        if (event.keyCode === enterKey) {
            helper.handleLogin(component, event, helper);
        }
    },

    navigateToForgotPassword: function(component, event, helper) {
        const forgotPasswordUrl = component.get("v.communityForgotPasswordUrl");
        if (!forgotPasswordUrl) {
            forgotPasswordUrl = component.get("v.forgotPasswordUrl");
        }
        const attributes = { url: forgotPasswordUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },

    navigateToSelfRegister: function(component, event, helper) {
        var selfRegistrationURL = component.get("v.communitySelfRegisterUrl");
        if (!selfRegistrationURL) {
            selfRegistrationURL = component.get("v.selfRegisterUrl");
        }
        var attributes = { url: selfRegistrationURL };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }
})