/**
* @author: Stephen James Laylo
* @date: July 2017
* @description: This class handles all CRUD operations for the
* Case Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class CaseTriggerHandler {

    private static Id productInfoCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Info').getRecordTypeId();
    private static Id productComplaintCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Complaint').getRecordTypeId();
    private static Id customerExperienceCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();
    private static Id b2cPersonAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id orderCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order').getRecordTypeId();
    private static Id redemptionCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Redemption').getRecordTypeId();
    private static Id csOtherCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CS Other').getRecordTypeId();
    private static Id csStandardCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CS Standard').getRecordTypeId();
    private static Id financeCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
    private static Id warehouseCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId();
    private static Boolean runOnce = false;
    private static Boolean populateDefaultValuesRunOnce = false;
    public static String debug = '';

    /**
    * @author: Stephen James Laylo
    * @date: July 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Case
    */ 
    public static void onBeforeInsert(List<Case> newCases) {
        if (!runOnce) {
            if (System.isFuture() || System.isBatch()) {
                createPersonAccountFromWebToCaseSync(newCases);
                runOnce = true;
            } else {
                createPersonAccountFromWebToCaseAsync(JSON.serialize(newCases));
            }
        }
        validateOrPopulateDivision(newCases,null); //RDAVID 8/31 SD-2350
        validateICMCaseAndPopulateChild(newCases,null);
        populateDefaultValues(newCases, null);
        setPotentialDuplicates(newCases, null);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: July 2017
    * @description: This method handles all on After Insert
    * functionalities of the Case
    */ 
    public static void onAfterInsert(List<Case> newCases) {
        // createRelatedEmails(newCases);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: July 2017
    * @description: This method handles all on Before Update
    * functionalities of the Case
    */ 
    public static void onBeforeUpdate(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        if (!populateDefaultValuesRunOnce){
            populateDefaultValues(newCases, oldCasesMap);
            populateDefaultValuesRunOnce = true;
        }
        validateOrPopulateDivision(newCases,null); //RDAVID 8/31 SD-2350
        createCryptoId(newCases);
        validateICMCaseAndPopulateChild(newCases,oldCasesMap);
        setPotentialDuplicates(newCases, oldCasesMap);
    }
    
    @future
    private static void createPersonAccountFromWebToCaseASync(String serializedCaseIds) {
        List<Case> newCases = (List<Case>) JSON.deserialize(serializedCaseIds, List<Case>.class);
        
        createPersonAccountFromWebToCase(newCases);
        runOnce = true;
    }
    
    private static void createPersonAccountFromWebToCaseSync(List<Case> newCases) {
        createPersonAccountFromWebToCase(newCases);
    }

    public static void createPersonAccountFromWebToCase(List<Case> newCases) {
        Savepoint sp = Database.setSavepoint();

        Map<String, String> accountEmailBrandsMap = new Map<String, String>();
        Map<String, String> accountPhoneNameBrandsMap = new Map<String, String>();
        Set<String> accountEmailsSet = new Set<String>();
        Set<String> accountPhonesSet = new Set<String>();
        Set<String> accountBrandSet = new Set<String>();
        List<Group> warrantyQueue = [SELECT Id FROM Group WHERE Name = 'Warranty' AND Type = 'Queue' LIMIT 1];

        for (Case newCase : newCases) {
            if (newCase.Origin == 'Web' && (newCase.RecordTypeId == productInfoCaseRecTypeId || newCase.RecordTypeId == productComplaintCaseRecTypeId || newCase.RecordTypeId == customerExperienceCaseRecTypeId)) {
                if (newCase.SuppliedName == null) {
                    newCase.SuppliedName = '';
                }
                if (newCase.SuppliedPhone == null) {
                    newCase.SuppliedPhone = '';
                }
                if (newCase.SuppliedEmail == null) {
                    newCase.SuppliedEmail = '';
                }
                if (newCase.Type == 'Warranty') {
                    if (!warrantyQueue.isEmpty()) {
                        newCase.OwnerId = warrantyQueue[0].Id;
                    }
                }
                
                accountBrandSet.add(newCase.Brand__c);
                newCase.SuppliedPhone = TTIUtilClass.formatPhoneNumberByCountry(newCase.SuppliedPhone, newCase.Web_Country__c);

                String emailBrandKey = (newCase.SuppliedEmail + '_' + newCase.Brand__c).toLowerCase();
                String phoneNameBrandKey = (newCase.SuppliedPhone + '_' + newCase.Brand__c + '_' + newCase.SuppliedName.replace(' ', '_').replace(',', '')).toLowerCase();

                if (newCase.SuppliedEmail != '') {
                    accountEmailsSet.add(newCase.SuppliedEmail);
                    accountEmailBrandsMap.put(emailBrandKey, newCase.Brand__c);
                }
                if (newCase.SuppliedPhone != '') {
                    accountPhonesSet.add(newCase.SuppliedPhone);
                    accountPhoneNameBrandsMap.put(phoneNameBrandKey, newCase.Brand__c);
                }
            }
        }

        if (accountEmailsSet.isEmpty()) {
            return;
        }
        
        Map<String, Id> personAccountIdsEmailMap = new Map<String, Id>();
        for (Account existingAccount : [SELECT Id, Name, FirstName, LastName, PersonEmail, Phone, Brand__pc FROM Account WHERE RecordTypeId = :b2cPersonAccountRecTypeId AND (PersonEmail IN :accountEmailsSet OR Phone IN :accountPhonesSet)]) {
            if (existingAccount.PersonEmail != null) {
               String emailBrandKey = (existingAccount.PersonEmail + '_' + existingAccount.Brand__pc).toLowerCase();
               String phoneNameBrandKey = (existingAccount.Phone + '_' + existingAccount.Brand__pc + '_' + (existingAccount.LastName + ', ' + existingAccount.FirstName).replace(' ', '_').replace(',', '')).toLowerCase();
                
                if (accountEmailBrandsMap.containsKey(emailBrandKey) && existingAccount.Brand__pc == accountEmailBrandsMap.get(emailBrandKey)) {
                    personAccountIdsEmailMap.put(emailBrandKey, existingAccount.Id);
                } else if ((!accountPhonesSet.isEmpty()) && accountPhoneNameBrandsMap.containsKey(phoneNameBrandKey) && existingAccount.Brand__pc == accountPhoneNameBrandsMap.get(phoneNameBrandKey)) {
                    personAccountIdsEmailMap.put(phoneNameBrandKey, existingAccount.Id);
                }
           }
        }

        List<Account> newPersonAccounts = new List<Account>();

        for (Case newCase : newCases) {
            if (newCase.Origin == 'Web' && (newCase.RecordTypeId == productInfoCaseRecTypeId || newCase.RecordTypeId == productComplaintCaseRecTypeId || newCase.RecordTypeId == customerExperienceCaseRecTypeId)) {
                String emailBrandKey = (newCase.SuppliedEmail + '_' + newCase.Brand__c).toLowerCase();
                String phoneNameBrandKey = (newCase.SuppliedPhone + '_' + newCase.Brand__c + '_' + newCase.SuppliedName.replace(' ', '_').replace(',', '')).toLowerCase();

                Account newAccount = new Account();
                newAccount.Salutation = newCase.Web_Title__c;
                newAccount.FirstName = newCase.SuppliedName.contains(', ') ? newCase.SuppliedName.substringAfter(', ') : newCase.SuppliedName.substringBefore(' ');
                newAccount.LastName = newCase.SuppliedName.contains(', ') ? newCase.SuppliedName.substringBefore(', ') : newCase.SuppliedName.substringAfter(' ');
                newAccount.Phone = newCase.SuppliedPhone;
                newAccount.PersonMailingState = newCase.Web_State__c;
                newAccount.PersonEmail = newCase.SuppliedEmail;
                newAccount.Brand__pc = newCase.Brand__c;
                newAccount.PersonLeadSource = 'Web';
                newAccount.RecordTypeId = b2cPersonAccountRecTypeId;

                if (personAccountIdsEmailMap.containsKey(emailBrandKey)) {
                    newAccount.Id = personAccountIdsEmailMap.get(emailBrandKey);
                } else if (personAccountIdsEmailMap.containsKey(phoneNameBrandKey)) {
                    newAccount.Id = personAccountIdsEmailMap.get(phoneNameBrandKey);
                } else {
                    newAccount.PersonHasOptedOutOfEmail = (!newCase.Newsletter__c);
                }

                newPersonAccounts.add(newAccount);
            }
        }
        try {
            upsert newPersonAccounts;
        } catch (Exception err) {
            System.debug('@Error in Account: ' + err);
        }

        Map<Id, Contact> personAccountContactsMap = new Map<Id, Contact>();
        for (Contact personContact : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :newPersonAccounts]) {
            if (personContact.AccountId != null) {
                personAccountContactsMap.put(personContact.AccountId, personContact);
            }
        }

        for (Case newCase : newCases)  {
            if (newCase.Origin == 'Web' && (newCase.RecordTypeId == productInfoCaseRecTypeId || newCase.RecordTypeId == productComplaintCaseRecTypeId || newCase.RecordTypeId == customerExperienceCaseRecTypeId)) {
                for (Account personAccount : [SELECT Id, Salutation, FirstName, LastName, Phone, PersonMailingState, PersonEmail, Brand__pc, PersonLeadSource, RecordTypeId FROM Account WHERE Id IN :newPersonAccounts]) {
                    if (personAccount.Salutation == newCase.Web_Title__c &&
                        personAccount.FirstName == (newCase.SuppliedName.contains(', ') ? newCase.SuppliedName.substringAfter(', ') : newCase.SuppliedName.substringBefore(' ')) &&
                        personAccount.LastName == (newCase.SuppliedName.contains(', ') ? newCase.SuppliedName.substringBefore(', ') : newCase.SuppliedName.substringAfter(' ')) &&
                        personAccount.Phone == newCase.SuppliedPhone &&
                        personAccount.PersonMailingState == newCase.Web_State__c &&
                        personAccount.PersonEmail == newCase.SuppliedEmail &&
                        personAccount.Brand__pc == newCase.Brand__c &&
                        personAccount.PersonLeadSource == 'Web' &&
                        personAccount.RecordTypeId == b2cPersonAccountRecTypeId) {

                        if (personAccountContactsMap.containsKey(personAccount.Id)) {
                            newCase.AccountId = personAccount.Id;
                            newCase.ContactId = personAccountContactsMap.get(personAccount.Id).Id;
                        }
                    }
                }
            }
        }
        
        
        List<Marketing_Preference__c> existingMarketingPreferences = [SELECT Id, Newsletter__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c IN :newPersonAccounts];
        Map<String, Id> marketingPreferencesPersonAccountsMap = new Map<String, Id>();
        for (Marketing_Preference__c existingMarketingPreference : existingMarketingPreferences) {
            if (existingMarketingPreference.Person_Account__c != null) {
                marketingPreferencesPersonAccountsMap.put(existingMarketingPreference.Person_Account__c, existingMarketingPreference.Id);
            }
        }

        List<Marketing_Preference__c> newMarketingPreferences = new List<Marketing_Preference__c>();

        for (Account personAccount : newPersonAccounts) {
            Marketing_Preference__c newMarketingPreference = new Marketing_Preference__c();

            if (marketingPreferencesPersonAccountsMap.containsKey(personAccount.Id)) {
                newMarketingPreference.Id = marketingPreferencesPersonAccountsMap.get(personAccount.Id);
            } else {
                newMarketingPreference.Person_Account__c = personAccount.Id;
            }

            newMarketingPreferences.add(newMarketingPreference);
        }
            
        
        try {
            upsert newMarketingPreferences;
        } catch (Exception err) {
            System.debug(err);
            Database.rollback(sp);
        }

        for (Case newCase : [SELECT Id, CaseNumber, Contact.Account.Name, Contact.Account.PersonEmail FROM Case WHERE Id IN :newCases]) {
            if (Trigger.isInsert && newCase.Contact.Account.PersonEmail != null) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.ToAddresses = new String[] {newCase.Contact.Account.PersonEmail};
                message.OptOutPolicy = 'FILTER';
                message.Subject = 'Case Created';
                message.PlainTextBody = 'Dear ' + newCase.Contact.Account.Name + ',\nYour case has been created: ' + newCase.CaseNumber;
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }

        return;
    }
    
    /**
     * @author:                     Jerome Liwanag
     * @date:                       Sep 2017
     * @description:                Creates a copy of the emails of the parent case to their
     *                              child cases upon creation
     * 
     * @deprecated                  June 10, 2021
    */ 
    /**  
    public static void createRelatedEmails(List<Case> caseList) {
        Set<Id> caseIds = new Set<Id>();
        for (Case caseLoop : caseList) {
            if (caseLoop.ParentId != null) {
                caseIds.add(caseLoop.ParentId);
            }
        }
        
        List<EmailMessage> emailList = [SELECT Id,
                                               Subject, 
                                               FromName,
                                               FromAddress,
                                               TextBody,
                                               ToAddress,
                                               ParentId,
                                               Status 
                                        FROM EmailMessage 
                                        WHERE ParentId IN :caseIds];
        List<EmailMessage> emailMessagesToCreate = new List<EmailMessage>();
    
        for (Case caseLoop : caseList) {
            if (caseLoop.ParentId != null) {
                for (EmailMessage emailLoop : emailList) {
                    if (emailLoop.ParentId == caseLoop.ParentId) {
                        emailMessagesToCreate.add(new EmailMessage(
                            ParentId = caseLoop.Id, 
                            Subject = emailLoop.Subject, 
                            Status = emailLoop.Status, 
                            FromAddress = emailLoop.FromAddress, 
                            FromName = emailLoop.FromName, 
                            TextBody = emailLoop.TextBody, 
                            ToAddress = emailLoop.ToAddress)); 
                    }
                }
            }
        }
        
        if (!emailMessagesToCreate.isEmpty()) {
            insert emailMessagesToCreate;
        }
    }
    */
    
    /**
    * @author: Jerome Liwanag
    * @date: Sep 2017
    * @description: Populate Default values for the case record
    */ 
    public static void populateDefaultValues(List<Case> caseList, Map<Id,Case> oldCasesMap) {
        Case_Setting__c cs = Case_Setting__c.getInstance();
        
        Set<Id> accIds = new Set<Id>();
        
        for (Case caseLoop : caseList) {
            if(caseLoop.accountId != null){
                accIds.add(caseLoop.accountId);
            }
        }
        List<Contact> conUser = [SELECT Id, AccountId FROM Contact WHERE Name = :cs.Default_Contact_Name_Report__c AND Account.Name = :cs.Default_Account_Name_Report__c LIMIT 1];
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, NVM_Brand__c FROM Account WHERE Id IN :accIds]);
        for (Case caseLoop : caseList) {
            if (oldCasesMap == null) {
                if (caseLoop.SuppliedEmail != null) {
                    if (caseLoop.SuppliedEmail.containsIgnoreCase('Fax')) {
                        caseLoop.Brand__c = 'Milwaukee';
                    }
                }
                if(!conUser.isEmpty()){
                    if (caseLoop.Subject != null) {
                        if (caseLoop.Subject.containsIgnoreCase(cs.Case_Subject_Report__c)) {
                            caseLoop.AccountId = conUser[0].AccountId;
                            caseLoop.ContactId = conUser[0].Id;
                        }
                    }
                }
                if (caseLoop.ContactId != null) {
                    if(caseLoop.Brand__c == null || caseLoop.Brand__c == 'None'){
                        caseLoop.Brand__c = caseLoop.Capture_B2C_brand__c;
                    }
                }
                if (caseLoop.recordTypeId == redemptionCaseRecTypeId && caseLoop.Data_Loaded__c == true) {
                    caseLoop.Type = 'New Redemption';
                    caseLoop.Nature__c = 'Valid';
                    caseLoop.Details__c = 'Redemption Approved';
                    caseLoop.Resolution__c = 'Completed';
                    caseLoop.Select_a_Queue__c = 'Redemptions';
                    caseLoop.Status = 'Closed';
                }
                else if(caseLoop.Origin == 'Email - Reports') {
                    caseLoop.Type = 'Reports';
                    caseLoop.Nature__c = 'Company Report';
                    caseLoop.Details__c = 'Actioned';
                    caseLoop.Resolution__c = 'Completed';
                }
                else if(caseLoop.Description != null && caseLoop.Subject != null){
                    if((caseLoop.Description.containsIgnoreCase('Price') || caseLoop.Description.containsIgnoreCase('Availability') || caseLoop.Subject.containsIgnoreCase('Price') || caseLoop.Subject.containsIgnoreCase('Availability')) && 
                        (caseLoop.Origin == 'Email-CS@TTI' || caseLoop.Origin == 'Email-CS@MW')){
                
                    caseLoop.Type = 'Pricing & Availability';
                    caseLoop.Nature__c = 'Pricing & Availability Enquiry';
                        }
                }
            } else {
                if(caseLoop.Brand__c == null || caseLoop.Brand__c == 'None'){
                    if(caseLoop.Capture_B2C_brand__c != 'None'){
                        caseLoop.Brand__c = caseLoop.Capture_B2C_brand__c;
                    }
                }
            }
        }
    }
    public static void createCryptoId(List<Case> newCases){
        for(Case cs: newCases){
            if(String.isBlank(cs.Case_Encrypted_Id__c)){
                Blob cryptoKey = Crypto.generateAesKey(256);
                Blob caseId = Blob.valueOf(cs.Id);
                Blob encryptedCaseID = Crypto.encryptWithManagedIV('AES256', cryptoKey, caseId);
                cs.Case_Encrypted_Id__c = EncodingUtil.base64Encode(encryptedCaseID).replaceAll('[^a-zA-Z0-9\\s]', '');
            }          
        }
    }

    /**
    * @author: Rexie Aaron David
    * @date: 6/27/2023
    * @description: Populate Potential Duplicate Lookup Field
    */ 
    public static void setPotentialDuplicates(List<Case> caseList, Map<Id,Case> oldCasesMap){

        //Internal
        Set<String> customerRefNumberSet = new Set<String>();
        Set<String> ttiInvoiceNumberIdSet = new Set<String>();
        Map<String,String> ttiInvoiceNumberMap = new Map<String,String>();
        
        //External (email2case)
        Set<String> subjectSet = new Set<String>();
        Set<String> suppliedEmailSet = new Set<String>();

        for(Case caseRec : caseList){
            //Check only for Parent Cases
            if(caseRec.ParentId == NULL){
                //Internal - Email to Case
                if(caseRec.Id == NULL 
                || (caseRec.Id != NULL && (caseRec.TTI_Invoice_Number__c != oldCasesMap.get(caseRec.Id).TTI_Invoice_Number__c) 
                || (caseRec.Customer_PO_number__c != oldCasesMap.get(caseRec.Id).Customer_PO_number__c)
                || (caseRec.Subject != oldCasesMap.get(caseRec.Id).Subject)
                || (caseRec.SuppliedEmail != oldCasesMap.get(caseRec.Id).SuppliedEmail))){
                    if(caseRec.TTI_Invoice_Number__c != NULL && caseRec.Customer_PO_number__c != NULL){
                        customerRefNumberSet.add(caseRec.Customer_PO_number__c);
                        ttiInvoiceNumberIdSet.add(caseRec.TTI_Invoice_Number__c);//Get the TTI Invoice Number Id for Query Preparation
                    }
                    //External - Email to Case
                    if(caseRec.Subject != NULL && caseRec.SuppliedEmail != NULL){
                        subjectSet.add(caseRec.Subject);
                        suppliedEmailSet.add(caseRec.SuppliedEmail);
                    }
                }
            }
        }

        if(ttiInvoiceNumberIdSet.size() > 0){
            for(Sales_History__c sH : [SELECT Id, Billing_Doc__c FROM Sales_History__c WHERE Id IN:  ttiInvoiceNumberIdSet AND Billing_Doc__c != NULL]){
                ttiInvoiceNumberMap.put(sH.Id,sH.Billing_Doc__c);
            }
        }

        if((customerRefNumberSet.size() > 0 && ttiInvoiceNumberMap.keySet().size() > 0 ) || (subjectSet.size() > 0 && suppliedEmailSet.size() > 0)){
            Map<String,String> potentialParentCaseMap = new Map<String,String> ();//Placeholder
            Map<Id,Case> getPotentialParentCaseMap = new Map<Id,Case> ([SELECT Id, Customer_PO_number__c, TTI_Invoice_Number__r.Billing_Doc__c, Subject, SuppliedEmail 
                                                                        FROM Case 
                                                                        WHERE IsClosed = FALSE AND Potential_Duplicate_Case__c = NULL
                                                                        AND ((Customer_PO_number__c IN: customerRefNumberSet AND TTI_Invoice_Number__r.Billing_Doc__c IN: ttiInvoiceNumberMap.values()) OR (Subject IN: subjectSet AND SuppliedEmail IN: suppliedEmailSet)) ]);

            if(!getPotentialParentCaseMap.isEmpty()){
                for(Case potCase : getPotentialParentCaseMap.values()){
                    if(potCase.Customer_PO_number__c != NULL && potCase.TTI_Invoice_Number__c != NULL){
                        potentialParentCaseMap.put((potCase.Customer_PO_number__c+potCase.TTI_Invoice_Number__r.Billing_Doc__c).tolowercase(),potCase.Id);
                    }
                    if(potCase.Subject != NULL && potCase.SuppliedEmail != NULL){
                        potentialParentCaseMap.put((potCase.Subject+potCase.SuppliedEmail).tolowercase(),potCase.Id);
                    }
                }

                for(Case caseRec : caseList){
                    if(caseRec.TTI_Invoice_Number__c != NULL && caseRec.Customer_PO_number__c != NULL){
                        if(potentialParentCaseMap.containsKey((caseRec.Customer_PO_number__c+ttiInvoiceNumberMap.get(caseRec.TTI_Invoice_Number__c)).tolowercase())){
                            Id potentialId = potentialParentCaseMap.get((caseRec.Customer_PO_number__c+ttiInvoiceNumberMap.get(caseRec.TTI_Invoice_Number__c)).tolowercase());
                            if(potentialId != caseRec.Id) caseRec.Potential_Duplicate_Case__c = potentialId;
                        }
                        
                    }
                    if(caseRec.Subject != NULL && caseRec.SuppliedEmail != NULL){
                        if(potentialParentCaseMap.containsKey((caseRec.Subject+caseRec.SuppliedEmail).toLowerCase())){
                            Id potentialId = potentialParentCaseMap.get((caseRec.Subject+caseRec.SuppliedEmail).toLowerCase());
                            if(potentialId != caseRec.Id) caseRec.Potential_Duplicate_Case__c = potentialId;
                        }
                    }
                }
            }
        }
    }

    /**
    * @author: Rexie Aaron David
    * @date: 7/03/2023
    * @description: 
    Validate ICM Cases - Custom Validations via "BEFORE" Trigger - This is a workaround on the Case Maximum reference on related objects limitation.
    Populate Child Case - Logic to auto-populate child records based on the value from the Parent Case
    */ 
    public static void validateICMCaseAndPopulateChild(List<Case> caseList, Map<Id,Case> oldCasesMap){
        
        Set<Id> icmCaseRTSet = new Set<Id> {csOtherCaseRecTypeId,csStandardCaseRecTypeId,financeCaseRecTypeId,warehouseCaseRecTypeId};
        Set<Id> parentCaseIdSet = new Set<Id>();
        Map<Id,Case> parentCaseMap= new Map<Id,Case>();

        for(Case caseRec : caseList){
            if(caseRec.ParentId != NULL && icmCaseRTSet.contains(caseRec.RecordTypeId)){
                parentCaseIdSet.add(caseRec.ParentId);
            }
        }

        if(parentCaseIdSet.size() > 0){
            parentCaseMap = new Map<Id,Case> ([ SELECT  Id, AccountId, ParentId, Subject, Division__c, Courier__c,
                                                        Courier_Con_Note_Number__c, SAP_Order_Free_Text__c, Customer_PO_number__c
                                                FROM Case 
                                                WHERE Id IN: parentCaseIdSet]);
        }

        for(Case caseRec : caseList){
            if(icmCaseRTSet.contains(caseRec.RecordTypeId)){
                //Validation
                Case parentCase = (caseRec.ParentId != NULL && parentCaseMap.containsKey(caseRec.ParentId)) ? parentCaseMap.get(caseRec.ParentId) : new Case();
                if(caseRec.ParentId == NULL && (caseRec.Origin != NULL && !caseRec.Origin.containsIgnoreCase('Email') && !caseRec.Origin.containsIgnoreCase('Fax'))){ //Parent Cases
                    if(caseRec.AccountId == NULL) caseRec.AccountId.addError('Complete this field.');
                    if(caseRec.RecordTypeId == warehouseCaseRecTypeId && (caseRec.Subject == NULL || caseRec.Subject == '-')) caseRec.Subject.addError('Complete this field.');
                    if(caseRec.RecordTypeId == financeCaseRecTypeId && String.isBlank(caseRec.SAP_Order_Free_Text__c)) caseRec.SAP_Order_Free_Text__c.addError('Complete this field.');
                }
                if(caseRec.ParentId != NULL && parentCase.Id != NULL){ //Child Cases
                    //Require AccountId in Child if the Parent Account Id is NULL
                    if(caseRec.AccountId == NULL && parentCase.AccountId == NULL) caseRec.AccountId.addError('Complete this field.');
                    //Require Subject in Child if the Parent Subject Id is NULL - Only require subject for Warehouse Cases
                    if(caseRec.RecordTypeId == warehouseCaseRecTypeId && (caseRec.Subject == NULL || caseRec.Subject == '-') && (parentCase.Subject == NULL || parentCase.Subject == '-')) caseRec.Subject.addError('Complete this field.');
                    if(caseRec.RecordTypeId == financeCaseRecTypeId && String.isBlank(caseRec.SAP_Order_Free_Text__c) && String.isBlank(parentCase.SAP_Order_Free_Text__c)) caseRec.SAP_Order_Free_Text__c.addError('Complete this field.');
                }
                //Populate Child Cases
                if(caseRec.AccountId == NULL && parentCase.AccountId != NULL) caseRec.AccountId = parentCase.AccountId;
                if(caseRec.Division__c == NULL && parentCase.Division__c != NULL) caseRec.Division__c = parentCase.Division__c;
                if(caseRec.Courier__c == NULL && parentCase.Courier__c != NULL) caseRec.Courier__c = parentCase.Courier__c;
                if(caseRec.Courier_Con_Note_Number__c == NULL && parentCase.Courier_Con_Note_Number__c != NULL) caseRec.Courier_Con_Note_Number__c = parentCase.Courier_Con_Note_Number__c;
                if(caseRec.SAP_Order_Free_Text__c == NULL && parentCase.SAP_Order_Free_Text__c != NULL) caseRec.SAP_Order_Free_Text__c = parentCase.SAP_Order_Free_Text__c;
                if(caseRec.Customer_PO_number__c == NULL && parentCase.Customer_PO_number__c != NULL) caseRec.Customer_PO_number__c = parentCase.Customer_PO_number__c;
                if((caseRec.Subject == NULL || caseRec.Subject == '-') && (parentCase.Subject != NULL && parentCase.Subject != '-')) caseRec.Subject = parentCase.Subject;
            }
        }
    }

    /**
    * @author: Rexie Aaron David
    * @date: 8/29/2023
    * @description: [SD-2350] Validate Division Field 
    */ 
    public static void validateOrPopulateDivision(List<Case> caseList, Map<Id,Case> oldCasesMap){

        Set<String> industrialBrands = new Set<String>(System.Label.Industrial_Brands.split(','));
        Set<String> floorcareBrands = new Set<String>(System.Label.Floorcare_Brands.split(','));
        Set<String> consumerBrands = new Set<String>(System.Label.Consumer_Brands.split(','));

        Map<Id,List<Case>> accountCaseMap = new  Map<Id,List<Case>>();
        Map<String,Division_Mapping__c> divisionMap = retrieveDivisionMappings();

        for(Case cse : caseList){
            if(cse.AccountId != NULL){
                //accountIds.add(cse.AccountId);    
                if(!accountCaseMap.containsKey(cse.AccountId)) accountCaseMap.put(cse.AccountId,new List<Case> {cse});
                else {
                    accountCaseMap.get(cse.AccountId).add(cse);
                }
            } 
        }

        Map<Id,Account> accountMap = new Map<Id,Account>([  SELECT Id, RecordType.Name, Type, Owner.Business_Unit__c, Owner.Division, CreatedDate, Customer_Group__c, Customer_Group_1__c, Customer_Group_1_Code__c, IsPersonAccount, Brand__pc 
                                                            FROM Account 
                                                            WHERE Id IN: accountCaseMap.keySet() AND 
                                                            ((Type IN ('Retailer','Head Office') AND Customer_Group_1_Code__c != NULL) 
                                                            OR (Type = 'End Consumer' AND Owner.Business_Unit__c != NULL) 
                                                            OR (IsPersonAccount = TRUE AND Brand__pc != NULL))
                                                        ]);
        if(!accountMap.isEmpty()){
            for(Account acc : accountMap.values()){
                if(accountCaseMap.containsKey(acc.Id)){
                    for(Case cse : accountCaseMap.get(acc.Id)){
                        if(!acc.IsPersonAccount){
                            if((acc.Type == 'Retailer' || acc.Type == 'Head Office') && acc.Customer_Group_1_Code__c != NULL && divisionMap.containsKey(acc.Customer_Group_1_Code__c)){
                                Division_Mapping__c divMap = divisionMap.get(acc.Customer_Group_1_Code__c);
                                if(acc.Customer_Group_1_Code__c == divMap.Group_Code__c && divMap.Division__c != cse.Division__c) {
                                    if(cse.Division__c != NULL){ //Only fire the validation if the Case Division is populated.
                                        cse.Division__c.addError('Please select '+divMap.Division__c+'.');
                                    }
                                    else { //If Division is null populate the Case
                                        cse.Division__c = divMap.Division__c;
                                    }
                                }
                            }
                            else if(acc.Type == 'End Consumer' && acc.Owner.Business_Unit__c != NULL && (acc.Owner.Business_Unit__c == 'Industrial' || acc.Owner.Business_Unit__c == 'Consumer')){
                                if(cse.Division__c != acc.Owner.Business_Unit__c){
                                    if(cse.Division__c != NULL){ //Only fire the validation if the Case Division is populated.
                                        cse.Division__c.addError('Please select '+acc.Owner.Business_Unit__c+'.');
                                    }
                                    else { //If Division is null populate the Case
                                        cse.Division__c = acc.Owner.Business_Unit__c;//divMap.Division__c;
                                    }
                                }
                            }
                        }
                        else{
                            String division;
                            if(industrialBrands.contains(acc.Brand__pc)){
                                division = 'Industrial';
                            }
                            else if(consumerBrands.contains(acc.Brand__pc)){
                                division = 'Consumer';
                            }
                            else if(floorcareBrands.contains(acc.Brand__pc)){
                                division = 'Floorcare';
                            }
                            if(division != NULL && cse.Division__c != division){
                                if(cse.Division__c != NULL){ //Only fire the validation if the Case Division is populated.
                                    cse.Division__c.addError('Please select '+division+'.');
                                }
                                else { //If Division is null populate the Case
                                    cse.Division__c = division;
                                }
                            }
                        } 
                    }    
                }
            }
        }
    }
    

    /**
    * @author: Rexie Aaron David
    * @date: 8/29/2023
    * @description: Retrieve Division Mappings
    */ 
    public static Map<String,Division_Mapping__c> retrieveDivisionMappings(){
        Map<String,Division_Mapping__c> divisionMap = new Map<String,Division_Mapping__c>();
        for(Division_Mapping__c div : [SELECT Id, Division__c, Name, Group__c, Group_Code__c FROM Division_Mapping__c WHERE Active__c = TRUE]){
            divisionMap.put(div.Group_Code__c,div);
        }
        return divisionMap;
    }
}