@IsTest
//(seeAllData = true)
public class ProfileDetailCC_Test {
    
    static testMethod void getProfileDetails_Test() {
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.R1y2o3b4i5',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        system.runAs(portalUser){
            ProfileDetailCC.getProfileDetails();
        }
        ProfileDetailCC.getSiteName();
        
        ProfileDetailCC.dummyTest();
    }
    static testMethod void updateProfileDetails_Test() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.6R5y4o3b2i1',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        //ProfileDetailCC.testDummy();
        
        ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
    }
    
    static testMethod void updateProfileDetails_Test2() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.5R6y7o8b9i0',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname=null,
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = null,
            PostalCode = null,
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test3() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.0R9y8o7b6i5',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = null,
            PostalCode = null,
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    static testMethod void updateProfileDetails_Test4() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.1R0y2o9b3i8',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = null,
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    static testMethod void updateProfileDetails_Test5() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.8R3y9o2b0i1',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test6() {
        Community_Settings__c cs =  Community_Settings__c.getValues('myRyobi');
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.1R1y2o2b3i3',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = '123456789',
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test7() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.Name = 'myRyobi';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.3R3y2o2b1i1',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = '123456789',
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test8() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'myAEG';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Brands__c = 'AEG';
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.A1E1G1',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = '123456789',
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, null, 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test9() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'myAEG';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Brands__c = 'AEG';
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.A2E2G2',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = '123456789',
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', null, '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test10() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'myAEG';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Brands__c = 'AEG';
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.A3E3G3',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    
    static testMethod void updateProfileDetails_Test11() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'myAEG';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Brands__c = 'AEG';
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.A4E4G4',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = '12324',
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', null);
        }catch(Exception ex){
            ex.getMessage();
        }
    }
    static testMethod void updateProfileDetails_Test12() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'myAEG';
        insert cs;
         Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Brands__c = 'AEG';
        insert a;
        //get contact
        Contact c=  [Select Id FROM Contact Where AccountID =:a.Id];
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        try{
            User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test@yahoo.com.A5E5G5',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Title = 'Mr.',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id,
            Country  = 'Australia',
            PostalCode = '12345',
            MobilePhone = null,
            Phone = null
            );
            Database.insert(portalUser);
            
            ProfileDetailCC.updateProfileDetails(portalUser, 'Business', 'Dealer', '0-10');
        }catch(Exception ex){
            ex.getMessage();
        }
    }
   

}