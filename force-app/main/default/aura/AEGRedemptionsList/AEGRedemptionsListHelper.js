({
    ACTIVE_STATUS: ['Submitted', 'Approved - Sent to SAP', 'Approved - SAP Error', 'Approved - SAP Order Created',
                     'Further Information Required'],
    COMPLETE_STATUS: ['Rejected', 'Completed'],
    /**
     * @description                 Initialize table columns and redemptions
     * @param {*} component         Aura component
     */
    initializeData: function(component) {
        this.resetComponentValues(component);
        const params  = { "statuses": JSON.stringify([...this.ACTIVE_STATUS, ...this.COMPLETE_STATUS]) };
        this.runPromiseCall(component, 'fetchRedemptions', params)
        .then(result => {
            this.processRedemptions(component, result);
        })
        .catch(error => {
            this.showToast(component, 'Error!', error.message, 'error');
        })
    },

    /**
     * @description                 Reset component values
     * @param {*} component         Aura component
     */
    resetComponentValues: function(component) {
        component.set('v.isLoaded', false);
        component.set('v.activeRedemptionsList', []);
        component.set('v.completeRedemptionsList', []);
        this.setTableColumns(component);
    },

    /**
     * @description                 Run apex method in promise
     *
     * @param {*} component         Aura component
     * @param {*} apexmethod        Method name
     * @param {*} params            Method parameters
     */
    runPromiseCall: function(component, apexmethod, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get(`c.${apexmethod}`);
            action.setParams(params);
            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else {
                    reject(Error($A.get("$Label.c.Generic_Error_Message")));
                }
            });
            $A.enqueueAction(action);
        }));
    },

    /**
     * @description                 Process redemption records
     *
     * @param {*} component         Aura component
     * @param {*} payload           Redemption records
     */
    processRedemptions: function(component, payload) {
        const status = this.updateRedemptionStatus();
        const activeRedemptions = [];
        const completedRedemptions = [];
        const results = JSON.parse(payload);
        results.forEach(el => {
            const obj = this.buildTableData(el);
            if (this.ACTIVE_STATUS.includes(obj.Status__c)) {
                activeRedemptions.push(obj);
            } else {
                completedRedemptions.push(obj);
            }
            obj.Status__c = status(obj.Status__c);
        });
        component.set('v.activeRedemptionsList', activeRedemptions);
        component.set('v.completeRedemptionsList', completedRedemptions);
        component.set('v.isLoaded', true);
    },

    buildTableData: function(payload) {
        const { redemption, redeemedProducts, purchasedProducts, formattedCreatedDate } = payload;
        const purchasedProductNames = purchasedProducts.map(el => el.Product__r.Name || el.Product__r.ProductCode).join(', ');
        return {
            CreatedDate: formattedCreatedDate,
            Id: redemption.Id,
            Name: redemption.Name,
            Product_Name__c: purchasedProductNames,
            PurchasedProducts: this.buildCarouselDetails(purchasedProducts),
            RedeemedItems: this.buildCarouselDetails(redeemedProducts),
            Status__c: redemption.Status__c,
            Freight_Tracking_URL__c: redemption.Freight_Tracking_URL__c
        }
    },

    buildCarouselDetails: function(products) {
        return products.reduce((acc, el) => [
            ...acc, 
            this.buildCarouselItem(el.Product__r)
        ], [])
    },

    buildCarouselItem: function(product) {
        return {
            id: product.Id,
            imageURL: product.Image_URL__c,
            title: '',
            productName: '',
            validTo: '',
            validFrom: ''
        }
    },

    /**
     * @description                 Update redemption status
     *
     *                              Maximize usage of closure methods
     *                              to cache the constant variables.
     */
    updateRedemptionStatus: function() {
        const inProgressStatuses = ['Approved - Sent to SAP', 'Approved - SAP Error', 'Approved - SAP Order Created'];
        const verificationRequiredStatuses = ['Submitted'];
        return status = (status) => {
            let newStatus;
            if (inProgressStatuses.includes(status)) {
                newStatus = 'In Progress';
            } else if (verificationRequiredStatuses.includes(status)) {
                newStatus = 'Verification Required';
            } else {
                newStatus = status;
            }
            return newStatus;
        }
    },

    /**
     * @description                 Hide component via class
     *
     * @param {*} component         Component to hide
     */
    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    /**
     * @description                 Show component via class
     *
     * @param {*} component         Component to show
     */
    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    /**
     * @description                 Show toast
     *
     * @param {*} component         Aura component
     * @param {*} title             Toast title
     * @param {*} message           Toast message
     * @param {*} type              Toast type
     */
    showToast: function(component, title, message, type) {
        component.find('notifLib').showToast({
            "variant": type,
            "title": title,
            "message": message
        });
    },

    setTableColumns: function(component) {
        const columns = [
            { label: 'RECORD ID', fieldName: 'Id' },
            { label: 'STATUS', fieldName: 'Status__c' },
            { label: 'PURCHASED PRODUCT NAME', fieldName: 'Product_Name__c' },
            { label: 'CREATED DATE', fieldName: 'CreatedDate' },
            { label: 'FREIGHT TRACKING URL', fieldName: 'Freight_Tracking_URL__c' }
        ];
        component.set('v.activeTableColumns', columns);
        component.set('v.completeTableColumns', columns);
    }
})