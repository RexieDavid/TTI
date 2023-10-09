@isTest
private class CatalogueProductCreateControllerTest {
    
    @testSetup static void testData() {
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
    }
	private static testMethod void testMethod1() {
	    Id headOfficeRecType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
	    Account acc = new Account(Name = 'Test1', recordTypeId = headOfficeRecType);
	    insert acc;
	    
	    Catalogue_Submission__c catSub = new Catalogue_Submission__c(Account__c = acc.Id, Catalogue_Name__c='Sample', 
                                                            	    Buy_In_End_Date__c = System.today(), 
                                                            	    Buy_In_Start_Date__c = System.today(), 
                                                            	    Advertising_Start_Date__c = system.today(), 
                                                            	    Advertising_End_Date__c = system.today()+1);
	    
	    insert catSub;
	    
	    
	    
	    Product2 product = [Select Id from Product2 where SAP_Material_Group__c = 'ML-TL' limit 1];
	    
	    PageReference pageRef = Page.CatalogueProductCreate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id', catSub.Id);
        CatalogueProductCreateController.CatalogueWrapper cmp = new CatalogueProductCreateController.CatalogueWrapper(1);
            cmp.recCount='1';
            cmp.catalogueProd.Product__c = product.Id;
            cmp.catalogueProd.Dealer_Pricing__c = 123;
        CatalogueProductCreateController controller = new CatalogueProductCreateController();
        controller.selectedRowIndex = '1';
        controller.catWrap.add(cmp);
        controller.save();
        controller.add();
        controller.addMore();
        controller.del();
        controller.cancel();
        
	}

}