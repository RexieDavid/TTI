@isTest
private class TTI_SubmitClaimControllerTest {

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();

    @TestSetup
    static void makeData() {
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Warranty'];
        Account personAccount = new Account();
        personAccount.FirstName = 'Dominador';
        personAccount.LastName = 'De Leon';
        personAccount.Delivery_Country__c = 'Australia';
        personAccount.PersonMailingStreet = 'Mainet';
        personAccount.PersonMailingCity = 'Rowville';
        personAccount.PersonMailingState = 'Melbourne';
        personAccount.PersonMailingPostalCode = '4024';
        personAccount.PersonMailingCountry = 'Australia';
        personAccount.PersonEmail = 'test.account3@testing.com';
        personAccount.PersonHasOptedOutOfEmail = false;
        personAccount.Brand__pc = 'Ryobi';
        personAccount.PersonMobilePhone = '2413594';
        personAccount.PersonLeadSource = 'Web';
        personAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        insert personAccount;

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :personAccount.Id LIMIT 1];

        User portalUser = new User();
        portalUser.Username = personAccount.PersonEmail + '.tst';
        portalUser.Email = personAccount.PersonEmail;
        portalUser.CommunityNickname = 'Ador';
        portalUser.ContactId = personContact.Id;
        portalUser.ProfileId = portalProfile.Id;
        portalUser.Alias = 'Ador123';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LastName = personAccount.LastName;
        portalUser.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';
        insert portalUser;
        
        Case newCase = TTI_CommonUtilityClass.createCase();
        newCase.Brand__c = 'Milwaukee';
        newCase.Goods_Movement_Reference__c = 'Created';
        newCase.Completion_Date__c = Date.today();
        insert newCase;
        
        Service_Request_Line_Item__c srl = new Service_Request_Line_Item__c();
		srl.Order_Line_Category__c = 'Manual Entry';
		srl.Order_Line_Type__c = 'Part';
		srl.Service_Request_Number__c = newCase.id;
		srl.Unit_Cost__c  = 20;
		srl.Quantity__c = 2;
		insert srl;
    }
    
    @isTest
    private static void getUserTest() {
        User userRetrieved = new User();
        User comUser = [SELECT Id FROM User WHERE Username = :'test.account3@testing.com.tst'];
        Test.startTest();
            System.runAs(comUser) {
                userRetrieved = TTI_SubmtClaimController.getUserType();
            }
        Test.stopTest();
        System.assertEquals(userRetrieved.Id, comUser.Id, 'User returned no Account');
    }
    
    @isTest
    private static void test_method_one() {
        TTI_SubmtClaimController.dummyTest();
        TTI_PdfAndEmailHandler.testDummy();
        
        PageReference pageRef = Page.TTI_JobSummary_Milwaukee;
        Test.setCurrentPage(pageRef);
        Case rec = [SELECT Id FROM Case];
        ApexPages.currentPage().getParameters().put('caseId',rec.id);
        
        TTI_JobSummaryReceiptController js = new TTI_JobSummaryReceiptController();
    }
}