/**
 * @author: Francis Nasalita
 * @date: March 2018
 * @description: This class handles logic AEG Redemption Page
 */
global without sharing class AEGRedemptionController {
    private static final String SITE_MASTERLABEL = (!Test.isRunningTest()? Site.getMasterLabel(): 'myAEG');
    // TO DO: move to custom settings
    public static Community_Setting__mdt communitySettings = CommunitySettingsHelper.getSiteSettings(SITE_MASTERLABEL);

    @AuraEnabled
    public static CommunitySettingsHelper.SiteSettingsResult getSiteSettings() {
        return CommunitySettingsHelper.getSiteAndUserSettings(SITE_MASTERLABEL);
    }

    /**********************************************************************
     * @description             Fetch contact detail
     * @return                  Serialize contact record
     */
    @AuraEnabled
    public static String getPersonAccountDetails() {
        Contact contact = new Contact();
        try {
            contact = [SELECT Id, 
                              Name, 
                              MobilePhone, 
                              Email, 
                              MailingStreet, 
                              MailingState, 
                              MailingPostalCode, 
                              MailingCountry, 
                              MailingCity, 
                              Brand__c, 
                              AccountId, 
                              FirstName, 
                              LastName
                      FROM Contact 
                      WHERE Id IN (SELECT ContactId 
                                   FROM User 
                                   WHERE Id = :UserInfo.getUserId())
                      LIMIT 1];
        } catch (Exception ex){
            throw new AuraHandledException(Label.AEG_Generic_Error_Message);
        }
        return JSON.serialize(contact);
    }

    @AuraEnabled
    public static String getPromotions(String assetId) {
        Contact con = (Contact) JSON.deserialize(getPersonAccountDetails(), Contact.class);
        Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>> results = 
            new Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>>();
        for (AgRedemptionService.AgRedemptionServiceWrapper wrapper : getRedemptionCampaigns(con.AccountId, assetId)) {
            Redemption_Campaigns__c campaign = wrapper.campaign;
            // Group campaigns based on the purchased product and range
            String key  = generateMapKey(campaign);
            if (!results.containsKey(key)) {
                results.put(key, new List<AgRedemptionService.AgRedemptionServiceWrapper>());
            }
            results.get(key).add(wrapper);
        }
        return JSON.serialize(results);
    }

    private static String generateMapKey(Redemption_Campaigns__c campaign) {
        Decimal submissionLimit = campaign.Submission_Limit__c != null ? campaign.Submission_Limit__c : 0;
        Decimal disclaimerLimit = campaign.Customer_Disclaimer_Limit__c != null ? campaign.Customer_Disclaimer_Limit__c : 0;
        return 'PurchasedId: ' + campaign.PurchasedProducts__c + ' | ' +
            'Range: ' + campaign.Valid_From__c + '-' + campaign.Valid_To__c + '-' + campaign.Redeemed_By__c + ' | ' +
            'Submission Limit: ' + submissionLimit + ' | ' +
            'Disclaimer Limit: ' + disclaimerLimit;
    }

    private static List<AgRedemptionService.AgRedemptionServiceWrapper> getRedemptionCampaigns(String accountId, String assetId) {
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload(accountId, assetId);
        AgRedemptionService service = new AgRedemptionService(payload);
        return service.fetchCampaigns();
    }

    private static AgRedemptionService.AgRedemptionServicePayload buildPayload(String accountId, String assetId) {
        return new AgRedemptionService.AgRedemptionServicePayload()
            .setAccountId(accountId)
            .setAssetId(assetId);
    }

    @AuraEnabled
    public static void submitRedemption(String payload) {
        Savepoint sp = Database.setSavepoint();
        try {
            AEGSubmitRedemptionWrapper details = (AEGSubmitRedemptionWrapper) JSON.deserialize(payload, AEGSubmitRedemptionWrapper.class);
            RedeemedProducts__c redeemedProduct = createRedeemedProduct();
            createRedeemedItems(details.campaign, details.redeemedProductId, redeemedProduct.Id);

            //Added By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
            PurchasedProducts__c purchasedProduct = createPurchasedProduct();
            createPurchasedItems(details.campaign, purchasedProduct.Id);
            Redemptions__c redemption = createRedemptions(details.campaign, details.contact, redeemedProduct.Id, purchasedProduct.Id);
            //INC0025332 update END

            //Redemptions__c redemption = createRedemptions(details.campaign, details.contact, redeemedProduct.Id); // Removed By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
            limitedCampaignChecker(details.campaign.Id);
            linkRedemptionToAssets(details.campaign, redemption.Id, details.contact.Id);

            //Added By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
            updateRedeemedProduct(redeemedProduct.Id, redemption.Id);
            updatePurchasedProduct(purchasedProduct.Id, redemption.Id);
            //INC0025332 update END


        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static RedeemedProducts__c createRedeemedProduct() {
        RedeemedProducts__c record = new RedeemedProducts__c();
        insert record;
        return record;
    }

    //Added By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
    private static PurchasedProducts__c createPurchasedProduct() {
        PurchasedProducts__c record = new PurchasedProducts__c();
        insert record;
        return record;
    }

    private static void updateRedeemedProduct(String redeemedProductId, String redemptionId) {
        RedeemedProducts__c record = new RedeemedProducts__c();
        record.Id = redeemedProductId;
        record.Related_Redemption__c = redemptionId;
        update record;
    }

    private static void updatePurchasedProduct(String purchasedProductId, String redemptionId) {
        PurchasedProducts__c record = new PurchasedProducts__c();
        record.Id = purchasedProductId;
        record.Related_Redemption__c = redemptionId;
        update record;
    }

    private static void createPurchasedItems(Redemption_Campaigns__c campaign, String purchasedProductId) {

        List<PurchasedProductLineItem__c> lstPPLI = new List<PurchasedProductLineItem__c>();
        List<PurchasedProductLineItem__c> lstPPLIToCreate = new List<PurchasedProductLineItem__c>();

        lstPPLI = [SELECT Id, PurchasedProduct__c, Product__c, Quantity__c, Required__c, Purchased__c FROM PurchasedProductLineItem__c WHERE PurchasedProduct__c =: campaign.PurchasedProducts__c];
        
        if(lstPPLI.size() > 0){
            for(PurchasedProductLineItem__c ppli : lstPPLI){
                PurchasedProductLineItem__c newppli = new PurchasedProductLineItem__c();
                newppli.Product__c = ppli.Product__c;
                newppli.Quantity__c = ppli.Quantity__c;
                newppli.Required__c = ppli.Required__c;
                newppli.PurchasedProduct__c = purchasedProductId;
                if(ppli.Required__c){
                    newppli.Purchased__c = true;
                }
                lstPPLIToCreate.add(newppli);
            }
            if(lstPPLIToCreate.size() > 0){
                insert lstPPLIToCreate;
            }
        }

    }
    //INC0025332 update END


    private static Redemptions__c createRedemptions(Redemption_Campaigns__c campaign, Contact contact, String redeemedProductId, String purchasedProductId) {
        Redemptions__c record = new Redemptions__c(
            Status__c = 'Submitted',
            PurchasedProducts__c = purchasedProductId, //Added By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
            //PurchasedProducts__c = campaign.PurchasedProducts__c, // Removed By: KB 12/13/22 - INC0025332 (part of solution for multiline redemption)
            RedeemedProducts__c = redeemedProductId,
            Name__c = contact.Id,
            Brand__c = contact.Brand__c,
            Redemption_Campaign__c = campaign.Id
        );
        insert record;
        return record;
    }

    private static void createRedeemedItems(Redemption_Campaigns__c campaign, String redeemedItem, String redeemedProductId) {
        Boolean isAllRedeemable = campaign.RedeemableProducts__r.RedeemType__c == 'All';
        List<RedeemedProductItem__c> redeemedItems = new List<RedeemedProductItem__c>();
        for (RedeemableProductItem__c item : [SELECT Product__c, 
                                                     Quantity__c,
                                                     Required__c
                                               FROM RedeemableProductItem__c
                                               WHERE RedeemableProduct__c = :campaign.RedeemableProducts__c]) {
            if (isAllRedeemable) {
                redeemedItems.add(createRedeemedProductItem(redeemedProductId, item));
            } else {
                if(item.Required__c == true){
                    redeemedItems.add(createRedeemedProductItem(redeemedProductId, item));
                }else{
                    if (item.Id == redeemedItem) {
                        redeemedItems.add(createRedeemedProductItem(redeemedProductId, item));
                    }
                }
            }
        }
        insert redeemedItems;
    }

    private static RedeemedProductItem__c createRedeemedProductItem(String parentId, RedeemableProductItem__c item) {
        return new RedeemedProductItem__c(
            Product__c = item.Product__c,
            Quantity__c = item.Quantity__c,
            RedeemedProduct__c = parentId
        );
    }

    private static void linkRedemptionToAssets(Redemption_Campaigns__c campaign, String redemptionId, String contactId) {
        List<Asset> assets = new List<Asset>();
        Map<String, Decimal> purchasedProductCount = getPurchasedProductCount(campaign.PurchasedProducts__c);
        Map<String, Decimal> getKitToolQuantity = getKitToolQuantity(purchasedProductCount);
        Map<String, Decimal> totalCount = getTotalCount(new List<Map<String, Decimal>>{ purchasedProductCount, getKitToolQuantity });
        for (Asset asset: [SELECT Id, 
                                  Product2Id, 
                                  Receipt__c, 
                                  Redeemed__c,
                                  KitProduct__c
                          FROM Asset
                          WHERE (KitProduct__c IN :purchasedProductCount.keySet()
                          OR Product2Id IN :purchasedProductCount.keySet())
                          AND ContactId = :contactId
                          AND Redeemed__c = false]) {
            String key = (String.isNotBlank(asset.KitProduct__c) ? asset.KitProduct__c + '-' : '') + asset.Product2Id;
            Decimal quantity = totalCount.get(key);
            if (quantity > 0) {
                asset.Redeemed__c = true;
                asset.Redemption__c = redemptionId;
                assets.add(asset);
                totalCount.put(key, quantity - 1);
            }
        }
        update assets;
    }

    private static Map<String, Decimal> getPurchasedProductCount(String purchasedProductId) {
        Map<String, Decimal> productCount = new Map<String, Decimal>();
        for (PurchasedProductLineItem__c item : [SELECT Product__c, 
                                                        Quantity__c
                                                FROM PurchasedProductLineItem__c 
                                                WHERE PurchasedProduct__c = :purchasedProductId]) {
            String key = item.Product__c;
            if (!productCount.containsKey(key)) {
                productCount.put(key, item.Quantity__c);
            }

            Decimal quantity = productCount.get(key);
            productCount.put(key, quantity + item.Quantity__c);
        }
        return productCount;
    }

    private static Map<String, Decimal> getKitToolQuantity(Map<String, Decimal> purchasedProducts) {
        Map<String, Decimal> toolsQuantity = new Map<String, Decimal>();
        for (Product_Kit__c kit: [SELECT Kit__c,
                                         Kit_Tool__c, 
                                         Quantity__c 
                                  FROM Product_Kit__c 
                                  WHERE Kit__c IN :purchasedProducts.keySet()]) {
            Decimal multiplier = purchasedProducts.get(kit.Kit__c);
            String key = kit.Kit__c + '-' + kit.Kit_Tool__c;
            if (!toolsQuantity.containsKey(key)) {
                toolsQuantity.put(key, 0);
            }
            Decimal quantity = toolsQuantity.get(key);
            toolsQuantity.put(key, quantity + (multiplier * kit.Quantity__c));
        }
        return toolsQuantity;
    }

    private static Map<String, Decimal> getTotalCount(List<Map<String, Decimal>> counts) {
        Map<String, Decimal> totalCount = new Map<String, Decimal>();
        for (Map<String, Decimal> count : counts) {
            totalCount.putAll(count);
        }
        return totalCount;
    }

    @AuraEnabled
    public static String updateContactDetails(String inputFirstName, String inputLastName, String inputMobile, String inputEmail,
        String inputStreet, String inputCity, String inputCountry, String inputProvince, String inputPostalCode) {

        Contact con = (Contact) JSON.deserialize(getPersonAccountDetails(), Contact.class);
        Account acc = new Account();
        acc.Id = con.AccountId;
        acc.FirstName = inputFirstName;
        acc.LastName = inputLastName;
        acc.PersonMobilePhone = inputMobile;
        acc.PersonEmail = inputEmail;
        acc.PersonMailingStreet = inputStreet;
        acc.PersonMailingCity = inputCity;
        acc.PersonMailingState = inputProvince;
        acc.PersonMailingCountry = inputCountry;
        acc.PersonMailingPostalCode = inputPostalCode;

        try {
            update acc;
            return JSON.serialize((Contact) JSON.deserialize(getPersonAccountDetails(), Contact.class));
        } catch (Exception err) {
            return JSON.serialize(err.getMessage());
        }
    }

    //FOR GOOGLE API
    @AuraEnabled
    global static string getAddressAutoComplete(String input, String countryname) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:' 
                        + countryname + '&input=' 
                        + EncodingUtil.urlEncode(input, 'UTF-8') 
                        + '&types=geocode&key=' + getGoogleMapsAPIKey();
        return UtilityClass.getHttp(url);
    }

    @AuraEnabled
    global static string getAddressDetails(String PlaceId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' 
                        + PlaceId + '&key=' 
                        + getGoogleMapsAPIKey();
        return UtilityClass.getHttp(url);
    }


    global static String getGoogleMapsAPIKey() {
        return Label.GoogleMapsApiKey;
    }

    @AuraEnabled
    public static AgSurveyEntity getSurveyDetails() {
        AgSurveyService survey = new AgSurveyService('Product_Exposure');
        return survey.fetch();
    }
    
    @AuraEnabled
    public static Boolean hasParticipated() {
        Id accountId = [SELECT AccountId FROM User Where Id = :UserInfo.getUserId()].AccountId;

        AgSurveyService survey = new AgSurveyService('Product_Exposure');
        return survey.hasParticipated(accountId);
    }

    private static void limitedCampaignChecker(Id redCampId) {
        Redemption_Campaigns__c redCamp = [SELECT Id, 
                                                  Total_Number_of_Submissions__c, 
                                                  Submission_Limit__c
                                           FROM Redemption_Campaigns__c
                                           WHERE Id = :redCampId];
        if (redCamp.Submission_Limit__c != 0 && redCamp.Submission_Limit__c != NULL) {
            if (redCamp.Total_Number_of_Submissions__c < redCamp.Submission_Limit__c) {
                redCamp.Total_Number_of_Submissions__c = redCamp.Total_Number_of_Submissions__c + 1;
            } else if (redCamp.Total_Number_of_Submissions__c == NULL) {
                redCamp.Total_Number_of_Submissions__c = 1;
            } else {
                throw new AuraHandledException(Label.AG_Limited_Redemption_Error_Message);
            }
        }
        update redCamp;
    }

    public class AEGSubmitRedemptionWrapper {
        public Contact contact { get; set; }
        public Redemption_Campaigns__c campaign { get; set; }
        public String redeemedProductId { get; set; }
    }
}