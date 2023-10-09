@isTest
private class QuarterlyRebateTest {
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
    private static void quarterRebateCalculationTest() {
        Test.startTest();
            RebateCalculations.service = service;
            QuarterRebateCalculation quarterRebate = new QuarterRebateCalculation(QUERY);
            Database.executeBatch(quarterRebate);
        Test.stopTest();
        System.assert(!RebateCalculations.contracts.isEmpty(), 'Failed to fetch contract records');
    }

    @isTest
    static void quarterlyRebateCalculationScheduleJobTest() {
        Integer currYear = Date.today().year();
        String cronExp = '0 0 0 15 3 ? ' + (currYear + 2);
        String jobId;
        Test.startTest();
            jobId = System.schedule('QuarterlyRebateJob', cronExp, new QuarterlyRebate());
        Test.stopTest();
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression, 'Different CRON Expression');
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered, 'Scheduled job executed');
    }
}