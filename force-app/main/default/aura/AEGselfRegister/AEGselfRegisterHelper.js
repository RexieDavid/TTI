({
    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    initializeFieldErrorMessages: function(component) {
        let fieldErrorMessages = {
            firstName: 'Please enter first name.',
            lastName: 'Please enter last name.',
            email: 'Please enter an email.',
            emailFormat: 'Please enter a valid Email Address.',
            postcode: 'Please enter a postcode.',
            postcodeFormat: 'Invalid postcode entered.',
            mobile: 'Please enter a mobile.',
            mobileFormat: 'Invalid mobile phone entered.',
            customerType: 'Customer type is required.',
            employeeSize: 'Employee size is required.',
            profession: 'Profession is required.',
            // answer: 'Please enter a security question answer.',
            // title: 'Please enter title.',
            referralCode: 'Referral Code should be 6 characters. Please retry.'
        };
        component.set('v.fieldErrorMessages', fieldErrorMessages);
    },

    initializePayload: function(component) {
        const country = component.get('v.country');
        const isCountryAU = country === 'Australia';
        const mobilePattern = isCountryAU ? component.get('v.mobilePatternAU') :
                component.get('v.mobilePatternNZ');
        const mobilePatterMismatchErrMsg = isCountryAU ? component.get('v.mobilePatterMismatchAU') :
                component.get('v.mobilePatterMismatchNZ');
        const mobilePrefix = isCountryAU ? '+61' : '+64';
        const payload = {
            firstName: '',
            lastName: '',
            email: '',
            accountId: '',
            // title: '',
            country,
            postcode: '',
            mobile: '',
            phone: '',
            referralCode: '',
            subscribed: false,
            customerType: '',
            profession: '',
            employeeSize: '',
            // securityQuestion: this.setSecurityQuestions()[0],
            // answer: '',
            custom: {
                mobilePrefix,
                isCustomerBusinessType: false,
                hasProfession: true,
            }
        };
        component.set('v.payload', payload);
        component.set('v.mobilePattern', mobilePattern);
        component.set('v.mobilePatterMismatchErrMsg', mobilePatterMismatchErrMsg);
    },

    initializeCustomSettings: function(component) {
        var action = component.get("c.getCommunitySettings");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set("v.siteSettings", response.getReturnValue());
            } else {
                this.showErrorMessage($A.get("$Label.c.Generic_Error_Message"));
            }
        });
        $A.enqueueAction(action);
    },

    populatePicklists: function(component) {
        const picklists = {
            countryList: this.setPicklistCountry(component)/*,
            securityQuestionList: this.setSecurityQuestions()*/
        };
        const utilityMethods = component.find('utilityMethods');
        const promiseGetPicklistValues = new Promise($A.getCallback(function(resolve, reject) {
            utilityMethods.getPicklistValues({
                'Account': ['Profession__c', /*'Salutation', */'Type', 'Employee_Size__c']
            }, resolve, reject);
        }));

        promiseGetPicklistValues.then(value => {
            const response = JSON.parse(value);
            if (response.State === 'SUCCESS') {
                const accountPicklistValues = response.value['Account'];
                for (let field in accountPicklistValues) {
                    let picklistValues = accountPicklistValues[field];
                    if (field === 'Type') {
                        picklistValues = this.processCustomerTypePicklistValue(picklistValues);
                    }
                    picklists[field] = this.processPicklistValues(picklistValues);
                }
            } else {
                this.showErrorMessage($A.get("$Label.c.Generic_Error_Message"));
            };
            component.set('v.picklistValues', picklists);
        })
    },

    setPicklistCountry: function(component) {
        return [component.get('v.country')];
    },

    /*setSecurityQuestions: function() {
        return ['What is your mother\'s maiden name?',
                'Who was your childhood hero?',
                'What was the name of your first school?',
                'What was your childhood nickname?'];
    },*/

    processPicklistValues: function(value) {
        let picklists = value;
        let defaultPicklistValue = picklists.find(el => el.defaultValue);
        picklists.unshift({
            active: true,
            defaultValue: !!defaultPicklistValue,
            label: "--Select--",
            validFor: null,
            value: null
        });
        return picklists;
    },

    processCustomerTypePicklistValue: function(value) {
        const acceptedCustomerType = ['Individual', 'Business'];
        return value.filter(el => acceptedCustomerType.includes(el.value));
    },

    handleSelfRegister: function(component) {
        const payload = component.get('v.payload');
        const isValid = this.validate(component, payload);
        if (isValid) {
            component.set("v.showSpinner", true);
            const action = component.get("c.selfRegister");
            const param = this.constructRegisterActionParam(component, payload);
            action.setParams(param);
            action.setCallback(this, function(response) {
                var rtnValue = response.getReturnValue();
                if (rtnValue) {
                    $A.util.removeClass(component.find("registering"), "notRegistering");
                    this.showErrorMessage(component, rtnValue);
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
        }
    },

    validate: function(component, payload) {
        const requiredFields = component.find('requiredField');
        this.validateProfession(component, payload);
        const allFieldValid = requiredFields.reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        component.set('v.payload', payload);
        return allFieldValid && payload.custom.hasProfession;
    },

    validateProfession: function(component, payload) {
        const professionField = component.find('profession');
        const errorClass = 'profession-has-error';
        payload.custom.hasProfession = !!payload.profession;
        if (!payload.custom.hasProfession) {
            if (!$A.util.hasClass(professionField, errorClass)) {
                $A.util.addClass(professionField, errorClass);
            }
        } else {
            $A.util.removeClass(professionField, errorClass);
        }
    },

    constructRegisterActionParam: function(component, payload) {
        const mobile = payload.mobile.includes(payload.custom.mobilePrefix) ?
            payload.mobile : payload.mobile.replace('0', payload.custom.mobilePrefix);
        return {
            firstname: payload.firstName,
            lastname: payload.lastName,
            email: payload.email,
            accountId: null,
            regConfirmUrl: component.get("v.regConfirmUrl"),
            extraFields: JSON.stringify(component.get("v.extraFields")),
            startUrl: decodeURIComponent(component.get("v.startUrl")),
            includePassword: component.get("v.includePasswordField"),
            // title: payload.title,
            country: payload.country,
            postcode: this.formatPostCode(payload.postcode),
            mobile: mobile,
            phone: payload.phone,
            subscribed: payload.subscribed,
            tncAccepted: true,
            customerType: payload.customerType,
            profession: payload.profession,
            employeeSize: payload.employeeSize,
            // securityQuestion: payload.securityQuestion,
            // answer: payload.answer,
            referralCode: payload.referralCode
            
        }
    },

    formatPostCode: function(postcode) {
        const pad = '0000';
        return pad.substring(0, pad.length - postcode.length) + postcode;
    },

    showErrorMessage: function(component, message) {
        component.set("v.errorMessage", message);
        component.set("v.showError", true);
    },
})