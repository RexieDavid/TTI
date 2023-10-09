@isTest
public class AccountMatchingScheduler_Test {
    
    public static testMethod void testschedule() {

	Test.StartTest();
        AccountMatchingScheduler sh1 = new AccountMatchingScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test batch', sch, sh1); 
     Test.stopTest(); 
    }

}