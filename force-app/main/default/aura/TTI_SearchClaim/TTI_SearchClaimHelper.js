({
    createTable: function(component, serviceReqCase) {
        var table = component.find('table');
        $A.util.removeClass(table, 'slds-hide');
        component.set('v.serviceReqCaseList', serviceReqCase);
    },

    fieldValueValidation: function(component, searchObj) {
        const errorBox = component.find('errorBox');
        errorBox.set('v.value', '');
        const payload = JSON.parse(JSON.stringify(searchObj));
        const filterResponse = this.validateFilter(payload);
        let isValid = filterResponse.isValid;
        if (filterResponse.isValid) {
            // If has filter, validate if have custom date range
            const dateResponse = this.validateDate(component, payload.fromDate, payload.toDate);
            isValid = isValid && dateResponse.isValid;
            if (!dateResponse.isValid) {
                errorBox.set('v.value', dateResponse.errorMessage);
            } 
        } else {
            errorBox.set('v.value', filterResponse.errorMessage);
        }
        return isValid;
    },

    getUrlParameter: function(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    },

    generateSearchObject: function(component) {
        const caseNumberInForm = component.get('v.caseNumberFromSubmitClaim');
        const caseNumberInURL = this.getUrlParameter('claimNumber');
        const displayOpenClaims = $A.util.isEmpty(caseNumberInURL);
        return {
            claimNumber: caseNumberInForm || caseNumberInURL || '',
            lastName: '',
            email: '',
            mobile: '',
            retailerId: '',
            productId: '',
            consignmentNumber: '',
            displayOpenClaims,
            jobNumber: '',
            fromDate: '',
            toDate: ''
        };
    },

    validateDate: function(component, from, to) {
        const isDateFieldsValid = this.validateDateFields(component);
        const isRangeValid = this.validateDateRange(from, to);
        const errorType = !isDateFieldsValid ? 'requiredFieldInvalid' : (!isRangeValid ? 'dateRangeInvalid' : '');
        return { 
            isValid: isDateFieldsValid && isRangeValid,
            errorMessage: this.generateErrMessage(errorType) 
        }
    },

    validateDateFields: function(component) {
        const isValid = component
            .find('dateRange')
            .reduce((acc, el) => acc && el.reportValidity(), true);
        return $A.util.isUndefinedOrNull(isValid) || isValid;
    },

    validateDateRange: function(from, to) {
        const hasFromValue = !$A.util.isUndefinedOrNull(from) && !$A.util.isEmpty(from);
        const hasToValue = !$A.util.isUndefinedOrNull(to) && !$A.util.isEmpty(to);
        return (!hasFromValue && !hasToValue) || (hasFromValue && hasToValue && from < to);
    },

    validateFilter: function(payload) {
        const excludedProps = [ 'displayOpenClaims' ];
        const keys = Object
            .keys(payload)
            .filter(el => !excludedProps.includes(el));
        const isValid = keys.some(el => 
            !$A.util.isUndefinedOrNull(payload[el]) &&
            !$A.util.isEmpty(payload[el]));
        return { 
            isValid, 
            errorMessage: !isValid ? this.generateErrMessage('noFilter') : '' }
    },

    generateErrMessage: function(type) {
        const messages = {
            requiredFieldInvalid: 'One or more required fields have invalid value. Kindly check them and retry.',
            dateRangeInvalid: 'From Date can not be greater than To Date',
            noFilter: 'You must specify atleast one value in order to perform a search for a service request',
            generic: $A.get("$Label.c.Generic_Error_Message")
        };
        return messages[type] || '';
    },
})