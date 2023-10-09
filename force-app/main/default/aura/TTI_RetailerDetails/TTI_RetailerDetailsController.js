({
	requiredRetailerEmailAddress : function(component, event, helper) {
        var serviceRequestCase = component.get("v.Service_Request_Case");
        var validateRetailerEmail = helper.validateRetailerEmailAddress(component,serviceRequestCase);
		
	},
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    quoteToRetailerClicked:function(component){
        var Service_Request_Case=component.get("v.Service_Request_Case");
        Service_Request_Case.TTI_Quote_to_Customer__c=!(Service_Request_Case.TTI_Quote_to_Retailer__c);
        component.set("v.Service_Request_Case",Service_Request_Case);
    }
})