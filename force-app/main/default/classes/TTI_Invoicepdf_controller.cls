public class TTI_Invoicepdf_controller {

	public Case objCase { get; set; }
	public List<Case> lstCase { get; set; }
	public List<Service_Request_Line_Item__c> lstSRL { get; set; }
	public String strCaseId { get; set; }
	public Decimal totalCost { get; set; }
	public Decimal totalCostWithGst { get; set; }
	public Account invoiceToAccount { get; set; }
	public Contact invoiceToAccountContact { get; set; }
	public TTIPDFSettings__c ttiSettings {get;set;}

	public TTI_Invoicepdf_controller() {
		lstCase = new List<Case>();
		invoiceToAccount = [SELECT Id, Name, ABC_ACN__c, Delivery_Country__c, Delivery_Street__c, Delivery_Postcode__c, Delivery_Suburb__c, Phone, (SELECT Id, Name, Email, Phone FROM Contacts WHERE Phone != null AND Email != null) FROM Account WHERE Name LIKE 'Techtronic Industries Pty Ltd%' LIMIT 1];
		if (!invoiceToAccount.Contacts.isEmpty()) {
			invoiceToAccountContact = invoiceToAccount.Contacts[0];
		} else {
			invoiceToAccountContact = new Contact();
		}
		
		ttiSettings = TTIPDFSettings__c.getValues('Service Portal');
		strCaseId = ApexPages.currentPage().getParameters().get('caseId');
		
		lstCase = [SELECT Id, CaseNumber, Status, Paid_Sundry_Amount__c, TTI_BaseChargeCalculation__c, TTI_InvoiceAndLessAmountTotal__c, TTI_GSTTotalCalculation__c, Sundry_Expense_Reason__c, Repair_Type__c, 
						  TTI_BonusCalculation__c, Retailer_Account__c, TTI_Service_Agent_Comments__c, Total_Sundry_Expenses__c, Invoice_Approved_Date__c, Retailer_Account__r.Name, Claim_Type__c, 
						  Invoice_Number_PC__c, TTI_Customer_Account__r.Name, TTI_Customer_Contact__c, Service_Agent__r.Name, 
						  SuppliedEmail, Brand__c, Product_Name__c, Purchase_Date__c, Fault_Description__c, TTI_Freight_In_Required__c, CreatedDate, TTI_Customer_Account__r.PersonMobilePhone,  
						  TTI_Freight_Out_Required__c, Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c, Retailer_Account__r.Delivery_Postcode__c, 
						  TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Country__c, 
						  TTI_Freight_In_PickUp_Address__c, TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_Postcode__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Country__c, 
						  Retailer_Account__r.Delivery_State__c, Retailer_Account__r.Delivery_Country__c, Service_Agent__r.Delivery_State__c, Service_Agent__r.Delivery_Country__c, Service_Agent__r.Delivery_Street__c, 
						  Service_Agent__r.Delivery_Suburb__c, TTI_Service_Agent_Job_Number__c, Total_Invoice_Amount__c, TTI_GST_for_SRLI__c, Asset.Name, TTI_CaseFromEmailId__c, TTI_Email_Notification_Opt_In__c, 
						  Service_Agent__r.Delivery_Postcode__c, Serial_Number__c, Product_Name__r.Name, TTI_Brand_Logo_URL__c, Account.ABC_ACN__c, Service_Agent__r.ABC_ACN__c, 
						  Account.Delivery_State__c, Account.Delivery_Country__c, Account.Delivery_Street__c, Account.Delivery_Postcode__c, Account.Delivery_Suburb__c, Account.Name, Account.Phone,
						  Service_Agent__r.BillingCity, Service_Agent__r.BillingPostalCode, Service_Agent__r.BillingState, Service_Agent__r.BillingStreet, Repair_case_Reference__c

						  , Base_GST_Payable_AUD__c, Base_GST_Payable_NZD__c, Bonus_GST_Payable_AUD__c, Bonus_GST_Payable_NZD__c, Sundry_Expense_GST_Payable__c
				   FROM Case 
				   WHERE Id = :strCaseId];
		
		if (lstCase != null && !lstCase.isEmpty()) {
			objCase = lstCase[0];
		}
		
		lstSRL = [SELECT Quantity__c, Line_Item_Description__c, Unit_Cost__c, Total_Value__c, Service_Request_Number__c 
				  FROM Service_Request_Line_Item__c 
				  WHERE Service_Request_Number__c = :objCase.Id];
					
		totalCost = 0;
		totalCostWithGst = 0;

		for (Service_Request_Line_Item__c srl : lstSRL ) {
			if (srl.Total_Value__c != null) {
				totalCost = totalCost + srl.Total_Value__c;
			}
		}

		totalCostWithGst = totalCost + (objCase.TTI_GST_for_SRLI__c * totalCostWithGst) / 100;
	}
	
}