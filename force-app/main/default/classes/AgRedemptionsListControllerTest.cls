/**
* @author                           Kristopher Veraces
* @date                             2020-09-07
*
* @group                            AEG Community
*/
@isTest
public class AgRedemptionsListControllerTest {
    private static integer GRACE_PERIOD = 15;
    private static final Integer RECORD_MAX_COUNT= 3;
    private static final String USERNAME = 'aeg_user@tti.com.aeg';
    private static final Set<String> STATUS = new Set<String>{ 'Submitted' };
    /**********************************************************************
     * @description                 Initialize data
     */
    @TestSetup
    static void makeData() {
        Account account = createAccount();
        Contact contact = fetchContact();
        List<Product2> products = createProducts();
        List<PurchasedProducts__c> purchasedProducts = createPurchasedProducts(products);
        List<RedeemableProducts__c> redeemableProducts = createRedeemableProducts(products);
        List<Redemption_Campaigns__c> campaigns = createRedemptionCampaigns(purchasedProducts, redeemableProducts);
        List<RedeemedProducts__c> redeemedProducts = createRedeemedProducts(products);
        createRedemptions(campaigns, redeemedProducts, contact.Id);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            createPortalUser(contact.Id);
        }
    }

    @isTest
    private static void fetchRedemptionWithStatusTest() {
        String response;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                response = AgRedemptionsListController.fetchRedemptions(JSON.serialize(STATUS));
            }
        Test.stopTest();
        List<AgRedemptionsListController.RedemptionWrapper> results = 
            (List<AgRedemptionsListController.RedemptionWrapper>)JSON.deserialize(response, List<AgRedemptionsListController.RedemptionWrapper>.class);
        System.assertEquals(RECORD_MAX_COUNT, results.size(), 'Failed to retrieve redemption records');
    }

    @isTest
    private static void fetchRedemptionWithoutStatusTest() {
        String error;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                try {
                    AgRedemptionsListController.fetchRedemptions('');
                } catch(Exception ex) {
                    error = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals('Redemption status is required.', error, 'Successfully retrieved redemptions');
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

    private static void createPortalUser(String contactId) {
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
    }

    private static List<RedeemedProducts__c> createRedeemedProducts(List<Product2> products) {
        List<RedeemedProducts__c> redeemedProducts = new List<RedeemedProducts__c>();
        for (Integer i = 0; i < RECORD_MAX_COUNT; i++) {
            redeemedProducts.add(new RedeemedProducts__c());
        }
        insert redeemedProducts;
        createRedeemedProductItems(redeemedProducts, products);
        return redeemedProducts;
    }

    private static void createRedeemedProductItems(List<RedeemedProducts__c> redeemedProducts, List<Product2> products) {
        List<RedeemedProductItem__c> items = new List<RedeemedProductItem__c>();
        for (RedeemedProducts__c redeemedProduct : redeemedProducts) {
            for (Integer i =  RECORD_MAX_COUNT; i < products.size(); i++) {
                items.add(createRedeemedProductItem(redeemedProduct.Id, products.get(i).Id));
            }
        }
        insert items;
    }

    private static RedeemedProductItem__c createRedeemedProductItem(String parentId, String productId) {
        return new RedeemedProductItem__c(
            Product__c = productId,
            RedeemedProduct__c = parentId,
            Quantity__c = 1
        );
    }

    private static void createRedemptions(List<Redemption_Campaigns__c> campaigns, List<RedeemedProducts__c> redeemedProducts, String contactId) {
        List<Redemptions__c> redemptions = new List<Redemptions__c>();
        for (Integer i = 0; i < campaigns.size(); i++) {
            redemptions.add(createRedemption(campaigns.get(i), redeemedProducts.get(i).Id, contactId));
        }
        insert redemptions;
    }

    private static Redemptions__c createRedemption(Redemption_Campaigns__c campaign, String redeemedProductId, String contactId) {
        return new Redemptions__c(
            Name__c = contactId,
            Status__c = 'Submitted',
            Redemption_Campaign__c = campaign.Id,
            PurchasedProducts__c = campaign.PurchasedProducts__c,
            RedeemedProducts__c = redeemedProductId
        );
    }
}