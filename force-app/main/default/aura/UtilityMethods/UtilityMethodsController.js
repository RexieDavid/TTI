({
    showToast: function(component, event, helper) {
        let methodArguments = event.getParam('arguments');
        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "type": methodArguments.type,
            "title": methodArguments.title,
            "message": methodArguments.message,
            "mode": methodArguments.mode,
            "duration": methodArguments.duration
        });
        toastEvent.fire();
    },

    correctLocalPhoneNumber: function(component, event, helper) {
        let methodArguments = event.getParam('arguments');
        let phoneNumber = methodArguments.phoneNumber;
        let isValidField = methodArguments.isValidField;

        if(!isValidField) return null;
        if(phoneNumber.substring(0,2) == '04') return phoneNumber.replace('04','+614');
        if(phoneNumber.substring(0,2) == '02') return phoneNumber.replace('02','+642');
    },

    format: function(component, event, helper) {
        let methodArguments = event.getParam('arguments');

        return methodArguments.stringVal.replace(/\{(\d+)\}/g, function() {
            return methodArguments.replacements[arguments[1]];
        });
    },

    jsGetPicklistValues: function(component, event, helper) {
        let methodArguments = event.getParam('arguments');

        let action = component.get("c.getPickListValuesToJSON");

        action.setParams({
            "mapObjAndPicklistJSON" : JSON.stringify(methodArguments.mapObjAndPicklist)
        });

        action.setCallback(this, function(response){
            let responseState = response.getState();

            if(responseState == 'SUCCESS') {
                let responseVal = response.getReturnValue();
                if(responseVal != null) {                    
                    let parsedVal = JSON.parse(responseVal);

                    let response = {
                        'State' : 'SUCCESS',
                        'value' : parsedVal
                    };

                    methodArguments.resolve(JSON.stringify(response));
                }
            } else {
                // TODO: reject function
            }
        });

        $A.enqueueAction(action);
    }
})