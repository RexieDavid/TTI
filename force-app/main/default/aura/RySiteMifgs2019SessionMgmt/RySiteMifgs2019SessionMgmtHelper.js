({
    fetchSessions : function(component) {
        component.set('v.mycolumns', [
            {label: 'Workshop', fieldName: 'Workshop_Name__c', type: 'text'},
            {label: 'Date', fieldName: 'Date__c', type: 'date'},
            {
                label: 'Start Time', 
                fieldName: 'Start_Time__c', 
                type: 'date', 
                typeAttributes: {
                    hour: '2-digit',
                    minute: '2-digit',
                    timeZone: 'UTC'
                }
            },
            {
                label: 'End Time', 
                fieldName: 'End_Time__c', 
                type: 'date', 
                typeAttributes: {
                    hour: '2-digit',
                    minute: '2-digit',
                    timeZone: 'UTC'
                }
            },
            {
                label: 'Status', 
                fieldName: 'Capacity_Status__c', 
                type: 'text',
                typeAttributes: {
                    class: 'aaa'
                },
                class: 'bbb'
            }
        ]);
        var action = component.get("c.fetchSessions");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('DBG: sessions > ', response.getReturnValue());
                component.set("v.sessions", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    attendSession : function(component) {
        var action = component.get("c.sattendSessionApex");
        action.setParams({
            'personAccountId' : component.get('v.personAccountId'),
            'selectedSessionId' : component.get('v.selectedSessionRecord.Id')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('DBG: state > ', state);
            console.log('DBG: error > ', JSON.stringify(response.getError(), null, '\t'));
            if (state === "SUCCESS") {
                console.log('DBG: SESSION ATTENDEE CREATED > ', response.getReturnValue());
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": "You have successfully joined the session."
                // });
                // toastEvent.fire();

                component.find("modal").open(
                    'SessionBooking',
                    null,
                    component.get('v.selectedSessionRecord.Date__c'),
                    component.get('v.selectedSessionRecord.Start_Time__c')
                );
            }
            if (state === "ERROR") {
                // TODO
            }
        });
        $A.enqueueAction(action);
    },

    cancelSessionSelection : function(component) {
        
        var stateUpdated = component.getEvent("stateUpdated");
        stateUpdated.setParams({
            "state" : "sessionSelectionFinished"
        });
        stateUpdated.fire();

    }
})