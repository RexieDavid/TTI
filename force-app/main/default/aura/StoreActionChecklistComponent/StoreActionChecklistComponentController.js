({
    initialize: function(component, event, helper) {
        helper.fetchRecords(component, event);
        helper.fetchTotalTime(component, event);
    },

    handleNext: function(component, event, helper) {
        helper.isTotalTimeExceeded(component, 'FromParent', null);
        let isTimeIncrease = component.get("v.isTimeIncrease");
        if (!isTimeIncrease) {
            return;
        }
        component.set("v.confirmDialog", true);
    },

    handleDialogCancel: function(component) {
        component.set("v.confirmDialog", false);
    },

    handleDialogYes: function(component, event, helper) {
        helper.setFileUpload(component);
        helper.closeDialogBox(component);
        helper.handleSave(component, event);
    },

    onOther: function(component, event, helper) {
        helper.handleOtherClick(component);
    },

    closeQuickAction: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleComponentEvent: function(component, event, helper) {
        var valueFromChild = event.getParam("isFinish");
        component.set("v.showFinish", valueFromChild);
    },

    HideDialogBox: function(component, event, helper) {
        component.set("v.isTimeIncrease", true);
    },

    checkTotalTimeMethod: function(component, event, helper) {
        var firedFrom = event.getParam("firedFrom");
        var childName = event.getParam("childName");
        component.set("v.firedFrom", firedFrom);
        helper.isTotalTimeExceeded(component, 'FromChild', childName);
    },

    viewOffLocation: function(component, event, helper) {
        component.set("v.showChecklistSection", false);
        component.set("v.showOffLocationSection", true);
    },
    
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam("selectedRows");
        component.set("v.selectedRowsCount", selectedRows.length);
        component.set("v.selectedRows", selectedRows.map(row => row.Id));
    },

    handleSort: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    handleHeaderAction: function (component, event, helper) {
        // Retrieves the name of the selected filter
        var actionName = event.getParam("action").name;
        // Retrieves the current column definition
        // based on the selected filter
        var colDef = event.getParam("columnDefinition");
        var columns = component.get("v.columns");
        var activeFilter = component.get("v.activeFilter");
        if (actionName !== activeFilter) {
            var idx = columns.indexOf(colDef);
            // Update the column definition with the updated actions data
            var actions = columns[idx].actions;
            actions.forEach(function (action) {
                action.checked = action.name === actionName;
            });
            component.set("v.activeFilter", actionName);
            helper.updateBooks(component);
            component.set("v.columns", columns);
        }
    },

    handleOffLocSave: function(component, event, helper) {
        if(component.get("v.selectedRowsCount") > 0) {
            component.set("v.saveOffLoc", true);
        } else {
            helper.showChecklist(component);
        }
    },

    handleOffLocReviewed: function(component, event, helper) {
        if(component.get("v.selectedRowsCount") > 0) {
            component.set("v.reviewOffLoc", true);
        } else {
            helper.showChecklist(component);
        }
    },

    closeOffLocation: function(component, event, helper) {
        helper.showChecklist(component);
    },

    handleOffLocCancel: function(component) {
        component.set("v.saveOffLoc", false);
    },

    handleOffLocYes: function(component, event, helper) {
        component.set("v.saveOffLoc", false);
        helper.saveOffLocation(component, event, "Deactivate");
    },

    handleReviewCancel: function(component) {
        component.set("v.reviewOffLoc", false);
    },

    handleReviewYes: function(component, event, helper) {
        component.set("v.reviewOffLoc", false);
        helper.saveOffLocation(component, event, "Reviewed");
    }
})