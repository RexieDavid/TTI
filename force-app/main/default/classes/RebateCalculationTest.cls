/**
 * @Note:                           Do not change the class access type
 *                                  Public variables are reference in 
 *                                  RebateCalculationsDataServiceMock class
 */
@isTest
public class RebateCalculationTest {
    public static final List<String> ACCOUNT_IDS = generateAccountIds();
    public static final String CONTRACT_ID = DataMock.Id.generate(Contract.SObjectType);
    private static final Date CURR_DATE = Date.today();
    private static final Contract CONTRACT_RECORD = createContract();
    private static final String FOUND_CONTRACT_ACCOUNT_RECORDS = 'Have Contract Account records';
    private static final String FOUND_CONTRACT_TIER_RECORDS = 'Have Contract Tier records';
    private static final String FAILED_TO_FETCH_OPPORTUNITY_RECORDS = 'Failed to fetch Opportunity records';
    private static final String SUCCESSFULLY_FETCH_OPPORTUNITY_RECORDS = 'Successfully fetch Opportunity records';
    private static final String UNABLE_TO_COMPUTE_REBATE = 'Unable to compute rebate';
    private static final String UNABLE_TO_COMPUTE_NEXT_YEAR_SPEND = 'Unable to compute next year spend';
    private static final String FAILED_TO_CREATE_REBATE_RECORDS = 'Failed to create rebate records';

    private static RebateCalculationsDataService service = 
        (RebateCalculationsDataService) Test.createStub(RebateCalculationsDataService.class, new RebateCalculationsDataServiceMock());

