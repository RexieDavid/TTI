({
    initialize : function(component, event, helper) {
        helper.fetchSessions(component);
    },

    onSessionSelected : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        // cmp.set('v.selectedRowsCount', selectedRows.length);
        console.log('DBG: selectedRows > ', JSON.stringify(selectedRows, null, '\t'));
        // component.set('v.selectedSessionId', selectedRows[0].Id);
        component.set('v.selectedSessionRecord', selectedRows[0]);
    },

    handleAttendSession : function(component, event, helper) {
        console.log('DBG: being clicked --- handleAttendSession');
        helper.attendSession(component);
    },

    handleCancelSessionSelection : function(component, event, helper) {
        console.log('DBG: being clicked --- handleCancelSessionSelection');
        helper.cancelSessionSelection(component);
    }
})