({
    handleNavigate: function(component, event, helper) {
        if (event.getParam('Target') === component.get('v.pageName')) {
            helper.initializeData(component);
            helper.showComponent(component.find('promotionListDiv'));
        }
    },

    navigateTo: function(component, event, helper) {
        var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": 'AEGRedemptionPage' });
        navEvent.fire();
        helper.hideComponent(component.find('promotionListDiv'));
    },
})