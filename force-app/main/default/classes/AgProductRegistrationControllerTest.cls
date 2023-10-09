/**
 * @author Francis Nasalita
 * @date 2020-06-02
 *
 * @group Aeg Community
 * @group-content ../../ApexDocContent/aeg-community.html
 *
 * @description AEG Product Registration test class
 **/
@isTest
public class AgProductRegistrationControllerTest {   

    private static final String USERNAME = '1t4e7s8t3@yahoo.com.aeg';
    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id inPackPromoMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('In Pack Promo').getRecordTypeId();

    @testSetup
    private static void testSetup() {
        Integer counter = 0;
        createCommunitySettings();
        Account account = getAccount();
        SerialNumberDisplayType__c serialNumberDisplayType = getSerialNumberDisplayType();
        Contact contact = [SELECT Id, Country__c FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        createReceipt(account.Id);
        createProducts(serialNumberDisplayType.Id);
        createContentVersion();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            createPortalUser(contact.Id);
        }
    }

    

    /**********************************************************************
     * @description     Register product
     */
    @isTest
    static void saveProductRegistrationTest() {
        AgProductRegistrationController.saveProductRegistrationResult result;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Asset asset = createAsset(product.Id, account.Id, portalUser.ContactId);
        Test.startTest();
            System.runAs(portalUser) {
                result = AgProductRegistrationController.saveProductRegistration(new List<Asset> {asset}, 'Yes', 'TestFile', 'ProdCode1', true, null, 'Bunnings');
            }
        Test.stopTest();
        System.assert(String.isNotBlank(result.assetId), 'Did not register product');
    }

    /**********************************************************************
     * @description     Register product
     */
    @isTest
    static void saveProductRegistrationWithContentDocumentIdTest() {
        AgProductRegistrationController.saveProductRegistrationResult result;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        ContentDocument document = [SELECT Id FROM ContentDocument LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Asset asset = createAsset(product.Id, account.Id, portalUser.ContactId);
        Test.startTest();
            System.runAs(portalUser) {
                result = AgProductRegistrationController.saveProductRegistration(new List<Asset> {asset}, 'Yes', 'TestFile', 'ProdCode1', true, document.Id, 'Bunnings');
            }
        Test.stopTest();
        System.assert(String.isNotBlank(result.assetId), 'Did not register product');
    }

    /**********************************************************************
     * @description     Register product
     */
    @isTest
    static void saveProductRegistrationNonPortalUserTest() {
        String error;
        AgProductRegistrationController.saveProductRegistrationResult result;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Asset asset = createAsset(product.Id, account.Id, portalUser.ContactId);
        Test.startTest();
            result = AgProductRegistrationController.saveProductRegistration(new List<Asset> {asset}, 'Yes', 'TestFile', 'ProdCode1', true, null, 'Bunnings');
        Test.stopTest();
        //RD System.assertEquals('This user is not permitted to register tools.', result.message, 'Successfully registered a product');
    }

    /**********************************************************************
     * @description     Update registered product
     */
    @isTest
    static void updateProductRegistrationTest() {
        AgProductRegistrationController.saveProductRegistrationResult result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        Receipts__c exReceipt = [SELECT Id FROM Receipts__c WHERE Account__c = :exAccount.Id LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];

        List<Product2> exProdsList = [SELECT Id FROM Product2 LIMIT 2];

        Asset newAsset = TestUtilityClass.createAsset(1, exAccount.Id, portalUser.ContactId, exProdsList.get(0).Id)[0];
        newAsset.Standard_Warranty_Months__c = 48;
        newAsset.Extended_Warranty_Months__c = 24;
        newAsset.AssetSource__c = 'Retailer - Bunnings';
        newAsset.Receipt__c = exReceipt.Id;
        Test.startTest();
            System.runAs(portalUser) {
                insert newAsset;
                result = AgProductRegistrationController.updateProductRegistration(newAsset, 'Yes', 'NoFile');
            }
        Test.stopTest();
        System.assertEquals(exReceipt.Id, result.receiptID, 'Did not update product');
    }

    /**********************************************************************
     * @description     Fetch Community and Site Setting
     */
    @isTest
    static void getSiteTest() {
        Community_Setting__mdt commSetting;
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Test.startTest();
            System.runAs(portalUser) {
                commSetting = AgProductRegistrationController.getSiteSettings();
            }
        Test.stopTest();
        System.assert(commSetting != null, 'Community Setting not found');
    }

    /**********************************************************************
     * @description     Remove content document via Id
     */
    @isTest
    private static void removeContentDocumentsSingleTest() {
        List<ContentDocument> eContentDocumentsList = [SELECT Id FROM ContentDocument];
        Test.startTest();
            AgProductRegistrationController.removeContentDocuments(eContentDocumentsList.get(0).Id, false);
        Test.stopTest();
        eContentDocumentsList = [SELECT Id FROM ContentDocument WHERE Id = :eContentDocumentsList.get(0).Id];
        System.assert(eContentDocumentsList.isEmpty(), 'Failed to remove content document');

    }

    /**********************************************************************
     * @description     Remove content document in bulk
     */
    @isTest
    private static void removeContentDocumentsBulkTest() {
        Test.startTest();
            AgProductRegistrationController.removeContentDocuments(null, true);
        Test.stopTest();
        List<ContentDocumentLink> eConDocLinksList = [SELECT Id, 
                                                             ContentDocumentId 
                                                      FROM ContentDocumentLink 
                                                      WHERE LinkedEntityId = :UserInfo.getUserId()];
        System.assert(eConDocLinksList.isEmpty(), 'Failed to remove all content documents related to user');

    }    

    /**********************************************************************
     * @description     Create attachment from content document record
     */
    @isTest
    private static void convertContentDocumentToAttachmentTest() {
        ContentDocument eContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];
        Receipts__c eReceipt = [SELECT Id FROM Receipts__c LIMIT 1];
        Test.startTest();
            AgProductRegistrationController.convertContentDocumentToAttachment(eReceipt.Id, eContentDocument.Id);
        Test.stopTest();
        Attachment eAttachment = [SELECT Id FROM Attachment WHERE ParentId = :eReceipt.Id LIMIT 1];
        System.assert(eAttachment != null, 'Failed to create attachment record');
    }

