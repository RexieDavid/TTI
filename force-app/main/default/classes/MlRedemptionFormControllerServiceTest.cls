/**
 * @author                          Kristopher Veraces
 * @date                            2020-10-26
 *
 * @group                           Milwaukee Community
*/
@isTest
private class MlRedemptionFormControllerServiceTest {
    private static final MlRedemptionFormControllerService SERVICE = new MlRedemptionFormControllerService();
    private static final String USERNAME = '1t4e7s8t3@yahoo.com.Milwaukee';
    private static final String ASSET_ID_REQUIRED = 'Asset record Ids are required.';
    private static final String CONTENT_DOCUMENT_ID_REQUIRED = 'Content Document record Id is required.';
    private static final String FILTER_REQUIRED = 'Filter is required.';
    private static final String MASTER_LABEL_REQUIRED = 'Master Label is required.';
    private static final String SOBJECT_REQUIRED = 'SObject record is required.';
    private static final Integer RECORD_COUNT = 3;

    @TestSetup
    static void makeData() {
        insert fetchMockContentVersion();
        createRedeemableProducts(); 
        createPurchasedProducts();
    }

    /**********************************************************************
     * @description                 Fetch contact record related to
     *                              current user
     */
    @isTest
    private static void getPersonAccountDetails() {
        Contact contact;
        Test.startTest();
            System.runAs(fetchMockPortalUser()) {
                String result = SERVICE.getPersonAccountDetails();
                contact = (Contact)JSON.deserialize(result, Contact.class);
            }
        Test.stopTest();
        System.assert(contact != null, 'Failed to fetch contact records');
    }

    /**********************************************************************
     * @description                 Fetch specific site settings in custom
     *                              metadata with master label
     */
    @isTest
    private static void getSiteSettings() {
        String masterLabel = 'OneKey Portal';
        Community_Setting__mdt settings;
        Test.startTest();
            settings = SERVICE.getSiteSettings(masterLabel);
        Test.stopTest();
        System.assertEquals(masterLabel, settings.MasterLabel,  'Failed to fetch custom settings metadata');
    }

    /**********************************************************************
     * @description                 Fetch specific site settings in custom
     *                              metadata without master label
     */
    @isTest
    private static void getSiteSettingsWithoutMasterLabel() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.getSiteSettings(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(MASTER_LABEL_REQUIRED, errMessage,  'Successfully fetch custom settings metadata');
    }

    /**********************************************************************
     * @description                 Upsert account record
     */
    @isTest
    private static void upsertRecord() {
        Account account =  MILTestUtilityClass.createPersonAccount(1)[0];
        String recordId;
        Test.startTest();
            recordId = SERVICE.upsertRecord(account);
        Test.stopTest();
        System.assert(String.isNotBlank(recordId), 'Failed to upsert record');
    }

    /**********************************************************************
     * @description                 Upsert account records
     */
    @isTest
    private static void upsertRecords() {
        SObject account = (SObject) MILTestUtilityClass.createPersonAccount(1)[0];
        List<String> recordIds;
        Test.startTest();
            recordIds = SERVICE.upsertRecords(new List<SObject>{ account });
        Test.stopTest();
        System.assert(!recordIds.isEmpty(), 'Failed to upsert record');
    }

    /**********************************************************************
     * @description                 Upsert null/empty record
     */
    @isTest
    private static void upsertNullRecord() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.upsertRecord(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(SOBJECT_REQUIRED, errMessage,  'Failed upsert record');
    }

    /**********************************************************************
     * @description                 Fetch Content Version using content
     *                              document Id
     */
    @isTest
    private static void fetchContentVersion() {
        ContentVersion cv;
        ContentDocument cd = [SELECT Id FROM ContentDocument];
        Test.startTest();
            cv = SERVICE.fetchContentVersion(cd.Id);
        Test.stopTest();
        System.assert(cv != null, 'Failed to fetch content version record');
    }

    /**********************************************************************
     * @description                 Fetch Content Version without content
     *                              document Id
     */
    @isTest
    private static void fetchContentVersionWithoutId() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.fetchContentVersion(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(CONTENT_DOCUMENT_ID_REQUIRED, errMessage,  'Successfully fetch content version record');
    }

    /**********************************************************************
     * @description                 Fetch content document with
     *                              record id
     */
    @isTest
    private static void fetchContentDocument() {
        ContentDocument currDocument;
        ContentDocument cd = [SELECT Id FROM ContentDocument];
        Test.startTest();
            currDocument = SERVICE.fetchContentDocument(cd.Id);
        Test.stopTest();
        System.assertEquals(cd.Id, currDocument.Id, 'Failed to fetch content document record');
    }

