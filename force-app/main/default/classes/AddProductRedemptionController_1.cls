public with sharing class AddProductRedemptionController_1 {

    @AuraEnabled (cacheable=true)
    public static String getRedemptionCampaignProductItem(String redempCampaignId) {
        RedemptionProductWrapper wrapper = new RedemptionProductWrapper();
        try {
            if (String.isNotBlank(redempCampaignId)) {
                Redemption_Campaigns__c campaign = fetchCampaignDetails(redempCampaignId);
                wrapper.campaign = campaign;
                wrapper.purchaseProductItems = fetchPurchaseProductItems(campaign.PurchasedProducts__c);
                wrapper.redeemableProductItems = fetchRedeemableProductItems(campaign.RedeemableProducts__c);
            }
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new AddProductRedemptionControllerException(e.getMessage());
        }
    }

    private static Redemption_Campaigns__c fetchCampaignDetails(String recordId) {
        return [SELECT Id,
                       PurchasedProducts__c,
                       RedeemableProducts__c
                FROM Redemption_Campaigns__c
                WHERE Id = :recordId][0];
    }

    private static List<PurchasedProductLineItem__c> fetchPurchaseProductItems(String purchasedProductId) {
        if (String.isBlank(purchasedProductId)) {
            return new List<PurchasedProductLineItem__c>();
        }

        return [SELECT Id, 
                       Name, 
                       Product__c, 
                       Product__r.Name, 
                       Product_Name__c, 
                       Quantity__c, 
                       PurchasedProduct__c  
                FROM PurchasedProductLineItem__c 
                WHERE PurchasedProduct__c  = :purchasedProductId];
    }

    private static List<RedeemableProductItem__c> fetchRedeemableProductItems(String redeemedProductId) {
        if (String.isBlank(redeemedProductId)) {
            return new List<RedeemableProductItem__c>();
        }

        return [SELECT Id,
                       Name,
                       Product__c,
                       Product__r.Name,
                       Product_Name__c,
                       Quantity__c,
                       RedeemableProduct__c 
                FROM RedeemableProductItem__c
                WHERE RedeemableProduct__c = :redeemedProductId];
    }

    @AuraEnabled
    public static void createPurchasedAndRedeemProducts(String payload) {
        Savepoint sp = Database.setSavepoint();
        AddProductRedemptionPayloadWrapper wrapper = (AddProductRedemptionPayloadWrapper)JSON.deserialize(payload, AddProductRedemptionPayloadWrapper.class);
        try {
            String redeemedItem = insertRedeemedItems(wrapper);
            if (wrapper.redemption.RedeemedProducts__c == null) {
                wrapper.redemption.RedeemedProducts__c = redeemedItem;
                update wrapper.redemption;
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new AddProductRedemptionControllerException(ex.getMessage());
        }
    }

    private static String insertRedeemedItems(AddProductRedemptionPayloadWrapper wrapper) {
        String redeemedProductId = createRedeemedProduct(wrapper.redemption.RedeemedProducts__c);
        for (RedeemedProductItem__c item : wrapper.redeemedItems) {
            item.RedeemedProduct__c = redeemedProductId;
        }
        insert wrapper.redeemedItems;
        return redeemedProductId;
    }

    private static String createRedeemedProduct(String redeemedProductId) {
        if (String.isNotBlank(redeemedProductId)) {
            return redeemedProductId;
        }

        RedeemedProducts__c redeemedProduct = new RedeemedProducts__c();
        insert redeemedProduct;
        return redeemedProduct.Id;
    }

    public class AddProductRedemptionPayloadWrapper {
        Redemptions__c redemption;
        Redemption_Campaigns__c campaign;
        List<RedeemedProductItem__c> redeemedItems;
    }

    // wrapper class 
    public class RedemptionProductWrapper {
        public Redemption_Campaigns__c campaign { get; set; }
        public List<PurchasedProductLineItem__c> purchaseProductItems { get; set; }
        public List<RedeemableProductItem__c> redeemableProductItems {get; set; }
    }

    public class AddProductRedemptionControllerException extends Exception {}
}