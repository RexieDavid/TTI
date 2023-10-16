/** 
 * @description:        Controlled for the product add/edit page
 * 
 * @author:             Andrew Manetakis (Accenture)
 * @date:               2017-03-20 
*/
public class ProductDetailCC {
    public static final String ERROR_USER_CANNOT_REGISTER = 'This user is not permitted to register tools.';
    
    @AuraEnabled
    public static String getHostUrl() {
        return Label.BVPixelSite;
    }
    
    /**
     * @description                 Save asset record and fetch available redemption 
     *                              campaign
     * 
     * @param  assets               Asset to save
     * @param  isBunningReceipt     Is bunning receipt
     * @param  filename             File name of bunning receipt
     * @param  productCode          Product code of purchased item
     * @return                      saveProductRegistrationResult which contains
     *                              asset information and redemption campaign
     */
    @AuraEnabled
    public static saveProductRegistrationResult saveProductRegistration(List<Asset> assets, String isBunningReceipt, String filename, String productCode, Boolean isCustomMedata) { 
        saveProductRegistrationResult result = new saveProductRegistrationResult();
        result.assets = new List<Asset>();

        User currentUser = [SELECT Id, ContactId, Contact.Accountid, Country from User WHERE Id = :Userinfo.getUserId()];
        
        if (currentUser.ContactId == null || currentUser.Contact.Accountid == null) {
            //return ERROR_USER_CANNOT_REGISTER;
            return new saveProductRegistrationResult(ERROR_USER_CANNOT_REGISTER, true);
        }
        
        Boolean kt = true;
        for (Asset asset : assets) { 
            System.debug('JAC asset : ' + asset);
            asset.AccountId = currentUser.contact.accountid;
            asset.ContactId = currentUser.ContactId;
            asset.Status = CommunitySettingsHelperClass.getAssetCreateStatus();
            if (!isCustomMedata) {
                asset.AssetSource__c = CommunitySettingsHelper.mapPurchasedFrom(asset.AssetSource__c);
            }
            asset.IdentifiedBy__c = CommunitySettingsHelperClass.getAssetDefaultIdentifiedBy();
            asset.WarrantyStatus__c = CommunitySettingsHelperClass.getAssetDefaultWarrantyStatus();
            //only set the first asset in the kit to true - this is used for workfow for kits
            asset.KitRegistrationTrigger__c = kt;
            kt = false;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        // Check if the product is qualified for a redemption promo item
        String currentCountry = currentUser.country;
        if (String.isNotBlank(currentCountry) 
                && (currentCountry.equalsIgnoreCase('Australia') 
                || currentCountry.equalsIgnoreCase('New Zealand'))) {
            Boolean isSameKit = false;
            if (assets.size() > 1) {
                for(Integer i = 1; i < assets.size(); i++) {
                    if (assets[0].KitProduct__c == assets[i].KitProduct__c) {
                        isSameKit = true;
                        break;
                    }
                }
            } else {
                isSameKit = true;
            }
            
            if (isSameKit) {
                result.redemptionCampaignJSON = getRedemptionCampaign(assets[0], productCode);
            }
        }
        
        try {
            // RDAVID 12/16/2022 INC0030635 - Added condition to check if Filename is not Blank
            if(!String.isBlank(filename)){
                Receipts__c receipt = insertReceipt(filename, string.valueOf(currentUser.contact.accountid), isBunningReceipt == 'Yes', 'Bunnings');
                for (Asset asset : assets) {
                    asset.Receipt__c = receipt.Id;
                }
                result.receiptID = receipt.Id;
            }
            
            insert assets;
            
            assets = [SELECT Id, 
                             AccountId, 
                             Standard_Warranty_Months__c, 
                             Extended_Warranty_Months__c, 
                             Total_Warranty_Years__c,
                             AssetSource__c,
                             IdentifiedBy__c,
                             ProductDescription,
                             ProductCode,
                             SerialNumber,
                             PurchaseDate,
                             SerialNumberWeek__c, 
                             SerialNumberYear__c,
                             Product2.AU_ListPrice__c,
                             Product2.NZ_ListPrice__c,
                             Product2.Category_Customer_Level2__c
                        FROM Asset 
                       WHERE Id IN :assets];  
            
            if (assets.size() == 1) {
                result.standardWarranty = assets[0].Standard_Warranty_Months__c != null ? assets[0].Standard_Warranty_Months__c.intValue() : 0;
                result.extendedWarranty = assets[0].Extended_Warranty_Months__c != null ? assets[0].Extended_Warranty_Months__c.intValue() : 0;
                result.totalWarrantyYears = assets[0].Total_Warranty_Years__c != null ? assets[0].Total_Warranty_Years__c.intValue() : 0;        
                result.accId = assets[0].AccountId;
                result.assetId = assets[0].Id;
                //RDAVID 10/16/2023 SD-2386 Membership Loyalty Program - Blackhawk Integration
                Set<String> assetIds = new Set<String>();
                for(Asset assetRec : assets){
                    assetIds.add(assetRec.Id);
                }
                if(assetIds.size() > 0){
                    MembershipLoyaltyController.GenerateMemberBenefitWrapper generateMemberBenefitRecords = MembershipLoyaltyController.generateMemberBenefits(assetIds);
                    System.debug('saveProductRegistration >>> generateMemberBenefitRecords >>> ' + generateMemberBenefitRecords);  
                    if(generateMemberBenefitRecords != NULL && generateMemberBenefitRecords.memberBenefitList.size() > 0 && generateMemberBenefitRecords.assetList.size() > 0){
                        MembershipLoyaltyController.WithoutShare elevatedContext = new MembershipLoyaltyController.WithoutShare();
                        elevatedContext.insertMemberBenefits(generateMemberBenefitRecords.memberBenefitList, generateMemberBenefitRecords.assetList);
                    }
                }
            }

            result.assets.addAll(assets);
            result.brand = TTIUtilClass.getBrandCurrentUser();
            
            System.debug('JAC result : ' + result);
            return result; 
        } catch(Exception e) {
            Database.rollback(sp);
            return new saveProductRegistrationResult(e.getMessage(), true);
        }
    }  
    
    @AuraEnabled
    public static saveProductRegistrationResult updateProductRegistration(Asset updatedAsset, String isFromValidRetailer, String filename, string retailerSource) {
        User currentUser = [SELECT id, contactId, contact.accountid  from User where id = :Userinfo.getUserId()];
        Asset oldAsset = [SELECT id,  Receipt__c, PurchaseDate, SerialNumber, SerialNumberWeek__c, SerialNumberYear__c from Asset where id = :updatedAsset.Id];
        
        if (currentUser.contactId == null) {
            return new saveProductRegistrationResult(ERROR_USER_CANNOT_REGISTER, true);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            // INC0032031 - My Ryobi edit screen details does not match initial  details - 01/20/2022 - JAC
            // Receipts__c receipt = new Receipts__c();
            // if (filename == 'NoFile') {
            //     receipt = [SELECT id,  ReceiptSource__c from Receipts__c where id = :oldAsset.Receipt__c];
                
            //     if (receipt != null) {
            //         String mapReceiptSource = CommunitySettingsHelperClass.mapReceiptSource(retailerSource);
            //         String mapOtherReceiptSource = CommunitySettingsHelperClass.mapReceiptSource('Other');
                    
            //         receipt.ReceiptSource__c = isFromValidRetailer == 'Yes' && mapReceiptSource != null ?
            //              mapReceiptSource : mapOtherReceiptSource;
            //         update receipt;
            //     } 
            // } else {
            //     receipt = insertReceipt(filename, string.valueOf(currentUser.contact.accountid), isFromValidRetailer == 'Yes', retailerSource);
            // }
            
            // oldAsset.Receipt__c =  receipt.Id;
            // INC0032031 - End

            List<Receipts__c> receipts = new List<Receipts__c>();
            if (filename == 'NoFile') {
                receipts = [SELECT id,  ReceiptSource__c from Receipts__c where id = :oldAsset.Receipt__c];
                
                if (!receipts.isEmpty()) {
                    String mapReceiptSource = CommunitySettingsHelperClass.mapReceiptSource(retailerSource);
                    String mapOtherReceiptSource = CommunitySettingsHelperClass.mapReceiptSource('Other');
                    
                    for(Receipts__c receipt : receipts){
                        receipt.ReceiptSource__c = isFromValidRetailer == 'Yes' && mapReceiptSource != null ?
                             mapReceiptSource : mapOtherReceiptSource;

                    }
                    update receipts;
                } 
            } else {
                receipts.add(insertReceipt(filename, string.valueOf(currentUser.contact.accountid), isFromValidRetailer == 'Yes', retailerSource));
            }
            
            oldAsset.Receipt__c =  receipts[0].Id;
            //oldAsset.AssetSource__c = CommunitySettingsHelperClass.mapPurchasedFrom(updatedAsset.AssetSource__c);
            oldAsset.Asset_Source_Other__c= updatedAsset.Asset_Source_Other__c;
            oldAsset.PurchaseDate = updatedAsset.PurchaseDate;
            oldAsset.SerialNumber = updatedAsset.SerialNumber;
            oldAsset.SerialNumberWeek__c = updatedAsset.SerialNumberWeek__c;
            oldAsset.SerialNumberYear__c = updatedAsset.SerialNumberYear__c;
            update oldAsset;
            
            Asset result = [SELECT Id, Name, Standard_Warranty_Months__c, Extended_Warranty_Months__c, Total_Warranty_Years__c FROM Asset WHERE Id = :oldAsset.id];
            
            saveProductRegistrationResult r = new saveProductRegistrationResult();
            // INC0032031 - My Ryobi edit screen details does not match initial  details - 01/20/2022 - JAC
            // r.receiptID = receipt.Id;
            // INC0032031 - End

            r.receiptID = receipts[0].Id;
            r.standardWarranty = result.Standard_Warranty_Months__c.intValue();
            r.extendedWarranty = result.Extended_Warranty_Months__c.intValue();
            r.totalWarrantyYears = result.Total_Warranty_Years__c.intValue();
            
            return r;
        } catch(Exception e) {
            Database.rollback(sp);
            return new saveProductRegistrationResult(e.getMessage(), true);
        }
    } 
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;
        
        ProductDetailCC.Utility_RowIterator r = new ProductDetailCC.Utility_RowIterator(base64Data, ',');
        String firstRow = (r.hasNext() ? r.next() : '');
        firstRow = (r.hasNext() ? r.next() : '');
        base64Data = (firstRow != '' ? firstRow : base64Data);
        firstRow = (r.hasNext() ? r.next() : '');
        base64Data = (firstRow != '' ? firstRow : base64Data);
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        insert a;
        
        return a.Id;
    }
    
