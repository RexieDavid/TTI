({
    buildData: function(component, payload) {
        let tableData = [];
        let columns = component.get('v.columns');
        let currPageNumber = component.get('v.currPage');
        let arrIndex = currPageNumber === 1 ? 0 : (currPageNumber - 1) * 10;
        component.set('v.currData', payload);
        payload = payload.slice(arrIndex, currPageNumber * 10);
        payload.forEach(value => {
            let data = [];
            columns.forEach(col => {
                data.push({
                    label: col.label,
                    type: col.fieldName,
                    value: value[col.fieldName === 'Id' ? 'Name' : col.fieldName],
                    id: value.Id
                });
            });
            tableData.push(data);
        });

        component.set('v.tableData', tableData);
    },

    filterData: function(component, searchText) {
        let payload = component.get('v.payload');
        let columns = component.get('v.columns');
        payload = payload.filter(value => {
            let isFound = false;
            columns.forEach(colData => {
                let property = colData.fieldName === 'Id' ? 'Name' : colData.fieldName;
                if (!isFound
                        && value[property]
                        && value[property].toLowerCase().indexOf(searchText) !== -1) {
                    isFound = true;
                }
            })
            return isFound;
        });
        this.buildData(component, payload);
        this.updatePagination(component, payload);
        component.set('v.currPage', 1);
    },

    updatePagination: function(component, payload) {
        let maxPageNumber = Math.ceil(payload.length / 10);
        component.set('v.pageNumbers', maxPageNumber);
    },
})