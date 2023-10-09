@isTest
private class MlJobSiteFormControllerTest {
    private static final String LASTNAME = 'Doe' + System.now().millisecond();

    @TestSetup
    private static void makeData() {
        User currUser = new User(Id = Userinfo.getUserId());
        Account account = MyMilwaukeeTestDataFactory.createPersonAccount(LASTNAME);
        insert account;

        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        User user = MyMilwaukeeTestDataFactory.createCustomerCommunityMilwaukeeUser(contact.Id);
        insert user;
    }

    @isTest
    private static void getUserAccountDetailsTest() {
        String response;
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        System.runAs(user) {
            response = MlJobSiteFormController.getUserAccountDetails();
        }
        List<User> users = (List<User>)JSON.deserialize(response, List<User>.class);
        System.assertEquals(contact.AccountId, users[0].Contact.AccountId, 'Failed to fetch user account details');
    }

    @isTest
    private static void saveTest() {
        String payload = buildPayload();
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE '%Doe%' LIMIT 1];
        User user = [SELECT Id, Name, Profile.Name, ContactId FROM User WHERE ContactId = :contact.Id LIMIT 1];
        MlJobSiteFormController.save(payload);
        List<Marketing_Campaign__c> marketingCampaigns = [SELECT Id FROM Marketing_Campaign__c];
        System.assert(!marketingCampaigns.isEmpty(), 'Failed to create marketing campaign');
    }

    private static String buildPayload() {
        MlJobSiteFormController.JobSiteFormWrapper wrapper = new MlJobSiteFormController.JobSiteFormWrapper();
        Account account = buildUpdatedAccountPayload();
        wrapper.account = account;
        wrapper.user = buildUpdatedUserPayload();
        wrapper.marketingCampaign = buildMarketingCampaignPayload(account.Id);
        wrapper.file = buildFilePayload();
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

    private static MlJobSiteFormController.FileWrapper buildFilePayload() {
        String payload = 'base 64 encode';
        MlJobSiteFormController.FileWrapper file = new MlJobSiteFormController.FileWrapper();
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