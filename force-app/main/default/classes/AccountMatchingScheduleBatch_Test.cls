@isTest
public class AccountMatchingScheduleBatch_Test {
    
    static testMethod void testMethod1() 
    {
        List<Account> accList = new List<Account>();
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1]; 
        for(Integer i = 0; i< 5;i++){
            Account a = new Account();
            a.FirstName = 'Test';
            a.LastName = 'Test'+i;
            a.PersonEmail = 'test@test.com';
            a.Brand__pc = 'Ryobi';
            a.Country__pc ='Australia';
            a.PersonMobilePhone = '12312312';
            a.RecordTypeId = rt.Id;
            
            accList.add(a);
        } 
        
        insert accList;
        
        Test.startTest();
			String soql ='SELECT ID FROM Account WHERE isPersonAccount = true AND ParentContact__c = Null';
            AccountMatchingScheduleBatch obj = new AccountMatchingScheduleBatch(soql);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }

}