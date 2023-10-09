@isTest
private class MyRyobiCustomerSurveyControllerTest {

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id inPackPromoMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('In Pack Promo').getRecordTypeId();

    @testSetup
    private static void test() {
        Test.startTest();
        
        Account personAccount = new Account();
        personAccount.FirstName = 'Ricardo';
        personAccount.LastName = 'Dalisay';
        personAccount.Delivery_Country__c = 'Australia';
        personAccount.PersonMailingStreet = 'Mainet';
        personAccount.PersonMailingCity = 'Rowville';
        personAccount.PersonMailingState = 'Melbourne';
        personAccount.PersonMailingPostalCode = '4024';
        personAccount.PersonMailingCountry = 'Australia';
        personAccount.PersonEmail = 'test.account@testing.com';
        personAccount.PersonHasOptedOutOfEmail = false;
        personAccount.Brand__pc = 'Ryobi';
        personAccount.PersonMobilePhone = '2413599';
        personAccount.PersonLeadSource = 'Web';
        personAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        
        insert personAccount;

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :personAccount.Id LIMIT 1];

        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        marketingPreference.Newsletter__c = true;
        marketingPreference.DIY_Inspiration__c = true;
        marketingPreference.New_Product_Updates__c = true;
        marketingPreference.Person_Account__c = personAccount.Id;
        insert marketingPreference;
        
        Marketing_Campaign__c marketingCampaign = new Marketing_Campaign__c();
        marketingCampaign.RecordTypeId = inPackPromoMarketingCampaignRecTypeId;
        marketingCampaign.Next_Project_Tools__c = 'Drill; Saw;';
        marketingCampaign.To_Do_List__c = 'Home Maintenance; Gardening;';
        marketingCampaign.Person_Account__c = personAccount.Id;
        insert marketingCampaign;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi'];
        
        User portalUser = new User();
        portalUser.Username = personAccount.PersonEmail + '.tst';
        portalUser.Email = personAccount.PersonEmail;
        portalUser.CommunityNickname = 'Cardo';
        portalUser.ContactId = personContact.Id;
        portalUser.ProfileId = portalProfile.Id;
        portalUser.Alias = 'Cardo123';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LastName = personAccount.LastName;
        portalUser.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';
        
        insert portalUser;
        
        Test.stopTest();
        
        portalUser = [SELECT Id, AccountId, IsActive, IsPortalEnabled FROM User WHERE Id = :portalUser.Id LIMIT 1];
        
        System.assertEquals(personAccount.Id, portalUser.AccountId);
    }
    
    @isTest
    private static void test_method_one() {
        User u = [SELECT Id, ContactId FROM User WHERE Alias = 'Cardo123'];
        System.assertNotEquals('User', MyRyobiCustomerSurveyController.getCurrentUser(u.ContactId));
        System.assertEquals(false, MyRyobiCustomerSurveyController.hasCustomerFinishedSurvey(u.ContactId));
        System.assertEquals('SUCCESS', MyRyobiCustomerSurveyController.saveSurvey(u.ContactId, '2', '3'));
        System.assertEquals(true, MyRyobiCustomerSurveyController.hasCustomerFinishedSurvey(u.ContactId));
        System.assertEquals(null, MyRyobiCustomerSurveyController.getCurrentUser(''));
        System.assertEquals('SUCCESS', MyRyobiCustomerSurveyController.cancelSurvey(u.ContactId));
    }
    
}