@isTest
private class MlCatalogueFormControllerTest {
    private static final String MARKETING_TYPE = 'Catalogue_Campaign_2022';
    private static final Long UNIQUE_ID = System.now().getTime();
    private static final String LASTNAME = 'Doe' + UNIQUE_ID;
    
    @TestSetup
    private static void makeData() {
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Milwaukee' LIMIT 1];
        User currUser = new User(Id = Userinfo.getUserId());
        Account account = MyMilwaukeeTestDataFactory.createPersonAccount(LASTNAME);
        account.PersonEmail = 'johndoe@mailinator.com';
        insert account;

        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        System.runAs(currUser) {
            User user = MyMilwaukeeTestDataFactory.createCustomerCommunityMilwaukeeUser(contact.Id);
            user.ProfileId = communityProfile.Id;
            insert user;
        }
    }

    @isTest
    private static void fetchExistingLeadIdWithoutParams() {
        String error;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                try {
                    MlCatalogueFormController.fetchExistingLeadId('', 2022);
                } catch (Exception ex) {
                    error = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals('Must provide email and campaign year.', error, 'Successfully retrieved lead records');
    }

    @isTest
    private static void fetchExistingLeadIdNonExistentRecord() {
        String response;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId, Email FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                response = MlCatalogueFormController.fetchExistingLeadId(user.Email, 2022);
            }
        Test.stopTest();
        System.assert(String.isBlank(response), 'Successfully retrieved lead records');
    }

    @isTest
    private static void fetchExistingLeadIdExistingRecord() {
        String response;
        Contact contact = [SELECT Id, AccountId, Account.PersonEmail FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId, Email FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Lead lead = buildLeadRecord(contact.AccountId);
        insert lead;
        Test.startTest();
            System.runAs(user) {
                response = MlCatalogueFormController.fetchExistingLeadId(contact.Account.PersonEmail, 2022);
            }
        Test.stopTest();
        System.assertEquals(String.valueOf(lead.Id), response, 'Failed to retrieve lead record');
    }

    @isTest
    private static void fetchExistingMarketingCampaignIdWithoutParams() {
        String error;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                try {
                    MlCatalogueFormController.fetchExistingMarketingCampaignId('');
                } catch (Exception ex) {
                    error = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals('Must provide account details.', error, 'Successfully retrieved marketing campaign records');
    }

    @isTest
    private static void fetchExistingMarketingCampaignIdNonExistentRecord() {
        String response;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId, Email FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                response = MlCatalogueFormController.fetchExistingMarketingCampaignId(contact.AccountId);
            }
        Test.stopTest();
        System.assert(String.isBlank(response), 'Successfully retrieved marketing campaign records');
    }

    @isTest
    private static void fetchExistingMarketingCampaignIdExistingRecord() {
        String response;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId, Email FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Marketing_Campaign__c campaign = buildMarketingCampaignRecord(contact.AccountId);
        insert campaign;
        Test.startTest();
            System.runAs(user) {
                response = MlCatalogueFormController.fetchExistingMarketingCampaignId(contact.AccountId);
            }
        Test.stopTest();
        System.assertEquals(campaign.Id, response, 'Failed to retrieve marketing campaign record');
    }

    private static Lead buildLeadRecord(String accountId) {
        Account account = fetchAccountRecord(accountId);
        return new Lead(
            FirstName = account.FirstName,
            LastName = account.LastName,
            Email = account.PersonEmail,
            Phone = account.PersonMobilePhone,
            Company = account.Company_Name__c,
            Industry_Type__c = account.Industry_Type__c,
            Street = account.PersonMailingStreet,
            City = account.PersonMailingCity,
            State = account.PersonMailingState,
            PostalCode = account.PersonMailingPostalCode,
            Country = 'Australia',
            LeadSource = 'Web Page - Milwaukee',
            Comments__c = 'Catalogue 2022 AU'
        );
    }

    private static Account fetchAccountRecord(String accountId) {
        return [SELECT FirstName,
                       LastName,
                       PersonEmail,
                       PersonMobilePhone,
                       Company_Name__c,
                       Industry_Type__c,
                       PersonMailingStreet,
                       PersonMailingCity,
                       PersonMailingState,
                       PersonMailingPostalCode
                FROM Account
                WHERE Id = :accountId
                LIMIT 1];
    }

    private static Marketing_Campaign__c buildMarketingCampaignRecord(String accountId) {
        String recordtypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName().get(MARKETING_TYPE).getRecordTypeId();
        return new Marketing_Campaign__c(
            RecordTypeId = recordtypeId,
            Person_Account__c = accountId
        );
    }

}