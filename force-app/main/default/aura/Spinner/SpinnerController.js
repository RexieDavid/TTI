({
	ToggleSpinnerJS : function(component, event, helper) {
		if(component.get('v.isVisible') == true) {
			helper.hideComponent(component.find('divSpinner'));
			component.set('v.isVisible', false);
		} else {
			helper.showComponent(component.find('divSpinner'));
			component.set('v.isVisible', true);
		}
	}
})