({
    handleForgotPassword: function(component, event, helper) {
        helper.handleForgotPassword(component);
    },

    onKeyUp: function(component, event, helper) {
        const enterKey = 13;
        if (event.keyCode === enterKey) {
            helper.handleForgotPassword(component);
        }
    }
})