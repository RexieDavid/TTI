({
    doInit: function(component, event, helper) {
        helper.initializeModal(component);
        helper.removeContDocument(null, component, true);
    },

    handleNavigateFromSelectionEvent: function(component, event, helper) {
        helper.removeContDocument(null, component, true);
        component.set('v.currentUser', $A.get("$SObjectType.CurrentUser"));

        var asset = event.getParam("selectedAsset");
        component.set("v.asset", asset);
        component.set("v.assetImageURL", asset.Image_URL__c);
        component.set("v.assetProductCode", asset.ProductCode);
        component.set("v.assetIsSerialNumberOptional", asset.Is_Serial_Number_Optional__c);
        component.set("v.assetHelpText", asset.HelpText__c.split("_"));

        var individualAssetList = event.getParam("individualAssetList");
        component.set("v.individualAssetList", individualAssetList);

        component.set("v.purchaseDateP", '');
        component.set("v.purchaseDateK", '');
        component.set("v.serialNoP", '');
        component.set("v.locationHolderP", '');
        component.set("v.locationHolderK", '');
        component.set("v.serialWeek", '');
        component.set("v.serialYear", '');
        component.set("v.contentDocument", []);
        component.set("v.hasFile", false);
        component.set("v.isBunningReceipt", 'Yes');
        component.set("v.showError", false);

        helper.updateLocationList(component);
        helper.initializeCustomSettings(component);

        $("#confirmBtn").blur();
        if (individualAssetList.length > 1) {
            $("#kitDetailDiv").show();
            $("#productDetailDiv").hide();
        } else {
            $("#kitDetailDiv").hide();
            $("#productDetailDiv").show();
        }
        $("#mainDetailDiv").show();
    },

    fileUploaded: function(component, event, helper) {
        var uploadedFiles = event.getParam("files")[0];
        uploadedFiles.documentId = uploadedFiles.documentId.substring(0, 15);
        uploadedFiles.name = uploadedFiles.name.substring(0, uploadedFiles.name.lastIndexOf('.'));
        helper.removeContDocument(uploadedFiles, component, false, helper);
    },

    execSaveSurvey: function(component, event, helper) {
        const successCallback = (component) => {
            component.surveySuccessCallback();
        }
        
        component.find('surveyModal')
        .execSaveSurvey(component, successCallback, () => {});
    },

    closeSurvey: function(component, event, helper) {
        const successCallback = (component) => {
            component.surveySuccessCallback();
        }

        component.find('surveyModal')
        .closeSurvey(component, successCallback, () => {});
    },

    surveySuccessCallback: function(component, event, helper) {
        helper.initializeModal(component);
        helper.navigateTo(component.get("v.siteSettings").My_Toolbag__c);
    },

    nextProcess: function(component, event, helper) {
        helper.destroyComponents(component, 'modalHeader');
        helper.destroyComponents(component, 'modalContent');
        helper.destroyComponents(component, 'modalFooter');
        
        const surveyModal = component.find('surveyModal');
        const hasParticipated = surveyModal.get('v.hasParticipated');
        const isQualifiedPromo = component.get('v.isQualifiedPromo');
        
        if (!isQualifiedPromo && !hasParticipated) {
            helper.initializeModal(component);
            helper.showSurveyModal(component);
        } else {
            helper.showRedemptionModal(component);
        }
    },

    register: function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        if (helper.validateForm(component)) {
            const products = {
                items: component.get("v.individualAssetList"),
                isKit: component.get("v.individualAssetList").length > 1
            }
            const isRedemptionApplicable = helper.isRedemptionApplicable(component, products);     

            helper.execSave(component, {
                assets: helper.prepareAssets(component, products),
                isFromValidRetailer: component.get("v.isBunningReceipt"),
                filename: helper.getFile(component),
                productCode: component.get('v.assetProductCode'),
                isCustomMedata: true,
                contentDocumentId: component.get("v.hasFile") ? 
                    component.get('v.contentDocument').documentId : null,
                retailerSource: products.isKit ?
                	component.get("v.locationK") : component.get("v.locationP")
            })
            .then(response => {
                if (response.error) {
                    throw response.message;
                }
                helper.handleProductSubmissionPayload(component, { response,  isRedemptionApplicable, products });
            })
            .catch(() => {
                helper.displayServerErrorMessage(component);
            });
        }
        event.getSource().set("v.disabled", false);
    },

    goBackToSelection: function(component, event, helper) {
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        var evt = $A.get("e.c:ProductDetailConfirmEvent");
        evt.fire();
    },

    displaySerialHelper: function(component, event, helper) {
        var idx = event.target.id;
        helper.setSerialHelperPromptValues(component, idx);
        $("#SerialHelperInfo").show();
    },

    hideSerialHelper: function(component, event, helper) {
        $("#SerialHelperInfo").hide();
    },

    navigateToCreateRedemption: function(component, event, helper) {
        const uniqueId = component.get('v.uniqueId'); // campaignid - redeemableproductlineitemid
        if (uniqueId) {
            const asset = component.get('v.asset');
            const { campaignId, redeemableItemId  } = helper.parseCarouselUniqueId(uniqueId);
            helper.navigateToRedemption(component, {
                campaignId,
                redeemableItemId,
                assetId: asset.Id,
                productId: asset.Product2Id
            }, 'source=ProductRegistration');   
        } else {
            helper.showToast(component, '', $A.get("$Label.c.AEG_Redeem_Item_Error"), 'error');
        }
    },

    navigateToRedemptionsList: function(component, event, helper) {
        helper.navigateToRedemption(component, {}, '');
    },

    navigateToToolbag: function(component, event, helper) {
        helper.navigateTo(component.get("v.siteSettings").My_Toolbag__c);
    }
})