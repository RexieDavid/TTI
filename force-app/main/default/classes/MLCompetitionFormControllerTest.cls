@isTest
private class MLCompetitionFormControllerTest {
    private static final String LASTNAME = 'Doe' + System.now().millisecond();

    @TestSetup
    private static void makeData() {
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Milwaukee' LIMIT 1];
        User currUser = new User(Id = Userinfo.getUserId());
        Account account = MyMilwaukeeTestDataFactory.createPersonAccount(LASTNAME);
        insert account;

        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        System.runAs(currUser) {
            User user = MyMilwaukeeTestDataFactory.createCustomerCommunityMilwaukeeUser(contact.Id);
            user.ProfileId = communityProfile.Id;
            insert user;
        }
    }

    @isTest
    private static void getUserAccountDetailsTest() {
        String response;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                response = MLCompetitionFormController.getUserAccountDetails();
            }
        Test.stopTest();
        List<User> users = (List<User>)JSON.deserialize(response, List<User>.class);
        System.assertEquals(contact.AccountId, users[0].Contact.AccountId, 'Failed to fetch user account details');
    }

    @isTest
    private static void saveTestWithoutFile() {
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        Test.startTest();
            System.runAs(user) {
                String payload = buildPayload(false);
                MLCompetitionFormController.save(payload);
            }
        Test.stopTest();
        List<Marketing_Campaign__c> marketingCampaigns = [SELECT Id FROM Marketing_Campaign__c];
        System.assert(!marketingCampaigns.isEmpty(), 'Failed to create marketing campaign');
    }

    @isTest
    private static void saveTestWithFile() {
        Test.startTest();
            /**
             * Did not runAs portal user due to the error
             * with network Id with creating a contentversion
             * record
             */
            String payload = buildPayload(true);
            MLCompetitionFormController.save(payload);
        Test.stopTest();
        List<Marketing_Campaign__c> marketingCampaigns = [SELECT Id FROM Marketing_Campaign__c];
        System.assert(!marketingCampaigns.isEmpty(), 'Failed to create marketing campaign');
    }

    private static String buildPayload(Boolean hasFile) {
        Account account = buildUpdatedAccountPayload();
        User user = buildUpdatedUserPayload();
        List<SObject> sobjects = new List<SObject>{ account, user };
        MLCompetitionFormController.MLCompetitionFormWrapper wrapper = new MLCompetitionFormController.MLCompetitionFormWrapper();
        wrapper.marketingCampaign = buildMarketingCampaignPayload(account.Id);
        wrapper.file = hasFile ? buildFilePayload() : null;
        wrapper.marketingCampaignType = 'Job_Site_to_Camp_Site_Competition';
        wrapper.sobjects = sobjects;
        return JSON.serialize(wrapper);
    }

    private static Account buildUpdatedAccountPayload() {
        Account account = [SELECT Id, 
                                  FirstName, 
                                  LastName 
                           FROM Account 
                           WHERE LastName LIKE '%Doe%'
                           LIMIT 1];
        account.FirstName = 'Jane';
        return account;
    }

    private static User buildUpdatedUserPayload() {
        User user = [SELECT Id, 
                            FirstName, 
                            LastName 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1];
        user.FirstName = 'Jane';
        return user;
    }

    private static Marketing_Campaign__c buildMarketingCampaignPayload(String accountId) {
        return new Marketing_Campaign__c(
            Person_Account__c = accountId,
            Agreed_to_Competition_Terms_Conditions__c = true,
            Agreed_to_Terms_and_Conditions__c = true
        );
    }

    private static MLCompetitionFormController.FileWrapper buildFilePayload() {
        String payload = 'base 64 encode';
        MLCompetitionFormController.FileWrapper file = new MLCompetitionFormController.FileWrapper();
        file.fileName = 'Demo File';
        file.base64 = buildBlobPayload();
        return file;
    }

    private static String buildBlobPayload() {
        String payload = 'base 64 encode';
        Blob file = Blob.valueOf(payload);
        return EncodingUtil.base64Encode(file);
    }
}