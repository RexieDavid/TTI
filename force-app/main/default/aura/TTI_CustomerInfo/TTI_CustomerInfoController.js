({    
    next : function(component, event, helper) {
        var email = component.find("email");
        var errMandatoryField = component.get("v.errMandatoryField");
        component.set("v.claim.TTI_Email_Notification_Opt_In__c",component.get("v.customer.HasOptedOutOfEmail"));
        if(component.get("v.customer.HasOptedOutOfEmail")
                && ($A.util.isUndefined(component.get("v.customer.Email")) 
                || $A.util.isEmpty(component.get("v.customer.Email")))) {

            email.setCustomValidity(errMandatoryField);
            email.reportValidity();
            return false;
        } else {
            email.setCustomValidity("");
        }

        var customerMobilePhone = component.get("v.customer.MobilePhone");
        var customerHomePhone = component.get("v.customer.HomePhone");        
        if(!$A.util.isUndefinedOrNull(customerMobilePhone) && customerMobilePhone !==''){
            
            component.set("v.claim.SuppliedPhone", customerMobilePhone);
            component.set("v.isMobilePhone", true);
        }
        else if(!$A.util.isUndefinedOrNull(customerHomePhone) && customerHomePhone !==''){
            
            component.set("v.claim.SuppliedPhone", customerHomePhone);
            component.set("v.isMobilePhone", true);
        }
        else{
            component.set("v.isMobilePhone", false);
        }
        component.set("v.isError", false);
        component.set("v.showErrorMessage", null);

        var correctfirstname = component.find('firstname').reportValidity();
        var correctlastname = component.find('lastname').reportValidity();
        var doValidateEmailOrPhone = helper.doValidateEmailOrPhone(component);
        var correctmobile = component.find('mobile').reportValidity();
        var correctHomePhone = component.find('home').reportValidity();
        var correctemail = component.find('email').reportValidity();

        var countClick = component.get("v.countClick");
        if(countClick === 2){
            doValidateEmailOrPhone = true;
        } else if(correctfirstname && correctlastname
                && correctmobile && correctemail
                && correctHomePhone && doValidateEmailOrPhone) {

            component.set("v.isError", false);
            component.set("v.activeScreenId","4");            
        }
        
    },
    
    getCustomerInformation: function(component, event, helper) {
        component.set("v.isEmailExist", false); 
        var customerInformation = event.getParam("customerInformation");
        var isSearch = event.getParam("isSearch");
        if(!$A.util.isUndefinedOrNull(customerInformation)){
            component.set("v.customer", customerInformation.contactObj); 
            component.set("v.claim.TTI_Customer_Contact__c", customerInformation.contactObj);
            if(!$A.util.isUndefinedOrNull(customerInformation.contactObj)){
                if(!$A.util.isUndefinedOrNull(customerInformation.contactObj.Email) && isSearch){
                    component.set("v.isEmailExist", true);  
                }
                else{
                    component.set("v.isEmailExist", false);  
                }
                
            }
            component.set("v.claim.TTI_Customer_Account__c",customerInformation.contactObj.AccountId);
        }else{
            var customer={'FirstName': '', 'LastName': '', 'MobilePhone': '', 'Email': ''};
            component.set("v.customer", customer);
            component.set("v.claim.TTI_Customer_Contact__c", customer);
        }
        
        
        component.set("v.newcustomer", isSearch); 
        component.set("v.activeScreenId","3");
        
    },
    
    previous: function(component, event, helper) {
        component.set("v.activeScreenId","2");
        component.set("v.newcustomer", false);
    },

    checkIfLocalPhoneNumber: function(component, event, helper) {
        var mobile = component.get("v.customer.MobilePhone");
        var isValidField = component.find("mobile").reportValidity();

        if(isValidField && mobile != '' && mobile != null) {
            var utilityMethods = component.find("utilityMethods");

            mobile = utilityMethods.correctLocalPhoneNumber(mobile, isValidField);

            if(mobile != null) {
                component.set("v.customer.MobilePhone", mobile);
            }
        }
    },

    checkIfHomePhoneNumber: function(component, event, helper) {
        var home = component.get("v.customer.HomePhone");
        var isValidField = component.find("home").reportValidity();

        if(isValidField && home != '' && home != null) {
            var utilityMethods = component.find("utilityMethods");

            home = utilityMethods.correctHomePhoneNumber(home, isValidField);

            if(home != null) {
                component.set("v.customer.HomePhone", home);
            }
        }
    },
})