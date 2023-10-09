/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
@isTest
private class RebateCalculationsDataServiceTest {
    private static final RebateCalculationsDataService service = new RebateCalculationsDataService();
    private static final String SOQL_QUERY = 'SELECT Id, Sum(Amount) FROM Opportunity GROUP BY Id';

    @isTest
    private static void fetchAggregateResultTest() {
        List<RebateCalculationsDataService.AggregateResultProxy> agProxies;
        Test.startTest();
            agProxies = service.fetchAggregateResult(SOQL_QUERY);
        Test.stopTest();
        System.assert(agProxies != null, 'Failed to fetch aggregate results');
    }

    @isTest
    private static void fetchAggregateResultNegativeTest() {
        String errMessage;
        Test.startTest();
            try {
                service.fetchAggregateResult(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Query string required.', errMessage, 'Successfully fetch aggregate results');
    }

    /**
     * Will insert test data in the database to have an
     * aggregate result
     * 
     * Possible it will cause an issue in the future due
     * to validations or required fields
     */
    @isTest
    private static void fetchAggregateResultWithDBDataTest() {
        List<RebateCalculationsDataService.AggregateResultProxy> agProxies;
        insert createOpportunity();
        Test.startTest();
            agProxies = service.fetchAggregateResult(SOQL_QUERY);
        Test.stopTest();
        System.assert(agProxies != null, 'Failed to fetch aggregate results');
    }

    @isTest
    private static void upsertRebatesTest() {
        Test.startTest();
            service.upsertRebates(new List<Rebate__c>());
        Test.stopTest();
        // Don't have assertion for successfuly inserts
    }

    @isTest
    private static void upsertRebatesNegativeTest() {
        String errMessage;
        Test.startTest();
            try {
                service.upsertRebates(null);
            } catch(Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Rebate records are required.', errMessage, 'Successfully committed rebate records in database');
    }

    @isTest
    private static void fetchYearlyBreakDownTest() {
        Map<String, List<YearBreakDownForRebates.YearlyBreakDown>> breakdowns;
        Test.startTest();
            breakdowns = service.fetchYearlyBreakDown(new Set<String>());
        Test.stopTest();
        System.assert(breakdowns != null, 'Failed to fetch yearly breakdowns');
    }

    @isTest
    private static void fetchYearlyBreakDownNegativeTest() {
        String errMessage;
        Test.startTest();
            try {
                service.fetchYearlyBreakDown(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Contract Ids are required.', errMessage, 'Successfully fetch yearly breakdowns');
    }

    private static Opportunity createOpportunity() {
        return new Opportunity(
            Name = 'Dummy_Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 100
        );
    }
}