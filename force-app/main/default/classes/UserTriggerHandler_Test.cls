@isTest
public class UserTriggerHandler_Test {
    
    /*static testMethod void onAfterInsert_Test() {
        
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.Parent_Contact__pc = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.Ryobi',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        
        

        
    }*/
    
   
}