    /**********************************************************************
     * @description                 Fetch content document without
     *                              record id
     */
    @isTest
    private static void fetchContentDocumentWithoutId() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.fetchContentDocument(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(CONTENT_DOCUMENT_ID_REQUIRED, errMessage,  'Successfully fetch content document record');
    }

    /**********************************************************************
     * @description                 Delete all content documents that
     *                              have 'Test' in title
     */
    @isTest
    private static void deleteContentDocuments() {
        Test.startTest();
            SERVICE.deleteContentDocuments('%Test%');
        Test.stopTest();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        System.assert(contentDocuments.isEmpty(), 'Failed to delete content document records');
    }

    /**********************************************************************
     * @description                 Delete all content documents without
     *                              filter
     */
    @isTest
    private static void deleteContentDocumentsWithoutFilter() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.deleteContentDocuments(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(FILTER_REQUIRED, errMessage,  'Successfully deleted content document records');
    }

    @isTest
    private static void getPurchaseProductLineItems() {
        List<PurchasedProductLineItem__c> purchasedproductItems = new List<PurchasedProductLineItem__c>();

        Id redeemableProductsId = [SELECT Id FROM PurchasedProducts__c LIMIT 1].Id;

        Test.startTest();
            purchasedproductItems = SERVICE.getPurchaseProductLineItems(redeemableProductsId);
        Test.stopTest();

        System.assert(!purchasedproductItems.isEmpty(), 'No purchased product items found.');
    }

    private static void createPurchasedProducts() {
        PurchasedProducts__c purchasedProducts = new PurchasedProducts__c();
        insert purchasedProducts;

        List<PurchasedProductLineItem__c> purchasedProductItems = new List<PurchasedProductLineItem__c>();

        for (Integer counter = 0; counter < RECORD_COUNT; counter++) {
            purchasedProductItems.add(new PurchasedProductLineItem__c(
                PurchasedProduct__c = purchasedProducts.Id,
                Quantity__c = 1
            ));
        }

        insert purchasedProductItems;
    }

    @isTest
    private static void getRedeemableProducts() {
        List<RedeemableProductItem__c> redeemableProductsItems = new List<RedeemableProductItem__c>();

        Id redeemableProductsId = [SELECT Id FROM RedeemableProducts__c LIMIT 1].Id;

        Test.startTest();
            redeemableProductsItems = SERVICE.getRedeemableProducts(redeemableProductsId, false);
        Test.stopTest();

        System.assert(!redeemableProductsItems.isEmpty(), 'No redeemable product items found.');
    }

    private static void createRedeemableProducts() {
        RedeemableProducts__c redeemableProducts = new RedeemableProducts__c(
            RedeemType__c = 'All'
        );
        insert redeemableProducts;
        
        List<RedeemableProductItem__c> redeemableProductItems = new List<RedeemableProductItem__c>();

        for (Integer counter = 0; counter < RECORD_COUNT; counter++) {
            redeemableProductItems.add(new RedeemableProductItem__c(
                RedeemableProduct__c = redeemableProducts.Id,
                Quantity__c = 1
            ));
        }

        insert redeemableProductItems;
    } 

    /**********************************************************************
     * @description                 Create mock content version
     * 
     *                              Will perform an insert to database after
     *                              to prevent exceptions
     */
    private static ContentVersion fetchMockContentVersion() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestContent';
        cv.VersionData = Blob.valueOf('Test Content Data');
        cv.IsMajorVersion = true;
        cv.PathOnClient = 'TestContent.jpg';
        return cv;
    }

    /**********************************************************************
     * @description                 Create mock portal user
     * 
     *                              Will perform an insert to database after
     *                              to prevent exceptions
     */
    private static User fetchMockPortalUser() {
        User sysAdminUser = MyMilwaukeeTestDataFactory.createSystemAdminUser();
        insert sysAdminUser;

        User portalUser;
        System.runAs(sysAdminUser) {
            Account account = MILTestUtilityClass.createPersonAccount(1)[0];
            insert account;

            Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.Id];

            Profile cspLitePortalProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
            portalUser = new User(
                ProfileId = cspLitePortalProfile.Id,
                Username = USERNAME,
                Alias = 'batman',
                Email = 'test@yahoo.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ContactId = contact.Id,
                Country = 'Australia'
            );
        }

        return portalUser;
    }
}