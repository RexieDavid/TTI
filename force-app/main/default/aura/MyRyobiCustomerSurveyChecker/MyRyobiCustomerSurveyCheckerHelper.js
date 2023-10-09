({
	checkIfCustomerHasFinishedSurvey : function (component, event, helpler) {
        var parseQueryString = function(url) {
            var urlParams = {};
            url.replace(
                new RegExp("([^?=&]+)(=([^&]*))?", "g"),
                function($0, $1, $2, $3) {
                    urlParams[$1] = $3;
                }
            );

            return urlParams;
        }
        
		var action = component.get("c.hasCustomerFinishedSurvey");

        var params = parseQueryString(location.search);
        var contactId = params.id;

        action.setParams({
            contactId : ''
        });
        
        action.setCallback(this, function(a) {
        	var rtnValue = a.getReturnValue();
            
            console.log('rtnValue', rtnValue);
            
            component.set('v.hasCustomerFinishedSurvey', rtnValue);
            
            if (rtnValue === false) {
                helpler.navigateToSurvey(component, event, helpler);
            }
        });
        
        $A.enqueueAction(action);
	},
    navigateToSurvey: function(component, event, helpler) {
        var action = component.get("c.getCurrentUser");
        action.setParams({
            contactId : ''
        });

        console.log('action', action.getParams());
        
        action.setCallback(this, function(a) {
            var currentUser = a.getReturnValue();

            component.set('v.currentUser', currentUser);
            console.log('currentUser', currentUser);
            
            if (currentUser !== 'User') {
                helpler.navigateToSurvey(component, event, helpler);

                var surveyUrl = component.get("v.surveyUrl");
                if (surveyUrl != null) {
                    var attributes = { url: surveyUrl + '?id=' + currentUser };
                    $A.get("e.force:navigateToURL").setParams(attributes).fire();
                }
            }
        }); 

        $A.enqueueAction(action);
    } 
})