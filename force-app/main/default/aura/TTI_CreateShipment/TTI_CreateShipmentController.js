/**
 * @File Name          : TTI_CreateShipmentController.js
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 09/08/2019, 1:02:20 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author            Modification
 *==============================================================================
 * 1.0    09/08/2019, 1:02:20 pm   Francis Nasalita     Initial Version
**/
({
    doInit: function (component, event, helper) {        
        let claim = component.get("v.serviceReqCase");
        if (claim.TTI_Freight_Out_Delivery_Country__c == 'Australia') {
            if (claim.Service_Agent__r.Internal_Service_Agent__c) {
                component.set("v.senderContactNumber", component.get('v.generalCstmrServLine'));
            } else {
                component.set("v.senderContactNumber", claim.Contact.Phone);
            }
        }

        if (claim.SuppliedPhone) {
            component.set(
                'v.regexPhoneFormat', 
                helper.getPhoneRegexPattern(
                    claim.SuppliedPhone, 
                    claim.TTI_Freight_Out_Delivery_Country__c
                )
            );
            component.set(
                'v.errPhoneNumberNotMatch', 
                helper.getErrorPhonePatternMismatch(
                    claim.SuppliedPhone, 
                    claim.TTI_Freight_Out_Delivery_Country__c
                )
            );
        }
       
        setTimeout(function(){ 
            helper.validateForm(component);
        }, 500);
    },
    
    handlePickupAddressChange: function(component, event, helper) {
        let claim = component.get("v.serviceReqCase");
        const data = JSON.parse(JSON.stringify(event.getParams()));
        const addressObj = helper.constructAddressObj(data.result.address_components);

        const street1 = addressObj.Street1 || '';
        let street2 = addressObj.Street2 || '';
        street2 = street1 ? ` ${street2}` : street2;

        claim.TTI_Freight_Out_PickUp_Address__c = street1 + street2;
        claim.TTI_Freight_Out_Pickup_Suburb__c = addressObj.City;
        claim.TTI_Freight_Out_Pickup_Postcode__c = addressObj.PostalCode;
        claim.TTI_Freight_Out_Pickup_State__c = addressObj.State;
        claim.TTI_Freight_Out_Pickup_Country__c = addressObj.Country;

        component.set("v.serviceReqCase", claim);
    },

    handleDeliveryAddressChange: function(component, event, helper) {
        let claim = component.get("v.serviceReqCase");
        const data = JSON.parse(JSON.stringify(event.getParams()));
        const addressObj = helper.constructAddressObj(data.result.address_components);

        const street1 = addressObj.Street1 || '';
        let street2 = addressObj.Street2 || '';
        street2 = street1 ? ` ${street2}` : street2;

        claim.TTI_Freight_Out_Delivery_Address__c = street1 + street2;
        claim.TTI_Freight_Out_Delivery_Suburb__c = addressObj.City;
        claim.TTI_Freight_Out_Delivery_Postcode__c = addressObj.PostalCode;
        claim.TTI_Freight_Out_Delivery_State__c = addressObj.State;
        claim.TTI_Freight_Out_Delivery_Country__c = addressObj.Country;

        component.set("v.serviceReqCase", claim);
    },

    handleValueChange: function(component, event, helper) {
        helper.validateForm(component);
        component.set('v.isCaseUpdated', true);
    },
    
    handleDeliveryOptionChange: function(component, event, helper) {
        let claim = component.get("v.serviceReqCase");
        let deliveryMethod = event.getParam("value");
        const isDeliverSelected = deliveryMethod === 'Deliver';
        component.set('v.isChangedToPickup', !isDeliverSelected);
        
        claim.TTI_Customer_Delivery_Method__c = deliveryMethod;
        if (isDeliverSelected) {
            if (!claim.FreightOutDeliverTo__c) {
                claim.FreightOutDeliverTo__c = claim.Retailer_Account__r.Name;
            }
        } else {
            component.set('v.isCaseUpdated', false);
        }

        helper.validateForm(component);
    },
    
    handleContactNumberChange: function(component, event, helper) {
        let country = component.get('{!v.serviceReqCase.TTI_Freight_Out_Delivery_Country__c}');
        let suppliedPhone = event.getSource();
        let suppliedPhoneValue = suppliedPhone.get('v.value');

        component.set('v.regexPhoneFormat', helper.getPhoneRegexPattern(suppliedPhoneValue, country));
        component.set('v.errPhoneNumberNotMatch', helper.getErrorPhonePatternMismatch(suppliedPhoneValue, country));
    },

})