    private static void prepareCollectionsTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        Test.startTest();
            RebateCalculations.prepareCollections();
        Test.stopTest();
        System.assert(!RebateCalculations.tiers.isEmpty(), 'Don\'t' + FOUND_CONTRACT_ACCOUNT_RECORDS);
        System.assert(!RebateCalculations.accountTocontractMap.isEmpty(), 'Don\'t' + FOUND_CONTRACT_TIER_RECORDS);
    }

    @isTest
    private static void prepareCollectionsNegativeTest() {
        RebateCalculations.contracts = new List<Contract>();
        Test.startTest();
            RebateCalculations.prepareCollections();
        Test.stopTest();
        System.assert(RebateCalculations.accountTocontractMap.isEmpty(), FOUND_CONTRACT_ACCOUNT_RECORDS);
        System.assert(RebateCalculations.tiers.isEmpty(), FOUND_CONTRACT_TIER_RECORDS);
    }

    @isTest
    private static void retreiveDailyOpportunityRollupTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            RebateCalculations.retreiveDailyOpportunityRollup(CURR_DATE);
        Test.stopTest();
        System.assert(!RebateCalculations.rollupSum.isEmpty(), FAILED_TO_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void retreiveDailyOpportunityRollupNegativeTest() {
        String errMessage;
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            try {
                RebateCalculations.retreiveDailyOpportunityRollup(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing Opportunity Close Date.', errMessage, SUCCESSFULLY_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void retreiveQuarterOpportunityRollupTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            RebateCalculations.retreiveOpportunityRollup(CURR_DATE - 30, CURR_DATE, null, true);
        Test.stopTest();
        System.assert(!RebateCalculations.rollupSum.isEmpty(), FAILED_TO_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void retreiveQuarterOpportunityRollupNegativeTest() {
        String errMessage;
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            try {
                RebateCalculations.retreiveOpportunityRollup(CURR_DATE - 30, null, null, true);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing Quarter Range Dates.', errMessage, SUCCESSFULLY_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void retreiveNotQuarterOpportunityRollupTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            RebateCalculations.retreiveOpportunityRollup(null, null, CURR_DATE, false);
        Test.stopTest();
        System.assert(!RebateCalculations.rollupSum.isEmpty(), FAILED_TO_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void retreiveNotQuarterOpportunityRollupNegativeTest() {
        String errMessage;
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        Test.startTest();
            try {
                RebateCalculations.retreiveOpportunityRollup(null, null, null, false);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing Opportunity Close Date.', errMessage, SUCCESSFULLY_FETCH_OPPORTUNITY_RECORDS);
    }

    @isTest
    private static void caluclateDailyRebateTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveDailyOpportunityRollup(CURR_DATE);
        Test.startTest();
            RebateCalculations.caluclateRebate();
        Test.stopTest();
        System.assert(!RebateCalculations.rebateTiers.isEmpty(), UNABLE_TO_COMPUTE_REBATE);
    }

    @isTest
    private static void caluclateQuarterlyRebateTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(CURR_DATE - 30, CURR_DATE, null, true);
        Test.startTest();
            RebateCalculations.caluclateRebate();
        Test.stopTest();
        System.assert(!RebateCalculations.rebateTiers.isEmpty(), UNABLE_TO_COMPUTE_REBATE);
    }

    @isTest
    private static void evaluteNextYearSpendForDailyRebatesTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(null, null, CURR_DATE, false);
        RebateCalculations.caluclateRebate();
        Test.startTest();
            RebateCalculations.evaluteNextYearSpend();
        Test.stopTest();
        System.assert(!RebateCalculations.rebateNextYearSpend.isEmpty(), UNABLE_TO_COMPUTE_NEXT_YEAR_SPEND);
    }

    @isTest
    private static void evaluteNextYearSpendForQuarterlyRebatesTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(CURR_DATE - 30, CURR_DATE, null, true);
        RebateCalculations.caluclateRebate();
        Test.startTest();
            RebateCalculations.evaluteNextYearSpend();
        Test.stopTest();
        System.assert(!RebateCalculations.rebateNextYearSpend.isEmpty(), UNABLE_TO_COMPUTE_NEXT_YEAR_SPEND);
    }

    @isTest
    private static void createDailyRebateTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveDailyOpportunityRollup(CURR_DATE);
        RebateCalculations.caluclateRebate();
        RebateCalculations.evaluteNextYearSpend();
        Test.startTest();
            RebateCalculations.createRebate(false, null);
        Test.stopTest();
        System.assert(!RebateCalculations.rebates.isEmpty(), FAILED_TO_CREATE_REBATE_RECORDS);
    }

    @isTest
    private static void createQuarterRebateTest() {
        RebateCalculations.service = service;
        RebateCalculations.contracts = new List<Contract>{ CONTRACT_RECORD };
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(CURR_DATE - 30, CURR_DATE, null, true);
        RebateCalculations.caluclateRebate();
        RebateCalculations.evaluteNextYearSpend();
        Test.startTest();
            Integer fiscalYearQuarter = 1;
            RebateCalculations.createRebate(true, String.valueOf(fiscalYearQuarter));
        Test.stopTest();
        System.assert(!RebateCalculations.rebates.isEmpty(), FAILED_TO_CREATE_REBATE_RECORDS);
    }

    private static List<String> generateAccountIds() {
        List<String> accountIds = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            accountIds.add(DataMock.Id.generate(Account.SObjectType));
        }
        return accountIds;
    }

    private static Contract createContract() {
        Contract contract = new Contract(
            Id = CONTRACT_ID,
            StartDate = CURR_DATE.addYears(-2),
            ContractTerm = 48,
            Status = 'Activated',
            Temp_Quarter_End_Date__c = CURR_DATE
        );
        contract = (Contract)DataMock.setFormulaField(contract, getFormulaFieldValues());
        contract = makeChildRelationships(contract);
        return contract;
    }

    private static Map<String, Object> getFormulaFieldValues() {
        return new Map<String, Object> {
            'EndDate' => CURR_DATE.addYears(2)
        };
    }

    private static Contract makeChildRelationships(Contract contract) {
        contract = makeContractAccountRelationship(contract);
        contract = makeContractTierRelationship(contract);
        return contract;
    }

    private static Contract makeContractAccountRelationship(Contract contract) {
        List<Contract_Account__c> contractAccounts = new List<Contract_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            Contract_Account__c contractAccount = new Contract_Account__c(
                Id = DataMock.Id.generate(Contract_Account__c.SObjectType),
                Contract__c = contract.Id,
                Account__c = ACCOUNT_IDS.get(i)
            );
            contractAccounts.add(contractAccount);
        }
        return makeContractRelationship(
                    contract, 
                    Contract_Account__c.Contract__c, 
                    new List<List<Contract_Account__c>> { contractAccounts });
    }

    private static Contract makeContractTierRelationship(Contract contract) {
        List<Contract_Tier__c> contractTiers = new List<Contract_Tier__c>();
        for (Integer i = 0; i < 5; i++) {
            Contract_Tier__c contractTier = new Contract_Tier__c(
                Id = DataMock.Id.generate(Contract_Tier__c.SObjectType),
                Contract__c = contract.Id,
                Level__c = String.valueOf(i),
                Min__c = 100 * i,
                Max__c = 1000 * i,
                Rebate__c = i
            );
            contractTiers.add(contractTier);
        }
        return makeContractRelationship(
                    contract, 
                    Contract_Tier__c.Contract__c, 
                    new List<List<Contract_Tier__c>> { contractTiers });
    }

    private static Contract makeContractRelationship(Contract contract, SObjectField relationshipField, List<List<SObject>> children) {
        List<Contract> contracts = (List<Contract>)
            DataMock.makeRelationship(
                List<Contract>.class, 
                new List<Contract> {contract}, 
                relationshipField, 
                children);
        return contracts[0];
    }

}