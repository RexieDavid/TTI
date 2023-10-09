/**
 * @author                          Haider Raza
 * @date                            07/04/2016
 * @description                     Calculate rebates
 * 
 * @Note                            Word of caution - Kris 
 * 
 *                                  Be careful in changing class scope
 *                                  variable names, all are in static 
 *                                  context and possible that it is 
 *                                  use in other classes.
 * 
 *                                  Same with method names, some of it have 
 *                                  wrong spellings. Don't change it 
 *                                  abruptly without checking if it's 
 *                                  reference in other classes.
**/
public class RebateCalculations {
    public static List<Contract> contracts;
    public static Map<String, Contract> contractsMap;
    public static Map<String, String> accountTocontractMap = new Map<String, String>();
    public static Set<String> accountIds = new Set<String>();
    public static Map<String, List<Contract_Tier__c>> tiers = new Map<String, List<Contract_Tier__c>>();
    public static Map<String, Map<String, Contract_Tier__c>> tiers1 = new Map<String, Map<String, Contract_Tier__c>>();
    public static Map<String, Tier> rebateTiers = new Map<String, Tier>();
    public static Map<String, Tier> rebateNextYearSpend = new Map<String, Tier>();
    public static List<Rebate__c> rebates = new List<Rebate__c>();
    public static Map<String, Double> rollupSum = new Map<String, Double>();
    public static Map<String, Rebate__c> dailyRebates = new Map<String, Rebate__c>();
    public static Date QuarterStartDate;
    public static String maxAutoNumber;
    public static Map<String, String> maxTierContract = new Map<String, String>();
    public static Map<String, List<YearBreakDownForRebates.YearlyBreakDown>> yrlyBreakDown = new Map<String, List<YearBreakDownForRebates.YearlyBreakDown>>();
    public static Map<String, YearBreakDownForRebates.YearlyBreakDown> dailyContractIds = new Map<String, YearBreakDownForRebates.YearlyBreakDown>();
    public static Boolean isDailyRebate = false;
    public static Boolean isDailyretrospective = false;

    @TestVisible
    private static RebateCalculationsDataService service = new RebateCalculationsDataService();
    private static final String MISSING_OPPORTUNITY_CLOSED_DATE = 'Missing Opportunity Close Date.';
    private static final String MISSING_QUARTER_RANGE_DATE = 'Missing Quarter Range Dates.';

    public static void prepareCollections() {
        if (contracts.isEmpty()) {
            return;
        }
        for (Contract contract : contracts) {
            setDailyRebates(contract.Rebates__r);
            for (Contract_Account__c contractAccount : contract.Contract_Accounts__r) {
                accountIds.add(contractAccount.Account__c);
                accountTocontractMap.put(contractAccount.Account__c, contract.Id);
                if (!contract.Contract_Tiers__r.isEmpty()) {
                    tiers.put(contract.Id, contract.Contract_Tiers__r);
                    setContractTiers(contract);
                }
            }
        }
        getYearlyBreakdown();
    }

    private static void setDailyRebates(List<Rebate__c> rebates) {
        for (Rebate__c rebate : rebates) {
            dailyRebates.put(rebate.Rebate_Unique_Id__c, rebate);
        }
    }

    private static void setContractTiers(Contract contract) {
        Map<String, Contract_Tier__c> tiers = new Map<String, Contract_Tier__c>();
        for (Contract_Tier__c tier : contract.Contract_Tiers__r) {
            tiers.put(tier.Auto_Number__c, tier);
            maxAutoNumber = tier.Auto_Number__c;
        }
        tiers1.put(contract.Id, tiers);
        maxTierContract.put(contract.Id, maxAutoNumber);
    }

    private static void getYearlyBreakdown() {
        contractsMap = new Map<String, Contract>(contracts);
        yrlyBreakDown = service.fetchYearlyBreakDown(contractsMap.keySet());
    }

    public static void retreiveDailyOpportunityRollup(Date oppCloseDate) {
        isValidDate(oppCloseDate);
        List<String> fields = new List<String>{'AccountId', 'CloseDate'};
        List<String> filters = getDailyOpportunityQueryFilter(oppCloseDate);
        for (RebateCalculationsDataService.AggregateResultProxy result : 
                service.fetchAggregateResult(getOpportunityRollupQuery(fields, filters))) {
            Map<String,Object> agProxy = result.proxy;
            String accountId = String.valueOf(agProxy.get('AccountId'));
            if (accountTocontractMap.containsKey(accountId)) {
                String contractId = String.valueOf(accountTocontractMap.get(accountId));
                Double amount = agProxy.get('expr0') != null ? Double.valueOf(agProxy.get('expr0')) : 0;
                String closeDate = String.valueOf(agProxy.get('CloseDate'));
                processDailyOpportunity(contractId, Date.valueOf(closeDate), amount);
            }
        }
    }

