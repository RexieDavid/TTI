@isTest
public class AEGLeadAccountMatchTriggerHandlerTest {
    
    @TestSetup
    static void makeData() {
        Id b2cRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Id aegOnsiteAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AEG Onsite Account').getRecordTypeId();
        
        User user = new User();
        UserRole role;

        System.runAs(new User(Id = UserINfo.getUserId())) {
            role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert role;

            user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            user.LastName = 'Mat';
            user.Email = 'kimat-admin010191-001@yopmail.com';
            user.Username = 'kimat-admin010191-001@yopmail.com' + System.currentTimeMillis();
            user.CompanyName = 'TEST';
            user.Title = 'title';
            user.Alias = 'alias';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.EmailEncodingKey = 'UTF-8';
            user.LanguageLocaleKey = 'en_US';
            user.LocaleSidKey = 'en_US';
            user.UserRoleId = role.Id;
            insert user;
        }

        Account aegOnsiteAccount = new Account(
            RecordTypeId = aegOnsiteAcctRtId,
            Name = 'Test AEG Onsite Account'
        );
        insert aegOnsiteAccount;

        Contact contact = new Contact(
            AccountId = aegOnsiteAccount.Id,
            FirstName = 'Kim',
            LastName = 'Mat',
            Email = 'kimat010191-001@yopmail.com',
            OwnerId = user.Id
        );
        insert contact;

        // Create customer portal
        Account customerAccount = new Account(
            RecordTypeId = b2cRecordTypeId,
            FirstName = 'Kim',
            LastName = 'Mat',
            PersonEmail = 'kimat010191-001@yopmail.com',
            Brand__pc = 'AEG'
        );
        insert customerAccount;
        
        Contact customerContact = [SELECT Id FROM Contact WHERE AccountId = :customerAccount.Id LIMIT 1];

        // Contact customerContact = new Contact(
        //     FirstName = 'Test',
        //     LastName = 'Contact',
        //     AccountId = customerAccount.Id,
        //     Email = 'test@contact.com'
        // );
        // insert customerContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
        User customerUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = portalProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testPartnerUser@123455678.com',
            ContactId = customerContact.Id);        
        insert customerUser;
    }

    @IsTest
    static void testAEGLeadAccountMatch() {
        Id tradeLeadRecordtTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade Lead').getRecordTypeId();

        Lead lead = new Lead();
        lead.RecordTypeId = tradeLeadRecordtTypeId;
        lead.FirstName = 'Kim';
        lead.LastName = 'Mat';
        lead.LeadSource = 'Website (Trade Solutions)';
        lead.Trade__c = 'Agriculture/Farmer';
        lead.Description = 'Purchase AEG 24V Battery.';
        lead.Email = 'kimat010191-001@yopmail.com';

        Test.startTest();
            insert lead;
        Test.stopTest();

        User owner = [SELECT Id FROM User WHERE Email = 'kimat-admin010191-001@yopmail.com' LIMIT 1];
        Lead newLead = [SELECT Id, My_AEG_User__c, OwnerId FROM Lead WHERE Id = :lead.Id];
        
        System.assertEquals(owner.Id, newLead.OwnerId, 'Incorrect lead owner.');
        System.assert(newLead.My_AEG_User__c, 'Lead matching failed.');

    }

}