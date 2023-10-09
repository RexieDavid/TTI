({    
    doValidateEmailOrPhone : function(component) {
        var customer = component.get("v.customer");
        
        var count=0;
        if(($A.util.isUndefined(customer.MobilePhone) || $A.util.isEmpty(customer.MobilePhone))){
            count++;
        }
        if(($A.util.isUndefined(customer.HomePhone) || $A.util.isEmpty(customer.HomePhone))){
            count++;
        }
        if(($A.util.isUndefined(customer.Email) || $A.util.isEmpty(customer.Email))){
            count++;
        }
        
        if(count>2)
            return false;
        
        return true;
    }
    
    
})