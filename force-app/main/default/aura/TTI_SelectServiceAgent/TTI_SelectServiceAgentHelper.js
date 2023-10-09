({
    getSelectedObjDeliveryAddress : function(component,selectedObj) {
        var address='';
        var street='';
        var city='';
        var state='';
        var postalCode='';
        var country='';
        if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Street__c)) {
            component.set("v.claim.TTI_Freight_In_Delivery_Address__c",selectedObj.Delivery_Street__c);
            street = selectedObj.Delivery_Street__c;
        }
        if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Suburb__c)) {
            component.set("v.claim.TTI_Freight_In_Delivery_Suburb__c",selectedObj.Delivery_Suburb__c);
            city = selectedObj.Delivery_Suburb__c;
        }
        if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_State__c)) {
            state = selectedObj.Delivery_State__c;
            component.set("v.claim.TTI_Freight_In_Delivery_State__c",selectedObj.Delivery_State__c);
        }
        if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Postcode__c)) {
            component.set("v.claim.TTI_Freight_In_Delivery_Postcode__c",selectedObj.Delivery_Postcode__c);
            postalCode = selectedObj.Delivery_Postcode__c;
        }
        if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Country__c)) {
            component.set("v.claim.TTI_Freight_In_Delivery_Country__c",selectedObj.Delivery_Country__c);
            country = selectedObj.Delivery_Country__c;
        }
        address=street+' '+city+' '+state+' '+postalCode+' '+country;
        return address;
    }
})