({

	getCurrentUser : function (component, event, helpler) {
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
        var action = component.get("c.getCurrentUser");

        var params = parseQueryString(location.search);
        var contactId = params.id;

        action.setParams({
            contactId : contactId
        });

        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            
            console.log('currentUser', rtnValue);
            
            component.set('v.currentUser', rtnValue.split('=::=')[0]);
            component.set('v.isGuest', rtnValue.split('=::=')[1].toUpperCase().includes('SITE GUEST USER'));
        });
        
        $A.enqueueAction(action);
    },
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
            contactId : contactId
        });

        action.setCallback(this, function(response) {
            var rtnValue = response.getReturnValue();
            
            console.log('rtnValue', rtnValue);
            
            component.set('v.hasCustomerFinishedSurvey', rtnValue);
            
            if (rtnValue === true) {
                //helpler.navigateToHome(component, event, helpler);
                //$A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    navigateToHome: function(component, event, helpler) {
        var homeUrl = component.get("v.homeUrl");
        if (homeUrl != null) {
            var attributes = { url: homeUrl };
            $A.get("e.force:navigateToURL").setParams(attributes).fire();
        }   
    },
    handleSubmitSurvey : function(component, event, helpler) {
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

        var action = component.get("c.saveSurvey");
        var question1 = component.get("v.question1");
        var question2 = component.get("v.question2");
        var params = parseQueryString(location.search);
        var contactId = params.id;

        action.setParams({
            contactId : contactId,
            q1 : question1,
            q2 : question2
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var rtnValue = response.getReturnValue();
                
                if (rtnValue == 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.log('There was an error: ' + rtnValue);
                }
            } else {
                console.log('Error!!!');
            }
            
        });

        $A.enqueueAction(action);

    },
    handleDismissSurvey : function(component, event, helpler) {
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

        var action = component.get("c.cancelSurvey");
        var params = parseQueryString(location.search);
        var contactId = params.id;

        action.setParams({
            contactId : contactId
        });
        
        console.log('contactId', contactId);
        console.log('action', action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var rtnValue = response.getReturnValue();
                
                if (rtnValue == 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.log('There was an error: ' + rtnValue);
                }
            } else {
                console.log('Error!!!');
            }
            
        });

        $A.enqueueAction(action);

    },
    handleSelectQ1Answer : function(component, event, helpler) {
        var clickedValue = event.currentTarget.dataset.value;
        var q1buttons = document.querySelectorAll('.q1-circles');

        for (var i = 0; i < q1buttons.length; i ++) {
            if (q1buttons[i].getAttribute('data-value') == clickedValue) {
                q1buttons[i].classList.add('selected-rows');
            } else {
                q1buttons[i].classList.remove('selected-rows');
            }
        }

        component.set('v.question1', clickedValue);
    },
    handleSelectQ2Answer : function(component, event, helpler) {
        var clickedValue = event.currentTarget.dataset.value;
        var q2buttons = document.querySelectorAll('.q2-circles');

        for (var i = 0; i < q2buttons.length; i ++) {
            if (q2buttons[i].getAttribute('data-value') == clickedValue) {
                q2buttons[i].classList.add('selected-rows');
            } else {
                q2buttons[i].classList.remove('selected-rows');
            }
        }

        component.set('v.question2', clickedValue);
    }
})