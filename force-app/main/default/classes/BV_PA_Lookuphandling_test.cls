@isTest
public class BV_PA_Lookuphandling_test{
/* Test class moved to BvPaLookuphandlingTest

public static string userId;
     
    static testMethod void testManageAuthorIds1()
    {  
        BV2__BVCustomSetting__c  cs;
        cs = new BV2__BVCustomSetting__c();
        cs.Name = 'BVDefaultSetting';
        cs.BV2__Disable_Triggers__c = false;
        insert cs;
        BV2__LookupCriteria__c lstCr = new  BV2__LookupCriteria__c();
        lstCr.Name = 'test';
        lstCr.BV2__Rule_Entry__c = 'email_address__c EQUALS personemail';
          

        Upsert lstCr; 
        BV2__Bazaarvoice_Setting__c bs = new BV2__Bazaarvoice_Setting__c(BV2__Allow_Case_Creation__c=true,BV2__Heroku_Hostname__c='https://dev-bv-sfdc-crypto.herokuapp.com',BV2__Hostname__c='http://api.bazaarvoice.com', BV2__PassKey__c='test', BV2__Email_Shared_Key__c='test',BV2__Client_Response_Passkey__c='test',BV2__Hubname__c='test',BV2__Shared_Key_User_Auth__c = 'test');
        insert bs;
                
        userId = UserInfo.getUserId();
        BV2__Author__c a = new BV2__Author__c();
        
        a.BV2__BVResp_Author_ID__c = 'TESTNAME23947832';
        a.BV2__User__c = userId;
        a.BV2__email_address__c = 'test@test.com';
        a.BV2__Location__c = 'US';
        a.BV2__isAnswerSubmitted__c = true;
        a.BV2__Bazaarvoice_Setting__c = bs.Id;
        insert a;
        
    BV2__Interaction__c testInt = new BV2__Interaction__c();
        testInt.Name = 'test';
        testInt.BV2__Bazaarvoice_Setting__c = bs.Id;
        testInt.BV2__Author__c = a.Id;
        testInt.BV2__Interaction_Type__c = 'Review';
        testInt.BV2__Create_Case__c = false;
        testInt.BV2__Moderator_Code__c = 'CR';
        testInt.BV2__Language_Code__c='en';
        testInt.BV2__Country_Code__c ='US';
        testInt.BV2__Moderation_Status__c = 'APPROVED';
        Database.insert(testInt, false);
        
        
        BV2__Author__c auth = [Select Id,BV2__BVResp_Author_ID__c,BV2__Location__c,BV2__User__c From BV2__Author__c Where BV2__BVResp_Author_ID__c = 'TESTNAME23947832' AND BV2__User__c =: userId];
        auth.BV2__Location__c = 'Austin';
        database.update(auth, false);
    
      
        system.assert(true);
    }
    
     
     static testMethod void testManageAuthorIds2()
    {  
        
        BV2__LookupCriteria__c lstCr = new  BV2__LookupCriteria__c();
        lstCr.Name = 'test';
        lstCr.BV2__Rule_Entry__c = 'bv2__email_address__c EQUALS personemail';
          

        Upsert lstCr; 

        BV2__BVCustomSetting__c  cs;
        cs = new BV2__BVCustomSetting__c();
        cs.Name = 'BVDefaultSetting';
        cs.BV2__Disable_Triggers__c = false;
        insert cs;
        
        BV2__Bazaarvoice_Setting__c bs = new BV2__Bazaarvoice_Setting__c(BV2__Allow_Case_Creation__c=true,BV2__Heroku_Hostname__c='https://dev-bv-sfdc-crypto.herokuapp.com',BV2__Hostname__c='http://api.bazaarvoice.com', BV2__PassKey__c='test', BV2__Email_Shared_Key__c='test',BV2__Client_Response_Passkey__c='test',BV2__Hubname__c='test',BV2__Shared_Key_User_Auth__c = 'test');
        insert bs;
         system.debug('bs rec : '+bs);
       /* sObject testAcc = new Account();
        
        Boolean isPersionAccountOrg = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
        if (isPersionAccountOrg == True)
        {
            RecordType rectype =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
            testAcc.put('lastname', 'test');
            testAcc.put('personemail', 'test@test.com');
            if (rectype != null)
                testAcc.put('recordtypeid', '01290000001Ij66');
            insert testAcc;
        }
        else
        {
            testAcc.put('name', 'test');
            insert testAcc;
        }    * /     
        userId = UserInfo.getUserId();
        BV2__Author__c a = new BV2__Author__c();
        
        a.BV2__BVResp_Author_ID__c = 'TESTNAME23947832';
        a.BV2__User__c = userId;
        a.BV2__email_address__c = 'test@test.com';
        a.BV2__Location__c = 'US';
        a.BV2__isAnswerSubmitted__c = true;
        a.BV2__Bazaarvoice_Setting__c = bs.Id;
        a.FirstName__c = 'Test';
        a.LastName__c  = 'User';
        insert a;
        system.debug('author rec : '+a);

         BV2__Interaction__c testInt = new BV2__Interaction__c();
        testInt.Name = 'test';
        testInt.BV2__Bazaarvoice_Setting__c = bs.Id;
        testInt.BV2__Author__c = a.Id;
        testInt.BV2__Interaction_Type__c = 'Review';
        testInt.BV2__Create_Case__c = false;
        testInt.BV2__Moderator_Code__c = 'CR';
        testInt.BV2__Language_Code__c='en';
        testInt.BV2__Country_Code__c ='US';
        testInt.BV2__Moderation_Status__c = 'APPROVED';
        Database.insert(testInt, false);
        BV2__Author__c auth = [Select Id,BV2__BVResp_Author_ID__c,BV2__Location__c,BV2__User__c From BV2__Author__c Where BV2__BVResp_Author_ID__c = 'TESTNAME23947832' AND BV2__User__c =: userId];
        auth.BV2__Location__c = 'Austin';
        database.update(auth, false);
    
      
        system.assert(true);
    }


*/
}