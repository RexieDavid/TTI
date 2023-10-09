({
    doValidationChecks: function(component, spinner) {
        let brand = component.get('v.brand');
        let lastName = component.get('v.lastName');
        let email = component.get('v.email');
        let mobile = component.get('v.mobile');
        let home = component.get('v.home');
        let hasError = false;

        if (!brand || brand == 'None') {
            hasError = true;
        } else {
            let count = 0;

            if (!lastName) {
                count++;
            }

            if (!email) {
                count++;
            }

            if (!home) {  
                count++;
            } else {
                if (!component.find('inputHome').reportValidity()) {
                    $A.util.toggleClass(spinner, 'slds-hide');
                    return false;
                }
            }
            
            if (!mobile) {
                count++;
            } else {
                if (!component.find('inputMobile').reportValidity()) {
                    $A.util.toggleClass(spinner, 'slds-hide');
                    return false;
                }
            }

            if (count > 2) {
                hasError = true;
            }
        }

        if (hasError) {
            $A.util.toggleClass(spinner, 'slds-hide');
            component.set('v.showHideErrorMessage', true);
            component.set('v.ErrorMessage', 'The Brand, along with two other fields must be specified to perform a search on a customer record');
            return false;
        } else {
            return true;
        }
    }
})