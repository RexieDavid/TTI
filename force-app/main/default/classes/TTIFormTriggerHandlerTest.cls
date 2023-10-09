@isTest
private class TTIFormTriggerHandlerTest {
    
   @testSetup static void testData() {
        
        Id demoSamppleRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Demo Sample Request').getRecordTypeId();
        Id promoStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
        Id showroomStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId();
        Id showroomStockRetRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Return').getRecordTypeId();
        Id zjssInternalRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Internal Order').getRecordTypeId();
        Id zjssRebateRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Rebate').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard@testing.com', TTI_SAP_Cust_No__c='12345', Division = 'Industrial');
        insert u;
        
        User u2 = new User(Alias = 'tbrad', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Tersting', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard2@testing.com', TTI_SAP_Cust_No__c='54321');
        insert u2;
        system.runAs(u) {
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'acc', TTI_SAP_Cust_No__c = '12345',Sales_Organisation__c ='BP01'));
        insert accList;
        TTIForm_Defaults__c cs = new TTIForm_Defaults__c();
        cs.Default_JSS_Approver__c='teststandard@testing.com';
        cs.Default_Promo_Approver__c='teststandard@testing.com';
        cs.Default_Promo_Account_Number__c='12345';
        insert cs;
        
        TTIForm_Defaults_NZ__c cs4 = new TTIForm_Defaults_NZ__c();
        cs4.Default_JSS_Approver__c='teststandard@testing.com';
        cs4.Default_Promo_Approver__c='teststandard@testing.com';
        cs4.Default_Promo_Account_Number__c='12345';
        insert cs4;
        
        TTI_Form_Delivery_Address__c cs3 = new TTI_Form_Delivery_Address__c();
        cs3.BP01_Suburb__c = 'test';
        cs3.BP01_State__c = 'test';
        cs3.BP01_Country__c = 'AU';
        cs3.BP02_Suburb__c = 'test';
        cs3.BP02_State__c = 'test';
        cs3.BP02_Country__c = 'AU';
        cs3.NZ01_Suburb__c = 'test';
        cs3.NZ01_State__c = 'test';
        cs3.NZ01_Country__c = 'NZ';
        insert cs3;
        
        Brand_Defaults__c cs2 = new Brand_Defaults__c();
        cs2.Name='ML';
        cs2.Record_Type_Name__c='Showroom Stock Request';
        cs2.SAP_Material_Group__c='ML%;PI;';
        cs2.Division__c = 'Industrial';
        cs2.Sales_Organisation__c = 'BP01';
        insert cs2;
        
        List<Contract> contractList = new List<Contract>(createContracts(2,accList[0].Id));
        
        insert contractList;
        
        List<TTI_Form__c> ttiFormList = new List<TTI_Form__c>();
        for (integer i=0; i < 10; i++) {
            if (i < 2) {
                ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = system.today(), recordTypeId = demoSamppleRecId, Contract__c = contractList[0].Id));
            }
            else if (i < 4) {
                ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = system.today(), recordTypeId = promoStockRecId, Contract__c = contractList[0].Id));
            }
            else if (i < 6) {
                ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = system.today(), recordTypeId = showroomStockRecId, Contract__c = contractList[0].Id));
            }
            else if (i < 8){
                ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = system.today(), recordTypeId = zjssRebateRecId, Approve_by__c = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com' LIMIT 1].Id , Contract__c = contractList[0].Id, Pickup_from_Wharehouse__c = true));
            }
            else{
                ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = system.today(), recordTypeId = showroomStockRetRecId, Approve_by__c = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com' LIMIT 1].Id , Contract__c = contractList[0].Id, Pickup_from_Wharehouse__c = true));
            }
        }
        
        List<Product2> prodList = new List<Product2>();
        for (integer i=0; i < 10; i++) {
            if (i < 2) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 4) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-AC', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 6) {
                prodList.add(new Product2(SAP_Material_Group__c='PI', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 8) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-SP', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
        }
        insert prodList;
        
        
        
            insert ttiFormList;
        }
        
      
    }
    
    private static testMethod void testTTIFormRecTypes() {
            
        user u = [select id from user where username = 'teststandard@testing.com'];
        u.Default_Plant__c = 'BP01';
        update u;
        system.runAs(u) {
            TTI_Form__c ttiform = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Rebate').getRecordTypeId() limit 1];
            TTI_Form__c ttiform2 = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId() limit 1];
            update ttiform2;
            update ttiform;
        }
        
        
    }
    
    private static testMethod void testTTIFormRecTypesBP02() {
            
        user u = [select id from user where username = 'teststandard@testing.com'];
        u.Default_Plant__c = 'BP02';
        update u;
        system.runAs(u) {
            TTI_Form__c ttiform = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Rebate').getRecordTypeId() limit 1];
            TTI_Form__c ttiform2 = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() limit 1];
            update ttiform;
            update ttiform2;
        }
               
    }
    
    private static testMethod void testTTIFormRecTypesNZ01() {
            
        user u = [select id from user where username = 'teststandard@testing.com'];
        u.Default_Plant__c = 'NZ01';
        update u;
        system.runAs(u) {
            TTI_Form__c ttiform = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Rebate').getRecordTypeId() limit 1];
            TTI_Form__c ttiform2 = [Select Id from TTI_Form__c where recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Return').getRecordTypeId() limit 1];
            update ttiform2;
            update ttiform;
            delete ttiform;
        }
               
    }

    private static Contact create1Contact(String accId) {
        return new Contact(FirstName = 'Deborah', LastName = 'Lopez', AccountId = accId);
    }

    private static List<Contract> createContracts(Integer numberOfContracts, String accId) {
        List<Contract> contracts = new List<Contract>();
        Contact contact = create1Contact(accId);
        insert contact;
        
        for (Integer i=0; i<numberOfContracts; i++) {
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
                                    AccountId = accId,
                                    Company_Contact__c             = UserInfo.getUserId()
                        ));
        }
        return contracts;
    }
}