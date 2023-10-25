/**
* @author: Jerome Liwanag
* @date: Mar 2017
* @description: This class handles all CRUD operations for the
* Account Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class AccountTriggerHandler {
    
    // Account Record Types
    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    public static Id serviceAgentRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_SERVICE_AGENT).getRecordTypeId();
    public static Id commercialRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_COMMERCIAL).getRecordTypeId();
    public static Id repAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_REP_ACCOUNT).getRecordTypeId();
    public static Id headOfficeAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT).getRecordTypeId();
    public static Id headOfficeEndConsumerRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT_END_CONSUMER).getRecordTypeId();
    public static Id industryAssocRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_INDUSTRY_ASSOCIATION).getRecordTypeId();
    public static Id internalTTIRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_INTERNAL_TTI_DIVISION_HQ).getRecordTypeId();
    public static Id endConsumerRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_END_CONSUMER).getRecordTypeId();
    public static Boolean updateMarketingPreferenceSubscriptionsRunOnce = false;
    public static Boolean updateUsernameFromPersonAccountEmailRunOnce = false;
    public static Boolean assignRecTypesRunOnce = false;
    public static Boolean assignParentAccountRunOnce = false;
    public static Boolean changeNumberFormatRunOnce = false;
    private static final String COMMUNITY_PROFILE_COMPLETION_PACKAGE = 'community_profile_completion';
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Account
    */ 
    public static void onBeforeInsert(List<Account> newAccounts) {
        assignRecTypes(newAccounts);
        assignOwnerId(newAccounts);
        assignParentAccount(newAccounts);
        populateRecordStatus(newAccounts);
        changePhoneNumberFormat(newAccounts);
        getPersonLeadSource(newAccounts, null);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all on After Insert
    * functionalities of the Account
    */ 
    public static void onAfterInsert(List<Account> newAccounts) {
        createProjectAccounts(newAccounts);
        updateMarketingPreferenceSubscriptions(newAccounts, null);
        updateUsernameFromPersonAccountEmail(newAccounts, null);
        //updateFormstackPrefillURL(newAccounts);
        // assignContactToCase(newAccounts);
        updateEligibleCustomers(newAccounts);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all on Before Update
    * functionalities of the Account
    */ 
    public static void onBeforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        if (!assignRecTypesRunOnce) {
            assignRecTypes(newAccounts);
            assignRecTypesRunOnce = true;
        }

        if (!assignParentAccountRunOnce) {
            assignParentAccount(newAccounts);
            assignParentAccountRunOnce = true;
        }

        if (!changeNumberFormatRunOnce) {
            changePhoneNumberFormat(newAccounts);
            changeNumberFormatRunOnce = true;
        }

        populateRecordStatus(newAccounts);
        assignOwnerId(newAccounts);
        getPersonLeadSource(newAccounts, oldAccountsMap);

        
        try {
            System.debug('%%%called from account trigger');
            CommunityProfileCompletion commProfCmpltnClass = new CommunityProfileCompletion(newAccounts, oldAccountsMap);
            commProfCmpltnClass.populateAccountRuleset();
            commProfCmpltnClass.computeAccountProfilePercentage();
        } catch (Exception e) {
            // CommunityProfileCompletion package does not exist
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all on After Update
    * functionalities of the Account
    */ 
    public static void onAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
       // if (!BunningsPOSTriggerHandler.hasFiredBunningsPOSTrigger) {
            if (!updateMarketingPreferenceSubscriptionsRunOnce) {
                updateMarketingPreferenceSubscriptions(newAccounts, oldAccountsMap);
                updateMarketingPreferenceSubscriptionsRunOnce = true;
            }
            if (!updateUsernameFromPersonAccountEmailRunOnce) {
                updateUsernameFromPersonAccountEmailRunOnce = true;
                updateUsernameFromPersonAccountEmail(newAccounts, oldAccountsMap);
            }
        	updateEligibleCustomers(newAccounts);
        //}
    }
    
    public static void getPersonLeadSource(List<Account> accList, Map<Id, Account> oldAccountsMap) {
        for (Account ac : accList) {
            if (oldAccountsMap == null) {
                //multi is null
                ac.Lead_Source_Multi__c = ac.PersonLeadSource;
            } else {
                //multi is not null
                if (ac.PersonLeadSource != null && oldAccountsMap.get(ac.Id).PersonLeadSource != null && oldAccountsMap.get(ac.Id).PersonLeadSource != ac.PersonLeadSource) {
                    //lead source, multi are not null and old value is not equal to latest value
                    if (ac.Lead_Source_Multi__c == null) {
                        //multi is null
                        ac.Lead_Source_Multi__c = '';
                    }
                    if (oldAccountsMap.get(ac.Id).Lead_Source_Multi__c == null) {
                        //old multi is null
                        ac.Lead_Source_Multi__c = oldAccountsMap.get(ac.Id).PersonLeadSource+ ';' +ac.PersonLeadSource;
                    } else if (!oldAccountsMap.get(ac.Id).Lead_Source_Multi__c.contains(ac.PersonLeadSource)) {
                        //old value and latest value are equal
                        ac.Lead_Source_Multi__c = oldAccountsMap.get(ac.Id).Lead_Source_Multi__c + ';' +ac.PersonLeadSource;
                    }
                } else {
                    //lead source and multi are null
                    ac.Lead_Source_Multi__c = ac.PersonLeadSource;
                }
            }
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all the updating of the Account
    * Record Type based on the Type field of the Account
    */ 
    public static void assignRecTypes(List<Account> accList) {
        for (Account accLoop : accList) {
            if (accLoop.Customer_Group__c != null) {
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_SERVICE_AGENT) {
                    accLoop.RecordTypeId = serviceAgentRecId;
                }
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_RETAILER) {
                    accLoop.RecordTypeId = commercialRecId;
                }
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_REP_ACCOUNT) {
                    accLoop.RecordTypeId = repAccountRecId;
                }
            } else {
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE) {
                    accLoop.RecordTypeId = headOfficeAccountRecId;
                }
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_END_CONSUMER) {
                    accLoop.RecordTypeId = headOfficeEndConsumerRecId;
                }
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_INDUSTRY_ASSOCIATION) {
                    accLoop.RecordTypeId = industryAssocRecId;
                }
                if (accLoop.Type == GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_INTERNAL) {
                    accLoop.RecordTypeId = internalTTIRecId;
                }
            }
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles the owner Id assignment if there
    * are any users that has the same REP Id as that of the pernr field of the Account
    */ 
    public static void assignOwnerId(List<Account> accList) {
        Set<String> pernrSet = new Set<String>();
        for (Account accLoop : accList) {
            if(accLoop.pernr__c != null) {
                pernrSet.add(accLoop.pernr__c);
            }
        }
        
        if(pernrSet.isEmpty()) {
            return;
        }
        
        Map<String, Id> userMap = new Map<String, Id>();
        
        List<User> userList = [Select Id, Name, SRC_RepId__c, Profile.UserLicense.Name 
                                                 From User 
                                                 Where Profile.UserLicense.Name = 'Salesforce'
                                                 And SRC_RepId__c != null 
                                                 And IsActive = true];
        for (User userLoop:userList) {
            userMap.put( userLoop.SRC_RepId__c, userLoop.id);
        }
        
        for (Account accLoop : accList) {
            if (userMap.containsKey(accLoop.pernr__c) && (accLoop.RecordTypeId == commercialRecId || accLoop.RecordTypeId == repAccountRecId)) {
                accLoop.OwnerId  = userMap.get(accLoop.pernr__c);              
            }
        }
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles the parent Account assignment
    * based on the customer group and salesorganisation of the Head office
    * Account
    */
    public static void assignParentAccount(List<Account> accList) {
        
        // Get all Retailer HQ Accounts
        Map<String, Map<String, Id>> headOfficeAccountMap = new Map<String, Map<String, Id>>(); 
        
        List<Account> headOfficeAccounts = [SELECT Id, Customer_Group_1_Code__c, Sales_Organisation__c FROM Account WHERE RecordTypeId = :headOfficeAccountRecId];
        
        for (Account headOfficAccLoop:headOfficeAccounts) {
            if (headOfficAccLoop.Sales_Organisation__c != null) {  
                headOfficeAccountMap.put(headOfficAccLoop.Customer_Group_1_Code__c, 
                    new Map<String, Id>{headOfficAccLoop.Sales_Organisation__c => headOfficAccLoop.Id});
            }
        }
        
        for (Account accLoop : accList) {
            if (accLoop.RecordTypeId == commercialRecId
                    && accLoop.Customer_Group_1_Code__c != null 
                    && accLoop.Sales_Organisation__c != null 
                    && headOfficeAccountMap.containsKey(accLoop.Customer_Group_1_Code__c)) {
                Map<String, Id> headOfficeAccountSalesOrgMap = headOfficeAccountMap.get(accLoop.Customer_Group_1_Code__c);
                if (headOfficeAccountSalesOrgMap.containsKey(accLoop.Sales_Organisation__c)) {
                    accLoop.ParentId = headOfficeAccountSalesOrgMap.get(accLoop.Sales_Organisation__c);
                }
            }
        }
    }

    /**
    * @author: Jerome Liwanag
    * @date: Mar 2017
    * @description: This method handles all the creation of Project Accounts
    * if there are Project records that has the same BCI Project Id value as
    * that of the Account being inserted
    */ 
    public static void createProjectAccounts(List<Account> accList) {
        List<Project_Account__c> projListToAdd = new List<Project_Account__c>();
        Map<Id, String> accBCIMap = new Map<Id, String>();
        
        for (Account accLoop : accList) {
            if (accLoop.BCI_ProjectId__c != null) {
                accBCIMap.put(accLoop.Id, accLoop.BCI_ProjectId__c);
            }
        }
        
        List<Project__c> projList = [SELECT id, BCI_Project_Id__c, Name FROM Project__c WHERE BCI_Project_Id__c IN :accBCIMap.values() limit 200];
        
        for (Account accLoop : accList) {
            if (accBCIMap.containsKey(accLoop.Id) && (accLoop.RecordTypeId == endConsumerRecId || accLoop.RecordTypeId == headOfficeEndConsumerRecId)) {
                for (Project__c projLoop : projList) {
                    if (projLoop.BCI_Project_Id__c == accLoop.BCI_ProjectId__c) {
                        
                        Project_Account__c projAcc = new Project_Account__c();
                        projAcc.ProjectRef__c = projLoop.id;
                        projAcc.AccountRef__c = accLoop.Id;
                        if (accLoop.BCI_Role__c != null) {
                            projAcc.Role__c = accLoop.BCI_Role__c;
                        }
                        projListToAdd.add(projAcc);
                    }
                }
            }
        }
        
        if (!projListToAdd.isEmpty()) {
            insert projListToAdd;
        }
    }

    @future
    public static void updateUsersAsynchronously(String serializedUserIds) {
        List<User> users = (List<User>) JSON.deserialize(serializedUserIds, List<User>.class);
        
        try {
            update users;
        } catch (Exception err) { }
    }
    
    public static void updateUsersSynchronously(List<User> users) {
        try {
            update users;
        } catch (Exception err) { }
    }

    /**
    * @author: Stephen James Laylo
    * @date: July 2017
    * @description: This method handles the update of User's Username based on Account's Email
    */ 
    public static void updateUsernameFromPersonAccountEmail(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        List<Account> accounts = [SELECT Id, Is_Community_User__c FROM Account WHERE RecordType.Name = 'B2C Consumer Contact' AND Id IN :newAccounts];
        List<User> usersToBeUpdated = [SELECT Id, Name, Contact.AccountId, Contact.Account.PersonEmail, Contact.Brand__c, Email, Username FROM User WHERE Contact.AccountId IN :accounts AND Contact.Account.RecordType.Name = 'B2C Consumer Contact' AND IsActive = true];
        Boolean isEmailUpdated = false;

        for (User u : usersToBeUpdated) {
            if (oldAccountsMap == null) {
                if (u.Contact.Account.PersonEmail != null) {
                    u.Email = u.Contact.Account.PersonEmail;
                    u.Username = u.Contact.Account.PersonEmail + ('.' + u.Contact.Brand__c).toLowerCase().replace(' ', '');
                }
                isEmailUpdated = true;
            } else {
                if (oldAccountsMap.containsKey(u.Contact.Account.Id)) {
                    Account oldAccount = oldAccountsMap.get(u.Contact.Account.Id);

                    if (u.Contact.Account.PersonEmail != oldAccount.PersonEmail) {
                        if (u.Contact.Account.PersonEmail != null) {
                            u.Email = u.Contact.Account.PersonEmail;
                            u.Username = u.Contact.Account.PersonEmail + ('.' + u.Contact.Brand__c).toLowerCase().replace(' ', '');
                        }
                        isEmailUpdated = true;
                    }
                }
            }    
        }

        if (isEmailUpdated) {
            if (System.isFuture() || System.isBatch()) {
                updateUsersSynchronously(usersToBeUpdated);
            } else {
                updateUsersAsynchronously(JSON.serialize(usersToBeUpdated));
            }
        } 
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles the update of Marketing Preference Subscriptions
    */ 
    public static void updateMarketingPreferenceSubscriptions(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        List<Account> accounts = [SELECT Id, Is_Community_User__c, PersonHasOptedOutOfEmail FROM Account WHERE RecordType.Name = 'B2C Consumer Contact' AND Id IN :newAccounts];
        List<Marketing_Preference__c> marketingPreferences = new List<Marketing_Preference__c>();
        List<Marketing_Preference__c> marketingPreferencesToAdd = new List<Marketing_Preference__c>();
        
        Set<Id> optInAccountIds = new Set<Id>();
        Set<Id> optOutAccountIds = new Set<Id>();
        
        for (Account newAccount : accounts) {
            if (oldAccountsMap == null) {
                if (newAccount.PersonHasOptedOutOfEmail) {
                    optOutAccountIds.add(newAccount.Id);
                } else {
                    optInAccountIds.add(newAccount.Id);
                }
            } else {
                if (oldAccountsMap.containsKey(newAccount.Id)) {
                    Account oldAccount = oldAccountsMap.get(newAccount.Id);
                    
                    if (newAccount.PersonHasOptedOutOfEmail != oldAccount.PersonHasOptedOutOfEmail) {
                        if (newAccount.PersonHasOptedOutOfEmail) {
                            optOutAccountIds.add(newAccount.Id);
                        } else {
                            optInAccountIds.add(newAccount.Id);
                        }
                    }
                }
            }
        }
        
        List<Marketing_Preference__c> optInMarketingPreferences = [SELECT Id, DIY_Inspiration__c, New_Product_Updates__c, Newsletter__c, SMS__c FROM Marketing_Preference__c WHERE Person_Account__c IN :optInAccountIds];
        if (!optInMarketingPreferences.isEmpty()) {
            for (Marketing_Preference__c optInMarketingPreference : optInMarketingPreferences) {
                optInMarketingPreference.DIY_Inspiration__c = true;
                optInMarketingPreference.New_Product_Updates__c = true;
                optInMarketingPreference.Newsletter__c = true;
                optInMarketingPreference.SMS__c = true;
            }
        } else {
            for (Account accLoop : [SELECT Id FROM Account WHERE Id IN :optInAccountIds]) {
                marketingPreferencesToAdd.add(new Marketing_Preference__c(Person_Account__c = accLoop.Id, 
                                                                          DIY_Inspiration__c = true, 
                                                                          New_Product_Updates__c = true, 
                                                                          Newsletter__c = true, 
                                                                          SMS__c = true));
                
            }
        }
        
        
        List<Marketing_Preference__c> optOutMarketingPreferences = [SELECT Id, DIY_Inspiration__c, New_Product_Updates__c, Newsletter__c FROM Marketing_Preference__c WHERE Person_Account__c IN :optOutAccountIds];
        if (!optOutMarketingPreferences.isEmpty()) {
            for (Marketing_Preference__c optOutMarketingPreference : optOutMarketingPreferences) {
                optOutMarketingPreference.DIY_Inspiration__c = false;
                optOutMarketingPreference.New_Product_Updates__c = false;
                optOutMarketingPreference.Newsletter__c = false;
                optOutMarketingPreference.SMS__c = false;
            }
        } else {
            for (Account accLoop : [SELECT Id FROM Account WHERE Id IN :optOutAccountIds]) {
                marketingPreferencesToAdd.add(new Marketing_Preference__c(Person_Account__c = accLoop.Id, 
                                                                          DIY_Inspiration__c = false, 
                                                                          New_Product_Updates__c = false, 
                                                                          Newsletter__c = false, 
                                                                          SMS__c = false));
                
            }
        }
        
        marketingPreferences.addAll(optInMarketingPreferences);
        marketingPreferences.addAll(optOutMarketingPreferences);
        
        if (!marketingPreferences.isEmpty()) {
            try {
                update marketingPreferences;
            } catch(DMLException e) {
              // Implement logger once live
            }
        } else if (!marketingPreferencesToAdd.isEmpty()) {
            try {
                insert marketingPreferencesToAdd;
            } catch(DMLException e) {
              // Implement logger once live
            }
        }
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: December 2017
    * @description: This method handles the formatting of phone number based on country to Account
    */ 
    public static void changePhoneNumberFormat(List<Account> accList) {
        for (Account accLoop : accList) {
            String country = accLoop.BillingCountry;

            if (accLoop.RecordTypeId == b2cConsumerContactAccRecTypeId) {
                country = accLoop.Country__pc;

                accLoop.PersonMobilePhone = TTIUtilClass.formatPhoneNumberByCountry(accLoop.PersonMobilePhone, country);
                accLoop.PersonHomePhone = TTIUtilClass.formatPhoneNumberByCountry(accLoop.PersonHomePhone, country);
                accLoop.PersonOtherPhone = TTIUtilClass.formatPhoneNumberByCountry(accLoop.PersonOtherPhone, country);
            }

            accLoop.Phone = TTIUtilClass.formatPhoneNumberByCountry(accLoop.Phone, country);
            accLoop.Fax = TTIUtilClass.formatPhoneNumberByCountry(accLoop.Fax, country);
        }
    }

    /**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles the value of Record Status of a Person Account
    */ 
    public static void populateRecordStatus(List<Account> accList) {
        for (Account accLoop : accList) {
            if (accLoop.RecordTypeId == b2cConsumerContactAccRecTypeId && accLoop.Registration_complete__c 
                    && (accLoop.PersonLeadSource == 'MYRYOBI' || accLoop.PersonLeadSource == 'MYAEG')) {
                accLoop.Record_Status__c = 'Active';
            }
        }
    }
    
        /**
    * @author: Lawrence Catan
    * @date: Sept 2023
    * @description: This method will update related Eligible_Customer__c 
    * records related to the Account if the Account's Send to MCloud field
    * is TRUE, set corresponding Send to MC field on Eligible_Customer__c
    */ 
    public static void updateEligibleCustomers(List<Account> accList) {
        List<Eligible_Customer__c> eligListToUpdate = new List<Eligible_Customer__c>();
        Set<Id> acctsSendtoMC = new Set<Id>();
        
        for (Account accLoop : accList) {
            //if (accLoop.Send_to_MCloud__pc == true) {
                acctsSendtoMC.add(accLoop.id);
            //}
        }
        
        List<Eligible_Customer__c> eligList = [SELECT id, Customer__c, Send_to_MC__c FROM Eligible_Customer__c WHERE Customer__c =: acctsSendtoMC];
        
        for(Account accLoop : accList){
            for(Eligible_Customer__c ec: eligList){
                if(accLoop.id == ec.Customer__c){
                    ec.Send_to_MC__c = accLoop.Send_to_MCloud__pc;
                    eligListToUpdate.add(ec);
                }
            } 
        }   

        System.debug('eligListToUpdate >>> '+eligListToUpdate);
        
        if (!eligListToUpdate.isEmpty()) {
            update eligListToUpdate;
        }
    }

    /**
     * @author:                     Jerome Liwanag
     * @date:                       Sep 2017
     * @description:                This method handles the automatic
     *                              assignation of contact and account to a case based on
     *                              its email and the case' web email
     * 
     * @history                     Kristopher Veraces 05-08-2020
     *                              Commenting-out the code but not permanent
     *                              delete as it can be uncommented in 
     *                              different stream and for reference. .
    */ 
    /*
    public static void assignContactToCase(List<Account> accList) {
        Map<String, Account> emailAccountsMap = new Map<String, Account>();
        for (Account accLoop : accList) {
            if (accLoop.RecordTypeId == b2cConsumerContactAccRecTypeId && String.isNotBlank(accLoop.PersonEmail)) {
                emailAccountsMap.put(accLoop.PersonEmail, accLoop);
            }
        }
        
        if (!emailAccountsMap.isEmpty()) {
            List<Case> eCasesList = [SELECT Id,
                                            SuppliedEmail,
                                            AccountId,
                                            ContactId
                                     FROM Case
                                     WHERE SuppliedEmail IN :emailAccountsMap.keySet() 
                                     AND ContactId = null];

            if (!eCasesList.isEmpty()) {
                for (Case eCase : eCasesList) {
                    eCase.AccountId = emailAccountsMap.get(eCase.SuppliedEmail).Id;
                    eCase.ContactId = emailAccountsMap.get(eCase.SuppliedEmail).PersonContactId;
                }

                // DML statement
                Database.SaveResult[] srList = Database.update(eCasesList, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) { 
                            // Will implement the logger once live
                        }
                    }
                }
            }
        }
    }
    */
    /*public static void updateFormstackPrefillURL(List<Account> accounts) {
        List<Id> accountIds = new List<Id>();
        List<Account> newAccounts = [SELECT Id, Website FROM Account WHERE Id IN :accounts];
        for (Account account : newAccounts) {
            // if (account.RecordTypeId == b2cConsumerContactAccRecTypeId && account.Brand__c == 'Milwaukee') {
                accountIds.add(account.Id);
            // }
        }
        VisualAntidote.FastFormsUtilities.DoUpdateRecords('Account', 'Website', 'a5Z5O000000127TUAQ', accountIds, null);
        update newAccounts;
    }*/
}