    public static Receipts__c insertReceipt(string name, string accountID, boolean isFromValidRetailer, String retailerSource) {
        String mapReceiptSource = CommunitySettingsHelperClass.mapReceiptSource(retailerSource);
        String mapOtherReceiptSource = CommunitySettingsHelperClass.mapReceiptSource('Other');
        
        Receipts__c receipt = new Receipts__c();
        receipt.Account__c =  accountID;
        receipt.Receipt_Name__c = name;
        receipt.ReceiptSource__c = isFromValidRetailer && mapReceiptSource != null ? mapReceiptSource : mapOtherReceiptSource;
        
        insert receipt;
        return receipt;  
    }
    
    @AuraEnabled
    public static Id saveFileChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        if (fileId == '') {
            fileId = saveFile(parentId, fileName, base64Data, contentType);
        } else {
            if (fileId != null) {
                appendChunkFile(fileId, base64Data);
            }
        }
        
        if (fileId == null) {
            return null;
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendChunkFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :fileId];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        update a;
    }
    
    @AuraEnabled
    public static String getFileId(Id receiptId) {
        Attachment attach = [SELECT Id,Name,OwnerId,ParentId FROM Attachment WHERE ParentId =: receiptId Order by CreatedDate desc Limit 1];
        string baseURl = site.getBaseUrl();
        String fileLink = baseURl +'/servlet/servlet.FileDownload?file=' + attach.Id;
        return fileLink;
    }
    
    @AuraEnabled
    public static Community_Settings__c getCommunitySettings() {
        CommunitySettingsHelperClass.SiteSettingsResult result =  CommunitySettingsHelperClass.getSiteAndUserSettings(site.getMasterLabel());    
        return result.communitySettings;    
    }
    
    @AuraEnabled
    public static CommunitySettingsHelperClass.SiteSettingsResult getSiteSettings() {
        return CommunitySettingsHelperClass.getSiteAndUserSettings(site.getMasterLabel());
    }
    
    public class Utility_RowIterator implements Iterator<String>, Iterable<String> {
        private String m_Data;
        private Integer m_index = 0;
        private String m_rowDelimiter = '\n';
        
        public Utility_RowIterator(String fileData) {
            m_Data = fileData; 
        }
        
        public Utility_RowIterator(String fileData, String rowDelimiter) {
            m_Data = fileData; 
            m_rowDelimiter = rowDelimiter;
        }
        
        public Boolean hasNext() {
            return m_index < m_Data.length() ? true : false;
        }
        
        public String next() {    
            Integer key = m_Data.indexOf(m_rowDelimiter, m_index);
            
            if (key == -1) {
                key = m_Data.length();
            }
            
            String row = m_Data.subString(m_index, key);
            m_index = key + 1;
            
            return row;
        }
        
        public Iterator<String> Iterator() {
            return this;  
        }
    }
    
    /**********************************************************************
     * @description             retrieves account of logged in user
     * 
     * @param                   id of current user
     * @return                  account with fields used for myRyobi customer 
     *                          survey
    */
    @AuraEnabled
    public static Account getSurveyDetails(String userId) {
        Id userPersonAccountId = [SELECT Id, AccountId FROM User WHERE Id = :userId LIMIT 1].AccountId;
        return [SELECT Id, FirstName, Confidence_in_Power_Tools__c, DIY_Enjoyment__c, Is_survey_completed__c FROM Account WHERE Id = :userPersonAccountId LIMIT 1];
    }
    
    /**********************************************************************
     * @description             Saves current user's answer to myRyobi  
     *                          customer survey modal
     * 
     * @return                  Confidence_in_Power_Tools__c and DIY_Enjoyment__c 
     *                          in the Account as answers of the user and
     *                          updates the Is_survey_completed__c
    */
    @AuraEnabled
    public static String saveSurvey(String userId, String q1, String q2, Boolean isSurveyComplete) {
        String msg = '';
        User currentUser = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1];
        
        if (currentUser != null) {
            Account userPersonAccount = [SELECT Id, Confidence_in_Power_Tools__c, DIY_Enjoyment__c, Is_survey_completed__c FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
            
            userPersonAccount.Confidence_in_Power_Tools__c = q2;
            userPersonAccount.DIY_Enjoyment__c = q1;
            userPersonAccount.Is_survey_completed__c = isSurveyComplete;
            
            update userPersonAccount;
            msg = 'SUCCESS';
        }
        return msg;
    }


    /**********************************************************************
     * @description                 Delete content document records related
     *                              to login user  
     *                              
     * @param  contentDocumentId    Id of contentdocument
     * @param  isBulk               Check if will delete bulk content data
     * @return                      Result of transaction
     */
    @AuraEnabled
    public static void removeContentDocuments(String contentDocumentId, Boolean isBulk) {
        Set<String> contentDocumentIdsSet = new Set<String>();
        if (isBulk) {
            for (ContentDocumentLink conDocLink : [SELECT Id, 
                                                          ContentDocumentId 
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :UserInfo.getUserId()]) {
                contentDocumentIdsSet.add(conDocLink.ContentDocumentId);
            }
        } else {
            contentDocumentIdsSet.add(contentDocumentId);
        }

        try {
            if (!contentDocumentIdsSet.isEmpty()) {
                delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIdsSet];
            }
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(Label.AEG_Generic_Error_Message);
            ahe.setMessage(Label.AEG_Generic_Error_Message);
            throw ahe;
        }
    }


    /**********************************************************************
     * @description                 Convert content document to attachment
     * 
     * @param  parentId             Parent record of attachment
     * @param  contentDocumentId    Content document Id
     * @return                      Return Id of attachment record
     */
    @AuraEnabled
    public static String convertContentDocumentToAttachment(String parentId, String contentDocumentId) {
        Attachment nAttachment = new Attachment();
        if (String.isNotBlank(contentDocumentId) && String.isNotBlank(parentId)) {
            ContentVersion eContentVersion = [SELECT Id, 
                                                     FileExtension,
                                                     Title,
                                                     VersionData 
                                              FROM ContentVersion 
                                              WHERE ContentDocumentId = :contentDocumentId 
                                              AND IsLatest = True LIMIT 1];

            String fileExtension = eContentVersion.FileExtension == 'jpg' ? 'jpeg' : eContentVersion.FileExtension;
            nAttachment.ParentId = parentId;
            nAttachment.Body = eContentVersion.VersionData;
            nAttachment.Name = eContentVersion.Title;
            nAttachment.ContentType = (fileExtension == 'pdf' ? 'application/' : 'image/') + fileExtension;
            insert nAttachment;
            // Remove content document once done
            removeContentDocuments(contentDocumentId, false);
        }

        return String.isNotBlank(nAttachment.Id) ? String.valueOf(nAttachment.Id) : '';
    }


    /**********************************************************************
     * Fetch available redemption campaign based on the asset and product code
     * 
     * @param  asset                Asset record
     * @param  productCode          Product code
     * @return                      JSON object of available redemption campaigns
     */
    private static String getRedemptionCampaign(Asset asset, String productCode) {
        List<Redemption_Campaigns__c> availableRedCampaignsList = new List<Redemption_Campaigns__c>();
        if (asset != null) {
            String country;
            switch on AEGRedemptionController.communitySettings.Lead_Source__c {
                when 'MYAEG' {
                    country = GlobalConstantUtility.AUSTRALIA;
                }
                when 'MYAEGNZ' {
                    country = GlobalConstantUtility.NEW_ZEALAND;
                }
            }

            Integer gracePeriod = (!Test.isRunningTest() 
                                    ? Integer.valueOf(CommunitySettingsHelper.getSiteSettings(Site.getMasterLabel()).RedemptionGracePeriod__c) 
                                    : 30);
            Date marginalDate = System.today() - (gracePeriod != null ? gracePeriod : 0);

            availableRedCampaignsList = [SELECT Id,
                                                Purchased_Product__c, 
                                                Purchased_Product__r.Customer_Facing_Name__c, 
                                                Purchased_Product__r.ProductCode, 
                                                Purchased_Product__r.Image_URL__c,
                                                Purchased_Product__r.Id,
                                                Redeemed_Item__c, 
                                                Redeemed_Item__r.Customer_Facing_Name__c,
                                                Redeemed_Item__r.SAP_MaterialNumber__c, 
                                                Redeemed_Item__r.ProductCode, 
                                                Redeemed_Item__r.Image_URL__c,
                                                Valid_From__c, 
                                                Valid_To__c, 
                                                Redeemed_Item_Qty__c
                                        FROM Redemption_Campaigns__c
                                        WHERE((Purchased_Product__r.Id = :asset.KitProduct__c 
                                        AND Purchased_Product__r.ProductCode = :productCode) 
                                        OR (Purchased_Product__r.Id = :asset.Product2Id 
                                        AND Purchased_Product__r.ProductCode = :productCode))
                                        AND(Country__c = :country OR Country__c = :GlobalConstantUtility.ANZ)
                                        AND Valid_From__c <= :asset.PurchaseDate
                                        AND Valid_To__c >= :asset.PurchaseDate
                                        AND Valid_From__c <= TODAY
                                        AND Valid_To__c >= :marginalDate];
            
        }
        return JSON.serialize(availableRedCampaignsList);
    }

    /**
     * @description             Will fetch purchased picklist values from custom
     *                          metadata based on the current site
     *
     *                          It will fetch picklist values that is tied to 
     *                          CommonSettings community and the current community
     *                          
     * @return                  List of picklist value
     */
    @AuraEnabled 
    public static String fetchPurchaseFromValues() {
        /** 
            Added Test.isRunningTest in fetching masterlabel due to difficulty
            in accesssing Site.getMasterLabel in test class
         */
        String siteLabel = !Test.isRunningTest() ? Site.getMasterLabel() : 'myAEG';
        Set<String> siteNamesSet = new Set<String>{'CommonSettings', siteLabel};
        List<Purchased_Brand_Mapping__mdt> pBrandsList = new List<Purchased_Brand_Mapping__mdt>();
        if (String.isNotBlank(siteLabel)) {
            pBrandsList = [SELECT Id,
                                  MasterLabel,
                                  DeveloperName,
                                  Order__c,
                                  Asset_Source_Value__c,
                                  Is_Redemption_Applicable__c
                           FROM Purchased_Brand_Mapping__mdt
                           WHERE Community__r.MasterLabel IN :siteNamesSet
                           ORDER BY Order__c DESC];
        }
        return JSON.serialize(pBrandsList);
    }

    /**********************************************************************
     * @description             Wrapper class that will contain the
     *                          result of save and update of
     *                          product registrations
     */
    public class saveProductRegistrationResult { 
        @AuraEnabled
        public boolean error;
        
        @AuraEnabled
        public string message;
        
        @AuraEnabled
        public integer standardWarranty;
        
        @AuraEnabled
        public integer extendedWarranty;
        
        @AuraEnabled
        public integer totalWarrantyYears;
        
        @AuraEnabled
        public string receiptID;
        
        @AuraEnabled
        public string accId;
        
        @AuraEnabled
        public string assetId;
        
        @AuraEnabled
        public string brand;
        
        @AuraEnabled
        public string returnURL;
        
        @AuraEnabled
        public String redemptionCampaignJSON;

        @AuraEnabled
        public List<Asset> assets;

        public saveProductRegistrationResult() {}
        
        public saveProductRegistrationResult(string a, boolean haserror) {
            message = a;
            error = haserror;
        }
    }
}