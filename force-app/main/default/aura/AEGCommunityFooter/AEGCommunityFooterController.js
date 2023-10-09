({
    doInit: function(component, event, helper) {
        const countryCode = component.get('v.countryCode');
        helper.initializeCustomSettings(component, countryCode);
        helper.setCustomerServiceHotline(component, countryCode);
    },
})