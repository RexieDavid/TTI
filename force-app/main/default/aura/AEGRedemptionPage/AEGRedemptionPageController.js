({
    doInit: function(component, event, helper) {
        if (helper.getURLParameter('target')) {
            helper.hideComponent(component.find('mainDiv'));
        } else {
            helper.initializeCustomSettings(component);
        }
    },

    handleNavigate: function(component, event, helper) {
        if (event.getParam('Target') === component.get('v.PageName')) {
            helper.showComponent(component.find('mainDiv'));
        }
    },

    navigateToActivePromotions: function(component, event, helper) {
        helper.navigateTo(component, 'AEGRedemptionPromotions');
        helper.hideComponent(component.find('mainDiv'));
    },

    navigateToRedemptionList: function(component, event, helper) {
        helper.navigateTo(component, 'AEGRedemptionList');
        helper.hideComponent(component.find('mainDiv'));
    },

    navigateToToolbag: function(component, event, helper) {
        let siteSettings = component.get('v.siteSettings');
        helper.navigateto(siteSettings.Register_New_Product__c);
    }
})