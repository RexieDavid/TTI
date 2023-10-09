/**
 * @author                              Kristopher Veraces
 * @date                                2020-08-27
 */
@isTest
public class RebateCalculationsExtensionDataMock implements System.StubProvider {
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) { 

        switch on stubbedMethodName { 
            when 'fetchApprovedContract' {
                return this.createContract();
            }
            when 'fetchFiscalYearPeriods' {
                return this.createPeriods();
            }
            when 'upsertRebates' {
                List<Rebate__c> rebates = (List<Rebate__c>) listOfArgs.get(0);
                return this.addRebateIds(rebates);
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    public Contract createContract() {
        Date currDate = Date.today();
        Contract mockContract = new Contract();
        mockContract.Id = DataMock.Id.generate(Contract.SObjectType);
        mockContract.StartDate = currDate.addYears(-2);
        mockContract.ContractTerm = 48;
        mockContract.Status = 'Activated';
        mockContract.Temp_Quarter_End_Date__c = currDate;
        mockContract = this.makeChildRelationships(mockContract);
        return mockContract;
    }

    private Contract makeChildRelationships(Contract contract) {
        contract = this.makeContractAccountRelationship(contract);
        contract = this.makeContractTierRelationship(contract);
        return contract;
    }

    private Contract makeContractAccountRelationship(Contract contract) {
        List<Contract_Account__c> contractAccounts = new List<Contract_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            Contract_Account__c contractAccount = new Contract_Account__c(
                Id = DataMock.Id.generate(Contract_Account__c.SObjectType),
                Contract__c = contract.Id,
                Account__c = DataMock.Id.generate(Contract_Account__c.SObjectType)
            );
            contractAccounts.add(contractAccount);
        }
        return this.makeContractRelationship(
                    contract, 
                    Contract_Account__c.Contract__c, 
                    new List<List<Contract_Account__c>> { contractAccounts });
    }

    private Contract makeContractTierRelationship(Contract contract) {
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
        return this.makeContractRelationship(
                    contract, 
                    Contract_Tier__c.Contract__c, 
                    new List<List<Contract_Tier__c>> { contractTiers });
    }

    private Contract makeContractRelationship(Contract contract, SObjectField relationshipField, List<List<SObject>> children) {
        List<Contract> contracts = (List<Contract>)
            DataMock.makeRelationship(
                List<Contract>.class, 
                new List<Contract> {contract}, 
                relationshipField, 
                children);
        return contracts[0];
    }

    private Map<String, Period> createPeriods() {
        Date periodDate =  Date.newInstance(2020, 1, 1);
        Map<String, Period> periods = new Map<String, Period>();
        for (Integer i = 0; i < 12; i++) {
            periodDate.addMonths(i);
            String key = i != 11 ? 'Y: ' + 2020 + 'Q: ' + i : 'Current';
            periods.put(key, this.createPeriod(periodDate, i));
        }
        return periods;
    }

    private Period createPeriod(Date periodDate, Integer quarterNumber) {
        Integer endDays = 27; //February has only 28 days
        return new Period(
                StartDate = periodDate,
                EndDate = periodDate.addDays(endDays),
                Number = quarterNumber);
    }

    private List<Rebate__c> addRebateIds(List<Rebate__c> rebates) {
        List<Rebate__c> rebatesWithId = new List<Rebate__c>();
        for (Rebate__c rebate : rebates) {
            rebate.Id = DataMock.Id.generate(Rebate__c.SObjectType);
            rebatesWithId.add(rebate);
        }
        return rebatesWithId;
    }
}