    /**********************************************************************
     * @description     Fetch purchase value from custom metadata
     */
    @isTest
    private static void fetchPurchaseFromValuesTest() {
        String res;
        Test.startTest();
            res = AgProductRegistrationController.fetchPurchaseFromValues();
        Test.stopTest();
        List<Purchased_Brand_Mapping__mdt> valuesList = (List<Purchased_Brand_Mapping__mdt>)JSON.deserialize(res, List<Purchased_Brand_Mapping__mdt>.class);
        System.assert(!valuesList.isEmpty(), 'Picklist value do not exist');
    }


    private static void createCommunitySettings() {
        List<Community_Settings__c> settings = new List<Community_Settings__c>{
            getCommonSettings(),
            getBrandSettings()
        };
        insert settings;
    }

    private static Community_Settings__c getCommonSettings() {
        Community_Settings__c settings = new Community_Settings__c();
        settings.Name = 'CommonSettings';
        settings.ToolboxDisplayStatus__c = 'Confirmed';
        settings.RecieptSourceMapping__c  = 'Bunnings;Bunnings;Other;Other';
        settings.PurchasedFromMapping__c  = 'Bunnings;Retailer - Bunnings;Other;Retailer - Other';
        settings.RemoveReasonMapping__c = 'I sold the tool;Sold;My tool was replaced;Replaced;'
                                            + 'My tool was refunded;Refunded;MyTool was stolen;Stolen;'
                                            + 'My tool broke;Faulty; gave my tool away as a gift;Gifted;'
                                            + 'Incorrect product selected;Incorrect;Other reason;Other';
        return settings;
    }

    private static Community_Settings__c getBrandSettings() {
        Community_Settings__c settings = new Community_Settings__c();
        settings.Name = 'myAEG';
        settings.Brand__c = 'AEG';
        settings.ProductBrand__c = 'AG';
        settings.Australia_Country__c = 'Australia';
        settings.Lead_Source__c = 'MYAEG';
        settings.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        return settings;
    }

    private static Account getAccount() {
        Parent_Contact__c parentContact = getParentContact();
        Account account = TestUtilityClass.createPersonAccount(1)[0];
        account.ParentContact__c = parentContact.Id;
        insert account;
        return account;
    }

    private static Parent_Contact__c getParentContact() {
        Parent_Contact__c parentContact = new Parent_Contact__c();
        parentContact.Name = 'Test';
        insert parentContact;
        return parentContact;
    }

    private static void createReceipt(String accountId) {
        Receipts__c receipt = new Receipts__c(ReceiptSource__c = 'Other', 
                                              Account__c = accountId);
        insert receipt;
    }

    private static SerialNumberDisplayType__c getSerialNumberDisplayType() {
        SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
        snType.Name = 'Test';
        snType.Serial_Number_Length__c = 10;
        snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
        snType.IsDefault__c = true;
        snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
        insert snType;
        return snType;
    }

    private static void createProducts(String snDisplayTypeId) {
        Integer max = 2;
        List<Product2> products = TestUtilityClass.createProduct(max);
        for (Integer i = 0; i < 2; i++) {
            Product2 product = products[i];
            product.SerialNumberDisplayType__c = snDisplayTypeId;
            product.Brand__C = 'AG';
            product.ProductCode = 'ProdCode-' + i;
            product.Category_customer_level1__c = 'Power Tools';
            product.Kit__c = true;
            product.Standard_Warranty_Months__c = 24;
            product.Standard_Warranty_Previous_Months__c = 24;
        }
        insert products;
    }

    private static void createContentVersion() {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'TestContent';
        contentVersion.VersionData = Blob.valueOf('Test Content Data');
        contentVersion.IsMajorVersion = true;
        contentVersion.PathOnClient = 'TestContent.jpg';
        insert contentVersion;
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

    private static Asset createAsset(String productId, String accountId, String contactId) {
        Asset asset = TestUtilityClass.createAsset(1, accountId, contactId, productId)[0];
        asset.Standard_Warranty_Months__c = 48;
        asset.Extended_Warranty_Months__c = 24;
        asset.AssetSource__c = 'Retailer - Bunnings';
        asset.KitProduct__c = productId;
        asset.PurchaseDate = System.today() - 1;
        asset.Receipt_No__c = '123456';
        asset.WarrantyCalculationOverride__c = true;
        asset.Redeemed__c = false;
        return asset;
    }
}