/**
 * @description                     Main service for retrieving aeg redemption campaign records
 *                                  with purchased and redeemable product line item, and 
 *                                  determines if the product is redeemable or not
 * @modified by                     rdavid2@ttibrands.com.au - 4/12/2023 - https://ttianz.atlassian.net/browse/SD-2149 - AEG NZ Website Product Registration Bug
 * 
 */
public without sharing class AgRedemptionService {
    private final String ACCOUNT_ERROR_REQUIRED = 'Must provide an Account Id';
    private final String BRAND_NAME = 'aeg';
    private AgRedemptionServicePayload payload;

    /**
     * @description                 Class constructor
     * 
     * @param payload               AEG Redemption service payload
     */
    public AgRedemptionService(AgRedemptionServicePayload payload) {
        this.payload = payload;
    }

    /**
     * @description                 Fetch AEG redemption campaigns along with
     *                              purchased and redeemable product items and
     *                              determine if campaign is redeemable or not
     */
    public List<AgRedemptionServiceWrapper> fetchCampaigns() {
        this.validatePayload();
        List<AgRedemptionServiceWrapper> results = new List<AgRedemptionServiceWrapper>();
        List<RedemptionService.RedemptionCampaignWrapper> response = this.fetchRedemptionCampaigns();
        Set<String> purchasedProductIds = this.fetchPurchaseProductIds(response);
        Map<String, Decimal> partsCount = this.fetchKitPartsCount(purchasedProductIds);
        Map<String, List<Asset>> assets = this.fetchAccountAssets(response, purchasedProductIds);
        for (RedemptionService.RedemptionCampaignWrapper item : response) {
            AgRedemptionServiceWrapper wrapper = this.buildRedemptionWrapper(item, assets, partsCount);
            if (String.isNotBlank(this.payload.assetId)) {
                if (wrapper.isRedeemable) {
                    results.add(wrapper);
                }
            } else {
                results.add(wrapper);
            }
        }

        return results;
    }

    /**
     * @description                 Validate payload if all have values
     */
    private void validatePayload() {
        if (String.isBlank(this.payload.accountId)) {
            throw new AgRedemptionServiceException(this.ACCOUNT_ERROR_REQUIRED);
        }
    }

    /**
     * @description                 Fetch all available redemption campaigns
     */
    private List<RedemptionService.RedemptionCampaignWrapper> fetchRedemptionCampaigns() {
        RedemptionService.RedemptionServicePayloadWrapper payload = this.buildPayload();
        RedemptionService service = new RedemptionService(payload);
        return service.fetchRedemptionCampaigns();
    }

    /**
     * @description                 Build payload for Redemption Service class
     */
    private RedemptionService.RedemptionServicePayloadWrapper buildPayload() {
        Date currDate = System.today();
        String country = this.getCountry();
        return new RedemptionService.RedemptionServicePayloadWrapper()
            .setBrandName(BRAND_NAME)
            .setCountry(country);
    }

    /**
     * @description                 Get country
     */
    private String getCountry() {
        String source = AEGRedemptionController.communitySettings.Lead_Source__c;
        return source == 'MYAEG' ? GlobalConstantUtility.AUSTRALIA : GlobalConstantUtility.NEW_ZEALAND;
    }

    /**
     * @description                 Fetch account assets
     */
    private Map<String, List<Asset>> fetchAccountAssets(List<RedemptionService.RedemptionCampaignWrapper> response, Set<String> productIds) {
        Set<String> assetSources = this.fetchAssetSource();
        Map<String, Date> range = this.fetchMinMaxDateRange(response);
        Map<String, List<Asset>> assets = new Map<String, List<Asset>>();
        for (Asset asset : [SELECT Id, 
                                   PurchaseDate, 
                                   KitProduct__c, 
                                   KitProduct__r.ProductCode, 
                                   Product2Id,  
                                   Product2.ProductCode,
                                   CreatedDate
                            FROM Asset 
                            WHERE AccountId = :this.payload.accountId
                            AND PurchaseDate >= :range.get('min')
                            AND PurchaseDate <= :range.get('max')
                            AND Redeemed__c = FALSE
                            AND AssetSource__c IN :assetSources
                            AND (Product2Id IN :productIds
                            OR KitProduct__c IN :productIds)
                            ORDER BY CreatedDate DESC]) {
            String key = String.isNotBlank(asset.KitProduct__c) ?  asset.KitProduct__c : asset.Product2Id;
            if (!assets.containsKey(key)) {
                assets.put(key, new List<Asset>());
            }
            assets.get(key).add(asset);
        }
        return assets;
    }
    
    /**
     * @description                 Fetch purchased product Ids
     * 
     * @param response              Redemption service response
     */
    private Set<String> fetchPurchaseProductIds(List<RedemptionService.RedemptionCampaignWrapper> response) {
        Set<String> productIds = new Set<String>();
        for(RedemptionService.RedemptionCampaignWrapper wrapper : response) {
            //rdavid2@ttibrands.com.au - 4/12/2023 - [SD-2149] - Null checker of Purchased Line Items
            if(wrapper.purchasedItems != NULL){ 
                for (PurchasedProductLineItem__c item : wrapper.purchasedItems) {
                    productIds.add(item.Product__c);
                }
            }
        }
        return productIds;
    }

    /**
     *  @description                Fetch kit parts, to be used later
     *                              to compute the quantity needed to
     * 
     * @param productIds            Kit product Ids
     */
    private Map<String, Decimal> fetchKitPartsCount(Set<String> productIds) {
        Map<String, Decimal> kitPartsCount = new Map<String, Decimal>();
        for (Product_Kit__c tool :  [SELECT Id, 
                                            Kit__c, 
                                            Quantity__c 
                                    FROM Product_Kit__c 
                                    WHERE Kit__c IN :productIds
                                    AND Kit_Product_Status__c = TRUE]) {
            String key = tool.Kit__c;
            if (!kitPartsCount.containsKey(tool.Kit__c)) {
                kitPartsCount.put(key, 0);
            }
            kitPartsCount.put(tool.Kit__c, kitPartsCount.get(tool.Kit__c) + tool.Quantity__c);
        }
        return kitPartsCount;
    }

    /**
     * @description                 Fetch asset sources
     */
    private Set<String> fetchAssetSource() {
        String siteLabel = Test.isRunningTest() ? 'myAEG' : Site.getMasterLabel();
        Set<String> settings = new Set<String>{'CommonSettings', siteLabel };
        Set<String> sources = new Set<String>();
        for (Purchased_Brand_Mapping__mdt pBrandMap : [SELECT Id,
                                                              Asset_Source_Value__c
                                                       FROM Purchased_Brand_Mapping__mdt
                                                       WHERE Community__r.MasterLabel IN :settings
                                                       AND Is_Redemption_Applicable__c = true
                                                       AND Asset_Source_Value__c != null]) {
            sources.add(pBrandMap.Asset_Source_Value__c);
        }
        return sources;
    }

    /**
     * @description                 Fetch date range of eligible assets for redemptions
     * 
     * @param response              Redemption service response
     */
    private Map<String, Date> fetchMinMaxDateRange(List<RedemptionService.RedemptionCampaignWrapper> response) {
        Map<String, Date> range = new Map<String, Date>{ 'min' => null, 'max' => null };
        for (RedemptionService.RedemptionCampaignWrapper item : response) {
            Redemption_Campaigns__c campaign = item.campaign;
            Date minDate = range.get('min');
            Date maxDate = range.get('max');
            if (minDate == null || minDate > campaign.Valid_From__c) {
                range.put('min', campaign.Valid_From__c);
            }

            if (maxDate == null || maxDate < campaign.Redeemed_By__c) {
                range.put('max', campaign.Redeemed_By__c);
            }
        }
        return range;
    }

    /**
     * @description                 Build AEG Redemption Service response
     * 
     * @param item                  Redemption service response
     * @param assets                Account assets
     * @param partsCount            Kit parts count
     */
    private AgRedemptionServiceWrapper buildRedemptionWrapper(RedemptionService.RedemptionCampaignWrapper item,
        Map<String, List<Asset>> assets, 
        Map<String, Decimal> partsCount) {
        AgRedemptionServiceWrapper wrapper = new AgRedemptionServiceWrapper();
        wrapper.campaign = item.campaign;
        wrapper.purchasedItems = item.purchasedItems;
        wrapper.redeemableItems = item.redeemableItems;
        wrapper.requiredRedeemableItems = item.requiredRedeemableItems;
        wrapper.isRedeemable = this.isRedeemable(item, assets, partsCount);
        wrapper.isActive = this.isCampaignActive(item.campaign);

        return wrapper;
    }

    /**
     * @description                 Determines if the asset is eligible for a redemption campaign
     * 
     * @param items                 List of campaigns, redeemableitems, and puchaseditems
     * @param productCount          List of account assets grouped by product
     */
    private Boolean isRedeemable(RedemptionService.RedemptionCampaignWrapper payload, Map<String, List<Asset>> assets, Map<String, Decimal> productCount) {
        PurchasedItemsWrapper wrapper = this.fetchPurchasedItemsWrapper(payload, productCount);
        if (!assets.keySet().containsAll(wrapper.requiredItems.keySet())) {
            return false;
        }

        Boolean hasRequiredItems = !wrapper.requiredItems.isEmpty();
        ValidateProductResponse requiredProductResponse = this.validateProducts(wrapper, assets, true);
        ValidateProductResponse optionalProductsResponse = this.validateProducts(wrapper, assets, false);
        Set<String> assetIds = new Set<String>();
        assetIds.addAll(requiredProductResponse.assetIds);
        assetIds.addAll(optionalProductsResponse.assetIds);
        Boolean isCurrAssetValid = (String.isBlank(this.payload.assetId) || assetIds.contains(this.payload.assetId));
        Boolean isRequiredItemsValid = hasRequiredItems && requiredProductResponse.isRedeemable;
        return (isRequiredItemsValid || optionalProductsResponse.isRedeemable) && isCurrAssetValid;
    }

    /**
     * @description                 Group purchased items if required or not
     */
    private PurchasedItemsWrapper fetchPurchasedItemsWrapper(RedemptionService.RedemptionCampaignWrapper payload, Map<String, Decimal> kitPartsCount) {
        PurchasedItemsWrapper wrapper = new PurchasedItemsWrapper(payload.campaign);
        //rdavid2@ttibrands.com.au - 4/12/2023 - [SD-2149] - Null checker of Purchased Line Items
        if(payload.purchasedItems != NULL){ 
            for (PurchasedProductLineItem__c item : payload.purchasedItems) {
                if (item.Required__c) {
                    this.updateProductMapCount(wrapper.requiredItems, item, kitPartsCount);
                } else {
                    this.updateProductMapCount(wrapper.optionalItems, item, kitPartsCount);
                }
            }
        }
        return wrapper;
    }

    /**
     * @description                 Fetch product quantities
     *                              For kit, Purchased Product Quantity * Kit Parts
     *                              For single items, purchased product quantity only
     */
    private void updateProductMapCount(Map<String, Decimal> products, PurchasedProductLineItem__c item, Map<String, Decimal> kitPartsCount) {
        if (!products.containsKey(item.Product__c)) {
            products.put(item.Product__c, 0);
        }
        Decimal quantity = this.fetchProductQuantity(item, kitPartsCount);
        products.put(item.Product__c, products.get(item.Product__c) + quantity);
    }

    /**
     * @description                 Compute new product quantities specifically for kits
     */
    private Decimal fetchProductQuantity(PurchasedProductLineItem__c item, Map<String, Decimal> kitPartsCount) {
        if (!kitPartsCount.containsKey(item.Product__c)) {
            return item.Quantity__c != NULL ? item.Quantity__c : 1;
        }
        return item.Quantity__c * kitPartsCount.get(item.Product__c);
    }

    /**
     * @description                 Validate if assets are valid for redemption
     */
    private ValidateProductResponse validateProducts(PurchasedItemsWrapper wrapper, Map<String, List<Asset>> assets, Boolean isRequired) {
        Set<String> assetIds = new Set<String>();
        Boolean isRedeemable = isRequired;
        Map<String, Decimal> items = isRequired ? wrapper.requiredItems : wrapper.optionalItems;
        for (String key : items.keySet()) {
            if (assets.containsKey(key)) {
                Decimal requiredQuantity = items.get(key);
                Set<String> validAssetIds = this.fetchValidAssetIds(wrapper.campaign, assets.get(key));
                Boolean isValidCount = validAssetIds.size() >= requiredQuantity;
                isRedeemable = isRequired ? (isRedeemable && isValidCount) : (isRedeemable || isValidCount);
                assetIds.addAll(validAssetIds);
            }
        }
        return new ValidateProductResponse(isRedeemable, assetIds);
    }

    /**
     * @description                 Fetch all eligible asset Ids
     * 
     * @param campaign              Redemption campaign record
     * @param assets                List of account assets
     */
    private Set<String> fetchValidAssetIds(Redemption_Campaigns__c campaign, List<Asset> assets) {
        Set<String> assetIds = new Set<String>();
        for (Asset asset : assets) {
            Boolean isValid = this.isAssetValid(campaign, asset);
            if (isValid) {
                assetIds.add(asset.Id);
            }
        }
        return assetIds;
    }

    /**
     * @description                 Determine if asset puchased date is eligible for the campaign
     * 
     * @param campaign              Redemption campaign record
     * @param asset                 Asset record
     */
    private Boolean isAssetValid(Redemption_Campaigns__c campaign, Asset asset) {
        return campaign.Valid_From__c <= asset.PurchaseDate &&
            campaign.Valid_To__c >= asset.PurchaseDate &&
            campaign.Redeemed_By__c >= System.today();
    }

    /**
     * @description                 Determine if campaign is active via valid from and valid to
     * 
     * @param campaign              Redemption campaign record
     */
    private Boolean isCampaignActive(Redemption_Campaigns__c campaign) {
        Date currDate = System.today();
        return campaign.Valid_From__c <= currDate && campaign.Valid_To__c >= currDate;
    }

    /**
     * @description                 Purchased Item Wrapper
     *                              Includes the campaign record,
     *                              required and optional purchased items, and 
     *                              productIds
     */
    private class PurchasedItemsWrapper {
        Redemption_Campaigns__c  campaign;
        Map<String, Decimal> requiredItems = new Map<String, Decimal>();
        Map<String, Decimal> optionalItems = new Map<String, Decimal>();
        public PurchasedItemsWrapper(Redemption_Campaigns__c campaign) {
            this.campaign = campaign;
        }
    }

    /**
     * @description                 Response for validate product method
     */
    private class ValidateProductResponse {
        Boolean isRedeemable;
        Set<String> assetIds;
        public ValidateProductResponse(Boolean isRedeemable, Set<String> assetIds) {
            this.isRedeemable = isRedeemable;
            this.assetIds = assetIds;
        }
    }

    /**
     * @description                 AEG Redemption Service response blueprint
     */
    public class AgRedemptionServiceWrapper {
        public Redemption_Campaigns__c campaign;
        public List<PurchasedProductLineItem__c> purchasedItems = new List<PurchasedProductLineItem__c>();
        public List<RedeemableProductItem__c> redeemableItems = new List<RedeemableProductItem__c>();
        public List<RedeemableProductItem__c> requiredRedeemableItems = new List<RedeemableProductItem__c>();
        public Boolean isRedeemable = false;
        public Boolean isActive = false;
    }

    /**
     * @description                 AEG Redemption Service payload blueprint
     */
    public class AgRedemptionServicePayload {
        String accountId;
        String assetId;

        public AgRedemptionServicePayload setAccountId(String value) {
            this.accountId = value;
            return this;
        }

        public AgRedemptionServicePayload setAssetId(String value) {
            this.assetId = value;
            return this;
        }
    }

    /**
     * @description                 AEG Redemption Service custom exception
     */
    public class AgRedemptionServiceException extends Exception {}
}