    private static void isValidDate(Date closeDate) {
        if (closeDate == null) {
            throw new RebateCalculationsException(MISSING_OPPORTUNITY_CLOSED_DATE);
        }
    }

    private static List<String> getDailyOpportunityQueryFilter(Date oppCloseDate) {
        List<String> filters = getQueryFilters(false, oppCloseDate, null);
        /**
         * It will also fetch all opportunities that was closed
         * and won before the date specified
         */
        filters.set(2, 'CloseDate <= ' + removeTimeStamp(oppCloseDate));
        return filters;
    }

    private static void processDailyOpportunity(String contractId, Date closeDate, Double amount) {
        YearBreakDownForRebates.YearlyBreakDown closeDateBreakDown = getYearlyBreakDown(contractId, closeDate);
        if (closeDateBreakDown != null) {
            String key = contractId + ': ' + closeDateBreakDown.StartDate + '-' + closeDateBreakDown.EndDate;
            computeRollupSum(key, amount);
            setDailyContractId(key, closeDateBreakDown, contractId);
        }
    }

    private static YearBreakDownForRebates.YearlyBreakDown getYearlyBreakDown(String contractId, Date closeDate) {
        if (!yrlyBreakDown.containsKey(contractId)) {
            return null;
        }
        return YearBreakDownForRebates.getCurrentYear(yrlyBreakDown.get(contractId), closeDate);
    }

    private static void setDailyContractId(String key, YearBreakDownForRebates.YearlyBreakDown yearlyBreakDown, String contractId) {
        dailyContractIds.put(
            key, 
            new YearBreakDownForRebates.YearlyBreakDown(
                yearlyBreakDown.StartDate, 
                yearlyBreakDown.EndDate, 
                null, 
                contractId)
        );
    }

    public static void retreiveOpportunityRollup(Date qStartDate, Date qEndDate, Date oppCloseDate, Boolean isQuarterRebate) {
        isValidDate(qStartDate, qEndDate, oppCloseDate, isQuarterRebate);
        List<String> fields = new List<String>{'AccountId'};
        List<String> filters = getQueryFilters(isQuarterRebate, isQuarterRebate ? qStartDate : oppCloseDate, qEndDate);
        for (RebateCalculationsDataService.AggregateResultProxy result : 
                service.fetchAggregateResult(getOpportunityRollupQuery(fields, filters))) {
            Map<String,Object> agProxy = result.proxy;
            String accountId = String.valueOf(agProxy.get('AccountId'));
            if (accountTocontractMap.containsKey(accountId)) {
                String contractId = String.valueOf(accountTocontractMap.get(accountId));
                Double amount = agProxy.get('expr0') != null ? Double.valueOf(agProxy.get('expr0')) : 0;
                computeRollupSum(contractId, amount);
            }
        }
    }

    private static void isValidDate(Date qStartDate, Date qEndDate, Date oppCloseDate, Boolean isQuarterRebate) {
        if (isQuarterRebate) {
            if (qStartDate != null && qEndDate != null) {
                QuarterStartDate = qStartDate;
            } else {
                throw new RebateCalculationsException(MISSING_QUARTER_RANGE_DATE);
            }
        } else {
            if (oppCloseDate == null) {
                throw new RebateCalculationsException(MISSING_OPPORTUNITY_CLOSED_DATE);
            }
        }
    }

    private static String getOpportunityRollupQuery(List<String> fields, List<String> filters) {
        String queryFields = String.join(fields, ',');
        String query = 'SELECT ' + queryFields +', Sum(Amount) FROM Opportunity';
        if (!filters.isEmpty()) {
            query += (' WHERE ' + String.join(filters, ' AND '));
        }
        query += ' GROUP BY ' + queryFields;
        return query;
    }

    private static List<String> getQueryFilters(Boolean isQuarterRebate, Date startDate, Date endDate) {
        List<String> filters = new List<String>{
            'IsClosed = true',
            'StageName= \'Closed Won\'',
            getClosedDateFilter(isQuarterRebate, startDate, endDate),
            getAccountIdsFilter()
        };
        return filters;
    }

