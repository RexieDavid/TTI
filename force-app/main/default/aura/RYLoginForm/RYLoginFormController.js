({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
    },
    
    handleLogin: function (component, event, helper) {
        helper.handleLogin(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    onKeyUp: function(component, event, helper){
        const enterKey = 13;
        if (event.keyCode === enterKey) {
            helper.handleLogin(component, event, helper);
        }
    }
})