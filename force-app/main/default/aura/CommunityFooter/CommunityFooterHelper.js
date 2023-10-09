({
    initializeCustomSettings: function(component) {
        const action = component.get("c.getSiteSettings");
        const custServiceAU = component.get("v.customerServiceAU");
        const custServiceNZ = component.get("v.customerServiceNZ");
        action.setCallback(this, function(response){
            const customSettingValues = response.getReturnValue();
            const country = customSettingValues.userCountry;
            component.set("v.siteSettings", customSettingValues.communitySettings);
            component.set("v.value", country.toUpperCase().includes('AU') ? true : false);
        });
        $A.enqueueAction(action);
    }
})