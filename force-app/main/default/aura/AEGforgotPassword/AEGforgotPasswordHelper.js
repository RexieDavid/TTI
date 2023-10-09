({
    handleForgotPassword: function(component) {
        const username = component.find("email").get("v.value");
        const checkEmailUrl = component.get("v.checkEmailUrl");
        const action = component.get("c.forgotPassword");
        const isValid = this.validate(component);
        if (isValid) {
            action.setParams({ username, checkEmailUrl });
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    window.location.href = response.getReturnValue();
                } else if (state === "ERROR") {
                    component.set("v.errorMessage", response.getError()[0].message);
                    component.set("v.showError", true);
                }
            });
            $A.enqueueAction(action);
        }
    },

    validate: function(component) {
        const emailField = component.find('email');
        emailField.reportValidity();
        return emailField.get('v.validity').valid
    }
})