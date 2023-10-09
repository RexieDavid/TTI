({
    ValidateGoodWill : function(component) {
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var goodwillcheckbox = component.find("goodwillcheckbox");
        if(Service_Request_Case.Goodwill__c 
           && Service_Request_Case.Claim_Type__c =='Non-Warranty'
           && (($A.util.isUndefinedOrNull(Service_Request_Case.Parts_Percentage_Discount__c) 
                || $A.util.isEmpty(Service_Request_Case.Parts_Percentage_Discount__c)) 
               && ($A.util.isUndefinedOrNull(Service_Request_Case.Labour_Percentage_Discount__c) 
                   || $A.util.isEmpty(Service_Request_Case.Labour_Percentage_Discount__c) ))
           
          ){
            goodwillcheckbox.set("v.errors",[{message:"You must specify a valid discount when applying goodwill to a non-warranty claim"}]);
        }else{
            
            goodwillcheckbox.set("v.errors",null);
        }
    },
    Validatepartpercentage : function(component){
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var partsdiscount = component.find("partsdiscount");
        if(!($A.util.isUndefinedOrNull(Service_Request_Case.Parts_Percentage_Discount__c) 
             || $A.util.isEmpty(Service_Request_Case.Parts_Percentage_Discount__c)) 
           && Service_Request_Case.Parts_Percentage_Discount__c<0 
           ||Service_Request_Case.Parts_Percentage_Discount__c>100 
          ){
            partsdiscount.set("v.errors",[{message:"discount should be between 0 and 100"}]);
        }else{
            partsdiscount.set("v.errors",null);
        }   
    },
    Validateretailpercentage : function(component){
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var retaildiscount = component.find("retaildiscount");
        if(!($A.util.isUndefinedOrNull(Service_Request_Case.Labour_Percentage_Discount__c) 
             || $A.util.isEmpty(Service_Request_Case.Labour_Percentage_Discount__c)) 
           && Service_Request_Case.Labour_Percentage_Discount__c<0 
           ||Service_Request_Case.Labour_Percentage_Discount__c>100){
            retaildiscount.set("v.errors",[{message:"discount should be between 0 and 100"}]); 
        }
        else{
            retaildiscount.set("v.errors",null);
        }
    },
    
    uncheckgoodwill : function(component) {
        var Service_Request_Case = component.get("v.Service_Request_Case");
        if(Service_Request_Case.Goodwill_parts_only__c){
            component.set("v.Service_Request_Case.Goodwill__c",false);
        }
        
    },
    uncheckgoodwillparts : function(component) {
        var Service_Request_Case = component.get("v.Service_Request_Case");
        if(Service_Request_Case.Goodwill__c){
            component.set("v.Service_Request_Case.Goodwill_parts_only__c",false);
        }
        
        
    },
    clearpercentagewhengoodwillunchecked : function(component){
		var Service_Request_Case = component.get("v.Service_Request_Case");
        var goodwillcheckbox = component.find("goodwillcheckbox");
        if(!Service_Request_Case.Goodwill__c){
            component.set("v.Service_Request_Case.Parts_Percentage_Discount__c","");
            component.set("v.Service_Request_Case.Labour_Percentage_Discount__c","");
        }        
    }
})