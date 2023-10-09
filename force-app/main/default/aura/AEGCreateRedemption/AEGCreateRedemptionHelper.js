({
    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    addHideCSS: function(component) {
        $A.util.addClass(component, 'slds-hide');
    },

    removeHideCSS: function(component) {
        $A.util.removeClass(component, 'slds-hide');
    },

    toggleSpinner: function() {
        var toggleSpinner = $A.get("e.c:ToggleSpinner");
        toggleSpinner.fire();
    },

    navigateTo: function(component, target) {
        var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": target });
        navEvent.fire();
    },

    validateForm: function(component, inputProvince, inputPostalCode, inputStreet, inputCity) {
        self = this;
        var hasError = false;
        var errorMsg;
        var errorCounter = 0;

        if (!inputStreet) {
            errorMsg = 'Enter Address';
            hasError = true;
            errorCounter++;
        }

        if (!inputCity) {
            errorMsg = 'Enter Suburb';
            hasError = true;
            errorCounter++;
        }

        if (!inputProvince || inputProvince === '-- None --') {
            errorMsg = 'Please choose a state.';
            hasError = true;
            errorCounter++;
        }

        if (!inputPostalCode) {
            errorMsg = 'Enter Postcode.';
            hasError = true;
            errorCounter++;
        } else {
            if (isNaN(inputPostalCode)) {
                errorMsg = 'Number only for postcode.';
                hasError = true;
            }
            if (inputPostalCode.length > 4) {
                errorMsg = 'Maximum of 4 digits for postcode.';
                hasError = true;
            }
        }

        if (hasError) {
            if (errorCounter === 4) {
                errorMsg = 'Enter Address';
            }
            component.set('v.errorMsg', errorMsg);
            self.toggleSpinner();
            return false;
        } else {
            return true;
        }
    },

    displayPredictions: function(component, searchString) {
        var selectedCountry;
        var commName = component.get("v.siteSettings");

        if (commName.Lead_Source__c === 'MYAEG') {
            selectedCountry = 'au';
        }
        if (commName.Lead_Source__c === 'MYAEGNZ') {
            selectedCountry = 'nz';
        }

        var action = component.get("c.getAddressAutoComplete");
        action.setParams({
            "input": searchString,
            "countryname": selectedCountry
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                var predictions = options.predictions;
                var addresses = [];

                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        addresses.push(
                            {
                                value: predictions[i].types[0],
                                label: predictions[i].description,
                                PlaceId: predictions[i].place_id,
                            });
                    }
                    component.set("v.predictions", addresses);
                }
            }
        });
        $A.enqueueAction(action);

    },

    displaySelectionDetails: function(component, placeId) {
        var action = component.get("c.getAddressDetails");
        action.setParams({
            "PlaceId": placeId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var option = JSON.parse(response.getReturnValue());
                var address = option.result;
                var key = "address_components";
                var selection = address[key]
                this.insertRecords(component, selection);
            }
        });
        $A.enqueueAction(action);
    },

    insertRecords: function(component, data) {
        var commName = component.get("v.siteSettings");
        var fullstreetname = '';
        for (var prop in data) {
            if (commName.Lead_Source__c === 'MYAEG' && data[prop].types[0] === "locality") {
                component.set("v.suburb", data[prop].long_name);
            }

            if (commName.Lead_Source__c === 'MYAEGNZ' && data[prop].types[0] === "sublocality_level_1") {
                component.set("v.suburb", data[prop].long_name);
            }

            if (data[prop].types[0] === "postal_code") {
                component.set("v.postcode", data[prop].long_name);
            }

            if (data[prop].types[0] === "country") {
                component.set("v.country", data[prop].long_name);
            }

            if (data[prop].types[0] === "administrative_area_level_1") {
                component.set("v.state", data[prop].long_name);
            }

            if (data[prop].types[0] === "street_number") {
                fullstreetname += data[prop].long_name + " ";
            }

            if (data[prop].types[0] === "route") {
                fullstreetname += data[prop].long_name;
            }

        }

        var strSearch = component.get('v.searchString');
        var strCheckStreet = strSearch.substring(0, strSearch.indexOf(fullstreetname));
        if (strCheckStreet) {
            fullstreetname = strCheckStreet + fullstreetname;
        }
        component.set('v.address', fullstreetname);
    },

    openListbox: function(component, searchString) {
        var searchLookup = component.find("searchLookup");

        if (typeof searchString === 'undefined' || searchString.length < 2) {
            $A.util.addClass(searchLookup, 'slds-combobox-lookup');
            $A.util.removeClass(searchLookup, 'slds-is-open');
            return;
        }

        $A.util.addClass(searchLookup, 'slds-is-open');
        $A.util.removeClass(searchLookup, 'slds-combobox-lookup');

    },

    clearComponentConfig: function(component) {
        var searchLookup = component.find("searchLookup");
        var iconPosition = component.find("iconPosition");
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        component.set("v.selectedOption", null);
        component.set("v.searchString", null);
        component.set("v.address", null);
        component.set("v.suburb", null);
        component.set("v.state", null);
        component.set("v.postcode", null);
        $A.util.removeClass(iconPosition, 'slds-input-has-icon_right');
        $A.util.addClass(iconPosition, 'slds-input-has-icon_right');

    },

    loadData: function(component) {
        var getUserDetails = component.get("c.getPersonAccountDetails");
        getUserDetails.setCallback(this, function(response) {
            var data = JSON.parse(response.getReturnValue());
            var countryListString = component.get('v.countryListString');
            component.set('v.countryList', countryListString);
            if (data != null) {
                component.set('v.contactInfo', data);
                component.set('v.state', data.MailingState);
                component.set('v.country', data.MailingCountry);
                component.set('v.postcode', data.MailingPostalCode);
                component.set('v.suburb', data.MailingCity);
                component.set('v.address', data.MailingStreet);
            } else {
                component.set('v.state', '');
                component.set('v.country', '');
                component.set('v.postcode', '');
                component.set('v.suburb', '');
                component.set('v.address', '');
            }
            $A.enqueueAction(getSiteSettingsJS);
        });
        $A.enqueueAction(getUserDetails);

        var getSiteSettingsJS = component.get("c.getSiteSettings");
        getSiteSettingsJS.setCallback(this, function(response) {
            var customSettingValues = response.getReturnValue();
            var leadSource = customSettingValues.communitySettings.Lead_Source__c;
            var countryMap = { 'Australia': 'Australian', 'New Zealand': 'New Zealand' };
            var country = leadSource === 'MYAEG' ? 'Australia' : leadSource === 'MYAEGNZ' ? 'New Zealand' : '';
            component.set('v.shippingAddressHelpCountry', countryMap[country])
            component.set("v.country", country);
            component.set("v.siteSettings", customSettingValues.communitySettings);
            component.set('v.isLoaded', true);
        });
    },

    toggleModal: function(component, modalType) {
        component.set(`v.${modalType}`, !component.get(`v.${modalType}`));
    },

    processPayload: function(component, payload) {
        const { promo } = payload;
        const { redeemableItems, requiredRedeemableItems, custom } = promo;
        const hasManyRedemptions = redeemableItems.length > 1;
        var hasManyRequiredRedemptions = false;

        if(requiredRedeemableItems && requiredRedeemableItems.length > 0 && requiredRedeemableItems[0]){
            hasManyRequiredRedemptions = true;
        }
        
        const result = {
            redeemableItems,
            requiredRedeemableItems,
            redemptionItemId: custom.redemptionItemId,
            purchasedProductId: custom.purchasedProductId,
            redeemedItems: this.getRedeemedItems(redeemableItems),
            purchasedItems: this.getPurchasedItems(payload),
            hasManyRedemptions,
            hasManyRequiredRedemptions
        };

        this.setRedeemItemName(component, result.redeemedItems);
        if(requiredRedeemableItems && requiredRedeemableItems.length > 0 && requiredRedeemableItems[0]){
            this.setRequiredRedeemItemName(component, result.redeemedItems, result.requiredRedeemableItems);
        }
        component.set('v.selectedPromo', result);
        component.set('v.payload', payload);

    },

    getRedeemedItems: function(redeemableItems) {
        const selected = redeemableItems.find(el => el.initialClass.indexOf('redeem-item-opt') !== -1);
        return selected.items;
    },

    getPurchasedItems: function(payload) {
        const { promotions, selectedPromo } = payload;
        const { productId, campaignId } = selectedPromo;
        const promotion = promotions.find(el => el.campaign.Id.indexOf(campaignId) !== -1);
        if (!productId) {
            return promotion.purchasedItems;
        }
        return [ promotion.purchasedItems.find(el => el.productId === productId) ];
    },

    setRedeemItemName: function(component, redeemedItems) {
        const names = this.getProductNames(redeemedItems);
        const confirmationHeader = component.get('v.confirmationHeader')
        component.set('v.confirmationHeaderMsg', confirmationHeader.replace('<redeemedItemName>', names)); 
    },

    setRequiredRedeemItemName: function(component, redeemedItems, requiredRedeemableItems) {
        const names = this.getProductNames(redeemedItems);
        const reqNames = this.getRequiredProductNames(requiredRedeemableItems);
        var confirmationLabel = $A.get("$Label.c.AEG_Redeem_Submit_Redemption_Confirmation_Label");
        var confirmationLabelRedeemedItem = confirmationLabel.replace('<redeemedItemName>', names);
        var confirmationLabelRequiredRedeemedItem = confirmationLabelRedeemedItem.replace('<requiredRedeemedItemName>', reqNames);
        component.set('v.confirmationHeaderMsg', confirmationLabelRequiredRedeemedItem); 
    },

    getProductNames: function(products) {
        return products
            .map(el => el.productName || el.title)
            .join(', ');
    },

    getRequiredProductNames: function(products) {
        return products
            .map(el => el.Product__r.Name)
            .join(', ');
    },

    saveDetailsH: function(component) {
        this.toggleSpinner();
        var inputFirstName = component.find('inputFirstName').get('v.value');
        var inputLastName = component.find('inputLastName').get('v.value');
        var inputMobile = component.find('inputMobile').get('v.value');
        var inputEmail = component.find('inputEmail').get('v.value');
        var inputStreet = component.get('v.address');
        var inputCity = component.get('v.suburb');
        var inputProvince = component.get('v.state');
        var inputPostalCode = component.get('v.postcode');
        var inputCountry = component.get('v.country');
        let isConfirmModalOpen = component.get('v.isShowConfirmModal');

        if (this.validateForm(component, inputProvince, inputPostalCode, inputStreet, inputCity)) {
            this.hideComponent(component.find('alertErrorMsg'));
            var updateContactDetails = component.get('c.updateContactDetails');
            updateContactDetails.setParams({
                'inputFirstName': inputFirstName,
                'inputLastName': inputLastName,
                'inputMobile': inputMobile,
                'inputEmail': inputEmail,
                'inputStreet': inputStreet,
                'inputCity': inputCity,
                'inputCountry': inputCountry,
                'inputProvince': inputProvince,
                'inputPostalCode': inputPostalCode
            });

            updateContactDetails.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    const contact = JSON.parse(response.getReturnValue());
                    component.set('v.contactInfo', contact);
                    this.submitRedemption(component, contact);
                } else {
                    if (isConfirmModalOpen) {
                        this.toggleModal(component, 'isShowConfirmModal');
                    }
                    this.toggleSpinner();
                }

            });
            $A.enqueueAction(updateContactDetails);
        } else {
            this.showComponent(component.find('alertErrorMsg'));
        }
    },

    submitRedemption: function(component, contact) {
        const isConfirmModalOpen = component.get('v.isShowConfirmModal');
        const action = component.get('c.submitRedemption');
        const payload = this.buildSubmitRedemptionPayload(component, contact);
        action.setParams({ "payload": JSON.stringify(payload) });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                window.sessionStorage.clear(); // Clear session storage after submission
                const surveyModal = component.find('surveyModal');
                const hasParticipated = surveyModal.get('v.hasParticipated');

                if (!hasParticipated) {
                    this.showSurveyModal(component);
                } else {
                    this.hideComponent(component.find('createRedemptionDiv'));
                    this.navigateTo(component, 'AEGRedemptionList');
                }
            } else {
                component.set('v.redemptionPopupHeader', $A.get("$Label.c.Generic_Error_Message"));
                $A.util.toggleClass(component.find('limCampaignErrorModal'), 'slds-hide');
            }

            if (isConfirmModalOpen) {
                this.toggleModal(component, 'isShowConfirmModal');
            }
            this.toggleSpinner();
            this.resetCarouselIntervals(component);
        });
        $A.enqueueAction(action);
    },

    buildSubmitRedemptionPayload: function(component, contact) {
        const { selectedPromo, promotions } = component.get('v.payload');
        const { campaignId, redeemableItemId } = selectedPromo;
        const { campaign } = promotions.find(el => el.campaign.Id.indexOf(campaignId) !== -1);
        delete campaign.custom;
        return {
            contact,
            campaign,
            redeemedProductId: redeemableItemId
        }
    },

    resetCarouselIntervals: function(component) {
        const carousels = component.find('purchasedProductCarousel');
        carousels.forEach(el =>{
            el.clearInterval();
        });
    },

    showSurveyModal: function(component) {
        const { redeemedItems, purchasedItems } = component.get('v.selectedPromo');
        const surveyModal = component.find('surveyModal');
        surveyModal.toggleModal();

        let surveyEntity = surveyModal.get('v.surveyEntity');
        surveyEntity.questions[0].label = surveyEntity.questions[0].label
            .replace('<Product.Customer_Facing_Name__c>', this.getProductNames(purchasedItems));
        surveyModal.set('v.surveyEntity', surveyEntity);
        let headerText = $A.get('$Label.c.AG_Redemption_Survey_Header');
        headerText = headerText.replace('<Product.Customer_Facing_Name__c>', this.getProductNames(redeemedItems));
        const headerElements = [
            ...this.getModalCloseBtnElements(component.getReference('c.closeSurvey')),
            ['aura:html', {
                'tag': 'h2',
                body: headerText,
                HTMLAttributes: {
                    class: 'slds-text-heading_medium'
                }
            }],
        ];

        surveyModal.set('v.modal', {
            visible: true,
            isHeaderVisible: true,
            isContentVisible: true,
            isFooterVisible: true
        });
        let modalHeader = surveyModal.find('modalHeader');
        let modalHeaderBody = modalHeader.get('v.body');

        $A.util.addClass(modalHeader, 'div--bg-color-brand');
        $A.createComponents(headerElements, (components) => {
            let closeBtn = components[0];
            let spanIcon = components[1];
            let spanAssistiveText = components[2];
            let closeIcon = components[3];
            let headerText = components[4];

            spanIcon.set('v.body', closeIcon);
            closeBtn.set('v.body', [spanIcon, spanAssistiveText]);

            modalHeaderBody.push(closeBtn);
            modalHeaderBody.push(headerText);

            surveyModal.find('modalHeader').set('v.body', modalHeaderBody);
        });

        let footerElements = [
            ['aura:html', { tag: 'center' }],
            ['lightning:button', {
                variant: 'brand',
                label: 'Ok',
                onclick: component.getReference('c.execSaveSurvey'),
                class: 'slds-align_absolute-center globalProductItemButton'
            }]
        ]

        let modalFooter = surveyModal.find('modalFooter').get('v.body');
        $A.createComponents(footerElements, (components) => {
            let center = components[0];
            let button = components[1];

            center.set('v.body', button);
            modalFooter.push(center);

            surveyModal.find('modalFooter').set('v.body', modalFooter);
        });
    },

    getSurveySuccessCallback: function() {
        return (component) => {
            $A.util.removeClass(component.find('createRedemptionDiv'), 'slds-show');
            $A.util.addClass(component.find('createRedemptionDiv'), 'slds-hide');
            component.navigateToRedemptionList();
        };
    },

    getModalCloseBtnElements: function(onclickCallback) {
        return [
            ['aura:html', {
                tag: 'button',
                HTMLAttributes: {
                    class: 'slds-button slds-button_icon slds-modal__close slds-button_icon-inverse',
                    title: 'Close',
                    onclick: onclickCallback
                }
            }],
            ['aura:html', {
                tag: 'span',
                HTMLAttributes: {
                    class: 'slds-icon_container span__lightning-icon'
                }
            }],
            ['aura:html', {
                tag: 'button',
                body: 'Close',
                HTMLAttributes: {
                    class: 'slds-assistive-text'
                }
            }],
            ['lightning:icon', {
                iconName: 'utility:close',
                alternativeText: 'closed'
            }]
        ];
    },

    setHeaderComponentStyle: function(component) {
        const { hasManyRedemptions } = component.get('v.selectedPromo');
        const columnSize = hasManyRedemptions ? 5 : 6;
        const columnStyle = `slds-medium-size_${columnSize}-of-12 slds-large-size_${columnSize}-of-12`;
        const pcViewHeaderComponents = component.find('pcHeaderGrid');
        pcViewHeaderComponents.forEach(cmp => $A.util.addClass(cmp, columnStyle));
    },

    toggleRedeem: function(component) {
        const redeemModalState = component.get('v.isShowRedeemModal');
        component.set('v.isShowRedeemModal', !redeemModalState)
    },

    resetSelectedPromo: function(component) {
        const selectedPromo = component.get('v.selectedPromo');
        selectedPromo.purchasedItems = [];
        selectedPromo.redeemedItems = [];
        component.set('v.selectedPromo', selectedPromo);
    }

})