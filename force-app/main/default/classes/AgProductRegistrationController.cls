/**
* @author Francis Nasalita
* @date 2020-06-02
*
* @group Aeg Community
* @group-content ../../ApexDocContent/aeg-community.html
*
* @description The AEG Product Registration controller
*/
public without sharing class AgProductRegistrationController {
    private static final String BRAND_NAME = 'AEG';
    public static final String ERROR_USER_CANNOT_REGISTER = 'This user is not permitted to register tools.';

    /**********************************************************************
    * @description                 Save asset record and fetch available redemption 
    *                              campaign
    * @param  assets               Asset to save
    * @param  isFromValidRetailer  Is purchased item from valid retailer
    * @param  filename             File name of bunning receipt
    * @param  productCode          Product code of purchased item
    * @param  isCustomMedata       Is custom metadata
    * @param  contentDocumentId    Content Document Id of purchased item
    * @param  retailerSource        Where the purchased item is from
    * @return                      saveProductRegistrationResult which contains
    *                              asset information and redemption campaign
    *
    * @example
    * AgProductRegistrationController.saveProductRegistration(new List<Asset>{Asset}, '', '', '', true, '');
    */
    @AuraEnabled
    public static saveProductRegistrationResult saveProductRegistration(
            List<Asset> assets, 
            String isFromValidRetailer, 
            String filename, 
            String productCode, 
            Boolean isCustomMedata, 
            String contentDocumentId, 
            String retailerSource) { 

        Savepoint sp = Database.setSavepoint();
        try {
            saveProductRegistrationResult result = new saveProductRegistrationResult();
            User currentUser = getUserDetails();
            String receiptId = getReceiptId(filename, currentUser.Contact.AccountId, isFromValidRetailer, retailerSource);
            if (String.isNotBlank(contentDocumentId)) {
                convertContentDocumentToAttachment(receiptId, contentDocumentId);
            }
            List<Asset> updatedAssets = getAssets(assets, isCustomMedata, currentUser, receiptId);
            result.assets = updatedAssets;
            result.redemptionCampaignJSON = getRedemptionCampaignJSON(currentUser, updatedAssets);
            result.receiptID = receiptId;
            result.brand = TTIUtilClass.getBrandCurrentUser();
            if (updatedAssets.size() == 1) {
                Asset asset = updatedAssets[0];
                result.standardWarranty = getWarrantyValue(asset.Standard_Warranty_Months__c);
                result.extendedWarranty = getWarrantyValue(asset.Extended_Warranty_Months__c);
                result.totalWarrantyYears = getWarrantyValue(asset.Total_Warranty_Years__c);        
                result.accId = asset.AccountId;
                result.assetId = asset.Id;
            }
            if(String.isNotBlank(currentUser.Used_Referral_Code__c) && currentUser.RAF_Case_Created__c!=true){ 
                String recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Refer a Friend cases').getRecordTypeId();
                Case referralCase = new Case(recordtypeID =recordTypeId,TTI_Customer_Contact_email__c=currentUser.Email,
                                            Case_Country__c=currentUser.Country,FirstName__c=currentUser.firstName,
                                             LastName__c=currentUser.lastname,Used_referral_Code__c=currentUser.Used_referral_Code__c,
                                             Subject='Refer By Friend', Brand__c = TTIUtilClass.getBrandCurrentUser());
                insert referralCase;  
                currentUser.RAF_Case_Created__c=true;
                update currentUser;
            }
            return result; 
        } catch(Exception e) {
            Database.rollback(sp);
            return new saveProductRegistrationResult('\\RDAVID '+ e.getLineNumber() + e.getMessage(), true);
        }
    }
    
    private static User getUserDetails() {
        User user =  [SELECT Id, 
                             ContactId, 
                             firstName,
                             lastname,
                             Contact.Accountid, 
                             Country,
                             email,
                             RAF_Case_Created__c,
                             Used_Referral_Code__c                             
                      FROM User 
                      WHERE Id = :Userinfo.getUserId()
                      LIMIT 1];
        if (user.ContactId == null || user.Contact.Accountid == null) {
            throw new AgProductRegistrationControllerException(ERROR_USER_CANNOT_REGISTER);
        }

        return user;
    }

    private static List<Asset> getAssets(List<Asset> payload, Boolean isCustomMetadata, User currentUser, String receiptId) {
        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < payload.size(); i++) {
            Asset asset = payload[i];
            asset.AccountId = currentUser.Contact.accountid;
            asset.ContactId = currentUser.ContactId;
            asset.Status = CommunitySettingsHelperClass.getAssetCreateStatus();
            if (!isCustomMetadata) {
                asset.AssetSource__c = CommunitySettingsHelper.mapPurchasedFrom(asset.AssetSource__c);
            }
            asset.IdentifiedBy__c = CommunitySettingsHelperClass.getAssetDefaultIdentifiedBy();
            asset.WarrantyStatus__c = CommunitySettingsHelperClass.getAssetDefaultWarrantyStatus();
            //only set the first asset in the kit to true - this is used for workfow for kits
            asset.KitRegistrationTrigger__c = i == 0;
            asset.Receipt__c = receiptId;
            assets.add(asset);
        }
        insert assets;
        return getUpdatedAssets(assets);
    }

    private static List<Asset> getUpdatedAssets(List<Asset> assets) {
        return [SELECT Id,
                       Product2Id,
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
                       KitProduct__c,
                       Product2.AU_ListPrice__c,
                       Product2.NZ_ListPrice__c,
                       Product2.Category_Customer_Level2__c,
                       Product2.Customer_Facing_Name__c
                FROM Asset 
                WHERE Id IN :assets];
    }

    private static String getReceiptId(String fileName, String accountId, String isFromValidRetailer, String retailerSource) {
        Receipts__c receipt = insertReceipt(filename, 
                                            accountId, 
                                            isFromValidRetailer == 'Yes', 
                                            retailerSource);
        return receipt.Id;
    }

    private static String getRedemptionCampaignJSON(User currentUser, List<Asset> assets) {
        Boolean isValidCountry = isValidCountry(currentUser.country);
        String response = null;
        if (isValidCountry) {
            Boolean isSameKit = isSameKit(assets);
            if (isSameKit) {
                response = getRedemptionCampaign(currentUser.Contact.AccountId, assets[0].Id);
            }
        }
        return response;
    }

    private static Boolean isValidCountry(String country) {
        if (String.isBlank(country)) {
            return false;
        }
        Set<String> validCountries = new Set<String>{ 'australia', 'new zealand' };
        return validCountries.contains(country.toLowerCase());
    }

    private static Boolean isSameKit(List<Asset> assets) {
        Boolean isSameKit = assets.size() == 1;
        if (assets.size() > 1) {
            for(Integer i = 1; i < assets.size(); i++) {
                isSameKit = assets[0].KitProduct__c == assets[i].KitProduct__c;
                if (isSameKit) {
                    break;
                }
            }
        }
        return isSameKit;
    }

    private static Integer getWarrantyValue(Decimal warranty) {
        return warranty != null ? warranty.intValue() : 0;
    }
        
    /**********************************************************************
    * @description                 update asset record 
    *                              campaign
    * @param  updatedAsset         Asset to update
    * @param  isBunningReceipt     Is bunning receipt
    * @param  filename             File name of bunning receipt
    * @return                      saveProductRegistrationResult which contains
    *                              asset information
    *
    * @example
    * AgProductRegistrationController.updateProductRegistration(new List<Asset>{Asset}, '', '');
    */
    @AuraEnabled
    public static saveProductRegistrationResult updateProductRegistration(Asset updatedAsset, String isBunningReceipt, String filename) {
        User currentUser = [SELECT id, contactId, contact.accountid  from User where id = :Userinfo.getUserId()];
        Asset oldAsset = [SELECT id,  Receipt__c, PurchaseDate, SerialNumber, SerialNumberWeek__c, SerialNumberYear__c from Asset where id = :updatedAsset.Id];
        
        if (currentUser.contactId == null) {
            return new saveProductRegistrationResult(ERROR_USER_CANNOT_REGISTER, true);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            Receipts__c receipt = new Receipts__c();
            if (filename == 'NoFile') {
                receipt = [SELECT id,  ReceiptSource__c from Receipts__c where id = :oldAsset.Receipt__c];
                
                if (receipt != null) {
                    if (isBunningReceipt == 'Yes' && receipt.ReceiptSource__c == CommunitySettingsHelperClass.mapReceiptSource('Other')) { 
                        receipt.ReceiptSource__c = CommunitySettingsHelperClass.mapReceiptSource('Bunnings');
                    } else if (isBunningReceipt != 'Yes' && receipt.ReceiptSource__c == CommunitySettingsHelperClass.mapReceiptSource('Bunnings')) {
                        receipt.ReceiptSource__c = CommunitySettingsHelperClass.mapReceiptSource('Other');
                    } else {
                        receipt.ReceiptSource__c = null;
                    }
                    update receipt;
                } 
            } else {
                receipt = insertReceipt(filename, string.valueOf(currentUser.contact.accountid), isBunningReceipt == 'Yes', 'Bunnings');
            }
            
            oldAsset.Receipt__c =  receipt.Id;
            oldAsset.AssetSource__c = CommunitySettingsHelperClass.mapPurchasedFrom(updatedAsset.AssetSource__c);
            oldAsset.Asset_Source_Other__c= updatedAsset.Asset_Source_Other__c;
            oldAsset.PurchaseDate = updatedAsset.PurchaseDate;
            oldAsset.SerialNumber = updatedAsset.SerialNumber;
            oldAsset.SerialNumberWeek__c = updatedAsset.SerialNumberWeek__c;
            oldAsset.SerialNumberYear__c = updatedAsset.SerialNumberYear__c;
            update oldAsset;
            
            Asset result = [SELECT Id, Name, Standard_Warranty_Months__c, Extended_Warranty_Months__c, Total_Warranty_Years__c FROM Asset WHERE Id = :oldAsset.id];
            
            saveProductRegistrationResult r = new saveProductRegistrationResult();
            r.receiptID =receipt.Id;
            r.standardWarranty = result.Standard_Warranty_Months__c.intValue();
            r.extendedWarranty = result.Extended_Warranty_Months__c.intValue();
            r.totalWarrantyYears = result.Total_Warranty_Years__c.intValue();
            
            return r;
        } catch(Exception e) {
            Database.rollback(sp);
            return new saveProductRegistrationResult(e.getMessage(), true);
        }
    }
        
    /**********************************************************************
    * @description                 save receipt record 
    *
    * @param  name                 Receipt name
    * @param  accountID            Account where the receipt will be link
    * @param  isFromValidRetailer     Is receipt from Bunnings store
    * @param  retailerSource        Where the purchased item is from
    * @return                      Receipts__c receipt information
    *
    * @example
    * AgProductRegistrationController.insertReceipt('filename', '001xxx', true);
    */
    private static Receipts__c insertReceipt(string name, string accountID, boolean isFromValidRetailer, string retailerSource) {
        String mapReceiptSource = CommunitySettingsHelperClass.mapReceiptSource(retailerSource);
        String mapOtherReceiptSource = CommunitySettingsHelperClass.mapReceiptSource('Other');
        
        Receipts__c receipt = new Receipts__c();
        receipt.Account__c =  accountID;
        receipt.Receipt_Name__c = name;
        receipt.ReceiptSource__c = isFromValidRetailer && mapReceiptSource != null ? mapReceiptSource : mapOtherReceiptSource;

        insert receipt;
        return receipt;  
    }    
        
    /**********************************************************************
    * @description                 Retrieves community settings
    *
    * @return                      SiteSettingsResult community settings
    *
    * @example
    * AgProductRegistrationController.SiteSettingsResult();
    */
    @AuraEnabled
    public static Community_Setting__mdt getSiteSettings() {
        return CommunitySettingsHelper.getSiteSettings(Site.getMasterLabel());
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
    public static void convertContentDocumentToAttachment(String parentId, String contentDocumentId) {
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
    }

    public static String getRedemptionCampaign(String accountId, String assetId) {
        AgRedemptionService.AgRedemptionServicePayload payload = buildPayload(accountId, assetId);
        AgRedemptionService service = new AgRedemptionService(payload);
        return JSON.serialize(service.fetchCampaigns());
    }

    private static AgRedemptionService.AgRedemptionServicePayload buildPayload(String accountId, String assetId) {
        return new AgRedemptionService.AgRedemptionServicePayload()
            .setAccountId(accountId)
            .setAssetId(assetId);
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

    public class AgProductRegistrationControllerException extends Exception {}
}