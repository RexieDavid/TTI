@isTest
private class BatchUpdateContactAssignmentsTest {
    
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
        
        User u2 = new User(Alias = 'tbrad', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Tersting', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard2@testing.com', TTI_SAP_Cust_No__c='54321');
        insert u2;
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'Valtymore', TTI_SAP_Cust_No__c = '12345',Sales_Organisation__c ='BP01'));
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName = 'Armin', LastName = 'Abala', Email = 'armin.abala@test.com', Phone = '09154147892', MailingPostalCode = '4024', AccountId = accList[0].Id, BCI_Contact_ID__c = 'test'));
        insert conList;
      
    }
    
	private static testmethod void testBatch_Update_Contact_Assignments(){
   
        Test.startTest();
        Batch_Update_Contact_Assignments obj = new Batch_Update_Contact_Assignments();
        DataBase.executeBatch(obj);
        Test.stopTest();

    }

}