@isTest
public with sharing class AgRedemptionServiceTest {
    private static integer GRACE_PERIOD = 15;
    private static integer RECORD_MAX_COUNT = 3;

    @TestSetup
    static void makeData() {
        Account account = createAccount();
        Contact contact = fetchContact();

        List<Product2> products = createProducts();
        List<PurchasedProducts__c> purchasedProducts = createPurchasedProducts(products);
        List<RedeemableProducts__c> redeemableProducts = createRedeemableProducts(products);
        createRedemptionCampaigns(purchasedProducts, redeemableProducts);
        createAssets(products, account.Id, contact.Id);
    }

    @isTest
    private static void missingAccountIdTest() {
        String errorMessage;
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload('', '');
        Test.startTest();
            try {
                AgRedemptionService service = new AgRedemptionService(payload);
                service.fetchCampaigns();
            } catch(Exception ex) {
                errorMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Must provide an Account Id', errorMessage, 'Successfully retrieve campaigns without account Id');
    }
    
    @isTest
    private static void fetchBrandWithoutAssetIdCampaigns() {
        Account account = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
        List<AgRedemptionService.AgRedemptionServiceWrapper> result = new List<AgRedemptionService.AgRedemptionServiceWrapper>();
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload(account.Id, '');
        Test.startTest();
            AgRedemptionService service = new AgRedemptionService(payload);
            result = service.fetchCampaigns();
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Failed to retrieve aeg campaigns');
    }

    @isTest
    private static void fetchBrandWithAssetIdCampaigns() {
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
        List<AgRedemptionService.AgRedemptionServiceWrapper> result = new List<AgRedemptionService.AgRedemptionServiceWrapper>();
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload(account.Id, asset.Id);
        Test.startTest();
            AgRedemptionService service = new AgRedemptionService(payload);
            result = service.fetchCampaigns();
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Failed to retrieve redeemable aeg campaigns');
    }

    @isTest
    private static void fetchBrandWithoutAssetsCampaigns() {
        delete [SELECT Id FROM Asset];
        Account account = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
        List<AgRedemptionService.AgRedemptionServiceWrapper> result = new List<AgRedemptionService.AgRedemptionServiceWrapper>();
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload(account.Id, '');
        Test.startTest();
            AgRedemptionService service = new AgRedemptionService(payload);
            result = service.fetchCampaigns();
        Test.stopTest();
        for (AgRedemptionService.AgRedemptionServiceWrapper wrapper : result) {
            System.assert(!wrapper.isRedeemable, 'Campaign is redeemable without registered products');
        }
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
            redeemableProducts.add(new RedeemableProducts__c(RedeemType__c = 'Optional'));
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
            PurchaseDate = currDate
        );
    }
}