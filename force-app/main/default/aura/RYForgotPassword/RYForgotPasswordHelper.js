({
    handleForgotPassword: function (component, event, helper) {
        var username = component.find("email").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassword");
        action.setParams({username: username, checkEmailUrl: checkEmailUrl});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            } else if (state === "ERROR") {
                component.set("v.errorMessage", response.getError()[0].message);
                component.set("v.showError", true);
            }
        });
        $A.enqueueAction(action);
    }
})