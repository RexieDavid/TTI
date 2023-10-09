({
    doInit: function(component, event, helper) {
        if (component.get("v.type") == 'receipt') {
            helper.showPDF(component, event, helper);
        } else {
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            setTimeout(function() { 
                $A.util.addClass(spinner, "slds-hide");
            }, 3000);            
        }
    }
})