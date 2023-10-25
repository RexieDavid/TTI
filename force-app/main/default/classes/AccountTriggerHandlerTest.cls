@isTest
private class AccountTriggerHandlerTest {
    
    @testSetup
    private static void testData() {
        Id headOfficeAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT).getRecordTypeId();
        Id headOfficeEndConsumerRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT_END_CONSUMER).getRecordTypeId();
        Id commercialRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_COMMERCIAL).getRecordTypeId();
        Id b2cPersonAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Id productInfoCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Info').getRecordTypeId();

        Project__c proj = new Project__c(BCI_Project_ID__c = 'test');
        insert proj;

        Case_Setting__c cs = new Case_Setting__c();
        cs.Default_Account_Name_Report__c = 'Manika';
        cs.Default_Contact_Name_Report__c = 'Venus Rolle';
        cs.Case_Subject_Report__c = 'JB Hi Fi Report';
        insert cs;

        Account reportAccount = new Account(Name = 'Manika', TTI_SAP_Cust_No__c = '12345', RecordTypeId = headOfficeAccountRecId, BCI_ProjectID__c = 'test', BillingCountry = 'NZ');
        insert reportAccount;

        Contact reportContact = new Contact(FirstName = 'Venus', LastName = 'Rolle', Email = 'venus.rolle@manika.com', AccountId = reportAccount.Id, MobilePhone = '042142321');
        insert reportContact;
        
        Case newCase = new Case();
        newCase.Origin = 'Phone';
        newCase.RecordTypeId = productInfoCaseRecTypeId;
        newCase.SuppliedEmail = 'joy.williams@fueledbyramen.com';
        newCase.Brand__c = 'Ryobi';
        newCase.Subject = 'JB Hi Fi Report';
        newCase.Web_State__c = 'Cavite';
        newCase.Type = 'Warranty';
        newCase.SuppliedPhone = '09123456789';
        newCase.SuppliedName = 'Williams, Joy';
        newCase.Description = 'Price';
        insert newCase;

        Case newCase2 = new Case();
        newCase2.Origin = 'Phone';
        newCase2.RecordTypeId = productInfoCaseRecTypeId;
        newCase2.SuppliedEmail = 'hayley.williams@fueledbyramen.com';
        newCase2.Brand__c = 'Ryobi';
        newCase2.Subject = 'Udu';
        newCase2.Web_State__c = 'Cavite';
        newCase2.Type = 'Warranty';
        newCase2.SuppliedPhone = '09123456789';
        newCase2.SuppliedName = 'Williams, Hayley';
        newCase2.Description = 'Test';
        newCase2.AccountID =  reportAccount.id;
        insert newCase2;
        
        Country_Codes__c cc = new Country_Codes__c();
        cc.country_ABV__c = 'NZ';
        cc.country_code__c = '+64';
        cc.country_name__c = 'New Zealand';
        cc.Name = 'Test';
        insert cc;
        
        List<Account> accList = new List<Account>();
        for (integer i = 0; i < 10; i ++) {
            if (i == 0) {
                accList.add(new Account(Name = 'BBC' + i, TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, BCI_ProjectID__c = 'test',BillingCountry = 'NZ'));
            } else if (i == 1) {
                accList.add(new Account(Name = 'acc' + i, TTI_SAP_Cust_No__c = '12345' + i, BCI_ProjectID__c = 'test', RecordTypeId = headOfficeEndConsumerRecId));
            } else if ( i == 2) {
                accList.add(new Account(Name = 'acc' + i, TTI_SAP_Cust_No__c = '12345' + i, BCI_ProjectID__c = 'test', RecordTypeId = commercialRecId));
            } else if ( i==3 ){
                accList.add(new Account(FirstName = 'Hayley', LastName = 'Williams', PersonEmail = 'hayley.williams@fueledbyramen.com', Brand__pc = 'Ryobi', RecordTypeId = b2cPersonAccountRecId, PersonMobilePhone = '042142321', Country__pc = 'NZ'));
            } else if ( i==4 ){
                accList.add(new Account(Name = 'acc' + i, Customer_Group_4_Code__c = 'Test', Customer_Group_5_Code__c = 'Test', Sales_Organisation__c = GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_BP01, TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, Type = GlobalConstantUtility.ACCOUNT_TYPE_SERVICE_AGENT, Customer_Group__c = 'Test Group'));
            } else if ( i==5 ){
                accList.add(new Account(Name = 'acc' + i, Customer_Group_4_Code__c = 'Test', Customer_Group_5_Code__c = 'Test', Sales_Organisation__c = GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_NZ01, TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, Type = GlobalConstantUtility.ACCOUNT_TYPE_RETAILER, Customer_Group__c = 'Test Group'));
            } else if ( i==6 ){
                accList.add(new Account(Name = 'acc' + i, Customer_Group_4_Code__c = 'Test', Customer_Group_5_Code__c = 'Test', TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, Type = GlobalConstantUtility.ACCOUNT_TYPE_REP_ACCOUNT, Customer_Group__c = 'Test Group'));
            } else if ( i==7 ){
                accList.add(new Account(Name = 'acc' + i, Customer_Group_4_Code__c = 'Test', Customer_Group_5_Code__c = 'Test', TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, Type = GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_END_CONSUMER));
            } else if ( i==8 ){
                accList.add(new Account(Name = 'acc' + i, Customer_Group_4_Code__c = 'Test', Customer_Group_5_Code__c = 'Test', TTI_SAP_Cust_No__c = '12345' + i, RecordTypeId = headOfficeAccountRecId, Type = GlobalConstantUtility.ACCOUNT_TYPE_INDUSTRY_ASSOCIATION));
            } else {
                accList.add(new Account(FirstName = 'Test Name', LastName = 'Test' + i, PersonEmail = 'Testing@yahoo.com', Brand__pc = 'Ryobi', RecordTypeId = b2cPersonAccountRecId));
            }
        }
        
        Database.insert(accList, false);

        Contact con = new Contact(MailingCountry = 'NZ', accountId = accList[0].Id, LastName = 'Rolle', npe01__WorkEmail__c ='venus.rolle@bbc.com', FirstName = 'Venus', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
        insert con;

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :accList[3].Id LIMIT 1];

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi'];
        
        User portalUser = new User();
        portalUser.Username = accList[3].PersonEmail + '.tst';
        portalUser.Email = accList[3].PersonEmail;
        portalUser.CommunityNickname = 'Cardo';
        portalUser.ProfileId = portalProfile.Id;
        portalUser.ContactId = personContact.Id;
        portalUser.Alias = 'Cardo123';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LastName = accList[3].LastName;
        portalUser.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';
        
        insert portalUser;
    }
    
    @isTest
    private static void testAccountWithoutCustomerGroup() {
        Account acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_INTERNAL;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal TTI Division HQ').getRecordTypeId());
        
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_INDUSTRY_ASSOCIATION;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        // System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId());
        
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_INTERNAL;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        // System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account - End-Consumer').getRecordTypeId());
    } 
    
    @isTest
    private static void testAccountWithCustomerGroup() {
        Account acc = [SELECT Id, Type, Customer_Group__c FROM Account WHERE Name = 'Hayley Williams'][0];
 		
        // Test.setMock(HttpCalloutMock.class, new Auth0_MockCalloutResponse());
        
        Marketing_Preference__c mp = new Marketing_Preference__c(Person_Account__c = acc.Id);
        insert mp;
        
        Member_Benefit_Program__c newMBP = new Member_Benefit_Program__c();
        newMBP.Name = 'test';
        insert newMBP;
                
        Eligible_Customer__c elig = new Eligible_Customer__c();
        elig.Customer__c = acc.id;
		elig.Member_Benefit_Program__c = newMBP.id;
        elig.Send_to_MC__c = false;
        insert elig;
        
        acc.PersonHasOptedOutOfEmail = true;
        acc.PersonEmail = 'testing@xhamster.com';
        acc.Send_to_MCloud__pc = true;
        update acc;
        
        acc = [SELECT Id,Type,Customer_Group__c FROM Account WHERE Name = 'acc1'];
        acc.Customer_Group__c = 'Bunnings';
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_SERVICE_AGENT;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        // System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId());
        
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_RETAILER;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId FROM Account WHERE Name = 'acc1'];
        // System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId());
        
        acc.Type = GlobalConstantUtility.ACCOUNT_TYPE_REP_ACCOUNT;
        update acc;
        
        acc = [SELECT Id, Type, RecordTypeId, PersonEmail FROM Account WHERE Name = 'acc1'];
        // System.assertEquals(acc.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Rep Account').getRecordTypeId());
        
        delete acc;
    }
}