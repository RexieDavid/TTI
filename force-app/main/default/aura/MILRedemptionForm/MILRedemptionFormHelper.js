({
    initData: function(component) {
        this.setCountryLongName(component);
        Promise.all([
            this.getPersonAccountDetails(component),
            this.removeContentDocuments(component)
        ])
        .then(responses => {
            this.setPersonAccountDetails(component, responses[0]);
            component.set('v.isCmpInitiated', true);

            if (component.get('v.isPayloadReady')) {
                this.initPayload(component);
            }
        })
        .catch(err => {
            this.showToast(component, '', err, 'error');
        })
    },

    setCountryLongName: function(component) {
        const countryCode = component.get('v.country');
        const validCountryCodes = ['AU', 'NZ'];
        let countryLongName;
        if (countryCode && validCountryCodes.includes(countryCode)) {
            countryLongName = countryCode === 'AU' ? 'Australia' : 'New Zealand';
            component.set('v.countryLongName', countryLongName);
        } else {
            this.showToast(component, '', $A.get("$Label.c.Supported_Country_Code_Error_Message"), 'error');
        }
    },

    getPersonAccountDetails: function(component) {
        return this.runPromiseApexAction(
            component,
            'getPersonAccountDetails',
            null
        );
    },

    setPersonAccountDetails: function(component, response) {
        if (response) {
            component.set('v.contactInfo', JSON.parse(response));
        }
    },

    removeContentDocuments: function(component) {
        return this.runPromiseApexAction(
            component,
            'removeContentDocuments', 
            { }
        );
    },

    clearAddress: function(component) {
        const addressFields = ['MailingStreet', 'MailingCity', 'MailingState', 'MailingPostalCode'];
        for (const fields of addressFields) {
            component.set(`v.contactInfo.${fields}`, null);
        }
    },

    initPayload: function(component) {

        let record = JSON.parse(component.get('v.selectedPromoJSON'))[0];
        if (record) {
            
            component.set('v.isMultipleRedemption', true);
            component.set('v.selectedPromo', record);
            
            this.getPurchasedAndRedeemedProducts(component)
            .then(redemptionInfoJSON => {
                const redemptionInfo = JSON.parse(redemptionInfoJSON);
                const purchasedProduct = redemptionInfo.purchasedProducts[0].Product__r || {};
                const purchasedProductName = purchasedProduct.Customer_Facing_Name__c || purchasedProduct.Name;
                const redeemOptions = redemptionInfo.redeemableProducts.map((item, index) => { 
                    return {
                        id: item.Id, 
                        label: item.Product__r.Customer_Facing_Name__c || item.Product__r.Name,
                        selected: !index
                    };
                });

                const reqProds = redemptionInfo.redeemableRequiredProducts.map((item, index) => { 
                    return {
                        id: item.Id, 
                        label: item.Product__r.Customer_Facing_Name__c || item.Product__r.Name,
                        selected: !index
                    };
                });

                var hasRequiredRedeemedProduct = false;

                if(reqProds && reqProds.length > 0 && reqProds[0]){
                    console.log('*** enter 1st checking ');
                    hasRequiredRedeemedProduct = true;
                }

                component.set('v.selectedItem', redeemOptions.find(el => el.selected));
                component.set('v.purchasedProducts', redemptionInfo.purchasedProducts);
                component.set('v.redeemableProducts', redemptionInfo.redeemableProducts);
                component.set('v.requiredProductsRedemption', reqProds);
                component.set('v.hasRequiredRedeemedProduct', hasRequiredRedeemedProduct);
                component.set('v.redeemOptions', redeemOptions);
                component.set('v.purchasedProductName', purchasedProductName);

            })
            .catch(err => {
                this.showToast(component, '', err, 'error');
            })
        }
    },

    getPurchasedAndRedeemedProducts: function(component) {
        return this.runPromiseApexAction(
            component,
            'getPurchasedAndRedeemedProducts', 
            this.getHandleSubmitParams(component)
        );
    },

    validate: function(component) {
        return new Promise($A.getCallback((resolve, reject) => { 
            component.set('v.isAddressNotFound', true); // Set to true to check address fields
            const requiredFields = this.validateFields(component, 'requiredField');
            const addressFields = this.validateFields(component, 'address');
            const termsAndCondition = this.validateTermsAndCondition(component);
            if (addressFields.isValid && requiredFields.isValid && termsAndCondition.isValid) {
                resolve();
            } else {
                reject( requiredFields.errorField || addressFields.errorField || termsAndCondition.errorField );
            }
        }));
    },

    validateTermsAndCondition: function(component) {
        const termsAndCondition = component.find('termsAndCondition');
        const isValid = component.get("v.isTNCchecked");
        if (isValid) {
            $A.util.removeClass(termsAndCondition, 'slds-has-error');
        } else {
            $A.util.addClass(termsAndCondition, 'slds-has-error');
        }
        return { isValid,  errorField: isValid ? null : component.find('tncCheckbox') };
    },

    validateFields: function(component, identifier) {
        let errorField;
        const isValid = component.find(identifier).reduce(function(validSoFar, field) {
            field.reportValidity();
            const isValid = field.checkValidity();
            if (!errorField && !isValid) {
                errorField = field;
            }
            return validSoFar && isValid;
        }, true);
        return { isValid, errorField };
    },

    commit: function(component) {
        component.set("v.isProcessing", true);
        const eventHandlers = this.getEventHandlers();
        this.handleSubmit(component)
        .then(() => {
            this.submitSuccess(component, eventHandlers);
        })
        .catch(err => {
            this.toggleSpinner(eventHandlers.spinner);
            this.showToast(component, '', err, 'error');
        });
    },

    handleSubmit: function(component) {
        return this.runPromiseApexAction(
            component,
            'submitRedemption', 
            this.getHandleSubmitParams(component)
        );
    },

    getHandleSubmitParams: function(component) {
        const hasFile = component.get('v.hasFile');
        const contact = JSON.parse(JSON.stringify(component.get('v.contactInfo')));
        const purchasedProducts = component.get('v.purchasedProducts');
        const redeemableProducts = component.get('v.redeemableProducts');
        const selectedItem = component.get('v.selectedItem') || {};
        delete contact.AccountId; // delete attribute to update contact
        const payload = {
            storeName: component.get('v.storeName'),
            storeSuburb: component.get('v.storeSuburb'),
            contact,
            account: contact.Account,
            redemptionCampaign:  component.get('v.selectedPromo'),
            selectedItem: selectedItem.id || ''
        }

        if (hasFile) {
            const file = component.get("v.contentDocument");
            payload.fileId = file.documentId;
        }

        if (purchasedProducts) {
            payload.purchasedProducts = purchasedProducts;
        }   

        if (redeemableProducts) {
            payload.redeemableProducts = redeemableProducts;
        }   

        return { payload: JSON.stringify(payload) };
    },

    getEventHandlers: function() {
        /**
         * Application events can't be fetch in
         * Promise chain result. For solution
         * fetch it before executing the promise chain
         */
        return {
            spinner: $A.get("e.c:MILToggleSpinner"),
            navigate: $A.get("e.c:MILNavigateEvent")
        }
    },

    submitSuccess: function(component, eventHandlers) {
        this.hideComponent(component.find('createRedemptionDiv'));
        this.navigateTo(component, 'MILConfirmRedemption', eventHandlers.navigate);
        this.toggleSpinner(eventHandlers.spinner);
    },

    navigateTo: function(component, target, navEvent) {
        navEvent.setParams({
            "Target": target,
            "RecordJSON": component.get("v.contactInfo.Email")
        });
        navEvent.fire();
    },

    toggleSpinner: function(spinnerEvent) {
        spinnerEvent.fire();
    },

    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            "variant": type,
            "title": title,
            "message": message
        });
    },

    scrollToTop: function(component) {
        window.scrollTo({
            top: component.find('createRedemptionDiv').getElement().offsetTop,
            behavior: 'smooth'
        });
    },

    processFileUploaded: function(component, file) {
        const eventHandlers = this.getEventHandlers();
        component.set('v.contentDocumentId', file.documentId);
        component.set('v.contentDocument', file);
        this.changeContentDocuments(component, file.documentId)
        .then(response => {
            this.setFileDetails(component, file, eventHandlers.spinner);
            component.set('v.contentDocument', file);
        });
    },

    changeContentDocuments: function(component, recordId) {
        return this.runPromiseApexAction(
            component,
            'changeContentDocuments', 
            { recordId }
        );
    },

    setFileDetails: function(component, file, spinner) {
        component.set('v.hasFile', true);
        component.set('v.contentDocument', file);
        this.toggleSpinner(spinner);
    },

    runPromiseApexAction: function(component, method, params) {
        return new Promise($A.getCallback((resolve, reject) => { 
            const action = component.get(`c.${method}`);
            if (params) {
                action.setParams(params);
            }
            action.setCallback(this, response => {
                if (response.getState() === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else {
                    reject($A.get("$Label.c.Generic_Error_Message"));
                }
            });
            $A.enqueueAction(action);
        }));
    },
})