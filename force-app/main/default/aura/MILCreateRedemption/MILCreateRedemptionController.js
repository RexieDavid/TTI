({
	handleNavigate : function(component, event, helper) {
		if(event.getParam('Target') == component.get('v.PageName')) {
			helper.showComponent(component.find('createRedemptionDiv'));
			component.set('v.selectedPromo', JSON.parse(event.getParam('RecordJSON')));
			component.set('v.selectedPromoJSON', event.getParam('RecordJSON'));
		}		
	},

	doInit : function(component, event, helper) {
		var getUserDetails = component.get("c.getPersonAccountDetails");

		getUserDetails.setCallback(this, function(response) {
			var data = JSON.parse(response.getReturnValue());
            var countryListString = component.get('v.countryListString');
            component.set('v.countryList', countryListString);
				
			if(data != null) {
				component.set('v.contactInfo', data);
				component.set('v.contactInfoJSON', response.getReturnValue());
				/*
				component.set('v.state', data.MailingState);
				component.set('v.country', data.Mailingddress.country);
				component.set('v.postcode', data.MailingAddress.postalCode);
				component.set('v.suburb', data.MailingAddress.city);
				component.set('v.address', data.MailingAddress.street);*/
                component.set('v.state', data.MailingState);
				component.set('v.country', data.MailingCountry);
				component.set('v.postcode', data.MailingPostalCode);
				component.set('v.suburb', data.MailingCity);
				component.set('v.address', data.MailingStreet);
			} else {
				component.set('v.state', '');
				component.set('v.country', '');
				component.set('v.postcode', '');
				component.set('v.suburb', '');
				component.set('v.address', '');
			}


	        
	        $A.enqueueAction(getSiteSettingsJS);
		});
		$A.enqueueAction(getUserDetails);

		var getSiteSettingsJS = component.get("c.getSiteSettings");
        getSiteSettingsJS.setStorable();
        getSiteSettingsJS.setCallback(this, function(response){
            var customSettingValues = response.getReturnValue();
            var test = customSettingValues.Lead_Source__c;
            var leadSource = customSettingValues.communitySettings.Lead_Source__c;
            var countryMap = {'Australia':'Australian', 'New Zealand':'New Zealand'};
            var country = leadSource == 'MYAEG' ? 'Australia' : leadSource == 'MYAEGNZ' ? 'New Zealand': '';
            document.querySelector(".shippingAddress").innerHTML = `Shipping Address – ${countryMap[country]} address only`;
            component.set("v.country", country);
            component.set("v.siteSettings", customSettingValues.communitySettings);
        });
	},

	submitRedemptionJS : function(component, event, helper) {
		helper.toggleSpinner();

		var selectedPromo = JSON.parse(component.get('v.selectedPromoJSON'));
		var contactInfo = JSON.parse(component.get('v.contactInfoJSON'));
		var submitRedemption = component.get('c.submitRedemption');

		submitRedemption.setParams({
			'contactInfoJSON' : JSON.stringify(contactInfo),
			'selectedAssetJSON' : JSON.stringify(selectedPromo)
		});
		
		submitRedemption.setCallback(this, function(response) {
			if(response.getState() == 'SUCCESS') {
				var data = JSON.parse(response.getReturnValue());
				helper.refreshTables();
				helper.toggleSpinner();

				helper.navigateTo(component, 'MILRedemptionList');
				helper.hideComponent(component.find('createRedemptionDiv'));
			} else {

			}
		});

		$A.enqueueAction(submitRedemption);
	},

	toggleView : function(component, event, helper) {
		var target = event.getSource().getLocalId();
		if(target == 'conEditButtonRedemption' || target == 'conDeleteButtonRedemption') {
			if(component.get('v.contactEdit') == true) {
				helper.removeHideCSS(component.find('conViewDetails'));
				helper.addHideCSS(component.find('conEditDetails'));
				helper.showComponent(component.find('conEditButtonRedemption'));
				helper.hideComponent(component.find('conDetailsButtons'));

				component.set('v.contactEdit', false);
			} else {
				helper.addHideCSS(component.find('conViewDetails'));
				helper.removeHideCSS(component.find('conEditDetails'));
				helper.hideComponent(component.find('conEditButtonRedemption'));
				helper.showComponent(component.find('conDetailsButtons'));

				component.set('v.contactEdit', true);
			}			
		} else if(target == 'shipEditButtonRedemption' || target == 'shipDeleteButtonRedemption') {
			if(component.get('v.shippingAddressEdit') == true) {
				helper.removeHideCSS(component.find('shipViewDetails'));
				helper.addHideCSS(component.find('shipEditDetails'));
				helper.showComponent(component.find('shipEditButtonRedemption'));
				helper.hideComponent(component.find('shipAddressButtons'));

				component.set('v.shippingAddressEdit', false);
			} else {
				helper.addHideCSS(component.find('shipViewDetails'));
				helper.removeHideCSS(component.find('shipEditDetails'));
				helper.hideComponent(component.find('shipEditButtonRedemption'));
				helper.showComponent(component.find('shipAddressButtons'));

				component.set('v.shippingAddressEdit', true);
			}				
		}
	},

	closeAlert : function(component, event, helper) {
		helper.hideComponent(component.find('alertErrorMsg'));
	},

	saveDetails : function(component, event, helper) {
		helper.toggleSpinner();

		var inputFirstName = component.find('inputFirstName').get('v.value');
		var inputLastName = component.find('inputLastName').get('v.value');
		var inputMobile = component.find('inputMobile').get('v.value');
		var inputEmail = component.find('inputEmail').get('v.value');
		var inputStreet = component.get('v.address');
		var inputCity = component.get('v.suburb');
		var inputProvince = component.get('v.state');
		var inputPostalCode = component.get('v.postcode');
		var inputCountry = component.get('v.country');

		if(helper.validateForm(component, inputProvince, inputPostalCode, inputStreet, inputCity)) {
			helper.hideComponent(component.find('alertErrorMsg'));
			var updateContactDetails = component.get('c.updateContactDetails');
			updateContactDetails.setParams({
				'inputFirstName' : inputFirstName,
				'inputLastName' : inputLastName,
				'inputMobile' : inputMobile,
				'inputEmail' : inputEmail,
				'inputStreet' : inputStreet,
				'inputCity' : inputCity,
				'inputCountry' : inputCountry,
				'inputProvince' : inputProvince,
				'inputPostalCode' : inputPostalCode
			});

			updateContactDetails.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS') {
					var data = JSON.parse(response.getReturnValue());
					component.set('v.contactInfo', data);
					component.set('v.contactInfoJSON', response.getReturnValue());

					var selectedPromo = JSON.parse(component.get('v.selectedPromoJSON'));
					var submitRedemption = component.get('c.submitRedemption');

					submitRedemption.setParams({
						'contactInfoJSON' : response.getReturnValue(),
						'selectedAssetJSON' : JSON.stringify(selectedPromo)
					});
					
					submitRedemption.setCallback(this, function(response) {
						if(response.getState() == 'SUCCESS') {
							var data = JSON.parse(response.getReturnValue());
							helper.hideComponent(component.find('createRedemptionDiv'));
							helper.navigateTo(component, 'MILRedemptionList');
                            helper.toggleSpinner();
							helper.refreshTables();	
						} else {
							helper.toggleSpinner();
						}
					});

					$A.enqueueAction(submitRedemption);
				} else {
					helper.toggleSpinner();
				}
			});

			$A.enqueueAction(updateContactDetails);
		} else {
			helper.showComponent(component.find('alertErrorMsg'));
		}
	},
      KeyUpHandler: function (component, event, helper) {
		var searchString = component.get("v.searchString");
		if(searchString != null && searchString != ''){
			helper.openListbox(component, searchString);
			helper.displayPredictions(component, searchString);
		}else{
			helper.clearComponentConfig(component);
		}
    },
    
    selectOption: function (component, event, helper) {  
        
        var list = component.get("v.predictions");        
        var placeId = component.get("v.placeId");        
        var searchLookup = component.find("searchLookup");        
        var iconPosition = component.find("iconPosition");        
        var selection  = event.currentTarget.dataset.record;      
       // alert(selection);
        for (var i =0; i < list.length; i++) {         
            if (list[i].label == selection ) {  
                
                placeId = (list[i].PlaceId);                
            }            
        }
        
        component.set("v.selectedOption ", selection);        
        component.set("v.searchString", selection);        
        
        $A.util.removeClass(searchLookup, 'slds-is-open');        
        $A.util.removeClass(iconPosition, 'slds-input-has-icon_left');        
        $A.util.addClass(iconPosition, 'slds-input-has-icon_right');
   
        helper.displaySelectionDetails(component, placeId);
        
        
    },
    
    clear: function (component, event, helper) {
        
        helper.clearComponentConfig(component);
        
    },
    onCheck:function (component, event, helper) {
        var checkdisAdd = component.get("v.disAddress");
		
        if(checkdisAdd == true){
            component.set("v.disAddress",false);
        }else{
            component.set("v.disAddress",true);
        }
        helper.clearComponentConfig(component); 
    },
    
})