({
    init: function (component, event, helper) {
        const sObjectName = component.get('v.sObjectName');
        const flowName = component.get('v.warehouseCaseFlowName');
        const flowContainer = component.find('warehouseCase');
        const recordId = component.get('v.recordId');
        const modalHeader = component.find('modal-header');
        const payload = [];

        if (sObjectName === 'Account') {
            payload.push({
                name: 'recordId',
                type: 'String',
                value: recordId
            });
        }

        if (!sObjectName && modalHeader) {
            $A.util.addClass(modalHeader, 'slds-hide')
        }
        flowContainer.startFlow(flowName, payload);
    },

    handleStatusChange: function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            event.preventDefault();

            const sObjectName = component.get('v.sObjectName');
            var navService = component.find("navService");
            var pageReference;

            if (sObjectName === 'Account') {
                pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": component.get('v.recordId'),
                        "objectApiName": 'Account',
                        "actionName": "view"
                    }
                }
            } else {
                navService.navigate(helper.getNamedPageRef('today'));
                pageReference = helper.getNamedPageRef('home');
            }
            
            component.find('notifLib').showToast({
                "title": "Warehouse Case created successfully",
                "mode": "pester",
                "variant": "success",
            });
            navService.navigate(pageReference);
        }
    },

    closeQuickAction: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})