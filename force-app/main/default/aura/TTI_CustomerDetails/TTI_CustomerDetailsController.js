({
	myAction : function(component, event, helper) {
		
	},
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    quoteToCustomerClicked:function(component){
        var Service_Request_Case=component.get("v.Service_Request_Case");
        Service_Request_Case.TTI_Quote_to_Retailer__c=!(Service_Request_Case.TTI_Quote_to_Customer__c);
        component.set("v.Service_Request_Case",Service_Request_Case);
    }
})