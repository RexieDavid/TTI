({
    searchFromList: function(component) {
        var searchString = component.get("v.keyword");
        var objects = component.get("v.picklistValues");

        //store found results
        var foundResults = [];
        for (var i = 0; i < objects.length; i++) {
            //Object has value & label
            var allPickListLabel = objects[i].label;
            allPickListLabel = allPickListLabel.toLowerCase();
            searchString = searchString.toLowerCase();

            //can use indexOf or search
            //-1 as position is result if not found
            var found = allPickListLabel.indexOf(searchString);
                if (found > -1) {                
                    foundResults.push(objects[i]);
                }
        }

        if (foundResults.length > 0) {
            component.set("v.listOfSearchRecords", foundResults);
            component.set("v.showErrorMsg", "");
        } else {
            component.set("v.showErrorMsg", "No records found!");             
            component.set("v.listOfSearchRecords", null);
            var eMsg = component.get("v.showErrorMsg"); 
        }
    }
    
})