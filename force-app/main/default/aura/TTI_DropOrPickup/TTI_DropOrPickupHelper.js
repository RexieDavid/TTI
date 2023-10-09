({
    Area1validation : function(component){
        var fieldvalue = component.get("v.address1");
        var fieldauraID = component.find("addressline1");
        if($A.util.isUndefinedOrNull(fieldvalue) || fieldvalue==''){
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            return false;
        }else{
            fieldauraID.set("v.errors",[{message:""}]);
            return true;
        }
    },
    
    Phonevalidation : function(component){
        var claim = component.get("v.claim");
        var mobile = component.find("mobile");
        if(!$A.util.isUndefinedOrNull(claim.TTI_Customer_Contact__c)){
            if($A.util.isUndefinedOrNull(claim.TTI_Customer_Contact__c.MobilePhone) || claim.TTI_Customer_Contact__c.MobilePhone ===''){
                mobile.set("v.errors",[{message:"This field is mandatory"}]);
                return false;
            }else{
                mobile.set("v.errors", null);
                return true;
            }
        }
    },
    
    pincodevalidation : function(component){
        var fieldvalue = component.get("v.postalCode"); 
        console.log('====  fieldvalue====='+fieldvalue);
        var fieldauraID = component.find("postcode");
        console.log('====  fieldauraID====='+fieldauraID);
        if($A.util.isUndefinedOrNull(fieldvalue) || fieldvalue == ''){
            console.log('inside if');
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            console.log('After errorinside if');
            return false;
        }else{
            console.log('inside else');
            fieldauraID.set("v.errors",[{message:""}]);
            return true;
        }
    },
    suburbvalidation : function(component){
        var fieldvalue = component.get("v.suburb");
        console.log('====  fieldvalue====='+fieldvalue);
        var fieldauraID = component.find("suburbName");
        console.log('====  fieldauraID====='+fieldauraID);
        if($A.util.isUndefinedOrNull(fieldvalue) || fieldvalue == ''){
            console.log('inside if');
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            console.log('After errorinside if');
            return false;
        }else{
            console.log('inside else');
            fieldauraID.set("v.errors",[{message:""}]);
            return true;
        }
    },
    countryvalidation : function(component){
        var fieldvalue = component.get("v.claim.TTI_Freight_In_Pickup_Country__c");
        
        console.log('====  country fieldvalue====='+fieldvalue);
        var fieldauraID = component.find("countryName");
        console.log('====  fieldauraID====='+fieldauraID);
        
        if($A.util.isUndefinedOrNull(fieldvalue) ||fieldvalue== '--None--'){ //$A.util.isUndefinedOrNull(fieldvalue)){
            console.log('inside if');
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            console.log('After errorinside if');
            return false;
        }else{
            console.log('inside else');
            fieldauraID.set("v.errors",null);
            return true;
        } 
    },
    statevalidation : function(component){
        var countryValue = component.get("v.claim.TTI_Freight_In_Pickup_Country__c");
        var fieldvalue = component.get("v.state");
        var fieldauraID = component.find("stateName");
        if(countryValue=='New Zealand') {
            fieldauraID.set("v.errors",[{message:""}]);
            return true;
        }
        
        if($A.util.isUndefinedOrNull(fieldvalue) || fieldvalue == ''){
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            return false;
        }else{
            if((countryValue=='Australia') && (fieldvalue !='VIC' && fieldvalue !='QLD'
                                              && fieldvalue !='NSW' && fieldvalue !='SA'
                                              && fieldvalue !='WA' && fieldvalue !='TAS'
                                              && fieldvalue !='TAS' && fieldvalue !='ACT'
                                              && fieldvalue !='NT'))
            {
                fieldauraID.set("v.errors",[{message:"The state for freight to Australia must be VIC, QLD, NSW, SA, WA, TAS, ACT or NT"}]);
                return false;
            }
            else{
                fieldauraID.set("v.errors",[{message:""}]);
                return true;
            }
        } 
    },
    
    blurMobileFormat : function(component) {
        var claim = component.get("v.claim");
        var mobileCss = component.find("mobile");
        if(!$A.util.isUndefinedOrNull(claim.TTI_Customer_Contact__c)){
            if(!$A.util.isUndefinedOrNull(claim.TTI_Customer_Contact__c.MobilePhone) || claim.TTI_Customer_Contact__c.MobilePhone !==''){
                if(((claim.TTI_Customer_Contact__c.MobilePhone).substring(0,2)=='02'|| (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,2)=='04' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,5)=='+6104' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,5)=='+6102' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,6)=='+61 02' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,6)=='+61 04' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,4)=='+614' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,4)=='+642' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,6)=='+64 02' || (claim.TTI_Customer_Contact__c.MobilePhone).substring(0,5)=='+6402') && (claim.TTI_Customer_Contact__c.MobilePhone).length>=10){
                    
                    mobileCss.set("v.errors",null);
                    return true;
                }
                else{
                    mobileCss.set("v.errors",[{message:"Invalid Number"}]);
                    return false;
                }   
            }
        }
        mobileCss.set("v.errors",null);
        return true;
    }
    
})