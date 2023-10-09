({
    open : function(component, event, helper) {
        
        var params = event.getParam('arguments');

        var modal;
        if (params.modalToOpen === 'SessionMgmt') {
            component.set('v.personAccountId', params.personAccountId);

            modal = component.find("modalForSessionMgmt");
            $A.util.removeClass(modal, 'slds-hidden');
            $A.util.addClass(modal, 'slds-fade-in-open');
        } else {
            // SessionBooking
            component.set('v.selectedSessionDate', params.selectedSessionDate);
            component.set('v.selectedSessionTime', params.selectedSessionTime);

            modal = component.find("modalForSessionBooking");
            $A.util.removeClass(modal, 'slds-hidden');
            $A.util.addClass(modal, 'slds-fade-in-open');
        }

        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-hidden');
        $A.util.addClass(backdrop, 'slds-backdrop_open');
    },

    closeModalForSessionMgmt : function(component, event, helper) {

        // var action = component.get("c.isMifgsPromoEligible");
        // action.setParams({});
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     console.log('DBG: state >>> ', state);
        //     var ret = response.getReturnValue();
        //     console.log('DBG: ret >>> ', ret);
        // });
        // $A.enqueueAction(action);

        // helper.handleShowModal(component);

        console.log('DBG: closing...');

        // console.log('DBG: modalId > ', component.get("v.modalId"));
        // console.log('DBG: has slds-fade-in-open > ', $A.util.hasClass(component.find("modalForSessionMgmt"), 'slds-fade-in-open'));
        var modal = component.find("modalForSessionMgmt");
        // console.log('DBG: modal > ', modal);

        // console.log('DBG: has slds-backdrop_open > ', $A.util.hasClass(component.find("backdrop"), 'slds-backdrop_open'));
        var backdrop = component.find('backdrop');
        // console.log('DBG: backdrop > ', backdrop);

        $A.util.removeClass(backdrop, 'slds-backdrop_open');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        
        console.log('DBG: closed.');

    },

    showSessionMgmt : function(component, event, helper) {
        console.log('DBG: showSessionMgmt');

        var stateUpdated = component.getEvent("stateUpdated");
        stateUpdated.setParams({
            "state" : "segmentationFinished",
            "personAccountId" : component.get("v.personAccountId")
        });
        stateUpdated.fire();
    },

    reShowSegmentationForm : function(component, event, helper) {
        
        var stateUpdated = component.getEvent("stateUpdated");
        stateUpdated.setParams({
            "state" : "modalToSessionMgmtCancelled"
        });
        stateUpdated.fire();
        
    },

    triggerSessionSelectionFinishedEvt : function(component, event, helper) {
        
        var stateUpdated = component.getEvent("stateUpdated");
        stateUpdated.setParams({
            "state" : "sessionSelectionFinished"
        });
        stateUpdated.fire();
        
    }
})