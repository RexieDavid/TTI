({
    previousClicked: function(component, event, helper) {
        component.set('v.showHideErrorMessage', false);
        component.set('v.ErrorMessage', null);
        component.set('v.isError', false);
        component.set('v.showErrorMessage', null);
        component.set('v.activeScreenId', '1');
    },

    searchClicked: function(component,event,helper) {
        let spinner = component.find('mySpinner');
        $A.util.toggleClass(spinner, 'slds-hide');
        component.set('v.isError', false);
        component.set('v.showErrorMessage', null);
        let isValid = helper.doValidationChecks(component, spinner);
        if (isValid) {
            component.set('v.showHideErrorMessage', false);
            component.set('v.ErrorMessage', null);
            
            let brand = component.get('v.brand');
            let lastName = component.get('v.lastName');
            let email = component.get('v.email');
            let mobile = component.get('v.mobile');
            let home = component.get('v.home');
            let action = component.get('c.searchCustomer');
            action.setParams({
                'brand': brand,
                'lastName': lastName,
                'email': email,
                'mobile': mobile,
                'home': home
            });
            
            action.setCallback(this, function(response) {
                $A.util.toggleClass(spinner, 'slds-hide');
                let searchCustomerState = response.getState();
                let valueSearchCustomer = response.getReturnValue();
                if (searchCustomerState === 'SUCCESS' && valueSearchCustomer) {
                    if (valueSearchCustomer.isError) {
                        component.set('v.isError', valueSearchCustomer.isError);
                        component.set('v.showErrorMessage', valueSearchCustomer.errorMessage); 
                    } else {
                        component.set('v.searchCustomerValue', valueSearchCustomer);
                        let searchOrCreateCustomerEvent = $A.get('e.c:TTI_SearchOrCreateCustomerEvent');
                        searchOrCreateCustomerEvent.setParams({
                            'customerInformation' : valueSearchCustomer,
                            'isSearch' : true
                        });
                        searchOrCreateCustomerEvent.fire();
                        component.set('v.activeScreenId', '3');
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    newClicked: function(component, event, helper) {
        component.set('v.showHideErrorMessage', false);
        component.set('v.ErrorMessage', null);
        component.set('v.isError', false);
        component.set('v.showErrorMessage', null);
        
        let SearchOrCreateCustomerEvent = $A.get('e.c:TTI_SearchOrCreateCustomerEvent');
        SearchOrCreateCustomerEvent.setParams({
            'customerInformation' : null,
            'isSearch' : false
        });
        SearchOrCreateCustomerEvent.fire();
        
    },

    checkIfLocalPhoneNumber: function(component, event, helper) {
        let mobile = component.get('v.mobile');
        let isValidField = component.find('inputMobile').reportValidity();
        
        if (isValidField && mobile) {
            let utilityMethods = component.find('utilityMethods');
            mobile = utilityMethods.correctLocalPhoneNumber(mobile, isValidField);

            if (mobile) {
                component.set('v.mobile', mobile);
            }
        }
    },

    checkIfHomePhoneNumber: function(component, event, helper) {
        let home = component.get('v.home');
        let isValidField = component.find('inputHome').reportValidity();

        if (isValidField && home) {
            let utilityMethods = component.find('utilityMethods');
            home = utilityMethods.correctHomePhoneNumber(home, isValidField);

            if (home) {
                component.set('v.home', home);
            }
        }
    }
})