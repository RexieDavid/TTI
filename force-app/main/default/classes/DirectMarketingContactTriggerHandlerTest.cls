@isTest
private class DirectMarketingContactTriggerHandlerTest {

	private static Id commercialAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
	private static Id industrialRetailPreferencesDirectMarketingContactRecTypeId = Schema.SObjectType.Marketing_Preference__c.getRecordTypeInfosByName().get('Industrial Retail Preferences').getRecordTypeId();
	
	@isTest
	private static void test_method_one() {
		Test.startTest();

		Account commercialAccount = new Account(Name = 'Destination XYZ', TTI_SAP_Cust_No__c = '02231994', RecordTypeId = commercialAccountRecId, BCI_ProjectID__c = 'Potakte');
        insert commercialAccount;

        Contact cont = new Contact(MailingCountry = 'NZ', AccountId = commercialAccount.Id, LastName = 'Rolle', Email ='venus.rolle@bbc.com', FirstName = 'Venus', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
        insert cont;

        Direct_Marketing_Contact__c dmc = new Direct_Marketing_Contact__c();
        dmc.Account__c = commercialAccount.Id;
        dmc.Contact__c = cont.Id;
        insert dmc;

        Test.stopTest();
	}

	@isTest
	private static void test_method_two() {
		Test.startTest();

		Account commercialAccount = new Account(Name = 'Destination XYZ', TTI_SAP_Cust_No__c = '02231994', RecordTypeId = commercialAccountRecId, BCI_ProjectID__c = 'Potakte');
        insert commercialAccount;

        Contact cont = new Contact(MailingCountry = 'NZ', AccountId = commercialAccount.Id, LastName = 'Rolle', Email ='venus.rolle@bbc.com', FirstName = 'Venus', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
        insert cont;

        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        marketingPreference.General_Communication__c = true;
		marketingPreference.Monthly_Communication__c = true;
		marketingPreference.Image_Relay__c = false;
		marketingPreference.Press_Release__c = true;
		marketingPreference.Product_Launch_2_WEEK__c = false;
		marketingPreference.Product_Launch_4_WEEK__c = false;
		marketingPreference.Contact__c = cont.Id;
		marketingPreference.RecordTypeId = industrialRetailPreferencesDirectMarketingContactRecTypeId;
		insert marketingPreference;

        Direct_Marketing_Contact__c dmc = new Direct_Marketing_Contact__c();
        dmc.Account__c = commercialAccount.Id;
        dmc.Contact__c = cont.Id;
        insert dmc;

        Test.stopTest();
	}

}