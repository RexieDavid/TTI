({
    doInit: function(component, event, helper) {
        const source = helper.getURLParameter('source');
        if (helper.getURLParameter('target') === component.get('v.pageName')) {
            if (source === 'ProductRegistration') {
                helper.fetchSessionStorage(component);
            } else {
                helper.init(component, helper);
            }
        }
    },

    handleNavigate: function(component, event, helper) {
        if (event.getParam('Target') === component.get('v.pageName')) {
            helper.init(component, helper);
        }
    },

    navigateToCreateRedemption: function(component, event, helper) {
        //SCTASK0023019 - Updated to get the name and data-id attribute - 10/26/2022-JAC
        const campaignId = event.currentTarget.getAttribute("name");
        //const campaignId = event.getSource().get('v.name');
        const availablePromotions = component.get('v.availablePromotions');
        const promo = availablePromotions.find(el => el.campaign.Id.indexOf(campaignId) !== -1);
        promo.custom.redemptionItemId = event.currentTarget.getAttribute("data-id");
        //End SCTASK0023019 10/26/2022-JAC
        const { redemptionItemId } = promo.custom;
        if (redemptionItemId) {
            const keys = redemptionItemId.split('-');
            const selectedPromo = { campaignId, redeemableItemId: keys[1] };
            helper.createRedemption(component, { promo, selectedPromo });
        } else {
            helper.showToast(component, '', $A.get("$Label.c.AEG_Redeem_Item_Error"), 'error');
        }
    },

    slick: function(component, event, helper) {
        let slidesToShow = 2;
        $('.carousel-container').slick({
            infinite: true,
            slidesToShow: slidesToShow,
            slidesToScroll: slidesToShow,
            dots: true,
            responsive: [
                {
                    breakpoint: 1024,
                    settings: {
                        slidesToShow: (slidesToShow - 1 > 1 ? slidesToShow - 1 : 1),
                        slidesToScroll: (slidesToShow - 1 > 1 ? slidesToShow - 1 : 1),
                        arrows: false
                    }
                },
                {
                    breakpoint: 600,
                    settings: {
                        slidesToShow: (slidesToShow - 2 > 1 ? slidesToShow - 2 : 1),
                        slidesToScroll: (slidesToShow - 2 > 1 ? slidesToShow - 2 : 1),
                        arrows: false
                    }
                },
                {
                    breakpoint: 480,
                    settings: {
                        slidesToShow: 1,
                        slidesToScroll: 1,
                        arrows: false

                    }
                }
            ]
        });
        component.set('v.isCssLoaded', true);
    }
})