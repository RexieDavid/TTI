({
    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    navigateTo: function(component, target) {
        var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": target });
        navEvent.fire();
    },

    getURLParameter: function(name) {
        return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
    },

    navigateto: function(page) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    },
    
    initializeCustomSettings: function(component) {
        var action = component.get("c.getSiteSettings");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var customSettingValues = response.getReturnValue();
                component.set("v.siteSettings", customSettingValues.communitySettings);
            } else {
                this.showToast(component, '', $A.get("$Label.c.AEG_Generic_Error_Message"), 'error');
            }
            
        });
        $A.enqueueAction(action);
    },

    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            "variant": type,
            "title": title,
            "message": message
        });
    },
})