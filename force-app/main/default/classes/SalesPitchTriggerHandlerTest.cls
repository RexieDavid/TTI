@isTest
private class SalesPitchTriggerHandlerTest {
    
    @isTest
	private static void testSalesPitchInsertUpdate() {
	    Test.startTest();
	    
	    Account commercialAccount = new Account();
	    commercialAccount.Name = 'Test Commercial Account';
	    insert commercialAccount;
	    
        Commercial_Opportunity__c commercialOpportunity = new Commercial_Opportunity__c();
        commercialOpportunity.Name = 'Test Commercial Opportunity';
        commercialOpportunity.Account__c = commercialAccount.Id;
        commercialOpportunity.Status__c = 'Open';
        commercialOpportunity.Related_To__c = 'Other';
        insert commercialOpportunity;
        
        Opportunity_Product_Category__c opportunityProductCategory = new Opportunity_Product_Category__c();
        opportunityProductCategory.Name = 'Test Opportunity Product Category';
        opportunityProductCategory.Description__c = 'Test Description';
        opportunityProductCategory.Division__c = 'Consumer';
        opportunityProductCategory.Is_Active__c = true;
        insert opportunityProductCategory;
        
        Sales_Pitch__c salesPitch = new Sales_Pitch__c();
        salesPitch.Name = 'Test Sales Pitch';
        salesPitch.Commercial_Opportunity__c = commercialOpportunity.Id;
        salesPitch.Status__c = 'Open';
        salesPitch.Opportunity_Product_Category__c = opportunityProductCategory.Id;
        salesPitch.Pitch_Date__c = Date.today();
        insert salesPitch;
        
        salesPitch.Account__c = null;
        update salesPitch;
        
        Test.stopTest();
        
        salesPitch = [SELECT Id, Account__c FROM Sales_Pitch__c WHERE Id = :salesPitch.Id LIMIT 1];
        System.assertNotEquals(null, salesPitch.Account__c);
	}

}