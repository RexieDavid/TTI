public class TTI_CaseTriggerHandler {

    /**
    * @author: Shivam Singh
    * @date: Jan 2018
    * @description: Delete receipt and quotePdf.
    */
    public static Boolean stopRecusion = false;

    public static void deleteReceiptAndQuotePdf(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Set<Id> caseObjId = new Set<Id>();

        for (Case caseObj : newCaseList) {
            if ((oldCaseMap.get(caseObj.Id).Invoice_Number_PC__c == null || oldCaseMap.get(caseObj.Id).Invoice_Number_PC__c == '') && caseObj.Invoice_Number_PC__c != null && caseObj.Invoice_Number_PC__c != '' && (caseObj.SAP_Error_Text__c == null || caseObj.SAP_Error_Text__c == '') && (caseObj.Freight_Error_Text__c == null || caseObj.Freight_Error_Text__c == '') && (caseObj.TTI_Freight_Out_Required__c == false || (caseObj.TTI_Freight_Out_Required__c == true && (caseObj.Freight_out_consignment_number__c != null || caseObj.Freight_out_consignment_number__c != '')))) {
                caseObjId.add(caseObj.Id);
                caseObj.Status = 'Closed';
                caseObj.Service_Request_Milestone__c = 'Closed';
                caseObj.Closed_Reason__c = 'Service Request Completed';
                caseObj.TTI_CreateInvoicePdf__c = true;
            }
        }

        List<Attachment> attachmentObjId = new List<Attachment>();
        if (caseObjId.size() > 0) {
            List<Attachment> attachmentObj = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :caseObjId];
            for (Attachment attachment : attachmentObj) {
                if (attachment.Name == 'Case PDF - ' + oldCaseMap.get(attachment.ParentId).CaseNumber + '.pdf' || attachment.Name == 'Quote PDF - ' + oldCaseMap.get(attachment.ParentId).CaseNumber + '.pdf' || attachment.Name == oldCaseMap.get(attachment.ParentId).CaseNumber + '_Job_Summary.PDF') {
                    attachmentObjId.add(attachment);
                }
            }
        }

        if (attachmentObjId.size() > 0) {
            delete attachmentObjId;
        }
    }

    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Sending email to customer when claim is get rejected.
    */

    public static void sendEmailtoCustomerWhenClaimRejected(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Set<Id> diagnosedUserId = new Set<Id>();
        List<Case> lstCase = new List<Case>();
        for (Case caseObj: newCaseList) {
            if (oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c != 'Closed' && caseObj.Service_Request_Milestone__c == 'Closed' && oldCaseMap.get(caseObj.Id).Closed_Reason__c != 'Rejected by Warranty Team' && caseObj.Closed_Reason__c == 'Rejected by Warranty Team') {
                lstCase.add(caseObj);
            }
        }
        
        if (lstCase != null && lstCase.size() > 0) {
            for (Case caseObj : lstCase) {
                diagnosedUserId.add(caseObj.Diagnosed_User__c);
            }
            Map<Id, User> contactIdOfUser = new  Map<Id, User>([SELECT Id, ContactId, Contact.FirstName, Contact.Email FROM USer WHERE Id IN :diagnosedUserId]);
            TTI_Template__c template = TTI_Template__c.getValues('TTI_RejectedWarrantyClaimTemplate');
            List<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = : template.Approved_Claim_Notification_Template__c];
            String emailBody = '';
            String emailSubject = '';
            if (templateAGE.size() > 0) {
                if (templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != '') {
                    emailBody = templateAGE[0].HtmlValue;
                }

                if (templateAGE[0].Subject != null && templateAGE[0].Subject != '') {
                    emailSubject = templateAGE[0].Subject;
                }
            }
            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            for (Case caseObj : lstCase) {
                if (oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c != 'Closed' && caseObj.Service_Request_Milestone__c == 'Closed' && oldCaseMap.get(caseObj.Id).Closed_Reason__c != 'Rejected by Warranty Team' && caseObj.Closed_Reason__c == 'Rejected by Warranty Team' && contactIdOfUser.containsKey(caseObj.Diagnosed_User__c) && contactIdOfUser.get(caseObj.Diagnosed_User__c).ContactId != null && contactIdOfUser.get(caseObj.Diagnosed_User__c).Contact.Email != '' && contactIdOfUser.get(caseObj.Diagnosed_User__c).Contact.Email != null) {
                    if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.Claim_Type__c == 'Warranty') {
                        Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                        emailToBeSent.setSaveAsActivity(true);
                        String emailSubjectReplaceCaseNo = '';
                        emailSubjectReplaceCaseNo = emailSubject.replace('caseCaseNumber', caseObj.CaseNumber);
                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                        }
                        emailToBeSent.setSubject(emailSubjectReplaceCaseNo);

                        String emailBodyCaseFieldsmapping = '';
                        if (emailBody != '' && emailBody != null) {
                            emailBodyCaseFieldsmapping = emailBody.replace('caseCaseNumber', caseObj.CaseNumber);
                            if (contactIdOfUser.get(caseObj.Diagnosed_User__c).Contact.FirstName != '' && contactIdOfUser.get(caseObj.Diagnosed_User__c).Contact.FirstName != null) {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('userContactName', contactIdOfUser.get(caseObj.Diagnosed_User__c).Contact.FirstName);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('userContactName', '');
                            }
                            if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', caseObj.Brand__c);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', '');
                            }
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                        }

                        emailToBeSent.setHtmlBody(emailBodyCaseFieldsmapping);
                        emailToBeSent.setTargetObjectId(contactIdOfUser.get(caseObj.Diagnosed_User__c).ContactId);
                        emailToBeSent.setWhatId(caseObj.Id);
                        emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                        emailToSent.add(emailToBeSent);
                    }
                }
            }
            if (emailToSent.size() > 0) {
                List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSent);
            }
        }
    }

    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Sending email to customer when claim is get approved.
    */

    public static void sendEmailtoCustomerWhenClaimApproved(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Set<Id> contactObjId = new Set<Id>();
        Set<Id> assetObjId = new Set<Id>();
        Set<Id> setofAccId = new Set<Id>();
        List<Case> lstCase = new List<Case>();

        for (Case caseObj : newCaseList) {
            if (caseObj.Approved_Flag__c == true && oldCaseMap.get(caseObj.Id).Approved_Flag__c == false && caseObj.Service_Request_Milestone__c == 'In Progress' && oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c != 'In Progress') {
                lstCase.add(caseObj);
            }
        }

        if(lstCase.size() > 0){
            TriggerHelperClass.setAlreadyfired();
        }

        if (lstCase != null && lstCase.size() > 0) {
            for (Case caseObj : lstCase) {
                contactObjId.add(caseObj.TTI_Customer_Contact__c);
                assetObjId.add(caseObj.AssetId);
                setofAccId.add(caseObj.Service_Agent__c);
                if (caseObj.Retailer_Account__c != null) {
                    setofAccId.add(caseObj.Retailer_Account__c);
                }
            }
            Map<Id, Contact> contactObjMap = new Map<Id, Contact>([SELECT Id, Email, FirstName FROM Contact WHERE Id = :contactObjId]);
            Map<Id, Asset> assetObjMap = new Map<Id, Asset>([SELECT Id, Name FROM Asset WHERE Id = :assetObjId]);
            Map<Id, Account> accountObjMap = new Map<Id, Account>([SELECT Id, Name, Phone, Delivery_Street__c, Delivery_Suburb__c, Delivery_Postcode__c FROM Account WHERE Id IN :setofAccId]);
           
            TTI_Template__c template = TTI_Template__c.getValues('TTI_WarrantyClaimApprovedNotification');
            List<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = : template.Approved_Claim_Notification_Template__c];
            String emailBody = '';
            String emailSubject = '';
            if (templateAGE.size() > 0) {
                if (templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != '') {
                    emailBody = templateAGE[0].HtmlValue;
                }

                if (templateAGE[0].Subject != null && templateAGE[0].Subject != '') {
                    emailSubject = templateAGE[0].Subject;
                }
            }
            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            List<Task> taskToCreate = new List<Task>();
            Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            for (Case caseObj : lstCase) {
                // Francis Nasalita [SP-865] 2018/11/15 - Removed null checker for caseObj.TTI_Customer_Contact__c Email.
                if (oldCaseMap.get(caseObj.Id).Approved_Flag__c == false && caseObj.Approved_Flag__c == true && caseObj.TTI_Customer_Contact__c != null && contactObjMap.containsKey(caseObj.TTI_Customer_Contact__c)) {
                    if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.TTI_Email_Notification_Opt_In__c && caseObj.Claim_Type__c == 'Warranty') {
                        Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                        emailToBeSent.setSaveAsActivity(true);
                        String emailSubjectReplaceCaseNo = '';
                        emailSubjectReplaceCaseNo = emailSubject.replace('CaseCaseNumber', caseObj.CaseNumber);

                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                        }

                        emailToBeSent.setSubject(emailSubjectReplaceCaseNo);

                        String emailBodyCaseFieldsmapping = '';
                        Contact customerContact = null;
                        if (emailBody != '' && emailBody != null) {
                            emailBodyCaseFieldsmapping = emailBody.replace('CaseCaseNumber', caseObj.CaseNumber);
                            if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', assetObjMap.get(caseObj.AssetId).Name);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', '');
                            }

                            if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', caseObj.Brand__c);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', '');
                            }

                            
                            if(contactObjMap.containsKey(caseobj.TTI_Customer_Contact__c)){
                                customerContact = contactObjMap.get(caseObj.TTI_Customer_Contact__c);
                                if(customerContact.FirstName != '' && customerContact.FirstName != null){
                                    emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('CASE_CONTACT_FIRST_NAME', customerContact.FirstName);
                                }else{
                                    emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('CASE_CONTACT_FIRST_NAME', '');
                                }
                            }

                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', 'If you have any queries regarding the progress of your claim, please contact the Authorised Service Agent and quote the above Claim number:');
                            if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('SAname', accountObjMap.get(caseObj.Service_Agent__c).Name);
                            }

                            if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', '');
                            }

                            if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c != '' && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c + ', ' + accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', '');
                            }

                            if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Phone != null && accountObjMap.get(caseObj.Service_Agent__c).Phone != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', 'Tel: ' + accountObjMap.get(caseObj.Service_Agent__c).Phone);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', '');
                            }
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                        }
                        emailToBeSent.setHtmlBody(emailBodyCaseFieldsmapping);
                        
                        emailToBeSent.setWhatId(caseObj.Id);
                        emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                        
                        if(customerContact != null) {
                            if(customerContact.Email != null && customerContact.Email != '') {
                                emailToBeSent.setTargetObjectId(caseObj.TTI_Customer_Contact__c);

                                if(customerContact.Email != caseObj.SuppliedEmail) {
                                    emailTobeSent.setSaveAsActivity(false);
                                    emailTobeSent.setToAddresses(new List<String>{caseObj.SuppliedEmail});
                                }
                            } else {
                                emailTobeSent.setToAddresses(new List<String>{caseObj.SuppliedEmail});
                                emailToBeSent.setTreatTargetObjectAsRecipient(false);
                                
                                taskToCreate.add(
                                    TTI_CaseTriggerHandler.createServiceRequestTask(emailBodyCaseFieldsmapping, emailSubjectReplaceCaseNo, caseObj.Id, caseObj.TTI_Customer_Contact__c)
                                );
                            }

                            emailToSent.add(emailToBeSent);
                        }   
                    }
                }
            }

            if (emailToSent.size() > 0) {
                List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSent);
            }

            if(!taskToCreate.isEmpty()) {
                insert taskToCreate;
            }
        }
    }

    public static Task createServiceRequestTask(String emailBodyCaseFieldsmapping, String emailSubjectReplaceCaseNo, Id caseId, Id contactId) {
        Id taskServiceRequestRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();

        Task task = new Task();
        task.RecordTypeId = taskServiceRequestRTId;
        task.Subject = 'Email: ' + emailSubjectReplaceCaseNo;
        task.Description = emailBodyCaseFieldsmapping;
        task.WhatId = caseId;
        task.WhoId = contactId;
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.ActivityDate = system.today()+1;

        return task;
    }

    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Sending email to customer when claim is get complete.
    */
    public static void sendEmailtoCustomerWhenClaimMarkedAsComplete(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        if (!stopRecusion) {
            List<Case> lstCase = new List<Case>();
            for (Case caseObj: newCaseList) {
                if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.TTI_Email_Notification_Opt_In__c && oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c == 'In Progress' && caseObj.Service_Request_Milestone__c == 'Completed' && caseObj.TTI_Customer_Contact__c != null) {
                    lstCase.add(caseObj);
                }
            }

            if (lstCase != null && lstCase.size() > 0) {
                stopRecusion = true;
                Set<Id> contactObjId = new Set<Id>();
                Set<Id> assetObjId = new Set<Id>();
                Set<Id> accountObjId = new Set<Id>();
                for (Case caseObj : lstCase) {
                    contactObjId.add(caseObj.TTI_Customer_Contact__c);
                    assetObjId.add(caseObj.AssetId);
                    accountObjId.add(caseObj.Service_Agent__c);
                    if (caseObj.Retailer_Account__c != null) {
                        accountObjId.add(caseObj.Retailer_Account__c);
                    }
                }

                Map<Id, Contact> contactObjMap = new Map<Id, Contact>([SELECT Id, Email, FirstName FROM Contact WHERE Id IN:contactObjId]);
                Map<Id, Asset> assetObjMap = new Map<Id, Asset>([SELECT Id, Name FROM Asset WHERE Id IN:assetObjId]);
                Map<Id, Account> accountObjMap = new Map<Id, Account>([SELECT Id, Name, Phone, Delivery_Street__c, Delivery_Suburb__c, Delivery_Postcode__c FROM Account WHERE Id IN :accountObjId]);
                TTI_Template__c template = TTI_Template__c.getValues('TTI_MarkedAsCompleteNotification');
                List<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = : template.Approved_Claim_Notification_Template__c];
                String emailBody = '';
                String emailSubject = '';

                if (templateAGE.size() > 0) {
                    if (templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != '') {
                        emailBody = templateAGE[0].HtmlValue;
                    }

                    if (templateAGE[0].Subject != null && templateAGE[0].Subject != '') {
                        emailSubject = templateAGE[0].Subject;
                    }
                }

                List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
                List<Task> taskToCreate = new List<Task>();
                for (Case caseObj : lstCase) {
                    // Francis Nasalita [SP-865] 2018/11/15 - Removed null checker for caseObj.TTI_Customer_Contact__c Email.
                    if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.TTI_Email_Notification_Opt_In__c && oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c == 'In Progress' && caseObj.Service_Request_Milestone__c == 'Completed' && caseObj.TTI_Customer_Contact__c != null && contactObjMap.containsKey(caseObj.TTI_Customer_Contact__c)) {
                        Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                        emailToBeSent.setSaveAsActivity(true);
                        String emailSubjectReplaceCaseNo = '';

                        emailSubjectReplaceCaseNo = emailSubject.replace('CaseCaseNumber', caseObj.CaseNumber);

                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                        }

                        emailToBeSent.setSubject(emailSubjectReplaceCaseNo);

                        String emailBodyCaseFieldsmapping = '';
                        Contact customerContact = null;
                        if (emailBody != '' && emailBody != null) {
                            emailBodyCaseFieldsmapping = emailBody.replace('CaseCaseNumber', caseObj.CaseNumber);

                            if (contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != null && contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('contactFirstName', contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName);
                            } else {
                                emailBodyCaseFieldsmapping = emailBody.replace('contactFirstName', '');
                            }

                            if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Asset2Name', assetObjMap.get(caseObj.AssetId).Name);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Asset2Name', '');
                            }

                            if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAgentName', accountObjMap.get(caseObj.Service_Agent__c).Name);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAgentName', '');
                            }

                            if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', caseObj.Brand__c);
                            } else {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', '');
                            }

                            if(contactObjMap.containsKey(caseobj.TTI_Customer_Contact__c)){
                                customerContact = contactObjMap.get(caseObj.TTI_Customer_Contact__c);
                                if(customerContact.FirstName != '' && customerContact.FirstName != null){
                                    emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('CASE_CONTACT_FIRST_NAME', customerContact.FirstName);
                                }else{
                                    emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('CASE_CONTACT_FIRST_NAME', '');
                                }
                            }

                            if (caseObj.TTI_Freight_Out_Required__c && caseObj.Retailer_Account__c == null) {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', 'Your tool may now be collected from the following address at your earliest convenience:');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', '');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', '');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', '');

                            } else if (caseObj.TTI_Freight_Out_Required__c && caseObj.Retailer_Account__c != null) {
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', 'Please check with ' + accountObjMap.get(caseObj.Retailer_Account__c).Name + ' to ensure that your tool is ready for collection.');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', '');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', '');
                                emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', '');
                            }

                            if (!caseObj.TTI_Freight_Out_Required__c) {
                                if (caseObj.Retailer_Account__c == null) {
                                    emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', 'Your tool may now be collected from the following address at your earliest convenience:');
                                    if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', accountObjMap.get(caseObj.Service_Agent__c).Delivery_Street__c);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', '');
                                    }
                                    if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c != '' && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c != null && accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', accountObjMap.get(caseObj.Service_Agent__c).Delivery_Suburb__c + ', ' + accountObjMap.get(caseObj.Service_Agent__c).Delivery_Postcode__c);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', '');
                                    }
                                    if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Phone != null && accountObjMap.get(caseObj.Service_Agent__c).Phone != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', 'Tel: ' + accountObjMap.get(caseObj.Service_Agent__c).Phone);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', '');
                                    }
                                } else if (caseObj.Retailer_Account__c != null) {
                                    if (caseObj.Retailer_Account__c != null && accountObjMap.get(caseObj.Retailer_Account__c).Name != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', 'Please check with ' + accountObjMap.get(caseObj.Retailer_Account__c).Name + ' to ensure that your tool is ready for collection');
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('pickUpOrDeliver', '');
                                    }
                                    if (caseObj.Retailer_Account__c != null && accountObjMap.containsKey(caseObj.Retailer_Account__c) && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Street__c != null && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Street__c != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Street__c);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('street', '');
                                    }
                                    if (caseObj.Retailer_Account__c != null && accountObjMap.containsKey(caseObj.Retailer_Account__c) && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Suburb__c != null && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Suburb__c != '' && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Postcode__c != null && accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Postcode__c != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Suburb__c + ', ' + accountObjMap.get(caseObj.Retailer_Account__c).Delivery_Postcode__c);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('addresses', '');
                                    }
                                    if (caseObj.Retailer_Account__c != null && accountObjMap.containsKey(caseObj.Retailer_Account__c) && accountObjMap.get(caseObj.Retailer_Account__c).Phone != null && accountObjMap.get(caseObj.Retailer_Account__c).Phone != '') {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', 'Tel: ' + accountObjMap.get(caseObj.Retailer_Account__c).Phone);
                                    } else {
                                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('tel_Number', '');
                                    }
                                }
                            }

                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                        }
                        emailToBeSent.setHtmlBody(emailBodyCaseFieldsmapping);
                        emailToBeSent.setWhatId(caseObj.Id);
                        emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);

                        if(customerContact != null) {
                            if(customerContact.Email != null && customerContact.Email != '') {
                                emailToBeSent.setTargetObjectId(caseObj.TTI_Customer_Contact__c);

                                if(customerContact.Email != caseObj.SuppliedEmail) {
                                    emailTobeSent.setSaveAsActivity(false);
                                    emailTobeSent.setToAddresses(new List<String>{caseObj.SuppliedEmail});
                                }
                            } else {
                                emailTobeSent.setToAddresses(new List<String>{caseObj.SuppliedEmail});
                                emailToBeSent.setTreatTargetObjectAsRecipient(false);

                                taskToCreate.add(
                                    TTI_CaseTriggerHandler.createServiceRequestTask(emailBodyCaseFieldsmapping, emailSubjectReplaceCaseNo, caseObj.Id, caseObj.TTI_Customer_Contact__c)
                                );
                            }

                            emailToSent.add(emailToBeSent);                                
                        }
                    }
                }

                if (emailToSent.size() > 0) {
                    List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSent);
                }

                if(!taskToCreate.isEmpty()) {
                    insert taskToCreate;
                }
            }
        }
    }

    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Sending email to customer to track the status of the delivery.
    */
    public static void sendEmailtoTrackTheStatusOfDelivery(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Set<Id> contactObjId = new Set<Id>();
        Set<Id> assetObjId = new Set<Id>();
        Set<Id> serviceAgentId = new Set<Id>();
        List<Case> lstCase = new List<Case>();

        for (Case caseObj : newCaseList) {
            if (caseObj.RecordTypeId == recordTypeIdCase &&
                    caseObj.TTI_Email_Notification_Opt_In__c &&
                    ((oldCaseMap.get(caseObj.Id).Freight_in_consignment_number__c == null
                      && caseObj.Freight_in_consignment_number__c != null) || (oldCaseMap.get(caseObj.Id).Freight_out_consignment_number__c == null &&
                              caseObj.Freight_out_consignment_number__c != null))  && caseObj.TTI_Customer_Contact__c != null) {
                lstCase.add(caseObj);
            }
        }

        if (lstCase != null && lstCase.size() > 0) {
            for (Case caseObj : lstCase) {
                contactObjId.add(caseObj.TTI_Customer_Contact__c);
                assetObjId.add(caseObj.AssetId);
                serviceAgentId.add(caseObj.Service_Agent__c);
            }

            Map<Id, Account> accountObjMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id = :serviceAgentId]);
            Map<Id, Contact> contactObjMap = new Map<Id, Contact>([SELECT Id, FirstName, Email FROM Contact WHERE Id = :contactObjId]);
            Map<Id, Asset> assetObjMap = new Map<Id, Asset>([SELECT Id, Name FROM Asset WHERE Id = :assetObjId]);
            TTI_Template__c template = TTI_Template__c.getValues('ConsignmentNoteTemplate');
            List<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = : template.Approved_Claim_Notification_Template__c];
            String emailBody = '';
            String emailSubject = '';

            if (templateAGE.size() > 0) {
                if (templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != '') {
                    emailBody = templateAGE[0].HtmlValue;
                }
                if (templateAGE[0].Subject != null && templateAGE[0].Subject != '') {
                    emailSubject = templateAGE[0].Subject;
                }
            }

            TTI_Template__c templateFreightOut = TTI_Template__c.getValues('ConsignmentNoteTemplateFreightOut');
            List<EmailTemplate> templateFrightOut = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = : templateFreightOut.Approved_Claim_Notification_Template__c];
            String emailBodyFreightOut = '';
            String emailSubjectFreightOut = '';

            if (templateFrightOut.size() > 0) {
                if (templateFrightOut[0].HtmlValue != null && templateFrightOut[0].HtmlValue != '') {
                    emailBodyFreightOut = templateFrightOut[0].HtmlValue;
                }
                if (templateFrightOut[0].Subject != null && templateFrightOut[0].Subject != '') {
                    emailSubjectFreightOut = templateFrightOut[0].Subject;
                }
            }

            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> emailToSentFreightOut = new List<Messaging.SingleEmailMessage>();

            for (Case caseObj : lstCase) {
                if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.TTI_Email_Notification_Opt_In__c && oldCaseMap.get(caseObj.Id).Freight_in_consignment_number__c == null && caseObj.Freight_in_consignment_number__c != null && caseObj.TTI_Customer_Contact__c != null && contactObjMap.containsKey(caseObj.TTI_Customer_Contact__c) && contactObjMap.get(caseObj.TTI_Customer_Contact__c).Email != null && contactObjMap.get(caseObj.TTI_Customer_Contact__c).Email != '') {
                    Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                    emailToBeSent.setSaveAsActivity(true);
                    String emailSubjectReplaceCaseNo = '';
                    if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                        emailSubjectReplaceCaseNo = emailSubject.replace('Product2Name', assetObjMap.get(caseObj.AssetId).Name);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubject.replace('Product2Name', '');
                    }
                    if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('serviceAggentName', accountObjMap.get(caseObj.Service_Agent__c).Name);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('serviceAggentName', '');
                    }
                    if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                    }
                    emailToBeSent.setSubject(emailSubjectReplaceCaseNo);

                    String emailBodyCaseFieldsmapping = '';
                    if (emailBody != '' && emailBody != null) {
                        if (contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != null && contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != '') {
                            emailBodyCaseFieldsmapping = emailBody.replace('caseContactFirstName', contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName);
                        } else {
                            emailBodyCaseFieldsmapping = emailBody.replace('caseContactFirstName', '');
                        }
                        if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', assetObjMap.get(caseObj.AssetId).Name);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', '');
                        }
                        if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAggentName', accountObjMap.get(caseObj.Service_Agent__c).Name);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAggentName', '');
                        }
                        if (caseObj.TTI_Freight_In_Courier__c != null && caseObj.TTI_Freight_In_Courier__c != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightInCourier', caseObj.TTI_Freight_In_Courier__c);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightInCourier', '');
                        }

                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', '');
                        }
                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightInTrackingURL', caseObj.TTI_Freight_in_tracking_url__c);
                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                    }
                    emailToBeSent.setHtmlBody(emailBodyCaseFieldsmapping);
                    emailToBeSent.setTargetObjectId(caseObj.TTI_Customer_Contact__c);
                    emailToBeSent.setWhatId(caseObj.Id);
                    emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                    emailToSent.add(emailToBeSent);
                }

                if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.TTI_Email_Notification_Opt_In__c && oldCaseMap.get(caseObj.Id).Freight_out_consignment_number__c == null && caseObj.Freight_out_consignment_number__c != null && caseObj.TTI_Customer_Contact__c != null && contactObjMap.containsKey(caseObj.TTI_Customer_Contact__c) && contactObjMap.get(caseObj.TTI_Customer_Contact__c).Email != null && contactObjMap.get(caseObj.TTI_Customer_Contact__c).Email != '') {
                    Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                    emailToBeSent.setSaveAsActivity(true);
                    String emailSubjectReplaceCaseNo = '';
                    if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                        emailSubjectReplaceCaseNo = emailSubjectFreightOut.replace('Product2Name', assetObjMap.get(caseObj.AssetId).Name);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubjectFreightOut.replace('Product2Name', '');
                    }
                    if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('serviceAggentName', accountObjMap.get(caseObj.Service_Agent__c).Name);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('serviceAggentName', '');
                    }
                    if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                    } else {
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                    }
                    if (caseObj.Service_Request_Milestone__c == 'Completed' || caseObj.Service_Request_Milestone__c == 'Invoice Awaiting Approval') {
                        String Asset2Name = '';
                        if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                            Asset2Name = (assetObjMap.get(caseObj.AssetId)).Name;
                        }
                        emailToBeSent.setSubject(caseObj.Brand__c + 'booking details for the delivery of ' + Asset2Name + ' back to you');
                    } else {
                        emailToBeSent.setSubject(emailSubjectReplaceCaseNo);
                    }

                    String emailBodyCaseFieldsmapping = '';
                    if (emailBodyFreightOut != '' && emailBodyFreightOut != null) {
                        if (contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != null && contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName != '') {
                            emailBodyCaseFieldsmapping = emailBodyFreightOut.replace('caseContactFirstName', contactObjMap.get(caseObj.TTI_Customer_Contact__c).FirstName);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyFreightOut.replace('caseContactFirstName', '');
                        }
                        if (caseObj.AssetId != null && assetObjMap.containsKey(caseObj.AssetId) && assetObjMap.get(caseObj.AssetId).Name != null && assetObjMap.get(caseObj.AssetId).Name != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', assetObjMap.get(caseObj.AssetId).Name);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Product2Name', '');
                        }
                        if (caseObj.Service_Agent__c != null && accountObjMap.containsKey(caseObj.Service_Agent__c) && accountObjMap.get(caseObj.Service_Agent__c).Name != null && accountObjMap.get(caseObj.Service_Agent__c).Name != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAggentName', accountObjMap.get(caseObj.Service_Agent__c).Name);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('serviceAggentName', '');
                        }
                        if (caseObj.TTI_Freight_Out_Courier__c != null && caseObj.TTI_Freight_Out_Courier__c != '') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightInCourier', caseObj.TTI_Freight_Out_Courier__c);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightInCourier', '');
                        }
                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('brandName', '');
                        }
                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('freightoutTrackingURL', caseObj.TTI_Freight_out_tracking_url__c);
                        emailBodyCaseFieldsmapping = emailBodyCaseFieldsmapping.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                    }
                    emailToBeSent.setHtmlBody(emailBodyCaseFieldsmapping);
                    emailToBeSent.setTargetObjectId(caseObj.TTI_Customer_Contact__c);
                    emailToBeSent.setWhatId(caseObj.Id);
                    emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                    emailToSentFreightOut.add(emailToBeSent);
                }
            }
            if (emailToSent.size() > 0) {
                List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSent);
            }
            if (emailToSentFreightOut.size() > 0) {
                List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSentFreightOut);
            }
        }
    }

    // Variables defined
    private static Id serviceRequestCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();

    public static void onBeforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        changeCaseOwnerInSR(newCaseList, oldCaseMap);
        paymentevaluation(newCaseList, oldCaseMap);
        setSlaDate(newCaseList, oldCaseMap);
        setDateTimeAndDuration(newCaseList, oldCaseMap);
        setFreightPickupAdress(newCaseList, oldCaseMap);
    }

    /**
    * @author: Jubesh Nagpal
    * @date: December 2017
    * @description: Set Date/time and duration for a service milestone.
    */
    private static void setDateTimeAndDuration(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        for (Case newCase : newCaseList) {
            Case oldCase =  oldCaseMap.get(newCase.Id);
            if (newCase.Service_Request_Milestone__c == 'Awaiting Approval' && oldCase.Service_Request_Milestone__c != 'Awaiting Approval') {
                newCase.TTI_Awaiting_Approval_Datetime__c = DateTime.now();
                newCase.TTI_In_Progress_Datetime__c = null;
                newCase.TTI_Completed_Datetime__c = null;
                newCase.TTI_Invoice_Awaiting_Approval_Datetime__c = null;
                newCase.TTI_Closed_Datetime__c = null;
            }
            if (newCase.Service_Request_Milestone__c == 'In Progress' && oldCase.Service_Request_Milestone__c != 'In Progress') {
                newCase.TTI_In_Progress_Datetime__c = DateTime.now();
                newCase.TTI_Completed_Datetime__c = null;
                newCase.TTI_Invoice_Awaiting_Approval_Datetime__c = null;
                newCase.TTI_Closed_Datetime__c = null;
            }
            if (newCase.Service_Request_Milestone__c == 'Completed' && oldCase.Service_Request_Milestone__c != 'Completed') {
                newCase.TTI_Completed_Datetime__c = DateTime.now();
                newCase.TTI_Invoice_Awaiting_Approval_Datetime__c = null;
                newCase.TTI_Closed_Datetime__c = null;
            }
            if (newCase.Service_Request_Milestone__c == 'Invoice Awaiting Approval' && oldCase.Service_Request_Milestone__c != 'Invoice Awaiting Approval') {
                newCase.TTI_Invoice_Awaiting_Approval_Datetime__c = DateTime.now();
                newCase.TTI_Closed_Datetime__c = null;
            }
            if (newCase.Service_Request_Milestone__c == 'Closed' && oldCase.Service_Request_Milestone__c != 'Closed') {
                newCase.TTI_Closed_Datetime__c = DateTime.now();
            }
        }
    }

    /**
    * @author: Jubesh Nagpal
    * @date: December 2017
    * @description: Set freight pickup adress on update of service agent.
    */
    private static void setFreightPickupAdress(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Set<Id> serviceAgentId = new Set<Id>();
        Boolean isServiceAgentChanged;
        Boolean isDeliveryMethodChanged;

        for (Case objCase : newCaseList) {
            serviceAgentId.add(objCase.Service_Agent__c);
        }

        Map<Id, Account> ServiceAgentfieldsmap = new Map<Id, Account>([SELECT Id, Delivery_Country__c, Delivery_Street__c, Delivery_Suburb__c, Delivery_Postcode__c,
                                                                              Delivery_State__c, Freight_Company__c 
                                                                       FROM Account
                                                                       WHERE Id IN :serviceAgentId]);
        for (Case newCase : newCaseList) {
            isServiceAgentChanged = newCase.Service_Agent__c != null 
                    && newCase.Service_Agent__c != oldCaseMap.get(newCase.Id).Service_Agent__c;
                    
            isDeliveryMethodChanged = newCase.TTI_Customer_Delivery_Method__c != null
                    && newCase.TTI_Customer_Delivery_Method__c != oldCaseMap.get(newCase.Id).TTI_Customer_Delivery_Method__c;
                    
            if (newCase.TTI_Freight_Out_Required__c  && (isServiceAgentChanged || isDeliveryMethodChanged)) {
                Account objAcc = ServiceAgentfieldsmap.get(newCase.Service_Agent__c);
                newCase.TTI_Freight_Out_PickUp_Address__c = objAcc.Delivery_Street__c;
                newCase.TTI_Freight_Out_Pickup_Suburb__c = objAcc.Delivery_Suburb__c;
                newCase.TTI_Freight_Out_Pickup_Postcode__c = objAcc.Delivery_Postcode__c;
                newCase.TTI_Freight_Out_Pickup_State__c = objAcc.Delivery_State__c;
                newCase.TTI_Freight_Out_Pickup_Country__c = objAcc.Delivery_Country__c;
                newCase.TTI_Freight_Out_Courier__c = objAcc.Freight_Company__c;
            }
        }
    }

    /**
    * @author: Jubesh Nagpal
    * @date: December 2017
    * @description: Set SLA Date on update.
    */
    private static void setSlaDate(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        for (Case newCase : newCaseList) {
            Case oldCase = oldCaseMap.get(newCase.Id);

            if (newCase.Diagnosed_Date__c != null && oldCase.Diagnosed_Date__c == null && oldCase.SLA_Start_Date__c == null && newCase.SLA_Start_Date__c == null) {
                newCase.SLA_Start_Date__c = newCase.Diagnosed_Date__c;
            }

            if (newCase.Invoiced_Approved__c == true && oldCase.Invoiced_Approved__c == false) {
                newCase.SLA_End_Date__c = DateTime.now();
            }
        }
    }

    /**
    * @author: Susant Dwivedi
    * @date: December 2017
    * @description: Cange the Case owner to dignosed user.
    * child cases upon creation
    */
    private static void changeCaseOwnerInSR(List<Case> lstCase, Map<Id, Case> mapidWithcase) {
        for (Case objCase : lstCase) {
            Boolean isWarrantyServiceRequestApproved = objCase.Approved_Flag__c && !mapidWithcase.get(objCase.Id).Approved_Flag__c;
            Boolean isWarrantyInvoiceApproved = objCase.Invoiced_Approved__c && !mapidWithcase.get(objCase.Id).Invoiced_Approved__c;

            if (objCase.RecordTypeId == serviceRequestCaseRecTypeId && objCase.Diagnosed_User__c != null
                    && (isWarrantyServiceRequestApproved || isWarrantyInvoiceApproved)) {
                objCase.OwnerId = objCase.Diagnosed_User__c;
            }
        }
    }

    /**
    * @author: Jubesh Nagpal
    * @date: December 2017
    * @description:Payment Evaluations on update
    */
    private static void paymentevaluation(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Map<String, PricingStructure__c> PricingStructurelist = PricingStructure__c.getAll();
        Map<String, ServiceAgentBonus__c> ServiceAgentBonuslist = ServiceAgentBonus__c.getAll();
        Map<String, GST_Rates__c> GSTRateslist = GST_Rates__c.getAll();
        List<Case> caseWithParentFields = [SELECT Id, 
                                            Invoiced_Approved__c,
                                            Service_Agent__r.Allow_Delivery_to_Customers__c,
                                            Product_Payment_Category__c,
                                            Service_Agent__r.Delivery_Country__c,
                                            Repair_Type__c, Base_Amount_Payable_AUD__c,
                                            Base_Amount_Payable_NZD__c,
                                            Service_Agent__r.Service_Agent_Status__c, 
                                            Service_Agent__r.Allow_Inspection_Fee__c
                                            , Bonus_Amount_Payable_AUD__c,
                                            Bonus_Amount_Payable_NZD__c 
                                            FROM Case 
                                            WHERE Id IN :newCaseList];
        Map<Id, Case> caseWithParentFieldsMap = new Map<Id, Case>();
        for (Case c : caseWithParentFields) {
            caseWithParentFieldsMap.put(c.Id, c);
        }

        for (Case newCase : newCaseList) {
            String psname;
            String saname;
            Case oldCase =  oldCaseMap.get(newCase.Id);
            if (newCase.Invoiced_Approved__c == true && oldCase.Invoiced_Approved__c == false) {
                if (newCase.Claim_Type__c == 'Non-Warranty' || newCase.Claim_Type__c == 'Warranty') {
                    if (newCase.Claim_Type__c == 'Non-Warranty' 
                            || (newCase.Claim_Type__c == 'Warranty'  && (newCase.Goodwill_parts_only__c 
                            || (newCase.Repair_Type__c == 'Declined Warranty - Inspection fee' 
                            && caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Allow_Inspection_Fee__c == false)))) {
                        newCase.Base_Amount_Payable_AUD__c = 0;
                        newCase.Base_GST_Payable_AUD__c = 0;
                        newCase.Base_Amount_Payable_NZD__c = 0;
                        newCase.Base_GST_Payable_NZD__c = 0;
                        newCase.Bonus_Amount_Payable_AUD__c = 0;
                        newCase.Bonus_GST_Payable_AUD__c = 0;
                        newCase.Bonus_Amount_Payable_NZD__c = 0;
                        newCase.Bonus_GST_Payable_NZD__c = 0; 
                    }
                    else {
                        Integer pscount = 0;
                        Integer sacount = 0;
                        for (PricingStructure__c ps : PricingStructurelist.values()) {
                            if (ps.Pricing_Type__c == newCase.Repair_Type__c 
                                    && ps.Product_Category__c == newCase.Product_Payment_Category__c 
                                    && ps.Size__c == newCase.Product_Size_Category__c 
                                    && ps.Service_Agent_Status__c == caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Service_Agent_Status__c ) {
                                psname = ps.Name;
                                pscount++;
                                break;
                            }
                        }

                        if (pscount < 1) {
                            newCase.Base_Amount_Payable_AUD__c = 0;
                            newCase.Base_GST_Payable_AUD__c = 0;
                            newCase.Base_Amount_Payable_NZD__c = 0;
                            newCase.Base_GST_Payable_NZD__c = 0;
                        } else {
                            newCase.Base_Amount_Payable_AUD__c = 0;
                            newCase.Base_GST_Payable_AUD__c = 0;
                            newCase.Base_Amount_Payable_NZD__c = 0;
                            newCase.Base_GST_Payable_NZD__c = 0;

                            if (caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c != null 
                                    && (caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'Australia'
                                    || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'AU')) {
                                if (psname != null && PricingStructurelist.get(psname).Pricing_Amount_AUD__c != null && GSTRateslist.get('Australia').GST_Rate__c != null) {
                                    newCase.Base_Amount_Payable_AUD__c = PricingStructurelist.get(psname).Pricing_Amount_AUD__c;
                                    newCase.Base_GST_Payable_AUD__c = (PricingStructurelist.get(psname).Pricing_Amount_AUD__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                                }

                                newCase.Base_Amount_Payable_NZD__c = 0;
                                newCase.Base_GST_Payable_NZD__c = 0;
                            } else if (caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c != null 
                                    && (caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'New Zealand'
                                    || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'NZ')) {
                                newCase.Base_Amount_Payable_AUD__c = 0;
                                newCase.Base_GST_Payable_AUD__c = 0;

                                if (psname != null && PricingStructurelist.get(psname).Pricing_Amount_NZD__c != null && GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                                    newCase.Base_Amount_Payable_NZD__c = PricingStructurelist.get(psname).Pricing_Amount_NZD__c;
                                    newCase.Base_GST_Payable_NZD__c = (PricingStructurelist.get(psname).Pricing_Amount_NZD__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                                }
                            }
                        }
                        
                         Decimal totalsladuration = (newCase.TTI_New_Duration__c + newCase.In_Progress_Duration__c + newCase.TTI_Completed_Duration__c) / 24 ;
                        
                        if (totalsladuration <= 1) {
                            for (ServiceAgentBonus__c sa : ServiceAgentBonuslist.values()) {
                                if (sa.RepairType__c == newCase.Repair_Type__c && sa.PaymentCategory__c == newCase.Product_Payment_Category__c && sa.Job_Duration__c == '24HR' && sa.Grading__c == caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Service_Agent_Status__c) {
                                    saname = sa.Name;
                                    sacount++;
                                    break;
                                }
                            }
                            if (sacount < 1) {
                                newCase.Bonus_Amount_Payable_AUD__c = 0;
                                newCase.Bonus_GST_Payable_AUD__c = 0;
                                newCase.Bonus_Amount_Payable_NZD__c = 0;
                                newCase.Bonus_GST_Payable_NZD__c = 0;
                            } else {
                                newCase.Bonus_Amount_Payable_AUD__c = 0;
                                newCase.Bonus_GST_Payable_AUD__c = 0;
                                newCase.Bonus_Amount_Payable_NZD__c = 0;
                                newCase.Bonus_GST_Payable_NZD__c = 0;
                                if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'Australia'
                                        || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'AU') 
                                        && ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c != null) {
                                    if (saname != null && ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c != null && GSTRateslist.get('Australia').GST_Rate__c != null) {
                                        newCase.Bonus_Amount_Payable_AUD__c = ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c;
                                        newCase.Bonus_GST_Payable_AUD__c = (ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                                    }
                                    newCase.Bonus_Amount_Payable_NZD__c = 0;
                                    newCase.Bonus_GST_Payable_NZD__c = 0;
                                } else if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'New Zealand'
                                        || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'NZ') 
                                        && ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c != null) {
                                    newCase.Bonus_Amount_Payable_AUD__c = 0;
                                    newCase.Bonus_GST_Payable_AUD__c = 0;
                                    if (saname != null && ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c != null && GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                                        newCase.Bonus_Amount_Payable_NZD__c = ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c;
                                        newCase.Bonus_GST_Payable_NZD__c = (ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                                    }

                                }
                            }
                        }

                        if (1 < totalsladuration && totalsladuration <= 2) {
                            for (ServiceAgentBonus__c sa : ServiceAgentBonuslist.values()) {
                                if (sa.RepairType__c == newCase.Repair_Type__c && sa.PaymentCategory__c == newCase.Product_Payment_Category__c && sa.Job_Duration__c == '48HR' && sa.Grading__c == caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Service_Agent_Status__c) {
                                    saname = sa.Name;
                                    sacount++;
                                    break;
                                }
                            }
                            if (sacount < 1) {
                                newCase.Bonus_Amount_Payable_AUD__c = 0;
                                newCase.Bonus_Amount_Payable_NZD__c = 0;
                            } else {
                                newCase.Bonus_Amount_Payable_AUD__c = 0;
                                newCase.Bonus_GST_Payable_AUD__c = 0;
                                newCase.Bonus_Amount_Payable_NZD__c = 0;
                                newCase.Bonus_GST_Payable_NZD__c = 0;
                                if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'Australia'
                                        || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'AU')  
                                        && ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c != null ) {
                                    if (saname != null && ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c != null && GSTRateslist.get('Australia').GST_Rate__c != null) {
                                        newCase.Bonus_Amount_Payable_AUD__c = ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c;
                                        newCase.Bonus_GST_Payable_AUD__c = (ServiceAgentBonuslist.get(saname).Bonus_Amount_AUD__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                                    }

                                    newCase.Bonus_Amount_Payable_NZD__c = 0;
                                    newCase.Bonus_GST_Payable_NZD__c = 0;
                                } else if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'New Zealand'
                                        || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'NZ') 
                                        && ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c != null) {
                                    newCase.Bonus_Amount_Payable_AUD__c = 0;
                                    newCase.Bonus_GST_Payable_AUD__c = 0;
                                    if (saname != null && ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c != null && GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                                        newCase.Bonus_Amount_Payable_NZD__c = ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c;
                                        newCase.Bonus_GST_Payable_NZD__c = (ServiceAgentBonuslist.get(saname).Bonus_Amount_NZD__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                                    }

                                }
                            }
                        }

                        if (totalsladuration > 2) {
                            if (sacount < 1) {
                                newCase.Bonus_Amount_Payable_AUD__c = 0;
                                newCase.Bonus_Amount_Payable_NZD__c = 0;
                            }

                        } 
                    }
                }

                if (newCase.Total_Sundry_Expenses__c == null) {
                    newCase.Total_Sundry_Expenses__c = 0;
                }

                if (newCase.Total_Sundry_Expenses__c == 0) {
                    newCase.Sundry_Expense_GST_Payable__c = 0;
                } else {
                    newCase.Sundry_Expense_GST_Payable__c = 0;
                    if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'Australia'
                            || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'AU') 
                            && caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('Australia').GST_Rate__c != null) {
                            //newCase.Sundry_Expense_GST_Payable__c = (newCase.Total_Sundry_Expenses__c * GSTRateslist.get('Australia').GST_Rate__c) / 100;
                            newCase.Sundry_Expense_GST_Payable__c = (newCase.Total_Sundry_Expenses__c / (1 + (GSTRateslist.get('Australia').GST_Rate__c / 100))) * (GSTRateslist.get('Australia').GST_Rate__c / 100);
                        }
                    } else if ((caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'New Zealand'
                            || caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c == 'NZ') 
                            && caseWithParentFieldsMap.get(newCase.Id).Service_Agent__r.Delivery_Country__c != null) {
                        if (GSTRateslist.get('New Zealand').GST_Rate__c != null) {
                            //newCase.Sundry_Expense_GST_Payable__c = (newCase.Total_Sundry_Expenses__c * GSTRateslist.get('New Zealand').GST_Rate__c) / 100;
                            newCase.Sundry_Expense_GST_Payable__c = (newCase.Total_Sundry_Expenses__c / (1 + (GSTRateslist.get('New Zealand').GST_Rate__c / 100))) * (GSTRateslist.get('New Zealand').GST_Rate__c / 100);
                        }
                    }
                    //Below code updated by Upendra Kumar
                    if (newCase.Sundry_Expense_GST_Payable__c != null) {
                        newCase.Total_Sundry_Expenses_Inc_GST__c = newCase.Total_Sundry_Expenses__c + newCase.Sundry_Expense_GST_Payable__c;
                    }
                    //Changes done
                }                
                
                if (newCase.Total_Invoice_Amount__c == 0 && (newCase.SAP_Error_Text__c == null || newCase.SAP_Error_Text__c == '') && (newCase.Freight_Error_Text__c == null || newCase.Freight_Error_Text__c == '')) {
                    newCase.Status = 'Closed';
                    newCase.Service_Request_Milestone__c = 'Closed';
                    newCase.Closed_Reason__c = 'Service Request Completed';
                }
            }
        }
    }

    public static void onAfterUpdate(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        createManSharingRecord(newCases, oldCasesMap);
    }

    public static void createManSharingRecord(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        List<CaseShare> mansharinglist = new List<CaseShare>();
        TTI_queueid__c qid = TTI_queueid__c.getvalues('Warranty Service Request Approval');
        for (Case newCase : newCases) {
            Case oldCase = oldCasesMap.get(newCase.Id);
            if (qid != null && (newCase.OwnerId == qid.id__c) && newCase.OwnerId != oldCase.OwnerId) {
                CaseShare manSharing = new CaseShare();
                manSharing.CaseId = newCase.Id;
                manSharing.UserOrGroupId = oldCase.OwnerId;
                manSharing.CaseAccessLevel = 'Read';
                mansharinglist.add(manSharing);
            }
        }

        try {
            insert mansharinglist;
        } catch (exception err) {
        }
    }

    public static void sendEmailtoCustomerWhenNonWarrantyClaimRejected(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        List<Case> lstCase = new List<Case>();
        for (Case caseObj : newCaseList) {
            if (oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c != 'Closed' && caseObj.Service_Request_Milestone__c == 'Closed' && oldCaseMap.get(caseObj.Id).Closed_Reason__c != 'Rejected by Customer' && caseObj.Closed_Reason__c == 'Rejected by Customer'  && caseObj.TTI_Email_Notification_Opt_In__c == true && (caseObj.SuppliedEmail != null || caseObj.SuppliedEmail != '')) {
                lstCase.add(caseObj);
            }
        }
        if (lstCase != null && lstCase.size() > 0) {
            TTI_Template__c template = TTI_Template__c.getValues('TTI_RejectedNonWarrantyClaimToCustomer');
            List<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = :template.Approved_Claim_Notification_Template__c];
            List<Case> caseWithParentFields = [SELECT Id, Product_Name__r.Name FROM Case WHERE Id IN :lstCase];
            Map<Id, Case> caseWithParentFieldsMap = new Map<Id, Case>();
            for (Case c : caseWithParentFields) {
                caseWithParentFieldsMap.put(c.Id, c);
            }
            String emailBody = '';
            String emailSubject = '';
            if (templateAGE.size() > 0) {
                if (templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != '') {
                    emailBody = templateAGE[0].HtmlValue;
                }
                if (templateAGE[0].Subject != null && templateAGE[0].Subject != '') {
                    emailSubject = templateAGE[0].Subject;
                }
            }
            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            for (Case caseObj : lstCase) {
                if (oldCaseMap.get(caseObj.Id).Service_Request_Milestone__c != 'Closed' && caseObj.Service_Request_Milestone__c == 'Closed' && oldCaseMap.get(caseObj.Id).Closed_Reason__c != 'Rejected by Customer' && caseObj.Closed_Reason__c == 'Rejected by Customer'  && caseObj.TTI_Email_Notification_Opt_In__c == true && (caseObj.SuppliedEmail != null || caseObj.SuppliedEmail != '')) {
                    if (caseObj.RecordTypeId == recordTypeIdCase && caseObj.Claim_Type__c == 'Non-Warranty') {
                        Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                        emailToBeSent.setSaveAsActivity(true);
                        String emailSubjectReplaceCaseNo = '';
                        emailSubjectReplaceCaseNo = emailSubject.replace('caseCaseNumber', caseObj.CaseNumber);
                        if (caseObj.Brand__c != null && caseObj.Brand__c != '' && caseObj.Brand__c != '--None--') {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', caseObj.Brand__c);
                        } else {
                            emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', '');
                        }
                        emailToBeSent.setSubject(emailSubjectReplaceCaseNo);

                        if (emailBody != '' && emailBody != null) {
                            emailBody = emailBody.replace('caseCaseNumber', caseObj.CaseNumber);
                            emailBody = emailBody.replace('productName', caseWithParentFieldsMap.get(caseObj.Id).Product_Name__r.Name);
                            emailBody = emailBody.replace('brandName', caseObj.Brand__c);
                            emailBody = emailBody.replace('Brand_LogoURL', caseObj.TTI_Brand_Logo_URL__c);
                        }
                        List<String> toAddresses = new List<String> {};
                        toAddresses.add(caseObj.SuppliedEmail);
                        emailToBeSent.setHtmlBody(emailBody);
                        emailToBeSent.setTargetObjectId(caseObj.TTI_Customer_Contact__c);
                        emailToBeSent.setToAddresses(toAddresses);
                        emailToBeSent.setWhatId(caseObj.Id);
                        emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                        emailToSent.add(emailToBeSent);
                    }
                }
            }
            if (emailToSent.size() > 0) {
                List<Messaging.SendEmailResult> r1 = Messaging.sendEmail(emailToSent);
            }
        }
    }

