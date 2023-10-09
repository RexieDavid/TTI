@isTest
private class AEGRedemptionControllerTest {
    private static final Integer GRACE_PERIOD = 15;
    private static final Integer RECORD_MAX_COUNT = 3;
    private static final String USERNAME = '1t4e7s8t3@yahoo.com.aeg';

    /**********************************************************************
     * @description     Initialize data before running test
     */
    @testSetup
    private static void initData() {
        Account account = createAccount();
        Contact contact = fetchContact();

        List<Product2> products = createProducts();
        List<PurchasedProducts__c> purchasedProducts = createPurchasedProducts(products);
        List<RedeemableProducts__c> redeemableProducts = createRedeemableProducts(products);
        createRedemptionCampaigns(purchasedProducts, redeemableProducts);
        createAssets(products, account.Id, contact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            createUser(contact.Id);
        }
    }

    /**********************************************************************
     * @description     Fetch Community Settings
     */
    @isTest
    private static void getSiteSettingsTest() {
        CommunitySettingsHelper.SiteSettingsResult res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = AEGRedemptionController.getSiteSettings();
            }
        Test.stopTest();
        System.assert(res != null, 'Community Settings not found');
    }

    /**********************************************************************
     * @description     Fetch all active redemption campaigns/promotion
     *                  with Asset
     */
    @isTest
    private static void getPersonAccountDetailsTest() {
        String response;
        Contact contact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id, ContactId FROM User WHERE ContactId = :contact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                response = AEGRedemptionController.getPersonAccountDetails();
            }
        Test.stopTest();
        Contact result = (Contact)JSON.deserialize(response, Contact.class);
        System.assertEquals(portalUser.ContactId, result.Id,  'Failed to retrieve contact record');
    }

    @isTest
    private static void getPersonAccountDetailsNegativeTest() {
        String error;
        Test.startTest();
            try {
                AEGRedemptionController.getPersonAccountDetails();
            } catch(Exception ex) {
                error = ex.getMessage();
            }
        Test.stopTest();
        System.assert(String.isNotBlank(error),  'Successfully retrieve contact record');
    }

    /**********************************************************************
     * @description     Fetch all active redemption campaigns/promotion
     *                  without Asset
     */
    @isTest
    private static void getaAllPromotionTestWithoutAssetIdTest() {
        String response;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                response = AEGRedemptionController.getPromotions('');
            }
        Test.stopTest();
        Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>> results = 
            (Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>>)JSON.deserialize(response, Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>>.class);
        System.assert(!results.isEmpty(), 'No active redemption campaigns/promotions in the system');
        System.assertEquals(RECORD_MAX_COUNT, results.size(), 'Active promotions count mismatch');
    }

    /**********************************************************************
     * @description     Fetch all active redemption campaigns/promotion
     *                  with Asset
     */
    @isTest
    private static void getaAllPromotionTestWithAssetIdTest() {
        String response;
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                response = AEGRedemptionController.getPromotions(asset.Id);
            }
        Test.stopTest();
        Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>> results = 
            (Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>>)JSON.deserialize(response, Map<String, List<AgRedemptionService.AgRedemptionServiceWrapper>>.class);
        System.assert(!results.isEmpty(), 'No active redemption campaigns/promotions in the system');
        System.assertEquals(RECORD_MAX_COUNT, results.size(), 'Active promotions count mismatch');
    }

    @isTest
    private static void submitRedemptionWithOptionalRedeemableItemTest() {
        Contact contact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        Redemption_Campaigns__c campaign = [SELECT Id, 
                                                   PurchasedProducts__c,
                                                   RedeemableProducts__c,
                                                   RedeemableProducts__r.RedeemType__c
                                           FROM Redemption_Campaigns__c 
                                           WHERE RedeemableProducts__r.RedeemType__c = 'Optional' LIMIT 1];
        AEGRedemptionController.AEGSubmitRedemptionWrapper payload = buildSubmitRedemptionPayload(contact, campaign);
        Test.startTest();
            AEGRedemptionController.submitRedemption(JSON.serialize(payload));
        Test.stopTest();
        List<Asset> assets = [SELECT Id FROM Asset WHERE Redeemed__c = TRUE AND Redemption__c != NULL];
        System.assert(!assets.isEmpty(), 'Failed to retrieve redeemed assets');
    }

    @isTest
    private static void submitRedemptionWithAllRedeemableItemTest() {
        Contact contact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        Redemption_Campaigns__c campaign = [SELECT Id, 
                                                  PurchasedProducts__c,
                                                  RedeemableProducts__c,
                                                  RedeemableProducts__r.RedeemType__c
                                           FROM Redemption_Campaigns__c 
                                           WHERE RedeemableProducts__r.RedeemType__c = 'All' LIMIT 1];
        AEGRedemptionController.AEGSubmitRedemptionWrapper payload = buildSubmitRedemptionPayload(contact, campaign);
        Test.startTest();
            AEGRedemptionController.submitRedemption(JSON.serialize(payload));
        Test.stopTest();
        List<Asset> assets = [SELECT Id FROM Asset WHERE Redeemed__c = TRUE AND Redemption__c != NULL];
        System.assert(!assets.isEmpty(), 'Failed to retrieve redeemed assets');
    }

    @isTest
    private static void updateContactDetailsTest() {
        Account account = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :contact.Id];

        Test.startTest();
            System.runAs(portalUser) {
                AEGRedemptionController.updateContactDetails('Demo-FirstName',
                                                             'Demo-LastName',
                                                             '22112312',
                                                             'test@test.com',
                                                             'Demo-Street',
                                                             'Demo-City',
                                                             'Australia',
                                                             'Demo-Province',
                                                             '1223');             
            }
        Test.stopTest();
        Account updatedAccount = [SELECT Id, PersonEmail FROM Account WHERE Id = :account.Id];
        System.assertEquals('test@test.com', updatedAccount.PersonEmail, 'Account record did not update');
    }

    /**********************************************************************
     * @description     create a connection between google api and salesforce
     *                  show the list of possible addresses
     *                  
     */
    @isTest
    private static void getAddressAutoCompleteNegativeTest() {
        String res;
        Test.startTest();
            res = AEGRedemptionController.getAddressAutoComplete('Test', 'Australia');
        Test.stopTest();
        System.assertEquals('sle string', res, 'Google API successfully connected');
    }

    /**********************************************************************
     * @description     create a connection between google api and salesforce
     *                  show the list of possible addresses
     *                  
     */
    @isTest
    private static void getAddressDetailsNegativeTest() {
        String res;
        Test.startTest();
            res = AEGRedemptionController.getAddressDetails('PlaceId');
        Test.stopTest();
        System.assertEquals('sle string', res, 'Google API successfully connected');
    }

    @isTest
    private static void getGooleMapAPIKeyTest() {
        String response;
        Test.startTest();
            response = AEGRedemptionController.getGoogleMapsAPIKey();
        Test.stopTest();
        System.assertEquals(Label.GoogleMapsApiKey, response, 'Failed to retrieve google maps api key');
    }

    @isTest
    private static void getSurveyDetailsTest() {
        AgSurveyEntity response;
        Test.startTest();
            response = AEGRedemptionController.getSurveyDetails();
        Test.stopTest();
        AgSurveyEntity.Question question = response.questions[0];
        List<Schema.PicklistEntry> options = Marketing_Campaign__c.AG_Product_Information_Source__c.getDescribe().getPicklistValues();
        System.assertEquals(Label.AG_Product_Information_Source, question.label, 'Failed to retrieve survey details');
        System.assertEquals(options.size(), question.options.size(), 'Failed to retrieve survey details');
    }

    @isTest
    private static void hasParticipatedTest() {
        Boolean hasParticipated;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                hasParticipated = AEGRedemptionController.hasParticipated();
            }
        Test.stopTest();
        System.assert(!hasParticipated, 'User have completed the survey');
    }

    private static AEGRedemptionController.AEGSubmitRedemptionWrapper buildSubmitRedemptionPayload(Contact contact, Redemption_Campaigns__c campaign) {
        RedeemableProductItem__c item = [SELECT Id FROM RedeemableProductItem__c WHERE RedeemableProduct__c = :campaign.RedeemableProducts__c LIMIT 1];
        AEGRedemptionController.AEGSubmitRedemptionWrapper payload = new AEGRedemptionController.AEGSubmitRedemptionWrapper();
        payload.contact = contact;
        payload.campaign = campaign;
        payload.redeemedProductId = item.Id;
        return payload;
    }

    private static Account createAccount() {
        Account account = TestUtilityClass.createPersonAccount(1)[0];
        insert account;
        return account;
    }

    private static Contact fetchContact() {
        Contact contact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        contact.Email = 'test@mailinator.com';
        contact.Country__c = 'Australia';
        contact.Brand__c = 'AEG';
        update contact;
        return contact;
    }

    private static List<Product2> createProducts() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < (RECORD_MAX_COUNT * 2); i++) {
            products.add(createProduct(String.valueOf(i)));
        }
        insert products;
        return products;
    }

    private static Product2 createProduct(String uniqueId) {
        String prefix = 'Prod-';
        return new Product2(
            Name = prefix + uniqueId,
            Published__c = true,
            IsActive = true,
            Available_AU__c = true,
            Available_NZ__c = true,
            Customer_Facing_Name__c = prefix + uniqueId,
            ProductCode = 'xxxx' + uniqueId
        );
    }

    private static List<PurchasedProducts__c> createPurchasedProducts(List<Product2> products) {
        List<PurchasedProducts__c> purchasedProducts = new List<PurchasedProducts__c>();
        for (Integer i = 0; i < RECORD_MAX_COUNT; i++) {
            purchasedProducts.add(new PurchasedProducts__c());
        }
        insert purchasedProducts;
        createPurchasedProductLineItems(purchasedProducts, products);
        return purchasedProducts;
    }

    private static void createPurchasedProductLineItems(List<PurchasedProducts__c> purchasedProducts, List<Product2> products) {
        List<PurchasedProductLineItem__c> items = new List<PurchasedProductLineItem__c>();
        for (PurchasedProducts__c purchasedProduct : purchasedProducts) {
            for (Integer i =  0; i < RECORD_MAX_COUNT; i++) {
                items.add(createPurchasedProductItems(purchasedProduct.Id, products.get(i).Id));
            }
        }
        insert items;
    }

    private static PurchasedProductLineItem__c createPurchasedProductItems(String parentId, String productId) {
        return new PurchasedProductLineItem__c(
            Product__c = productId,
            PurchasedProduct__c = parentId,
            Quantity__c = 1,
            Required__c = true
        );
    }

    private static List<RedeemableProducts__c> createRedeemableProducts(List<Product2> products) {
        List<RedeemableProducts__c> redeemableProducts = new List<RedeemableProducts__c>();
        for (Integer i = 0; i < RECORD_MAX_COUNT; i++) {
            String redeemType = Math.mod(i, 2) == 0 ? 'Optional' : 'All';
            redeemableProducts.add(new RedeemableProducts__c(RedeemType__c = redeemType));
        }
        insert redeemableProducts;
        createRedeemableProductItems(redeemableProducts, products);
        return redeemableProducts;
    }

    private static void createRedeemableProductItems(List<RedeemableProducts__c> redeemableProducts, List<Product2> products) {
        List<RedeemableProductItem__c> items = new List<RedeemableProductItem__c>();
        for (RedeemableProducts__c redeemableProduct : redeemableProducts) {
            for (Integer i =  RECORD_MAX_COUNT; i < products.size(); i++) {
                items.add(createRedeemableProductItems(redeemableProduct.Id, products.get(i).Id));
            }
        }
        insert items;
    }

    private static RedeemableProductItem__c createRedeemableProductItems(String parentId, String productId) {
        return new RedeemableProductItem__c(
            Product__c = productId,
            RedeemableProduct__c = parentId,
            Quantity__c = 1
        );
    }

    private static List<Redemption_Campaigns__c> createRedemptionCampaigns(List<PurchasedProducts__c> purchasedProducts, List<RedeemableProducts__c> redeemableProducts) {
        List<Redemption_Campaigns__c> campaigns = new List<Redemption_Campaigns__c>();
        for (Integer i = 0; i < RECORD_MAX_COUNT; i++ ) {
            campaigns.add(createRedemptionCampaign(
                String.valueOf(i),
                purchasedProducts.get(i).Id,
                redeemableProducts.get(i).Id
            ));
        }
        insert campaigns;
        return campaigns;
    }

    private static Redemption_Campaigns__c createRedemptionCampaign(String uniqueId, String purchasedProductId, String redeemableProductId) {
        Date currDate = System.today();
        return new Redemption_Campaigns__c(
            Name = 'RED-' + uniqueId,
            Brand__c = 'AEG',
            Country__c = 'Australia',
            PurchasedProducts__c = purchasedProductId,
            RedeemableProducts__c = redeemableProductId,
            Valid_From__c = currDate - GRACE_PERIOD,
            Valid_To__c = currDate + GRACE_PERIOD,
            Redeemed_By__c = currDate + GRACE_PERIOD,
            Redemption_Type__c = 'External'
        );
    }

    private static AgRedemptionService.AgRedemptionServicePayload buildPayload(String accountId, String assetId) {
        return new AgRedemptionService.AgRedemptionServicePayload()
            .setAccountId(accountId)
            .setAssetId(assetId);
    }

    private static List<Asset> createAssets(List<Product2> products, String accountId, String contactId) {
        List<Asset> assets = new List<Asset>();
        for (Product2 product : products) {
            assets.add(createAsset(product, accountId, contactId));
        }
        insert assets;
        return assets;
    }

    private static Asset createAsset(Product2 prod, String accountId, String contactId) {
        Date currDate = System.today();
        return new Asset(
            Product2Id = prod.Id,
            AccountId = accountId,
            ContactId = contactId,
            AssetSource__c = 'Retailer - Bunnings',
            Name = 'Asset' + prod.Id,
            Purchased_Online__c = 'In-Store',
            PurchaseDate = currDate - 1
        );
    }

    private static User createUser(String contactId) {
        String uniqueId = String.valueOf(System.now().getTime());
        Profile profile = [SELECT Id FROM Profile WHERE Name = '~Customer Community AEG' LIMIT 1];
        User user = new User(
            ProfileId = profile.Id,
            Username = USERNAME,
            Alias = 'user' + uniqueId.substring(0, 4),
            Email = 'user-'+ uniqueId + '@test.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'User' + uniqueId,
            Lastname = 'User' + uniqueId,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            ContactId = contactId,
            Country = 'Australia'
        );
        insert user;
        return user;
    }
}