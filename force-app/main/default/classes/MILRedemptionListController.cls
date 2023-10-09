/**
* @author: Francis Nasalita
* @date: May 2022
* @description: This class handles logic for Milwaukee Redemption List Page
*/
public without sharing class MILRedemptionListController {

    @AuraEnabled
    public static String getRedemptions() {
        List<Redemptions__c> redemptions = [SELECT Id, Name, Status__c, CreatedDate, Freight_Tracking_URL__c, PurchasedProducts__c FROM Redemptions__c WHERE Name__c = :getUserContactId()];
        Set<String> purchasedProductsIds = new Set<String>();
        List<RedemptionData> redemptionsData = new List<RedemptionData>();

        if (!redemptions.isEmpty()) {
            for (Redemptions__c redemption : redemptions) {
                if (String.isNotBlank(redemption.PurchasedProducts__c)) {
                    purchasedProductsIds.add(redemption.PurchasedProducts__c);
                }
                
                redemptionsData.add(new RedemptionData(redemption));
            }
    
            Map<String, String> productNames = new Map<String, String>();
            for (PurchasedProductLineItem__c productLineItem : [SELECT Product__r.Customer_Facing_Name__c,
                                                                       PurchasedProduct__c
                                                                FROM PurchasedProductLineItem__c
                                                                WHERE PurchasedProduct__c = :purchasedProductsIds]) {
                if (!productNames.containsKey(productLineItem.PurchasedProduct__c)) {
                    productNames.put(productLineItem.PurchasedProduct__c, productLineItem.Product__r.Customer_Facing_Name__c);
                }
            }
    
            for (RedemptionData redemptionData : redemptionsData) {
                redemptionData.productName = productNames.get(redemptionData.redemption.PurchasedProducts__c);
            }
        }

        return JSON.serialize(redemptionsData);
    }
    
    private static Id getUserContactId() {
        return [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()) LIMIT 1].Id;
    }
    
    public class RedemptionData {
        public Redemptions__c redemption;
        public String productName;

        public RedemptionData(Redemptions__c redemption) {
            this.redemption = redemption;
        }
    }

}