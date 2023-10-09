@isTest
private class CompetitorCreateControllerTest {
    
    @isTest
	private static void testAddDelCompetitors() {
	    Test.startTest();
	    
	    Account commercialAccount = new Account();
	    commercialAccount.Name = 'Test Commercial Account';
	    insert commercialAccount;
	    
        Commercial_Opportunity__c commercialOpportunity = new Commercial_Opportunity__c();
        commercialOpportunity.Name = 'Test Commercial Oppty';
        commercialOpportunity.Account__c = commercialAccount.Id;
        commercialOpportunity.Status__c = 'Open';
        commercialOpportunity.Related_To__c = 'Other';
        insert commercialOpportunity;
        
        Opportunity_Product_Category__c opportunityProductCategory = new Opportunity_Product_Category__c();
        opportunityProductCategory.Name = 'Test Oppty Product Category';
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

        Competitor_Brand__c parentBrand = new Competitor_Brand__c();
        parentBrand.Name = 'TTI';
        insert parentBrand;

        Competitor_Brand__c brand = new Competitor_Brand__c();
        brand.Name = 'Ryobi';
        brand.Parent_Brand__c = parentBrand.Id;
        insert brand;
        
        PageReference pageRef = Page.CompetitorCreate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('retUrl', 'www.google.com.ph');
        ApexPages.currentPage().getParameters().put('salesPitchId', salesPitch.Id);
        
        CompetitorCreateController controller = new CompetitorCreateController();
        
        controller.save();
        
        controller.add();
        controller.add();
        controller.add();
        controller.add();
        controller.add();
        
        controller.selectedRowIndex = controller.competitors.size() + '';
        
        for (Competitor__c competitor : controller.competitors) {
            competitor.Sub_Brand__c = brand.Id;
            competitor.Estimated_Value__c = 70;
            competitor.Sales_Pitch__c = salesPitch.Id;
            competitor.SKU_Count__c = 89;
            competitor.Primary_Supplier__c = false;
            competitor.Comment__c = 'Test Comment';
        }
        
        controller.del();
        controller.save();
        controller.cancel();
        
        ApexPages.currentPage().getParameters().put('retUrl', null);
        
        controller = new CompetitorCreateController();
        
        controller.selectedRowIndex = '1';
        
        for (Competitor__c competitor : controller.competitors) {
            competitor.Sub_Brand__c = brand.Id;
            competitor.Estimated_Value__c = 705;
            competitor.SKU_Count__c = 23;
            competitor.Primary_Supplier__c = false;
            competitor.Comment__c = 'Test Comment';
        }
        
        controller.del();
        controller.save();
        
        Test.stopTest();
        
        
	}

}