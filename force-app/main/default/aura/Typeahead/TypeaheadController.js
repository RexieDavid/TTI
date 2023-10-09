({
    handleEvent : function(component, event) {
        var val = event.getParam("valueByEvent");
        component.set("v.selectedRecord", val); 
 
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-close');
        $A.util.removeClass(forOpen, 'slds-is-open'); 
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show'); 
    },
    
    keyPressController : function(component, event, helper) {
        var searchString = component.get("v.keyword");

        if (searchString.length > 0) {  
            // Method to search on passed picklist value from Parent Component
            helper.searchFromList(component);            

            // Do the css
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        } else {            
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-close');
            $A.util.removeClass(forOpen, 'slds-is-open');   
        }        
    },
    
    onClickProfessionField : function(component, event, helper) {

        var arr = component.get("v.picklistValues");
        component.set("v.listOfSearchRecords", arr);

        var forOpen = component.find("searchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        var lookUpTarget = component.find("lookupField");        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, ' slds-hide');
    },
    
    handleBlur : function(component) {  
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-close');
        $A.util.removeClass(forOpen, 'slds-is-open');        
    },
    
    clear : function(component, event, heplper) {
        var compEvent = component.getEvent("selectedValEvent"); 
        compEvent.setParams({"valueByEvent" : null });   
        compEvent.fire(); 
        
        var searchResult = component.find("searchRes");
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        var pill = component.find("pill");
        
        $A.util.addClass(searchResult, 'slds-show');
        $A.util.removeClass(searchResult, ' slds-hide');
        
        $A.util.removeClass(pillTarget, 'slds-show');
        $A.util.addClass(pillTarget, ' slds-hide');
        
        $A.util.removeClass(pill, 'slds-show');
        $A.util.addClass(pill, ' slds-hide');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, ' slds-hide');

        component.set("v.keyword", null);
        component.set("v.selectedRecord", null);
        component.set("v.listOfSearchRecords", null);
    },

    onPicklistValuesChange : function(component, event, heplper) {
        // remove --select--
        var allpickListValues = component.get("v.picklistValues");
        var index = allpickListValues.indexOf[0];
        allpickListValues.splice(index, 1);

        // set picklist without the --select--
        component.set("v.listOfSearchRecords", allpickListValues); 
        
    }
})