/**
 * @File Name          : TTI_ServiceRequestControllerV2.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 29/08/2019, 7:49:09 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    07/08/2019, 11:58:59 am   Francis Nasalita     Initial Version
**/
public without sharing class TTI_ServiceRequestControllerV2 {

    private static Map<String, Service_Portal_Freight_Configuration__mdt> configFreightMap;
    private static final String RCTI_BUCKET_NAME = 'RCTI_Bucket';

    public class ServiceRequestControllerException extends Exception {}

    static {
        Boolean inProduction = ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        configFreightMap = new Map<String, Service_Portal_Freight_Configuration__mdt>();
        for (Service_Portal_Freight_Configuration__mdt c : [SELECT Account_Number__c,
                                                                   Brand__c,
                                                                   Carrier__c,
                                                                   Country__c,
                                                                   Product_Default_Height__c,
                                                                   Product_Default_Length__c,
                                                                   Product_Default_Weight__c,
                                                                   Product_Default_Width__c,
                                                                   Product_Minimum_Weight__c
                                                              FROM Service_Portal_Freight_Configuration__mdt]) {

            String country = '';

            if (c.Country__c == 'Australia') {
                country = 'AU';
            } else if (c.Country__c == 'New Zealand') {
                country = 'NZ';
            }

            configFreightMap.put(country + '_' + c.Carrier__c + '_' + c.Brand__c, c);
        }

        // if (configFreightMap.isEmpty()) {
        //     throw new ServiceRequestControllerException('There is a problem with your integration configuration. Kindly contact your administrator for assistance.');
        // }
    }

    @AuraEnabled
    public static String getApprovalProcessLastStep(String targetObjectId) {
        return (targetObjectId != '' && targetObjectId != null) ? JSON.serialize(UtilityClass.getApprovalProcessLastStep(targetObjectId)) : null;
    }
    
    @AuraEnabled
    public static string getCurrentUser() {
        return UserInfo.getUserId() + ':' + UserInfo.getName();
    }
    
    @AuraEnabled
    public static string getInCompletedTasks(string caseId) {
        List<Task> listTask = [SELECT Subject, ActivityDate, OwnerId, Owner.Name, WhatId 
                                 FROM Task 
                                WHERE WhatId = :caseId 
                                  AND Status != 'Completed'];
        if (listTask != null && listTask.size() > 0) {
            return JSON.serialize(listTask);
        }
        return null;
    }
    
    @AuraEnabled
    public static User getUserType(String userId) {
        return [SELECT Id,profile.name, Account.RecordTypeId, Account.RecordType.Name, Account.Internal_Service_Agent__c, AccountId, UserRole.Name, Account.Delivery_Country__c ,
                       Account.Allow_Delivery_to_Customers__c, Account.BillingAddress, Account.ShippingStreet,Account.ShippingCity, Account.ShippingCountry, Account.ShippingState,
                       Account.ShippingPostalCode, Account.Delivery_Street__c, Account.Delivery_Suburb__c, Account.Delivery_State__c, Account.Delivery_Postcode__c, Account.Company_Code__c,
                       Account.Freight_Company__c, ContactId, Account.MX_Authorised__c, Contact.Last_Manifested_Date__c
                  FROM User 
                 WHERE id = :userId];
    }
    
    @AuraEnabled
    public static User getUserType() {
        return [SELECT Id,profile.name, Account.RecordTypeId, Account.RecordType.Name, Account.Internal_Service_Agent__c, AccountId, UserRole.Name, Account.Delivery_Country__c ,
                       Account.Allow_Delivery_to_Customers__c, Account.BillingAddress, Account.ShippingStreet,Account.ShippingCity, Account.ShippingCountry, Account.ShippingState,
                       Account.ShippingPostalCode, Account.Delivery_Street__c, Account.Delivery_Suburb__c, Account.Delivery_State__c, Account.Delivery_Postcode__c, Account.Company_Code__c,
                       Account.Freight_Company__c, ContactId, Contact.Last_Manifested_Date__c
                  FROM User 
                 WHERE id = :UserInfo.getUserId()];
    }
    
    @AuraEnabled 
    public static string getSOHRAGStatusCustomSetting() {
        List<SOHRAGStatus__c> lstSOHRAGStatus = SOHRAGStatus__c.getall().values();
        return JSON.serialize(lstSOHRAGStatus);
    }
    
    @AuraEnabled 
    public static void submitForApprovalMethod(String caseId) {
        Id cid = caseId;
        TTI_ServiceRequest_Auto_Approval_Process.autoapprove(cid);
    }
    
    @AuraEnabled 
    public static void submitInvoiceForApprovalMethod(String caseId) {
        Id cid = caseId;
        List<Id> caseidlist = new List<Id>();
        caseidlist.add(cid);
        TTI_Invoice_Auto_Approval_Process.autoapprove(caseidlist);
    }

    /*
    *  Name :- Upendra Kumar
    *  Created Date:- 10/09/2018
    *  Purpose:- Below logic added to get immediate GST result in portal
    *  Modified By :-
    *  Purpose :-
    *  Modidired Date :-
    */
    @AuraEnabled 
    public static string calculateGST(string strServiceRequestCaseObj) {
        try{
            Case objCase = new Case();
            if (strServiceRequestCaseObj != null ||strServiceRequestCaseObj != '') {
                objCase = (Case) JSON.deserialize(strServiceRequestCaseObj, Case.class);
                if (objCase.Total_Sundry_Expenses__c != null && objCase.Service_Agent__c != null) {
                    //Getting All GST rates
                    Map<String, GST_Rates__c> GSTRateslist = GST_Rates__c.getAll();
                    
                    //GST calculation for Australia
                    if (objCase.Service_Agent__r.Delivery_Country__c == 'Australia' && objCase.Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('Australia').GST_Rate__c != null) {
                            objCase.Sundry_Expense_GST_Payable__c = (objCase.Total_Sundry_Expenses__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                        }
                    }
                    //GST calculation for New Zealand 
                    else if (objCase.Service_Agent__r.Delivery_Country__c == 'New Zealand' && objCase.Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                            objCase.Sundry_Expense_GST_Payable__c = (objCase.Total_Sundry_Expenses__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                        }
                    }
                    //Total Sundry Expenses calculation
                    if (objCase.Sundry_Expense_GST_Payable__c != null) {
                        objCase.Total_Sundry_Expenses_Inc_GST__c = objCase.Total_Sundry_Expenses__c + objCase.Sundry_Expense_GST_Payable__c;
                    }
                }
            }
            return JSON.serialize(objCase);
        } catch(Exception objException) {
            //Creating exception log
            TTI_LogError.createExceptionLog(objException, strServiceRequestCaseObj);
            return null;
        }
    }
    
    /*
    *  Name :- Upendra Kumar
    *  Created Date:- 15/09/2018
    *  Purpose:- This method is used to get Label PDF for TNT
    *  Modified By :-
    *  Purpose :-
    *  Modidired Date :-
    */    
    // @AuraEnabled 
    // public static string generateLabelPdfForAU(string caseRecordString) {
    //     try{
    //         Case objCase = (Case)JSON.deserialize(caseRecordString, Case.class);
    //         //Getting Frieght Company API Details TNT company
    //         TTI_Frieght_Company_API_Details__c objFreightCompanyDetails = TTI_Frieght_Company_API_Details__c.getValues('TNT');
    //         //Checking if Freight out consignment number is null or not
    //         if (objCase.Freight_out_consignment_number__c != null) {
    //             list<ContentDocumentLink> listOfAllLabels = new list<ContentDocumentLink>();
    //             for(ContentDocumentLink ObjLink : [SELECT ContentDocumentId, 
    //                                                       ContentDocument.Title, 
    //                                                       ContentDocument.FileExtension, 
    //                                                       ContentDocument.FileType 
    //                                                  FROM ContentDocumentLink 
    //                                                 WHERE LinkedEntityId = :objCase.Id]) {
    //                 if (ObjLink.ContentDocument.Title.contains('Label')) {
    //                     listOfAllLabels.add(ObjLink);
    //                 }
    //             }
    //             //Checking if case has already a label then no need to hit API again
    //             if (listOfAllLabels.size() > 0) {
    //                 return listOfAllLabels[0].ContentDocumentId;
    //             }
    //             //Sending a request to TNT for Label
    //             else {
    //                 //Preparing XML Request
    //                 string xmlRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:con="http://schemas.datacontract.org/2004/07/ConsignmentService">';
    //                 xmlRequest += '<soapenv:Header/>';
    //                 xmlRequest += '<soapenv:Body>';       
    //                 xmlRequest += '<tem:ReprintLabelRequest>';
    //                 xmlRequest += '<tem:Request>';           
    //                 xmlRequest += '<con:UserName>' + objFreightCompanyDetails.TTI_Username__c + '</con:UserName>';
    //                 xmlRequest += '<con:Password>'+ objFreightCompanyDetails.TTI_Password__c + '</con:Password>';             
    //                 xmlRequest += '<con:ConsignmentNumber>' + objCase.Freight_out_consignment_number__c + '</con:ConsignmentNumber>';            
    //                 xmlRequest += '<con:labelType>A</con:labelType>';          
    //                 xmlRequest += '</tem:Request>';       
    //                 xmlRequest += '</tem:ReprintLabelRequest>';   
    //                 xmlRequest += '</soapenv:Body>'; 
    //                 xmlRequest += '</soapenv:Envelope>';
                    
    //                 HttpRequest httpRequest = new HttpRequest();
    //                 httpRequest.setMethod('POST');
    //                 httpRequest.setHeader('Content-Type','text/xml; charset=utf-8');
    //                 httpRequest.setHeader('SOAPAction',objFreightCompanyDetails.Label_SOAP_Action_URL__c);
    //                 httpRequest.setEndpoint(objFreightCompanyDetails.Label_End_Point_URL__c);
    //                 HttpRequest.setBody(xmlRequest);
    //                 Http http = new Http();
    //                 //Sending Request
    //                 HttpResponse httpResponse;
    //                 if (!test.isRunningTest()) {
    //                     httpResponse= http.send(httpRequest);
    //                 } else {
    //                     httpResponse = new HttpResponse();
    //                     httpResponse.setStatusCode(200);
    //                     httpResponse.setBody('<a:LabelPDF>TESTPDFDATA</a:LabelPDF>');
    //                 }

    //                 if (httpResponse.getStatusCode() == 200) {
    //                     String body = httpResponse.getBody();
    //                     //Extrating Base 64 Label PDF string from body
    //                     if (body.contains('<a:LabelPDF>')) {
    //                         string base64String = body.substringBetween('<a:LabelPDF>', '</a:LabelPDF>');
    //                         ContentVersion contentVersion_1 = new ContentVersion(
    //                             Title = objCase.CaseNumber + '_Label.pdf',
    //                             PathOnClient = objCase.CaseNumber + '_Label.pdf',
    //                             VersionData = EncodingUtil.base64Decode(base64String),
    //                             IsMajorVersion = true
    //                         );
    //                         //Inserting Label PDF as content document
    //                         insert contentVersion_1;
                            
    //                         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                            
    //                         ContentDocumentLink objDocumentLink = new ContentDocumentLink(
    //                             ContentDocumentId = contentVersion_2.ContentDocumentId,
    //                             LinkedEntityId = objCase.Id,
    //                             ShareType = 'V'
    //                         );
    //                         //Link Content Document with parent case
    //                         insert objDocumentLink;
                            
    //                         return contentVersion_2.ContentDocumentId;
    //                     } else {
    //                         return 'Consignment Number not present';
    //                     }
    //                 } else {
    //                     return 'Consignment Number not present';
    //                 }
    //             }
    //         } else {
    //             return 'Consignment Number not present';
    //         }
    //     } catch(Exception objException) {
    //         //Creating exception log
    //         TTI_LogError.createExceptionLog(objException, caseRecordString);
    //         return null;
    //     }
    // }
    //Changes done
    
    @AuraEnabled 
    public static string saveCase(string strServiceRequestCaseObj, string strAccountObj, string strProductObj, string strRetailerObj, string partsOrderedListToRemove, string ListToInsertServiceReqLineItemStr, string buttonClicked) {
        Savepoint sp = Database.setSavepoint();

        try {
            Case claim = new Case();
            Boolean displayOpenClaims = true;
            if (String.isNotBlank(strServiceRequestCaseObj)) {
                claim = (Case)JSON.deserialize(strServiceRequestCaseObj, Case.class);
                update claim;

                if ((claim.Service_Request_Milestone__c == 'Closed' || claim.Service_Request_Milestone__c == 'Completed') &&  buttonClicked == 'Save') {
                    update claim;
                }
            }

            if (String.isNotBlank(partsOrderedListToRemove)) {
                List<Service_Request_Line_Item__c> lstServiceReqLineItem = (List<Service_Request_Line_Item__c>) JSON.deserialize(partsOrderedListToRemove, List<Service_Request_Line_Item__c>.class);
                delete lstServiceReqLineItem;
            }
            
            if (String.isNotBlank(ListToInsertServiceReqLineItemStr)) {
                List<Service_Request_Line_Item__c> ListToInsertServiceReqLineItem = (List<Service_Request_Line_Item__c>) JSON.deserialize(ListToInsertServiceReqLineItemStr, List<Service_Request_Line_Item__c>.class);
                upsert ListToInsertServiceReqLineItem;
            }
                
            //INC0025540 - Copied the code in prod then made the changes - 12/15/2022 - JAC
            displayOpenClaims = isShowOpenClaims(claim, buttonClicked);
            submitCaseForApproval(claim, buttonClicked);
            submitInvoiceForApproval(claim.Id, buttonClicked);
            //INC0025540 - End

            return TTI_SearchController.doSearchServiceReq(claim.CaseNumber, displayOpenClaims);
        } catch(Exception e) {
            Database.rollback(sp);

            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    private static Boolean isShowOpenClaims(Case claim, String buttonClicked) {
        Set<String> milestoneStatus = new Set<String>{ 'Closed', 'Completed' };
        Set<String> buttons = new Set<String>{'RejectWarranty', 'RejectNonWarranty', 'ApproveNonWarranty', 'MarkAsComplete'};
        Boolean isSaveClose = milestoneStatus.contains(claim.Service_Request_Milestone__c) &&  buttonClicked == 'Save';
        return !(buttons.contains(buttonClicked) || isSaveClose);
    }

    private static void submitCaseForApproval(Case claim, String button) {
        String inProgressStatus = 'In Progress';
        Boolean isInProgress = claim.Service_Request_Milestone__c.equalsIgnoreCase(inProgressStatus);
        Boolean isWarrantyClaim = claim.Claim_Type__c == 'Warranty';
        if ((isInProgress && button == 'Save') || button == 'SubmitForApproval') {
            if (isWarrantyClaim) {
                submitForApprovalMethod(claim.Id);
            } else {
                claim.status = inProgressStatus;
                claim.Service_Request_Milestone__c = inProgressStatus;
                claim.Auto_Approved__c = true; 
                claim.Approved_Flag__c = true;
                claim.Approved_Date__c = Datetime.now();
                claim.Number_of_Interactions__c =  claim.Number_of_Interactions__c + 1;
                update claim;
            }
        }
    }

    private static void submitInvoiceForApproval(String caseId, String button) {
        Boolean isMarkCompleteAction = button == 'MarkAsComplete';
        if (isMarkCompleteAction) {
            submitInvoiceForApprovalMethod(caseId);
        }
    }

    @AuraEnabled
    public static void handleEmailPart(string caseId, string operation) {
        Case objCase = new Case(Id = caseId);
        TTI_PdfAndEmailHandler.handleEmailAndAttachmentProcess(objCase, operation);
    } 
    
    @AuraEnabled
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField) {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            
            TTI_MyPickListInfo info = (TTI_MyPickListInfo) JSON.deserialize(jsonString, TTI_MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            
            Integer baseCount = 0;
            
            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }
                
                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }                    

                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());    
                }                    

                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());       
                }
                    
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());
                }
                
                baseCount += 4;
            }            
        } 
        
        return controllingInfo;
    }
    
    @AuraEnabled
    public static String saveReplishmentHeaderAndItsLineItem(String objReplenishmentHeaderStr, String lstReplenishmentLineItemStr, String lstRemoveReplenishmentLineItemStr) {
        TTI_Replenishment_Header__c objRepHeader = (TTI_Replenishment_Header__c) JSON.deserialize(objReplenishmentHeaderStr, TTI_Replenishment_Header__c.class);
        if (objRepHeader.TTI_Status__c == 'Submitted') {
            objRepHeader.TTI_Submitted_Date__c = date.today();
        }
        upsert objRepHeader;

        if (!String.isBlank(lstReplenishmentLineItemStr)) {
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItems = (List<TTI_Replenishment_Line_Item__c>) JSON.deserialize(lstReplenishmentLineItemStr, List<TTI_Replenishment_Line_Item__c>.class);
            for (TTI_Replenishment_Line_Item__c objRepHeaderLineItem :lstRepHeaderLineItems) {
                if (String.isBlank(objRepHeaderLineItem.id))
                    objRepHeaderLineItem.TTI_Replenishment_Header__c=objRepHeader.Id;
            }
            upsert lstRepHeaderLineItems;
        }

        if (!String.isBlank(lstRemoveReplenishmentLineItemStr)) {
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItemsRemove = (List<TTI_Replenishment_Line_Item__c>) JSON.deserialize(lstRemoveReplenishmentLineItemStr, List<TTI_Replenishment_Line_Item__c>.class);
            delete lstRepHeaderLineItemsRemove;
        }
        return objRepHeader.Id;        
    }
    
    @AuraEnabled
    public static List<ProductParts__c> fetchBillOfMaterials(String productToolId) {
        return [SELECT Id, ProductPart__c, ProductPart__r.Description, ProductPart__r.SOH_BP01__c, ProductPart__r.SOH_BP05__c,
                       ProductPart__r.SOH_BP06__c, ProductPart__r.BP05_Bin__c, ProductPart__r.BP06_Bin__c, Quantity__c, 
                       ProductPart__r.AU_ListPrice__c, ProductPart__r.NZ_ListPrice__c, ProductPart__r.ProductCode 
                  FROM ProductParts__c 
                 WHERE ProductTool__c = :productToolId];
    }
    
    @AuraEnabled
    public static TTI_Replenishment_Header__c fetchReplenishmentRecord(String recordId) {
        return [SELECT Id, TTI_Purchase_Order_Reference__c, TTI_Status__c, TTI_Service_Agent__c, TTI_Service_Agent__r.Company_Code__c,
                           (SELECT Id, TTI_SKU_Number__c, TTI_Product_Number__r.SOH_BP01__c, TTI_Product_Number__r.SOH_BP05__c,
                                   TTI_Product_Number__r.SOH_BP06__c, TTI_Product_Number__r.BP05_Bin__c, TTI_Product_Number__r.BP06_Bin__c,
                                   TTI_Product_Number__r.Description, TTI_Consignment_Number__c, TTI_Quantity__c, TTI_Unit_Cost__c, TTI_Total_Cost__c 
                              FROM Replenishment_Line_Items__r) 
                  FROM TTI_Replenishment_Header__c 
                 WHERE Id = :recordId];
    }
    
    @AuraEnabled
    public static String getCasedeatils(String whereQuery, String fields) {
        List<Case> lstcase = new List<Case>();
        String result = '';

        if (fields != null && fields != '' && whereQuery != null && whereQuery != '') {
            String strQuery = 'SELECT ' + fields + ' FROM Case WHERE ' + whereQuery;
            lstcase = Database.query(strQuery);
            result = JSON.serialize(lstcase);
        }       
        return result;
    }
    
    @AuraEnabled
    public static String doSearchServiceReq(String CaseNumber) {
        try {
            return TTI_SearchController.doSearchServiceReq(CaseNumber, false);
        } catch(Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }
    
    @AuraEnabled
    public static String openReceiptPdf(String receiptId) {
        List<Attachment> lstAttachment = [SELECT Id,Body,ContentType FROM Attachment WHERE ParentId = :receiptId];
        if (lstAttachment != null && lstAttachment.size() > 0) {
            Attachment objAttachment = lstAttachment[0];
            Blob blobBody = objAttachment.Body;
            String pdfString = EncodingUtil.base64Encode(blobBody);
            
            if (Test.isRunningTest()) {
                pdfString += ':' + blob.valueOf('Unit.Test');
            } else {
                pdfString += ':'+ objAttachment.ContentType;
            }
            
            return pdfString;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean serviceRequestHasHAWAProducts(String caseNumber) {
        if (!String.isBlank(caseNumber)) {
            Set<Id> prodIds = new Set<Id>();

            for (Service_Request_Line_Item__c serviceReq :[SELECT Part_Number__r.Id FROM Service_Request_Line_Item__c WHERE Service_Request_Number__r.CaseNumber = :caseNumber]) {
                if (!prodIds.contains(serviceReq.Part_Number__r.Id)) {
                    prodIds.add(serviceReq.Part_Number__r.Id);
                }
            }

            if (!prodIds.isEmpty()) {
                for (Product2 prod :[SELECT SAP_Material_Type__c FROM Product2 WHERE Id IN :prodIds]) {
                    if (prod.SAP_Material_Type__c == 'HAWA') {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    @AuraEnabled
    public static String getCase(String caseNumber) {
        return JSON.serialize([SELECT Id, CaseNumber, SuppliedEmail, Brand__c, Service_Agent__r.Name, Service_Agent__r.Internal_Service_Agent__c, TTI_Service_Agent_Job_Number__c, 
                                      TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Pickup_State__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_PickUp_Address__c, 
                                      TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Address__c, 
                                      Contact.Email, Contact.Phone, TTI_Customer_Account__r.Name, TTI_Customer_Account__r.Phone, Service_Agent__r.Company_Code__c,
                                      Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Weight__c, 
                                      Product_Name__r.Width__c, Product_Name__r.Dangerous_Goods_Text__c, Service_Agent__r.Freight_Company__c, FreightOutDeliverTo__c
                                 FROM Case 
                                WHERE CaseNumber = :caseNumber][0]);
    }

    @AuraEnabled
    public static String updateCase(String caseJSON) {
        try {
            Case claim = (Case) JSON.deserialize(caseJSON, Case.class);
            update claim;

            return TTI_SearchController.doSearchServiceReq(claim.CaseNumber, false);
        } catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());
            throw exc;
        }
    }

    @AuraEnabled
    public static void updateFreightAddress(String caseJson) {

        if (!String.isBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);

            if (!String.isBlank(caseRec.CaseNumber)) {
                try {
                    update caseRec;
                } catch(Exception e) {
                    AuraHandledException exc = new AuraHandledException('Error updating address. Please contact your administrator.');
                    exc.setMessage('Error updating address. Please contact your administrator.');
                    throw exc;
                }
            }
        }
    }

    @AuraEnabled
    public static String createShipment(String caseJson) {
        return TTI_FreightManagementController.createShipment(caseJson);
    }
    
    @AuraEnabled
    public static String deleteShipment(String caseId, String shipmentId) {
        return TTI_FreightManagementController.deleteShipment(caseId, shipmentId);
    }

    @AuraEnabled
    public static String createLabel(String caseJson, String shipmentId, String format) {
        return TTI_FreightManagementController.createLabel(caseJson, shipmentId, format);
    }

    @AuraEnabled
    public static String getLabel(String caseJson, String requestId) {
        return TTI_FreightManagementController.getLabel(caseJson, requestId);
    }

    @AuraEnabled
    public static String getDangerousGoodsForm(String caseJson, String shipmentId) {
        String response = '';
        if (!String.isBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);

            if (String.isNotBlank(shipmentId)) {
                try {

                    Service_Portal_Freight_Configuration__mdt config = configFreightMap.get(getFreightConfigLabel(caseRec));

                    response = JSON.serialize(SpShippingAndTrackingAup.getDangerousGoodsForm(config.Account_Number__c, shipmentId));
                } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                    throw TTI_FreightManagementController.getAuraException(JSON.serialize(new TTI_FreightManagementController.AuraWrapperClass(e.errors, e.statusCode, '')));
                }
            } else {
                throw TTI_FreightManagementController.getAuraException(JSON.serialize(TTI_FreightManagementController.GENERIC_ERROR));
            }
        } else {
            throw TTI_FreightManagementController.getAuraException(JSON.serialize(TTI_FreightManagementController.GENERIC_ERROR));
        }
        return response;
    }

    private static String getFreightConfigLabel(Case caseRec) {
        if (caseRec != null) {
            String freightConfigLabel = '';

            if (caseRec.Service_Agent__r.Company_Code__c == 'BP01') {
                freightConfigLabel += 'AU_';
            } else if (caseRec.Service_Agent__r.Company_Code__c == 'NZ01') {
                freightConfigLabel += 'NZ_';
            } else {
                return null;
            }

            if (caseRec.Service_Agent__r.Freight_Company__c != null) {
                freightConfigLabel += caseRec.Service_Agent__r.Freight_Company__c + '_';
            } else {
                return null;
            }

            if (caseRec.Brand__c != null) {
                freightConfigLabel += caseRec.Brand__c;
            } else {
                return null;
            }

            return freightConfigLabel;
        } else {
            return null;
        }
    }
    
    //Below method added by Upendra Kumar
    //Method will return true if there is a attachment under claim else return false
    // 19/10/2018 Francis Nasalita - returns false if the Total Sundry Expense is null or 0
    //                             - added null checker for list before looping
    @AuraEnabled
    public static boolean isAttachmentRequired(string objCaseString) {
        Case objCase = (Case)JSON.deserialize(objCaseString, Case.Class);
        decimal totalClaimSum = 0;
        date monthFirstDate = Date.newInstance(System.today().Year(), System.today().month(), 1);
        date monthLastDate = Date.newInstance(System.today().Year(), System.today().month() + 1, 1);
        
        list<Case> listOfDetailedCase = [SELECT Id, Service_Agent__c, 
                                                Service_Agent__r.Max_Claimable_Sundry_Expenses__c, 
                                                Total_Sundry_Expenses__c 
                                           FROM Case
                                          WHERE Service_Agent__c = :objCase.Service_Agent__c
                                            AND Invoiced_Approved__c = true
                                            AND Completion_Date__c >= :monthFirstDate 
                                            AND Completion_Date__c < :monthLastDate
                                            AND RecordType.Name = 'Service Request'
                                            AND Id != :objCase.Id];
        
        if (objCase.Total_Sundry_Expenses__c == null || objCase.Total_Sundry_Expenses__c == 0) {
            return false;
        } else {
            totalClaimSum += objCase.Total_Sundry_Expenses__c;
        }

        if (!listOfDetailedCase.isEmpty()) {
            For (Case objDetailedCase :listOfDetailedCase) {
                if (objDetailedCase.Total_Sundry_Expenses__c != null) {
                    totalClaimSum += objDetailedCase.Total_Sundry_Expenses__c;
                }
            }
        }
            
        if (totalClaimSum > objCase.Service_Agent__r.Max_Claimable_Sundry_Expenses__c) {
            return true;
        }
        return false;
    }
    //Changes done

    @AuraEnabled
    public static boolean hasHAWAProducts(List<Id> productIds) {
        return ((Integer) [SELECT COUNT(Id) hasHawa FROM Product2 WHERE SAP_Material_Type__c = 'HAWA' AND Id IN :productIds][0].get('hasHawa')) > 0;
    }

    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }

    @AuraEnabled(cacheable=true)
    public static String getRCTIPdf(String awsKey) {
        return AwsService.getFileFromS3Bucket(awsKey, RCTI_BUCKET_NAME);
    }

    @AuraEnabled
    public static Case getAwsKey(String caseNumber) {
        return [SELECT AWS_Invoice_File_Key__c, 
                       Service_Request_Milestone__c, 
                       Total_Invoice_Amount__c, 
                       Invoice_Number_PC__c 
                  FROM Case 
                 WHERE CaseNumber = :caseNumber LIMIT 1];
    }

    @AuraEnabled
    public static String insertSystemlog(String logType, String logValue, String logModule) {
        List<System_Log__e> logEvents = new List<System_Log__e>();
        List<Map<String, String>> errorMap = new List<Map<String, String>> {
            new Map<String,String> {
                'type' => logType, 
                'value' => logValue,
                'module' => logModule
            }
        };

        logEvents.add(new System_Log__e(
            Level__c = 'error',
            Payload__c = JSON.serialize(errorMap)
        ));

        System.debug('System Log: ' + logEvents);
        return JSON.serialize(logEvents);
        // SD-1286 - Disable System Logs
        // List<Database.SaveResult> results = EventBus.publish(logEvents);
        // return JSON.serialize(results);
    }

    //INC0027580 - Updated requirement to remove the field in the portal - 01/18/2023 - JAC
    //@AuraEnabled
    //public static Boolean getServiceOperaionPermission(){
    //    List<Id> permissionList = new List<Id>();
    //    for (PermissionSetAssignment permissionSet : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Label = 'Service Operation']) {
    //        permissionList.add(permissionSet.AssigneeId);
            
    //    }        
        
    //    if(permissionList.contains(UserInfo.getUserId())){
    //        return true;
    //    }else{
    //        return false;
    //    }

    //}
    //INC0027580 - End
}