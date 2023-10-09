({
    handleForgotPassword: function(component, event, helper) {
        helper.handleForgotPassword(component, event, helper);
    },

    onKeyUp: function(component, event, helper) {
        const enterKey = 13;
        //checks for "enter" key
        if (event.keyCode === enterKey) {
            helper.handleForgotPassword(component, event, helper);
        }
    }
})