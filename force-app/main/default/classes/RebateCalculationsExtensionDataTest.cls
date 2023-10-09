/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 * 
 * @description                         Integration testing for 
 *                                      Service layer
 */
@isTest
private class RebateCalculationsExtensionDataTest {
    private static final RebateCalculationsExtensionDataService service = 
        new RebateCalculationsExtensionDataService();

    @TestSetup
    private static void makeData() {
        Account account = TestData.createAccounts(1)[0];
        insert account;

        Contract contract = TestData.createContracts(1, account.Id)[0];
        contract.AccountId = account.Id;
        insert contract;
    }
    
    @isTest
    private static void fetchApprovedContractTest() {
        Id approvedRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Approved').getRecordTypeId();
        Contract contract = [SELECT Id, Status, RecordTypeId FROM Contract LIMIT 1];
        contract.Status = 'Activated';
        contract.RecordTypeId = approvedRecordTypeId;
        update contract;
        Test.startTest();
            contract = service.fetchApprovedContract(contract.Id);
        Test.stopTest();
        System.assert(contract != null, 'Failed to fetch approved contract records');
    }

    @isTest
    private static void fetchNonApprovedContractTest() {
        String errMessage;
        Contract contract = [SELECT Id, Status, RecordTypeId FROM Contract LIMIT 1];
        Test.startTest();
            try {
                service.fetchApprovedContract(contract.Id);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Approved contract not found.', errMessage, 'Successfully fetch approved contract record');
    }

    @isTest
    private static void fetchApprovedContractNullIdTest() {
        String errMessage;
        Test.startTest();
            try {
                service.fetchApprovedContract(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing Contract Id', errMessage, 'Successfully fetch approved contract record');
    }

    @isTest 
    private static void fetchFiscalYearPeriodsTest() {
        Map<String, Period> periods;
        Test.startTest();
            periods = service.fetchFiscalYearPeriods();
        Test.stopTest();
        System.assert(periods != null, 'Failed to fetch fiscal periods');
    }

    @isTest 
    private static void upsertRebatesTest() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Test.startTest();
            service.upsertRebates(createRebates(contract.Id));
        Test.stopTest();
        List<Rebate__c> rebates = [SELECT Id FROM Rebate__c];
        System.assertEquals(5, rebates.size(), 'Failed to upsert rebate records');
    }

    @isTest 
    private static void upsertRebatesNullListTest() {
        String errMessage;
        Test.startTest();
            try {
                service.upsertRebates(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing Rebate Records', errMessage, 'Successfully upsert rebate records');
    }

    @isTest 
    private static void upsertRebatesMissingRequiredFieldTest() {
        String errMessage;
        Test.startTest();
            try {
                service.upsertRebates(createRebates(null));
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(Label.Generic_Error_Message, errMessage, 'Successfully upsert rebate records');
    }

    private static List<Rebate__c> createRebates(String contractId) {
        List<Rebate__c> rebates = new List<Rebate__c>();
        for (Integer i = 0; i < 5; i++) {
            rebates.add(new Rebate__c(
                Name = 'MockRebate-' + i,
                Contract__c = contractId,
                Rebate_Unique_Id__c = String.valueOf(System.now().getTime()) + i
            ));
        }
        return rebates;
    }


}