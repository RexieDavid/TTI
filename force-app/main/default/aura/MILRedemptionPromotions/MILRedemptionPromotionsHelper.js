({
	redemptionFlag: true,


	hideComponent : function(component) {
		$A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
	},

	showComponent : function(component) {
		$A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
	},
    
    initializeCustomSettings : function (component){
        var action = component.get("c.getSiteSettings");
        action.setStorable();
        action.setCallback(this, function(response){
            var customSettingValues = response.getReturnValue();
            component.set("v.siteSettings", customSettingValues.communitySettings);
        });
        
        $A.enqueueAction(action);
    },

	getAllPromotions : function(component) {
        debugger;
		var getAllActivePromotions = component.get('c.getAllActivePromotions');
		var promotionId = this.getURLParameter('PromotionId');

		getAllActivePromotions.setCallback(this, function(response) {
			var data = JSON.parse(response.getReturnValue());
			component.set('v.activePromotions', data);
		});

		$A.enqueueAction(getAllActivePromotions);

		if(promotionId != null && promotionId != '') {
            debugger;
			var getPromotion = component.get('c.getPromotion');

			getPromotion.setParams({
				'redemptionCampaignId': promotionId
	        });

	        getPromotion.setCallback(this, function(response) {
                var result = response.getReturnValue();
                debugger;
                if(result != '') {
                    var data = JSON.parse(result);                    
                    
                    if(data!=null) {
                        debugger;
                        var recordJSON = null;
                        for(var i = 0; i <= data.length; i++) {
                            if(data[i].Id == promotionId || data[i].Id.substring(0, 15) == promotionId) {
                                debugger;
                                recordJSON = data[i];
                                debugger;
                                break;
                            }
                        }
                        
                        debugger;
                        if(recordJSON != null) {
                            debugger;
                            var navEvent = $A.get("e.c:NavigateEvent");
                            navEvent.setParams({ 
                                "Target": "MILCreateRedemption",
                                "RecordJSON": JSON.stringify(recordJSON)
                            });
                            navEvent.fire();
                        }
                    }
                } else {
                    debugger;
                    var url = component.get('v.siteSettings').Redemption__c;
        			window.location.href = url;
                }                    
	        });

			$A.enqueueAction(getPromotion);

		} else {
            debugger;
			var getAvailablePromotions = component.get('c.getAvailablePromotions');

			getAvailablePromotions.setCallback(this, function(response) {
				var data = JSON.parse(response.getReturnValue());
				
				if(data!=null) {
					for (var i = data.length - 1; i >= 0; i--) {
						var d = new Date(data[i]['Valid_To__c']);
						data[i].validUntil = d.getDate() + '/' + (d.getMonth() + 1) + '/' + d.getFullYear();
					}
					component.set('v.availablePromotions', data);
					component.set('v.availablePromotionsJSON', response.getReturnValue());
				}				
			});

			$A.enqueueAction(getAvailablePromotions);
		}			
	},

	getURLParameter : function(name) {
		return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
	}
})