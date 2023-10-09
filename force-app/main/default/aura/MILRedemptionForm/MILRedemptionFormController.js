({
    doInit: function(component, event, helper) {        
        helper.initData(component);        
    },

    handleNavigate: function(component, event, helper) {
        if (event.getParam('Target') === component.get('v.PageName')) {
            if (event.getParam('RecordJSON')) {
                component.set('v.selectedPromoJSON', event.getParam('RecordJSON'));
            }

            if (component.get('v.isCmpInitiated')) {
                helper.initPayload(component);
            } else {
                component.set('v.isPayloadReady', true);
            }

            helper.showComponent(component.find('createRedemptionDiv'));
        } else {
            helper.hideComponent(component.find('createRedemptionDiv'));
        }
    },

    validateDetails: function(component, event, helper) {
        component.set("v.isSubmitted", true);
        
        //ADDED BY: KB - INC0042223 - 08/15/23
        const hasFileUpload = component.get('v.hasFile');
        if(!hasFileUpload){
            component.set('v.fileUploadErrorMsg', true); 
            return;
        }

        helper.validate(component)

        .then(() => {
            component.set("v.showConfirmModal", true);
        })
        .catch(field => {
            field.focus();
            helper.showToast(component, 
                '', 
                'Please update the invalid form entries and try again.',
                'error');
        });
    },

    hideModal: function(component) {
        component.set("v.showConfirmModal", false);
    },

    saveDetails: function(component, event, helper) {
        component.set("v.showConfirmModal", false);
        helper.toggleSpinner($A.get("e.c:MILToggleSpinner"));
        helper.commit(component);
        helper.scrollToTop(component);
    },

    reRenderAddressFields: function(component, event, helper) {
        /**
         * Rerender address fields to remove error message
         * if disabled
         */
        component.find('address').forEach(field => {
            field.reportValidity();
        });
        helper.clearAddress(component);
    },

    handleAddressSelect: function(component, event) {
        const country = component.get('v.country');
        let typesFieldsMap = {
            postal_code: "MailingPostalCode",
            administrative_area_level_1: "MailingState",
            tti_inferred_route: "MailingStreet",
            country: "MailingCountry"
        };

        typesFieldsMap = country.toUpperCase() === 'AU' 
                        ? Object.assign(typesFieldsMap, { locality: "MailingCity"}) 
                        : Object.assign(typesFieldsMap, { sublocality_level_1: "MailingCity"}) 
        let data = event.getParams('responseValue').result.address_components;
        let addresstypes = Object.keys(typesFieldsMap);

        for (const address in data) {
            if (addresstypes.includes(data[address].types[0])) {
                let field = 'v.contactInfo.' + typesFieldsMap[data[address].types[0]];
                component.set(field, data[address].long_name);
            }
        }
    },

    onSelectRedeemOption: function(component, event, helper) {
        const id = event.getSource().get('v.value');
        const redeemOptions = component.get('v.redeemOptions');
        redeemOptions.forEach(el => el.selected = el.id === id);
        component.set('v.selectedItem', redeemOptions.find(el => el.id === id));
    },

    fileUpload: function(component, event, helper) {
        helper.toggleSpinner($A.get("e.c:MILToggleSpinner"));
        component.set('v.hasFile', false); //set to false to rerender component
        component.set('v.fileUploadErrorMsg', false); //ADDED BY: KB - INC0042223 - 08/15/23
        const uploadedFiles = event.getParam("files")[0];
        helper.processFileUploaded(component, uploadedFiles);
    }

})