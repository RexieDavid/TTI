@isTest
private class CaseTriggerHandlerTest {

	private static Id productInfoCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Info').getRecordTypeId();
    private static Id redemptionCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Redemption').getRecordTypeId();
    private static Id customerExperienceCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();
    private static Id b2cPersonAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();

	private static Id financeRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
	private static Id warehouseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId();
    
	@isTest
	private static void testPersonAccountCreationWebToCase() {
		Case_Setting__c cs = new Case_Setting__c();
		cs.Default_Account_Name_Report__c = 'Techtronic Industries Pty Ltd';
		cs.Default_Contact_Name_Report__c = 'Andrew Grant';
		cs.Case_Subject_Report__c = 'JB Hi Fi Report';
		insert cs;

	    Account acc = new Account(Name = 'Techtronic Industries Pty Ltd', TTI_SAP_Cust_No__c = '12345', BCI_ProjectID__c = 'test', RecordTypeId = b2cPersonAccountRecTypeId, BillingCountry = 'NZ');
	    insert acc;

	    Contact con = new Contact(MailingCountry = 'NZ',accountId = acc.Id, LastName = 'Grant', npe01__WorkEmail__c = 'Testing@yahoo.com0', FirstName = 'Andrew', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
	    insert con;

	    con = [SELECT Name FROM Contact WHERE Id = :con.id];

		Case newCase = new Case();
		newCase.Origin = 'Web';
		newCase.RecordTypeId = productInfoCaseRecTypeId;
		newCase.SuppliedEmail = 'user@faxtest.com';
		newCase.Brand__c = 'Ryobi';
		newCase.Subject = 'JB Hi Fi Report';
		newCase.Web_State__c = 'Laguna';
		newCase.Type = 'Warranty';
		newCase.SuppliedPhone = '09123456789';
		newCase.SuppliedName = 'User, Test U.';
		newCase.Description = 'Price';
		newCase.AccountId = acc.Id;
		insert newCase;
		
		Case newCase2 = new Case();
		newCase2.Data_Loaded__c = true;
		newCase2.Origin = 'Web';
		newCase2.RecordTypeId = redemptionCaseRecTypeId;
		newCase2.SuppliedEmail = 'user@faxtest.com';
		newCase2.Brand__c = 'Ryobi';
		newCase2.Subject = 'jb hi fi report';
		newCase2.Web_State__c = 'Laguna';
		newCase2.Type = 'Warranty';
		newCase2.SuppliedPhone = '09123456789';
		newCase2.SuppliedName = 'User, Test U.';
		newCase2.description = 'Price';
		newCase2.AccountId = acc.Id;
		insert newCase2;
		
		Case newcase3 = new Case();
		newcase3.Data_Loaded__c = true;
		newcase3.Origin = 'Email - Reports';
		newcase3.RecordTypeId = productInfoCaseRecTypeId;
		newcase3.SuppliedEmail = 'user@faxtest.com';
		newcase3.Brand__c = 'Ryobi';
		newcase3.Subject = 'jb hi fi report';
		newcase3.Web_State__c = 'Laguna';
		newcase3.Type = 'Warranty';
		newcase3.SuppliedPhone = '09123456789';
		newcase3.SuppliedName = 'User, Test U.';
		newcase3.description = 'Price';
		newcase3.AccountId = acc.Id;
		insert newcase3;
		
		update newCase;
	}

	@isTest
	private static void testSetPotentialDuplicates(){
		Case_Setting__c cs = new Case_Setting__c();
		cs.Default_Account_Name_Report__c = 'Techtronic Industries Pty Ltd';
		cs.Default_Contact_Name_Report__c = 'Andrew Grant';
		cs.Case_Subject_Report__c = 'JB Hi Fi Report';
		insert cs;

	    Account acc = new Account(Name = 'Techtronic Industries Pty Ltd', TTI_SAP_Cust_No__c = '12345', BCI_ProjectID__c = 'test', RecordTypeId = b2cPersonAccountRecTypeId, BillingCountry = 'NZ');
	    insert acc;

	    Contact con = new Contact(MailingCountry = 'NZ',accountId = acc.Id, LastName = 'Grant', npe01__WorkEmail__c = 'Testing@yahoo.com0', FirstName = 'Andrew', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
	    insert con;

		Sales_History__c shOne = new Sales_History__c(Name = 'a0J2e000000bVrK', Billing_Doc__c = '93512836');
		Sales_History__c shTwo = new Sales_History__c(Name = 'a0J2e000000bVrJ', Billing_Doc__c = '93512836');

		List<Sales_History__c> shList = new List<Sales_History__c> {shOne,shTwo};
		insert shList;

	    con = [SELECT Name FROM Contact WHERE Id = :con.id];

		Case newCase = new Case();
		newCase.Origin = 'Web';
		newCase.RecordTypeId = financeRecTypeId;
		newCase.Brands__c = 'Ryobi';
		newCase.Subject = 'JB Hi Fi Report';
		newCase.Web_State__c = 'Laguna';
		newCase.Type = 'Warranty';
		newCase.SuppliedPhone = '09123456789';
		newCase.SuppliedName = 'User, Test U.';
		newCase.Description = 'Price';
		newCase.Customer_PO_number__c = 'CRN1234';
		newCase.TTI_Invoice_Number__c = shOne.Id;
		newCase.AccountId = acc.Id;
		newCase.SAP_Order_Free_Text__c = '12345';
		insert newCase;

		Case newCaseTwo = new Case();
		newCaseTwo.Origin = 'Web';
		newCaseTwo.RecordTypeId = financeRecTypeId;
		newCaseTwo.Brands__c = 'Ryobi';
		newCaseTwo.Subject = 'JB Hi Fi Report';
		newCaseTwo.Web_State__c = 'Laguna';
		newCaseTwo.Type = 'Warranty';
		newCaseTwo.SuppliedPhone = '09123456789';
		newCaseTwo.SuppliedName = 'User, Test U.';
		newCaseTwo.Description = 'Price';
		newCaseTwo.Customer_PO_number__c = 'CRN1234';
		newCaseTwo.TTI_Invoice_Number__c = shTwo.Id;
		newCaseTwo.AccountId = acc.Id;
		newCaseTwo.SAP_Order_Free_Text__c = '12345'; 
		insert newCaseTwo;
		newCaseTwo = [SELECT Id,Potential_Duplicate_Case__c FROM Case WHERE Id =: newCaseTwo.Id];
		System.assertNotEquals(NULL, newCaseTwo.Potential_Duplicate_Case__c);

	}

	@isTest
	private static void testValidationAndPopulateChildCase(){
		Case_Setting__c cs = new Case_Setting__c();
		cs.Default_Account_Name_Report__c = 'Techtronic Industries Pty Ltd';
		cs.Default_Contact_Name_Report__c = 'Andrew Grant';
		cs.Case_Subject_Report__c = 'JB Hi Fi Report';
		insert cs;

		Account acc = new Account(Name = 'Techtronic Industries Pty Ltd', TTI_SAP_Cust_No__c = '12345', BCI_ProjectID__c = 'test', RecordTypeId = b2cPersonAccountRecTypeId, BillingCountry = 'NZ');
	    insert acc;

	    Contact con = new Contact(MailingCountry = 'NZ',accountId = acc.Id, LastName = 'Grant', npe01__WorkEmail__c = 'Testing@yahoo.com0', FirstName = 'Andrew', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412');
	    insert con;

		Case newCase = new Case();
		newCase.Origin = 'Web';
		newCase.RecordTypeId = warehouseRecTypeId;
		newCase.Brands__c = 'Ryobi';
		newCase.Subject = 'JB Hi Fi Report';
		newCase.Web_State__c = 'Laguna';
		newCase.Type = 'Warranty';
		newCase.SuppliedPhone = '09123456789';
		newCase.SuppliedName = 'User, Test U.';
		newCase.Description = 'Price';
		newCase.Customer_PO_number__c = 'CRN1234';
		// newCase.TTI_Invoice_Number__c = shOne.Id;
		newCase.AccountId = acc.Id;
		newCase.Division__c = 'Consumer';
		newCase.Courier__c = 'AFS – Mainstream';
		newCase.Courier_Con_Note_Number__c = 'CCN Note 123';
		newCase.SAP_Order_Free_Text__c = 'SAP12345';
		newCase.Customer_PO_number__c = 'CRN2131241';
		newCase.Subject = 'Parent Subject';
		newCase.Warehouse__c = 'BP01';
		insert newCase;

		Case newCaseChild = new Case();
		newCaseChild.Origin = 'Web';
		newCaseChild.RecordTypeId = warehouseRecTypeId;
		newCaseChild.Brands__c = 'Ryobi';
		newCaseChild.Subject = 'JB Hi Fi Report';
		newCaseChild.Web_State__c = 'Laguna';
		newCaseChild.Type = 'Warranty';
		newCaseChild.SuppliedPhone = '09123456789';
		newCaseChild.SuppliedName = 'User, Test U.';
		newCaseChild.Description = 'Price';
		newCaseChild.Customer_PO_number__c = 'CRN1234';
		// newCaseChild.TTI_Invoice_Number__c = shOne.Id;
		newCaseChild.AccountId = acc.Id;
		newCaseChild.ParentId = newCase.Id;
		// newCaseChild.Division__c = 'Consumer';
		// newCaseChild.Courier__c = 'AFS – Mainstream';
		// newCaseChild.Courier_Con_Note_Number__c = 'CCN Note 123';
		// newCaseChild.SAP_Order_Free_Text__c = 'SAP12345';
		// newCaseChild.Customer_PO_number__c = 'CRN2131241';
		newCaseChild.Subject = 'Child Subject';
		newCaseChild.Warehouse__c = 'BP01';

		insert newCaseChild;

		newCaseChild = [SELECT Id, Courier__c FROM Case WHERE Id =: newCaseChild.Id];
		System.assertEquals(newCaseChild.Courier__c,'AFS – Mainstream');

		Case newCaseParentValidation = new Case();
		newCaseParentValidation.Origin = 'Web';
		newCaseParentValidation.RecordTypeId = warehouseRecTypeId;
		newCaseParentValidation.Brands__c = 'Ryobi';
		newCaseParentValidation.Subject = 'JB Hi Fi Report';
		newCaseParentValidation.Web_State__c = 'Laguna';
		newCaseParentValidation.Type = 'Warranty';
		newCaseParentValidation.SuppliedPhone = '09123456789';
		newCaseParentValidation.SuppliedName = 'User, Test U.';
		newCaseParentValidation.Description = 'Price';
		newCaseParentValidation.Customer_PO_number__c = 'CRN1234';
		// newCaseParentValidation.TTI_Invoice_Number__c = shOne.Id;
		newCaseParentValidation.AccountId = null;
		newCaseParentValidation.Subject = null;

		try {
			insert newCaseParentValidation;
		} catch (Exception e) {
			System.assertEquals(e.getMessage().containsIgnoreCase('Complete this field.'), true);
		}
	}
}