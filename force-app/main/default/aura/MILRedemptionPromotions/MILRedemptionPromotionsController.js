({
	doInit : function(component, event, helper) {
		helper.getAllPromotions(component);
        helper.initializeCustomSettings(component);
	},

	handleNavigate : function(component, event, helper) {
		if(event.getParam('Target') == component.get('v.PageName')) {
			helper.showComponent(component.find('activePromotionDiv'));
		}
		
	},

	navigateToCreateRedemption : function(component, event, helper) {
		var availablePromotions = JSON.parse(component.get('v.availablePromotionsJSON'));
		var selectedPromoId = event.getSource().get('v.value');
		var selectedPromo;
		
		if(availablePromotions!=null) {
				for(var i = 0; i <= availablePromotions.length; i++) {
				if(availablePromotions[i].Id == selectedPromoId) {
					selectedPromo = availablePromotions[i];
					break;
				}
			}
		}			

		var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ 
        	"Target": "MILCreateRedemption",
        	"RecordJSON": JSON.stringify(selectedPromo)
        });
        navEvent.fire();

        helper.hideComponent(component.find('activePromotionDiv'));
	}
})