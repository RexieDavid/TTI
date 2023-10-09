@isTest
public class BatchRedemptionDataFix_RedeemProdsTest {
	
    public static testMethod void testBatchRedeemProdsSingleRedemption(){
        
        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        insert product;
        
        RedeemedProducts__c newRP = new RedeemedProducts__c();
        insert newRP;
       
        RedeemedProductItem__c rpi = new RedeemedProductItem__c();
        rpi.Product__c = product.Id;
        rpi.RedeemedProduct__c = newRP.Id;
        rpi.Quantity__c = 1;
        insert rpi;
        
        Redemption_Campaigns__c redCampaign = new Redemption_Campaigns__c();
        redCampaign.Name = 'test';
        insert redCampaign;
        
        Redemptions__c red = new Redemptions__c();
        red.RedeemedProducts__c = newRP.id;
        red.Redemption_Campaign__c = redCampaign.id;
        insert red;
        
        Test.startTest();
        BatchRedemptionDataFix_RedeemProds b = new BatchRedemptionDataFix_RedeemProds();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
    }
    
        public static testMethod void testBatchRedeemProdsMultiRedemption(){
        
        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        insert product;
        
        RedeemedProducts__c newRP = new RedeemedProducts__c();
        insert newRP;
       
        RedeemedProductItem__c rpi = new RedeemedProductItem__c();
        rpi.Product__c = product.Id;
        rpi.RedeemedProduct__c = newRP.Id;
        rpi.Quantity__c = 1;
        insert rpi;
        
        Redemption_Campaigns__c redCampaign = new Redemption_Campaigns__c();
        redCampaign.Name = 'test';
        insert redCampaign;
        
        Redemptions__c red = new Redemptions__c();
        red.RedeemedProducts__c = newRP.id;
        red.Redemption_Campaign__c = redCampaign.id;
        insert red;
            
		Redemptions__c red2 = new Redemptions__c();
        red2.RedeemedProducts__c = newRP.id;
        red2.Redemption_Campaign__c = redCampaign.id;
        insert red2;    
        
        Test.startTest();
        BatchRedemptionDataFix_RedeemProds b = new BatchRedemptionDataFix_RedeemProds();
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();
    }
}