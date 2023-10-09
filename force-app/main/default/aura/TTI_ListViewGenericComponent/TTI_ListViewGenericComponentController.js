({  
    renderPage: function(component, event, helper) {
        const records = component.get('v.listOfRecords');
        const recordsCount = component.get('v.maxRecords');
        const pageNumber = component.get('v.pageNumber');
        const pageRecords = records.slice((pageNumber - 1) * recordsCount, pageNumber * recordsCount);

        component.set('v.recordsToDisplay', pageRecords);
    },

    linkClicked: function(component, event, helper) {
        const value = event.currentTarget.title;
        let compEvent = component.getEvent('getSelectedListViewValue');

        compEvent.setParams({'selectedValue': value});
        compEvent.fire();
    },

    handleData: function(component, event, helper) {
        let listOfLabel = component.get('v.listOfLabel');
        listOfLabel = listOfLabel.includes(',') ? listOfLabel.split(',') : listOfLabel;
        
        let lstAPI = component.get('v.listOfAPI');
        lstAPI = lstAPI.includes(',') ? lstAPI.split(',') : lstAPI;

        let fieldType = component.get('v.fieldType');
        fieldType = fieldType.includes(',') ? fieldType.split(',') : fieldType;
        
        let data = component.get('v.data');
        let listOfRecords = component.get('v.listOfRecords');

        listOfRecords = [];
        for (let i = 0; i < data.length; i++) {
            let temp = data[i];
            let tempList = [];

            for (let j = 0; j < lstAPI.length; j++) {
                let record = {};

                if (lstAPI[j].search('__r') === -1) {
                    record.value = temp[lstAPI[j]];
                    record.type = fieldType[j];
                    record.label = listOfLabel[j];
                    tempList.push(record);
                } else {
                    let x = lstAPI[j].split('.');
                    let y = temp[x[0]];
                    if (y) {
                        record.value = y[x[1]];
                        record.type = fieldType[j];
                        record.label = listOfLabel[j];
                        tempList.push(record);
                    } else {
                        record.value = '';
                        record.type = fieldType[j];
                        record.label = listOfLabel[j];
                        tempList.push(record);
                    }
                }
            }

            listOfRecords[i] = {};
            listOfRecords[i].value = tempList;
        }
        
        const recordsCount = component.get('v.maxRecords');
        const maxPage = Math.floor((listOfRecords.length + (recordsCount - 1)) / recordsCount);
        const pageRecords = listOfRecords.slice(0, recordsCount);

        component.set('v.columns', listOfLabel);
        component.set('v.pageNumber', 1);
        component.set('v.maxPage', maxPage);
        component.set('v.listOfRecords', listOfRecords);
        component.set('v.recordsToDisplay', pageRecords);
    }
})