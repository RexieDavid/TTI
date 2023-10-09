({
    handlePayloadChange: function(component, event, helper) {
        let payload = component.get('v.payload');
        helper.buildData(component, payload);
        helper.updatePagination(component, payload);
    },

    handlePagination: function(component, event, helper) {
        let payload = component.get('v.currData');
        helper.buildData(component, payload);
    },

    handleTextChange: function(component, event, helper) {
        let eventObj = event.target;
        let searchText = component.find(eventObj.id).get('v.value');
        helper.filterData(component, searchText.toLowerCase().trim());
    },

    handleSort: function(component, event, helper) {
        let payload = component.get('v.currData');
        let fieldName = event.currentTarget.dataset.fieldname;
        let sortDirection = component.get('v.sortDirection');
        let isReverse = sortDirection !== 'utility:arrowup' ? 1 : -1;
        component.set('v.sortDirection', `utility:${isReverse === 1 ? 'arrowup' : 'arrowdown'}`);
        component.set('v.sortedBy', fieldName);
        if (payload && payload.length > 0) {
            payload.sort((a, b) => a[fieldName] < b[fieldName] ? isReverse : (a[fieldName] > b[fieldName] ? isReverse * -1 : 0));
            helper.buildData(component, payload);
            helper.updatePagination(component, payload);
        }

    },

    toggleShowDetails: function(component, event, helper) {
        const recordId = event.currentTarget.dataset.id;
        const payload = component.get('v.payload');
        let isShowDetails = component.get('v.isShowDetails');
        const recordToShow = payload.find(el => el.Id === recordId);
        component.set('v.recordToShow', recordToShow);
        component.set('v.isShowDetails', !isShowDetails);
    }
})