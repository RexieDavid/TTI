@isTest
private class ValueAddedProductCreateControllerTest {
    
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
        
        Catalogue_Submission__c catSub2 = new Catalogue_Submission__c(Account__c = acc.Id, Catalogue_Name__c='Sample1', 
                                                                    Buy_In_End_Date__c = System.today(), 
                                                                    Buy_In_Start_Date__c = System.today(), 
                                                                    Advertising_Start_Date__c = system.today(), 
                                                                    Advertising_End_Date__c = system.today()+1);
        
        insert catSub2;
        
        Product2 product = [Select Id from Product2 where SAP_Material_Group__c = 'ML-TL' limit 1];
        Product2 prod2 = [Select Id from Product2 where SAP_Material_Group__c = 'ML-SP' limit 1];
        Catalogue_Product__c catProd = new Catalogue_Product__c(Product__c = product.Id, Dealer_Pricing__c = 123, Catalogue__c = catSub.Id);
        insert catProd;
        
        Catalogue_Product__c catProd2 = new Catalogue_Product__c(Product__c = product.Id, Dealer_Pricing__c = 123, Catalogue__c = catSub2.Id);
        insert catProd2;
        
        Loyalty_Added_Product__c vaProd = new Loyalty_Added_Product__c(Catalogue_Product__c = catProd2.Id, Bonus_Product__c = product.Id, Catalogue_Submission__c = catSub2.Id);
        insert vaProd;
        PageReference pageRef = Page.ValueAddedProductCreate;
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('Id', catSub.Id);
        
        ValueAddedProductCreateController.productWrapper cmp = new ValueAddedProductCreateController.productWrapper(catProd);
            cmp.prod=catProd;
            cmp.bonusProd.Bonus_Product__c = prod2.Id;
            
        ValueAddedProductCreateController controller = new ValueAddedProductCreateController();
        controller.prodWrap.add(cmp);
        controller.cancel();
        controller.test();
        controller.redirectMethod();
        controller.setQuantityMethod();
    }

    private static testMethod void testMethod2() {
        Id headOfficeRecType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
        Account acc = new Account(Name = 'Test1', recordTypeId = headOfficeRecType);
        insert acc;
        
        Catalogue_Submission__c catSub = new Catalogue_Submission__c(Account__c = acc.Id, Catalogue_Name__c='Sample', 
                                                                    Buy_In_End_Date__c = System.today(), 
                                                                    Buy_In_Start_Date__c = System.today(), 
                                                                    Advertising_Start_Date__c = system.today(), 
                                                                    Advertising_End_Date__c = system.today()+1);
        
        insert catSub;
        
        Catalogue_Submission__c catSub2 = new Catalogue_Submission__c(Account__c = acc.Id, Catalogue_Name__c='Sample1', 
                                                                    Buy_In_End_Date__c = System.today(), 
                                                                    Buy_In_Start_Date__c = System.today(), 
                                                                    Advertising_Start_Date__c = system.today(), 
                                                                    Advertising_End_Date__c = system.today()+1);
        
        insert catSub2;
        
        Product2 product = [Select Id from Product2 where SAP_Material_Group__c = 'ML-TL' limit 1];
        Product2 prod2 = [Select Id from Product2 where SAP_Material_Group__c = 'ML-SP' limit 1];
        Catalogue_Product__c catProd = new Catalogue_Product__c(Product__c = product.Id, Dealer_Pricing__c = 123, Catalogue__c = catSub.Id);
        insert catProd;
        
        Catalogue_Product__c catProd2 = new Catalogue_Product__c(Product__c = product.Id, Dealer_Pricing__c = 123, Catalogue__c = catSub2.Id);
        insert catProd2;
        
        Loyalty_Added_Product__c vaProd = new Loyalty_Added_Product__c(Catalogue_Product__c = catProd2.Id, Bonus_Product__c = product.Id, Catalogue_Submission__c = catSub2.Id);
        insert vaProd;
        
        Loyalty_Added_Product__c vaProd2 = new Loyalty_Added_Product__c(Catalogue_Product__c = catProd2.Id, Bonus_Product__c = product.Id, Catalogue_Submission__c = catSub.Id);
        insert vaProd2;
        PageReference pageRef = Page.ValueAddedProductCreate;
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('Id', catSub.Id);
        ApexPages.currentPage().getParameters().put('vapSize', '1');
        ApexPages.currentPage().getParameters().put('vapPq0', '1');
        ApexPages.currentPage().getParameters().put('vapBq0', '1');
        ApexPages.currentPage().getParameters().put('catprodId0', catProd.Id);
        ApexPages.currentPage().getParameters().put('catprodCode0', catProd.Product_Code__c);
        

        
        ValueAddedProductCreateController.productWrapper cmp = new ValueAddedProductCreateController.productWrapper(catProd);
            cmp.prod=catProd;
            cmp.bonusProd.Bonus_Product__c = product.Id;    
            cmp.bonusProd.Bonus_Quantity__c = 1;
            cmp.bonusProd.Purchase_Quantity__c = 1;
        ValueAddedProductCreateController controller = new ValueAddedProductCreateController();
        controller.prodWrap.add(cmp);
        controller.cancel();
        controller.test();
        controller.redirectMethod();
        controller.setQuantityMethod();
    }

}