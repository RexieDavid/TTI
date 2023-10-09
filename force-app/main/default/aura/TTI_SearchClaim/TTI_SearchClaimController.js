({
    doInit: function(component, event, helper) {
        const currDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        const searchObj = helper.generateSearchObject(component);
        component.set('v.currDate', currDate);
        component.set('v.searchObj', searchObj);

        if (!$A.util.isEmpty(searchObj.claimNumber)) {
            component.openServiceRequestPage();
        }
    },

    validateDate: function(component, event) {
        component.set('v.isRendered', false);
        const { fromDate, toDate } = component.get('v.searchObj');
        const hasFromValue = !$A.util.isUndefinedOrNull(fromDate) && !$A.util.isEmpty(fromDate);
        const hasToValue = !$A.util.isUndefinedOrNull(toDate) && !$A.util.isEmpty(toDate);
        component.set('v.isDateRangeRequired', hasFromValue || hasToValue);   
        component.set('v.isRendered', true);
    },

    populatePredictiveFields: function(component, event) {
        var selectedObj = event.getParam('sObject');
        var sObjectLabel = event.getParam('SobjectLabel');
        if (sObjectLabel === 'Customer') {
            component.set('v.searchObj.customerId', selectedObj.Id);
        } else if (sObjectLabel === 'Retailer') {
            component.set('v.searchObj.retailerId', selectedObj.Id);
        } else if (sObjectLabel === 'Product') {
            component.set('v.searchObj.productId', selectedObj.Id);
        }
    },

    caseNumberClicked: function(component, event, helper) {
        var table = component.find('table');
        $A.util.toggleClass(table, 'slds-hide');
        var index = event.currentTarget.dataset.index;
        var serviceReqCaseList = component.get('v.serviceReqCaseList');
        var searchClaimBlock = component.find('searchClaimBlock');
        if (searchClaimBlock.length > 1) {
            searchClaimBlock[0].destroy();
            searchClaimBlock[1].destroy();
        }
        component.set('v.caseNumber', serviceReqCaseList[index].CaseNumber);
        component.set('v.showServiceReqCmp', true);
    },

    formPress: function(component, event, helper) {
        if (event.keyCode === 13) {
            component.openServiceRequestPage(component);
        }
    },

    searchClicked: function(component, event, helper) {
        const searchObj = component.get('v.searchObj');
        const isValid = helper.fieldValueValidation(component, searchObj);
        if (isValid) {
            component.set('v.serviceReqCaseList', []);
            $A.util.addClass(component.find("table"), "slds-hide");
            $A.util.removeClass(component.find("mySpinner"), "slds-hide");
            const action = component.get("c.doSearchServiceReq");
            action.setParams(searchObj);
            action.setCallback(this, function(response) {
                const spinner = component.find("mySpinner");
                const table = component.find("table");
                const state = response.getState();
                const errorBox = component.find("errorBox");
                if (response !== null && state === 'SUCCESS') {
                    errorBox.set("v.value", '');
                    const serviceReqCase = JSON.parse(response.getReturnValue());
                    if (serviceReqCase.length === 1) {
                        $A.util.addClass(table, "slds-hide");
                        const searchClaimBlock = component.find("searchClaimBlock");
                        if (searchClaimBlock.length > 1) {
                            searchClaimBlock[0].destroy();
                            searchClaimBlock[1].destroy();
                        }
                        component.set('v.caseNumber', serviceReqCase[0].CaseNumber);
                        component.set('v.showServiceReqCmp', true);
                    } else {
                        $A.util.addClass(table, "slds-hide");
                        helper.createTable(component, serviceReqCase);
                    }

                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    errorBox.set("v.value", errors[0].message);
                } else {
                    errorBox.set("v.value", 'An error occured while searching a service request. Please contact your administrator.');
                }
                $A.util.toggleClass(spinner, "slds-hide");
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
        }
    },

    cancelClicked: function(component, event, helper) {
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            'url': '/'
        });
        urlEvent.fire();
    }
})