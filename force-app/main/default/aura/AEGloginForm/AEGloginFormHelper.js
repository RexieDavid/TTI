({

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },
    handleLogin: function(component) {
        component.set('v.showError', false);
        const username = component.get('v.username');
        const password = component.get('v.password');
        const startUrl = decodeURIComponent(component.get('v.startUrl'));
        const userLoginParams = { username, password, startUrl }
        const isValid = this.validate(component, userLoginParams);
        if (isValid) {
            const action = component.get('c.login');
            action.setParams(userLoginParams);
            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    const result = response.getReturnValue();
                    if (result) {
                        this.showErrorMessage(component, result);
                    }
                } else {
                    this.showErrorMessage(component, $A.get("$Label.c.Generic_Error_Message"));
                }
            });
            $A.enqueueAction(action);
        }
    },

    validate: function(component, userLoginParams) {
        const requiredFields = component.find('requiredField');
        let isValid = requiredFields.reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (isValid) {
            isValid = !this.validateFields(component, userLoginParams);
        }

        return isValid;
    },

    validateFields: function(component, userLoginParams) {
        let errMessage;
        if (!userLoginParams.username && !userLoginParams.password) {
            errMessage = 'Please enter Email and Password. If username and password were pre-filled, please type them in and try logging in again.';
        } else if (userLoginParams.username && !userLoginParams.password) {
            errMessage = 'Enter a value in the Password field.';
        } else if (!userLoginParams.username && userLoginParams.password) {
            errMessage = 'Enter a value in the Email field.';
        } else {
            errMessage = '';
        }

        if (errMessage) {
            this.showErrorMessage(component, errMessage);
        }

        return !!errMessage;
    },

    showErrorMessage: function(component, errorMessage) {
        component.set('v.errorMessage', errorMessage);
        component.set('v.showError', true);
    },

    getIsUsernamePasswordEnabled: function(component) {
        let action = component.get('c.getIsUsernamePasswordEnabled');
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getIsSelfRegistrationEnabled: function(component) {
        let action = component.get('c.getIsSelfRegistrationEnabled');
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunityForgotPasswordUrl: function(component) {
        let action = component.get('c.getForgotPasswordUrl');
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.forgotPasswordUrl', rtnValue);
            }

        });
        $A.enqueueAction(action);
    },

    getCommunitySelfRegisterUrl: function(component) {
        let action = component.get('c.getSelfRegistrationUrl');
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.selfRegisterUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})