/*  Name :- Upendra Kumar
*  Created Date:- 01/09/2018
*  Purpose:- This method will send a Notification to Service Agent
If total calim sundry reached 80% of maximum Sundry allowence
*  Modified By :-
*  Purpose :-
*  Modidired Date :-
*/
    public static void sendNotificationAfterLimit(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        try{
            set<Id> setOfApprovedCaseAgentId = new set<Id>();
            map<Id, decimal> mapOfAgentIdVsAllowence = new map<Id, decimal>();
            map<Id, decimal> mapOfAgentIdVsCurrentTotal = new map<Id, decimal>();
            map<Id, list<Case>> mapOfAgentIdVsListOfClaims = new map<Id, list<Case>>();
            map<Id, date> mapOfAgentIdVsEmailSentDate = new map<Id, date>();
            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            string templateName = 'TTI_Threshold_Email_Notification';
            List<Account> listOfAgentToUpdate = new List<Account>();
            List<EmailTemplate> emailTemplate = [SELECT Id, Subject, HtmlValue FROM 
                                                 EmailTemplate WHERE Name = : templateName LIMIT 1];
            date monthFirstDate = Date.newInstance(System.today().Year(), System.today().month(), 1);           
            date monthLastDate = Date.newInstance(System.today().Year(), System.today().month() + 1, 1);
            
            String emailBody = '';
            String emailSubject = '';
            
            if (emailTemplate.size() > 0){
                if (emailTemplate[0].HtmlValue != null && emailTemplate[0].HtmlValue != '') {
                    emailBody = emailTemplate[0].HtmlValue;
                }
                if (emailTemplate[0].Subject != null && emailTemplate[0].Subject != '') {
                    emailSubject = emailTemplate[0].Subject;
                }
            }
            //This the case of Claim update
            if(oldCaseMap != null){
                for(Case objNewCase : newCaseList){
                    Case objOldCase = oldCaseMap.get(objNewCase.Id);
                    if(objNewCase.Invoiced_Approved__c == true && 
                       objNewCase.Invoiced_Approved__c != objOldCase.Invoiced_Approved__c){
                           setOfApprovedCaseAgentId.add(objNewCase.Service_Agent__c);
                       }
                }
            }
            //This the case of Claim Insert
            else{
                for(Case objNewCase : newCaseList){
                    if(objNewCase.Invoiced_Approved__c == true){
                        setOfApprovedCaseAgentId.add(objNewCase.Service_Agent__c);
                    }
                }
            }
            
            For(Case objCase : [SELECT Id, Service_Agent__c, TTI_CaseFromEmailId__c,
                                Service_Agent__r.Max_Claimable_Sundry_Expenses__c, 
                                Service_Agent__r.TTI_Email_Sent_Date__c,
                                Total_Sundry_Expenses__c,ContactId, Contact.Name,
                                Contact.npe01__HomeEmail__c FROM Case
                                WHERE Service_Agent__c IN: setOfApprovedCaseAgentId
                                AND Invoiced_Approved__c = true
                                AND Completion_Date__c >=: monthFirstDate 
                                AND Completion_Date__c <: monthLastDate
                                AND RecordType.Name = 'Service Request'
                                ORDER By LastModifiedDate DESC]){
                                    //Preparing a map of AgentId Vs Allowence
                                    if(!mapOfAgentIdVsAllowence.containsKey(objCase.Service_Agent__c)){
                                        if(objCase.Service_Agent__r.Max_Claimable_Sundry_Expenses__c != null){
                                            mapOfAgentIdVsAllowence.put(objCase.Service_Agent__c, objCase.Service_Agent__r.Max_Claimable_Sundry_Expenses__c);
                                        } else {
                                            mapOfAgentIdVsAllowence.put(objCase.Service_Agent__c, 0);
                                        }
                                    }
                                    
                                    //Preparing a map of AgentId Vs List Of Claims
                                    if(!mapOfAgentIdVsListOfClaims.containsKey(objCase.Service_Agent__c)) {
                                        mapOfAgentIdVsListOfClaims.put(objCase.Service_Agent__c, new list<Case>());
                                    }
                                    mapOfAgentIdVsListOfClaims.get(objCase.Service_Agent__c).add(objCase);
                                    
                                    //Preparing a map of AgentId Vs Email Sent Date
                                    if(!mapOfAgentIdVsEmailSentDate.containsKey(objCase.Service_Agent__c)){
                                        if(objCase.Service_Agent__r.TTI_Email_Sent_Date__c != null){
                                            mapOfAgentIdVsEmailSentDate.put(objCase.Service_Agent__c, objCase.Service_Agent__r.TTI_Email_Sent_Date__c);
                                        } else {
                                            mapOfAgentIdVsEmailSentDate.put(objCase.Service_Agent__c, system.today().addMonths(-1));
                                        }
                                    }
                                }
            
            For(Id objAgentId : mapOfAgentIdVsListOfClaims.keySet()){
                decimal totalClaimSum = 0;
                For(Case objCase : mapOfAgentIdVsListOfClaims.get(objAgentId)){
                    //Summing up total sundry cost for each Agent
                    if(objCase.Total_Sundry_Expenses__c != null){
                        totalClaimSum += objCase.Total_Sundry_Expenses__c;
                    }
                }
                //Preparing a map of agentId vs total sundry cost
                mapOfAgentIdVsCurrentTotal.put(objAgentId, totalClaimSum);
            }
            
            For(Id objAgentId : mapOfAgentIdVsAllowence.keySet()){
                Case caseObj = mapOfAgentIdVsListOfClaims.get(objAgentId)[0];
                //Checking if agent has been already received mail for current month or not
                if((mapOfAgentIdVsEmailSentDate.get(objAgentId)).month() != (system.today()).month()){
                    decimal capPercentage = decimal.valueOf(label.Cap_Percentage_For_Email_Notification) / 100;
                    if(mapOfAgentIdVsCurrentTotal.get(objAgentId) >= (mapOfAgentIdVsAllowence.get(objAgentId) * capPercentage)){
                        decimal currPercentage = ((mapOfAgentIdVsCurrentTotal.get(objAgentId) / mapOfAgentIdVsAllowence.get(objAgentId)) * 100).setScale(2);
                        //replacing current total percentage
                        emailBody = emailBody.replace('{!xx}', string.valueOf(currPercentage));
                        //replacing Contact Name
                        emailBody = emailBody.replace('{!Contact.Name}', caseObj.Contact.Name);
                        Messaging.SingleEmailMessage emailToBeSent = new Messaging.SingleEmailMessage();
                        emailToBeSent.setSubject(emailSubject);
                        emailToBeSent.setHtmlBody(emailBody);
                        emailToBeSent.setWhatId(caseObj.Id);
                        emailToBeSent.setOrgWideEmailAddressId(caseObj.TTI_CaseFromEmailId__c);
                        emailToBeSent.setTargetObjectId(caseObj.ContactId);
                        emailToSent.add(emailToBeSent);
                        
                        //Upadating send date on agents
                        Account objAgent = new Account(id = objAgentId);
                        objAgent.TTI_Email_Sent_Date__c = system.today();
                        listOfAgentToUpdate.add(objAgent);
                    }
                }
            }
            //Sending mail to agent mail Id
            if(emailToSent.size() > 0){
                Messaging.sendEmail(emailToSent);
            }
            //Upadating send date on agents
            if(listOfAgentToUpdate.size() > 0) {
                update listOfAgentToUpdate;
            }
        }
        catch(Exception objException){
            //Inserting exception log
            string inputParam = '"newCaseList":"' + JSON.serialize(newCaseList) + '", "oldCaseMap":"' + JSON.serialize(oldCaseMap) + '"';
            TTI_LogError.createExceptionLog(objException, inputParam);
        }
    }
}