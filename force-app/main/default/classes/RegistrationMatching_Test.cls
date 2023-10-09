@isTest
public class RegistrationMatching_Test {
    static testMethod void getPersonAccounts_Test() {
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
        RegistrationMatching.getPersonAccounts(a.Id, a.PersonEmail, a.FirstName, a.LastName, a.PersonMobilePhone, a.PersonHomePhone, a.Brands__c, string.valueOf(a.RecordTypeId));
    }
    static testMethod void getPersonAccounts_Test2() {
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
        RegistrationMatching.getPersonAccounts(a.Id, 'test@test.com', a.FirstName, a.LastName, a.PersonMobilePhone, a.PersonHomePhone, a.Brands__c, string.valueOf(a.RecordTypeId));
    }
    static testMethod void getPersonAccounts_Test3() {
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
        RegistrationMatching.getPersonAccounts(a.Id, 'test@test.com', a.FirstName, a.LastName, '1234455', a.PersonHomePhone, a.Brands__c, string.valueOf(a.RecordTypeId));
    }
    static testMethod void updatePersonAccount_Test() {
        //create Person Account
        Account accVar = new Account();
        accVar.RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact');
        accVar.FirstName = 'test';
        accVar.LastName = 'test1';
        accVar.PersonMailingPostalCode='12345';
        accVar.PersonMailingCity='SFO';
        accVar.PersonEmail='test@yahoo.com';
        accVar.PersonHomePhone='123456789';
        accVar.PersonMobilePhone='+619174561230';
        accVar.Brands__c = 'Ryobi';
        accVar.Country__pc = 'Australia';
        
        Account accVar2 = new Account();
        accVar2.RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact');
        accVar2.FirstName = 'test';
        accVar2.LastName = 'test1';
        accVar2.PersonMailingPostalCode='12345';
        accVar2.PersonMailingCity='SFO';
        accVar2.PersonEmail='test@yahoo.com';
        accVar2.PersonHomePhone='123456787';
        accVar2.PersonMobilePhone='+619174561231';
        accVar2.Brands__c = 'AEG';
        accVar2.Country__pc = 'Australia';
            
        Account accVar3 = new Account();
        accVar3.RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact');
        accVar3.FirstName = 'test';
        accVar3.LastName = 'test1';
        accVar3.PersonMailingPostalCode='12345';
        accVar3.PersonMailingCity='SFO';
        accVar3.PersonEmail='test@yahoo1.com';
        accVar3.PersonHomePhone='123456788';
        accVar3.PersonMobilePhone='+619174561231';
        accVar3.Brands__c = 'Ryobi';
        accVar3.Country__pc = 'Australia';
        
        Account accVar4 = new Account();
        accVar4.RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact');
        accVar4.FirstName = 'test';
        accVar4.LastName = 'test1';
        accVar4.PersonMailingPostalCode='12345';
        accVar4.PersonMailingCity='SFO';
        accVar4.PersonEmail='test@yahoo2.com';
        accVar4.PersonHomePhone='123456788';
        accVar4.PersonMobilePhone='+619174561238';
        accVar4.Brands__c = 'AEG';
        accVar4.Country__pc = 'Australia';
        
        List<Account> a = new List<Account>();
        a.add(accVar);
        a.add(accVar2);
        a.add(accVar3);
        a.add(accVar4);
        insert a;
        RegistrationMatching.updatePersonAccount(a);
    }
    //Dynamic method to get Record type id
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
}