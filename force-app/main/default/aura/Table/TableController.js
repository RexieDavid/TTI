({
	initializeTable : function(component, event, helper) {
        debugger;
		var title = event.getParam('Title');
		if(title == component.get('v.title')) {
			var fieldSetApiName = event.getParam('FieldSetApiName');
			var objectApiName = event.getParam('ObjectApiName');
			var allRecord = JSON.parse(event.getParam('AllRecord'));
			var tableName = event.getParam('TableId');
            debugger;

			helper.getTableHeaders(component, fieldSetApiName, objectApiName, allRecord);

			component.set('v.tableName', tableName);
            component.set('v.allRecordJSON', event.getParam('AllRecord'));

			component.set('v.doneInitialized', true);
		}			
	},

    renderPage: function(component, event, helper) {
        helper.renderPage(component, component.get("v.recordList"));
    },

    searchFor: function(component, event, helper) {
        helper.sortBySearch(component, 
                            component.get("v.sortField"), 
                            helper.searchFor(component, component.get("v.searchTxt"), JSON.parse(component.get("v.allRecordJSON"))));
    },

    sortColumn: function(component, event, helper) {
        var colID = event.target.id,
            colID = colID.slice(colID.indexOf("-") + 1, colID.length);

        helper.sortBy(component, colID, component.get("v.recordList"));
    }
})