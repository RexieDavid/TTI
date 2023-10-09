({
	handleNavigate : function(component, event, helper) {
		if(event.getParam('Target') == component.get('v.PageName')) {
			helper.showComponent(component.find('viewRedemptionDiv'));
			var record = JSON.parse(event.getParam('Record'));

			var getRedemptionDetails = component.get('c.getRedemptionDetails');
			getRedemptionDetails.setParams({
				'redemptionId' : record.Id
			});
			getRedemptionDetails.setCallback(this, function(response) {
				var data = JSON.parse(response.getReturnValue());

				if(new Date(data['CreatedDate']) != 'Invalid Date') {
					var date = new Date(data['CreatedDate']);
					var newDate = date.getDate() + '/' + (date.getMonth() + 1) + '/' + (date.getYear() + 1900);
					data['CreatedDate'] = newDate;
				}

				if(data['Status__c'] == 'Approved - Sent to SAP' || data['Status__c'] == 'Approved - SAP Error' 
					|| data['Status__c'] == 'Approved - SAP Order Created') {
					data['Status__c'] = 'In Progress';
				}

				component.set('v.record', data);
			});

			$A.enqueueAction(getRedemptionDetails);
		}	
	},

	navigateToRedemptionList : function(component, event, helper) {
		helper.navigateTo(component, 'MILRedemptionList');
		helper.hideComponent(component.find('viewRedemptionDiv'));
	}
})