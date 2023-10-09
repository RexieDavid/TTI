({
	searchHandler : function(component, event) {
		try {
            var SelectedItemName = component.get("v.SelectedItemName");
            if(SelectedItemName != null && SelectedItemName != '' ) {
                if (SelectedItemName.length < 3)
                    return;

                component.set("v.SelectedItemObject", null);
                component.set("v.listObj", null);
                var compEvent = component.getEvent("ValueChangeOfSearch");
                compEvent.setParams({
                    "newValue": component.get("v.SelectedItemName"),
                    "SobjectLabel": component.get("v.SobjectLabel"),
                    "objectIndexInList": component.get("v.objectIndexInList"),
                    "selectedObjectApiName": component.get("v.SobjectName")
                });
                compEvent.fire();

                var dynamicValueObject = component.get("v.dynamicValueObject");
		        var dynamicValueObject2 = component.get("v.dynamicValueObject2");
		        var whereQueryString = component.get("v.whereQueryString");

		        if (dynamicValueObject != undefined) {
		            whereQueryString = whereQueryString.replace("dynamicValueObject", "'" + dynamicValueObject + "'");
		        }
		        if (dynamicValueObject2 != undefined) {
		            whereQueryString = whereQueryString.replace("dynamicValueObject2", "'" + dynamicValueObject2 + "'");
		        }

                // Francis Nasalita - clean search term before issuing a search request
                // This will ensure that search terms like “Astro,” “astro*” or “Astro ” (with a trailing space) all hit the same cached response.
                SelectedItemName = SelectedItemName.trim().replace(/\*/g).toLowerCase();

                $A.util.removeClass(component.find("searchinprogressbox"), 'slds-hide');
                component.set("v.listObj", null);
                var searchAction = component.get("c.getListOfObjects");
                searchAction.setParams({
                    "searchString": SelectedItemName,
                    "whereQuery": whereQueryString,
                    "objName": component.get("v.SobjectName"),
                    "ignoreDefaultNameSearch": component.get("v.ignoreDefaultNameSearch"),
                    "ParentFieldsToQuery": component.get("v.ParentFieldsToQuery")
                });

                searchAction.setCallback(this, function(response) {
                    var result = response.getReturnValue();
                    component.set("v.hasSelected", false);

                    $A.util.addClass(component.find("searchinprogressbox"), 'slds-hide');
                    if (response.getState() == 'SUCCESS' && !($A.util.isEmpty(response.getReturnValue()))) {
                        component.set("v.listObj", response.getReturnValue());
                        $A.util.removeClass(component.find("lookuplist"), 'slds-hide');
                    }
                    
                    if(response.getReturnValue() != null) {
                        component.set("v.hasResult", true);
                    } else {
                        component.set("v.hasResult", false);
                    }
                    
                });

                if (SelectedItemName == undefined || $A.util.isEmpty(SelectedItemName)) {
                    $A.util.addClass(component.find("lookuplist"), 'slds-hide');
                } else {
                    // Francis Nasalita - Added setStorable for client-side cache
                    searchAction.setStorable();

                    $A.enqueueAction(searchAction);
                }
                //shows the next button in TTI_AssetDetails.cmp when serial number field is populated
                if(component.get("v.SobjectName") == 'Asset'){
                   var disableNextBtnEvent = component.getEvent("disableNxtBtnEvt");
                    disableNextBtnEvent.setParams({
                        "isDisabled": false
                    });
                    disableNextBtnEvent.fire(); 
                }
            }
        } catch (err) {
            console.log('Error: ', err);
        }
	}
})