({
    fireModalEvent: function(question, functionToRunObject) {
        var compEvent = $A.get("e.c:TTI_Confirmation_ModalEvent");
        var buttonNames = [];
        buttonNames.push('Yes');
        buttonNames.push('No');
        compEvent.setParams({
            "OpenModal": true,
            "question": question,
            "buttonNames": buttonNames,
            "functionToRunObject": functionToRunObject

        });
        compEvent.fire();
    },
    fireOkModalEvent: function(question, functionToRunObject) {
        var compEvent = $A.get("e.c:TTI_Confirmation_ModalEvent");
        var buttonNames = [];
        buttonNames.push('Okay');
        compEvent.setParams({
            "OpenModal": true,
            "question": question,
            "buttonNames": buttonNames,
            "functionToRunObject": functionToRunObject

        });
        compEvent.fire();
    },
    populateData: function(component, ServiceReqCase) {
        //new service milestone attribute object 
        var ServiceMilestoneAttribute = component.get("v.ServiceMilestoneAttribute");
        ServiceMilestoneAttribute = {};
        ServiceReqCase.Service_Request_Milestone__c == 'In Progress' ? ServiceMilestoneAttribute.InProgress = true : ServiceMilestoneAttribute.InProgress = false;
        ServiceReqCase.Service_Request_Milestone__c == 'New' ? ServiceMilestoneAttribute.New = true : ServiceMilestoneAttribute.New = false;
        ServiceReqCase.Service_Request_Milestone__c == 'Awaiting Approval' ? ServiceMilestoneAttribute.AwaitingApproval = true : ServiceMilestoneAttribute.AwaitingApproval = false;
        ServiceReqCase.Service_Request_Milestone__c == 'Invoice Awaiting Approval' ? ServiceMilestoneAttribute.AwaitingInvoiceApproval = true : ServiceMilestoneAttribute.AwaitingInvoiceApproval = false;
        ServiceReqCase.Service_Request_Milestone__c == 'Closed' ? ServiceMilestoneAttribute.Closed = true : ServiceMilestoneAttribute.Closed = false;
        ServiceReqCase.Service_Request_Milestone__c == 'Completed' ? ServiceMilestoneAttribute.Completed = true : ServiceMilestoneAttribute.Completed = false;
        component.set("v.ServiceMilestoneAttribute", ServiceMilestoneAttribute);
        //debugger;
        //check for retailer and customer information
        var hasRetailer = component.get("v.hasRetailer");
        var hasCustomer = component.get("v.hasCustomer");
        ServiceReqCase.Retailer_Account__c === undefined ? hasRetailer = false : hasRetailer = true;
        ServiceReqCase.TTI_Customer_Account__c === undefined ? hasCustomer = false : hasCustomer = true;
        if (hasCustomer && !hasRetailer) {
            ServiceReqCase.TTI_Quote_to_Customer__c = true;
        }
        if (hasRetailer) {
            ServiceReqCase.TTI_Quote_to_Retailer__c = true;
        }
        component.set("v.hasCustomer", hasCustomer);
        component.set("v.hasRetailer", hasRetailer);

        //populate Address
        var DeliveryAddress = component.get("v.DeliveryAddress");
        if (!$A.util.isUndefinedOrNull(ServiceReqCase.Retailer_Account__r)) {
            DeliveryAddress = ServiceReqCase.Retailer_Account__r.Delivery_Street__c +
                "  " + ServiceReqCase.Retailer_Account__r.Delivery_Suburb__c +
                "  " + ServiceReqCase.Retailer_Account__r.Delivery_State__c +
                "  " + ServiceReqCase.Retailer_Account__r.Delivery_Postcode__c +
                "  " + ServiceReqCase.Retailer_Account__r.Delivery_Country__c;
            component.set("v.DeliveryAddress", DeliveryAddress);
        }
        var FreightOutDeliveryAddress = component.get("v.FreightOutDeliveryAddress");
        if (!($A.util.isUndefinedOrNull(ServiceReqCase.TTI_Freight_Out_Delivery_Address__c) || $A.util.isEmpty(ServiceReqCase.TTI_Freight_Out_Delivery_Address__c))) {
            FreightOutDeliveryAddress = ServiceReqCase.TTI_Freight_Out_Delivery_Address__c;
        }
        if (!($A.util.isUndefinedOrNull(ServiceReqCase.TTI_Freight_Out_Delivery_Suburb__c) || $A.util.isEmpty(ServiceReqCase.TTI_Freight_Out_Delivery_Suburb__c))) {
            FreightOutDeliveryAddress = FreightOutDeliveryAddress + " , " + ServiceReqCase.TTI_Freight_Out_Delivery_Suburb__c;
        }
        if (!($A.util.isUndefinedOrNull(ServiceReqCase.TTI_Freight_Out_Delivery_Postcode__c) || $A.util.isEmpty(ServiceReqCase.TTI_Freight_Out_Delivery_Postcode__c))) {
            FreightOutDeliveryAddress = FreightOutDeliveryAddress + " , " + ServiceReqCase.TTI_Freight_Out_Delivery_Postcode__c;
        }
        if (!($A.util.isUndefinedOrNull(ServiceReqCase.TTI_Freight_Out_Delivery_State__c) || $A.util.isEmpty(ServiceReqCase.TTI_Freight_Out_Delivery_State__c))) {
            FreightOutDeliveryAddress = FreightOutDeliveryAddress + " , " + ServiceReqCase.TTI_Freight_Out_Delivery_State__c;
        }
        if (!($A.util.isUndefinedOrNull(ServiceReqCase.TTI_Freight_Out_Delivery_Country__c) || $A.util.isEmpty(ServiceReqCase.TTI_Freight_Out_Delivery_Country__c))) {
            FreightOutDeliveryAddress = FreightOutDeliveryAddress + " , " + ServiceReqCase.TTI_Freight_Out_Delivery_Country__c;
        }
        component.set("v.FreightOutDeliveryAddress", FreightOutDeliveryAddress);

        //Call Inner Components' Constructor
        var partsOrdered = component.find("PartsOrdered");
        var OrderPartsFromBill = component.find("OrderPartsFromBill");
        var TaskInfoTable = component.find("TaskInfoTable");
        var AssetInformation = component.find("AssetInformation");
        var ClaimCompletionDetails = component.find("ClaimCompletionDetails");
        var GoodWill = component.find("GoodWill");
        var NonWarrantyCharges = component.find("NonWarrantyCharges");

        partsOrdered != undefined ? partsOrdered.populatePartsOrdered() : '';
        OrderPartsFromBill != undefined ? OrderPartsFromBill.populateProdParts() : '';
        NonWarrantyCharges != undefined ? NonWarrantyCharges.populateNonWarrantyLineItems() : '';
        TaskInfoTable != undefined ? TaskInfoTable.populateTaskInfo() : '';
        ClaimCompletionDetails != undefined ? ClaimCompletionDetails.populateRepairType() : '';
        GoodWill != undefined ? GoodWill.GoodWillConstructor() : '';

    },
    checkAssignedToMe: function(component, ServiceReqCase) {

        var userType = component.get("v.userType");
        if (!$A.util.isUndefinedOrNull(ServiceReqCase.OwnerId) || !$A.util.isEmpty(ServiceReqCase.OwnerId)) {
            if (ServiceReqCase.OwnerId == userType.Id) {
                component.set("v.errorMessages", null);
                return true;
            } else {
                component.set("v.errorMessages", "You must assign the service request to yourself prior to saving the service request details");
                return false;
            }
        } else {
            component.set("v.errorMessages", "You must assign the service request to yourself prior to saving the service request details");
            return false;
        }

    },
    getSelectedPartsOrderedItem: function(component, selectedPartsOrdered) {
        var OrderPartsFromBill = component.find("OrderPartsFromBill");
        if (OrderPartsFromBill != null && OrderPartsFromBill != undefined) {
            var ProductPartsList = OrderPartsFromBill.get("v.ProductParts");
            var PartsOrderedSelectCheckboxList = OrderPartsFromBill.find("partsOrderedSelectCheckboxId");

            if (PartsOrderedSelectCheckboxList != undefined || PartsOrderedSelectCheckboxList != null) {
                if (PartsOrderedSelectCheckboxList != undefined && PartsOrderedSelectCheckboxList.length == undefined && PartsOrderedSelectCheckboxList.get("v.value") == true) {
                    selectedPartsOrdered.push(ProductPartsList[0]);
                } else {
                    for (var i = 0; i < PartsOrderedSelectCheckboxList.length; i++) {
                        if (PartsOrderedSelectCheckboxList[i].get("v.value")) {
                            selectedPartsOrdered.push(ProductPartsList[PartsOrderedSelectCheckboxList[i].get("v.labelClass")]);
                        }
                    }
                }
            }
        }

    },
    createServiceReqLineItemList: function(component, ListToInsertServiceReqLineItem, ServiceReqCase) {
        component.set("v.errorMessages", null);
        var userType = component.get("v.userType");
        var selectedPartsOrdered = [];
        this.getSelectedPartsOrderedItem(component, selectedPartsOrdered);
        for (var i = 0; i < selectedPartsOrdered.length; i++) {
            var ObjServiceReqLineItem = {};
            if (selectedPartsOrdered[i].Quantity__c > 0) {
                component.set("v.errorMessages", null);
                ObjServiceReqLineItem.Quantity__c = selectedPartsOrdered[i].Quantity__c;
            } else {
                component.set("v.isError", true);
                component.set("v.errorMessages", "All parts ordered must have a quantity > 0");
                return;
            }
            ObjServiceReqLineItem.sobjectType = 'Service_Request_Line_Item__c';
            ObjServiceReqLineItem.Service_Request_Number__c = ServiceReqCase.Id;
            ObjServiceReqLineItem.Order_Line_Type__c = 'Part';
            ObjServiceReqLineItem.Order_Line_Category__c = 'Bill of Materials';
            ObjServiceReqLineItem.Part_Number__c = selectedPartsOrdered[i].ProductPart__c;
            ObjServiceReqLineItem.SKU_Number__c = selectedPartsOrdered[i].ProductPart__r.ProductCode;
            ObjServiceReqLineItem.Line_Item_Description__c = selectedPartsOrdered[i].ProductPart__r.Description;
            if (userType.Account.Delivery_Country__c == 'Australia') {
                ObjServiceReqLineItem.Unit_Cost__c = selectedPartsOrdered[i].ProductPart__r.AU_Landed_Cost__c;
                ObjServiceReqLineItem.Unit_List_Price__c = selectedPartsOrdered[i].ProductPart__r.AU_ListPrice__c;

            } else {
                ObjServiceReqLineItem.Unit_Cost__c = selectedPartsOrdered[i].ProductPart__r.NZ_Landed_Cost__c;
                ObjServiceReqLineItem.Unit_List_Price__c = selectedPartsOrdered[i].ProductPart__r.NZ_ListPrice__c;
            }
            ObjServiceReqLineItem.Not_in_Stock__c = selectedPartsOrdered[i].NotInStock;
            ListToInsertServiceReqLineItem.push(ObjServiceReqLineItem);

        }
        var PartsOrderedNotListed = this.getPartsOrderedItemNotListed(component);
        if (PartsOrderedNotListed != null || PartsOrderedNotListed != undefined) {
            PartsOrderedNotListed = JSON.parse(JSON.stringify(PartsOrderedNotListed));
            for (var i = 0; i < PartsOrderedNotListed.length; i++) {
                if (PartsOrderedNotListed[i].Quantity__c <= 0) {
                    component.set("v.isError", true);
                    component.set("v.errorMessages", "All parts ordered must have a quantity > 0");
                    return;
                } else if (PartsOrderedNotListed[i].TTI_Reason__c == '' || PartsOrderedNotListed[i].TTI_Reason__c == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMessages", "Reason must be provided when inserting parts manually");
                    return;
                } else {
                    component.set("v.errorMessages", null);

                }
                PartsOrderedNotListed[i].sobjectType = 'Service_Request_Line_Item__c';
                PartsOrderedNotListed[i].Service_Request_Number__c = ServiceReqCase.Id;
                PartsOrderedNotListed[i].Order_Line_Type__c = 'Part';
                PartsOrderedNotListed[i].Order_Line_Category__c = 'Manual Entry';
                ListToInsertServiceReqLineItem.push(PartsOrderedNotListed[i]);

            }
        }
        var NonWarrantyLineItems = this.getNonWarrantyLineItems(component);
        if (NonWarrantyLineItems != null || NonWarrantyLineItems != undefined) {
            NonWarrantyLineItems = JSON.parse(JSON.stringify(NonWarrantyLineItems));
            for (var i = 0; i < NonWarrantyLineItems.length; i++) {
                if (NonWarrantyLineItems[i].Quantity__c <= 0) {
                    component.set("v.isError", true);
                    component.set("v.errorMessages", "All parts ordered must have a quantity > 0");
                    return;
                } else {
                    component.set("v.errorMessages", null);

                }
                NonWarrantyLineItems[i].sobjectType = 'Service_Request_Line_Item__c';
                NonWarrantyLineItems[i].Service_Request_Number__c = ServiceReqCase.Id;
                NonWarrantyLineItems[i].Order_Line_Type__c = 'Quote';
                NonWarrantyLineItems[i].Order_Line_Category__c = 'Manual Entry';
                ListToInsertServiceReqLineItem.push(NonWarrantyLineItems[i]);

            }
        }
    },
    getPartsOrderedItemNotListed: function(component) {
        var OrderPartsNotBill = component.find("OrderPartsNotBill");
        if (OrderPartsNotBill != null && OrderPartsNotBill != undefined) {
            var ServiceReqLineItemsList = OrderPartsNotBill.get("v.ServiceReqLineItems");
            return ServiceReqLineItemsList;
        }
        return null;
    },
    getNonWarrantyLineItems: function(component) {
        var NonWarrantyCharges = component.find("NonWarrantyCharges");
        if (NonWarrantyCharges != null && NonWarrantyCharges != undefined) {
            var NonWarrantyLineItemsList = NonWarrantyCharges.get("v.NonWarrantyLineItemsList");
            return NonWarrantyLineItemsList;
        }
        return null;
    },
    Save: function(component) {
        component.set("v.isError", false);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var ServiceReqCase = component.get("v.Service_Request_Case");
        var userType = component.get("v.userType");
        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        if (partsOrderedListToRemove.length > 0) {
            var nonWar = component.get("v.NonWarrantyLineItemsListToDelete");
            if (nonWar != null && nonWar.length > 0) {
                partsOrderedListToRemove.push(nonWar);
            }
        } else {
            var nonWar = component.get("v.NonWarrantyLineItemsListToDelete");
            if (nonWar != null && nonWar.length > 0) {
                partsOrderedListToRemove = nonWar;
            }
        }
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        if (ServiceReqCase.Service_Request_Milestone__c == "In Progress") {
            ServiceReqCase.Auto_Approved__c = false;
            ServiceReqCase.Approved_Date__c = null;
            ServiceReqCase.Approved_Flag__c = false;
            ServiceReqCase.Manual_Approval_Reason__c = null;
        }
        //valdations
        var Old_Service_Request_Case = component.get("v.Old_Service_Request_Case");
        if (Old_Service_Request_Case.Claim_Type__c == "Non-Warranty" && ServiceReqCase.Claim_Type__c == "Warranty" && ServiceReqCase.Goodwill__c) {
            ServiceReqCase.Parts_Percentage_Discount__c = "0";
            ServiceReqCase.Labour_Percentage_Discount__c = "0";
        }
        //Processing Section Additional Fields
        ServiceReqCase.Service_Agent__c = userType.AccountId;
        ServiceReqCase.Diagnosed_User__c = userType.Id;

        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'Save');

    },
    saveCaseAndDoAdditionalProcess: function(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, buttonClicked) {
        this.setaccountname(component, ServiceReqCase);
        var action = component.get("c.saveCase");
        action.setParams({
            "strServiceRequestCaseObj": JSON.stringify(ServiceReqCase),
            "strAccountObj": JSON.stringify(ObjAccount),
            "strProductObj": JSON.stringify(ObjProduct),
            "strRetailerObj": JSON.stringify(ObjRetailer),
            "partsOrderedListToRemove": JSON.stringify(partsOrderedListToRemove),
            "ListToInsertServiceReqLineItemStr": JSON.stringify(ListToInsertServiceReqLineItem),
            "buttonClicked": buttonClicked
        });
        action.setCallback(this, function(response) {
            if (response != null && response.getState() == 'SUCCESS') {
                var OrderPartsNotBill = component.find("OrderPartsNotBill");
                if (OrderPartsNotBill != null && OrderPartsNotBill != undefined) {
                    var ServiceReqLineItemsList = OrderPartsNotBill.get("v.ServiceReqLineItems");
                    if (ServiceReqLineItemsList.length > 0) {
                        ServiceReqLineItemsList.splice(0, ServiceReqLineItemsList.length);
                        OrderPartsNotBill.set("v.ServiceReqLineItems", ServiceReqLineItemsList);
                    }
                }

                var updatedClaim = JSON.parse(response.getReturnValue())[0];
                component.set("v.Service_Request_Case", updatedClaim);
                if (buttonClicked == 'SubmitForApproval' && ServiceReqCase.TTI_Send_Quote__c) {
                    var pdfAction = component.get("c.handleEmailPart");
                    pdfAction.setParams({
                        "caseId": ServiceReqCase.Id,
                        "operation": "QuoteGeneration"
                    });
                    $A.enqueueAction(pdfAction);



                }
                if (buttonClicked == "MarkAsComplete") {
                    var pdfAction = component.get("c.handleEmailPart");
                    pdfAction.setParams({
                        "caseId": updatedClaim.Id,
                        "operation": "JobSummaryGeneration"
                    });
                    pdfAction.setCallback(this, function(response) {
                        if (ServiceReqCase.TTI_Freight_Out_Required__c == true) {
                            var apiAction = component.get("c.sendFreightCompanyRequest");
                            apiAction.setParams({
                                "caseId": updatedClaim.Id,
                                "TriggerPoint": buttonClicked
                            });
                            apiAction.setCallback(this, function(response) {
                                if (response.getState() == 'SUCCESS') {
                                    var ObjAPIResponse = JSON.parse(response.getReturnValue());
                                    debugger;
                                    console.log(ObjAPIResponse);
                                    component.set("v.APIResponseObject", ObjAPIResponse);
                                    var functionToRunObject1 = {};
                                    functionToRunObject1.run = function() {
                                        window.open('/ttiservice/s/claimreceipt?claimNumber=' + updatedClaim.Id + '&type=job');
                                        component.refreshPageInternally();

                                    }
                                    var date = new Date();
                                    date.setDate(date.getDate() + 1);
                                    if (date.getDay() == 0) {
                                        date.setDate(date.getDate() + 1);
                                    }
                                    if (date.getDay() == 1) {
                                        date.setDate(date.getDate() + 2);
                                    }
                                    var day = date.getDate();
                                    var month = date.getMonth() + 1;
                                    var year = date.getFullYear();
                                    var utilityMethods = component.find("utilityMethods");
                                    var message;

                                    let freightOutCourier = ServiceReqCase.TTI_Freight_Out_Courier__c;
                                    let today = day + "/" + month + "/" + year;

                                    var errMessageSuccessFreightCompanyRequest = component.get("v.errMessageSuccessFreightCompanyRequest");
                                    var replacementsSuccessMessage = [
                                        component.get("v.Service_Request_Case.TTI_Freight_Out_Courier__c"),
                                        component.get("v.Service_Request_Case.TTI_Freight_Out_Courier__c"),
                                        today
                                    ];
                                    var errMessageFailedFreightCompanyRequest = component.get("v.errMessageFailedFreightCompanyRequest");
                                    var replacementsFailedMessage = [
                                        component.get("v.Service_Request_Case.TTI_Freight_Out_Courier__c"),
                                        component.get("v.Service_Request_Case.TTI_Freight_Out_Courier__c"),
                                        today,
                                        ObjAPIResponse.Tracking_references
                                    ];

                                    if (ObjAPIResponse.Success)
                                        message = utilityMethods.format(errMessageSuccessFreightCompanyRequest, replacementsSuccessMessage);
                                    else
                                        message = utilityMethods.format(errMessageFailedFreightCompanyRequest, replacementsFailedMessage);

                                    debugger;
                                    this.showToastMessages(ServiceReqCase, updatedClaim, buttonClicked);
                                    $A.util.toggleClass(spinner, "slds-hide");
                                    this.fireOkModalEvent(message, functionToRunObject1);

                                } else {
                                    window.open('/ttiservice/s/claimreceipt?claimNumber=' + updatedClaim.Id + '&type=job');
                                    component.refreshPageInternally();
                                    $A.util.toggleClass(spinner, "slds-hide");
                                    this.showToastMessages(ServiceReqCase, updatedClaim, buttonClicked);
                                }
                            });
                            $A.enqueueAction(apiAction);
                        } else {
                            window.open('/ttiservice/s/claimreceipt?claimNumber=' + updatedClaim.Id + '&type=job');
                            component.refreshPageInternally();
                            $A.util.toggleClass(spinner, "slds-hide");
                            this.showToastMessages(ServiceReqCase, updatedClaim, buttonClicked);
                        }
                    });
                    $A.enqueueAction(pdfAction);


                } else {
                    component.refreshPageInternally();
                    $A.util.toggleClass(spinner, "slds-hide");
                    this.showToastMessages(ServiceReqCase, updatedClaim, buttonClicked);

                }
                if (ServiceReqCase.openPdf) {
                    window.open('/ttiservice/s/claimreceipt?claimNumber=' + updatedClaim.Id + '&type=quote');

                }
            } else {
                console.log(response.getError());
            }

            var OrderPartsFromBill = component.find("OrderPartsFromBill");
                if (OrderPartsFromBill != null && OrderPartsFromBill != undefined) {
                    var PartsOrderedSelectCheckboxList = OrderPartsFromBill.find("partsOrderedSelectCheckboxId");

                    if (PartsOrderedSelectCheckboxList != undefined || PartsOrderedSelectCheckboxList != null) {
                        if (PartsOrderedSelectCheckboxList != undefined && PartsOrderedSelectCheckboxList.length == undefined && PartsOrderedSelectCheckboxList.get("v.value") == true) {
                            PartsOrderedSelectCheckboxList.set("v.value", false);
                        } else {
                            for (var i = 0; i < PartsOrderedSelectCheckboxList.length; i++) {
                                if (PartsOrderedSelectCheckboxList[i].get("v.value")) {
                                    PartsOrderedSelectCheckboxList[i].set("v.value", false);
                                }
                            }
                        }
                    }
                }

        });
        if (!component.get("v.isError")) {
            $A.enqueueAction(action);
        } else {
            $A.util.toggleClass(spinner, "slds-hide");

        }

    },
    showToastMessages: function(ServiceReqCase, updatedClaim, buttonClicked) {
        var messageToShow = '';
        var toastEvent = $A.get("e.force:showToast");
        if (buttonClicked == 'Save') {
            if (ServiceReqCase.Service_Request_Milestone__c == 'In Progress' && updatedClaim.Service_Request_Milestone__c == 'Awaiting Approval') {
                messageToShow = 'As a result of your update, this service claim now needs to be re-approved by the Warranty Team';
            } else {
                messageToShow = 'Your changes to this service claim have been saved';
            }

        } else if (buttonClicked == 'SubmitForApproval') {
            if (updatedClaim.Claim_Type__c == 'Warranty') {
                if (updatedClaim.Service_Request_Milestone__c == 'Awaiting Approval') {
                    messageToShow = 'The warranty service claim has been submitted for approval and requires to be approved by the TTI Warranty Team';
                } else if (updatedClaim.Service_Request_Milestone__c == 'In Progress') {
                    messageToShow = 'The warranty service claim has been approved. You may proceed to service this claim';
                }
            } else {
                messageToShow = 'The quote has been sent to the recipient and this non-warranty claim is now awaiting approval from the recipient';
            }
        } else if (buttonClicked == 'RejectWarranty') {
            messageToShow = 'The warranty service claim has been successfully rejected and will no longer appear in your list of pending claims';
        } else if (buttonClicked == 'RejectNonWarranty') {
            messageToShow = 'The non-warranty service claim has been successfully rejected and will no longer appear in your list of pending claims';
        } else if (buttonClicked == 'ApproveNonWarranty') {
            messageToShow = 'The non-warranty service claim has been approved. You may proceed to service this claim';
        } else if (buttonClicked == 'MarkAsComplete') {
            if (updatedClaim.Claim_Type__c == 'Warranty') {
                if (updatedClaim.Service_Request_Milestone__c == 'Invoice Awaiting Approval') {
                    messageToShow = 'The warranty service claim has been successfully marked as complete and will require your invoice to be approved by the TTI warranty team';
                } else {
                    messageToShow = 'The warranty service claim has been successfully marked as complete';
                }

            } else {
                messageToShow = 'The non-warranty service claim has been successfully marked as complete';
            }

        }
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": messageToShow
        });
        if (messageToShow != '') {
            toastEvent.fire();
        }
    },
    Rejectwarrantyhelper: function(component, ServiceReqCase) {
        var userType = component.get("v.userType");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        //Adding processing field updates
        ServiceReqCase.Service_Agent__c = userType.AccountId;
        ServiceReqCase.Status = "Closed";
        ServiceReqCase.Service_Request_Milestone__c = "Closed";
        ServiceReqCase.Closed_Reason__c = "Rejected by Service Agent";
        var currentdatetime = new Date();
        ServiceReqCase.Number_of_Interactions__c = ServiceReqCase.Number_of_Interactions__c + 1;
        ServiceReqCase.Diagnosed_Date__c = currentdatetime;
        ServiceReqCase.ClosedDate = currentdatetime;
        ServiceReqCase.Diagnosed_User__c = userType.Id;

        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'RejectWarranty');

    },

    Approvenonwarrantyhelper: function(component, ServiceReqCase) {
        var userType = component.get("v.userType");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        //Adding processing field updates
        ServiceReqCase.Service_Agent__c = userType.AccountId;
        ServiceReqCase.Service_Request_Milestone__c = "In Progress";
        var currentdatetime = new Date();
        ServiceReqCase.Number_of_Interactions__c = ServiceReqCase.Number_of_Interactions__c + 1;
        ServiceReqCase.Approved_Flag__c = true;
        ServiceReqCase.Approved_Date__c = currentdatetime;
        ServiceReqCase.Diagnosed_Date__c = currentdatetime;
        ServiceReqCase.Diagnosed_User__c = userType.Id;

        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'ApproveNonWarranty');

    },

    Rejectnonwarrantyhelper: function(component, ServiceReqCase) {
        var userType = component.get("v.userType");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        //Adding processing field updates
        ServiceReqCase.Service_Agent__c = userType.AccountId;
        ServiceReqCase.Status = "Closed";
        ServiceReqCase.Service_Request_Milestone__c = "Closed";
        ServiceReqCase.Closed_Reason__c = "Rejected by Customer";
        var currentdatetime = new Date();
        ServiceReqCase.Number_of_Interactions__c = ServiceReqCase.Number_of_Interactions__c + 1;
        ServiceReqCase.Diagnosed_Date__c = currentdatetime;
        ServiceReqCase.ClosedDate = currentdatetime;
        ServiceReqCase.Diagnosed_User__c = userType.Id;

        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'RejectNonWarranty');

    },
    deleteUnwantedItemsFromCaseObject: function(ServiceReqCase, ObjAccount, ObjRetailer) {
        delete ServiceReqCase.Account;
        delete ServiceReqCase.Product_Name__r;
        delete ServiceReqCase.Retailer_Account__r;
        delete ServiceReqCase.Owner;
        delete ServiceReqCase.MilestoneStatus;
        if (ObjAccount != undefined) {
            delete ObjAccount.Name;
        }
        if (ObjRetailer != undefined) {
            delete ObjRetailer.Name;
        }

    },

    SubmitForApproval: function(component, ServiceReqCase) {
        var userType = component.get("v.userType");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        //Adding processing field updates
        ServiceReqCase.Service_Agent__c = userType.AccountId;
        var currentdatetime = new Date();
        ServiceReqCase.Diagnosed_Date__c = currentdatetime;
        if (ServiceReqCase.Claim_Type__c == "Non-Warranty") {
            ServiceReqCase.Service_Request_Milestone__c = "Awaiting Approval";
        }
        ServiceReqCase.Diagnosed_User__c = userType.Id;
        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'SubmitForApproval');


    },

    SubmitInvoiceForApproval: function(component, ServiceReqCase) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        //Adding processing field updates
        var currentdatetime = new Date();
        ServiceReqCase.Completion_Date__c = currentdatetime;
        ServiceReqCase.Service_Request_Milestone__c = "Completed";
        ServiceReqCase.TTI_Marked_As_Complete__c = true;

        var ListToInsertServiceReqLineItem = [];
        this.createServiceReqLineItemList(component, ListToInsertServiceReqLineItem, ServiceReqCase);
        ServiceReqCase.sobjectType = 'Case';
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        var ObjAccount = ServiceReqCase.Account;
        var ObjProduct = ServiceReqCase.Product_Name__r;
        var ObjRetailer = ServiceReqCase.Retailer_Account__r;
        component.set("v.Old_Service_Request_Case", ServiceReqCase);
        this.deleteUnwantedItemsFromCaseObject(ServiceReqCase, ObjAccount, ObjRetailer);
        this.saveCaseAndDoAdditionalProcess(component, ServiceReqCase, ObjAccount, ObjProduct, ObjRetailer, partsOrderedListToRemove, ListToInsertServiceReqLineItem, spinner, 'MarkAsComplete');


    },

    validationChecksOnSave: function(component, ServiceReqCase) {
        return this.ValidationOnClaimType(component, ServiceReqCase) &&
            this.ValidationOnNotificationEmail(component, ServiceReqCase) &&
            this.checkAssignedToMe(component, ServiceReqCase) &&
            this.checkDeliveryAddress(component, ServiceReqCase) &&
            this.sundryexpensereasonnull(component, ServiceReqCase) &&
            this.ValidationOnRepairType(component, ServiceReqCase) &&
            this.validategoodwill(component, ServiceReqCase) &&
            this.validationOnOrderPartsNotListed(component);
    },
    //Added by Upendra Kumar
    //This method check if total current month sundry amount
    //excedding monthly allowed expense or not 
    receiptValidationForSaving: function(component){
        var isFileAttached = component.get("v.isFileAttached");
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var ServiceMilestoneAttribute = component.get("v.ServiceMilestoneAttribute");
        if(component.get("v.userType.Account.Internal_Service_Agent__c") == false
           && Service_Request_Case.Claim_Type__c == 'Warranty'
           && (ServiceMilestoneAttribute.AwaitingInvoiceApproval
               || ServiceMilestoneAttribute.InProgress || ServiceMilestoneAttribute.Completed)){
            var action = component.get("c.isAttachmentRequired");
            action.setParams({
                "objCaseString" : JSON.stringify(Service_Request_Case)
            });
            action.setCallback(this, function(response){
                if (response.getState() == 'SUCCESS') {
                    var isAttachmentRequired = response.getReturnValue();
                    if(isAttachmentRequired == true && isFileAttached != true){
                        component.set("v.errorMessages", "Please Attach Receipt(s)");
                    }
                    else{
                        this.Save(component);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else{
            this.Save(component);
        }
    },
    validationOnOrderPartsNotListed: function(component) {
        var OrderPartsNotListed = component.find("OrderPartsNotBill");
        var hasResult = true;
        var hasSelected = true;
        if(OrderPartsNotListed != null && OrderPartsNotListed != undefined) {
            var searchCmp = OrderPartsNotListed.find("searchCmp");
            if(searchCmp != null && searchCmp != undefined) {
                if (searchCmp != undefined && searchCmp.length == undefined) {
                    // check blank SKU
                    var SelectedItemName = searchCmp.get("v.SelectedItemName");
                    if (SelectedItemName == undefined) {
                        $A.util.addClass(searchCmp.find("lookup"), 'errorBox');
                        component.set("v.errorMessages", "Please input SKU.");
                        debugger;
                        return false;
                    }

                    if(searchCmp.get("v.hasResult") == true && searchCmp.get("v.hasSelected") == true) {                        
                        $A.util.removeClass(searchCmp.find("lookup"), 'errorBox');
                    } else {
                        $A.util.addClass(searchCmp.find("lookup"), 'errorBox');
                        hasResult = false;
                        hasSelected = false;
                    }                        
                } else if(searchCmp.length == 1) {
                    // check blank SKU
                    var SelectedItemName = searchCmp[0].get("v.SelectedItemName");
                    if (SelectedItemName == undefined) {
                        debugger;
                        $A.util.addClass(searchCmp[0].find("lookup"), 'errorBox');
                        component.set("v.errorMessages", "Please input SKU.");
                        debugger;
                        return false;
                    }

                    if(searchCmp.get("v.hasResult") == true && searchCmp.get("v.hasSelected") == true) {                        
                        $A.util.removeClass(searchCmp.find("lookup"), 'errorBox');
                    } else {
                        $A.util.addClass(searchCmp.find("lookup"), 'errorBox');
                        hasResult = false;
                        hasSelected = false;
                    }                       
                } else if(searchCmp.length > 0) {
                    var hasEmptySKU = false;
                    for (var i = 0; i < searchCmp.length; i++) {
                        // check blank SKU
                        var SelectedItemName = searchCmp[i].get("v.SelectedItemName");
                        debugger;
                        if (SelectedItemName == undefined) {
                            debugger;
                            $A.util.addClass(searchCmp[i].find("lookup"), 'errorBox');
                            component.set("v.errorMessages", "Please input SKU.");
                            hasEmptySKU = true;
                            hasResult = false;
                            debugger;
                        }

                        if(hasEmptySKU == false) {
                            debugger;
                            if (searchCmp[i].get("v.hasResult") == true && searchCmp[i].get("v.hasSelected") == true) {
                                $A.util.addClass(searchCmp[i].find("lookup"), 'errorBox');
                            } else {
                                $A.util.removeClass(searchCmp[i].find("lookup"), 'errorBox');
                                hasResult = false;
                                hasSelected = false;
                            }
                        }                            
                    }
                }
            }
        }

        if(hasResult == true) {
            return true;
        }

        component.set("v.errorMessages", "SKU must be valid when inserting parts manually");
        return false;        
    },

    ValidationOnRepairType: function(component, ServiceReqCase) {
        if (ServiceReqCase.Repair_Type__c == 'Declined Warranty - Inspection fee') {
            var selectedPartsOrdered = [];
            this.getSelectedPartsOrderedItem(component, selectedPartsOrdered);
            var PartsOrderedNotListed = this.getPartsOrderedItemNotListed(component);
            if ((selectedPartsOrdered != undefined && selectedPartsOrdered != null && selectedPartsOrdered.length > 0) ||
                (PartsOrderedNotListed != undefined && PartsOrderedNotListed != null && PartsOrderedNotListed.length > 0)) {
                component.set("v.errorMessages", "You cannot order parts for an inspection fee warranty claim");
                return false;
            }
        }
        return true;

    },
    ValidationOnClaimType: function(component, Service_Request_Case) {
        var ServiceRequestDetails = component.find("ServiceRequestDetails");
        var claimTypeBox = ServiceRequestDetails.find("claimType");
        var claimType = claimTypeBox.get("v.value");
        if (claimType == 'Warranty' && Service_Request_Case.Goodwill__c) {
            claimTypeBox.set("v.errors", [{ message: "Goodwill Non-Warranty claims cannot be set to Warranty claims" }]);
            return false;
        } else {
            if (claimType == 'Non-Warranty' && ($A.util.isUndefinedOrNull(Service_Request_Case.SuppliedEmail) || $A.util.isEmpty(Service_Request_Case.SuppliedEmail))) {
                var CustomerDetails = component.find("CustomerDetails");
                var notificationEmail = CustomerDetails.find("notificationEmail");
                notificationEmail.set("v.errors", [{ message: "Email address is required for non-warranty claims" }]);
            } else {
                claimTypeBox.set("v.errors", null);
            }


        }
        return true;
    },
    ValidationOnNotificationEmail: function(component, Service_Request_Case) {
        var CustomerDetails = component.find("CustomerDetails");
        var notificationEmail = CustomerDetails.find("notificationEmail");
        if (Service_Request_Case.TTI_Email_Notification_Opt_In__c && ($A.util.isUndefinedOrNull(Service_Request_Case.SuppliedEmail) || $A.util.isEmpty(Service_Request_Case.SuppliedEmail))) {
            notificationEmail.set("v.errors", [{ message: "Notification Email Address is required for service requests that have the Notification Opt In checked" }]);
            return false;
        } else {
            notificationEmail.set("v.errors", null);
            return true;
        }

    },
    checkDeliveryAddress: function(component, Service_Request_Case) {
        var ClaimCompletionDetails = component.find("ClaimCompletionDetails");
        var pickupdelivery = ClaimCompletionDetails.find("pickupdelivery");
        if (pickupdelivery == undefined) return true;
        if (Service_Request_Case.TTI_Customer_Delivery_Method__c == 'Deliver' &&
            (($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Freight_Out_Delivery_Address__c) ||
                    $A.util.isEmpty(Service_Request_Case.TTI_Freight_Out_Delivery_Address__c)) ||
                ($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Freight_Out_Delivery_Suburb__c) ||
                    $A.util.isEmpty(Service_Request_Case.TTI_Freight_Out_Delivery_Suburb__c)) ||
                ($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Freight_Out_Delivery_Postcode__c) ||
                    $A.util.isEmpty(Service_Request_Case.TTI_Freight_Out_Delivery_Postcode__c)) ||
                ($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Freight_Out_Delivery_Country__c) ||
                    $A.util.isEmpty(Service_Request_Case.TTI_Freight_Out_Delivery_Country__c)))) {
            pickupdelivery.set("v.errors", [{ message: "Delivery Address must be specified if the tool is to be delivered to the customer on completion" }]);
            return false;

        } else {
            pickupdelivery.set("v.errors", null);
            return true;
        }

    },
    timespentnull: function(component, Service_Request_Case) {
        var userType = component.get("v.userType");
        if (userType.Account.Internal_Service_Agent__c && ($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Time_Spent_Hours__c) || $A.util.isEmpty(Service_Request_Case.TTI_Time_Spent_Hours__c) || $A.util.isUndefinedOrNull(Service_Request_Case.TTI_Time_Spent_Minutes__c) || $A.util.isEmpty(Service_Request_Case.TTI_Time_Spent_Minutes__c))) {
            component.set("v.errorMessages", "You must specify Time Spent prior to marking this service request as complete.");
            return false;

        } else {

            return true;
        }

    },
    faultcodenull: function(component, Service_Request_Case, errorMessage) {
        if ($A.util.isUndefinedOrNull(Service_Request_Case.Fault_Codes__c) || $A.util.isEmpty(Service_Request_Case.Fault_Codes__c)) {
            component.set("v.errorMessages", errorMessage);
            return false;

        } else {
            return true;
        }

    },
    repairtypenull: function(component, Service_Request_Case) {

        if ($A.util.isUndefinedOrNull(Service_Request_Case.Repair_Type__c) || $A.util.isEmpty(Service_Request_Case.Repair_Type__c)) {
            component.set("v.errorMessages", "You must specify a repair type prior to marking this service request as complete.");
            return false;

        } else {
            return true;
        }

    },
    validategoodwill: function(component, Service_Request_Case) {

        if (Service_Request_Case.Goodwill__c &&
            Service_Request_Case.Claim_Type__c == 'Non-Warranty' &&
            (($A.util.isUndefinedOrNull(Service_Request_Case.Parts_Percentage_Discount__c) ||
                    $A.util.isEmpty(Service_Request_Case.Parts_Percentage_Discount__c)) &&
                ($A.util.isUndefinedOrNull(Service_Request_Case.Labour_Percentage_Discount__c) ||
                    $A.util.isEmpty(Service_Request_Case.Labour_Percentage_Discount__c)))
        ) {
            component.set("v.errorMessages", "You must specify a valid discount when applying goodwill to a non-warranty claim");
            return false;
        } else if (Service_Request_Case.Goodwill__c != true && Service_Request_Case.Claim_Type__c == 'Non-Warranty' &&
            (Service_Request_Case.Parts_Percentage_Discount__c > 0 || Service_Request_Case.Labour_Percentage_Discount__c > 0)) {
            component.set("v.errorMessages", "Discounts can only be specified for goodwill claims. Either remove the discounts or tick the Goodwill box");
            return false;
        } else {
            return true;
        }

    },
    validatemarkascomplete: function(component, Service_Request_Case) {
        return this.checkAssignedToMe(component, Service_Request_Case) &&
            this.timespentnull(component, Service_Request_Case) &&
            this.faultcodenull(component, Service_Request_Case, "You must specify a Fault Code prior to marking this service request as complete.") &&
            this.repairtypenull(component, Service_Request_Case) &&
            this.validategoodwill(component, Service_Request_Case) &&
            this.sundryexpensereasonnull(component, Service_Request_Case) &&
            this.validateDiagnosisComments(component, Service_Request_Case, "Diagnosis comments field is mandatory") &&
            this.validatePurchaseOrderAndPaymentReferece(component, Service_Request_Case, "You must either provide the payment reference or purchase order reference prior to marking this claim as complete");
    },
    validatePurchaseOrderAndPaymentReferece: function(component, Service_Request_Case, errorMessage) {
        if (($A.util.isUndefinedOrNull(Service_Request_Case.Purchase_Order_Reference__c) ||
                $A.util.isEmpty(Service_Request_Case.Purchase_Order_Reference__c)) &&
            ($A.util.isUndefinedOrNull(Service_Request_Case.Payment_Reference__c) ||
                $A.util.isEmpty(Service_Request_Case.Payment_Reference__c)) &&
            Service_Request_Case.Claim_Type__c == 'Non-Warranty') {
            component.set("v.errorMessages", errorMessage);
            return false;
        } else {
            component.set("v.errorMessages", null);
            return true;
        }
    },
    validateDiagnosisComments: function(component, Service_Request_Case, errorMessage) {
        if (($A.util.isUndefinedOrNull(Service_Request_Case.TTI_Service_Agent_Comments__c) ||
                $A.util.isEmpty(Service_Request_Case.TTI_Service_Agent_Comments__c))) {
            component.set("v.errorMessages", errorMessage);
            return false;
        } else {
            component.set("v.errorMessages", null);
            return true;
        }
    },
    Quotegiven: function(component, Service_Request_Case) {
        var userType = component.get("v.userType");
        var Service_Request_Case = component.get("v.Service_Request_Case");
        if (Service_Request_Case.Claim_Type__c == 'Non-Warranty') {
            if ((Service_Request_Case.TTI_Quote_to_Retailer__c == false && Service_Request_Case.TTI_Quote_to_Customer__c == false) || (Service_Request_Case.TTI_Quote_to_Retailer__c == true && Service_Request_Case.TTI_Quote_to_Customer__c == true)) {
                component.set("v.errorMessages", "The quote must be sent either to the Retailer or the Customer. You must specify which of these will receive the quote");
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    },
    validatesubmitforapproval: function(component, Service_Request_Case) {

        return this.checkAssignedToMe(component, Service_Request_Case) &&
            this.Quotegiven(component, Service_Request_Case) &&
            this.validateRetailerEmailAddress(component, Service_Request_Case) &&
            this.validategoodwill(component, Service_Request_Case) &&
            this.faultcodenull(component, Service_Request_Case, "One fault code must be selected from the list prior to submitting a claim for approval") &&
            this.validateDiagnosisComments(component, Service_Request_Case, "Please provide detailed information about the job in the fault diagnosis comments field prior to submitting a claim for approval") &&
            this.validationOnOrderPartsNotListed(component);
    },
    setaccountname: function(component, Service_Request_Case) {
        var userType = component.get("v.userType");
        if ($A.util.isUndefinedOrNull(Service_Request_Case.AccountId) || $A.util.isEmpty(Service_Request_Case.AccountId)) {
            Service_Request_Case.AccountId = userType.AccountId;
        }
    },
    IsPartsOrderedListEmpty: function(component) {
        var selectedPartsOrdered = [];
        this.getSelectedPartsOrderedItem(component, selectedPartsOrdered);
        var PartsOrderedNotListed = this.getPartsOrderedItemNotListed(component);
        var PartsOrderedComp = component.find("PartsOrdered");
        var PartsOrdered = [];
        if (PartsOrderedComp != undefined || PartsOrderedComp != null) {
            PartsOrdered = PartsOrderedComp.get("v.Service_Request_Line_Item");
        }
        if (selectedPartsOrdered.length > 0 || PartsOrderedNotListed.length > 0 || PartsOrdered.length > 0)
            return false;
        return true;
    },
    IsRetailsChargesListEmpty: function(component) {
        var NonWarrantyLineItems = this.getNonWarrantyLineItems(component);
        if (NonWarrantyLineItems != null && NonWarrantyLineItems != undefined && NonWarrantyLineItems.length > 0)
            return false;
        return true;
    },
    sundryexpensereasonnull: function(component, Service_Request_Case) {

        if (Service_Request_Case.Total_Sundry_Expenses__c > 0) {
            if ($A.util.isUndefinedOrNull(Service_Request_Case.Sundry_Expense_Reason__c) || $A.util.isEmpty(Service_Request_Case.Sundry_Expense_Reason__c)) {
                component.set("v.errorMessages", "Please Fill Sundry Expense Reason");
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }

    },
    validateRetailerEmailAddress: function(component, serviceRequestCase) {
        if (!$A.util.isUndefinedOrNull(serviceRequestCase)) {
            if (($A.util.isUndefinedOrNull(serviceRequestCase.Retailer_Email_Address__c) || $A.util.isEmpty(serviceRequestCase.Retailer_Email_Address__c)) &&
                serviceRequestCase.TTI_Quote_to_Retailer__c == true && serviceRequestCase.Claim_Type__c == 'Non-Warranty') {
                component.set("v.errorMessages", "You must specify the retailer email address if you want to send this quote to the retailer");
                return false;
            } else {
                component.set("v.errorMessages", null);
                return true;
            }
        }
    }


})