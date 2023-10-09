({
	doInit : function(component, event, helper) {
		if(helper.getURLParameter('PromotionId') != null && helper.getURLParameter('PromotionId') != '') {
			helper.hideComponent(component.find('mainDiv'));
		}
	},

	handleNavigate : function(component, event, helper) {		
		if(event.getParam('Target') == component.get('v.PageName')) {
			helper.showComponent(component.find('mainDiv'));
		}	
	},

	navigateToActivePromotions : function(component, event, helper) {
        helper.navigateTo(component, 'MILRedemptionPromotions');
        helper.hideComponent(component.find('mainDiv'));
	},

	navigateToRedemptionList : function(component, event, helper) {        
        helper.navigateTo(component, 'MILRedemptionList');
        helper.hideComponent(component.find('mainDiv'));
	},

    navigatetotoolbag: function(component, event, helper) {
        helper.navigateto('/register-new-product/');
	}   
})