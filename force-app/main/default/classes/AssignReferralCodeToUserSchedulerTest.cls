@isTest(SeeAllData=false)
public class AssignReferralCodeToUserSchedulerTest {

    private static testMethod void testExecuteScheduler() {
        Test.StartTest();
        
            AssignReferralCodeToUserScheduler refCodeSched = new AssignReferralCodeToUserScheduler();        
            String sch = '0 0 23 30 12 ?'; 
            String jobid = system.schedule('Test Assign Referral Code', sch, refCodeSched); 

            CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
            System.assertEquals(sch,ct.CronExpression);

        Test.stopTest(); 
    }

}