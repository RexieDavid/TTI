/**
 * @description                     Main service for retrieving redemption campaign records
 *                                  with purchased and redeemable product line item
 * 
 */
public without sharing class RedemptionService {
    private final String BRAND_ERROR_REQUIRED = 'Must provide a brand name(e.g., AEG, Milwaukee)';
    private final String COUNTRY_ERROR_REQUIRED = 'Must provide a country(e.g., Australia or New Zealand)';
    private RedemptionServicePayloadWrapper payload;

    /**
     * @description                 Class constructor
     * 
     * @param payload               Redemption service payload. All 
     *                              variables in the wrapper are required.
     */
    public RedemptionService(RedemptionServicePayloadWrapper payload) {
        this.payload = payload;
    }

    /**
     * @description                 Fetch redemption campaigns along with
     *                              purchased and redeemable product items
     */
    public List<RedemptionCampaignWrapper> fetchRedemptionCampaigns() {
        this.validatePayload();
        List<RedemptionCampaignWrapper> wrappers = new List<RedemptionCampaignWrapper>();
        List<Redemption_Campaigns__c> campaigns = this.fetchAvailableRedemptionCampaigns();
        RedemptionServiceIdsWrapper serviceIds = this.fetchProductIds(campaigns);
        Map<String, List<PurchasedProductLineItem__c>> purchasedLineItems = this.fetchCampaignPurchasedItems(serviceIds.purchasedProductIds);
        Map<String, List<RedeemableProductItem__c>> redeemableLineItems = this.fetchCampaignRedeemableItems(serviceIds.redeemableProductIds, false);
        Map<String, List<RedeemableProductItem__c>> requiredRedeemableLineItems = this.fetchCampaignRedeemableItems(serviceIds.redeemableProductIds, true);
        for (Redemption_Campaigns__c campaign : campaigns) {
            RedemptionCampaignWrapper wrapper = new RedemptionCampaignWrapper();
            wrapper.campaign = campaign;
            wrapper.purchasedItems = purchasedLineItems.get(campaign.PurchasedProducts__c);
            wrapper.redeemableItems = redeemableLineItems.get(campaign.RedeemableProducts__c);
            wrapper.requiredRedeemableItems = requiredRedeemableLineItems.get(campaign.RedeemableProducts__c);
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    /**
     * @description                 Validate payload if all have values
     */
    private void validatePayload() {
        if (String.isBlank(this.payload.brandName)) {
            throw new RedemptionServiceException(this.BRAND_ERROR_REQUIRED);
        }

        if (String.isBlank(this.payload.country)) {
            throw new RedemptionServiceException(this.COUNTRY_ERROR_REQUIRED);
        }
    }

    /**
     * @desciption                  Fetch available redemption campaigns
     */
    private List<Redemption_Campaigns__c> fetchAvailableRedemptionCampaigns() {
        List<String> countries = new List<String>{ this.payload.country, GlobalConstantUtility.ANZ };
        return [SELECT Name,
                       PurchasedProducts__c,
                       RedeemableProducts__c,
                       RedeemableProducts__r.RedeemType__c,
                       Valid_From__c,
                       Valid_To__c,
                       Redeemed_Item_Qty__c,
                       Total_Number_of_Submissions__c,
                       Submission_Limit__c,
                       Customer_Disclaimer_Limit__c,
                       Redeemed_By__c
                FROM Redemption_Campaigns__c 
                WHERE Country__c IN :countries
                AND PurchasedProducts__c != NULL
                AND RedeemableProducts__c != NULL
                AND Brand__c = :this.payload.brandName
                AND ((Valid_From__c <= TODAY
                AND Valid_To__c >= TODAY)
                OR Redeemed_By__c >= TODAY)];
    }

    /**
     * @desciption                  Consolidate lookup Ids related to campaigns
     * 
     * @param campaigns             List of available campaigns
     */
    private RedemptionServiceIdsWrapper fetchProductIds(List<Redemption_Campaigns__c> campaigns) {
        RedemptionServiceIdsWrapper wrapper = new RedemptionServiceIdsWrapper();
        for (Redemption_Campaigns__c campaign : campaigns) {
            wrapper.purchasedProductIds.add(campaign.PurchasedProducts__c);
            wrapper.redeemableProductIds.add(campaign.RedeemableProducts__c);
        }
        return wrapper;
    }

    /**
     * @desciption                  Fetch all related purchased product items related to campaigns
     * 
     * @param campaigns             List of available campaigns
     */
    private Map<String, List<PurchasedProductLineItem__c>> fetchCampaignPurchasedItems(Set<String> recordIds) {
        Map<String, List<PurchasedProductLineItem__c>> items = new Map<String, List<PurchasedProductLineItem__c>>();
        for (PurchasedProductLineItem__c item : [SELECT Id,
                                                        PurchasedProduct__c,
                                                        Product__c,
                                                        Product__r.ProductCode,
                                                        Product__r.Customer_Facing_Name__c,
                                                        Product__r.Image_URL__c,
                                                        Product__r.SAP_MaterialNumber__c,
                                                        Quantity__c,
                                                        Required__c
                                                 FROM PurchasedProductLineItem__c
                                                 WHERE PurchasedProduct__c IN :recordIds]) {
            String key = item.PurchasedProduct__c;
            if (!items.containsKey(key)) {
                items.put(key, new List<PurchasedProductLineItem__c>());
            }
            items.get(key).add(item);
        }
        return items;
    }

    /**
     * @desciption                  Fetch all related redeemable product line items related to campaigns
     * 
     * @param campaigns             List of available campaigns
     */
    private Map<String, List<RedeemableProductItem__c>> fetchCampaignRedeemableItems(Set<String> recordIds, Boolean isRequired) {
        Map<String, List<RedeemableProductItem__c>> items = new Map<String, List<RedeemableProductItem__c>>();
        if(isRequired){
            for (RedeemableProductItem__c item : [SELECT Id,
                                                        RedeemableProduct__c,
                                                        Product__c,
                                                        Product__r.Name,
                                                        Product__r.ProductCode,
                                                        Product__r.Customer_Facing_Name__c,
                                                        Product__r.Image_URL__c,
                                                        Product__r.SAP_MaterialNumber__c,
                                                        Quantity__c,
                                                        Required__c
                                                FROM RedeemableProductItem__c
                                                WHERE RedeemableProduct__c IN :recordIds
                                                    AND Required__c = TRUE]) {
                String key = item.RedeemableProduct__c;
                if (!items.containsKey(key)) {
                    items.put(key, new List<RedeemableProductItem__c>());
                }
                items.get(key).add(item);
            }
        }else{
            for (RedeemableProductItem__c item : [SELECT Id,
                                                        RedeemableProduct__c,
                                                        Product__c,
                                                        Product__r.ProductCode,
                                                        Product__r.Customer_Facing_Name__c,
                                                        Product__r.Image_URL__c,
                                                        Product__r.SAP_MaterialNumber__c,
                                                        Quantity__c,
                                                        Required__c
                                                FROM RedeemableProductItem__c
                                                WHERE RedeemableProduct__c IN :recordIds
                                                    AND Required__c = FALSE]) {
                String key = item.RedeemableProduct__c;
                if (!items.containsKey(key)) {
                    items.put(key, new List<RedeemableProductItem__c>());
                }
                items.get(key).add(item);
            }
        }

        return items;
    }

    /**
     * @description                 Redemption Service payload blueprint
     */
    public class RedemptionServicePayloadWrapper {
        String brandName;
        String country;

        public RedemptionServicePayloadWrapper setBrandName(String brandName) {
            this.brandName = brandName;
            return this;
        }

        public RedemptionServicePayloadWrapper setCountry(String country) {
            this.country = country;
            return this;
        }
    }

    /**
     * @description                 Redemption Service Ids Wrapper blueprint
     */
    private class RedemptionServiceIdsWrapper {
        public Set<String> purchasedProductIds = new Set<String>();
        public Set<String> redeemableProductIds = new Set<String>();
    }

    /**
     * @description                 Redemption Service response
     */
    public class RedemptionCampaignWrapper {
        public Redemption_Campaigns__c campaign;
        public List<PurchasedProductLineItem__c> purchasedItems = new List<PurchasedProductLineItem__c>();
        public List<RedeemableProductItem__c> redeemableItems = new List<RedeemableProductItem__c>();
        public List<RedeemableProductItem__c> requiredRedeemableItems = new List<RedeemableProductItem__c>();
    }

    /**
     * @description                 Redemption Service custom exception
     */
    public class RedemptionServiceException extends Exception {}
}