({
    initializeModal: function(component) {
        component.set('v.modal', {
            visible: false,
            isHeaderVisible: false,
            isContentVisible: false,
            isFooterVisible: false
        });
    },

    hasParticipated: function(component) {
        return new Promise((resolve, reject) => {
            let action = component.get('c.hasParticipated');
            action.setCallback(this, function(response) {
                const state = response.getState();

                if (state === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        })
    },
    
    getSurveyDetails: function(component) {
        let action = component.get('c.getSurveyDetails');
        action.setCallback(this, function(response) {
            const state = response.getState();
            const retVal = response.getReturnValue();

            if (state === 'SUCCESS') {                
                let surveyEntity = JSON.parse(JSON.stringify(retVal));

                surveyEntity.questions.forEach(question => {
                    question.options = question.options
                        .map((a) => [Math.random(),a])
                        .sort((a,b) => a[0]-b[0])
                        .map((a) => a[1]);
                    question.selectedOptions = [];
                })

                component.set('v.surveyEntity', surveyEntity);
            } else {
                reject();
            }
        });
        $A.enqueueAction(action);
    },

    saveSurvey: function(component, questionsIdentifier, questionsAnswer) {
        return new Promise((resolve, reject) => {
            let action = component.get('c.saveSurvey');
            action.setParams({
                surveyIdentifier: '',
                questionsIdentifier: questionsIdentifier, 
                questionsAnswer: questionsAnswer
            });
            action.setCallback(this, function(response) {
                const state = response.getState();

                if (state === 'SUCCESS') {
                    this.destroyComponents(component, 'modalHeader');
                    this.destroyComponents(component, 'modalContent');
                    this.destroyComponents(component, 'modalFooter');

                    component.set('v.hasParticipated', true);

                    resolve();
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },

    destroyComponents: function(component, modalComponent) {
        let components = component.find(modalComponent).get('v.body');
        if (components.length > 0) {
            for (let ctr = 0; ctr < components.length; ctr++) {
                components[ctr].destroy();
            }
        }
    },

    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            variant: type,
            title: title,
            message: message
        });
    },
    
    toggleSpinner: function(component) {
        let spinner = component.find('modalSpinner');
        $A.util.toggleClass(spinner, "slds-hide");
    },

    validateSurvey: function(component) {
        const surveyEntity = component.get('v.surveyEntity');
        return surveyEntity.questions.reduce((a, b) => b.selectedOptions.length < 1, false);
    }
})