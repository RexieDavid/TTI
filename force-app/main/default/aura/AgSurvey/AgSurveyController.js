({
    doInit: function(component, event, helper) {        
        helper.hasParticipated(component)
        .then(hasParticipated => {
            component.set('v.hasParticipated', hasParticipated);

            if (!hasParticipated) {
                helper.getSurveyDetails(component);
                helper.initializeModal(component);
            }
        })
        .catch(() => {});
    },

    toggleModal: function(component, event, helper) {
        component.set('v.modal.visible', !component.get('v.modal.visible'));
    },

    execSaveSurvey: function(component, event, helper) {
        var params = event.getParam('arguments');

        const hasUnansweredQuestion = helper.validateSurvey(component);

        if (hasUnansweredQuestion) {
            helper.showToast(component, 'At least one option must be selected', '', 'warning');
        } else {
            helper.toggleSpinner(component);
            const surveyEntity = component.get('v.surveyEntity');
            let questionsIdentifier = [];
            let questionsAnswer = [];
    
            surveyEntity.questions.forEach(question => {
                questionsIdentifier.push('');
                questionsAnswer.push(question.selectedOptions.reduce((a, b) => a += `${b};`, ''));
            });
    
            helper.saveSurvey(component, questionsIdentifier, questionsAnswer)
            .then(() => {
                helper.toggleSpinner(component);
                helper.initializeModal(component);
                if(params.successCallback) params.successCallback(params.parentComponent);
            })
            .catch(() => {
                if(params.errorCallback) params.errorCallback();
            });
        }
        
    },

    closeSurvey: function(component, event, helper) {
        let params = event.getParam('arguments');
        helper.toggleSpinner(component);

        helper.saveSurvey(component, [], [])
        .then(() => {
            helper.toggleSpinner(component);
            helper.initializeModal(component);
            if(params.successCallback) params.successCallback(params.parentComponent);
        })
        .catch(() => {
            if(params.errorCallback) params.errorCallback();
        });
    },
})