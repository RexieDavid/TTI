({
    handleForgotPassword: function (component, event, helper) {
        var username = component.find("username").get("v.value");
        //alert('username: ' + username);
        var checkEmailUrl = component.get("v.checkEmailUrl");
        //alert('Email: ' +checkEmailUrl);
        var action = component.get("c.forgotPassword");
        //alert('action: ' +action);
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        //action.setParams({username:username});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            //alert('rtnValue: '+ rtnValue);
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
       });
        $A.enqueueAction(action);
    }
})