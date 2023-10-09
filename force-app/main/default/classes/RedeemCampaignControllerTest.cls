@isTest
public without sharing  class RedeemCampaignControllerTest {
    private static final Integer GRACE_PERIOD = 15;
    private static final Integer RECORD_MAX_COUNT = 3;
    private static final String USERNAME = '1t4e7s8t3@yahoo.com.aeg';
    private static final String REFERRAL_CODE = 'raf001';

    @TestSetup
    static void setupData() {
        List<Contact> contacts = fetchContacts();
        List<Product2> products = createProducts();
        List<PurchasedProducts__c> purchasedProducts = createPurchasedProducts(products);
        List<RedeemableProducts__c> redeemableProducts = createRedeemableProducts(products);
        createRedemptionCampaigns(purchasedProducts, redeemableProducts);
        createRAFCase(contacts[0], contacts[1]);
        System.runAs(new User(Id = Userinfo.getUserId())) {
            createUsers(contacts);
        }
    }

    private static testMethod void createRedemptionMissingParamTest() {
        RedeemCampaignController controller;
        User referrer = [SELECT Id, ContactId FROM User WHERE Referral_Code__c = :REFERRAL_CODE LIMIT 1];
        Product2 product = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 1];
        Redemption_Campaigns__c campaign = [SELECT Id FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        Test.startTest();
            Test.setCurrentPage(Page.RedeemProductTemplate);
            ApexPages.currentPage().getParameters().put('ContactId', referrer.ContactId); 
            ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
            controller = new RedeemCampaignController(sc);
        Test.stopTest();
        System.assertEquals('Missing URL Parameters', controller.errorMessage, 'Successfully initiated controller with missing parameters(Token Id and ContactId');
    }

    private static testMethod void createRedemptionRandomTokenTest() {
        RedeemCampaignController controller;
        User referrer = [SELECT Id, ContactId FROM User WHERE Referral_Code__c = :REFERRAL_CODE LIMIT 1];
        Product2 product = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 1];
        Redemption_Campaigns__c campaign = [SELECT Id FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        Test.startTest();
            Test.setCurrentPage(Page.RedeemProductTemplate);
            ApexPages.currentPage().getParameters().put('ContactId', referrer.ContactId); 
            ApexPages.currentPage().getParameters().put('TokenId', 'abcd'); 
            ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
            controller = new RedeemCampaignController(sc);
        Test.stopTest();
        System.assertEquals('Token not found', controller.errorMessage, 'Successfully initiated controller with random token');
    }

    private static testMethod void createRedemptionTest() {
        User referrer = [SELECT Id, ContactId FROM User WHERE Referral_Code__c = :REFERRAL_CODE LIMIT 1];
        Product2 product = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 1];
        Redemption_Campaigns__c campaign = [SELECT Id FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        Case claim = [SELECT Id, ContactId, TTI_Customer_Contact_email__c, Used_referral_Code__c, Approve_Reject__c, Case_Encrypted_Id__c FROM Case WHERE Case_Encrypted_Id__c = 'qwetqw326534erhtru6535' LIMIT 1];
        Test.startTest();
            Test.setCurrentPage(Page.RedeemProductTemplate);
            ApexPages.currentPage().getParameters().put('ContactId', referrer.ContactId); 
            ApexPages.currentPage().getParameters().put('TokenId', claim.Case_Encrypted_Id__c); 
            ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
            RedeemCampaignController controller = new RedeemCampaignController(sc);
            controller.selectedProduct = product;
            controller.createRedemptionRecord();
        Test.stopTest();
        List<Redemptions__c> redemptions = [SELECT Id, Name, Case__c FROM Redemptions__c WHERE Case__c = :claim.id];
        System.assertEquals(1, redemptions.size(), 'Failed to create redemptions');
    }

    private static testMethod void createDuplicateRedemptionTest() {
        RedeemCampaignController controller;
        User referrer = [SELECT Id, ContactId FROM User WHERE Referral_Code__c = :REFERRAL_CODE LIMIT 1];
        Product2 product = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 1];
        Redemption_Campaigns__c campaign = [SELECT Id FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        Case claim = [SELECT Id, ContactId, TTI_Customer_Contact_email__c, Used_referral_Code__c, Approve_Reject__c, Case_Encrypted_Id__c FROM Case WHERE Case_Encrypted_Id__c = 'qwetqw326534erhtru6535' LIMIT 1];
        insert new Redemptions__c(Case__c = claim.Id, Name__c = referrer.ContactId, Redemption_Campaign__c = campaign.Id);
        Test.startTest();
            Test.setCurrentPage(Page.RedeemProductTemplate);
            ApexPages.currentPage().getParameters().put('ContactId', referrer.ContactId); 
            ApexPages.currentPage().getParameters().put('TokenId', claim.Case_Encrypted_Id__c); 
            ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
            controller = new RedeemCampaignController(sc);
            controller.selectedProduct = product;
            controller.createRedemptionRecord();
        Test.stopTest();
        System.assertEquals('You have already redeemed a product using the link.', controller.errorMessage, 'Created duplicate redemption');
    }

    private static List<Contact> fetchContacts() {
        List<Account> accounts = createAccounts();
        List<Contact> contacts = [SELECT Id, Firstname, LastName, Brand__c, Email, Country__c FROM Contact WHERE AccountId IN :accounts];
        for (Contact contact: contacts) {
            contact.Email = 'test@mailinator.com';
            contact.Country__c = 'Australia';
            contact.Brand__c = 'AEG';
        }
        update contacts;
        return contacts;
    }
    
    /**
     * There is an existing issue wherein we can't use a bulk
     * insert of accounts due to a batch job running in the background.
     * 
     * Error: System.UnexpectedException: No more than one executeBatch 
     * can be called from within a test method. Please make sure the iterable 
     * returned from your start method matches the batch size, resulting in one 
     * executeBatch invocation.
     * 
     * Solution: Insert one record at a time
     * 
     * Reference: https://www.infallibletechie.com/2015/11/systemunexpectedexception-no-more-than.html
     */
    private static List<Account> createAccounts() {
        List<Account> accounts = TestUtilityClass.createPersonAccount(2);
        for(Account act: accounts) {
            act.Brands__c = 'AEG';
        }
        
        insert accounts[0];
        insert accounts[1];
        return accounts;
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
            Redemption_Type__c = 'External',
            RAF__c = true
        );
    }

    private static void createUsers(List<Contact> contacts) {
        String uniqueId = String.valueOf(System.now().getTime());
        Profile profile = [SELECT Id FROM Profile WHERE Name = '~Customer Community AEG' LIMIT 1];
        List<User> users = new List<User>();
        for (Integer i = 0; i < contacts.size(); i++) {
            users.add(createUser(contacts[i].Id, profile.Id, i));
        }
        insert users;
    }

    private static User createUser(String contactId, String profileId, Integer index) {
        String uniqueId = String.valueOf(System.now().getTime());
        User user = new User(
            ProfileId = profileId,
            Username = 'user-'+ uniqueId + '@test.com.aeg',
            Alias = 'user' + uniqueId.substring(0, 4),
            Email = 'user-'+ uniqueId + '@test.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'User' + uniqueId,
            Lastname = 'User' + uniqueId,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            ContactId = contactId,
            Country = 'Australia',
            Referral_Code__c = 'raf00' + index
        );
        return user;
    }

    private static void createRAFCase(Contact referrer, Contact referred) {
        Id rafCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Refer a Friend cases').getRecordTypeId();
        Case claim = new Case();
        claim.ContactId = referred.Id;
        claim.RecordTypeId = rafCaseRecTypeId;
        claim.Brand__c = 'AEG';
        claim.Used_referral_Code__c = REFERRAL_CODE;   
        claim.Referred_By__c = referrer.id;
        claim.FirstName__c = referred.FirstName;
        claim.LastName__c = referred.LastName;
        claim.TTI_Customer_Contact_email__c = referred.Email;
        claim.Priority = 'Medium';
        claim.Status = 'New';
        claim.Subject = 'Case RAF Test';
        claim.Case_Encrypted_Id__c = 'qwetqw326534erhtru6535';
        insert claim;
    }
}