@isTest
private class CreateAccountAndMapWithInteractionTest {
    /**********************************************************************
    * @description             Initialize data
    */
    @TestSetup
    static void makeData() {
    
        Id personAccountRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account pAccount = new Account(
            RecordTypeId = personAccountRecTypeId,
            FirstName = 'testPerson',
            LastName =  'testAccount',
            Brand__pc = 'AEG',
            Country__pc = 'Australia',
            Record_Status__c = 'Active',
            Type = 'Individual',
            personemail = 'newtest@gmail.com'
        );
        insert pAccount;
        
        BV2__Bazaarvoice_Setting__c bvSetting = new BV2__Bazaarvoice_Setting__c (
            Name = 'testBazaarvoice',
            BV2__Is_Test__c = true,
            BV2__Rating__c = 'All Contents',
            BV2__Moderation_Status__c = 'Approved',
            BV2__Display_Workbench_Client_Responses__c = true,
            BV2__Question__c = true,
            BV2__Answer__c = true,
            BV2__Review__c = true,
            BV2__Comment__c = true,
            BV2__Dummy_Question__c = true,
            BV2__Dummy_Answer__c = true,
            BV2__Dummy_Review__c = true,
            BV2__Dummy_Comment__c = true,
            BV2__Dummy_Rating_Filter__c = 'All reviews',
            BV2__Dummy_Moderation_Status_Filter__c = 'All Contents',
            BV2__Shared_Key_User_Auth__c = 'TEST',
            BV2__Heroku_Hostname__c = 'https://dev-bv-sfdc-crypto.herokuapp.com',
            BV2__Hostname__c = 'TEST_HOST',
            BV2__PassKey__c = 'TEST_PASSKEY',
            BV2__Email_Shared_Key__c='TEST',
            BV2__Client_Response_Passkey__c='TEST',
            BV2__Hubname__c='TEST',
            BV2__Allow_Case_Creation__c = true,
            BV2__Enabled__c = true,
            BV2__Auto_Create_Case_Record_Type__c = 'TEST',
            BV2__Auto_Case_Creation_Period__c  = 30
        );
        insert bvSetting;
        
        BV2__Author__c bvAuthor = new BV2__Author__c (
            BV2__Email_Address__c = 'newtest@gmail.com',
            BV2__BVResp_Author_ID__c = 'TEST',
            BV2__Author_SFDC_ID__c = 'asfg-a00i000000Vi2Zo',
            BV2__location__c = 'TEST',
            FirstName__c = 'AuthorFirstName',
            LastName__c = 'AuthorLastName',
            BV2__Bazaarvoice_Setting__c = bvSetting.Id
        );
        insert bvAuthor;

        BV2__Interaction__c bvInteraction = new BV2__Interaction__c (
            BV2__Author__c = bvAuthor.Id,
            Name = '10381',
            BV2__External_Id__c = 'R-10381testexternalid',
            BV2__Interaction_Type__c = 'Review',
            BV2__Moderation_Status__c = 'APPROVED',
            BV2__Bazaarvoice_Setting__c = bvSetting.Id
        );
        insert bvInteraction;
    }

    private static testMethod void accountLinkedWithInteraction() {
        
        BV2__Author__c bvAuthor = [SELECT Id, 
                                        BV2__Email_Address__c, 
                                        BV2__BVResp_Author_ID__c,
                                        BV2__Author_SFDC_ID__c,
                                        BV2__location__c,
                                        BV2__Bazaarvoice_Setting__c,
                                        FirstName__c,
                                        LastName__c
                                        FROM BV2__Author__c];

        BV2__Interaction__c bvInteraction = [SELECT Id,
                                                    Name,
                                                    BV2__Author__c,
                                                    BV2__External_Id__c,
                                                    BV2__Interaction_Type__c,
                                                    BV2__Moderation_Status__c,
                                                    BV2__Bazaarvoice_Setting__c,
                                                    BV2__Rating__c
                                                    FROM BV2__Interaction__c];
        
        Test.startTest();
        CreateAccountAndMapWithInteraction createAccount = new CreateAccountAndMapWithInteraction();
        String scheduleTime = '0 20 * * * ?';
        String scheduleName = 'Bazaarvoice Account Mapping 19 Min';                           
        System.schedule(scheduleName, scheduleTime, createAccount);
        Test.stopTest();
        
        List<Account> accountCreated = [SELECT Id, PersonEmail FROM Account LIMIT 1];
        System.assert(!accountCreated.isEmpty(), 'No Account was created.');
        System.assertEquals(bvAuthor.BV2__Email_Address__c, accountCreated[0].PersonEmail, 'Account does not match.');
        System.assertEquals(bvAuthor.Id, bvInteraction.BV2__Author__c, 'Incorrect Interaction Author.');
    }
}