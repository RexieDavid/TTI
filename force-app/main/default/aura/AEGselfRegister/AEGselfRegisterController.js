({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({ "qsToEvent": helper.qsToEventMap }).fire();
        helper.initializePayload(component);
        helper.initializeFieldErrorMessages(component);
        helper.initializeCustomSettings(component);
        helper.populatePicklists(component);
    },

    handleSelfRegister: function(component, event, helper) {
        helper.handleSelfRegister(component);
    },

    setStartUrl: function(component, event, helper) {
        var startUrl = event.getParam('startURL');
        component.set("v.startUrl", startUrl);
    },
    /*added by Venkat*/
    changeReferral: function(component, event, helper){       
       let getReferral = component.get("v.enableReferral");
       component.set("v.enableReferral", !getReferral);
    },

    handleKeyUp: function(component, event, helper) {
        const enterKey = 13;
        if (event.keyCode === enterKey) {
            helper.handleSelfRegister(component);
        }
    },

    handleProfessionChange: function(component, event, helper) {
        const result = event.getParam("valueByEvent");
        const payload = component.get('v.payload');
        payload.profession = result ? result.value : '';
        helper.validateProfession(component, payload);
        component.set("v.payload", payload);
    },

    handleChangeBusinessType: function(component, event, helper) {
        const value = event.getSource().get("v.value");
        const payload = component.get('v.payload');
        payload.custom.isCustomerBusinessType = value === 'Business';
        component.set('v.payload', payload);
    }
})