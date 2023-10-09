/**
 * @File Name          : TTI_FreightManagementController.js
 * @Description        :
 * @Author             : Francis Nasalita
 * @Group              :
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 30/08/2019, 8:39:06 am
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author            Modification
 *==============================================================================
 * 1.0    31/07/2019, 2:26:48 pm   Francis Nasalita     Initial Version
 **/
({
    doInit: function (component, event, helper) {
        component.set("v.state", "Init");

        helper
            .fetchUserData(component)
            .then((response) => {
                if (response) {
                    let {
                        allowedDelivery,
                        customerNo,
                        allowedManifest,
                    } = response;

                    component.set("v.allowedDelivery", allowedDelivery);
                    component.set("v.customerNo", customerNo);
                    component.set("v.allowedManifest", allowedManifest);

                    if (allowedDelivery) {
                        helper.initializeColumns(component);
                        component.set("v.state", "Idle");
                        component.handleGetLatestClaims();
                    }
                }
            })

            .catch((err_response) => {
                helper.handleShowToast(
                    component,
                    "error",
                    component.get("v.genericError"),
                    `${err_response}`,
                    "sticky"
                );
            });
    },

    handleRowAction: function (component, event, helper) {
        let [action, recordId] = event.getParam("value").split(":");
        let caseRec = component.get("v.allDataRetrieved").filter((row) => {
            return row.Id === recordId;
        })[0];
        component.set("v.selectedCase", caseRec);

        let caseId = caseRec.Id;
        let shipmentId = caseRec.Shipment_Id__c;
        let requestId = caseRec.Label_Request_Id__c;
        const country = helper.getCountryByCourier(component, helper, caseRec);
        const createShipmentCmps = helper.generateCreateShipmentCmps(
            component,
            country
        );

        let allCase = component.get("v.allDataRetrieved");

        switch (action) {
            case "create_shipment":
                var componentsCallback = (content) => {
                    var modalHeader = "Book Freight " + caseRec.CaseNumber;
                    var modalCSSClass = "slds-modal_medium";
                    var modalCloseCallback = () => {
                        var isBookFreightBtnClicked = component.get(
                            "v.isBookFreightBtnClicked"
                        );
                        var isCaseUpdated = component.get("v.isCaseUpdated");
                        var selectedCase = component.get("v.selectedCase");
                        helper.checkAddressIsModified(component, selectedCase);

                        let labelFormat = component.get("v.labelFormat");
                        let isChangedToPickup = component.get(
                            "v.isChangedToPickup"
                        );

                        if (isBookFreightBtnClicked && selectedCase) {
                            component.set("v.state", "Processing");
                            helper.toggleSpinnerLabel(component, [
                                "stateCreateShipment",
                            ]);

                            helper
                                .execUpdateCaseFreight(
                                    component,
                                    selectedCase,
                                    isCaseUpdated
                                )
                                .then(
                                    $A.getCallback(() => {
                                        return helper.execCreateShipment(
                                            component,
                                            selectedCase
                                        );
                                    })
                                )
                                .then(
                                    $A.getCallback((response) => {
                                        [selectedCase, shipmentId] = response;

                                        component.set(
                                            "v.allDataRetrieved",
                                            allCase.map((caseItem) => {
                                                if (caseItem.Id === caseId) {
                                                    caseItem.Shipment_Id__c = shipmentId;
                                                    helper.populateLinksAndValidateBtns(
                                                        component,
                                                        caseItem
                                                    );
                                                }
                                                return caseItem;
                                            })
                                        );

                                        helper.toggleSpinnerLabel(component, [
                                            "stateCreateShipment",
                                            "stateCreateLabel",
                                        ]);
                                        return helper.execCreateLabel(
                                            component,
                                            selectedCase,
                                            shipmentId,
                                            labelFormat
                                        );
                                    })
                                )
                                .then(
                                    $A.getCallback((response) => {
                                        [selectedCase, requestId] = response;

                                        helper.startGetLabelTimeout(component);
                                        helper.toggleSpinnerLabel(component, [
                                            "stateCreateLabel",
                                            "stateGetLabel",
                                        ]);
                                        return helper.execGetLabel(
                                            component,
                                            selectedCase,
                                            requestId
                                        );
                                    })
                                )
                                .then(
                                    $A.getCallback((response) => {
                                        component.set(
                                            "v.allDataRetrieved",
                                            allCase.map((caseItem) => {
                                                if (caseItem.Id === caseId) {
                                                    caseItem.Label_Url__c =
                                                        response.url;
                                                    helper.populateLinksAndValidateBtns(
                                                        component,
                                                        caseItem
                                                    );
                                                }
                                                return caseItem;
                                            })
                                        );
                                        component.handleGetLatestClaims();
                                        helper.handleShowToast(
                                            component,
                                            "success",
                                            "Success",
                                            $A.get(
                                                "$Label.c.Freight_Shipment_Created"
                                            ),
                                            "dismissable"
                                        );

                                        helper.toggleSpinnerLabel(component, [
                                            "stateGetLabel",
                                        ]);
                                        component.set("v.state", "Idle");
                                    })
                                )
                                .catch(
                                    $A.getCallback((err_response) => {
                                        helper.handleErrors(
                                            component,
                                            err_response,
                                            helper.handleShowToast
                                        );
                                        component.set("v.state", "Idle");
                                        helper.clearSpinnerLabels(component, [
                                            "stateCreateShipment",
                                            "stateCreateLabel",
                                            "stateGetLabel"
                                        ]);
                                    })
                                );
                        } else if (isChangedToPickup && isCaseUpdated) {
                            selectedCase.Freight_Out_Delivery_Address_Modified__c = false;
                            component.handleUpdateCaseFreight(
                                selectedCase,
                                isCaseUpdated,
                                isChangedToPickup
                            );
                        } else {
                            component.handleGetLatestClaims();
                            component.set("v.state", "Idle");
                        }

                        component.set("v.isBookFreightBtnClicked", false);
                        component.set("v.isCaseUpdated", false);
                        component.set("v.isChangedToPickup", false);
                        component.set("v.selectedCase", null);
                    };

                    helper.showModal(
                        component,
                        modalHeader,
                        content[0],
                        content[1],
                        modalCSSClass,
                        modalCloseCallback
                    );
                };

                $A.createComponents(createShipmentCmps, componentsCallback);
                break;
            case "update_shipment":
                var componentsCallback = (content, status, err_message) => {
                    var modalHeader = "Update Freight " + caseRec.CaseNumber;
                    var modalCSSClass = "slds-modal_medium";
                    var modalCloseCallback = () => {
                        var isBookFreightBtnClicked = component.get(
                            "v.isBookFreightBtnClicked"
                        );
                        var isCaseUpdated = component.get("v.isCaseUpdated");
                        var selectedCase = component.get("v.selectedCase");
                        let labelFormat = component.get("v.labelFormat");
                        let isChangedToPickup = component.get(
                            "v.isChangedToPickup"
                        );

                        helper.checkAddressIsModified(component, selectedCase);

                        if (isBookFreightBtnClicked && selectedCase) {
                            component.set("v.state", "Processing");
                            helper.toggleSpinnerLabel(component, [
                                "stateUpdateShipment",
                            ]);

                            helper
                                .execUpdateCaseFreight(
                                    component,
                                    selectedCase,
                                    isCaseUpdated
                                )
                                .then(
                                    $A.getCallback((newCase) => {
                                        selectedCase = newCase;

                                        if (isCaseUpdated) {
                                            return helper.execUpdateShipment(
                                                component,
                                                selectedCase,
                                                shipmentId
                                            );
                                        } else {
                                            helper.handleShowToast(
                                                component,
                                                "error",
                                                "There no changes made on the freight",
                                                "",
                                                "pester"
                                            );
                                            component.set("v.state", "Idle");
                                        }
                                    })
                                )
                                .then(
                                    $A.getCallback(() => {
                                        helper.toggleSpinnerLabel(component, [
                                            "stateUpdateShipment",
                                            "stateCreateLabel",
                                        ]);
                                        return helper.execCreateLabel(
                                            component,
                                            selectedCase,
                                            shipmentId,
                                            labelFormat
                                        );
                                    })
                                )
                                .then(
                                    $A.getCallback(([newCase, requestId]) => {
                                        helper.toggleSpinnerLabel(component, [
                                            "stateCreateLabel",
                                            "stateGetLabel",
                                        ]);
                                        selectedCase = newCase;

                                        helper.startGetLabelTimeout(component);
                                        return helper.execGetLabel(
                                            component,
                                            selectedCase,
                                            requestId
                                        );
                                    })
                                )
                                .then(
                                    $A.getCallback((response) => {
                                        if (response) {
                                            component.set(
                                                "v.allDataRetrieved",
                                                allCase.map((caseItem) => {
                                                    if (
                                                        caseItem.Id === caseId
                                                    ) {
                                                        caseItem.Label_Url__c =
                                                            response.url;
                                                    }
                                                    return caseItem;
                                                })
                                            );
                                            component.handleGetLatestClaims();
                                            helper.toggleSpinnerLabel(
                                                component,
                                                ["stateGetLabel"]
                                            );
                                            helper.handleShowToast(
                                                component,
                                                "success",
                                                "Success",
                                                $A.get(
                                                    "$Label.c.Freight_Shipment_Updated"
                                                ),
                                                "dismissable"
                                            );
                                            component.set("v.state", "Idle");
                                        }
                                    })
                                )
                                .catch(
                                    $A.getCallback((err_response) => {
                                        helper.handleErrors(
                                            component,
                                            err_response,
                                            helper.handleShowToast
                                        );
                                        component.set("v.state", "Idle");
                                        helper.clearSpinnerLabels(component, [
                                            "stateUpdateShipment",
                                            "stateCreateLabel",
                                            "stateGetLabel"
                                        ]);
                                    })
                                );
                        } else if (isChangedToPickup && isCaseUpdated) {
                            component.handleUpdateCaseFreight(
                                selectedCase,
                                isCaseUpdated,
                                isChangedToPickup
                            );
                        } else {
                            component.handleGetLatestClaims();
                            component.set("v.state", "Idle");
                        }

                        component.set("v.isBookFreightBtnClicked", false);
                        component.set("v.isCaseUpdated", false);
                        component.set("v.isChangedToPickup", false);
                        component.set("v.selectedCase", null);
                    };

                    helper.showModal(
                        component,
                        modalHeader,
                        content[0],
                        content[1],
                        modalCSSClass,
                        modalCloseCallback
                    );
                };

                $A.createComponents(createShipmentCmps, componentsCallback);
                break;
            case "print_label":
                if (caseRec.Label_Url__c) {
                    window.open(caseRec.Label_Url__c);
                } else {
                    component.set("v.state", "Processing");
                    helper.toggleSpinnerLabel(component, ["stateCreateLabel"]);
                    let labelFormat = component.get("v.labelFormat");

                    return helper
                        .execCreateLabel(
                            component,
                            caseRec,
                            shipmentId,
                            labelFormat
                        )
                        .then(
                            $A.getCallback((response) => {
                                [caseRec, requestId] = response;

                                helper.toggleSpinnerLabel(component, [
                                    "stateCreateLabel",
                                    "stateGetLabel",
                                ]);

                                helper.startGetLabelTimeout(component);
                                return helper.execGetLabel(
                                    component,
                                    caseRec,
                                    requestId
                                );
                            })
                        )
                        .then(
                            $A.getCallback((response) => {
                                let labelUrl = response.url;
                                component.set(
                                    "v.allDataRetrieved",
                                    allCase.map((caseItem) => {
                                        if (caseItem.Id === caseId) {
                                            caseItem.Label_Url__c = labelUrl;
                                        }
                                        return caseItem;
                                    })
                                );

                                window.open(labelUrl);

                                helper.toggleSpinnerLabel(component, [
                                    "stateGetLabel",
                                ]);
                                component.set("v.state", "Idle");
                            })
                        )
                        .catch(
                            $A.getCallback((err_response) => {
                                helper.handleErrors(
                                    component,
                                    err_response,
                                    helper.handleShowToast
                                );
                                component.set("v.state", "Idle");
                                helper.clearSpinnerLabels(component, [
                                    "stateCreateLabel",
                                    "stateGetLabel"
                                ]);
                            })
                        );
                }
                break;
            case "print_dg_form":
                component.set("v.state", "Processing");
                helper.toggleSpinnerLabel(component, ["stateGetDGForm"]);
                let selectedCase = component.get("v.selectedCase");
                helper
                    .execGetDGForm(component, selectedCase, shipmentId)
                    .then(
                        $A.getCallback((pdfData) => {
                            component.set("v.dangerousGoodsContent", pdfData);
                            component.set("v.showDGForm", true);

                            component.set("v.state", "Idle");
                            helper.toggleSpinnerLabel(component, [
                                "stateGetDGForm"
                            ]);
                        })
                    )
                    .catch(
                        $A.getCallback((err_response) => {
                            helper.handleErrors(
                                component,
                                err_response,
                                helper.handleShowToast
                            );
                            component.set("v.state", "Idle");
                            helper.toggleSpinnerLabel(component, [
                                "stateGetDGForm"
                            ]);
                        })
                    );
                break;
            case "delete_shipment":
                component.set("v.state", "Processing");
                helper.toggleSpinnerLabel(component, ["stateDeleteShipment"]);

                helper
                    .execDeleteShipment(component, caseId, shipmentId)
                    .then(
                        $A.getCallback(() => {
                            component.set(
                                "v.allDataRetrieved",
                                allCase.map((caseItem) => {
                                    if (caseItem.Id === caseId) {
                                        caseItem.Shipment_Id__c = "";
                                        caseItem.Label_Url__c = "";
                                        helper.populateLinksAndValidateBtns(
                                            component,
                                            caseItem
                                        );
                                    }
                                    return caseItem;
                                })
                            );
                            component.handleGetLatestClaims();
                            helper.toggleSpinnerLabel(component, [
                                "stateDeleteShipment",
                            ]);
                            helper.handleShowToast(
                                component,
                                "success",
                                "Success",
                                $A.get("$Label.c.Freight_Shipment_Deleted"),
                                "dismissable"
                            );
                            component.set("v.state", "Idle");
                        })
                    )
                    .catch(
                        $A.getCallback((err_response) => {
                            helper.handleErrors(
                                component,
                                err_response,
                                helper.handleShowToast
                            );
                            helper.toggleSpinnerLabel(component, [
                                "stateDeleteShipment",
                            ]);
                            component.set("v.state", "Idle");
                        })
                    );
                break;
            default:
                component.set("v.state", "Idle");
                break;
        }
    },

    handleStateChange: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        const state = component.get("v.state");

        component.set("v.isInit", state === "Init" ? true : false);
    },

    // PAGINATION Methods
    onNext: function (component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.buildData(component, helper);
    },

    onPrev: function (component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.buildData(component, helper);
    },

    handlePageClick: function (component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },

    onFirst: function (component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },

    onLast: function (component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    // PAGINATION Methods

    handleSearchTextChange: function (component, event, helper) {
        const searchString = component
            .find("enter-search")
            .get("v.value")
            .trim();
        const isSearchStringEmpty = $A.util.isEmpty(searchString);
        const fields = component.get("v.columns");

        if (!isSearchStringEmpty && searchString.length > 2) {
            component.set("v.isSearching", true);

            // Cancel previous timeout if any
            let searchTimeout = component.get("v.searchTimeout");
            if (searchTimeout) {
                clearTimeout(searchTimeout);
            }
            // Set new timeout
            searchTimeout = window.setTimeout(
                $A.getCallback(() => {
                    component.set(
                        "v.allDataRetrieved",
                        component.get("v.rawData").filter((caseItem) => {
                            const searchStringExist = fields
                                .filter((field) => {
                                    return (
                                        caseItem.hasOwnProperty(
                                            field.fieldName
                                        ) && field.isSearchable
                                    );
                                })
                                .reduce((searchStringExist, { fieldName }) => {
                                    return (
                                        caseItem[fieldName]
                                            .toString()
                                            .includes(searchString) ||
                                        searchStringExist
                                    );
                                }, false);

                            return searchStringExist;
                        })
                    );

                    // Clear timeout
                    component.set("v.searchTimeout", null);
                }),
                500 // Wait for 500ms/.5sec before sending search request
            );

            component.set("v.searchTimeout", searchTimeout);
        } else if (isSearchStringEmpty) {
            component.set(
                "v.allDataRetrieved",
                component.get("v.rawData").slice(0)
            );
        }
    },

    showAdhocModal: function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        component.set('v.showAdhocRequest', true);
        helper.setAdhocPickupDefaultValues(component, helper.getTimeOptions());
    },

    closeModal: function(component, event, helper) {
        component.set('v.showAdhocRequest', false);
    },

    handleAdhocInputChange: function(component, event, helper) {
        let fieldname = event.getSource().get('v.name');
        let value = event.getSource().get('v.value');

        let adhocDetails = component.get('v.adhocDetails') || {};
        adhocDetails[fieldname] = value;
        component.set('v.adhocDetails', adhocDetails);
    },

    execCreateOrder: function(component, event, helper) {
        if (helper.validateAdhocForm(component)) {
            if (!component.get('v.data')) {
                helper.handleShowToast(
                    component, 
                    'error', 
                    'Bad Request', 
                    'An order requires a shipment or a pickup', 
                    'pester'
                );
                component.set('v.state', 'Idle');
            } else {
                component.set('v.showAdhocRequest', false);
                component.set('v.state', 'Processing');
                helper.toggleSpinnerLabel(component, ['stateCreateManifest']);

                const data = component
                    .get('v.data')
                    .filter(caseItem => caseItem.isSelected);

                const shipmentIds = data.map(caseItem => caseItem.Shipment_Id__c);
                const caseNumbers = data.map(caseItem => caseItem.CaseNumber);
                const adhocDetails = component.get('v.adhocDetails');
                let response;

                helper.execCreateOrder(component, shipmentIds, caseNumbers)
                .then(
                    $A.getCallback((order) => {
                        response = order;
                        adhocDetails["Freight_Out_Manifest_Order_Number__c"] = order.order_id;
                        component.set('v.adhocDetails', adhocDetails);
                        return helper.execCreateAdhocPickup(component, shipmentIds, caseNumbers, adhocDetails);
                    })
                )
                .then(
                    $A.getCallback((adhoc_pickups) => {
                        component.set('v.allDataRetrieved', 
                            component.get('v.allDataRetrieved').map( caseItem => {
                                if (shipmentIds.includes(caseItem.Shipment_Id__c)) {
                                    caseItem.isSelected = false;
                                    caseItem.OrderId__c = response.order_id;
                                    caseItem.Freight_Out_Manifest_Order_Number__c = response.order_id;
                                    caseItem.Freight_Out_Booking_ID__c = adhoc_pickups[0].booking_id;
                                }
                                helper.populateLinksAndValidateBtns(component, caseItem);
                                return caseItem;
                            })
                        );
                        helper.toggleSpinnerLabel(component, [
                            "stateCreateManifest",
                        ]);
                        helper.handleShowToast(
                            component,
                            "success",
                            "Success",
                            $A.get("$Label.c.Freight_Manifest_Created"),
                            "dismissable"
                        );
                        component.handleGetLatestClaims();
                        component.set("v.state", "Idle");
                    })
                )
                .catch(err_response => {
                    helper.handleErrors(
                        component, 
                        err_response, 
                        helper.handleShowToast
                    );
                    helper.toggleSpinnerLabel(component, [
                        "stateCreateManifest"
                    ]);
                    component.set("v.state", "Idle");
                })
            }
        }
    },
    
    handleShowConfirmManifestDialog: function (component, event, helper) {
        if (helper.getServiceAgentLocalTime(component) >= component.get("v.pickupCutOffHour")) {
            component.set("v.isPastCutOffHour", true);
            component.set("v.manifestDialogHeader","Same day pickup is no longer available today");
            component.set("v.manifestDialogContent","Please try again tomorrow before 1pm");
            component.set("v.manifestDialogNoBtn","OK");
        } else {
            component.set("v.isPastCutOffHour", false);
            component.set("v.manifestDialogHeader","Confirmation");
            component.set("v.manifestDialogContent","Please note: Only one manifest can be performed per day. Do you wish to continue?");
            component.set("v.manifestDialogNoBtn","No");
        }
        component.set("v.showConfirmDialog", true);
    },

    handleConfirmManifestDialogNo: function (component, event, helper) {
        component.set("v.showConfirmDialog", false);
    },

    locChanged: function (component, event, helper) {
        var [key, value] = event.getParam("token").split("=");

        switch (key) {
            case "order":
                component.set("v.state", "Processing");
                helper
                    .execGetOrder(component, value)
                    .then(
                        $A.getCallback((pdfData) => {
                            var cmpName = "c:pdfViewer";
                            var cmpAttributes = { pdfData: pdfData };
                            var cmpCallback = (content) => {
                                var modalHeader = null;
                                var modalCSSClass = "slds-modal_large";
                                var modalCloseCallback = () => {
                                    helper.removeLocHash();
                                    content.destroy();
                                };

                                helper.showModal(
                                    component,
                                    modalHeader,
                                    content,
                                    null,
                                    modalCSSClass,
                                    modalCloseCallback
                                );

                                component.set("v.state", "Idle");
                            };

                            $A.createComponent(
                                cmpName,
                                cmpAttributes,
                                cmpCallback
                            );
                        })
                    )
                    .catch(
                        $A.getCallback((err_response) => {
                            helper.handleErrors(
                                component,
                                err_response,
                                helper.handleShowToast
                            );
                            component.set("v.state", "Idle");
                        })
                    );
                break;
            case "shipment":
                component.set("v.state", "Processing");

                helper
                    .execGetShipment(component, value)
                    .then(
                        $A.getCallback((response) => {
                            var cmpName = "c:TTI_ShipmentDetails";
                            var cmpAttributes = {
                                shipment: response.shipments[0],
                            };
                            var cmpCallback = (content) => {
                                var modalHeader = "Shipment Details";
                                var modalCSSClass = "slds-modal_medium";
                                var modalCloseCallback = () => {
                                    helper.removeLocHash();
                                    content.destroy();
                                };

                                helper.showModal(
                                    component,
                                    modalHeader,
                                    content,
                                    null,
                                    modalCSSClass,
                                    modalCloseCallback
                                );

                                component.set("v.state", "Idle");
                            };

                            $A.createComponent(
                                cmpName,
                                cmpAttributes,
                                cmpCallback
                            );
                        })
                    )
                    .catch(
                        $A.getCallback((err_response) => {
                            helper.handleErrors(
                                component,
                                err_response,
                                helper.handleShowToast
                            );
                            component.set("v.state", "Idle");
                        })
                    );
                break;
        }
    },

    handleUpdateRawData: function (component, event, helper) {
        helper.buildData(component, helper);
    },

    handleCheckboxChange: function (component, event, helper) {
        let headerCheckbox = component.find("headerCheckbox").getElement();
        let data = component.get("v.data");
        let selectedDataCount = data.filter((el) => el.isSelected).length;

        if (selectedDataCount > 0 && selectedDataCount !== data.length) {
            headerCheckbox.indeterminate = true;
        } else {
            headerCheckbox.indeterminate = false;
        }

        data.forEach((el) => {
            el.rowClass = el.isSelected
                ? "slds-hint-parent slds-is-selected"
                : "slds-hint-parent";
        });

        component.set("v.data", data);
    },

    handleHeaderCheckboxChange: function (component, event, helper) {
        if (event.currentTarget.checked) {
            component.set(
                "v.allDataRetrieved",
                component.get("v.data").map((caseRec) => {
                    caseRec.isSelected = true;
                    return caseRec;
                })
            );
        } else {
            component.set(
                "v.allDataRetrieved",
                component.get("v.data").map((caseRec) => {
                    caseRec.isSelected = false;
                    return caseRec;
                })
            );
        }
    },

    handleUpdateCaseFreight: function (component, event, helper) {
        const params = event.getParam("arguments");
        let genericError = component.get("v.genericError");
        if (params) {
            const selectedCase = params.selectedCase;
            let isCaseUpdated = params.isCaseUpdated;

            let isChangedToPickup = params.isChangedToPickup;
            component.set("v.state", "Processing");
            helper.toggleSpinnerLabel(component, ["stateUpdateDeliveryOption"]);

            helper
                .execUpdateCaseFreight(component, selectedCase, isCaseUpdated)

                .then(
                    $A.getCallback(() => {
                        if (selectedCase.Shipment_Id__c) {
                            helper.execDeleteShipment(
                                component,
                                selectedCase.Id,
                                selectedCase.Shipment_Id__c
                            );
                        }
                        helper.toggleSpinnerLabel(component, [
                            "stateUpdateDeliveryOption",
                        ]);
                        component.set("v.state", "Idle");
                        helper.handleShowToast(
                            component,
                            "success",
                            "Success",
                            $A.get(
                                "$Label.c.Freight_Delivery_Preference_Changed"
                            ),
                            "dismissable"
                        );
                        component.handleGetLatestClaims();
                    })
                )
                .catch((err_response) => {
                    helper.handleShowToast(
                        component,
                        "error",
                        genericError,
                        `${err_response}`,
                        "sticky"
                    );
                    helper.toggleSpinnerLabel(component, [
                        "stateUpdateDeliveryOption",
                    ]);
                    component.set("v.state", "Idle");
                });
        }
    },
    handleGetLatestClaims: function (component, event, helper) {
        component.set("v.state", "Processing");
        let genericError = component.get("v.genericError");

        helper
            .getCases(component)
            .then((response) => {
                if (response) {
                    response = response.map((caseItem) => {
                        caseItem.isSelected = false;
                        caseItem.CustomerName =
                            caseItem.TTI_Customer_Contact__r.Name;
                        caseItem.TTI_Closed_Datetime__c = new Date(
                            caseItem.TTI_Closed_Datetime__c
                        );
                        caseItem.AgentRef = caseItem.Contact.Name;
                        caseItem.case_link = `/ttiservice/s/searchclaim?claimNumber=${caseItem.CaseNumber}`;
                        caseItem.Freight_out_consignment_number__c =
                            caseItem.Freight_out_consignment_number__c;
                        caseItem.RetailerAccount =
                            caseItem.Retailer_Account__c ? caseItem.Retailer_Account__r.Name : null;

                        helper.populateLinksAndValidateBtns(
                            component,
                            caseItem
                        );
                        return caseItem;
                    });

                    component.set("v.rawData", response);
                    component.set("v.allDataRetrieved", response);

                    let totalPages, currentPage;
                    if (response.length > 0) {
                        totalPages = Math.ceil(
                            response.length / component.get("v.pageSize")
                        );
                        currentPage = 1;

                        if (totalPages > 1) {
                            component.set("v.showPagination", true);
                        }
                    } else {
                        totalPages = 0;
                        currentPage = 0;
                    }

                    component.set("v.currentPageNumber", currentPage);
                    component.set("v.noData", totalPages === 0);
                    component.set("v.totalPages", totalPages);
                    component.set(
                        "v.tableContainerClass",
                        response.length > 24 ? "setHeight" : "setMaxHeight"
                    );

                    component.set("v.state", "Idle");
                } else {
                    component.set("v.data", null);
                    component.set("v.showPagination", false);
                    component.set("v.currentPageNumber", 0);
                    component.set("v.totalPages", 0);
                    component.set("v.tableContainerClass", "setMaxHeight");
                    component.set("v.state", "Idle");
                }
            })
            .catch((err_response) => {
                helper.handleShowToast(
                    component,
                    "error",
                    genericError,
                    `${err_response}`,
                    "sticky"
                );
                component.set("v.state", "Idle");
            });
    },

    loadDGPDF: function(component) {
        const pdfData = component.get('v.dangerousGoodsContent');
        document.getElementsByClassName("pdfViewer")[0].children[0].contentWindow.postMessage(pdfData, '*');
        document.getElementsByClassName("pdfViewer")[0].children[0].focus();
    },

    closeDGFormModal: function(component) {
        component.set("v.showDGForm", false);
    }
});