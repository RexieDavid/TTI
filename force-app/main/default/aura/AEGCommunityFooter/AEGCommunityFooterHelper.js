({
    initializeCustomSettings: function(component, countryCode) {
        const action = component.get("c.getSiteSettings");
        action.setCallback(this, function(response) {
            const settings = response.getReturnValue();
            this.setSafetyInformationLink(component, settings, countryCode);
        });
        $A.enqueueAction(action);
    },

    setSafetyInformationLink: function(component, settings, countryCode) {
        const suffix = countryCode !== 'AU' ? '_NZ' : '';
        const safetyInformationField = `Safety_Information${suffix}__c`;
        component.set("v.safetyInformationLink", settings[safetyInformationField]);
    },

    setCustomerServiceHotline: function(component, countryCode) {
        /**
         * There is a deployment error if fetch using 
         * dynamic approach like the code below:
         * AEG_Customer_Service_${country}
         */
        const label = countryCode === 'AU' ? 
                        '$Label.c.AEG_Customer_Service_AU' : 
                        '$Label.c.AEG_Customer_Service_NZ';
        component.set("v.value",  $A.get(label));
    }
})