({
	claimTypeChanged : function(component,claimTypeBox,Service_Request_Case) {
		var claimType=claimTypeBox.get("v.value");
        if(claimType=='Warranty' && !Service_Request_Case.Goodwill__c)
        {
            claimTypeBox.set("v.errors", [{message:"Goodwill Non-Warranty claims cannot be set to Warranty claims"}]);
        }
	}
})