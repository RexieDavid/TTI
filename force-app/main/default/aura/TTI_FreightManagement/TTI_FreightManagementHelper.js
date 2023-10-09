/**
 * @File Name          : TTI_FreightManagementHelper.js
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 30/08/2019, 8:39:54 am
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                   Modification
 *==============================================================================
 * 1.0    31/07/2019, 2:51:34 pm   Francis Nasalita     Initial Version
**/
({
    fetchUserData: function(component) {
        this.setPDFSourceView(component);
        return new Promise($A.getCallback(( resolve, reject ) => {
            var fetchDataAction = component.get("c.getCurrentUser");

                fetchDataAction.setCallback(this, response => {
                    var state = response.getState();
                    var retVal = response.getReturnValue();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if (state === 'SUCCESS') {
                        component.set('v.contactId', retVal.ContactId);
                        component.set("v.serviceAgentTimeZone", $A.get("$Locale.timezone"));
                        resolve({
                            allowedDelivery: retVal.Account.Allow_Delivery_to_Customers__c,
                            customerNo: retVal.Account.TTI_SAP_Cust_No__c,
                            allowedManifest: retVal.Account.Allow_Delivery_to_Customers__c
                                    && (!retVal.Contact.Last_Manifested_Date__c
                                        || retVal.Contact.Last_Manifested_Date__c < today)
                            
                        });
                    } else {
                        reject(retVal);
                    }
                });

                $A.enqueueAction(fetchDataAction);
        }));
    },

    setPDFSourceView: function(component) {
        const pdfjs = $A.get('$Resource.pdfjs') + '/web/viewer.html';
        component.set('v.pdfViewerSrc', pdfjs);
    },

    initializeColumns: function(component) {
        component.set('v.columns', [
            { label: 'Claim', fieldName: 'CaseNumber', type: 'url' , isSearchable: true},
            { label: 'Technician', fieldName: 'AgentRef', type: 'text' , isSearchable: true},
            { label: 'Customer Name', fieldName: 'CustomerName', type: 'text' , isSearchable: true},
            { label: 'Retailer', fieldName: 'Retailer_Account__c', type: 'text' , isSearchable: true},
            { label: 'Consignment Number', fieldName: 'Shipment_Id__c', type: 'url' , isSearchable: true},
            { label: 'Tracking Link', fieldName: 'Track', type: 'url' , isSearchable: false},
            { label: 'Booking #', fieldName: 'OrderId__c', type: 'url' , isSearchable: true},
            { label: 'Closed Date', fieldName: 'TTI_Closed_Datetime__c', type: 'date', isSearchable: true }
        ]);
    },

    getCases: function(component) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var getClaimsAction = component.get("c.getClaims");
            let isViewArchived = component.get("v.claimViewType") === 'archived';

            getClaimsAction.setParams({
                'lastNDays': component.get("v.lastNDays"),
                'isViewArchived': isViewArchived
            });

            getClaimsAction.setCallback(this, response => {
                var state = response.getState();
                var retVal = response.getReturnValue();
                if (state === 'SUCCESS') {
                    var results = JSON.parse(retVal);

                    resolve(results);
                } else {
                    reject(retVal);
                }
            });

            $A.enqueueAction(getClaimsAction);
        }));
    },

    buildData: function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allDataRetrieved");
        var counter = (pageNumber - 1) * pageSize;
        
        for(; counter <= (pageNumber) * pageSize; counter++) {
            if (counter > allData.length) {
                break;
            }

            if (allData[counter]) {
                allData[counter].rowClass = allData[counter].isSelected ? 'slds-hint-parent slds-is-selected' : 'slds-hint-parent';
                data.push(allData[counter]);
            }
        }
        component.set("v.data", data);

        helper.generatePageList(component, pageNumber);
    },

    generatePageList: function(component, pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if (totalPages > 1) {
            if (totalPages <= 10) {
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
        component.set("v.isSearching", false);
        
        if (component.get('v.state') === 'Init') {
            component.set('v.state', 'Idle');
        }
    },

    execCreateOrder: function(component, shipmentIds, caseNumbers) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionCreateOrder = component.get('c.createOrder');

            actionCreateOrder.setParams({
                'jsonShipmentIds': JSON.stringify(shipmentIds),
                'jsonCaseNumbers': JSON.stringify(caseNumbers),
                'customerNo': component.get('v.customerNo')
            });

            actionCreateOrder.setCallback(this, function(response) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal).order);
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionCreateOrder);
        }));
    },
        
    updateContactLastManifestDate: function(component) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionUpdateFreightContact = component.get('c.updateFreightContact');

            actionUpdateFreightContact.setParams({
                contactId: component.get("v.contactId")
            });

            actionUpdateFreightContact.setCallback(this, function(response) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal));
                    component.set('v.allowedManifest', false);
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionUpdateFreightContact);
        }));
    },

    execGetOrder: function(component, orderId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionGetOrder = component.get('c.getOrder');

            actionGetOrder.setParams({
                'orderId': orderId
            });

            actionGetOrder.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal));
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionGetOrder);
        }));
    },

    execGetShipment: function(component, shipmentId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionGetShipment = component.get('c.getShipment');

            actionGetShipment.setParams({
                'shipmentId': shipmentId
            });

            actionGetShipment.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal));
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionGetShipment);
        }));
    },

    execDeleteShipment: function(component, caseId, shipmentId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionDeleteShipment = component.get('c.deleteShipment');

            actionDeleteShipment.setParams({
                'caseId': caseId,
                'shipmentId': shipmentId
            });

            actionDeleteShipment.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve();
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionDeleteShipment);
        }));
    },

    execUpdateCaseFreight: function(component, caseRec, isCaseUpdated) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            if (!isCaseUpdated) {
                resolve();
            } else {
                var actionUpdateCaseFreight = component.get('c.updateCaseFreight');

                actionUpdateCaseFreight.setParams({
                    caseJson: JSON.stringify(caseRec)
                });

                actionUpdateCaseFreight.setCallback(this, function( response ) {
                    var retVal = response.getReturnValue();
                    var state = response.getState();
                    var err_response = response.getError();

                    if (state === 'SUCCESS' && retVal) {
                        resolve(JSON.parse(retVal));
                    } else {
                        reject(JSON.parse(err_response[0].message));
                    }
                });

                $A.enqueueAction(actionUpdateCaseFreight);
            }
        }));
    },

    execCreateShipment: function(component, caseRec) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionCreateShipment = component.get('c.createShipment');

            actionCreateShipment.setParams({
                caseJson: JSON.stringify(caseRec)
            });

            actionCreateShipment.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve([ caseRec, retVal ]);
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionCreateShipment);
        }));
    },

    execCreateLabel: function(component, caseRec, shipmentId, labelFormat) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionCreateLabel = component.get('c.createLabel');

            actionCreateLabel.setParams({
                caseJson: JSON.stringify(caseRec),
                shipmentId: shipmentId,
                format: labelFormat
            });

            actionCreateLabel.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    var parsedRetVal = JSON.parse(retVal);

                    resolve([caseRec, parsedRetVal[0].request_id]);
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionCreateLabel);
        }));
    },

    execGetLabel: function(component, caseRec, requestId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionGetLabel = component.get('c.getLabel');

            actionGetLabel.setParams({
                caseJson: JSON.stringify(caseRec), 
                requestId: requestId
            });
            
            actionGetLabel.setCallback(this, function( response ) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    var parsedRetVal = JSON.parse(retVal);

                    if (parsedRetVal.status === 'AVAILABLE') {
                        let getLabelMaxTimeout = component.get('v.getLabelMaxTimeout');
                        if (getLabelMaxTimeout) {
                            clearTimeout(getLabelMaxTimeout);
                        } 

                        resolve(parsedRetVal);
                    } else {
                        if (component.get('v.isTimeoutReachedMax')) {
                            reject({
                                errors: [
                                    {
                                        title: 'Error while generating label.',
                                        message: 'Reached maximum timeout. Please contact administrator.'
                                    }
                                ]
                            });
                        } else {
                            let getLabelTimeout = component.get('v.getLabelTimeout');
                            if (getLabelTimeout) {
                                clearTimeout(getLabelTimeout);
                            }

                            getLabelTimeout = window.setTimeout(
                                $A.getCallback(() => {
                                    if (!component.get('v.isTimeoutReachedMax')) {
                                        var self = this;
                                        resolve(self.execGetLabel(component, caseRec, requestId));
                                    } else {
                                        reject({
                                            errors: [
                                                {
                                                    title: 'Error while generating label.',
                                                    message: 'Reached maximum timeout. Please contact administrator.'
                                                }
                                            ]
                                        });
                                    }
                                    
                                    component.set('v.getLabelTimeout', null);
                                }),
                                3000
                            );

                            component.set('v.getLabelTimeout', getLabelTimeout);
                        }
                    }
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionGetLabel);
        }));
    },

    execUpdateShipment: function(component, caseRec, shipmentId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionUpdateShipment = component.get('c.updateShipment');

            actionUpdateShipment.setParams({
                caseJson: JSON.stringify(caseRec),
                shipmentId: shipmentId
            });

            actionUpdateShipment.setCallback(this, function( response ) {
                var state = response.getState();
                var err_response = response.getError();

                if (state === 'SUCCESS') {
                    resolve();
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionUpdateShipment);
        }));
    },
        
    execGetDGForm: function(component, caseRec, shipmentId) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            var actionGetDGForm = component.get('c.getDangerousGoodsForm');

            actionGetDGForm.setParams({
                caseJson: JSON.stringify(caseRec), 
                shipmentId: shipmentId
            });

            actionGetDGForm.setCallback(this, function(response) {
                var state = response.getState();
                var retVal = response.getReturnValue();
                var err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal));
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionGetDGForm);
        }));
    },

    execCreateAdhocPickup: function(component, shipmentIds, caseNumbers, adhocDetails) {
        return new Promise($A.getCallback(( resolve, reject ) => {
            let actionCreateAdhocPickup = component.get('c.createAdhocPickup');
            
            actionCreateAdhocPickup.setParams({
                'jsonShipmentIds': JSON.stringify(shipmentIds),
                'jsonCaseNumbers': JSON.stringify(caseNumbers),
                'jsonAdhocDets': JSON.stringify(adhocDetails)
            });

            actionCreateAdhocPickup.setCallback(this, function( response ) {
                let state = response.getState();
                let retVal = response.getReturnValue();
                let err_response = response.getError();

                if (state === 'SUCCESS' && retVal) {
                    resolve(JSON.parse(retVal).adhoc_pickups);
                    this.updateContactLastManifestDate(component);
                } else {
                    reject(JSON.parse(err_response[0].message));
                }
            });

            $A.enqueueAction(actionCreateAdhocPickup);
        }));
    },

    showModal: function(component, header, content, footer, cssClass, closeCallback) {
        component.find('overlayLib').showCustomModal({
            header: header,
            body: content, 
            footer: footer,
            showCloseButton: true,
            cssClass: cssClass,
            closeCallback: closeCallback
        });
    },
    
    handleShowToast : function(component, variant, title, message, mode) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    },

    removeLocHash: function() {
        var noHashURL = window.location.href.replace(/#.*$/, '');
        window.history.replaceState('', document.title, noHashURL);
    },

    handleErrors: function(component, err_response, handleShowToast) {
        if (err_response.errors) {
            err_response.errors.forEach( el => {
                handleShowToast(component, 'error', el.title, el.message, 'pester');
            });
        } else if (Array.isArray(err_response)) {
            err_response.forEach( el => {
                handleShowToast(component, 'error', el.message, '', 'pester');
            });
        } else {
            handleShowToast(component, 'error', 'An unknown error has occured. Please contact your administrator.', '', 'pester');
        }
        
    },

    startGetLabelTimeout: function(component) {
        component.set('v.isTimeoutReachedMax', false);

        // Cancel previous timeout if any
        let getLabelMaxTimeout = component.get('v.getLabelMaxTimeout');
        if (getLabelMaxTimeout) {
            clearTimeout(getLabelMaxTimeout);
        }    
        // Set new timeout
        getLabelMaxTimeout = window.setTimeout(
            $A.getCallback(() => {
                component.set('v.isTimeoutReachedMax', true);
                
                // Clear timeout
                component.set('v.getLabelMaxTimeout', null);
            }),
            30000 // Wait for 30000/30secs before sending search request
        );

        component.set('v.getLabelMaxTimeout', getLabelMaxTimeout);
    },

    toggleSpinnerLabel: function(component, labels) {
        labels.forEach( label => {
            $A.util.toggleClass(component.find('mySpinner'), label);
        });
    },

    populateLinksAndValidateBtns: function(component, caseItem) {
        if (caseItem.Shipment_Id__c) {
            caseItem.shipment_link = `/ttiservice/s/freight-management#shipment=${caseItem.Shipment_Id__c}`;
            caseItem.track_link = component.get('v.trackUrlStarTrack').replace('<shipment_id>', caseItem.Shipment_Id__c);
            
            caseItem.btnCreateShipmentDisabled = true;  

            caseItem.btnUpdateShipmentDisabled = false;
            caseItem.btnPrintLabelDisabled = false;
            caseItem.btnDeleteShipmentDisabled = false;
            caseItem.btnPrintDGFormDisabled = caseItem.Product_Name__r.Dangerous_Goods_Text__c !== 'CLASS9';
        } else {                    
            caseItem.shipment_link = '';
            caseItem.track_link = '';

            caseItem.btnCreateShipmentDisabled = false; 
            caseItem.btnUpdateShipmentDisabled = true;
            caseItem.btnPrintLabelDisabled = true;
            caseItem.btnDeleteShipmentDisabled = true;
            caseItem.btnPrintDGFormDisabled = true;
        }
        
        if (caseItem.OrderId__c) {
            caseItem.order_link = `/ttiservice/s/freight-management#order=${caseItem.OrderId__c}`;

            caseItem.btnDeleteShipmentDisabled = true;   
            caseItem.btnUpdateShipmentDisabled = true;
        } else {
            caseItem.order_link = '';
        }
    },

    generateCreateShipmentCmps: function(component, country) {
        return [
            ["c:TTI_CreateShipment",{
                'aura:id': 'createShipmentBody',
                serviceReqCase: component.getReference('v.selectedCase'),
                countryRestrict: country,
                isCaseUpdated: component.getReference('v.isCaseUpdated'),
                isChangedToPickup: component.getReference('v.isChangedToPickup'),
                hasFormError: component.getReference('v.hasFormError')
            }],
            ["c:TTI_CreateShipmentFooter",{
                'aura:id': 'createShipmentFooter',
                execCreateShipment: component.getReference('v.isBookFreightBtnClicked'),
                labelFormat: component.getReference('v.labelFormat'),
                serviceReqCase: component.getReference('v.selectedCase'),
                isCaseUpdated: component.getReference('v.isCaseUpdated'),
                isChangedToPickup: component.getReference('v.isChangedToPickup'),
                hasFormError: component.getReference('v.hasFormError')
            }]
        ];
    },

    getCountryByCourier: function(component, helper, claim) {
        const {
            TTI_Freight_Out_Courier__c: courier, 
            CaseNumber: caseNumber
        } = claim;

        if (courier === 'StarTrack') {
            return 'au';
        } else if (courier === 'Courier Post') {
            return 'nz';
        } else {
            helper.handleShowToast(component, 'info', `${caseNumber} does not have Courier.`, '', 'pester');
        }
    },

    getTimeOptions: function() {
        const tmpDate = new Date(2021, 0, 1);
        let timeOptions = [];

        while (tmpDate.getDate() === 1) {
            const time = {};
            // set locale to US English to display time in a 12-hour format with AM/PM
            time["label"] = tmpDate.toLocaleTimeString(
                                        'en-US', {
                                            hour: "numeric",
                                            minute: "numeric"
                                        }
                                    );
            // set locale to British English to store time in 24-hour format without AM/PM
            time["value"] = tmpDate.toLocaleTimeString('en-GB') +'.000';
            // increment time in 30 minute intervals
            tmpDate.setMinutes(tmpDate.getMinutes() + 30);
            timeOptions.push(time); 
        }

        return timeOptions;
    },

    validateAdhocForm: function(component) {
        return component.find('adhocFields').reduce(function(validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    },

    checkAddressIsModified: function(component, caseRec) {
        if (caseRec.TTI_Customer_Delivery_Method__c == 'Deliver'
                && caseRec.Retailer_Account__c
                && (caseRec.Retailer_Account__r.Delivery_Suburb__c !== caseRec.TTI_Freight_Out_Delivery_Suburb__c
                    || caseRec.Retailer_Account__r.Delivery_Postcode__c !== caseRec.TTI_Freight_Out_Delivery_Postcode__c
                    || caseRec.Retailer_Account__r.Delivery_State__c !== caseRec.TTI_Freight_Out_Delivery_State__c
                    || caseRec.Retailer_Account__r.Delivery_Street__c !== caseRec.TTI_Freight_Out_Delivery_Address__c
                    || caseRec.Retailer_Account__r.Delivery_Country__c !== caseRec.TTI_Freight_Out_Delivery_Country__c)) {
            caseRec.Freight_Out_Delivery_Address_Modified__c = true;
            component.set("v.isCaseUpdated", true);
        }
    },

    setAdhocPickupDefaultValues: function(component, timeOptions) {
        const start = timeOptions.findIndex(time => (time.label === "2:00 PM"));
        const end = timeOptions.findIndex(time => (time.label === "5:30 PM"));
        const today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.timeOptions", timeOptions.slice(start,end));
        
        let adhocFields = component.find("adhocFields");
        let adhocDetails = component.get('v.adhocDetails') || {};

        Object.keys(adhocFields).forEach(key => {
            let fieldName = adhocFields[key].get("v.name");
            if (fieldName === "Freight_Out_Manifest_Requested_Date__c") {
                adhocFields[key].set("v.value", today);
                adhocDetails[fieldName] = today;
            } else {
                adhocDetails[fieldName] = adhocFields[key].get("v.value");
            }
        });
        component.set('v.adhocDetails', adhocDetails);
    },

    getServiceAgentLocalTime: function(component) {
        return new Date().toLocaleTimeString(
            'en-GB', { 
                timeZone: component.get("v.serviceAgentTimeZone"), 
                hour: '2-digit'
            }
         );
    },

    clearSpinnerLabels: function(component, labels) {
        labels.forEach(label => {
            if ($A.util.hasClass(component.find('mySpinner'), label)) {
                $A.util.removeClass(component.find('mySpinner'), label);
            }
        });
    }
})