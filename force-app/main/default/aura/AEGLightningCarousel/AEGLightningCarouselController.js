({

    afterScriptsLoaded: function(component, event, helper) {
        
        //After setting the default, apply slick
        if (component.get('v.isLoadCss')) {
            let slidesToShow = component.get('v.slidesToShow');
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
        }
        component.set('v.isLoaded', true);
    },

    chooseRedeemItem: function(component, event, helper) {
        if (component.get('v.isChooseActive')) {
            const typeClass =  component.get('v.typeClass');
            const purchaseId = component.get('v.purchaseProductId');
            const divs = $(`.${typeClass} > a[data-id^="${purchaseId}"]`);
            const redemptionId = event.currentTarget.getAttribute("data-id");
            for (let elem of divs) {
                if ($(elem).attr('data-id') === redemptionId) {
                    $(elem).addClass('redeem-item-opt');
                } else {
                    $(elem).removeClass('redeem-item-opt');
                }
            }
            component.set('v.redemptionItemId', redemptionId.substring(redemptionId.indexOf('|') + 1));
        }
    },
})