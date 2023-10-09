({
    doInit: function(component, event, helper) {
        var ServiceReqCase = component.get("v.Service_Request_Case");
        component.set("v.Old_Service_Request_Case", ServiceReqCase);

        var getUserTypeAction = component.get("c.getUserType");

        getUserTypeAction.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var userType = response.getReturnValue();
                component.set("v.userType", userType);
                if (userType.Account != null && userType.Account != undefined && !userType.Account.Internal_Service_Agent__c) {
                    ServiceReqCase.Claim_Type__c = 'Warranty';
                }
                $A.enqueueAction(getSOHCustomSetngAction);
            }

        });
        $A.enqueueAction(getUserTypeAction);

        var getSOHCustomSetngAction = component.get("c.getSOHRAGStatusCustomSetting");
        getSOHCustomSetngAction.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                component.set("v.SOHRAGStatusList", JSON.parse(response.getReturnValue()));
                component.set("v.Service_Request_Case", ServiceReqCase);
                helper.populateData(component, ServiceReqCase);

            }
        });

    },
    Save: function(component, event, helper) {
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var isValid = helper.validationChecksOnSave(component, Service_Request_Case);
        if (isValid) {
            //Updated by Upendra Kumar
            //Added validation to upload receipt if total
            //sundry expense excedding monthly allowed amount
            helper.receiptValidationForSaving(component);
            //helper.Save(component);
        }

    },
    Submitforapproval: function(component, event, helper) {
        var ServiceReqCase = component.get("v.Service_Request_Case");
       	if (helper.validatesubmitforapproval(component, ServiceReqCase)) {
            var functionToRunObject = {};
            functionToRunObject.run = function() {
                if (ServiceReqCase.Claim_Type__c == 'Non-Warranty') {
                    if (helper.IsRetailsChargesListEmpty(component)) {
                        var functionToRunObject2 = {};
                        functionToRunObject2.run = function() {
                            ServiceReqCase.TTI_Send_Quote__c = true;
                            ServiceReqCase.openPdf = false;
                            var functionToRunObject1 = {};
                            functionToRunObject1.run = function() {
                                ServiceReqCase.openPdf = true;
                                helper.SubmitForApproval(component, ServiceReqCase);
                            }
                            functionToRunObject1.Norun = function() {
                                ServiceReqCase.openPdf = false;
                                helper.SubmitForApproval(component, ServiceReqCase);
                            }
                            helper.fireModalEvent("A quote will be now be sent to the recipient via email.  Would you like to print a copy of this quote?", functionToRunObject1);

                        }
                        helper.fireModalEvent("You are about to submit a non-warranty quote without specifying retail charges. Are you sure you wish to continue?", functionToRunObject2);
                    } else {
                        ServiceReqCase.TTI_Send_Quote__c = true;
                        ServiceReqCase.openPdf = false;
                        var functionToRunObject1 = {};
                        functionToRunObject1.run = function() {
                            ServiceReqCase.openPdf = true;
                            helper.SubmitForApproval(component, ServiceReqCase);
                        }
                        functionToRunObject1.Norun = function() {
                            ServiceReqCase.openPdf = false;
                            helper.SubmitForApproval(component, ServiceReqCase);
                        }
                        helper.fireModalEvent("A quote will be now be sent to the recipient via email.  Would you like to print a copy of this quote?", functionToRunObject1);

                    }

                } else {
                    if (helper.IsPartsOrderedListEmpty(component)) {
                        var functionToRunObject2 = {};
                        functionToRunObject2.run = function() {
                            helper.SubmitForApproval(component, ServiceReqCase);
                        }
                        helper.fireModalEvent("You are about to submit for approval without ordering any parts.  Are you sure you wish to continue?", functionToRunObject2);
                    } else {
                        helper.SubmitForApproval(component, ServiceReqCase);
                    }

                }
            }
            helper.fireModalEvent("Are you sure you want to submit this claim for approval?", functionToRunObject);
		}

    },
    MarkComplete: function(component, event, helper) {
        //Updated by Upendra Kumar
        //Added validation to upload receipt if total
        //sundry expense excedding monthly allowed amount
        console.log('DBG: MarkComplete 1');
        var ServiceReqCase = component.get("v.Service_Request_Case");
        var isFileAttached = component.get("v.isFileAttached");
        console.log('DBG: MarkComplete 2');
        if (helper.validatemarkascomplete(component, ServiceReqCase)) {
            console.log('DBG: MarkComplete 3');
            var action = component.get("c.isAttachmentRequired");
            action.setParams({
                "objCaseString" : JSON.stringify(ServiceReqCase)
            });
            console.log('DBG: MarkComplete 4');
            action.setCallback(this, function(response){
                console.log('DBG: MarkComplete 5');
                if (response.getState() == 'SUCCESS') {
                    console.log('DBG: MarkComplete - SUCCESS - 1');
                    var isAttachmentRequired = response.getReturnValue();
                    if(isAttachmentRequired == true && isFileAttached != true){
                        component.set("v.errorMessages", "Please Attach Receipt(s)");
                    }
                    else{
                        if ((ServiceReqCase.SAP_Error_Text__c != null && ServiceReqCase.SAP_Error_Text__c != '') ||
                            ServiceReqCase.TTI_Count_parts_not_having_sap_number__c > 0) {
                            component.set("v.errorMessages", component.get("v.errMessageCannotMarkComplete"));
                            return;
                        } else {
                            var functionToRunObject = {};
                            functionToRunObject.run = function() {
                                if(ServiceReqCase.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent'){
                                    ServiceReqCase.TTI_Freight_Out_Required__c = false;
                                }else if(ServiceReqCase.TTI_Customer_Delivery_Method__c == 'Deliver'){ // Francis Nasalita [SP-872] 2018/11/08 - Changed from Delivery to Deliver
                                    ServiceReqCase.TTI_Freight_Out_Required__c = true;        
                                }
                                console.log('ServiceReqCase >>>> ' + ServiceReqCase.TTI_Freight_Out_Required__c);    
                                helper.SubmitInvoiceForApproval(component, ServiceReqCase);
                            }
                            helper.fireModalEvent("Are you sure you wish to mark this service request as complete?", functionToRunObject);
                        }
                    }
                }
                console.log('DBG: MarkComplete 6');
            });
            $A.enqueueAction(action);
        }
    },
    Rejectwarranty: function(component, event, helper) {
        var ServiceReqCase = component.get("v.Service_Request_Case");
        if (!helper.checkAssignedToMe(component, ServiceReqCase)) {
            component.set("v.errorMessages", "You must assign the service request to yourself prior to marking the service request as complete");
        } else if (helper.validateDiagnosisComments(component, ServiceReqCase, "You must specify reason why this claim is being rejected in the Fault Diagnosis Comments")) {
            var functionToRunObject = {};
            functionToRunObject.run = function() {
                helper.Rejectwarrantyhelper(component, ServiceReqCase);
            }
            helper.fireModalEvent("Are you sure you wish to reject this warranty claim?", functionToRunObject);
        }
    },
    Approvenonwarranty: function(component, event, helper) {
        var ServiceReqCase = component.get("v.Service_Request_Case");
        if (!helper.checkAssignedToMe(component, ServiceReqCase)) {
            component.set("v.errorMessages", "You must assign the service request to yourself prior to marking the service request as complete");
        } else {
            var functionToRunObject = {};
            functionToRunObject.run = function() {
                helper.Approvenonwarrantyhelper(component, ServiceReqCase);
            }
            helper.fireModalEvent("Are you sure you wish to approve this non-warranty claim?", functionToRunObject);

        }
    },
    Rejectnonwarranty: function(component, event, helper) {
        var ServiceReqCase = component.get("v.Service_Request_Case");
        if (!helper.checkAssignedToMe(component, ServiceReqCase)) {
            component.set("v.errorMessages", "You must assign the service request to yourself prior to marking the service request as complete");
        } else if (helper.validateDiagnosisComments(component, ServiceReqCase, "You must specify reason why this claim is being rejected in the Fault Diagnosis Comments")) {
            var functionToRunObject = {};
            functionToRunObject.run = function() {
                helper.Rejectnonwarrantyhelper(component, ServiceReqCase);
            }
            helper.fireModalEvent("Are you sure you wish to reject this non-warranty claim?", functionToRunObject);

        }
    },
    Cancel: function(component, event, helper) {
        var functionToRunObject = {};
        functionToRunObject.run = function() {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/searchclaim'
            });
            urlEvent.fire();
        }
        helper.fireModalEvent("Are you sure you wish to leave this page without saving your changes?", functionToRunObject);
    },
    itemsChange: function(component, event, helper) {
        var NoofTCalled = component.get("v.NoofTimesCalled");
        if (!$A.util.isUndefinedOrNull(NoofTCalled)) {
            component.set("v.NoofTimesCalled", NoofTCalled + 1);
            console.log('=====NoofTCalled=====' + NoofTCalled);
        }
    },
    methodFromModal: function(component, event, helper) {},

    // Francis C. Nasalita - [SP-840] - 2018/11/13
    faultCodeChangeEventHandler: function(component, event, helper) {
        let claimCompletionDetails = component.find("ClaimCompletionDetails");

        claimCompletionDetails != undefined ? claimCompletionDetails.faultCodeChangedHandler() : '';
    }
})