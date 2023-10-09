/**
* @author        Haider Raza
* @date          14/04/2016
* @description  Prepare the date for the test classes
**/

public with sharing class TestData {
    public static List<Account> createAccounts(Integer numberOfAccounts) {
        List<Account> accs = new List<Account>();

        for (Integer i = 0; i < numberOfAccounts; i ++) {
            accs.add(new Account(Name = 'Test' + i));
        }

        return accs;
    }

    public static Contact create1Contact(String accId) {
        return new Contact(FirstName = 'Tyler', LastName = 'Carter', AccountId = accId, Email = 'tyler.carter@test.com.au');
    }
    
    
  public static List<Contract> createContracts(Integer numberOfContracts, String accId) {
        List<Contract> contracts = new List<Contract>();
        Contact contact = create1Contact(accId);
        insert contact;

        for (Integer i = 0; i<numberOfContracts; i++) {
            contracts.add(new Contract(
                                    Status                         = 'Draft',                                  
                                    StartDate                      = Date.today().addyears(-1),
                                    ContractTerm                   = 36,
                                    BillingPostalCode              = '3000',
                                    BillingCity                    = 'Melbourne',
                                    BillingCountry                 = 'Australia',
                                    BillingStreet                  = '1 Bourke Street',
                                    BillingState                   = 'Victoria',
                                    Customer_Director_Secretary__c = contact.Id,
                                    Company_Contact__c             = UserInfo.getUserId()
            ));
        }
        return contracts;
    }

    public static Map<Integer, List<Contract_Tier__c>> createContractTiers(Integer numberOf3TiersPerContract) {
        Map<Integer, List<Contract_Tier__c>> tiers = new Map<Integer, List<Contract_Tier__c>>();

        for (Integer i = 0; i < numberOf3TiersPerContract; i ++) {
            List<Contract_Tier__c> t = new List<Contract_Tier__c>();
            Integer level = 1, min = 1, max = 10, rebate = 1;
            for (Integer j = 0; j<3; j ++) {
                t.add(new Contract_Tier__c( Level__c  = String.valueOf(level),
                                            Min__c    = min,
                                            Max__c    = max,
                                            Rebate__c = rebate));
                min = max + 1;

                if (j == 2) {
                    max = null;
                } else {
                    max = max+1;
                }

                rebate +=  rebate;
            }
            tiers.put(i, t);
        }
        return tiers;
    }
    
    public static Opportunity create1Opportunities(String OppName) {
        return new Opportunity(
                            Name                 = OppName,                            
                            StageName            = 'Closed Won',
                            Close_Reason__c      = 'Won – Price',
                            Amount               = 100,
                            ForecastCategoryName = 'Closed'
        );
    }

    public static Contract_Account__c createContractAccount(String accId, String conId) {
        return new Contract_Account__c(Account__c = accId, Contract__c = conId);
    }

    public static Product2 create1Product() {
        return new Product2(Name = 'TestProduct', AU_ListPrice__c = 0, SAP_Material_Group__c = 'ML-TL', SAP_Product_Heirarchy__c = 'ML-PT-12L');
    }

    public static TTI_Form_Product__c createTTIFormProduct(String productId, String ttiFormId) {
        return new TTI_Form_Product__c(SAP_Material_Number__c = productId, Quantity__c = 5, Form_Number__c = ttiFormId, Product_Type__c = '1');
    }

    public static TTI_Form__c createTTIForm(String contractId) {
        String recId = TTIUtilClass.getRecordTypeId('TTI_Form__c', 'ZJSS Rebate').get('ZJSS Rebate');
        String frmownerId = [SELECT Id FROM User WHERE IsActive = TRUE AND TTI_SAP_Cust_No__c != null LIMIT 1].Id;

        return new TTI_Form__c(Contract__c = contractId, RecordTypeId = recId, OwnerId = frmownerId, Provide_Details__c = 'Test Details');
    }

    private static Integer s_num = 1;

    public static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num ++);

        return sot.getDescribe().getKeyPrefix()+'0'.repeat(12 - result.length()) + result;
    }

    public static M12_Inventory__c createM12Inventory(String prodId) {
        return new M12_Inventory__c(Is_Active__c = true, Required_Quantity__c = 5, M12_Hub_Price_per_unit__c = 100, Product__c = prodId);
    }
}