({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
       
        //component.set("v.ready", true);
        
    
        
    },
    afterScriptsLoaded: function (component, event, helpler) {
  
       
    },
    
    
    handleLogin: function (component, event, helpler) {

        helpler.handleLogin(component, event, helpler);
    },
    
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        //if (event.getParam('keyCode')===13) {
        if (event.getParams().keyCode===13) {
            helpler.handleLogin(component, event, helpler);
        }
    },
     onChange: function(component, event, helpler){
         //alert(component.get('v.usernameF'));
        //alert('s');
    },
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
    
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    } 
})