/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
@isTest
public class RebateCalculationsDataServiceMock implements System.StubProvider {
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) { 

        switch on stubbedMethodName { 
            when 'fetchAggregateResult' {
                return this.createAggregateResult();
            }
            when 'upsertRebates' {
                List<Rebate__c> rebates = (List<Rebate__c>) listOfArgs.get(0);
                return this.addRecordIds(rebates);
            }
            when 'fetchYearlyBreakDown' {
                return this.createYearlyBreakdown();
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    private List<RebateCalculationsDataService.AggregateResultProxy> createAggregateResult() {
        List<RebateCalculationsDataService.AggregateResultProxy> results = 
            new List<RebateCalculationsDataService.AggregateResultProxy>();
        for (Integer i = 0; i < 5; i++) {
            Map<String, Object> agProxy = new Map<String, Object> {
                'AccountId' => RebateCalculationTest.ACCOUNT_IDS.get(i),
                'CloseDate' => Date.today() - i,
                'expr0' => 1000 + 1
            };
            results.add(new RebateCalculationsDataService.AggregateResultProxy(agProxy));
        }
        return results;
    }

    private List<Rebate__c> addRecordIds(List<Rebate__c> rebates) {
        List<Rebate__c> rebatesWithId = new List<Rebate__c>();
        for (Rebate__c rebate : rebates) {
            rebate.Id = DataMock.Id.generate(Rebate__c.SObjectType);
            rebatesWithId.add(rebate);
        }
        return rebatesWithId;
    }

    private Map<String, List<YearBreakDownForRebates.YearlyBreakDown>> createYearlyBreakdown() {
        Date startDate = Date.newInstance(2020, 1, 1);
        Integer monthsInAYear = 12;
        Map<String, List<YearBreakDownForRebates.YearlyBreakDown>> yearlyBreakDown = new Map<String, List<YearBreakDownForRebates.YearlyBreakDown>>();
        List<YearBreakDownForRebates.YearlyBreakDown> breakdowns = new List<YearBreakDownForRebates.YearlyBreakDown>();
        for (Integer i = 0; i < 5; i++) {
            startDate = startDate.addMonths(monthsInAYear * i);
            breakdowns.add(new YearBreakDownForRebates.YearlyBreakDown(
                startDate, 
                startDate.addMonths(monthsInAYear).addDays(-1), 
                false, 
                RebateCalculationTest.CONTRACT_ID));
        }
        yearlyBreakDown.put(RebateCalculationTest.CONTRACT_ID, breakdowns);
        return yearlyBreakDown;
    }
}