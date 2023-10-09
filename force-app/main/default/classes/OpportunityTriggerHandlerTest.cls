/**
* @author: Stephen James Laylo
* @date: Apr 2017
* @description: This class handles all test methods operations for the
* Opportunity TriggerHandler.
*/
@isTest
private class OpportunityTriggerHandlerTest {

	private static final Id CONTRACT_RECORD_TYPE_APPROVED_ID = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_CONTRACT_APPROVED).getRecordTypeId();
	
    @testSetup static void testData() {

        Pricebook2 pb = new Pricebook2(Name='Consumer', isActive = true);
        insert pb;

        List<Product2> prodList = new List<Product2>();
        for (integer i=0; i < 10; i++) {
            if (i < 2) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 4) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-AC', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 6) {
                prodList.add(new Product2(SAP_Material_Group__c='PI', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            }
            else if (i < 8) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-SP', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i, SAP_Product_Heirarchy__c = 'ML'));
            }
        }

        insert prodList;

        PriceBookEntry pbe = new PriceBookEntry(Product2Id = prodList[1].Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2, UseStandardPrice = false, isActive = true);
        insert pbe;

        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Opportunity oppty = new Opportunity(Name = 'Test Opportunity', AccountId = acct.Id, StageName = GlobalConstantUtility.OPPORTUNITY_STAGENAME_PROSPECTING, CloseDate = System.today());
        insert oppty;

        Contract contr = new Contract(StartDate = System.today(), AccountId = acct.Id, Status = GlobalConstantUtility.CONTRACT_STATUS_DRAFT, ContractTerm = 6, Temp_Quarter_End_Date__c = System.today() + 2, RecordTypeId = CONTRACT_RECORD_TYPE_APPROVED_ID);
        insert contr;

        Contract_Account__c contractAccount = new Contract_Account__c(Contract__c = contr.Id, Account__c = acct.Id);
        insert contractAccount;

        Contract_Tier__c contractTier = new Contract_Tier__c(Contract__c = contr.Id, Max__c = 45, Min__c = 12, Rebate__c = 75);
        insert contractTier;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'New Bitmap Image.bmp';
        cv.VersionData = Blob.valueof('New Bitmap Image.bmp');
        cv.PathOnClient = 'New Bitmap Image.bmp';
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVErsion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = oppty.Id;
        cdl.ShareType = 'I';
        insert cdl;

        ContentDocumentTriggerHandler.testDummy();
        ContentVersionTriggerHandler.testDummy();
    }

	@isTest
	private static void testOpportunityCRUD() {

	    Test.startTest();

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Prod1' LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry LIMIT 1];

        OpportunityLineItem oppProd = new OpportunityLineItem(PriceBookEntryId = pbe.Id, OpportunityId = oppty.Id, UnitPrice = 12, Quantity = 1, Product2Id = product.Id, Dealer_Price_incGST__c = 2);
    	insert oppProd;

        oppty.Name = 'Updated Test Opportunity';
        oppty.StageName = GlobalConstantUtility.OPPORTUNITY_STAGENAME_CLOSED_WON;
    	update oppty;

    	Test.stopTest();

    	delete oppty;

	}

	
}