@isTest
public class ProductDetailCCTest {

    private static final String USERNAME = '1t4e7s8t3@yahoo.com.Ryobi';

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id inPackPromoMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('In Pack Promo').getRecordTypeId();

    @testSetup
    private static void testSetup() {
        Integer counter = 0;
        List<Community_Settings__c> newCommSettings = new List<Community_Settings__c>();

        //Community Custom Settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Name = 'CommonSettings';
        cs.ToolboxDisplayStatus__c = 'Confirmed';
        cs.RecieptSourceMapping__c  = 'Bunnings;Bunnings;Other;Other';
        cs.PurchasedFromMapping__c  = 'Bunnings;Retailer - Bunnings;Other;Retailer - Other';
        cs.RemoveReasonMapping__c = 'I sold the tool;Sold;My tool was replaced;Replaced;'
                                     + 'My tool was refunded;Refunded;MyTool was stolen;Stolen;'
                                     + 'My tool broke;Faulty; gave my tool away as a gift;Gifted;'
                                     + 'IIncorrect product selected;Incorrect;Other reason;Other';
        newCommSettings.add(cs);

        cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.ProductBrand__c = 'RY';
        cs.Australia_Country__c = 'Australia';
        cs.Name = 'myRyobi';
        cs.Lead_Source__c = 'MYRYOBI';
        cs.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        newCommSettings.add(cs);

        cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.ProductBrand__c = 'AG';
        cs.Australia_Country__c = 'Australia';
        cs.Name = 'myAEG';
        cs.Lead_Source__c = 'MYAEG';
        cs.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        newCommSettings.add(cs);

        insert newCommSettings;


        Parent_Contact__c newParentCont = new Parent_Contact__c();
        newParentCont.Name = 'Test';
        insert newParentCont;

        Account newAccount = TestUtilityClass.createPersonAccount(1)[0];
        newAccount.ParentContact__c = newParentCont.Id;
        insert newAccount;

        Receipts__c newReceipt = new Receipts__c(ReceiptSource__c = 'Other', Account__c = newAccount.Id);
        insert newReceipt;

        Contact exCont =  [SELECT Id,
                           Country__c
                           FROM Contact
                           WHERE AccountID = :newAccount.Id];

        SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
        snType.Name = 'Test';
        snType.Serial_Number_Length__c = 10;
        snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
        snType.IsDefault__c = true;
        snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
        insert snType;

        List<Product2> newProdsList = TestUtilityClass.createProduct(2);
        for (Product2 nProd : newProdsList) {
            nProd.SerialNumberDisplayType__c = snType.Id;
            nProd.Brand__C = 'RY';
            nProd.ProductCode = 'ProdCode-' + counter;
            nProd.Category_customer_level1__c = 'Power Tools';
            nProd.Kit__c = true;
            nProd.Standard_Warranty_Months__c = 24;
            nProd.Standard_Warranty_Previous_Months__c = 24;
        }
        insert newProdsList;

        // Create content version document
        ContentVersion nContentVersion = new ContentVersion();
        nContentVersion.Title = 'TestContent';
        nContentVersion.VersionData = Blob.valueOf('Test Content Data');
        nContentVersion.IsMajorVersion = true;
        nContentVersion.PathOnClient = 'TestContent.jpg';
        insert nContentVersion;

        Profile cspLitePortalProfile = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User portalUser = new User(
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
                ContactId = exCont.Id,
                Country = 'Australia'
            );
            insert portalUser;
        }
    }
    
    @isTest
    static void getHostUrlTest() {
        String result;
        Test.startTest();
            result = ProductDetailCC.getHostUrl();
        Test.stopTest();
        System.assertEquals(Label.BVPixelSite, result, 'Host URL not found');
    }

    /**********************************************************************
     * @description     Register product
     */
    @isTest
    static void saveProductRegistrationTest() {
        ProductDetailCC.saveProductRegistrationResult result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> exProdsList = [SELECT Id FROM Product2 LIMIT 2];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];

        Asset newAsset = TestUtilityClass.createAsset(1, exAccount.Id, portalUser.ContactId, exProdsList.get(0).Id)[0];
        newAsset.Standard_Warranty_Months__c = 48;
        newAsset.Extended_Warranty_Months__c = 24;
        newAsset.AssetSource__c = 'Retailer - Bunnings';
        newAsset.KitProduct__c = exProdsList.get(0).Id;
        newAsset.PurchaseDate = System.today() - 1;
        newAsset.Receipt_No__c = '123456';
        newAsset.WarrantyCalculationOverride__c = true;
        newAsset.Redeemed__c = false;

        Test.startTest();
            System.runAs(portalUser) {
                result = ProductDetailCC.saveProductRegistration(new List<Asset> {newAsset}, 'Yes', 'TestFile', 'ProdCode1', true);
            }
        Test.stopTest();
        System.assert(String.isNotBlank(result.assetId), 'Did not register product');
    }

    /**********************************************************************
     * @description     Register product using internal user
     */
    @isTest
    static void saveProductRegistrationInternalNegativeTest() {
        ProductDetailCC.saveProductRegistrationResult result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> exProdsList = [SELECT Id, Standard_Warranty_Months__c FROM Product2 LIMIT 2];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];

        for (Product2 exProd : exProdsList) {
            exProd.Standard_Warranty_Months__c = null;
        }
        update exProdsList;

        Asset newAsset = TestUtilityClass.createAsset(1, exAccount.Id, portalUser.ContactId, exProdsList.get(0).Id)[0];
        newAsset.Standard_Warranty_Months__c = 48;
        newAsset.Extended_Warranty_Months__c = 24;
        newAsset.AssetSource__c = 'Retailer - Bunnings';
        newAsset.KitProduct__c = exProdsList.get(0).Id;
        newAsset.PurchaseDate = System.today();
        newAsset.Receipt_No__c = '123456';
        newAsset.WarrantyCalculationOverride__c = true;
        newAsset.Redeemed__c = false;

        Test.startTest();
            result = ProductDetailCC.saveProductRegistration(new List<Asset> {newAsset}, 'Yes', 'TestFile', 'ProdCode1', true);
        Test.stopTest();
        System.assertEquals(ProductDetailCC.ERROR_USER_CANNOT_REGISTER, result.message, 'Community is enabled to the user');
    }

    /**********************************************************************
     * @description     Update registered product
     */
    @isTest
    static void updateProductRegistrationTest() {
        ProductDetailCC.saveProductRegistrationResult result;
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
                result = ProductDetailCC.updateProductRegistration(newAsset, 'Yes', 'NoFile', 'Bunnings');
            }
        Test.stopTest();
        System.assertEquals(exReceipt.Id, result.receiptID, 'Did not update product');
    }

    /**********************************************************************
     * @description     Update registered product without standard
     *                  warranty
     */
    @isTest
    static void updateProductRegistrationNegativeTest() {
        ProductDetailCC.saveProductRegistrationResult result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        Receipts__c exReceipt = [SELECT Id FROM Receipts__c WHERE Account__c = :exAccount.Id LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];

        List<Product2> exProdsList = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 exProd : exProdsList) {
            exProd.Standard_Warranty_Months__c = null;
        }
        update exProdsList;

        Asset newAsset = TestUtilityClass.createAsset(1, exAccount.Id, portalUser.ContactId, exProdsList.get(0).Id)[0];
        newAsset.Standard_Warranty_Months__c = null;
        newAsset.Extended_Warranty_Months__c = 24;
        newAsset.AssetSource__c = 'Retailer - Bunnings';
        newAsset.Receipt__c = exReceipt.Id;
        insert newAsset;

        Test.startTest();
            System.runAs(portalUser) {
                result = ProductDetailCC.updateProductRegistration(newAsset, 'Yes', 'NoFile', 'Bunnings');
            }
        Test.stopTest();
        System.assert(result.error, 'Successfully updated product');
    }

    /**********************************************************************
     * @description     Login as internal user and update registered
     *                  product
     */
    @isTest
    static void updateProductRegistrationInternalNegativeTest() {
        ProductDetailCC.saveProductRegistrationResult result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        Receipts__c exReceipt = [SELECT Id FROM Receipts__c WHERE Account__c = :exAccount.Id LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];

        List<Product2> exProdsList = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 exProd : exProdsList) {
            exProd.Standard_Warranty_Months__c = null;
        }
        update exProdsList;

        Asset newAsset = TestUtilityClass.createAsset(1, exAccount.Id, portalUser.ContactId, exProdsList.get(0).Id)[0];
        newAsset.Standard_Warranty_Months__c = 48;
        newAsset.Extended_Warranty_Months__c = 24;
        newAsset.AssetSource__c = 'Retailer - Bunnings';
        newAsset.Receipt__c = exReceipt.Id;
        insert newAsset;

        Test.startTest();
            result = ProductDetailCC.updateProductRegistration(newAsset, 'Yes', 'NoFile', 'Bunnings');
        Test.stopTest();
        System.assertEquals(ProductDetailCC.ERROR_USER_CANNOT_REGISTER, result.message, 'Community is enabled to the user');
    }

    /**********************************************************************
     * @description     Insert an attachment on registered product
     *                  (e.g. receipt)
     */
    @isTest
    static void saveFileTest() {
        String attachmentId;
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
                attachmentId = ProductDetailCC.saveFile(newAsset.Id, 'DemoFile', 'FileTest', 'text/plain');
            }
        Test.stopTest();
        System.assert(String.isNotBlank(attachmentId), 'Create attachment failed');
    }

    /**********************************************************************
     * @description     Insert an attachment on registered product
     *                  (e.g. receipt) and append the said attachment
     */
    @isTest
    static void saveFileChunkTest() {
        String attachmentId;
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
                attachmentId = ProductDetailCC.saveFileChunk(newAsset.Id,
                               'DemoFile',
                               'FileTest',
                               'textPlain',
                               '');
                System.assert(String.isNotBlank(attachmentId), 'Create attachment failed');

                attachmentId = ProductDetailCC.saveFileChunk(newAsset.Id,
                               'DemoFile',
                               'FileTestAppend',
                               'textPlain',
                               attachmentId);
            }
        Test.stopTest();
        System.assert(String.isNotBlank(attachmentId), 'Update attachment failed');

    }

    /**********************************************************************
     * @description     Insert an attachment on registered product
     *                  and get attachment record id
     */
    @isTest
    static void getFileIdTest() {
        String result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        Receipts__c exReceipt = [SELECT Id FROM Receipts__c WHERE Account__c = :exAccount.Id LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Test.startTest();
            System.runAs(portalUser) {
                ProductDetailCC.saveFile(exReceipt.Id, 'DemoFile', 'FileTest', 'text/plain');
                result = ProductDetailCC.getFileId(exReceipt.Id);
            }
        Test.stopTest();
        System.assert(String.isNotBlank(result), 'Attachment not found');
    }

    /**********************************************************************
     * @description     Negative test in fetching attachment record for the
     *                  the receipt
     */
    @isTest
    static void getFileIdNegativeTest() {
        String result;
        Account exAccount = [SELECT Id FROM Account LIMIT 1];
        Receipts__c exReceipt = [SELECT Id FROM Receipts__c WHERE Account__c = :exAccount.Id LIMIT 1];
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Test.startTest();
            System.runAs(portalUser) {
                try {
                    result = ProductDetailCC.getFileId(exReceipt.Id);
                } catch (Exception ex) {}
            }
        Test.stopTest();
        System.assert(String.isBlank(result), 'Attachment exists');
    }

    /**********************************************************************
     * @description     Fetch Community Setting
     */
    @isTest
    static void getCommunitySettingTest() {
        Community_Settings__c commSetting;
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Test.startTest();
            System.runAs(portalUser) {
                commSetting = ProductDetailCC.getCommunitySettings();
            }
        Test.stopTest();
        System.assert(commSetting != null, 'Community Setting not found');
    }

    /**********************************************************************
     * @description     Fetch Community and Site Setting
     */
    @isTest
    static void getSiteTest() {
        CommunitySettingsHelperClass.SiteSettingsResult commSetting;
        User portalUser = [SELECT Id, ContactId FROM User WHERE Username = :USERNAME LIMIT 1];
        Test.startTest();
            System.runAs(portalUser) {
                commSetting = ProductDetailCC.getSiteSettings();
            }
        Test.stopTest();
        System.assert(commSetting != null, 'Community Setting not found');
    }

    /**********************************************************************
     * @description     insert user's survey answers and check if survey is completed
     */
    @isTest
    static void myRyobiCustomerSurveyModal_SurveyCompleted() {        

        Account personAccount = TestUtilityClass.createPersonAccount(1)[0];
        personAccount.PersonEmail = 'test.account@testing.com';
        personAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        
        insert personAccount;

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :personAccount.Id LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi'];

        User portalUser = new User();
        portalUser.Username = personAccount.PersonEmail + '.tst';
        portalUser.Email = personAccount.PersonEmail;
        portalUser.CommunityNickname = 'Cardo';
        portalUser.ContactId = personContact.Id;
        portalUser.ProfileId = portalProfile.Id;
        portalUser.Alias = 'Cardo123';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LastName = personAccount.LastName;
        portalUser.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';
        
        insert portalUser;
        
        Test.startTest();
        
        String resultMsg = ProductDetailCC.saveSurvey(portalUser.Id, '2', '3', true);
        Account accountReturned = ProductDetailCC.getSurveyDetails(portalUser.Id);
        
        Test.stopTest();        
        
        System.assertEquals('SUCCESS', resultMsg, 'Saving of record not successful.');        
        System.assertEquals('2', accountReturned.DIY_Enjoyment__c, 'Answer in DIY Enjoyment question is incorrect.'); 
        System.assertEquals('3', accountReturned.Confidence_in_Power_Tools__c, 'Answer in Confidence in Power Tools question is incorrect.');
        System.assertEquals(true, accountReturned.Is_survey_completed__c, 'Survey was not completed.');
    }

    /**********************************************************************
     * @description     Remove content document via Id
     */
    @isTest
    private static void removeContentDocumentsSingleTest() {
        List<ContentDocument> eContentDocumentsList = [SELECT Id FROM ContentDocument];
        Test.startTest();
            ProductDetailCC.removeContentDocuments(eContentDocumentsList.get(0).Id, false);
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
            ProductDetailCC.removeContentDocuments(null, true);
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
        String res;
        ContentDocument eContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];
        Receipts__c eReceipt = [SELECT Id FROM Receipts__c LIMIT 1];
        Test.startTest();
            res = ProductDetailCC.convertContentDocumentToAttachment(eReceipt.Id, eContentDocument.Id);
        Test.stopTest();
        Attachment eAttachment = [SELECT Id FROM Attachment WHERE ParentId = :eReceipt.Id LIMIT 1];
        System.assertEquals(eAttachment.Id , res, 'Failed to create attachment record');
    }


    /**********************************************************************
     * @description     Negative testing in creating attachment from 
     *                  content document record
     */
    @isTest
    private static void convertContentDocumentToAttachmentNegativeTest() {
        String res;
        Test.startTest();
            res = ProductDetailCC.convertContentDocumentToAttachment(null, null);
        Test.stopTest();
        System.assert(String.isBlank(res), 'Successfully created attachment record');
    }

    /**********************************************************************
     * @description     Fetch purchase value from custom metadata
     */
    @isTest
    private static void fetchPurchaseFromValuesTest() {
        String res;
        Test.startTest();
            res = ProductDetailCC.fetchPurchaseFromValues();
        Test.stopTest();
        List<Purchased_Brand_Mapping__mdt> valuesList = (List<Purchased_Brand_Mapping__mdt>)JSON.deserialize(res, List<Purchased_Brand_Mapping__mdt>.class);
        System.assert(!valuesList.isEmpty(), 'Picklist value do not exist');
    }

}