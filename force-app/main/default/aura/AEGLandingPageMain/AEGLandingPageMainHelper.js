({
    navigateTo: function(page) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    },

    initializeCustomSettings: function(component) {
        const countryCode = component.get('v.countryCode');
        const action = component.get("c.getSiteSettings");
        action.setCallback(this, function(response) {
            const settings= response.getReturnValue();
            component.set('v.registerProductURL', settings.Register_New_Product__c);
            component.set('v.toolBagURL', settings.My_Toolbag__c);
            component.set("v.redemptionsURL", settings.Redemption__c);
            this.setWarrantyURL(component, settings, countryCode);
            this.setPromotionsURL(component, settings, countryCode);
        });
        $A.enqueueAction(action);
    },

    setWarrantyURL: function(component, settings, countryCode) {
        const suffix = countryCode !== 'AU' ? '_NZ' : '';
        const warrantyURLField = `Warranty_URL${suffix}__c`;
        component.set("v.warrantyURL", settings[warrantyURLField]);
    },

    setPromotionsURL: function(component, settings, countryCode) {
        const suffix = countryCode !== 'AU' ? '_NZ' : '';
        const promotionsURLField = `Promotions_URL${suffix}__c`;
        component.set("v.promotionsURL", settings[promotionsURLField]);
    }
})