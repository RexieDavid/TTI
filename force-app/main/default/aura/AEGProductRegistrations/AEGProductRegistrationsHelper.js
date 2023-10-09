({
    initializeModal: function(component) {
        component.set('v.modal', {
            visible: false,
            isHeaderVisible: false,
            isContentVisible: false,
            isFooterVisible: false
        });
    },

    showSurveyModal: function(component) {
        const assetName = component.get("v.asset.Name");
        const surveyModal = component.find('surveyModal');
        surveyModal.toggleModal();

        let surveyEntity = surveyModal.get('v.surveyEntity');
        surveyEntity.questions[0].label = surveyEntity.questions[0].label
            .replace('<Product.Customer_Facing_Name__c>', assetName);
        surveyModal.set('v.surveyEntity', surveyEntity);

        surveyModal.set('v.modal', {
            visible: true,
            isHeaderVisible: true,
            isContentVisible: true,
            isFooterVisible: true
        });
        
        const isQualifiedPromo = component.get('v.isQualifiedPromo');

        let headerText = $A.get('$Label.c.AG_Product_Registration_Survey_Header');
        headerText = headerText.replace('<Product.Customer_Facing_Name__c>', assetName);
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
        
        let modalHeader = surveyModal.find('modalHeader');
        let modalHeaderBody = modalHeader.get('v.body');
        
        $A.util.addClass(modalHeader, 'globalPromptTitle');
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

        // this.setModal(component, 'lightning:checkboxGroup', contentValues, 'modalContent');

        let footerElements = [
            ['aura:html', { tag: 'center' }],
            ['lightning:button', {
                variant: 'brand',
                label: isQualifiedPromo ? 'NEXT' : 'OK',
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

    destroyComponents: function(component, modalComponent) {
        let components = component.find(modalComponent).get('v.body');
        if (components.length > 0) {
            for (let ctr = 0; ctr < components.length; ctr++) {
                components[ctr].destroy();
            }
        }
    },

    saveAttachment: function(component, fileData) {
        this.showprogress(component, "Uploading receipt....", 15);
        return new Promise((resolve, reject) => {
            let action = component.get("c.convertContentDocumentToAttachment");
            action.setParams(fileData);
            action.setCallback(this, function(response) {                
                if (response.getState() === 'SUCCESS') {
                    this.hideprogress(component);
                    resolve(response.getReturnValue());
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },

    setModal: function(component, element, values, type) {
        let modalComponent = component.find(type).get('v.body');
        $A.createComponent(element, values, (content, status, errorMessage) => {
            if (status === "SUCCESS") {
                modalComponent.push(content);
                component.find(type).set('v.body', modalComponent);
            } else {
                this.displayServerErrorMessage(component);
            }
        });
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

    showRedemptionModal: function(component) {
        component.set('v.modal', {
            visible: true,
            isHeaderVisible: true,
            isContentVisible: true,
            isFooterVisible: true
        });

        let message = component.get('v.isLimited') ? 'v.limitedRedemptionPopupHeader' : 'v.redemptionPopupHeader';
        const headerElements = [
            ...this.getModalCloseBtnElements(component.getReference('c.navigateToRedemptionsList')),
            ['aura:html', {
                'tag': 'h2',
                body: component.get(message),
                HTMLAttributes: {
                    class: 'slds-text-heading_medium slds-hyphenate'
                }
            }],
        ];
        
        let modalHeader = component.find('modalHeader').get('v.body');
        $A.createComponents(headerElements, (components) => {
            let closeBtn = components[0];
            let spanIcon = components[1];
            let spanAssistiveText = components[2];
            let closeIcon = components[3];
            let redemptionHeaderText = components[4];

            spanIcon.set('v.body', closeIcon);
            closeBtn.set('v.body', [spanIcon, spanAssistiveText]);

            modalHeader.push(closeBtn);
            modalHeader.push(redemptionHeaderText);

            component.find('modalHeader').set('v.body', modalHeader);
        });

        let contentElements = [['aura:html', { tag: 'center' }]];
        /*const isShowRedeemHelpText = component.get('v.isShowRedeemHelpText');
        if (isShowRedeemHelpText) {
            contentElements = [
                ...contentElements,
                ['aura:html', {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'span--font-size'
                    }
                }],
                ['aura:html', {
                    tag: 'b',
                    body:component.get('v.redeemHelpText')
                }]
            ];
        }*/

        contentElements = [...contentElements, 
            ['c:AEGLightningCarousel', {
                objectList: component.get('v.carouselItemsList'),
                redemptionItemId: component.getReference('v.uniqueId'),
                isChooseActive: true,
                purchaseProductId: component.get('v.asset.Product2Id'),
                typeClass: 'active',
                requiredObjectList: component.get('v.requiredCarouselItemsList'),
                hasManyRequiredRedemptions: component.get('v.hasManyRequiredRedemptions')
            }]
        ];

        let modalContent = component.find('modalContent').get('v.body');
        $A.createComponents(contentElements, (components) => {
            let center, spanHelpTextContainer, helpText, aegLightningCarousel;
            let centerBody = [];

            /*if (isShowRedeemHelpText) {
                center = components[0];
                spanHelpTextContainer = components[1];
                helpText = components[2];
                aegLightningCarousel = components[3];

                spanHelpTextContainer.set('v.body', helpText);
                centerBody.push(spanHelpTextContainer);
            } else {
                center = components[0];
                aegLightningCarousel = components[1];
            }*/

            center = components[0];
            aegLightningCarousel = components[1];

            centerBody.push(aegLightningCarousel);
            center.set('v.body', centerBody);
            modalContent.push(center);

            component.find('modalContent').set('v.body', modalContent);
        });

        let footerElements = this.getRedemptionModalFooterElements(component);
        let modalFooter = component.find('modalFooter').get('v.body');
        $A.createComponents(footerElements, (components) => {
            let center = components[0];
            let button = components[1];

            center.set('v.body', button);
            modalFooter.push(center);

            component.find('modalFooter').set('v.body', modalFooter);
        });
    },

    getRedemptionModalFooterElements: function(component) {
        const isRedeemable = component.get('v.isRedeemable');
        return [
            ['aura:html', { tag: 'center' }],
            ['lightning:button', {
                variant: 'brand',
                label: isRedeemable ? 'Redeem' : 'Close',
                onclick: component.getReference(`c.${isRedeemable ? 'navigateToCreateRedemption' : 'navigateToRedemptionsList'}`),
                class: 'slds-align_absolute-center globalProductItemButton'
            }]
        ]
    },

    showWarrantyModal: function(component, warrantyMessage) {
        component.set('v.modal', {
            visible: true,
            isHeaderVisible: true,
            isContentVisible: true,
            isFooterVisible: true
        });

        const { Brand__c: brand } = component.get("v.siteSettings");
        const warrantyURL = component.get('v.warrantyURL');
        const isQualifiedPromo = component.get('v.isQualifiedPromo');
        const surveyModal = component.find('surveyModal');
        const hasParticipated = surveyModal.get('v.hasParticipated');
        const headerElement = 'aura:unescapedHtml';
        const contentElement = 'aura:unescapedHtml';
        const headerValue = '<h2 class="slds-text-heading--medium">Registration Successful</h2>';
        const contentValue = `<p>Thank you for registering your product.<br/>${warrantyMessage}<br/>
            You can find details of the ${brand} warranty <a href="${warrantyURL}" target="_blank">here</a>.</p>`; 
        const footerElement = 'lightning:button';
        const footerElValues = isQualifiedPromo || !hasParticipated ? 
            {
                class: 'slds-button slds-button_brand globalProductItemButton',
                label: 'OK',
                onclick: component.getReference('c.nextProcess')
            }:
            {
                class: 'slds-button slds-button_brand globalProductItemButton',
                label: 'OK',
                onclick: component.getReference('c.navigateToToolbag')
            };

        this.setModal(component, headerElement, { value: headerValue }, 'modalHeader');
        this.setModal(component, contentElement, { value: contentValue }, 'modalContent');
        this.setModal(component, footerElement, footerElValues, 'modalFooter');

        document.querySelector('div.slds-modal__footer.slds-theme--default').click()
    },

    getWarrantyMessage: function(component, saveProductRegistrationResult, products) {
        let warrantyMessage;

        if (products.items.length > 1) {
            warrantyMessage = "Warranty for each product within the kit varies, please check your toolbag for details of warranty received.";
        } else {
            const standardWarranty = saveProductRegistrationResult.standardWarranty;
            const extendedWarranty = saveProductRegistrationResult.extendedWarranty;
            if (standardWarranty > 0 && extendedWarranty > 0) {
                warrantyMessage = `You have qualified for a standard warranty of ${standardWarranty / 12} years and an extended warranty of ${extendedWarranty / 12} years.`;
            } else if (standardWarranty > 0) {
                warrantyMessage = `You have qualified for a standard warranty of ${standardWarranty / 12} years`;
            } else {
                warrantyMessage = "Unfortunately, this product does not qualify for a warranty with the information provided.";
            }
        }

        return warrantyMessage;
    },

    handleProductSubmissionPayload: function(component, payload) {
        const { response,  isRedemptionApplicable, products } = payload;
        component.find('ga').push(response.assets, this.getCountryLongName(component));
        this.storeAssetId(component, response);

        if (isRedemptionApplicable) {
            this.initializeRedemption(component, response);
        }
        const warrantyMessage = this.getWarrantyMessage(component, response, products);   
        this.showWarrantyModal(component, warrantyMessage);
    },

    storeAssetId: function(component, response) {
        const { assets } = response;
        const asset = component.get('v.asset');
        const updatedAsset = assets.find(el => el.KitProduct__c === asset.Product2Id || el.Product2Id === asset.Product2Id);
        asset.Id = updatedAsset.Id;
        component.set('v.asset', asset);
    },

    parseCarouselUniqueId: function(uniqueId) {
        const keys = uniqueId.split('-');
        return {
            campaignId: keys[0],
            redeemableItemId: keys[1]
        }
    },

    navigateToRedemption: function(component, storagePayload, urlParam) {
        this.setSessionStorageData(storagePayload);
        const endpoint = component.get('v.siteSettings').Redemption__c;
        const url = `${endpoint}?target=AEGRedemptionPromotions&${urlParam}`;
        this.navigateTo(url);
    },

    setSessionStorageData: function(payload) {
        const keys = Object.keys(payload);
        keys.forEach(el => {
            window.sessionStorage.setItem(el, payload[el]);
        });
    },

    initializeRedemption: function(component, response) {
        if (response.redemptionCampaignJSON) {
            const payload = JSON.parse(response.redemptionCampaignJSON);

            if (payload.length > 0) {
                const productId = component.get('v.asset.Product2Id');
                const disclaimerMessage = this.getDisclaimerMessage();
                const redeemableItems = payload.reduce((acc, el) => [...acc, ...el.redeemableItems] , []);
                const isRedeemable = payload.some(el => this.isRedeemable(el));
                const isSelected = redeemableItems.length === 1 && isRedeemable;
                const carouselItemsList = payload.reduce((acc, el) => [...acc, 
                        ...this.getCarouselItems({promotion: el, productId, isSelected, disclaimerMessage })
                    ], []);

                var hasManyRequiredRedemptions = false;
                const requiredCarouselItemsList = payload.map(el => el.requiredRedeemableItems).flat()
                
                if(requiredCarouselItemsList && requiredCarouselItemsList.length > 0 && requiredCarouselItemsList[0]){
                    hasManyRequiredRedemptions = true;
                    component.set('v.requiredCarouselItemsList', requiredCarouselItemsList);
                }
                
                component.set('v.hasManyRequiredRedemptions', hasManyRequiredRedemptions);

                if (carouselItemsList.length > 0) {
                    this.setUniqueId(component, { details: payload[0], carouselItemsList });
                    this.showRedemptionHelpText(component, carouselItemsList);
                    component.set('v.carouselItemsList', carouselItemsList);
                    component.set('v.isQualifiedPromo', true);
                    component.set('v.isRedeemable', isRedeemable);
                }
                component.set('v.isLimited', payload.map(el => el.campaign).every(el => !!el.Submission_Limit__c));
            }
        }
    },

    isRedeemable: function(campaign) {
        const isLimited = this.isLimited(campaign);
        const isExhausted = this.isExhausted(campaign);
        return !isLimited || (isLimited && !isExhausted);
    },

    getCarouselItems: function(payload) {
        const { promotion, isSelected, disclaimerMessage, productId } = payload;
        const { campaign, redeemableItems: items } = promotion;
        const areAllItemsRedeemable = campaign.RedeemableProducts__r.RedeemType__c === 'All';
        const redeemableItems = areAllItemsRedeemable ? [items[0]] : items;
        return redeemableItems.reduce((acc, item) => [
            ...acc, 
            this.buildCarouselItem({ campaign, productId, item, isSelected, disclaimerMessage })]
        , []);
    },

    buildCarouselItem: function(payload) {
        const { campaign, productId, item, isSelected, disclaimerMessage } = payload;
        const { Id: id, Product__r: prod } = item;
        return {
            id,
            imageURL: prod.Image_URL__c,
            title: prod.SAP_MaterialNumber__c,
            productName: prod.Customer_Facing_Name__c,
            alternativeText: `redeemable_item_image`,
            campaignId: campaign.Id,
            uniqueId: `${campaign.Id}-${id}`,
            dataId: `${productId}|${campaign.Id}-${id}`, // Must be unique
            initialClass: this.getInitialClass(isSelected, campaign),
            disclaimerMessage: disclaimerMessage(campaign),
        }
    },

    getInitialClass: function(isSelected, campaign) {
        return `${isSelected ? 'redeem-item-opt' : ''} 
            ${this.isExhausted(campaign) ? 'disabled' : ''} 
            slds-carousel__panel-action slds-text-link_reset`;
    },

    getDisclaimerMessage: function() {
        const productExhaustedMessage = $A.get("$Label.c.AG_Product_Exhausted");
        const disclaimerMessage = $A.get("$Label.c.AG_Limited_Redemption_Disclaimer_Text");
        return (campaign) => {
            if (this.isExhausted(campaign)) {
                return productExhaustedMessage;
            }

            if (this.isLimited(campaign)) {
                return disclaimerMessage.replace('{!Redemption_Campaigns__c.Customer_Disclaimer_Limit__c}', campaign.Customer_Disclaimer_Limit__c)
            }

            return '';
        }
    },

    isExhausted: function(campaign) {
        const submissionLimit = campaign.Submission_Limit__c || 0;
        const totalSubmissions = campaign.Total_Number_of_Submissions__c || 0;
        return submissionLimit > 0 && totalSubmissions >= submissionLimit ;
    },

    isLimited: function(campaign) {
        const submissionLimit = campaign.Submission_Limit__c || 0;
        const disclaimerLimit = campaign.Customer_Disclaimer_Limit__c || 0;
        return submissionLimit != 0 && disclaimerLimit > 0;
    },

    setUniqueId: function(component, payload) {
        let uniqueId = '';
        const { details, carouselItemsList } = payload;
        const hasManyRedemptions = carouselItemsList.length > 1;
        if (!hasManyRedemptions) {
            const { campaign, redeemableItems } = details;
            uniqueId = `${campaign.Id}-${redeemableItems[0].Id}`;
        }
        component.set('v.uniqueId', uniqueId);
    },

    showRedemptionHelpText: function(component, items) {
        const hasManyRedemption = items.length > 1;
        component.set('v.isShowRedeemHelpText', hasManyRedemption);
    },

    getFile: function(component) {
        const fileInput = component.get("v.contentDocument");
        return fileInput.name ? fileInput.name : '';
    },

    isRedemptionApplicable: function(component, products) {
        const brandMapping = component.get('v.brandMappingMetadata')[0];
        const purchaseFrom = products.isKit ? 
            component.get('v.locationK') : 
            component.get("v.locationP");

        return brandMapping[purchaseFrom].Is_Redemption_Applicable__c;
    },

    populateAsset: function(component, asset, isKit) {
        const brandMapping = component.get('v.brandMappingMetadata')[0];
        const purchaseFrom = isKit ? component.get('v.locationK') : component.get("v.locationP");
        const purchaseDate = isKit ? component.get("v.purchaseDateK") : component.get("v.purchaseDateP");

        asset.sobjectType = "Asset";
        asset.Status = 'Confirmed';
        asset.Quantity = 1;
        asset.PurchaseDate = purchaseDate;
        asset.AssetSource__c = brandMapping[purchaseFrom].Asset_Source_Value__c;

        if (isKit) {
            asset.Asset_Source_Other__c = purchaseFrom !== "Bunnings" ? component.get("v.locationHolderK") : null;
        } else {
            asset.Asset_Source_Other__c = purchaseFrom === "Others" ? component.get("v.locationHolderP") : null;
            asset.SerialNumber = component.get("v.serialNoP");
            asset.SerialNumberWeek__c = component.get("v.serialWeek");
            asset.SerialNumberYear__c = component.get("v.serialYear");
        }
    },

    prepareAssets: function(component, products) {
        let assetList = [];
        for (let i = 0; i < products.items.length; i++) {
            let asset = products.items[i];
            this.populateAsset(component, asset, products.isKit);
            assetList.push(asset);
        }

        return assetList;
    },

    execSave: function(component, saveData) {
        this.showprogress(component, "Saving product registration...", 10);
        return new Promise((resolve, reject) => {
            let saveProductRegistrationAction = component.get("c.saveProductRegistration");
            saveProductRegistrationAction.setParams(saveData);
            saveProductRegistrationAction.setCallback(this, function(response) {                
                if (response.getState() === 'SUCCESS') {
                    this.hideprogress(component);
                    resolve(response.getReturnValue());
                } else {
                    reject();
                }
            });
            $A.enqueueAction(saveProductRegistrationAction);
        });
    },

    showprogress: function(component, message, progress) {
        component.set("v.statusMessage", message);
        $("#uploadingnew").show();
        $("#progressbar").removeClass("progress1 progress2 progress3 progress4 progress5 progress6 progress7 progress8 progress9 progress10");
        if (progress < 10) {
            $("#progressbar").addClass("progress1");
        } else if (progress < 20) {
            $("#progressbar").addClass("progress2");
        } else if (progress < 30) {
            $("#progressbar").addClass("progress3");
        } else if (progress < 40) {
            $("#progressbar").addClass("progress4");
        } else if (progress < 50) {
            $("#progressbar").addClass("progress5");
        } else if (progress < 60) {
            $("#progressbar").addClass("progress6");
        } else if (progress < 70) {
            $("#progressbar").addClass("progress7");
        } else if (progress < 80) {
            $("#progressbar").addClass("progress8");
        } else if (progress < 90) {
            $("#progressbar").addClass("progress9");
        } else {
            $("#progressbar").addClass("progress10");
        }
    },

    hideprogress: function(component) {
        component.set("v.statusMessage", "");
        $("#uploadingnew").hide();
    },

    showErrorMessage: function(component, errmessage) {
        component.set("v.errorMessage", errmessage);
        component.set("v.showError", true);
        component.find("confirmBtn").set("v.disabled", false);
    },

    hideErrorMessage: function(component) {
        component.set("v.errorMessage", "");
        component.set("v.showError", false);
    },

    displayServerErrorMessage: function(component) {
        this.hideprogress(component);
        this.showToast(component, '', $A.get("$Label.c.AEG_Generic_Error_Message"), 'error');
    },

    updateLocationList: function(component) {
        let action = component.get('c.fetchPurchaseFromValues');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                let locationsList = {};
                let payload = JSON.parse(response.getReturnValue());
                payload.sort((a, b) => a.Order__c < b.Order__c ? -1 : (a.Order__c > b.Order__c ? 1 : 0));
                payload.forEach(item => locationsList[item.MasterLabel] = item);
                component.set('v.brandMappingMetadata', locationsList);
                component.set("v.locationList", Object.keys(locationsList));
                component.set("v.locationP", Object.keys(locationsList)[0]);
                component.set("v.locationK", Object.keys(locationsList)[0]);
            } else {
                this.showToast(component, '', $A.get("$Label.c.AEG_Generic_Error_Message"), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    initializeCustomSettings: function(component) {
        const action = component.get("c.getSiteSettings");
        action.setCallback(this, function(response) {
            const settings = response.getReturnValue();
            this.setWarrantyURL(component, settings);
            component.set("v.siteSettings", settings);
        });
        $A.enqueueAction(action);
    },

    setWarrantyURL: function(component, settings) {
        const countryCode = component.get('v.countryCode');
        const suffix = countryCode === 'NZ' ? '_NZ' : '';
        const warrantyField = `Warranty_URL${suffix}__c`;
        component.set('v.warrantyURL', settings[warrantyField]);
    },

    setSerialHelperPromptValues: function(component, selectedProduct) {
        var individualAssetList = component.get("v.individualAssetList");
        for (let i = 0; i < individualAssetList.length; i++) {
            if (selectedProduct === individualAssetList[i].ProductCode) {
                component.set('v.serialHelperText', individualAssetList[i].HelpText__c);
                component.set('v.serialHelperImageURL', individualAssetList[i].Helper_Image_URL__c);
            }
        }
    },

    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            "variant": type,
            "title": title,
            "message": message
        });
    },

    removeContDocument: function(uploadedFiles, component, isBulk) {
        let currContentDocument = component.get('v.contentDocument');
        let action = component.get('c.removeContentDocuments');
        action.setParams({
            contentDocumentId: (currContentDocument ? currContentDocument.documentId : ''),
            isBulk: isBulk
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if (uploadedFiles) {
                    component.set("v.hasFile", true);
                    component.set('v.contentDocument', uploadedFiles);
                }
            } else {
                this.displayServerErrorMessage(component);
                return;
            }
        });
        $A.enqueueAction(action);
    },

    validateForm: function(component) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }

        if (mm < 10) {
            mm = '0' + mm;
        }
        today = yyyy + '-' + mm + '-' + dd;

        var individualAssetList = component.get("v.individualAssetList");
        var assetRec = component.get("v.asset");
        var sWeek = component.get("v.serialWeek");
        var sYear = component.get("v.serialYear");
        var hasWeek = assetRec.Display_Week__c;
        var hasYear = assetRec.Display_Year__c;
        var serialNumber = component.get("v.serialNoP").trim();
        var serialNumberLen = assetRec.Serial_Number_Length__c;
        var hasFile = component.get("v.hasFile");
        var isOthers = (component.get("v.locationP") === "Others");
        var isBunningsReceipt = (component.get("v.isBunningReceipt") === "Yes");
        var serialRegEx = assetRec.Regexpression_Validator__c;
        var errmessage = '';
        var enforceSerialLength = assetRec.EnforceLength__c;
        let serialNumberOptional = component.get("v.assetIsSerialNumberOptional");

        if (individualAssetList.length > 1) {
            var purchaseddate = component.get("v.purchaseDateK");
            var purchaseLocation = component.get("v.locationK");
            var purchaseLocOther = component.get("v.locationHolderK");
        } else {
            var purchaseddate = component.get("v.purchaseDateP");
            var purchaseLocation = component.get("v.locationP");
            var purchaseLocOther = component.get("v.locationHolderP");
        }

        if (!purchaseddate) {
            errmessage = "Please enter purchase date.";
        } else if (purchaseddate > today) {
            errmessage = "Please make sure that Date of purchase is not a future date.";
        } else if (!purchaseLocation) {
            errmessage = "Please enter purchase location.";
        } else if (purchaseLocation === 'Others' && !purchaseLocOther) {
            errmessage = "Please specify other purchase location.";
        } else if (!hasFile && (!isOthers && isBunningsReceipt)) {
            errmessage = "Please enter a receipt.";
        } else {
            if (individualAssetList.length === 1) {
                if (!serialNumber && !serialNumberOptional) {
                    errmessage = "Serial number is required.";
                } else if (serialNumber && serialNumber.length !== serialNumberLen && enforceSerialLength) {
                    errmessage = "Invalid serial number length, please enter length of " + serialNumberLen + " digits";
                } else if (serialNumber && serialRegEx) {
                    var patt = new RegExp(serialRegEx);
                    if (!patt.test(serialNumber)) {
                        errmessage = "Invalid serial number.";
                    }
                } else if (hasWeek && !sWeek && !serialNumberOptional) {
                    errmessage = "Serial week is required.";
                } else if (hasWeek && sWeek.length !== 2) {
                    errmessage = "Invalid serial week number, please enter two digits.";
                } else if (hasYear && !sYear && !serialNumberOptional) {
                    errmessage = "Serial year is required.";
                } else if (hasYear && sYear.length !== 4) {
                    errmessage = "Invalid serial year, please enter four digits.";
                } else {
                    errmessage = '';
                }

            } else if (individualAssetList.length > 1) {
                for (let asset of individualAssetList) {
                    if (!asset.SerialNumber && !asset.Is_Serial_Number_Optional__c) {
                        errmessage = "Serial number is required for product " + asset.Name + '.';
                        break;
                    } else if (asset.SerialNumber && asset.Regexpression_Validator__c) {
                        var patt = new RegExp(asset.Regexpression_Validator__c);
                        if (!patt.test(asset.SerialNumber)) {
                            errmessage = "Invalid serial number " + asset.Name + '.';
                        }
                    } else if (asset.SerialNumber && asset.SerialNumber.length !== asset.Serial_Number_Length__c && asset.EnforceLength__c) {
                        errmessage = "Invalid serial number length. Please enter length of " + asset.Serial_Number_Length__c + " digits for product " + asset.Name + '.';
                    } else if (asset.Display_Week__c && !asset.SerialNumberWeek__c && !asset.Is_Serial_Number_Optional__c) {
                        errmessage = "Serial week is required for product " + asset.Name + '.';
                    } else if (asset.Display_Week__c && asset.SerialNumberWeek__c.length !== 2) {
                        errmessage = "Invalid serial week number. Please enter two digits for product " + asset.Name + '.';
                    } else if (asset.Display_Year__c && !asset.SerialNumberYear__c && !asset.Is_Serial_Number_Optional__c) {
                        errmessage = "Serial year is required for product " + asset.Name + '.';
                    } else if (asset.Display_Year__c && asset.SerialNumberYear__c.length !== 4) {
                        errmessage = "Invalid serial year. Please enter four digits for product " + asset.Name + '.';
                    } else {
                        errmessage = '';
                    }
                }
            }
        }

        if (errmessage) {
            this.showErrorMessage(component, errmessage);
            return false;
        } else {
            this.hideErrorMessage(component);
            return true;
        }
    },

    getCountryLongName: function(component) {
        const countryCode = component.get('v.countryCode');
        return countryCode === 'AU' ? 'Australia' : 'New Zealand';
    },

    navigateTo: function(page) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    }
})