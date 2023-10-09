({
	hideComponent : function(component) {
		$A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
	},

	showComponent : function(component) {
		$A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
	}
})