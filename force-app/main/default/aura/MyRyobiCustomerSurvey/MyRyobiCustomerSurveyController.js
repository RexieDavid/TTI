({
	initialize : function(component, event, helpler) {
		helpler.checkIfCustomerHasFinishedSurvey(component, event, helpler);
		helpler.getCurrentUser(component, event, helpler);
	},
    submitSurvey : function(component, event, helpler) {
		helpler.handleSubmitSurvey(component, event, helpler);
	},
	dismissSurvey : function(component, event, helpler) {
		helpler.handleDismissSurvey(component, event, helpler);
	},
    selectQ1Answer : function(component, event, helpler) {
		helpler.handleSelectQ1Answer(component, event, helpler);
	},
    selectQ2Answer : function(component, event, helpler) {
		helpler.handleSelectQ2Answer(component, event, helpler);
	}
})