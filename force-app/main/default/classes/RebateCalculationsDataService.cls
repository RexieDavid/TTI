/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
public class RebateCalculationsDataService {
    private final String QUERY_REQUIRED_ERR_MESSAGE = 'Query string required.';
    private final String REBATES_REQUIRED_ERR_MESSAGE = 'Rebate records are required.';
    private final String IDS_REQUIRED_ERR_MESSAGE = 'Contract Ids are required.';

    public List<AggregateResultProxy> fetchAggregateResult(String query) {
        if (String.isBlank(query)) {
            throw new RebateCalculationsDataServiceException(this.QUERY_REQUIRED_ERR_MESSAGE);
        }

        try {
            return this.buildAggregateResultProxies(Database.query(query));
        } catch(Exception ex) {
            /**
             * TODO: Implementation of sentry.io
             * 
             * For now, it will throw a generic error in the UI
             */
            throw new RebateCalculationsDataServiceException(Label.Generic_Error_Message); 
        }
    }

    private List<AggregateResultProxy> buildAggregateResultProxies(List<AggregateResult> results) {
        List<AggregateResultProxy> arProxies = new List<AggregateResultProxy>();
        for (AggregateResult agResult : results) {
            arProxies.add(new AggregateResultProxy(agResult));
        }
        return arProxies;
    }

    public void upsertRebates(List<Rebate__c> rebates) {
        if (rebates == null) {
            throw new RebateCalculationsDataServiceException(this.REBATES_REQUIRED_ERR_MESSAGE);
        }

        List<Database.UpsertResult> result = Database.upsert(rebates, Rebate__c.Fields.Rebate_Unique_Id__c, false);
        for (Database.UpsertResult sr : result) {
            if (!sr.isSuccess()) {
                /**
                 * TODO: Implementation of sentry.io
                 * 
                 * For now, it will throw a generic error in the UI
                 */
                throw new RebateCalculationsDataServiceException(Label.Generic_Error_Message);
            }
        }
    }

    public Map<String, List<YearBreakDownForRebates.YearlyBreakDown>> fetchYearlyBreakDown(Set<String> ids) {
        if (ids == null) {
            throw new RebateCalculationsDataServiceException(this.IDS_REQUIRED_ERR_MESSAGE);
        }

        return YearBreakDownForRebates.getYearlyBreakDown(ids);
    }

    /**
     * AggregateResult can't be mocked
     * 
     * Wrap with AggregateResultProxy which can be mocked by test methods. 
    */
    public class AggregateResultProxy {
        public Map<String,Object> proxy = new Map<String,Object>();

        public AggregateResultProxy(AggregateResult result) {
            String jsonResult = JSON.serialize(result);
            this.proxy = (Map<String, Object>) JSON.deserializeUntyped(jsonResult);
        }

        public AggregateResultProxy(Map<String, Object> proxy) {
            this.proxy = proxy;
        }
    }

    public class RebateCalculationsDataServiceException extends Exception {}
}