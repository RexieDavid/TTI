({
	hideComponent : function(component) {
		$A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
	},

	showComponent : function(component) {
		$A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
	},

	navigateTo : function(component, target) {
		var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": target});
        navEvent.fire();
	}
})