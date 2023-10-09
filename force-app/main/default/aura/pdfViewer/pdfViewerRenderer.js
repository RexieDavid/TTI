({
	// Your renderer method overrides go here
	afterRender: function(component, helper) {
	    this.superAfterRender();

	    component.getConcreteComponent().getElements()[0].parentElement.style.height = '100%';
	}
})