@isTest //(seeAllData = true)
private class MilwaukeeRedemptionControllerTest {

    private static final PageReference MIL_REDEMPTION_PAGE = Page.MilwaukeeExternalRedemption;
    private static final Integer GRACE_PERIOD = 50;
    private static final String USERNAME = '1t4e7s8t3@yahoo.com.Milwaukee';

    /**********************************************************************
     * @description     Setup test data
     */
    @testSetup
    static void initData() {
        List<Asset> newAssetsList = new List<Asset>();
        List<Product2> newProductsList = new List<Product2>();
        List<Product_Kit__c> newProdKitsList = new List<Product_Kit__c>();
        List<Redemptions__c> newRedemptionsList = new List<Redemptions__c>();
        List<Community_Settings__c> newCommSettings = new List<Community_Settings__c>();
        List<Redemption_Campaigns__c> newRedCampsList = new List<Redemption_Campaigns__c>();

        Account newPersonAccount = TestUtilityClass.createPersonAccount(1)[0];
        insert newPersonAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        eContact.Brand__c = 'AEG';
        update eContact;

        //Insert Community Settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Name = 'CommonSettings';
        cs.ToolboxDisplayStatus__c = 'Confirmed';
        cs.RecieptSourceMapping__c  = 'Bunnings;Bunnings;Other;Other';
        cs.PurchasedFromMapping__c  = 'Bunnings;Retailer - Bunnings;Other;Retailer - Other';
        cs.RemoveReasonMapping__c = 'I sold the tool;Sold;My tool was replaced;Replaced;My tool was refunded;Refunded;MyTool was stolen;Stolen;My tool broke;Faulty;I gave my tool away as a gift;Gifted;Incorrect product selected;Incorrect;Other reason;Other';
        newCommSettings.add(cs);

        cs = new Community_Settings__c();
        cs.Name = 'myAEG';
        cs.Brand__c = 'AEG';
        cs.Lead_Source__c = 'MYAEG';
        cs.RedemptionGracePeriod__c = GRACE_PERIOD;
        cs.RedemptionSuccessURL__c = 'https://localhost:1010/success';
        cs.GTMCode__c = 'DemoGTM';
        newCommSettings.add(cs);

        insert newCommSettings;

        //Insert New product
        newProductsList = TestUtilityClass.createProduct(10);
        for (Integer index = 0; index < newProductsList.size(); index++ ) {
            newProductsList[index].ProductCode += String.valueOf(index);
            newProductsList[index].Name += String.valueOf(index);
            newProductsList[index].Customer_Facing_Name__c = 'Customer Name - ' + index;
            newProductsList[index].Kit__c = true;
        }
        insert newProductsList;


        for (Integer index = 0; index < newProductsList.size(); index += 2 ) {
            //Insert Redemption Campaign
            Redemption_Campaigns__c newRedCamp = createRedemptionCampaign('Camp-' + index, 'AEG', GlobalConstantUtility.ANZ, GRACE_PERIOD, newProductsList.get(index).Id, newProductsList.get(index + 1).Id);
            newRedCampsList.add(newRedCamp);

            //Create Asset for redemptions
            Asset newAsset = new Asset();
            newAsset.Product2Id = newProductsList.get(index).Id;
            newAsset.AccountId = newPersonAccount.Id;
            newAsset.ContactId = eContact.Id;
            newAsset.Name = 'Temporary Name-' + index;
            newAsset.Purchased_Online__c = 'In-Store';
            newAsset.PurchaseDate = System.today() - 1;
            newAssetsList.add(newAsset);

            //Insert Product Kit
            Product_Kit__c newProdKit = new Product_Kit__c();
            newProdKit.Kit__c = newProductsList.get(index).Id;
            newProdKit.Kit_Tool__c = newProductsList.get(index).Id;
            newProdKit.Quantity__c = 1;
            newProdKitsList.add(newProdKit);

        }
        insert newRedCampsList;
        insert newAssetsList;
        insert newProdKitsList;

        for (Integer index = 0; index < 5; index++ ) {
            Redemptions__c newRedemption = new Redemptions__c();
            newRedemption.Name__c = eContact.Id;
            newRedemption.Redemption_Campaign__c = newRedCampsList.get(index).Id;
            newRedemptionsList.add(newRedemption);
        }
        insert newRedemptionsList;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile cspLitePortalProfile = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
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
                ContactId = eContact.Id,
                Country = 'Australia'
            );
            insert portalUser;
        }
    }

    /**********************************************************************
     * @description     Fetch states from Australia State Metadata
     */
    @isTest
    static void getStateTest() {
        List<SelectOption> selectOptionsList = new List<SelectOption>();
        Test.startTest();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
                selectOptionsList = milRedCont.getStates();
            }
        Test.stopTest();
        System.assert(!selectOptionsList.isEmpty(), 'States not found');
    }

    /**********************************************************************
     * @description     Fetch Regions from New  Zealand Region Metadata
     */
    @isTest
    static void getRegionsTest() {
        List<SelectOption> selectOptionsList = new List<SelectOption>();
        Test.startTest();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
                selectOptionsList = milRedCont.getRegions();
            }
        Test.stopTest();
        System.assert(!selectOptionsList.isEmpty(), 'Regions not found');
    }

    /**********************************************************************
     * @description     Constructor test
     */
    @isTest
    static void milwaukeeRedemptionControllerTest() {
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id FROM Redemption_Campaigns__c];
        Test.startTest();
            Test.setCurrentPage(MIL_REDEMPTION_PAGE);
            ApexPages.currentPage().getParameters().put('redemption', exRedCampaignsList.get(0).Id);
            MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
        Test.stopTest();
        System.assertEquals(exRedCampaignsList.get(0).Id, milRedCont.selectedRedemption.Id, 'Redemption Campaign not found');
    }

    /**********************************************************************
     * @description     Fetch GTM code in community settings
     */

    @isTest
    static void getGtmCodeTest() {
        Community_Settings__c commSetting = Community_Settings__c.getValues('myAEG');
        String res;
        Test.startTest();
            Test.setCurrentPage(MIL_REDEMPTION_PAGE);
            MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
            res = milRedCont.getGtmCode();
        Test.stopTest();
        System.assertEquals(commSetting.GTMCode__c, res, 'GMT Code not match');
    }

    /**********************************************************************
     * @description     Submit Redemption 
     */
    @isTest
    static void submitFormTest() {
        PageReference pageRefRes;
        Community_Settings__c commSetting = Community_Settings__c.getValues('myAEG');
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id, Purchased_Product__r.ProductCode, Redeemed_Item__r.ProductCode FROM Redemption_Campaigns__c];

        Account personAccount = [SELECT Id,
                                        PersonContactId,
                                        PersonEmail,
                                        PersonMobilePhone,
                                        Phone,
                                        FirstName,
                                        LastName,
                                        MRAddressStreetNumber__c,
                                        MRAddressRoute__c,
                                        Company_Name__c
                                 FROM Account
                                 WHERE IsPersonAccount = TRUE
                                 LIMIT 1];

        Contact exContact = [SELECT Id, Country__c, Email FROM Contact WHERE Id = :personAccount.PersonContactId LIMIT 1];
        exContact.Country__c = 'Australia';
        exContact.Email = 'test@test.com';
        update exContact;

        Test.startTest();
            Test.setCurrentPage(MIL_REDEMPTION_PAGE);
            ApexPages.currentPage().getParameters().put('redemption', exRedCampaignsList.get(0).Id);
            MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
            milRedCont.newAccount = personAccount;
            milRedCont.newAttachment = createAttachment('DemoAttachment', null);
            milRedCont.selectedProductCode = exRedCampaignsList.get(0).Purchased_Product__r.ProductCode;
            milRedCont.selectedRedeemedProductCode = exRedCampaignsList.get(0).Redeemed_Item__r.ProductCode;
            pageRefRes = milRedCont.submitForm();
        Test.stopTest();
        System.assert(pageRefRes != null, 'Error on submition');
    }

    /**********************************************************************
     * @description     Negative testing for submission of redemption
     */
    @isTest
    static void submitFormNegativeTest() {
        PageReference pageRefRes;
        Community_Settings__c commSetting = Community_Settings__c.getValues('myAEG');
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id, Purchased_Product__r.ProductCode, Redeemed_Item__r.ProductCode FROM Redemption_Campaigns__c];

        Account personAccount = [SELECT Id,
                                        PersonContactId,
                                        PersonEmail,
                                        PersonMobilePhone,
                                        Phone,
                                        FirstName,
                                        LastName,
                                        MRAddressStreetNumber__c,
                                        MRAddressRoute__c,
                                        Company_Name__c
                                 FROM Account
                                 WHERE IsPersonAccount = TRUE
                                 LIMIT 1];

        Test.startTest();
            Test.setCurrentPage(MIL_REDEMPTION_PAGE);
            ApexPages.currentPage().getParameters().put('redemption', exRedCampaignsList.get(0).Id);
            MilwaukeeRedemptionController milRedCont = new MilwaukeeRedemptionController();
            milRedCont.newAccount = personAccount;
            milRedCont.selectedProductCode = exRedCampaignsList.get(0).Purchased_Product__r.ProductCode;
            milRedCont.selectedRedeemedProductCode = exRedCampaignsList.get(0).Redeemed_Item__r.ProductCode;
            pageRefRes = milRedCont.submitForm();
        Test.stopTest();
        System.assertEquals(null, pageRefRes, 'Successfully submitted the form');
    }

    /**********************************************************************
     * @description     Fetch Community Site Settings
     */
    @isTest
    static void getSiteSettingsTest() {
        CommunitySettingsHelperClass.SiteSettingsResult res;
        Test.startTest();
            res = MilwaukeeRedemptionController.getSiteSettings();
        Test.stopTest();
        System.assert(res != null, 'Community Setting not found');
    }

    /**********************************************************************
     * @description     Fetch Redemption Record related to the current 
     *                  login community user
     */
    @isTest
    static void getRedemptionsTest() {
        String res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.getRedemptions('Active_Redemptions', 'Redemptions__c');
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Redemption not found');
    }

    /**********************************************************************
     * @description     Fetch person account details
     */
    @isTest
    static void getPersonAccountDetailsTest() {
        String res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.getPersonAccountDetails();
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Login user don\'t have contact associated');
    }

    /**********************************************************************
     * @description     Negative test for fetching person account details
     */
    @isTest
    static void getPersonAccountDetailsNegativeTest() {
        String res;
        Test.startTest();
            res = MilwaukeeRedemptionController.getPersonAccountDetails();
        Test.stopTest();
        System.assert(String.isBlank(res), 'Login user have contact associated');
    }

    /**********************************************************************
     * @description     Fetch Redemption Record via record Id
     */
    @isTest
    static void getRedemptionDetailsTest() {
        String res;
        Redemptions__c exRedemption = [SELECT Id FROM Redemptions__c LIMIT 1];
        Test.startTest();
            res = MilwaukeeRedemptionController.getRedemptionDetails(exRedemption.Id);
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Redemption not found');
    }

    /**********************************************************************
     * @description     Negative test for getting Redemption Record via 
     *                  record Id 
     */
    @isTest
    static void getRedemptionDetailsNegativeTest() {
        String res;
        Redemptions__c exRedemption = [SELECT Id FROM Redemptions__c LIMIT 1];
        Test.startTest();
            res = MilwaukeeRedemptionController.getRedemptionDetails(null);
        Test.stopTest();
        System.assert(String.isBlank(res), 'Redemption found');
    }

    /**********************************************************************
     * @description     Update contact details
     */
    @isTest
    static void updateContactDetailsTest() {
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];

        Test.startTest();
            System.runAs(portalUser) {
                MilwaukeeRedemptionController.updateContactDetails('U-FName',
                                                                    'U-LName',
                                                                    '1234567',
                                                                    'test-u@test.com',
                                                                    'test',
                                                                    'test',
                                                                    'Australia',
                                                                    'test',
                                                                    '12234');
            }
        Test.stopTest();
        Contact exContact = [SELECT Id FROM Contact WHERE FirstName = 'U-FName' LIMIT 1];
        System.assertEquals(eContact.Id, exContact.Id, 'Failed to update user contact record');
    }

    /**********************************************************************
     * @description     Fetch asset related to current login community
     *                  user
     */
    @isTest
    static void getAssetsTest() {
        List<Asset> eAssetsList = new List<Asset>();
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];

        Test.startTest();
            System.runAs(portalUser) {
                eAssetsList = MilwaukeeRedemptionController.getAssets(eContact.Id);
            }
        Test.stopTest();
        System.assert(!eAssetsList.isEmpty(), 'Asset associated with contact not found');
    }

     /**********************************************************************
     * @description     Negative test for getting asset related to current 
     *                  login community user
     */
    @isTest
    static void getAssetsNegativeTest() {
        List<Asset> eAssetsList = new List<Asset>();
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];

        Test.startTest();
            System.runAs(portalUser) {
                try {
                    eAssetsList = MilwaukeeRedemptionController.getAssets(null);
                } catch (Exception ex) {
                    //Do something here
                }
            }
        Test.stopTest();
        System.assert(eAssetsList.isEmpty(), 'Asset associated with contact found');
    }

    /**********************************************************************
     * @description     Fetch redemption campaign via asset record and 
     *                  product code
     */
    @isTest
    static void getRedemptionCampaignTest() {
        Redemption_Campaigns__c resRedCamp = new Redemption_Campaigns__c();
        List<Asset> eAssetsList = new List<Asset>();
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];

        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                eAssetsList = MilwaukeeRedemptionController.getAssets(eContact.Id);
                System.assert(!eAssetsList.isEmpty(), 'Asset associated with contact not found');
                Product2 eProd = [SELECT Id, ProductCode FROM Product2 WHERE Id = :eAssetsList.get(0).Product2Id LIMIT 1];
                resRedCamp = MilwaukeeRedemptionController.getRedemptionCampaign(eAssetsList.get(0), eProd.ProductCode);
            }
        Test.stopTest();
        System.assert(resRedCamp.Id != null, 'Redemption Campaign not found');
    }

    /**********************************************************************
     * @description     Negative test for getting redemption campaign via 
     *                  asset record and  product code
     */
    @isTest
    static void getRedemptionCampaignNegativeTest() {
        Redemption_Campaigns__c resRedCamp = new Redemption_Campaigns__c();
        Product2 eProd = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                resRedCamp = MilwaukeeRedemptionController.getRedemptionCampaign(null, null);
            }
        Test.stopTest();
        System.assert(resRedCamp == null, 'Redemption Campaign found');
    }

    /**********************************************************************
     * @description     Fetch available redemption campaign based on the
     *                  redemption campaign id and assets related to
     *                  login community user
     */
    @isTest
    static void getPromotionTest() {
        String res;
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id FROM Redemption_Campaigns__c LIMIT 10];
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.getPromotion(exRedCampaignsList.get(0).Id);
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Promotions not found');
    }

    /**********************************************************************
     * @description     Negative test for getting available redemption 
     *                  campaign based on the redemption campaign id and 
     *                  assets related to login community user
     */
    @isTest
    static void getPromotionNegativeTest() {
        String res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.getPromotion('');
            }
        Test.stopTest();
        System.assert(String.isBlank(res), 'Promotions found');
    }

    /**********************************************************************
     * @description     Fetch available redemption campaign based on the
     *                  assets related to login community user
     */
    @isTest
    static void getAvailablePromotionsTest() {
        String res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.getAvailablePromotions();
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'No available promotions');
    }

    /**********************************************************************
     * @description     Submit selected asset and create a redemption record
     *                  
     */
    @isTest
    static void submitRedemptionTest() {
        String res;
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id,
                                      Purchased_Product__c,
                                      Redeemed_Item__c,
                                      Purchased_Product__r.Id
                                      FROM Redemption_Campaigns__c
                                      LIMIT 10];
        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        eContact.Country__c = 'Australia';
        eContact.Email = 'test@test.com';
        update eContact;

        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.submitRedemption(JSON.serialize(eContact), JSON.serialize(exRedCampaignsList.get(0)));
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Failed to submit redemption');
    }

    /**********************************************************************
     * @description     Submit selected asset and create a redemption record
     *                  
     */
    @isTest
    static void submitRedemptionWithoutProductKitTest() {
        String res;
        List<Redemption_Campaigns__c> exRedCampaignsList = [SELECT Id,
                                      Purchased_Product__c,
                                      Redeemed_Item__c,
                                      Purchased_Product__r.Id
                                      FROM Redemption_Campaigns__c
                                      LIMIT 10];
        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        eContact.Country__c = 'Australia';
        eContact.Email = 'test@test.com';
        update eContact;

        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];

        delete [SELECT Id FROM Product_Kit__c];
        Test.startTest();
            System.runAs(portalUser) {
                res = MilwaukeeRedemptionController.submitRedemption(JSON.serialize(eContact), JSON.serialize(exRedCampaignsList.get(0)));
            }
        Test.stopTest();
        System.assert(String.isNotBlank(res), 'Failed to submit redemption');
    }

    /**********************************************************************
     * @description     Negative test for submitting selected asset and 
     *                  create a redemption record
     *                  
     */
    @isTest
    static void submitRedemptionNegativeTest() {
        String res;
        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            res = MilwaukeeRedemptionController.submitRedemption(JSON.serialize(eContact), null);
        Test.stopTest();
        System.assert(JSON.deserialize(res, String.class) == '3', 'Successfully submitted redemption');
    }

    /**********************************************************************
     * @description     create a connection between google api and salesforce
     *                  show the list of possible addresses
     *                  
     */
    @isTest
    static void getAddressAutoCompleteNegativeTest() {
        String res;
        Test.startTest();
            res = MilwaukeeRedemptionController.getAddressAutoComplete('Test', 'Australia');
        Test.stopTest();
        System.assertEquals('sle string', res, 'Google API successfully connected');
    }

    /**********************************************************************
     * @description     create a connection between google api and salesforce
     *                  show the list of possible addresses
     *                  
     */
    @isTest
    static void getAddressDetailsNegativeTest() {
        String res;
        Test.startTest();
            res = MilwaukeeRedemptionController.getAddressDetails('PlaceId');
        Test.stopTest();
        System.assertEquals('sle string', res, 'Google API successfully connected');
    }

    /**
     * @description             Create Redemption Campaign
     *
     * @param  name             Name of redemption campaign
     * @param  brand            Brand of redemption campaign
     * @param  country          Country of redemption campaign
     * @param  gracePeriod      Determine the validity of the redemption campaign
     * @param  purchasedProdId  Purchase product Id
     * @param  redeemedProdId   Redeemed Product Id
     * @return                  Redemption Campaign record
     */
    private static Redemption_Campaigns__c createRedemptionCampaign(String name, String brand, String country, Integer gracePeriod, String purchasedProdId, String redeemedProdId) {
        Redemption_Campaigns__c newRedCamp = new Redemption_Campaigns__c();
        newRedCamp.Name = name;
        newRedCamp.Brand__c = brand;
        newRedCamp.Country__c = country;
        newRedCamp.Valid_From__c = System.today().addDays(-gracePeriod);
        newRedCamp.Redeemed_Item__c = redeemedProdId;
        newRedCamp.Purchased_Product__c = purchasedProdId;
        newRedCamp.Valid_To__c = System.today();
        newRedCamp.Redemption_Type__c = 'External';
        return newRedCamp;
    }

    /**
     * @description         Create attachment record
     * @param  name         Name of Attachment
     * @param  parentId     Parent of attachment
     * @return              Attachment object
     */
    private static Attachment createAttachment(String name, String parentId) {
        Attachment newAttachment = new Attachment();
        newAttachment.Name = name;
        newAttachment.Body = Blob.valueOf('test');
        newAttachment.ParentId = parentId;
        return newAttachment;
    }

}