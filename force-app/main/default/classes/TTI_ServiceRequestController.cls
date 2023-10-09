public without sharing class TTI_ServiceRequestController {

    @AuraEnabled
    public static String getApprovalProcessLastStep(String targetObjectId) {
        return (targetObjectId != '' && targetObjectId != null) ? JSON.serialize(UtilityClass.getApprovalProcessLastStep(targetObjectId)) : null;
    }
    
    @AuraEnabled
    public static string getCurrentUser() {
        string userDetails=UserInfo.getUserId()+':'+UserInfo.getName();
        return userDetails;
    }
    
    @AuraEnabled
    public static string getInCompletedTasks(string caseId) {
        List<Task> listTask=[SELECT Subject,ActivityDate,OwnerId,Owner.Name,WhatId FROM Task WHERE WhatId=:caseId AND Status!='Completed'];
        if (listTask!=null && listTask.size() > 0) {
            return JSON.serialize(listTask);
        }
        return null;
    }
    
    @AuraEnabled
    public static User getUserType() {
        // FNasalita  Sept 11, 2018 [SAL-429] - Added Account.Company_Code__c to the query
        User userType = [SELECT Id, Account.RecordTypeId, Account.RecordType.Name, Account.Internal_Service_Agent__c, AccountId, UserRole.Name, Account.Delivery_Country__c ,
                         Account.Allow_Delivery_to_Customers__c,Account.BillingAddress, Account.ShippingStreet,Account.ShippingCity, Account.ShippingCountry, Account.ShippingState,
                         Account.ShippingPostalCode, Account.Delivery_Street__c, Account.Delivery_Suburb__c, Account.Delivery_State__c, Account.Delivery_Postcode__c, Account.Company_Code__c, 
                         Account.MX_Authorised__c
                         FROM User WHERE id=:UserInfo.getUserId()];
        if (userType != null) {
            return userType;
        }
        return null;
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
        try {
            Case objCase = new Case();
            if (strServiceRequestCaseObj !=null ||strServiceRequestCaseObj !='') {
                objCase =(Case)JSON.deserialize(strServiceRequestCaseObj,Case.class);
                if (objCase.Total_Sundry_Expenses__c != null && objCase.Service_Agent__c != null) {
                    //Getting All GST rates
                    Map<String, GST_Rates__c> GSTRateslist = GST_Rates__c.getAll();
                    
                    //GST calculation for Australia
                    if (objCase.Service_Agent__r.Delivery_Country__c == 'Australia' && objCase.Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('Australia').GST_Rate__c != null) {
                            objCase.Sundry_Expense_GST_Payable__c = (objCase.Total_Sundry_Expenses__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                        }
                    }
                    // GST calculation for New Zealand 
                    else if (objCase.Service_Agent__r.Delivery_Country__c == 'New Zealand' && objCase.Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                            objCase.Sundry_Expense_GST_Payable__c = (objCase.Total_Sundry_Expenses__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                        }
                    }
                    // Total Sundry Expenses calculation
                    if (objCase.Sundry_Expense_GST_Payable__c != null) {
                        objCase.Total_Sundry_Expenses_Inc_GST__c = objCase.Total_Sundry_Expenses__c + objCase.Sundry_Expense_GST_Payable__c;
                    }
                }
            }
            return JSON.serialize(objCase);
        }
        catch (Exception objException){
            // Creating exception log
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
    
    @AuraEnabled 
    public static string generateLabelPdfForAU(string caseRecordString) {
        try {
            Case objCase = (Case)JSON.deserialize(caseRecordString,Case.class);
            // Getting Frieght Company API Details TNT company
            TTI_Frieght_Company_API_Details__c objFreightCompanyDetails = TTI_Frieght_Company_API_Details__c.getValues('TNT');
            // Checking if Freight out consignment number is null or not
            if (objCase.Freight_out_consignment_number__c != null) {
                list<ContentDocumentLink> listOfAllLabels = new list<ContentDocumentLink>();
                for (ContentDocumentLink ObjLink : [SELECT ContentDocumentId, 
                                                   ContentDocument.Title, 
                                                   ContentDocument.FileExtension, 
                                                   ContentDocument.FileType FROM 
                                                   ContentDocumentLink WHERE 
                                                   LinkedEntityId =: objCase.Id]) {
                                                       if (ObjLink.ContentDocument.Title.contains('Label')) {
                                                           listOfAllLabels.add(ObjLink);
                                                       }
                                                   }
                // Checking if case has already a label then no need to hit API again
                if (listOfAllLabels.size() > 0) {
                    return listOfAllLabels[0].ContentDocumentId;
                }
                // Sending a request to TNT for Label
                else {
                    // Preparing XML Request
                    string xmlRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:con="http://schemas.datacontract.org/2004/07/ConsignmentService">';
                    xmlRequest += '<soapenv:Header/>';
                    xmlRequest += '<soapenv:Body>';       
                    xmlRequest += '<tem:ReprintLabelRequest>';
                    xmlRequest += '<tem:Request>';           
                    xmlRequest += '<con:UserName>' + objFreightCompanyDetails.TTI_Username__c + '</con:UserName>';
                    xmlRequest += '<con:Password>'+ objFreightCompanyDetails.TTI_Password__c + '</con:Password>';             
                    xmlRequest += '<con:ConsignmentNumber>' + objCase.Freight_out_consignment_number__c + '</con:ConsignmentNumber>';            
                    xmlRequest += '<con:labelType>A</con:labelType>';          
                    xmlRequest += '</tem:Request>';       
                    xmlRequest += '</tem:ReprintLabelRequest>';   
                    xmlRequest += '</soapenv:Body>'; 
                    xmlRequest += '</soapenv:Envelope>';
                    
                    HttpRequest httpRequest = new HttpRequest();
                    httpRequest.setMethod('POST');
                    httpRequest.setHeader('Content-Type','text/xml; charset=utf-8');
                    httpRequest.setHeader('SOAPAction',objFreightCompanyDetails.Label_SOAP_Action_URL__c);
                    httpRequest.setEndpoint(objFreightCompanyDetails.Label_End_Point_URL__c);
                    HttpRequest.setBody(xmlRequest);
                    Http http = new Http();
                    // Sending Request
                    HttpResponse httpResponse;
                    if (!test.isRunningTest()) {
                    httpResponse= http.send(httpRequest);
                    } else {
                        httpResponse = new HttpResponse();
                        httpResponse.setStatusCode(200);
                        httpResponse.setBody('<a:LabelPDF>TESTPDFDATA</a:LabelPDF>');
                    }
                    if (httpResponse.getStatusCode() == 200) {
                        String body = httpResponse.getBody();
                        // Extrating Base 64 Label PDF string from body
                        if (body.contains('<a:LabelPDF>')) {
                            string base64String = body.substringBetween('<a:LabelPDF>', '</a:LabelPDF>');
                            ContentVersion contentVersion_1 = new ContentVersion(
                                Title = objCase.CaseNumber + '_Label.pdf',
                                PathOnClient = objCase.CaseNumber + '_Label.pdf',
                                VersionData = EncodingUtil.base64Decode(base64String),
                                IsMajorVersion = true
                            );
                            // Inserting Label PDF as content document
                            insert contentVersion_1;
                            
                            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                            
                            ContentDocumentLink objDocumentLink = new ContentDocumentLink(
                                ContentDocumentId = contentVersion_2.ContentDocumentId,
                                LinkedEntityId = objCase.Id,
                                ShareType = 'V'
                            );
                            // Link Content Document with parent case
                            insert objDocumentLink;
                            
                            return contentVersion_2.ContentDocumentId;
                        } else {
                            return 'Consignment Number not present';
                        }
                    } else {
                        return 'Consignment Number not present';
                    }
                }
            } else {
                return 'Consignment Number not present';
            }
        } catch (Exception objException) {
            // Creating exception log
            TTI_LogError.createExceptionLog(objException, caseRecordString);
            return null;
        }
    }
    
/*
*  Name :- Upendra Kumar
*  Created Date:- 20/09/2018
*  Purpose:- This method is used to get Label PDF for Courier Post
*  Modified By :-
*  Purpose :-
*  Modidired Date :-
*/    
 /* ===============================================================================================================================   
    @AuraEnabled 
    public static string generateLabelPdfForNZ(string caseRecordString){
        try{
            Case objCase = (Case)JSON.deserialize(caseRecordString,Case.class);
            //Getting Frieght Company API Details TNT company
            TTI_Frieght_Company_API_Details__c objFreightCompanyDetails = TTI_Frieght_Company_API_Details__c.getValues('Courier Post');
            //Checking if Freight out consignment number is null or not
            if(objCase.Freight_out_consignment_number__c != null){
                list<ContentDocumentLink> listOfAllLabels = new list<ContentDocumentLink>();
                for(ContentDocumentLink ObjLink : [SELECT ContentDocumentId, 
                                                   ContentDocument.Title, 
                                                   ContentDocument.FileExtension, 
                                                   ContentDocument.FileType FROM 
                                                   ContentDocumentLink WHERE 
                                                   LinkedEntityId =: objCase.Id]){
                                                       if(ObjLink.ContentDocument.Title.contains('Label')){
                                                           listOfAllLabels.add(ObjLink);
                                                       }
                                                   }
                //Checking if case has already a label then no need to hit API again
                if(listOfAllLabels.size() > 0){
                    return listOfAllLabels[0].ContentDocumentId;
                }
                //Under build
                else{
                    return 'Consignment Number not present';
                }
            }
            else{
                return 'Consignment Number not present';
            }
        }
        catch(Exception objException){
            TTI_LogError.createExceptionLog(objException, caseRecordString);
            return null;
        }
    }
=============================================================================================================================*/    
    //Changes done
    
    @AuraEnabled 
    public static string saveCase(string strServiceRequestCaseObj,string strAccountObj,string strProductObj,string strRetailerObj,string partsOrderedListToRemove,string ListToInsertServiceReqLineItemStr,string buttonClicked){
        try{
            Case objCase = new Case();
            if(strServiceRequestCaseObj !=null ||strServiceRequestCaseObj !=''){
                objCase =(Case)JSON.deserialize(strServiceRequestCaseObj,Case.class);
                update objCase;
            }
            if(partsOrderedListToRemove !=null ||partsOrderedListToRemove !=''){
                List<Service_Request_Line_Item__c> lstServiceReqLineItem=(List<Service_Request_Line_Item__c>)JSON.deserialize(partsOrderedListToRemove,List<Service_Request_Line_Item__c>.class);
                delete lstServiceReqLineItem;
            }
            
            if(ListToInsertServiceReqLineItemStr!=null && ListToInsertServiceReqLineItemStr!='')
            {
                List<Service_Request_Line_Item__c> ListToInsertServiceReqLineItem=(List<Service_Request_Line_Item__c>)JSON.deserialize(ListToInsertServiceReqLineItemStr,List<Service_Request_Line_Item__c>.class);
                upsert ListToInsertServiceReqLineItem;
            }
            if(objCase.TTI_Send_Quote__c){
               // TTI_PdfAndEmailHandler.handleEmailAndAttachmentProcess(objCase,'QuoteGeneration'); 
                
            }
            if((objCase.Service_Request_Milestone__c=='In Progress' && objCase.Claim_Type__c=='Warranty' && buttonClicked=='Save')
              || buttonClicked=='SubmitForApproval')
            {
               submitForApprovalMethod(objCase.Id);
            }
            
            if (buttonClicked=='MarkAsComplete')
            {
                //TTI_PdfAndEmailHandler.handleEmailAndAttachmentProcess(objCase,'JobSummaryGeneration');
                submitInvoiceForApprovalMethod(objCase.Id);
                
            }
            Boolean displayOpenClaims=true;
            if (buttonClicked=='RejectWarranty' || buttonClicked=='RejectNonWarranty' || buttonClicked=='ApproveNonWarranty' || buttonClicked=='MarkAsComplete')
            {
               displayOpenClaims=false;
            }
            return TTI_SearchController.doSearchServiceReq(String.valueOf(objCase.CaseNumber), displayOpenClaims);
            
        } catch(Exception e){
            //return e.getStackTraceString()+ ';'+ e.getMessage();

            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
        
    }
    
    @AuraEnabled
    public static void handleEmailPart(string caseId,string operation){
        Case objCase =new Case(Id=caseId);
        TTI_PdfAndEmailHandler.handleEmailAndAttachmentProcess(objCase,operation);
    }
    
    @AuraEnabled
    public static string sendFreightCompanyRequest(Id caseId,string TriggerPoint)
    {
        TTI_FreightCompanyAPIResponse objResponse = new TTI_FreightCompanyAPIResponse();
        List<Case> lstCases=[select id, CaseNumber,TTI_Freight_In_Required__c,TTI_Freight_Out_Required__c,Product_Name__r.ProductCode,
                             Product_Name__r.Height__c,Product_Name__r.Width__c,Product_Name__r.Length__c,Product_Name__r.Weight__c,
                             Service_Agent__r.Name,Service_Agent__r.Phone,Retailer_Account__r.Name,Retailer_Account__r.Phone,
                             Service_Agent__r.Freight_Company__c,Service_Agent__r.Freight_Company_Account_Number__c,
                             TTI_Customer_Account__r.Name,TTI_Customer_Account__r.PersonMobilePhone,
                             TTI_Customer_Account__r.PersonEmail,TTI_Freight_In_PickUp_Address__c,TTI_Brand_Service_Phone__c
                             ,TTI_Freight_In_Pickup_Suburb__c,TTI_Freight_In_Pickup_State__c,TTI_Freight_In_Pickup_Postcode__c,
                             TTI_Freight_Out_PickUp_Address__c,TTI_Freight_Out_Pickup_Suburb__c,TTI_Freight_Out_Pickup_State__c,
                             TTI_Freight_Out_Pickup_Postcode__c,TTI_Freight_In_Delivery_Address__c,Freight_in_consignment_number__c,
                             Freight_out_consignment_number__c,Service_Request_Milestone__c,
                             TTI_Freight_In_Delivery_Suburb__c,TTI_Freight_In_Delivery_Postcode__c,TTI_Freight_In_Delivery_State__c,
                             TTI_Freight_Out_Delivery_Address__c,TTI_Freight_Out_Delivery_Suburb__c,TTI_Freight_Out_Delivery_State__c,
                             TTI_Freight_Out_Delivery_Postcode__c FROM case WHERE id = : caseId];
        TTI_FreightCompanyAPI.sendFreightCompanyRequest(lstCases,TriggerPoint,objResponse);
        Case objCase=lstCases[0];
        objCase.TTI_Freight_in_API_Request__c=objResponse.inputRequest;
        if(objResponse.Tracking_references!=null && objResponse.Tracking_references!=''){
            //objCase.Invoiced_Approved__c=true;
            objCase.Freight_out_consignment_number__c = objResponse.Tracking_references;
            if(objCase.Service_Agent__r.Freight_Company__c == 'TNT'){
                objCase.TTI_Freight_out_tracking_url__c='http://www.tntexpress.com.au/interaction/track.aspx?con='+objResponse.Tracking_references;
            }
            if(objCase.Service_Agent__r.Freight_Company__c == 'Courier Post'){
                objCase.TTI_Freight_out_tracking_url__c=' http://trackandtrace.courierpost.co.nz/Search/'+objResponse.Tracking_references;
            }
            
        }
        if(objResponse.Success==false)
        {
            //objCase.Invoiced_Approved__c=false;
            objCase.Freight_Error_Text__c=objResponse.Error_message;
            objCase.Status='Integration Error';
            if(objCase.Service_Request_Milestone__c == 'Closed'){
                objCase.Service_Request_Milestone__c='Completed';
                objCase.Closed_Reason__c='';
            }
        }
        update objCase;
        return JSON.serialize(objResponse);
        
    }
    @AuraEnabled
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            TTI_MyPickListInfo info = (TTI_MyPickListInfo) JSON.deserialize(jsonString, TTI_MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        
        
        return controllingInfo;
    }
    
    @AuraEnabled
    public static string saveReplishmentHeaderAndItsLineItem(string objReplenishmentHeaderStr,string lstReplenishmentLineItemStr,string lstRemoveReplenishmentLineItemStr)
    {
        TTI_Replenishment_Header__c objRepHeader=(TTI_Replenishment_Header__c)JSON.deserialize(objReplenishmentHeaderStr,TTI_Replenishment_Header__c.class);
        if(objRepHeader.TTI_Status__c=='Submitted'){
            objRepHeader.TTI_Submitted_Date__c=date.today();
        }
        upsert objRepHeader;
        if(!string.isBlank(lstReplenishmentLineItemStr)){
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItems=(List<TTI_Replenishment_Line_Item__c>)JSON.deserialize(lstReplenishmentLineItemStr,List<TTI_Replenishment_Line_Item__c>.class);
            for(TTI_Replenishment_Line_Item__c objRepHeaderLineItem : lstRepHeaderLineItems)
            {
                if(string.isBlank(objRepHeaderLineItem.id))
                {
                    objRepHeaderLineItem.TTI_Replenishment_Header__c=objRepHeader.Id;
                }
            }
            upsert lstRepHeaderLineItems;
        }
        if(!string.isBlank(lstRemoveReplenishmentLineItemStr)){
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItemsRemove=(List<TTI_Replenishment_Line_Item__c>)JSON.deserialize(lstRemoveReplenishmentLineItemStr,List<TTI_Replenishment_Line_Item__c>.class);
            delete lstRepHeaderLineItemsRemove;
        }
        return objRepHeader.Id;
        
    }
    
    @AuraEnabled
    public static List<ProductParts__c> fetchBillOfMaterials(string productToolId)
    {
        List<ProductParts__c> lstProdPart = [SELECT Id,ProductPart__c,ProductPart__r.Description,ProductPart__r.SOH_BP01__c,ProductPart__r.SOH_BP05__c,
                                             ProductPart__r.SOH_BP06__c,ProductPart__r.BP05_Bin__c,ProductPart__r.BP06_Bin__c,Quantity__c,ProductPart__r.AU_ListPrice__c,ProductPart__r.NZ_ListPrice__c,ProductPart__r.ProductCode FROM ProductParts__c WHERE ProductTool__c=:productToolId];
        return lstProdPart;
    }
    
    @AuraEnabled
    public static TTI_Replenishment_Header__c fetchReplenishmentRecord(string recordId){
        TTI_Replenishment_Header__c objRep=[SELECT Id,TTI_Purchase_Order_Reference__c,TTI_Status__c,
                                            (SELECT Id,TTI_SKU_Number__c,TTI_Product_Number__r.SOH_BP01__c,TTI_Product_Number__r.SOH_BP05__c,
                                             TTI_Product_Number__r.SOH_BP06__c,TTI_Product_Number__r.BP05_Bin__c,TTI_Product_Number__r.BP06_Bin__c,TTI_Product_Number__r.Description,TTI_Consignment_Number__c,TTI_Quantity__c,TTI_Unit_Cost__c,TTI_Total_Cost__c FROM Replenishment_Line_Items__r) FROM TTI_Replenishment_Header__c WHERE Id=:recordId];
        return objRep;
    }
    
    @AuraEnabled
    public static String getCasedeatils(String whereQuery, String fields){
        List<Case> lstcase= new List<Case>();
        string result='';
        if(fields != null && fields != '' && whereQuery != null && whereQuery != ''){
            String strQuery = 'SELECT '+fields+' FROM Case WHERE '+ whereQuery;
            lstcase= Database.query(strQuery);
            result = JSON.serialize(lstcase);
        }
       
        return result;
    }
    
    @AuraEnabled
    public static string doSearchServiceReq(string CaseNumber){
        try {
            return TTI_SearchController.doSearchServiceReq(String.valueOf(CaseNumber), false);
        } catch(Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }        
    }
    
    @AuraEnabled
    public static string openReceiptPdf(string receiptId){
        List<Attachment> lstAttachment=[SELECT Id,Body,ContentType FROM Attachment WHERE ParentId=:receiptId];
        if(lstAttachment!=null && lstAttachment.size()>0)
        {
            Attachment objAttachment= lstAttachment[0];
            Blob blobBody=objAttachment.Body;
            String pdfString=EncodingUtil.base64Encode(blobBody);
            return pdfString+':'+objAttachment.ContentType;
             
        }
        else
        {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean serviceRequestHasHAWAProducts(String caseNumber) {
        if(!String.isBlank(caseNumber)) {
            Set<Id> prodIds = new Set<Id>();

            for(Service_Request_Line_Item__c serviceReq :[SELECT Part_Number__r.Id FROM Service_Request_Line_Item__c WHERE Service_Request_Number__r.CaseNumber = :caseNumber]) {
                if(!prodIds.contains(serviceReq.Part_Number__r.Id)) {
                    prodIds.add(serviceReq.Part_Number__r.Id);
                }
            }

            if(!prodIds.isEmpty()) {
                for(Product2 prod :[SELECT SAP_Material_Type__c FROM Product2 WHERE Id IN :prodIds]) {
                    if(prod.SAP_Material_Type__c == 'HAWA') {
                        return true;   
                    }
                }

                return false;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    
    //Below method added by Upendra Kumar
    //Method will return true if there is a attachment under claim else return false
    // 19/10/2018 Francis Nasalita - returns false if the Total Sundry Expense is null or 0
    //                             - added null checker for list before looping
    @AuraEnabled
    public static boolean isAttachmentRequired(string objCaseString){
        Case objCase = (Case)JSON.deserialize(objCaseString, Case.Class);
        decimal totalClaimSum = 0;
        date monthFirstDate = Date.newInstance(System.today().Year(), System.today().month(), 1);           
        date monthLastDate = Date.newInstance(System.today().Year(), System.today().month() + 1, 1);
        
        list<Case> listOfDetailedCase = [SELECT Id, Service_Agent__c, 
                                         Service_Agent__r.Max_Claimable_Sundry_Expenses__c, 
                                         Total_Sundry_Expenses__c FROM Case
                                         WHERE Service_Agent__c =: objCase.Service_Agent__c
                                         AND Invoiced_Approved__c = true
                                         AND Completion_Date__c >=: monthFirstDate 
                                         AND Completion_Date__c <: monthLastDate
                                         AND RecordType.Name = 'Service Request'
                                         AND Id !=: objCase.Id];
        
        if(objCase.Total_Sundry_Expenses__c == null || objCase.Total_Sundry_Expenses__c == 0) 
            return false;
        else 
            totalClaimSum += objCase.Total_Sundry_Expenses__c;

        if(!listOfDetailedCase.isEmpty()) {
            For(Case objDetailedCase : listOfDetailedCase){
                if(objDetailedCase.Total_Sundry_Expenses__c != null) totalClaimSum += objDetailedCase.Total_Sundry_Expenses__c;
            }
        }
            
        if(totalClaimSum > objCase.Service_Agent__r.Max_Claimable_Sundry_Expenses__c){
            return true;
        }
        return false;
    }
    //Changes done
}