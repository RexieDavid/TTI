({
    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    handleSelfRegister: function(component) {
        component.set('v.showSpinner', true);
        const regex = $A.get("$Label.c.UTIL_REGEX_ANZ_Email_Format");
        const emailRegex = new RegExp(regex);
        var regConfirmUrl = component.get('v.regConfirmUrl');
        var firstname = component.find('firstname').get('v.value');
        var lastname = component.find('lastname').get('v.value');
        var email = component.find('email').get('v.value');
        var includePassword = component.get('v.includePasswordField');
        var action = component.get('c.selfRegister');
        var extraFields = JSON.stringify(component.get('v.extraFields'));
        var startUrl = component.get('v.startUrl');
        var title = component.get('v.title');
        var country = component.get('v.country');
        var postcode = component.get('v.postCodeNum');
        var mobile = component.get('v.mobileNum');
        var postcodeS = '';
        var mobileS = '';

        if (mobile) {
            mobileS = country === 'Australia' ? '+61' : '+64';
            mobileS = mobileS + mobile.toString();
        }

        if (postcode) {
            postcodeS = postcode.toString();
            var pad = '0000';
            var postcodeS = pad.substring(0, pad.length - postcodeS.length) + postcodeS;
        }

        var phone = component.get('v.phone');
        var subscribed = component.get('v.subscribed');
        var securityQuestion = component.get('v.securityQuestion');
        var answer = component.get('v.answer');
        
        component.set('v.showError', false);
        
        var errorMessage = '';
        if (!firstname) {
            errorMessage = 'Please enter first name.';
        } else if (!lastname) {
            errorMessage = 'Please enter last name.';
        } else if (!email) {
            errorMessage = 'Please enter an email.';
        } else if (!emailRegex.test(email)) {
            errorMessage = 'Please enter a valid Email Address.';
        } else if (!postcodeS) {
           errorMessage = 'Please enter a postcode.';
        } else if (!mobileS) {
            errorMessage = 'Please enter a mobile.';
        } else if (!answer) {
           errorMessage = 'Please enter a security question answer.';
        }

        if (errorMessage.length > 0) {
            component.set('v.errorMessage', errorMessage);
            component.set('v.showError', true);
            component.set('v.showSpinner', false);
            return false;
        }

        startUrl = decodeURIComponent(startUrl);
        action.setParams({
            firstname: firstname,
            lastname: lastname,
            email: email,
            regConfirmUrl: regConfirmUrl,
            extraFields: extraFields,
            startUrl: startUrl,
            includePassword: includePassword,
            title: title,
            country: country,
            postcode: postcodeS,
            mobile: mobileS,
            phone: phone,
            subscribed: subscribed,
            tncAccepted: true,
            securityQuestion: securityQuestion,
            answer: answer
        });
        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue) {
                component.set('v.errorMessage', rtnValue);
                component.set('v.showError', true);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    getExtraFields: function(component) {
        var action = component.get('c.getExtraFields');
        action.setParam('extraFieldsFieldSet', component.get('v.extraFieldsFieldSet'));
        action.setCallback(this, function(reponse) {
            var rtnValue = reponse.getReturnValue();
            if (rtnValue) {
                component.set('v.extraFields', rtnValue);
                component.set('v.fieldType', rtnValue.value === 'PICKLIST');
            }
        });
        $A.enqueueAction(action);
    },

    initializeCustomSettings: function(component) {
        var action = component.get('c.getCommunitySettings');
        component.set('v.countryList', [component.get('v.country')]);
        action.setCallback(this, function(response) {
            var customSettingValues = response.getReturnValue();
            component.set('v.terms', customSettingValues.Terms_and_Condition__c);
        });
        $A.enqueueAction(action);
    },

    checkCountry: function(component) {
        let country = component.get('v.country');
        component.set('v.isAustralia', country === 'Australia');
    }
})