({
    handleForgotPassword: function (component, event, helper) {
        helper.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helper){
    //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleForgotPassword(component, event, helper);
        }
    }
})