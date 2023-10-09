({
    handleNavigate: function(component, event, helper) {
        if (event.getParam('Target') === component.get('v.PageName')) {
            const payload = JSON.parse(event.getParam('RecordJSON'));
            helper.processPayload(component, payload);
            helper.loadData(component, event, helper);
            helper.setHeaderComponentStyle(component);
            helper.showComponent(component.find('createRedemptionDiv'));
        }
    },

    toggleView: function(component, event, helper) {
        var target = event.getSource().getLocalId();
        if (target === 'conEditButtonRedemption' || target === 'conDeleteButtonRedemption') {
            if (component.get('v.contactEdit')) {
                helper.removeHideCSS(component.find('conViewDetails'));
                helper.addHideCSS(component.find('conEditDetails'));
                helper.showComponent(component.find('conEditButtonRedemption'));
                helper.hideComponent(component.find('conDetailsButtons'));
                component.set('v.contactEdit', false);
            } else {
                helper.addHideCSS(component.find('conViewDetails'));
                helper.removeHideCSS(component.find('conEditDetails'));
                helper.hideComponent(component.find('conEditButtonRedemption'));
                helper.showComponent(component.find('conDetailsButtons'));
                component.set('v.contactEdit', true);
            }
        } else if (target === 'shipEditButtonRedemption' || target === 'shipDeleteButtonRedemption') {
            if (component.get('v.shippingAddressEdit')) {
                helper.removeHideCSS(component.find('shipViewDetails'));
                helper.addHideCSS(component.find('shipEditDetails'));
                helper.showComponent(component.find('shipEditButtonRedemption'));
                helper.hideComponent(component.find('shipAddressButtons'));
                component.set('v.shippingAddressEdit', false);
            } else {
                helper.addHideCSS(component.find('shipViewDetails'));
                helper.removeHideCSS(component.find('shipEditDetails'));
                helper.hideComponent(component.find('shipEditButtonRedemption'));
                helper.showComponent(component.find('shipAddressButtons'));
                component.set('v.shippingAddressEdit', true);
            }
        } else {
            // Reset values
            component.set('v.shippingAddressEdit', false);
            component.set('v.contactEdit', false);
        }
    },

    closeAlert: function(component, event, helper) {
        helper.hideComponent(component.find('alertErrorMsg'));
    },

    saveDetails: function(component, event, helper) {
        helper.saveDetailsH(component, event, helper);
    },

    keyUpHandler: function(component, event, helper) {
        var searchString = component.get("v.searchString");
        if (searchString) {
            helper.openListbox(component, searchString);
            helper.displayPredictions(component, searchString);
        } else {
            helper.clearComponentConfig(component);
        }
    },

    selectOption: function(component, event, helper) {
        var list = component.get("v.predictions");
        var placeId = component.get("v.placeId");
        var searchLookup = component.find("searchLookup");
        var iconPosition = component.find("iconPosition");
        var selection = event.currentTarget.dataset.record;
        placeId = list.filter(value => value.label === selection)[0].PlaceId;

        component.set("v.selectedOption ", selection);
        component.set("v.searchString", selection);
        $A.util.removeClass(searchLookup, 'slds-is-open');
        $A.util.removeClass(iconPosition, 'slds-input-has-icon_left');
        $A.util.addClass(iconPosition, 'slds-input-has-icon_right');
        helper.displaySelectionDetails(component, placeId);
    },

    clear: function(component, event, helper) {
        helper.clearComponentConfig(component);
    },

    onCheck: function(component, event, helper) {
        component.set('v.disAddress', !component.get('v.disAddress'));
        helper.clearComponentConfig(component);
    },

    toggleSubmitModal: function(component, event, helper) {
        helper.toggleModal(component, 'isShowConfirmModal');
    },

    handleSubmit: function(component, event, helper) {
        let hasManyRedemptions = component.get('v.hasManyRedemptions');
        if (hasManyRedemptions) {
            helper.toggleModal(component, 'isShowConfirmModal');
        } else {
            helper.saveDetailsH(component, event, helper);
        }
    },

    toggleRedeemModal: function(component, event, helper) {
        helper.toggleRedeem(component);
    },

    updateRedemption: function(component, event, helper) {
        const payload = JSON.parse(JSON.stringify(component.get('v.payload')));
        const { redemptionItemId } = component.get('v.selectedPromo');
        const details = redemptionItemId.split('-');
        payload.selectedPromo.campaignId = details[0];
        payload.selectedPromo.redeemableItemId = details[1];
        payload.promo.redeemableItems.forEach(el => {
            el.initialClass = `slds-carousel__panel-action slds-text-link_reset ${el.redemptionItemId === redemptionItemId ? ' redeem-item-opt' : ''}`;
        });
        helper.resetSelectedPromo(component);
        helper.processPayload(component, payload);
        helper.toggleRedeem(component);
    },

    closeSurvey: function(component, event, helper) {
        component.find('surveyModal')
        .closeSurvey(component, helper.getSurveySuccessCallback(), () => {});
    },   

    execSaveSurvey: function(component, event, helper) {
        component.find('surveyModal')
        .execSaveSurvey(component, helper.getSurveySuccessCallback(), () => {});
    },

    navigateToRedemptionList: function(component, event, helper) {
        $A.get('e.c:NavigateEvent')
        .setParams({Target: 'AEGRedemptionList'})
        .fire();
    },

    redirectHome: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/myAEG/s/"
        });
        urlEvent.fire();
    }
})