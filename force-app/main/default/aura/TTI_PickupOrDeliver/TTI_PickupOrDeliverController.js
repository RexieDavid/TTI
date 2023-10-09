({
    handleBlurState: function(component) {
        var inputCmp = component.find('fieldState');
        var countryValue = component.get('v.claim.TTI_Freight_Out_Delivery_Country__c');
        var state = inputCmp.get('v.value');

        if (countryValue && state) {
            if (countryValue == 'Australia' && state != 'VIC' 
                    && state != 'QLD' && state != 'NSW' && state != 'SA'
                    && state != 'WA' && state != 'TAS' && state != 'TAS' 
                    && state != 'ACT' && state != 'NT') {        

                inputCmp.setCustomValidity('The state for freight to Australia must be VIC, QLD, NSW, SA, WA, TAS, ACT or NT');
            } else {
                inputCmp.setCustomValidity('');
            }
        } else {
            return;
        }

        inputCmp.reportValidity();
    },
    
    populateDeliveryAddress : function(component, event, helper) {
        var droporPickup = component.get('v.claim.TTI_Customer_Delivery_Method__c');
        if (droporPickup && droporPickup == 'Deliver') {
            var retailerAcc = component.get('v.claim.Retailer_Account__c');
            var customerContact = component.get('v.claim.TTI_Customer_Contact__c');
            
            
            if (retailerAcc.Id) {
                var retailerAccountId = retailerAcc.Id;
                component.set("v.claim.FreightOutDeliverTo__c", retailerAcc.Name);

                if (retailerAcc.Delivery_Country__c == 'NZ') 
                    retailerAcc.Delivery_Country__c = 'New Zealand';

                if (retailerAcc.Delivery_Country__c == 'AU') 
                    retailerAcc.Delivery_Country__c = 'Australia';

                let retailerPhone = retailerAcc.Phone;
                if (retailerPhone) {
                    retailerPhone = helper.setPhoneNumberValidation(component, retailerPhone, retailerAcc.Delivery_Country__c);
                }
                component.set('v.claim.SuppliedPhone', retailerPhone);

                if (retailerAccountId) {
                    if (retailerAcc.Delivery_Street__c) 
                        component.set('v.address1', retailerAcc.Delivery_Street__c);                    
                    if (retailerAcc.Delivery_Suburb__c) 
                        component.set('v.suburb', retailerAcc.Delivery_Suburb__c);
                    if (retailerAcc.Delivery_Postcode__c)
                        component.set('v.postalCode', retailerAcc.Delivery_Postcode__c); 
                    if (retailerAcc.Delivery_State__c) 
                        component.set('v.state', retailerAcc.Delivery_State__c); 
                    if (retailerAcc.Delivery_Country__c)
                        component.set('v.claim.TTI_Freight_Out_Delivery_Country__c', retailerAcc.Delivery_Country__c);  
                }
            } else if (customerContact) {
                component.set("v.claim.FreightOutDeliverTo__c", customerContact.FirstName + ' ' + customerContact.LastName);

                if (customerContact.MailingCountry == 'NZ')
                    customerContact.MailingCountry = 'New Zealand';
                if (customerContact.MailingCountry == 'AU')
                    customerContact.MailingCountry = 'Australia';

                if (customerContact) {
                    if (customerContact.MailingStreet)
                        component.set('v.address1', customerContact.MailingStreet);
                    if (customerContact.MailingCity)
                        component.set('v.suburb', customerContact.MailingCity); 
                    if (customerContact.MailingPostalCode)
                        component.set('v.postalCode', customerContact.MailingPostalCode); 
                    if (customerContact.MailingState)
                        component.set('v.state', customerContact.MailingState); 
                    if (customerContact.MailingCountry)
                        component.set('v.claim.TTI_Freight_Out_Delivery_Country__c', customerContact.MailingCountry); 
                } else {
                    component.set('v.address1', null);
                    component.set('v.address2', null);
                    component.set('v.suburb', null);
                    component.set('v.postalCode', null);
                    component.set('v.state', null);   
                }
            }
        }
    },
    
    submit : function(component, event, helper) {
        var compEvent = component.getEvent('submitClaimEvent');
        var claim = component.get('v.claim');
        let user = component.get("v.userObject");
        
        var addres1 = component.get('v.address1'); 
        var addres2 = component.get('v.address2'); 
        var postcode = component.get('v.postalCode');
        var state = component.get('v.state');
        var suburb = component.get('v.suburb');
        var country = component.get('v.claim.TTI_Freight_Out_Delivery_Country__c');
        
        claim.Diagnosed_User__c = user.Id;
        if (claim.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent') {
            claim.TTI_Freight_Out_Delivery_Suburb__c = null;
            claim.TTI_Freight_Out_Delivery_Postcode__c = null;
            claim.TTI_Freight_Out_Delivery_State__c = null;
            claim.TTI_Freight_Out_Delivery_Address__c = null;
            claim.TTI_Freight_Out_Delivery_Country__c = null;      
            
            component.set('v.claim', claim);
            compEvent.fire();
            return;
        }

        var phoneValid = component.find('mobile').reportValidity();
        var allAddressValid = helper.validateAddress(component, { Country: country, State: state });
        var stateValid = component.find('fieldState').reportValidity();

        if (claim.Service_Agent__c) {
            claim.TTI_Freight_Out_PickUp_Address__c = claim.Service_Agent__c.Delivery_Street__c;
            claim.TTI_Freight_Out_Pickup_Suburb__c = claim.Service_Agent__c.Delivery_Suburb__c;
            claim.TTI_Freight_Out_Pickup_Postcode__c = claim.Service_Agent__c.Delivery_Postcode__c;
            claim.TTI_Freight_Out_Pickup_State__c = claim.Service_Agent__c.Delivery_State__c;
            claim.TTI_Freight_Out_Pickup_Country__c = claim.Service_Agent__c.Delivery_Country__c;
        }        

        if (claim.TTI_Customer_Delivery_Method__c == 'Deliver' 
                && allAddressValid && phoneValid && stateValid) {

            var addressObj;
            if (addres2) {
                addressObj = addres1 + ' ' + addres2;
            } else {
                addressObj = addres1;
            }

            claim.TTI_Freight_Out_Delivery_Suburb__c = suburb;
            claim.TTI_Freight_Out_Delivery_Postcode__c = postcode;
            claim.TTI_Freight_Out_Delivery_State__c = state;
            claim.TTI_Freight_Out_Delivery_Address__c = addressObj;

            component.set('v.claim', claim);
            compEvent.fire();
        }        
    },
    
    previous : function(component) {
        var userType = component.get('v.userType');
        if (userType == 'SAAD') {
            component.set('v.activeScreenId', '4');
        } else {
           var droporPickupCust = component.get('v.claim.TTI_Service_Agent_Delivery_Method__c');
            if (droporPickupCust == 'Drop off') {
                component.set('v.activeScreenId', '5');
            }
            if (droporPickupCust == 'Pickup from nominated address') {
                component.set('v.activeScreenId', '10');
            }
        }
    },

    checkIfLocalPhoneNumber: function(component) {
        var isValidField = component.find('mobile').reportValidity;
        let phoneNumber = component.find('mobile').get('v.value');
        let phoneValidity = component.find('mobile').get('v.validity');
        let country = component.get('{!v.claim.TTI_Freight_Out_Delivery_Country__c}');
        const auMobileRegex = new RegExp($A.get("$Label.c.UTIL_REGEX_AU_Phone_Format"));
        const nzMobileRegex = new RegExp($A.get("$Label.c.UTIL_REGEX_NZ_Phone_Format"));
        const landlineRegex = new RegExp($A.get("$Label.c.SP_REGEX_ANZ_RetailerPhone_Format"));

        if (phoneValidity.valid) {
            if (country === 'Australia' && auMobileRegex.test(phoneNumber) 
                    || (country === 'New Zealand' && nzMobileRegex.test(phoneNumber))) {
                var utilityMethods = component.find('utilityMethods');

                phoneNumber = utilityMethods.correctLocalPhoneNumber(phoneNumber, isValidField);

                if (phoneNumber != null) {
                    component.set('v.claim.SuppliedPhone', phoneNumber);
                }
            } else if (landlineRegex.test(phoneNumber) && phoneNumber.length > 9) {
                component.set('v.claim.SuppliedPhone', phoneNumber);
            }
        }
    },

    handleAddressSelect: function(component, event, helper) {
        const data = JSON.parse(JSON.stringify(event.getParams()));
        const addressObj = helper.constructAddressObj(data.result.address_components);

        component.set('v.address1', addressObj.tti_address);
        component.set('v.suburb', addressObj.City);
        component.set('v.postalCode', addressObj.PostalCode);
        component.set('v.state', addressObj.State);
        component.set('v.claim.TTI_Freight_Out_Delivery_Country__c', addressObj.Country);
    },

    setPhoneNumberValidation: function(component, event, helper) {
        let country = component.get('{!v.claim.TTI_Freight_Out_Delivery_Country__c}');
        let suppliedPhone = event.getSource();
        let suppliedPhoneValue = suppliedPhone.get('v.value');

        helper.setPhoneNumberValidation(component, suppliedPhoneValue, country);
    }
})