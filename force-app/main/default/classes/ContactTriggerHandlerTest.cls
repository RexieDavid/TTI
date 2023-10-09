@isTest
private class ContactTriggerHandlerTest {
    
    @testSetup
    private static void testData() {
        Id headOfficeAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
        Id commercialRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Account> accList = new List<Account>();
        for (integer i = 0; i < 10; i ++) {
            if (Math.mod(i, 2) == 0) {
                accList.add(new Account(Name = 'acc' + i, TTI_SAP_Cust_No__c = '12345' + i, BCI_ProjectID__c = 'test', RecordTypeId = commercialRecId, Delivery_Country__c = 'New Zealand'));
            } else if (Math.mod(i, 3) == 0) {
                accList.add(new Account(Name = 'acc' + i, TTI_SAP_Cust_No__c = '12345' + i, BCI_ProjectID__c = 'test', RecordTypeId = headOfficeAccountRecId, BillingCountry = 'NZ', Delivery_Country__c = 'New Zealand'));
            } else {
                accList.add(new Account(Name = 'acc' + i, TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, BCI_ProjectID__c = 'test', Delivery_Country__c = 'New Zealand'));
            }
        }
        insert accList;
        
        
        for (integer i = 0; i < 10; i ++) {
            caseList.add(new Case(Subject = 'Test', SuppliedEmail = 'Testing@yahoo.com' + i, AccountId = accList[0].Id));
        }
        insert caseList;
        
        Country_Codes__c cc = new Country_Codes__c();
        cc.country_ABV__c = 'NZ';
        cc.country_code__c = '+64';
        cc.country_name__c = 'New Zealand';
        cc.Name = 'Test';
        insert cc;
        
    }
    
    @isTest
    private static void testAccountWithoutCustomerGroup() {
        List<Contact> nContactsList = new List<Contact>();
        Account acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];

        for(Integer i = 0; i < 10; i++) {
            Contact nCont = new Contact(MailingCountry='NZ', 
                                        AccountId = acc.Id, 
                                        LastName = 'Test' + i, 
                                        FirstName = 'Tererome' + i, 
                                        HomePhone = '051234123' + i, 
                                        MobilePhone = '051231231' + i, 
                                        Phone = '051412412' + i, 
                                        OtherPhone = '051421412' + i);
            
            if (Math.mod(i, 2) == 0) {
                nCont.Email = 'Testing@yahoo.com' + i;
            } else if (Math.mod(i, 3) == 0) {
                nCont.npe01__AlternateEmail__c = 'Testing@yahoo.com' + i;
            } else {
                nCont.npe01__WorkEmail__c = 'Testing@yahoo.com' + i;
            }
            nContactsList.add(nCont);
        }

        Test.startTest();
            // Do an insert
            insert nContactsList;
            // Do an empty update - no idea why
            update nContactsList;
        Test.stopTest();
        List<Contact> eContact = [SELECT Id FROM Contact];
        System.assertEquals(10, eContact.size(), 'Did not create contact records');
    } 
}