/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
public class RebateCalculationsExtensionDataService {
    private final String MISSING_CONTRACT_ID = 'Missing Contract Id';
    private final String MISSING_REBATE_RECORDS = 'Missing Rebate Records';
    private final String APPROVED_CONTRACT_NOT_FOUND = 'Approved contract not found.';

    public Contract fetchApprovedContract(Id contractId) {
        if (contractId == null) {
            throw new RebateCalculationsExtensionDataServiceException(this.MISSING_CONTRACT_ID);
        }

        String approvedRecordTypeId = TTIUtilClass.getRecordTypeId('Contract', 'Approved').get('Approved');
        List<Contract> contracts = [SELECT Id, 
                                           StartDate,
                                           EndDate,
                                           ContractTerm,
                                           Status,
                                           Temp_Quarter_End_Date__c,
                                           (SELECT Id,
                                                   Account__c 
                                           FROM Contract_Accounts__r),
                                           (SELECT Id, 
                                                   Contract__c, 
                                                   Max__c, 
                                                   Min__c, 
                                                   Auto_Number__c, 
                                                   Rebate__c 
                                            FROM Contract_Tiers__r 
                                            ORDER BY Auto_Number__c)
                                    FROM Contract
                                    WHERE Id = :contractId
                                    AND RecordTypeId = :approvedRecordTypeId];
        
        if (contracts.isEmpty()) {
            throw new RebateCalculationsExtensionDataServiceException(this.APPROVED_CONTRACT_NOT_FOUND);
        }
        return contracts[0];
    }

    public Map<String, Period> fetchFiscalYearPeriods() {
        return TTIUtilClass.periods;
    }

    public void upsertRebates(List<Rebate__c> rebates) {
        if (rebates == null) {
            throw new RebateCalculationsExtensionDataServiceException(this.MISSING_REBATE_RECORDS);
        }

        List<Database.UpsertResult> result = Database.upsert(rebates, Rebate__c.Fields.Rebate_Unique_Id__c, false);
        for (Database.UpsertResult sr : result) {
            if (!sr.isSuccess()) {
                /**
                 * TODO: Implementation of sentry.io
                 * 
                 * For now, it will throw a generic error in the UI
                 */
                throw new RebateCalculationsExtensionDataServiceException(Label.Generic_Error_Message);
            }
        }
    }

    public class RebateCalculationsExtensionDataServiceException extends Exception {}
}