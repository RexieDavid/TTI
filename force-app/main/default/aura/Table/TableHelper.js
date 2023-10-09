({
	populateTableList : function(component, records, fields) {
        var allRecords = [];
        
        for(var i = 0; i < records.length; i ++) {
        	var record = records[i];
        	var newRecord = new Object();

        	for(var j = 0; j < fields.length; j++) {
        		var field = fields[j];
        		if(field.fieldType == 'REFERENCE') {
		            var temp = field.apiName.replace('__c', '__r');
		            if(record.hasOwnProperty(temp) && typeof record[temp] === 'object') {
		            	newRecord[temp] = {'Name' : record[temp]['Name']};
		            }
		        } else if(field.fieldType == 'ID') {
		        	newRecord['Name'] = record['Name'];
		        } else {
		        	newRecord[field.apiName] = record[field.apiName];
		        }
        	}
        	allRecords.push(newRecord);
        }

        if(records.length != 0) {
            component.set('v.haveRecords',true);
        }

        
        component.set("v.recordList", records);
        component.set("v.allRecord", allRecords);
        component.set("v.maxPage", Math.floor((records.length+9)/10));
        this.sortBy(component, fields[Object.keys(fields)[0]].apiName, records);     
	},

	/*  Sorting and Pagination Methods  */
    sortBy: function(component, field, records) {        
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField");
        
        sortAsc = sortField != field || !sortAsc;

        records.sort(function(a,b){
            var x,y;

            if(field.includes(".")) {
                var field0 = field.split(".")[0],
                    field1 = field.split(".")[1];

                x = ($A.util.isUndefinedOrNull(a[field0])) ? '' : typeof a[field0][field1] === String ? (a[field0][field1]).toLowerCase() : a[field0][field1],
                y = ($A.util.isUndefinedOrNull(b[field0])) ? '' : typeof b[field0][field1] === String ? (b[field0][field1]).toLowerCase() : b[field0][field1];
                
            } else {
                x = ($A.util.isUndefinedOrNull(a[field])) ? '' : typeof a[field] === String ? a[field].toLowerCase() : a[field],
                y = ($A.util.isUndefinedOrNull(b[field])) ? '' : typeof b[field] === String ? b[field].toLowerCase() : b[field];
            }

            if(sortAsc) {
                return x<y ? -1 : x>y ? 1 : 0;
            } else {
                return x>y ? -1 : x<y ? 1 : 0;
            }            
        });

        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.recordList", records);

        this.renderPage(component, records);
    },

    renderPage: function(component, records) {
        var pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        component.set("v.currentList", pageRecords);
    },

    sortBySearch: function(component, field, records) {   

        records.sort(function(a,b){
            var x,y;

            if(field.includes(".")) {
                var field0 = field.split(".")[0],
                    field1 = field.split(".")[1];

                x = ($A.util.isUndefinedOrNull(a[field0])) ? '' : typeof a[field0][field1] === String ? (a[field0][field1]).toLowerCase() : a[field0][field1],
                y = ($A.util.isUndefinedOrNull(b[field0])) ? '' : typeof b[field0][field1] === String ? (b[field0][field1]).toLowerCase() : b[field0][field1];
                
            } else {
                x = ($A.util.isUndefinedOrNull(a[field])) ? '' : typeof a[field] === String ? a[field].toLowerCase() : a[field],
                y = ($A.util.isUndefinedOrNull(b[field])) ? '' : typeof b[field] === String ? b[field].toLowerCase() : b[field];
            }          

            return x<y ? -1 : x>y ? 1 : 0;           
        });
        component.set("v.sortAsc", true);
        component.set("v.sortField", field);

        this.renderPageBySearch(component, records);
    },

    renderPageBySearch: function(component, records) {
        var pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);

        component.set("v.maxPage", Math.floor((records.length+9)/10));
        component.set("v.currentList", pageRecords);
        component.set("v.recordList", records);
    },

    trimString: function(s) {
        var l=0, r=s.length -1;
        while(l < s.length && s[l] == ' ') l++;
        while(r > l && s[r] == ' ') r-=1;
        return s.substring(l, r+1);
    },

    compareObjects: function(o1, o2) {
        var k = '';
        for(k in o1) if(o1[k] != o2[k]) return false;
        for(k in o2) if(o1[k] != o2[k]) return false;
        return true;
    },

    itemExists: function(haystack, needle) {
        for(var i=0; i<haystack.length; i++) if(this.compareObjects(haystack[i], needle)) return true;
        return false;
    },

    searchFor: function(component, toSearch, objects) {
        var results = [];
        var blacklistFields = [];
        toSearch = this.trimString(toSearch).toLowerCase(); // trim it

        for(var i=0; i<objects.length; i++) {
            for(var key in objects[i]) {
                if(key == 'attributes') {
                    continue;
                }

                if(this.isObject(objects[i][key])) {
                    var isExist = false;
                    for(var key2 in objects[i][key]) {
                        if(key2 == 'attributes') {
                            continue;
                        }

                        if(blacklistFields.indexOf(key2) == -1) {
                            if(objects[i][key][key2].toLowerCase().indexOf(toSearch)!=-1) {
                                if(!this.itemExists(results, objects[i])) {
                                    results.push(objects[i]);
                                    isExist = true;
                                    break;
                                }
                            }
                        }                            
                    }
                    if(isExist) break;
                } else {
                    if(blacklistFields.indexOf(key) == -1) {
                        if(objects[i][key].toLowerCase().indexOf(toSearch)!=-1) {
                            if(!this.itemExists(results, objects[i])) {
                                results.push(objects[i]);
                                break;
                            }
                        }
                    }                        
                }                    
            }
        }
        debugger;

        return results;
    },

    isObject: function(val) {
        if (val === null) { return false;}
        return ( (typeof val === 'function') || (typeof val === 'object') );
    },

	getTableHeaders : function(component, fieldSetApiName, objectApiName, records) {
		var getFieldSet = component.get('c.getFieldSet');
		getFieldSet.setParams({
			fieldSetApiName: fieldSetApiName,
			objectName: objectApiName
		});

		getFieldSet.setCallback(this, function(response) {
			var result = JSON.parse(response.getReturnValue());
			component.set('v.fields', result);

			this.populateTableList(component, records, result);
		});

		$A.enqueueAction(getFieldSet);
	}
})