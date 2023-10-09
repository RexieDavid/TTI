/**
 * @author: Francis Nasalita
 * @date: March 2018
 * @description: This class handles logic for Milwaukee & AEG Redemption Page
 */
global without sharing class MilwaukeeRedemptionController {

    public List<Redemption_Campaigns__c> listPromotions { get; set; }
    public Boolean hasSelectedRedemption { get; set; }
    public Redemption_Campaigns__c selectedRedemption { get; set; }
    public Redemptions__c red { get; set; }
    public GoogleAutocompleteParameter googleAutocompleteParam { get; set; }
    public String googleParamJSON { get; set; }

    public String addressStreetNumber { get; set; }
    public String addressStreet { get; set; }
    public String addressCity { get; set; }
    public String addressState { get; set; }
    public String addressPostCode { get; set; }
    public String addressCountry { get; set; }

    public Account newAccount { get; set; }
    public Asset newAsset { get; set; }
    public Attachment newAttachment { get; set; }
    public Receipts__c newReceipt { get; set; }
    public String receiptNumber { get; set; }
    public String receiptStore { get; set; }
    public String receiptSuburb { get; set; }
    public String selectedProductCode { get; set; }
    public String selectedRedeemedProductCode { get; set; }
    public Boolean isAgreedTerms { get; set; }
    public Boolean isSubmittedSuccessfully { get; set; }
    public String errorMessage { get; set; }

    public Boolean hasCountryParam { get; set; }
    public String baseURL { get; set; }
    public String country { get; set; } // Australia or New Zealand
    public String restrictAddressCountry { get; set; } // Au or Nz
    public String urlContactUs { get; set; }
    public String labelCountry { get; set; } // Australian or New Zealand
    public static String staticCountry;
    public String currentYear { get; set; }

    // Google Tag Manager Code
    public String getGtmCode() {
        return communitySettings.GTMCode__c;
    }

    // TO DO: move to custom settings
    public static Community_Settings__c communitySettings = CommunitySettingsHelperClass.getSiteSettings(site.getMasterLabel());

    public String productName { get; set; }
    public String redeemItemName { get; set; }

    public List<RedemptionWrapper> promotionWrapper { get; set; }
    public List<SelectOption> redeemables { get; set; }
    public List<SelectOption> products { get; set; }
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        for (Australia_State__mdt auState: [SELECT MasterLabel, Code__c from Australia_State__mdt ORDER BY MasterLabel ASC]) {
            options.add(new SelectOption(auState.MasterLabel, auState.MasterLabel));
        }
        return options;
    }

    public List<SelectOption> getRegions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        for (New_Zealand_Region__mdt nzRegion: [SELECT MasterLabel, Code__c from New_Zealand_Region__mdt ORDER BY MasterLabel ASC]) {
            options.add(new SelectOption(nzRegion.MasterLabel, nzRegion.MasterLabel));
        }
        return options;
    }

    public class RedemptionWrapper {
        public String productName { get; set; }
        public String redeemItemName { get; set; }
        public Date validFrom { get; set; }
        public Date validTo { get; set; }
        public String redemptionType { get; set; }
        public Id redemptionId { get; set; }
        public String imgURL { get; set; }


        public RedemptionWrapper(Redemption_Campaigns__c redemptionCampaign) {
            productName = redemptionCampaign.Purchased_Product__r.Customer_Facing_Name__c;
            redeemItemName = redemptionCampaign.Redeemed_Item__r.Customer_Facing_Name__c;
            validFrom = redemptionCampaign.Valid_From__c;
            validTo = redemptionCampaign.Valid_To__c;
            redemptionType = redemptionCampaign.Redemption_Type__c;
            redemptionId = redemptionCampaign.Id;
            imgURL = redemptionCampaign.Redemption_Image_URL__c;
        }
    }

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();

    public MilwaukeeRedemptionController() {
        // check domain if contains au or nz
        String siteLabel = site.getMasterLabel();
        hasCountryParam = false;

        Date d = System.Today();
        currentYear = String.valueOf(d.year());

        if (siteLabel == 'Milwaukee Redemption') {
            hasCountryParam = true;
            country = GlobalConstantUtility.AUSTRALIA;
            restrictAddressCountry = GlobalConstantUtility.AUSTRALIA_SHORT;
            urlContactUs = communitySettings.Contact_Us_URL_AU__c;
            labelCountry = GlobalConstantUtility.AUSTRALIAN;
            baseURL = 'milwaukeetools.com' + '.' + GlobalConstantUtility.AUSTRALIA_SHORT;
        } else if (siteLabel == 'Milwaukee Redemption NZ') {
            hasCountryParam = true;
            country = GlobalConstantUtility.NEW_ZEALAND;
            restrictAddressCountry = GlobalConstantUtility.NEW_ZEALAND_SHORT;
            urlContactUs = communitySettings.Contact_Us_URL_NZ__c;
            labelCountry = GlobalConstantUtility.NEW_ZEALAND;
            baseURL = 'milwaukeetools.co' + '.' + GlobalConstantUtility.NEW_ZEALAND_SHORT;
        } else {
            country = '';
            restrictAddressCountry = '';
            urlContactUs = '';
            labelCountry = '';
            baseURL = '';
        }
        staticCountry = country;

        String jsonActivePromotions = getAllActivePromotions();
        // can still be optimised
        listPromotions = (jsonActivePromotions != '' && jsonActivePromotions != null) ? (List < Redemption_Campaigns__c > ) JSON.deserialize(getAllActivePromotions(), List < Redemption_Campaigns__c > .class) : new List < Redemption_Campaigns__c > ();

        String redemptionId = ApexPages.currentPage().getParameters().get('redemption');
        hasSelectedRedemption = false;
        selectedRedemption = new Redemption_Campaigns__c();
        promotionWrapper = new List < RedemptionWrapper > ();
        products = new List < SelectOption > ();
        redeemables = new List < SelectOption > ();
        red = new Redemptions__c();
        addressStreetNumber = '';
        addressStreet = '';
        addressCity = '';
        addressState = '';
        addressPostCode = '';
        addressCountry = '';

        GoogleAutocompleteComponents googleCmps1 = new GoogleAutocompleteComponents(
            'j_id0:RedemptionForm:street_number', //street_number
            'j_id0:RedemptionForm:street_number', //subpremise
            'j_id0:RedemptionForm:route', //route
            'j_id0:RedemptionForm:locality', //locality
            'j_id0:RedemptionForm:inputState', //administrative_area_level_1
            '', //country
            'j_id0:RedemptionForm:inputPostcode', //postal_code
            'j_id0:RedemptionForm:googleApiAddress', //autocompleteId
            'j_id0:RedemptionForm:inputStateHidden' //stateHiddenId
        );

        GoogleAutocompleteComponents googleCmps2 = new GoogleAutocompleteComponents(
            'j_id0:mobileRedemptionForm:mStreet_Number', //street_number
            'j_id0:mobileRedemptionForm:mStreet_Number', //subpremise
            'j_id0:mobileRedemptionForm:mRoute', //route
            'j_id0:mobileRedemptionForm:mInputSuburb', //locality
            'j_id0:mobileRedemptionForm:mInputState', //administrative_area_level_1
            '', //country
            'j_id0:mobileRedemptionForm:mInputPostCode', //postal_code
            'j_id0:mobileRedemptionForm:mInputGoogleAddress', //autocompleteId
            'j_id0:mobileRedemptionForm:mInputStateHidden' //stateHiddenId
        );

        googleAutocompleteParam = new GoogleAutocompleteParameter();
        googleAutocompleteParam.mapGoogleAddress.put('googleCmps1', googleCmps1);
        googleAutocompleteParam.mapGoogleAddress.put('googleCmps2', googleCmps2);

        googleParamJSON = JSON.serialize(googleAutocompleteParam);

        if (redemptionId != null && redemptionId != '') {
            hasSelectedRedemption = true;
            newAccount = new Account();
            //newAccount.PersonMailingCountryCode = restrictAddressCountry;
            newAsset = new Asset();
            newAttachment = new Attachment();

            if (!listPromotions.isEmpty()) {
                for (Redemption_Campaigns__c redemption: listPromotions) {
                    if (redemption.Id == redemptionId) {
                        selectedRedemption = redemption;
                    }
                }

                productName = selectedRedemption.Purchased_Product__r.Customer_Facing_Name__c;
                redeemItemName = selectedRedemption.Redeemed_Item__r.Customer_Facing_Name__c;

                products.add(new SelectOption('', ''));
                products.add(new SelectOption(selectedRedemption.Purchased_Product__r.ProductCode,
                    selectedRedemption.Purchased_Product__r.Customer_Facing_Name__c));

                redeemables.add(new SelectOption('', ''));
                redeemables.add(new SelectOption(selectedRedemption.Redeemed_Item__r.ProductCode,
                    selectedRedemption.Redeemed_Item__r.Customer_Facing_Name__c));
            }
        } else {
            if (!listPromotions.isEmpty()) {
                for (Redemption_Campaigns__c redemption: listPromotions) {
                    promotionWrapper.add(new RedemptionWrapper(redemption));
                }
            }
        }
    }

    public PageReference submitForm() {
        isSubmittedSuccessfully = true;
        errorMessage = '';
        Savepoint sp = Database.setSavepoint();

        List<Account> existingAccountsEmailBrand = [SELECT Id, 
                                                           Name, 
                                                           PersonContactId 
                                                    FROM Account 
                                                    WHERE PersonEmail =: newAccount.PersonEmail 
                                                    AND Brand__pc = 'Milwaukee'
                                                    AND RecordTypeId =: b2cConsumerContactAccRecTypeId];

        List <Account> existingAccountsNameMobileBrand = [SELECT Id, 
                                                                 Name, 
                                                                 PersonContactId 
                                                          FROM Account 
                                                          WHERE PersonMobilePhone =: newAccount.PersonMobilePhone
                                                          AND FirstName =: newAccount.FirstName 
                                                          AND LastName =: newAccount.LastName 
                                                          AND Brand__pc = 'Milwaukee'
                                                          AND RecordTypeId =: b2cConsumerContactAccRecTypeId];


        newAccount.PersonMailingStreet = newAccount.MRAddressStreetNumber__c + ' ' + newAccount.MRAddressRoute__c;

        String siteLabel = site.getMasterLabel();
        if (siteLabel == 'Milwaukee Redemption') {
            newAccount.PersonMailingCountry = GlobalConstantUtility.AUSTRALIA;
            newAccount.Delivery_Country__c = GlobalConstantUtility.AUSTRALIA;
            newAccount.Country__pc = GlobalConstantUtility.AUSTRALIA;
        } else if (siteLabel == 'Milwaukee Redemption NZ') {
            newAccount.PersonMailingCountry = GlobalConstantUtility.NEW_ZEALAND;
            newAccount.Delivery_Country__c = GlobalConstantUtility.NEW_ZEALAND;
            newAccount.Country__pc = GlobalConstantUtility.NEW_ZEALAND;
        }

        newAccount.Brand__pc = 'Milwaukee';
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';
        newAccount.PersonMobilePhone = (newAccount.PersonMobilePhone != null) ? String.valueOf(newAccount.PersonMobilePhone).deleteWhitespace() : '';
        newAccount.Phone = (newAccount.Phone != null) ? String.valueOf(newAccount.Phone).deleteWhitespace() : '';

        if (selectedRedemption.Redemption_Type__c == 'External' && String.isBlank(newAccount.Company_Name__c)) {
            newAccount.Company_Name__c = 'tbc';
        }


        if (!existingAccountsEmailBrand.isEmpty()) {
            newAccount.Id = existingAccountsEmailBrand[0].Id;
        } else if (!existingAccountsNameMobileBrand.isEmpty()) {
            newAccount.Id = existingAccountsNameMobileBrand[0].Id;
        }

        List<User> connectedAppAdmins = [SELECT Id 
                                         FROM User 
                                         WHERE Name = 'Connected App Administrator'
                                         LIMIT 1];

        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }

        try {
            upsert newAccount;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        newAccount = [SELECT FirstName, LastName, Company_Name__c, PersonMobilePhone, Phone, PersonEmail,
                             MRAddressStreetNumber__c, MRAddressRoute__c, PersonMailingCity, PersonMailingState,
                             PersonMailingPostalCode, PersonContactId, PersonContact.Brand__c, Id
                      FROM Account
                      WHERE Id =: newAccount.Id];

        Product2 existingProduct = [SELECT Id FROM Product2 WHERE ProductCode =: selectedProductCode LIMIT 1];
        Product2 redemptionProduct = [SELECT Id FROM Product2 WHERE ProductCode =: selectedRedeemedProductCode LIMIT 1];

        Asset newAsset = new Asset();
        newAsset.Product2Id = redemptionProduct.Id;
        newAsset.AccountId = newAccount.Id;
        newAsset.ContactId = newAccount.PersonContactId;
        newAsset.Name = 'Temporary Name';
        newAsset.Purchased_Online__c = 'In-Store';

        try {
            insert newAsset;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        Receipts__c receipt = new Receipts__c();
        receipt.Account__c = newAccount.Id;
        receipt.ReceiptSource__c = 'Other';
        receipt.Receipt_Name__c = receiptNumber;

        try {
            insert receipt;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        red.Status__c = 'Submitted';
        red.Product_Name__c = selectedRedemption.Purchased_Product__c;
        red.Redeemed_Item__c = selectedRedemption.Redeemed_Item__c;
        red.Name__c = newAccount.PersonContactId;
        red.Brand__c = newAccount.PersonContact.Brand__c;
        red.Redemption_Campaign__c = selectedRedemption.Id;
        red.Receipt_Number__c = receiptNumber;

        red.Captured_FirstName__c = newAccount.FirstName;
        red.Captured_Surname__c = newAccount.LastName;
        red.Captured_Company__c = newAccount.Company_Name__c;
        red.Captured_Mobile__c = newAccount.PersonMobilePhone;
        red.Captured_Phone__c = newAccount.Phone;
        red.Captured_Email_Address__c = newAccount.PersonEmail;
        red.Captured_Street_Number__c = newAccount.MRAddressStreetNumber__c;
        red.Captured_Street_Address__c = newAccount.MRAddressRoute__c;
        red.Captured_Suburb__c = newAccount.PersonMailingCity;
        red.Captured_Region__c = newAccount.PersonMailingState;
        red.Captured_Postcode__c = newAccount.PersonMailingPostalCode;


        // Francis Nasalita [SP-587] Nov. 21, 2018
        // Populating record type based on the Redemption Type
        if (selectedRedemption.Redemption_Type__c == 'External') {
            red.RecordTypeId = UtilityClass.getRecordTypeIdbyName('Redemptions__c', 'External');
        } else {
            red.RecordTypeId = UtilityClass.getRecordTypeIdbyName('Redemptions__c', 'Internal');
        }

        try {
            insert red;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        try {
            newAsset.Receipt__c = receipt.Id;
            newAsset.Redeemed__c = true;
            newAsset.Redemption__c = red.Id;
            update newAsset;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        try {
            newAttachment.ParentId = receipt.Id;
            insert newAttachment;
        } catch (Exception err) {
            isSubmittedSuccessfully = false;
        }

        if (isSubmittedSuccessfully == true) {
            PageReference pageRef = new PageReference(MilwaukeeRedemptionController.communitySettings.RedemptionSuccessURL__c);
            return pageRef;
        } else {
            Database.rollback(sp);
            return null;
        }
    }

    @AuraEnabled
    public static CommunitySettingsHelperClass.SiteSettingsResult getSiteSettings() {
        return CommunitySettingsHelperClass.getSiteAndUserSettings(site.getMasterLabel());
    }

    @AuraEnabled
    public static String getRedemptions(String fieldSetApiName, String objectApiName) {

        if (TTIUtilClass.readFieldSetToList(fieldSetApiName, objectApiName) != null) {
            Contact con = (Contact) JSON.deserialize(MilwaukeeRedemptionController.getPersonAccountDetails(), Contact.class);
            String condition = 'Name__c = ' + '\'' + con.Id + '\' ';

            List<SObject> redemptions = Database.query(TTIUtilClass.constructSOQLQuery(fieldSetApiName, objectApiName, condition, null, null, null, null));

            if (!redemptions.isEmpty()) {
                return JSON.serialize(redemptions);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getPersonAccountDetails() {
        Id currentUserId = UserInfo.getUserId();

        User u = [SELECT ContactId FROM User WHERE Id =: currentUserId];

        if (u.ContactId != null) {
            Contact con = [SELECT Id, Name, MobilePhone, Email, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, Brand__c, AccountId, FirstName, LastName FROM Contact WHERE Id =: u.ContactId];

            if (con != null) {
                return JSON.serialize(con);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getAllActivePromotions() {
        Integer gracePeriod = getRedemptionGracePeriod();
        Date validToGracePeriod = System.today().addDays(-gracePeriod);

        // FNasalita Sept 20, 2018 [SAL-447]
        String country = staticCountry;
        String brand = '';
        switch on MilwaukeeRedemptionController.communitySettings.Lead_Source__c {
            when 'MYAEG' {
                country = GlobalConstantUtility.AUSTRALIA;
                brand = 'AEG';
            }
            when 'MYAEGNZ' {
                country = GlobalConstantUtility.NEW_ZEALAND;
                brand = 'AEG';
            }
            when 'MyMilwaukee' {
                //country = this.country;
                brand = 'Milwaukee';
            }
        }

        if (MilwaukeeRedemptionController.communitySettings != null) {
            // Francis Nasalita [SP-587] Nov. 21, 2018
            // Added Redemption_Type__c to query
            List<Redemption_Campaigns__c> listPromotions = [SELECT Purchased_Product__c, Purchased_Product__r.Customer_Facing_Name__c, Purchased_Product__r.Name, Purchased_Product__r.ProductCode, Purchased_Product__r.Image_URL__c,
                Redeemed_Item__c, Redeemed_Item__r.Customer_Facing_Name__c, Redeemed_Item__r.Name, Redeemed_Item__r.ProductCode, Redeemed_Item__r.Image_URL__c,
                Valid_From__c, Valid_To__c, Redeemed_Item_Qty__c, Redemption_Image_URL__c, Redemption_Type__c
                FROM Redemption_Campaigns__c
                WHERE Brand__c =: brand
                AND(Country__c =: country OR Country__c =: GlobalConstantUtility.ANZ)
                AND Valid_From__c <= TODAY
                AND Valid_To__c >=: validToGracePeriod
                ORDER BY CreatedDate ASC
            ];

            if (!listPromotions.isEmpty()) {
                return JSON.serialize(listPromotions);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Integer getRedemptionGracePeriod() {
        if(Test.isRunningTest()){
            return Integer.valueOf(CommunitySettingsHelperClass.getSiteSettings('myAEG').RedemptionGracePeriod__c);
        } else {
            return Integer.valueOf(CommunitySettingsHelperClass.getSiteSettings(site.getMasterLabel()).RedemptionGracePeriod__c);
        }
    }

    @AuraEnabled
    public static String getRedemptionDetails(String redemptionId) {
        if (redemptionId != null && redemptionId != '') {
            Redemptions__c red = [SELECT Id, Name, Status__c, CreatedDate,
                Product_Name__c, Product_Name__r.Name, Product_Name__r.Image_URL__c,
                Redeemed_Item__c, Redeemed_Item__r.Name, Redeemed_Item__r.Image_URL__c,
                Receipt_Number__c, Carrier_Tracking_Number__c
                FROM Redemptions__c
                WHERE Id =: redemptionId
            ];

            if (red != null) {
                return JSON.serialize(red);
            } else {
                return null;
            }
        }
        return null;
    }

    public static List<Asset> getAssets(Id conId) {
        return [SELECT Id, Product2Id, Redeemed__c, KitProduct__c, PurchaseDate FROM Asset WHERE ContactId =: conId AND Redeemed__c = false ORDER BY PurchaseDate DESC];
    }

    public static Redemption_Campaigns__c getRedemptionCampaign(Asset asset, String productCode) {
        if (asset != null) {
            // FNasalita Sept 20, 2018 [SAL-482]
            String country = '';
            switch on MilwaukeeRedemptionController.communitySettings.Lead_Source__c {
                when 'MYAEG' {
                    country = GlobalConstantUtility.AUSTRALIA;
                }
                when 'MYAEGNZ' {
                    country = GlobalConstantUtility.NEW_ZEALAND;
                }
            }

            Integer gracePeriod = (Test.isRunningTest()) ? getRedemptionGracePeriod() : 30;

            List<Redemption_Campaigns__c> promo = [SELECT Purchased_Product__c, Purchased_Product__r.Customer_Facing_Name__c, Purchased_Product__r.ProductCode, Purchased_Product__r.Image_URL__c,
                Purchased_Product__r.Id,
                Redeemed_Item__c, Redeemed_Item__r.Customer_Facing_Name__c, Redeemed_Item__r.ProductCode, Redeemed_Item__r.Image_URL__c,
                Valid_From__c, Valid_To__c, Id, Redeemed_Item_Qty__c
                FROM Redemption_Campaigns__c
                WHERE((Purchased_Product__r.Id =: asset.KitProduct__c AND Purchased_Product__r.ProductCode =: productCode) 
                      OR (Purchased_Product__r.Id =: asset.Product2Id AND Purchased_Product__r.ProductCode =: productCode))
                AND(Country__c =: country OR Country__c =: GlobalConstantUtility.ANZ)
                AND Valid_From__c <=: asset.PurchaseDate
                AND Valid_To__c >=: asset.PurchaseDate
                LIMIT 1
            ];

            if (!promo.isEmpty()) {
                Date validToGracePeriod = promo[0].Valid_To__c.addDays(gracePeriod);
                if (System.today() <= validToGracePeriod) {
                    return promo[0];
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getPromotion(String redemptionCampaignId) {
        if (redemptionCampaignId != '') {
            Contact con = (Contact) JSON.deserialize(MilwaukeeRedemptionController.getPersonAccountDetails(), Contact.class);
            Set<Id> assetsProductCode = new Set<Id>();

            for (Asset asset: MilwaukeeRedemptionController.getAssets(con.Id)) {
                if (asset.KitProduct__c != null) {
                    if (!assetsProductCode.contains(asset.KitProduct__c)) {
                        assetsProductCode.add(asset.KitProduct__c);
                    }
                } else {
                    if (!assetsProductCode.contains(asset.Product2Id)) {
                        assetsProductCode.add(asset.Product2Id);
                    }
                }
            }

            if (!assetsProductCode.isEmpty()) {
                List<Redemption_Campaigns__c> listAvailablePromotions = [SELECT Purchased_Product__c, Purchased_Product__r.Customer_Facing_Name__c, Purchased_Product__r.ProductCode, Purchased_Product__r.Image_URL__c,
                    Purchased_Product__r.Id,
                    Redeemed_Item__c, Redeemed_Item__r.Customer_Facing_Name__c, Redeemed_Item__r.ProductCode, Redeemed_Item__r.Image_URL__c,
                    Valid_From__c, Valid_To__c, Id, Redeemed_Item_Qty__c
                    FROM Redemption_Campaigns__c
                    WHERE Id =: redemptionCampaignId
                    AND Purchased_Product__r.Id IN: assetsProductCode
                ];

                if (!listAvailablePromotions.isEmpty()) {
                    return JSON.serialize(listAvailablePromotions);
                } else {
                    return '';
                }
            } else {
                return '';
            }
        } else {
            return '';
        }
    }

    @AuraEnabled
    public static String getAvailablePromotions() {
        Contact con = (Contact) JSON.deserialize(MilwaukeeRedemptionController.getPersonAccountDetails(), Contact.class);
        Integer gracePeriod = getRedemptionGracePeriod();

        if (con != null) {
            Set < Id > setProductIds = new Set < Id > ();
            Map < Id, Set < Date >> mapProductIdsAndPurchasedDates = new Map < Id, Set < Date >> ();

            for (Asset asset: MilwaukeeRedemptionController.getAssets(con.Id)) {
                if (asset.KitProduct__c != null) {
                    if (mapProductIdsAndPurchasedDates.containsKey(asset.KitProduct__c)) {
                        mapProductIdsAndPurchasedDates.get(asset.KitProduct__c).add(asset.PurchaseDate);
                    } else {
                        mapProductIdsAndPurchasedDates.put(asset.KitProduct__c, new Set < Date > ());
                        mapProductIdsAndPurchasedDates.get(asset.KitProduct__c).add(asset.PurchaseDate);
                    }
                } else {
                    if (mapProductIdsAndPurchasedDates.containsKey(asset.Product2Id)) {
                        mapProductIdsAndPurchasedDates.get(asset.Product2Id).add(asset.PurchaseDate);
                    } else {
                        mapProductIdsAndPurchasedDates.put(asset.Product2Id, new Set < Date > ());
                        mapProductIdsAndPurchasedDates.get(asset.Product2Id).add(asset.PurchaseDate);
                    }
                }
            }

            if (!mapProductIdsAndPurchasedDates.keySet().isEmpty()) {
                List<Redemption_Campaigns__c> listPromotions = new List<Redemption_Campaigns__c>();
                // FNasalita Sept 20, 2018 [SAL-447]
                String country = '';
                switch on MilwaukeeRedemptionController.communitySettings.Lead_Source__c {
                    when 'MYAEG' {
                        country = GlobalConstantUtility.AUSTRALIA;
                    }
                    when 'MYAEGNZ' {
                        country = GlobalConstantUtility.NEW_ZEALAND;
                    }
                }

                for (Redemption_Campaigns__c redCampaign: [SELECT Purchased_Product__c, Purchased_Product__r.Customer_Facing_Name__c, Purchased_Product__r.ProductCode, Purchased_Product__r.Image_URL__c,
                        Purchased_Product__r.Id,
                        Redeemed_Item__c, Redeemed_Item__r.Customer_Facing_Name__c, Redeemed_Item__r.ProductCode, Redeemed_Item__r.Image_URL__c,
                        Valid_From__c, Valid_To__c, Id, Redeemed_Item_Qty__c
                        FROM Redemption_Campaigns__c
                        WHERE Brand__c =: con.Brand__c
                        AND(Country__c =: country OR Country__c =: GlobalConstantUtility.ANZ)
                        AND Purchased_Product__r.Id IN: mapProductIdsAndPurchasedDates.keySet()
                    ]) {

                    Date validToGracePeriod = redCampaign.Valid_To__c.addDays(gracePeriod);
                    for (Date d: mapProductIdsAndPurchasedDates.get(redCampaign.Purchased_Product__r.Id)) {

                        if ((redCampaign.Valid_From__c <= d && d <= redCampaign.Valid_To__c) && validToGracePeriod >= System.today()) {
                            listPromotions.add(redCampaign);
                            break;
                        }
                    }
                }

                if (!listPromotions.isEmpty()) {
                    return JSON.serialize(listPromotions);
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String submitRedemption(String contactInfoJSON, String selectedAssetJSON) {
        if (contactInfoJSON != null && selectedAssetJSON != null) {
            Contact con = (Contact) JSON.deserialize(contactInfoJSON, Contact.class);
            Redemption_Campaigns__c redCampaign = (Redemption_Campaigns__c) JSON.deserialize(selectedAssetJSON, Redemption_Campaigns__c.class);

            if (con != null && redCampaign != null) {
                Redemptions__c red = new Redemptions__c();
                red.Status__c = 'Submitted';
                red.Product_Name__c = redCampaign.Purchased_Product__c;
                red.Redeemed_Item__c = redCampaign.Redeemed_Item__c;
                red.Name__c = con.Id;
                red.Brand__c = con.Brand__c;
                red.Redemption_Campaign__c = redCampaign.Id;

                try {
                    insert red;
                } catch (Exception err) {
                    return err.getMessage();
                }

                Map<Id, Decimal> mapKitToolQuantity = new Map<Id, Decimal>();
                for (Product_Kit__c kit: [SELECT Kit_Tool__r.Id, Quantity__c FROM Product_Kit__c WHERE Kit__c =: redCampaign.Purchased_Product__r.Id]) {
                    if (mapKitToolQuantity.keySet().contains(kit.Kit_Tool__r.Id)) {
                        mapKitToolQuantity.put(kit.Kit_Tool__r.Id, mapKitToolQuantity.get(kit.Kit_Tool__r.Id) + kit.Quantity__c);
                    } else {
                        mapKitToolQuantity.put(kit.Kit_Tool__r.Id, kit.Quantity__c);
                    }
                }

                List<Asset> listAsset = new List<Asset>();
                Set<Id> setProdIds = new Set<Id>();

                for (Asset assetTemp: [SELECT Id, Product2Id, Receipt__c, Redeemed__c
                        FROM Asset
                        WHERE(KitProduct__c =: redCampaign.Purchased_Product__r.Id OR Product2Id =: redCampaign.Purchased_Product__r.Id)
                        AND ContactId =: con.Id
                        AND Redeemed__c = false
                    ]) {

                    if (!mapKitToolQuantity.isEmpty()) {
                        if (mapKitToolQuantity.keySet().contains(assetTemp.Product2Id)) {
                            if (mapKitToolQuantity.get(assetTemp.Product2Id) != 0) {
                                setProdIds.add(assetTemp.Product2Id);
                                assetTemp.Redeemed__c = true;
                                assetTemp.Redemption__c = red.Id;
                                listAsset.add(assetTemp);

                                mapKitToolQuantity.put(assetTemp.Product2Id, mapKitToolQuantity.get(assetTemp.Product2Id) - 1);
                            }
                        }
                    } else {
                        assetTemp.Redeemed__c = true;
                        assetTemp.Redemption__c = red.Id;
                        listAsset.add(assetTemp);

                        break;
                    }
                }

                if (!listAsset.isEmpty()) {

                    try {
                        update listAsset;
                        return JSON.serialize('Success');
                    } catch (Exception err) {
                        return JSON.serialize(err.getMessage());
                    }
                } else {
                    return JSON.serialize('1');
                }

            } else {
                return JSON.serialize('2');
            }
        } else {
            return JSON.serialize('3');
        }
    }

    @AuraEnabled
    public static String updateContactDetails(String inputFirstName, String inputLastName, String inputMobile, String inputEmail,
        String inputStreet, String inputCity, String inputCountry, String inputProvince, String inputPostalCode) {

        Contact con = (Contact) JSON.deserialize(MilwaukeeRedemptionController.getPersonAccountDetails(), Contact.class);
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
            return JSON.serialize((Contact) JSON.deserialize(MilwaukeeRedemptionController.getPersonAccountDetails(), Contact.class));
        } catch (Exception err) {
            return JSON.serialize(err.getMessage());
        }
    }

    //FOR GOOGLE API
    @AuraEnabled
    global static string getAddressAutoComplete(String input, String countryname) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:' + countryname + '&input=' + EncodingUtil.urlEncode(input, 'UTF-8') + '&types=geocode&key=' + getGoogleMapsAPIKey();
        return UtilityClass.getHttp(url);
    }

    @AuraEnabled
    global static string getAddressDetails(String PlaceId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + PlaceId + '&key=' + getGoogleMapsAPIKey();
        return UtilityClass.getHttp(url);
    }

    global static String getGoogleMapsAPIKey() {
        return 'AIzaSyCQv1a_xCWjy0W5yQ9tBz_VIWW1q66sX9c';
    }
}