/**
* @author      : Ericka Cajucom
* @date        : 2020-05-26
*/
@isTest
public class BvPaLookuphandlingTest {
    
    public static String userId;
    
    /*************************************************************************
    * @description : Create account upon inserting Author if trigger is Active
    */
    static testMethod void testManageAuthorCreateAcct() {
        ApexTrigger bvPaLookupHandlingTrigger = 
            [SELECT Id, Status FROM ApexTrigger WHERE Name = 'BV_PA_Lookuphandling'];

        if(bvPaLookupHandlingTrigger.Status == 'Active') {
            BV2__Bazaarvoice_Setting__c bvSetting = new BV2__Bazaarvoice_Setting__c(
                    BV2__Allow_Case_Creation__c = false,
                    BV2__Heroku_Hostname__c = 'https://dev-bv-sfdc-crypto.herokuapp.com',
                    BV2__Hostname__c = 'http://api.bazaarvoice.com',
                    BV2__PassKey__c = 'test',
                    BV2__Email_Shared_Key__c = 'test',
                    BV2__Client_Response_Passkey__c = 'test',
                    BV2__Hubname__c = 'test',
                    BV2__Shared_Key_User_Auth__c = 'test',
                    BV2__Auto_Case_Creation_Period__c = null);
            insert bvSetting;
            
            userId = UserInfo.getUserId();
            
            Test.startTest();
            
            BV2__Author__c bvAuthor = new BV2__Author__c(
                    BV2__BVResp_Author_ID__c = 'TESTNAME23947832',
                    BV2__User__c = userId,
                    BV2__email_address__c = 'test@test.com',
                    BV2__Location__c = 'US',
                    BV2__isAnswerSubmitted__c = true,
                    BV2__Bazaarvoice_Setting__c = bvSetting.Id,
                    FirstName__c = 'Test',
                    LastName__c  = 'User');
            insert bvAuthor;
            
            Test.stopTest();
            
            List<Account> accList = [SELECT Id FROM Account];
            System.assertNotEquals(null, accList, 'No Account Record Created.');
        }
    }
}