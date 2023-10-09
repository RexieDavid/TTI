@isTest
private class TTI_Invoicepdf_controllerTest {
    
    private static Id productInfoCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    private static Id redemptionCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Redemption').getRecordTypeId();
    private static Id customerExperienceCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();
    private static Id b2cPersonAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();

    //Method to create records that will be used for Invoice PDF File parameters.
	private static testMethod void testInvoicePDF() {
	    insert new TTIPDFSettings__c(
	    	Name='Service Portal',
			Email_Queries__c='Test@Test.com',
			PaymentTerms__c='Test',
			ServicePaymentQueries__c='Test@Test.com',
			TTIABN__c='Test',
			TTIAccountName__c='Test',
			TTIRCTICity__c='Test',
			TTIRCTIPostalCode__c='Test',
			TTIRCTIState__c='Test',
			TTIRCTIStreet__c='Test'
		);    
                                           
        Case_Setting__c cs = new Case_Setting__c();
		cs.Default_Account_Name_Report__c = 'Techtronic Industries Pty Ltd';
		cs.Default_Contact_Name_Report__c = 'Andrew Grant';
		cs.Case_Subject_Report__c = 'JB Hi Fi Report';
		insert cs;

	    Account acc = new Account(Name = 'Techtronic Industries Pty Ltd', TTI_SAP_Cust_No__c = '12345', BCI_ProjectID__c = 'test', RecordTypeId = b2cPersonAccountRecTypeId, BillingCountry = 'NZ');
	    insert acc;

	    Contact con = new Contact(MailingCountry = 'NZ',accountId = acc.Id, LastName = 'Grant', FirstName = 'Andrew', HomePhone = '051234123', MobilePhone = '051231231', Phone = '051412412', OtherPhone = '051421412', Email = 'Grant@gmail.com');
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
		insert newCase;
		
		newCase = [SELECT Id, CaseNumber FROM Case WHERE SuppliedPhone = '09123456789' AND SuppliedName = 'User, Test U.'];

		Service_Request_Line_Item__c srl = new Service_Request_Line_Item__c();
		srl.Order_Line_Category__c = 'Manual Entry';
		srl.Order_Line_Type__c = 'Part';
		srl.Service_Request_Number__c = newCase.id;
		srl.Unit_Cost__c  = 20;
		srl.Quantity__c = 2;
		insert srl;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('caseId', String.valueOf(newCase.Id));
			TTI_Invoicepdf_controller controller = new TTI_Invoicepdf_controller();
		Test.stopTest();

		//TTIInvoicePDF Controller Assertion
		Case createdCase = [Select Id, TTI_GST_for_SRLI__c From Case where Id =: newCase.Id];
		Service_Request_Line_Item__c createdLineItem = [Select Id, Total_Value__c From Service_Request_Line_Item__c where Id =: srl.Id];
		Decimal totalCostwithGstTest = createdLineItem.Total_Value__c + (createdCase.TTI_GST_for_SRLI__c * 0) / 100 ;
		System.assertEquals(createdCase.Id, controller.objCase.Id, 'Case Ids did not matched');
		System.assertEquals(createdLineItem.Total_Value__c, controller.totalCost, 'TotalCost value did not matched');
		System.assertEquals(totalCostwithGstTest, controller.totalCostWithGst, 'TotalCostGST value did not matched');
		
	}
}