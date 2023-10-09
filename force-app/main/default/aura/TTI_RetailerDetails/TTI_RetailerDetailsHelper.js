({
    validateRetailerEmailAddress : function(component,serviceRequestCase) {
        var retailerEmailAddress = component.find("retailerEmailAddress");
        if(!$A.util.isUndefinedOrNull(serviceRequestCase)){
            if(($A.util.isUndefinedOrNull(serviceRequestCase.Retailer_Email_Address__c) || $A.util.isEmpty(serviceRequestCase.Retailer_Email_Address__c) )&& serviceRequestCase.TTI_Quote_to_Retailer__c == true){
                retailerEmailAddress.set("v.errors",[{message:"You must specify the retailer email address if you want to send this quote to the retailer"}]);
                return false;
            }else{
                retailerEmailAddress.set("v.errors", null);
                return true;
            }
        }
    }
})