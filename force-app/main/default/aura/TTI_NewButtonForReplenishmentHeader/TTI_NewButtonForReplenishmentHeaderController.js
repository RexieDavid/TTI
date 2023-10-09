({
    redirectToReplenishment: function (component, event, helper) {
        var getReplenishmentURL = component.get("c.getNewReplenishmentButton");
        getReplenishmentURL.setCallback(this, function (response) {
            var retVal = response.getReturnValue();
            if (retVal != null) {
                window.location.href = retVal;
            }
        });
        $A.enqueueAction(getReplenishmentURL);
    }
})