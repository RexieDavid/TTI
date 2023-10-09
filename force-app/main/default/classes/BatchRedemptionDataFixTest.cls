@isTest
public class BatchRedemptionDataFixTest {

    public static testMethod void testBatchPurcProds1(){
                      
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
        
        Redemptions__c red = new Redemptions__c();
        red.PurchasedProducts__c = newPurchase.id;
        red.Redemption_Campaign__c = redCampaign.id;
        insert red;
        
        Test.startTest();
        BatchRedemptionDataFix b = new BatchRedemptionDataFix();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
    }
}