@isTest
private class Test_BatchUpdateJSSBudgetTotals {
    
    @testSetup static void testData(){
        
        Id demoSamppleRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Demo Sample Request').getRecordTypeId();
        Id promoStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
        Id showroomStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId();
        Id zjssInternalRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Internal Order').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard@testing.com', TTI_SAP_Cust_No__c='12345', Division = 'Industrial');
        insert u;
        
        UserRole ur = new UserRole(DeveloperName = 'indjss', Name = 'Ind-jss');
        insert ur;
        
        User u2 = new User(Alias = 'tbrad', userRoleId = ur.Id, Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Tersting', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard2@testing.com', TTI_SAP_Cust_No__c='54321');
        insert u2;
        
       
        
        Sales_History__c sh = new Sales_History__c(Name = 'Test', Customer_Group_2_Code__c = 'testcode', Posting_Date__c = system.today()-1);
        system.runAs(u2){
        insert sh;
        }
        
      
    }

    static testMethod void testBatchUpdate() {
        
        user u = [select id from user where username = 'teststandard@testing.com'];
        
        Test.startTest();
        system.runAs(u){
            Account acc = new Account(Name = 'acc', TTI_SAP_Cust_No__c = '12345',Sales_Organisation__c ='BP01', BillingState = 'testcode');
            insert acc;
            
            Event e = new Event(Subject = 'Testing Subject', DurationInMinutes = 34, WhatId = acc.Id, ActivityDateTime = system.today(), Order_Confirmed_Date__c = system.today(), recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Sales RunSheet JSS').getRecordTypeId());
        
            insert e;
        
        }
        
        Batch_UpdateJSSBudgetTotals obj = new Batch_UpdateJSSBudgetTotals();
        DataBase.executeBatch(obj);
        
        Test.stopTest();

    }
}