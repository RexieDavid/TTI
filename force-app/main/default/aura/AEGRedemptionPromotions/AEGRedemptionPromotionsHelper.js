({
    
    fetchSessionStorage: function(component) {
        const self = this;
        const callback = $A.getCallback(function() {
            component.set('v.selectedPromo', self.fetchSelectedPromo());
            self.init(component, self);
        });
        callback();
    },

    fetchSelectedPromo: function() {
        const keys = ['campaignId', 'redeemableItemId', 'assetId', 'productId'];
        const payload = keys.reduce((acc, el) => {
            acc[el] = window.sessionStorage.getItem(el);
            return acc;
        }, {});
        return payload;
    },

    init: function(component, self) {
        const selectedPromo = component.get('v.selectedPromo') || {};
        self.showComponent(component.find('activePromotionDiv'));
        self.getAllPromotions(component);
        if (!selectedPromo.assetId) {
            self.isLoadCarousel(component);
        }
    },

    getAllPromotions: function(component) {
        const selectedPromo = component.get('v.selectedPromo') || {};
        const action = component.get('c.getPromotions');
        action.setParams({ assetId: selectedPromo.assetId });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                const promotions = this.processPayload(component, response.getReturnValue());
                this.getAvailablePromotions(component, { promotions, selectedPromo });
                if (selectedPromo.productId) {
                    this.getPromotion(component, selectedPromo);
                } else {
                    this.getActivePromotions(component, promotions);
                }
            } else {
                this.showToast(component, 'Error', $A.get("$Label.c.Generic_Error_Message"), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    processPayload: function(component, response) {
        const payload = [];
        const promotions = JSON.parse(response);
        const keys = Object.keys(promotions);
        keys.forEach(el => {
            const items = this.processItems(component, promotions[el]);
            const promotion = this.buildPromoDetails(items);
            payload.push(promotion);
        });
        component.set('v.payload', payload);
        return payload;
    },

    processItems: function(component, items) {
        const selectedPromo = component.get('v.selectedPromo') || {};
        return items.reduce((acc, el) => {
            el.campaign.custom = this.buildCampaignCustomProp(el.campaign);
            el.custom = this.buildItemCustomProp(selectedPromo, el.campaign);
            el.redeemableItems = this.processRedeemableItems(el); 
            el.purchasedItems = this.processPurchasedItems(el);
            return [...acc, el];
        }, []);
    },

    buildCampaignCustomProp: function(campaign) {
        return {
            validFrom: this.formatDate(new Date(campaign.Valid_From__c)),
            validTo: this.formatDate(new Date(campaign.Valid_To__c)),
            validUntil: this.formatDate(new Date(campaign.Redeemed_By__c)),
        }
    },

    buildItemCustomProp: function(selectedPromo, campaign) {
        return {
            purchasedProductId: selectedPromo.productId || campaign.PurchasedProducts__c
        }
    },

    processRedeemableItems: function(payload) {
        const messages = { exhaust: $A.get("$Label.c.AG_Product_Exhausted"), limit: $A.get("$Label.c.AG_Limited_Redemption_Disclaimer_Text") };
        const { campaign, redeemableItems, custom } = payload;
        const isAllRedeemable = campaign.RedeemableProducts__r.RedeemType__c === 'All';
        const items = redeemableItems.reduce((acc, item) => [
            ...acc, 
            this.buildRedeemableItem({ campaign, item, messages, custom })
        ], []);
        return this.processRedeemableCarouselItems(items, isAllRedeemable);
    },

    buildRedeemableItem: function(payload) {
        const { campaign, item, messages, custom } = payload;
        const { Id: id, Quantity__c: quantity, Product__r: prod } = item;
        return {
            id,
            imageURL: prod.Image_URL__c,
            title: prod.SAP_MaterialNumber__c,
            productName: prod.Customer_Facing_Name__c,
            alternativeText: `redeemable_item_image`,
            campaignId: campaign.Id,
            quantity,
            redemptionItemId: `${campaign.Id}-${id}`,
            dataId: `${custom.purchasedProductId}|${campaign.Id}-${id}`,
            initialClass: this.getInitialUIClass(campaign),
            disclaimerMessage: this.getDisclaimerMessage(campaign, messages),
            limit: campaign.Customer_Disclaimer_Limit__c
        }
    },

    processRedeemableCarouselItems: function(products, isAllRedeemable) {
        if (!isAllRedeemable) {
            products.forEach(el => el.items = [JSON.parse(JSON.stringify(el))]);
            return products;
        }
        const product = products[0];
        product.items = JSON.parse(JSON.stringify(products));
        return [ product ];
    },

    processPurchasedItems: function(payload) {
        const { campaign, purchasedItems } = payload;
        return purchasedItems.reduce((acc, item) => [
            ...acc,
            this.buildPurchasedItem({ campaign, item }) 
        ], []);
    },

    buildPurchasedItem: function(payload) {
        const { campaign, item } = payload;
        const { Id: id, Product__r: prod } = item;
        const { validFrom, validTo } = campaign.custom;
        return {
            id,
            imageURL: prod.Image_URL__c,
            title: prod.SAP_MaterialNumber__c,
            productName: prod.Customer_Facing_Name__c,
            validTo,
            validFrom,
            productId: prod.Id,
            campaignId: campaign.Id,
            limit: campaign.Customer_Disclaimer_Limit__c
        }
    },

    buildPromoDetails: function(payload) {
        const { campaign, purchasedItems, isRedeemable, isActive } = payload[0];
        const redeemableItems = payload.map(el => el.redeemableItems).flat()
        const requiredRedeemableItems = payload.map(el => el.requiredRedeemableItems).flat()
        const custom = this.buildPromoCustomProp(payload);
        return { 
            campaign, 
            purchasedItems, 
            isRedeemable, 
            redeemableItems, 
            isActive,
            custom,
            requiredRedeemableItems
        };
    },

    buildPromoCustomProp: function(payload) {
        const { campaign, custom } = payload[0];
        const isLimited = this.isLimited(campaign);
        const result = JSON.parse(JSON.stringify(custom));
        result.isLimited = isLimited;
        //SCTASK0023019 - Updated to return the result with redemptionItemId - 10/26/2022-JAC
        result.redemptionItemId = payload[0].redeemableItems[0].redemptionItemId;
        //result.redemptionItemId = '';
        //End SCTASK0023019 10/26/2022-JAC
        return result;
    },

    getAvailablePromotions: function(component, payload) {
        const { promotions, selectedPromo } = payload;
        const redeemableItems = promotions.filter(el => el.isRedeemable);
        const hasSelectedPromo = !!selectedPromo.productId;
        component.set('v.availablePromotions', this.groupAvailablePromotions(redeemableItems, hasSelectedPromo));
    },

    groupAvailablePromotions: function(payload, hasSelectedPromo) {
        const promotions = payload.reduce((acc, el) => {
            this.cleanPurchasedProducts(el);
            const key = this.getAvailablePromotionKey(el, hasSelectedPromo);
            if (!acc.hasOwnProperty(key)) {
                acc[key] = el;
            } else {
                acc[key] = this.processExistingItem(acc[key], el);
            }
            return acc;
        }, {});
        return Object.values(promotions);
    },

    cleanPurchasedProducts: function(payload) {
        payload.purchasedItems.forEach(el => {
            delete el.limit;
        });
    },

    getAvailablePromotionKey: function(payload, hasSelectedPromo) {
        const { campaign, custom } = payload;
        const key = custom.purchasedProductId;
        if (hasSelectedPromo) {
            return key;
        }
        return key + (hasSelectedPromo ? '' : ` | ${campaign.Valid_From__c} - ${campaign.Valid_To__c} | ${campaign.Redeemed_By__c}`);
    },

    processExistingItem: function(payload, source) {
        const result = JSON.parse(JSON.stringify(payload));
        const { redeemableItems } = source;
        result.redeemableItems = result.redeemableItems.concat(redeemableItems);
        return result;
    },

    getPromotion: function(component, selectedPromo) {
        const availablePromotions = component.get('v.availablePromotions');
        const promo = availablePromotions[0]; // This will always be one
        this.createRedemption(component, { selectedPromo , promo });
    },

    createRedemption: function(component, payload) {
        const { selectedPromo } = payload;
        const promo = this.buildPromo(payload);
        const promotions = component.get('v.payload');

        console.log('*** aeg promotions payload:'+JSON.stringify(payload));

        this.navigateToCreateRedemptionPage({ selectedPromo, promo, promotions });
        this.resetCarouselIntervals(component);
        this.hideComponent(component.find('activePromotionDiv'));
        $('.carousel-container').slick('unslick');
    },

    buildPromo: function(payload) {
        const { selectedPromo, promo } = payload;
        const { campaignId, redeemableItemId } = selectedPromo;
        const result = JSON.parse(JSON.stringify(promo));
        result.redeemableItems.forEach(el => { el.initialClass += (el.redemptionItemId === `${campaignId}-${redeemableItemId}` ? ' redeem-item-opt' : '') });
        return result
    },

    getActivePromotions: function(component, payload) {
        const promotions = this.removeDisclaimerMessages(payload);
        component.set('v.activePromotions', promotions);
        component.set('v.isCssLoaded', true);
    },

    removeDisclaimerMessages: function(payload) {
        const promotions = JSON.parse(JSON.stringify(payload)).filter(el => el.isActive);
        promotions.forEach(el => {
            el.redeemableItems.forEach(item => {
                delete item.disclaimerMessage;
                delete item.limit;
            });
        })
        return promotions;
    },

    resetCarouselIntervals: function(component) {
        const carousels = component.find('purchasedProductCarousel');
        if (carousels && carousels.length > 0) {
            carousels.forEach(el =>{
                el.clearInterval();
            });
        }
    },

    navigateToCreateRedemptionPage: function(payload) {

        console.log('*** aeg promotions - navigateToCreateRedemptionPage payload:'+JSON.stringify(payload));

        const nav = {
            "Target": "AEGCreateRedemption",
            "RecordJSON": JSON.stringify(payload)
        };
        this.fireNavigationEvent(nav);
    },

    fireNavigationEvent: function(params) {
        const navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams(params);
        navEvent.fire();
    },

    navigateTo: function(page) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    },

    getURLParameter: function(name) {
        return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
    },

    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            "variant": type,
            "title": title,
            "message": message
        });
    },

    isRedeemable: function(campaign) {
        const isLimited = this.isLimited(campaign);
        const isExhausted = this.isExhausted(campaign);
        return !isLimited || (isLimited && !isExhausted);
    },

    getInitialUIClass: function(campaign) {
        return `${this.isExhausted(campaign) ? 'disabled' : ''} 
            slds-carousel__panel-action slds-text-link_reset`;
    },

    getDisclaimerMessage: function(campaign, messages) {
        if (this.isExhausted(campaign) && messages.exhaust) {
            return messages.exhaust;
        }

        if (this.isLimited(campaign) && messages.limit) {
            return messages.limit.replace('{!Redemption_Campaigns__c.Customer_Disclaimer_Limit__c}', campaign.Customer_Disclaimer_Limit__c)
        }

        return '';
    },

    isExhausted: function(campaign) {
        const submissionLimit = campaign.Submission_Limit__c || 0;
        const totalSubmissions = campaign.Total_Number_of_Submissions__c || 0;
        return submissionLimit > 0 && totalSubmissions >= submissionLimit;
    },

    isLimited: function(campaign) {
        const submissionLimit = campaign.Submission_Limit__c || 0;
        const disclaimerLimit = campaign.Customer_Disclaimer_Limit__c || 0;
        return submissionLimit != 0 && disclaimerLimit > 0;
    },

    isLoadCarousel: function(component) {
        var isActive = $A.util.hasClass(component.find("activePromotionDiv"), "slds-show");
        component.set('v.isLoadCarousel', isActive ? true : false);
    },

    formatDate: function(date) {
        const day = this.padStart(date.getDate().toString(), 2, '0');
        const month = this.padStart((date.getMonth() + 1).toString(), 2, '0');
        const year = date.getFullYear();

        return `${day}/${month}/${year}`;
    },

    padStart: function(text, targetLength, padString) {
        targetLength = targetLength >> 0; // truncate if number or convert non-number to 0;
        padString = String((typeof padString !== 'undefined' ? padString : ' '));
        if (text.length > targetLength) {
            return String(text);
        } else {
            targetLength = targetLength - text.length;
            if (targetLength > padString.length) {
                padString += padString.repeat(targetLength / padString.length); // append to original to ensure we are longer than needed
            }
            return padString.slice(0, targetLength) + String(text);
        }
    },
    
    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },
})