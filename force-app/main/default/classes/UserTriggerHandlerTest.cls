@isTest
private class UserTriggerHandlerTest {
    
    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id inPackPromoMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('In Pack Promo').getRecordTypeId();

    @isTest
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
        
        Account personAccount2 = new Account();
        personAccount2.FirstName = 'Dominador';
        personAccount2.LastName = 'De Leon';
        personAccount2.Delivery_Country__c = 'Australia';
        personAccount2.PersonMailingStreet = 'Mainet';
        personAccount2.PersonMailingCity = 'Rowville';
        personAccount2.PersonMailingState = 'Melbourne';
        personAccount2.PersonMailingPostalCode = '4024';
        personAccount2.PersonMailingCountry = 'Australia';
        personAccount2.PersonEmail = 'test.account3@testing.com';
        personAccount2.PersonHasOptedOutOfEmail = false;
        personAccount2.Brand__pc = 'Ryobi';
        personAccount2.PersonMobilePhone = '2413594';
        personAccount2.PersonLeadSource = 'Web';
        personAccount2.RecordTypeId = b2cConsumerContactAccRecTypeId;
        
        insert personAccount2;

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :personAccount.Id LIMIT 1];
        Contact personContact2 = [SELECT Id FROM Contact WHERE AccountId = :personAccount2.Id LIMIT 1];
        
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

        User portalUser2 = new User();
        portalUser2.Username = personAccount2.PersonEmail + '.tst';
        portalUser2.Email = personAccount2.PersonEmail;
        portalUser2.CommunityNickname = 'Ador';
        portalUser2.ContactId = personContact2.Id;
        portalUser2.ProfileId = portalProfile.Id;
        portalUser2.Alias = 'Ador123';
        portalUser2.EmailEncodingKey = 'UTF-8';
        portalUser2.LastName = personAccount2.LastName;
        portalUser2.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser2.LocaleSidKey = 'en_US';
        portalUser2.LanguageLocaleKey = 'en_US';
        testFuture(JSON.serialize(portalUser2));
        
        Test.stopTest();
        
        portalUser = [SELECT Id, AccountId, IsActive, IsPortalEnabled FROM User WHERE Id = :portalUser.Id LIMIT 1];
        
        System.assertEquals(personAccount.Id, portalUser.AccountId);
    }
    
    @future
    private static void testFuture(String userJson) {
        User u = (User) JSON.deserialize(userJson, User.class);
        insert u;
        
        u.Alias = 'OppaAdor';
        //update u;
    }

}