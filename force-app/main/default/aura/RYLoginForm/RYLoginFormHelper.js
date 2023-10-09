({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    handleLogin: function(component, event, helper) {
        var username = component.get("v.username");
        var password = component.get("v.password");
        var startUrl = component.get("v.startUrl");

        var action = component.get("c.login");
        action.setParams({username:username, password:password, startUrl:startUrl});
        
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            var errmessage = '';
            if (!username && !password) {
                errmessage = "Please enter Email and Password. If username and password were pre-filled, please type them in and try logging in again.";
                component.set("v.errorMessage", errmessage);
                component.set("v.showError", true);
            }
            else if (username && !password) {
                errmessage = "Enter a value in the Password field.";
                component.set("v.errorMessage", errmessage);
                component.set("v.showError", true);
            }
            else if (!username && password) {
                errmessage = "Enter a value in the Email field.";
                component.set("v.errorMessage", errmessage);
                component.set("v.showError", true);
            }
            else if (rtnValue !== null) {
                component.set("v.errorMessage", rtnValue);
                component.set("v.showError", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled: function(component, event, helper) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled: function(component, event, helper) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl: function(component, event, helper) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl: function(component, event, helper) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})