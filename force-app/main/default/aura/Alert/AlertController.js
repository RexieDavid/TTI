({
	closeAlert : function(component, event, helper) {
		var alertCloseEvent = $A.get("e.c:AlertCloseEvent");
		alertCloseEvent.fire();
	}
})