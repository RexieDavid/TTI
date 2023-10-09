/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
@isTest
private class DailyRebateTest {
    private static final String QUERY = 'SELECT Id, EndDate FROM Contract';
    private static RebateCalculationsDataService service = 
        (RebateCalculationsDataService) Test.createStub(
            RebateCalculationsDataService.class, 
            new RebateCalculationsDataServiceMock());

    @TestSetup
    private static void makeData() {
        Id approvedRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Approved').getRecordTypeId();
        Account account = TestData.createAccounts(1)[0];
        insert account;

        Contract contract = TestData.createContracts(1, account.Id)[0];
        contract.AccountId = account.Id;
        insert contract;
    }

    @isTest
    private static void dailyRebateCalculationTest() {
        Test.startTest();
            RebateCalculations.service = service;
            DailyRebateCalculation dailyRebate = new DailyRebateCalculation(QUERY);
            Database.executeBatch(dailyRebate);
        Test.stopTest();
        System.assert(!RebateCalculations.contracts.isEmpty(), 'Failed to fetch contract records');
    }

    @isTest
    private static void dailyRebateCalculationScheduleJobTest() {
        Integer currYear = Date.today().year();
        String cronExp = '0 0 0 15 3 ? ' + (currYear + 2);
        String jobId;
        Test.startTest();
            jobId = System.schedule('DailyRebateJob', cronExp, new DailyRebate());
        Test.stopTest();
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, TimesTriggered, CronExpression FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression, 'Different CRON Expression');
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered, 'Scheduled job executed');
    }
}