    private static String getClosedDateFilter(Boolean isQuarterRebate, Date startDate, Date endDate) {
        String filter;
        if (isQuarterRebate) {
            filter = 'CloseDate >=  ' + removeTimeStamp(startDate)
                  + 'CloseDate <= ' + removeTimeStamp(endDate);
        } else {
            filter = 'CloseDate = ' + removeTimeStamp(startDate);
        }
        return filter;
    }

    private static String getAccountIdsFilter() {
        String filterFormat = 'AccountId IN ({0})';
        List<String> idFilters = new List<String>{'\'\''};
        for (String accountId : accountIds) {
            idFilters.add('\'' + accountId + '\'');
        }
        return String.format(filterFormat, new List<String>{String.join(idFilters, ', ')});
    }

    private static void computeRollupSum(String key, Double amount) {
        if (!rollupSum.containsKey(key)) {
            rollupSum.put(key, 0);
        }
        rollupSum.put(key, rollupSum.get(key) + amount);
    }

    public static void caluclateRebate() {
        for (String cId1 : rollupSum.keySet()) {
            String cId = getContractId(cId1);
            if (tiers.containsKey(cId)) {
                String key = isDailyRebate ? cId1 : cId;
                Double rollupAmount = isDailyRebate ? rollupSum.get(cId1) : rollupSum.get(cId) * 4;
                setRebateTiers(rebateTiers, key, getRebateTier(rollupAmount, tiers.get(cId)));
                if (rebateTiers.get(key) == null ) {
                    setRebateTiers(rebateTiers, key, getRebateMaxTier(rollupAmount, tiers1.get(cId).get(maxAutoNumber)));
                }
            }
        }
    }

    private static String getContractId(String key) {
        String contractId = key;
        if (isDailyRebate && dailyContractIds.containsKey(key)) {
            contractId = dailyContractIds.get(key).contractId;
        }
        return contractId;
    }

    public static void evaluteNextYearSpend() {
        for (String cId : rollupSum.keySet()) {
            if (tiers.containsKey(cId)) {
                Double amount = rollupSum.get(cId);
                setRebateTiers(rebateNextYearSpend, cId, getRebateTier(amount, tiers.get(cId)));
                if (rebateNextYearSpend.isEmpty()) {
                    setRebateTiers(rebateNextYearSpend, cId, getRebateMaxTier(amount, tiers1.get(cId).get(maxTierContract.get(cId))));
                }
            }
        }
    }

    private static void setRebateTiers(Map<String, Tier> rebates, String key, Tier value) {
        if (value != null) {
            rebates.put(key, value);
        }
    }

    private static Tier getRebateTier(Double rollupAmount, List<Contract_Tier__c> tiers) {
        Tier tier;
        for (Contract_Tier__c contractTier : tiers) {
            if (rollupAmount >= contractTier.Min__c && rollupAmount <= contractTier.Max__c) {
                Double nextMin = getNextMinTier(contractTier.Auto_Number__c, contractTier.Contract__c);
                tier = new Tier(contractTier.Id, nextMin, contractTier.Rebate__c);
                break;
            }
            maxAutoNumber = contractTier.Auto_Number__c;
        }
        return tier;
    }

    private static Double getNextMinTier(String currentAutoNumber, String contractId) {
        Double result;
        Map<String, Contract_Tier__c> tiers = tiers1.get(contractId);
        for (Contract_Tier__c tier : tiers.values()) {
            if (tier.Auto_Number__c > currentAutoNumber) {
                result = tier.Min__c;
                break;
            }
        }
        return result;
    }

    private static Tier getRebateMaxTier(Double rollupAmount, Contract_Tier__c maxTier) {
        Tier tier;
        if (maxTier != null && rollupAmount > maxTier.Min__c) {
            tier = new Tier(maxTier.Id, null, maxTier.Rebate__c);
        }
        return tier;
    }

    public static void createRebate(Boolean isQuarter, String qNumber){
        for (String cId : rollupSum.keySet()) {
            rebates.add(constructRebate(cId, isQuarter, qNumber));
        }

        if (isDailyretrospective) {
            return;
        }

        try {
            service.upsertRebates(rebates);
        } catch(Exception ex) {
            throw new RebateCalculationsException(ex.getMessage());
        }
    }

