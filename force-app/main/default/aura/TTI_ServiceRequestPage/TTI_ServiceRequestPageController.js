({
    doInit: function(component, event, helper) {
        let spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, 'slds-hide');

        let action = component.get('c.getUserType');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.userType', response.getReturnValue());
                $A.util.addClass(spinner, 'slds-hide');

                $A.enqueueAction(getTableMaxRecordsJS);
            }
        });
        $A.enqueueAction(action);

        let getTableMaxRecordsJS = component.get('c.getTableMaxRecords');
        getTableMaxRecordsJS.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                let retVal = response.getReturnValue();
                component.set('v.listMaxRecords', parseInt(retVal));
            }
        });
    },

    handleNewBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'New');
    },

    handleAwaitingApprovalBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'Awaiting Approval');
    },

    handleInProgressBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'In Progress');
    },

    handleCompleteBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'Completed');
    },

    handleClosedBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'Closed');
    },

    handleRejectedBtnClick: function(component, event, helper) {
        helper.displayListView(component, 'Rejected');
    },

    caseNumberClicked: function(component, event, helper) {
        const val = event.getParam('selectedValue');
        component.set('v.caseNumber', val);
        component.set('v.showListView', false);
        component.set('v.showServiceReqCmp', true);
    },

    getRecords: function(component, event, helper) {
        let spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, 'slds-hide');

        const claimType = component.get('v.listViewObj.claimType');
        const dateOpenedFilter = component.get('v.dateOpenedFilter');
        const whereQuery = helper.WHERE_CLAUSE[claimType].replace('<purchase_date>', dateOpenedFilter);
        const fields = helper.FIELDS[claimType];

        let action = component.get('c.getCasedeatils');
        action.setParams({
            'whereQuery': whereQuery,
            'fields': fields
        });
        action.setCallback(this, function(response) {
            $A.util.addClass(spinner, 'slds-hide');

            if (response.getState() === 'SUCCESS') {
                let claims = JSON.parse(response.getReturnValue());
                helper.populateClaimPriorityAndInvoiceLink(component, claims, claimType);
                component.set('v.listViewObj.data', claims);
                component.set('v.pageNumber', 1);
            }
        });
        $A.enqueueAction(action);
    }
})