@isTest
public class BatchRedemptionDataFix_PurcProdsTest {

    public static testMethod void testBatchPurcProdsSingleRedemption(){
                      
        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        insert product;
        
        PurchasedProducts__c newPurchase = new PurchasedProducts__c();
        insert newPurchase;
        
        PurchasedProductLineItem__c purProdsLine = new PurchasedProductLineItem__c();
        purProdsLine.Product__c = product.Id;
        purProdsLine.PurchasedProduct__c = newPurchase.Id;
        purProdsLine.Quantity__c = 1;
        insert purProdsLine;
        
        Redemption_Campaigns__c redCampaign = new Redemption_Campaigns__c();
        redCampaign.Name = 'test';
        insert redCampaign;
        
        Product2 productRed = new Product2();
        productRed.Name = 'test Product2';
        productRed.Brand__c = 'AEG';
        productRed.IsActive = true;
        productRed.ProductCode = 'test321';
        insert productRed;
        
        Redemptions__c red = new Redemptions__c();
        red.PurchasedProducts__c = newPurchase.id;
        red.Redemption_Campaign__c = redCampaign.id;
        insert red;
       
        Test.startTest();
        BatchRedemptionDataFix_PurcProds b = new BatchRedemptionDataFix_PurcProds();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
    }
    
        public static testMethod void testBatchPurcProdsMultiRedemption(){
                      
        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        insert product;
        
        PurchasedProducts__c newPurchase = new PurchasedProducts__c();
        insert newPurchase;
        
        PurchasedProductLineItem__c purProdsLine = new PurchasedProductLineItem__c();
        purProdsLine.Product__c = product.Id;
        purProdsLine.PurchasedProduct__c = newPurchase.Id;
        purProdsLine.Quantity__c = 1;
        insert purProdsLine;
        
        Redemption_Campaigns__c redCampaign = new Redemption_Campaigns__c();
        redCampaign.Name = 'test';
        insert redCampaign;
        
        Product2 productRed = new Product2();
        productRed.Name = 'test Product2';
        productRed.Brand__c = 'AEG';
        productRed.IsActive = true;
        productRed.ProductCode = 'test321';
        insert productRed;
        
        Redemptions__c red = new Redemptions__c();
        red.PurchasedProducts__c = newPurchase.id;
        red.Redemption_Campaign__c = redCampaign.id;
        insert red;
            
        Redemptions__c red2 = new Redemptions__c();
        red2.PurchasedProducts__c = newPurchase.id;
        red2.Redemption_Campaign__c = redCampaign.id;
        insert red2;
       
        Test.startTest();
        BatchRedemptionDataFix_PurcProds b = new BatchRedemptionDataFix_PurcProds();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
    }

}