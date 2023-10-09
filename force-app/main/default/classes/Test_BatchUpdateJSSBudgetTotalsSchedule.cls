@isTest
private class Test_BatchUpdateJSSBudgetTotalsSchedule {

    static testMethod void ScheduleTest() {
        Test.StartTest();
		Batch_UpdateJSSBudgetTotalsSchedule sh1 = new Batch_UpdateJSSBudgetTotalsSchedule();        
		String sch = '0 0 23 * * ?';
		System.schedule('Test Check', sch, sh1);
		Test.stopTest();
    }
}