    private static Rebate__c constructRebate(String cId, Boolean isQuarter, String qNumber) {
        String key = isQuarter ? cId.split(':')[0] : cId;
        List<String> identifiers = getRebateIdentifiers(key, isQuarter, qNumber);
        Rebate__c rebate = new Rebate__c(
            Name = getRebateName(isQuarter, identifiers),
            Contract__c = getRebateContractId(key, isQuarter),
            Sales__c = rollupSum.get(key),
            Rebate_Type__c = isQuarter ? 'Quarter' : 'Daily',
            Spent_to_Next_Level_Up__c = getSpentToNexLevelUp(key),
            Rebate_Unique_Id__c = getRebateUniqueId(key, isQuarter, identifiers),
            Calucated_Rebate__c = 0
        );
        if (isQuarter) {
            addRebateQuarterFields(rebate, key, qNumber);
        }
        addRebateTierFields(rebate, key);
        return rebate;
    }

    private static List<String> getRebateIdentifiers(String key, Boolean isQuarter, String qNumber) {
        List<String> identifiers;
        if (!isQuarter) {
            identifiers = getNonQuarterRebateIdentifiers(key);
        } else {
            identifiers = new List<String>{ String.valueOf(QuarterStartDate.year()), qNumber};
        }
        return identifiers;
    }

    private static List<String> getNonQuarterRebateIdentifiers(String key) {
        Date startDate;
        Date endDate;
        if (dailyContractIds.containsKey(key)) {
            YearBreakDownForRebates.YearlyBreakDown breakDown = dailyContractIds.get(key);
            startDate = breakDown.StartDate;
            endDate = breakDown.EndDate;
        } else {
            Contract contract = contractsMap.get(key);
            startDate = contract.StartDate;
            endDate = contract.EndDate;
        }
        return new List<String>{ removeTimeStamp(startDate), removeTimeStamp(endDate) };
    }

    private static String removeTimeStamp(Date value) {
        String dateValue = String.valueOf(value);
        return dateValue.remove('00:00:00').trim();
    }

    private static String getRebateName(Boolean isQuarter, List<String> identifiers) {
        String rebateNameFormat = 'Y: {0} Q: {1}';
        if (!isQuarter) {
            rebateNameFormat = 'Daily: {0} To {1}';
        }
        return String.format(rebateNameFormat, identifiers);
    }

    private static String getRebateContractId(String cId, Boolean isQuarter) {
        String contractId = cId;
        if (!isQuarter && dailyContractIds.containsKey(cId)) {
            contractId = dailyContractIds.get(cId).contractId;
        }
        return contractId;
    }

    private static void addRebateQuarterFields(Rebate__c rebate, String key, String qNumber) {
        rebate.Sales_4__c = rollupSum.get(key) * 4;
        rebate.Quarter__c = qNumber;
        rebate.Year__c = String.valueOf(QuarterStartDate.year());
    }

    private static void addRebateTierFields(Rebate__c rebate, String key) {
        Tier tier = rebateTiers.get(key);
        if (tier != null) {
            rebate.Calucated_Rebate__c = rollupSum.get(key) * tier.currentRebate/100;
            rebate.Contract_Tier__c = tier.tierId;
            rebate.Current_Rebate__c = tier.currentRebate;
        }
    }

    private static Decimal getSpentToNexLevelUp(String key) {
        Double value;
        if (rebateNextYearSpend.containsKey(key) && rebateNextYearSpend.get(key) != null) {
            Double nextMin = rebateNextYearSpend.get(key).nextMin;
            value = nextMin != null ? nextMin - rollupSum.get(key) : 0;
        }
        return value;
    }

    private static String getRebateUniqueId(String key, Boolean isQuarter, List<String> identifiers) {
        identifiers.add(key);
        if (isQuarter) {
            identifiers.set(0, String.valueOf(System.today().year()));
        }

        String uniqueIdFormat = 'Y: {0} Q: {1} {2}';
        if (!isQuarter) {
            uniqueIdFormat = 'D: {0} To {1} cId: {2}';
        }
        return String.format(uniqueIdFormat, identifiers);
    }

    public class Tier {
        String tierId;
        Double nextMin;
        Decimal currentRebate;
        public Tier(String tierId, Double nextMin, Decimal currentRebate){
            this.tierId = tierId;
            this.nextMin = nextMin;
            this.currentRebate = currentRebate;
        }
    }

    public class RebateCalculationsException extends Exception {}
}