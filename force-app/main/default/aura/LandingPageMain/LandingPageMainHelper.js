({
    navigateTo: function(page) {
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            'url': page,
            'isredirect': false
        });
        urlEvent.fire();
    },

    navigateToProfile: function(page) {
        var urlEvent = $A.get('e.force:navigateToURL');
        var userId = $A.get('$SObjectType.CurrentUser.Id');
        urlEvent.setParams({
            'url': page + userId + '?tabTitle=Communication preferences',
            'isredirect': false

        });
        urlEvent.fire();
    },


    

    initializeCustomSettings: function(component) {
        var actionGetSiteSettings = component.get('c.getSiteSettings');
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf('site'));

        component.set('v.baseURL', baseURL);

        actionGetSiteSettings.setCallback(this, function(response) {
            var customSettingValues = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.userCountry', customSettingValues.userCountry);
                const commSettings = customSettingValues.communitySettings;
                if (customSettingValues.userCountry === 'Australia') {
                    component.set('v.warrantyURL', commSettings.Warranty_URL__c);
                    component.set('v.promotionsURL', commSettings.Promotions_URL__c);
                } else {
                   component.set('v.warrantyURL', commSettings.Warranty_URL_NZ__c);
                   component.set('v.promotionsURL', commSettings.Promotions_URL_NZ__c);
                }
            }
        });
        $A.enqueueAction(actionGetSiteSettings);
    },

    getUserDetails: function(component) {
        var userId = $A.get('$SObjectType.CurrentUser.Id');
        component.set('v.userId', userId);
        
        var actionGetSurveyDetails = component.get('c.getSurveyDetails');
        actionGetSurveyDetails.setParams({ userId: userId });

        actionGetSurveyDetails.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            component.set('v.currentUser', rtnValue);
            // component.set('v.hasCustomerFinishedSurvey', rtnValue.Account.Is_survey_completed__c);
            component.set('v.country', rtnValue.Country);
        });
        $A.enqueueAction(actionGetSurveyDetails);
    },

    convertCountryNameToCode: function(component) {
        var country = component.get('v.country');
        if (country === 'Australia') {
            component.set('v.country', 'AU');
        } else if (country === 'New Zealand') {
            component.set('v.country', 'NZ');
        } else {
            component.set('v.country', 'AU');
        }
    },

    showToast: function(title, message) {
        $A.get('e.force:showToast').setParams({
            'title': title,
            'message': message
        }).fire();
    }
})