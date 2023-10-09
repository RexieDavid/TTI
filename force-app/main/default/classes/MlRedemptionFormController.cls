/**
 * @author                          Kristopher Veraces
 * @date                            2020-10-26
 *
 * @group                           Milwaukee Community
 *
 * @description                     Milwaukee Redemption Form main controller
*/
public without sharing class MlRedemptionFormController {
    private static final String PAYLOAD_REQUIRED = 'Payload is required in submitting redemption.';
    private static final String CONTENT_DOCUMENT_PREFIX = 'stopgap-';
    private static final String DOCUMENT_DELETE_FILTER = '%stopgap-%';
    private static final String PURCHASED_PRODUCTS_REQUIRED = 'Purchased Products Id is required.';
    private static final String REDEEMABLE_PRODUCTS_REQUIRED = 'Redeemed Products Id is required.';

    @TestVisible
    private static MlRedemptionFormControllerService service = new MlRedemptionFormControllerService();

    /**********************************************************************
     * @description                 Fetch person account details related
     *                              to the current user
     * 
     * @return                      JSON serialize contact
     */
    @AuraEnabled
    public static String getPersonAccountDetails() {
        return service.getPersonAccountDetails();
    }

    /**********************************************************************
     * @description                 Submit redemption which will perform the
     *                              following actions:
     *                                  - Create redemption record
     *                                  - Create receipt record (if any)
     *                                  - Create Asset
     *                                  - Update contact record
     * 
     * @param payload               JSON string of Redemption Info wrapper
     */
    @AuraEnabled
    public static void submitRedemption(String payload) {
        if (String.isBlank(payload)) {
            throw new MlRedemptionFormControllerException(PAYLOAD_REQUIRED);
        }

        RedemptionInfo redemptionInfo = (RedemptionInfo) JSON.deserialize(payload, RedemptionInfo.class);
        if (isValid(redemptionInfo)) {
            if (is24HrsAsyncLimitReached()) {
                submit(redemptionInfo);
            } else {
                submitAsync(payload);
            }
        }
    }

    @AuraEnabled
    public static String getPurchasedAndRedeemedProducts(String payload) {
        if (String.isBlank(payload)) {
            throw new MlRedemptionFormControllerException(PAYLOAD_REQUIRED);
        }

        RedemptionInfo redemptionInfo = (RedemptionInfo) JSON.deserialize(payload, RedemptionInfo.class);

        if (String.isBlank(redemptionInfo.redemptionCampaign.PurchasedProducts__c)) {
            throw new MlRedemptionFormControllerException(PURCHASED_PRODUCTS_REQUIRED);
        }
        
        if (String.isBlank(redemptionInfo.redemptionCampaign.RedeemableProducts__c)) {
            throw new MlRedemptionFormControllerException(REDEEMABLE_PRODUCTS_REQUIRED);
        }     

        redemptionInfo.purchasedProducts = service.getPurchaseProductLineItems(redemptionInfo.redemptionCampaign.PurchasedProducts__c);
        redemptionInfo.redeemableProducts = service.getRedeemableProducts(redemptionInfo.redemptionCampaign.RedeemableProducts__c, false);
        redemptionInfo.redeemableRequiredProducts = service.getRedeemableProducts(redemptionInfo.redemptionCampaign.RedeemableProducts__c, true);

        return JSON.serialize(redemptionInfo);
    }



    /**********************************************************************
     * @description                 Validate payload if valid and 
     *                              haven't reach the @future execution limit
     * 
     * @param redemptionInfo        Redemption info wrapper class
     */
    private static Boolean isValid(RedemptionInfo redemptionInfo) {
        Boolean isValidPayload = redemptionInfo.contact != null && redemptionInfo.redemptionCampaign != null;
        return isValidPayload;
    }

    /**********************************************************************
     * @description                 Verify if async limit reached in the
     *                              past 24 hrs
     */
    private static Boolean is24HrsAsyncLimitReached() {
        /**
         * The maximum number of future method invocations per a 24-hour 
         * period is 250,000 or the number of user licenses in organization 
         * multiplied by 200, whichever is greater
         * 
         * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_System_OrgLimits.htm
         * https://developer.salesforce.com/docs/atlas.en-us.228.0.api_rest.meta/api_rest/dome_limits.htm
         */
        Map<String, OrgLimit> limitsMap = OrgLimits.getMap();
        OrgLimit asyncLimit = limitsMap.get('DailyAsyncApexExecutions'); // Can be found on the second link
        return asyncLimit.getValue() >= asyncLimit.getLimit();
    }

    /**********************************************************************
     * @description                 Run @future processes
     * 
     * @param payload               Stringify redemption info object
     */
    @future
    private static void submitAsync(String payload) {
        RedemptionInfo redemptionInfo = (RedemptionInfo) JSON.deserialize(payload, RedemptionInfo.class);
        submit(redemptionInfo);
    }

    /**********************************************************************
     * @description                 Submit and create redemption records
     * 
     * @param redemptionInfo        Redemption info wrapper class
     */
    @TestVisible
    private static void submit(RedemptionInfo redemptionInfo) {
        Savepoint sp = Database.setSavepoint();
        Exception exceptionObj;
        Boolean hasError = false;
        String purchasedProductId;
        String redeemedProductId;
        String redemptionId;

        try {

            //Added By: KB - SD-2045 (part of solution for multiline redemption)
            purchasedProductId = createPurchasedProduct();
            createPurchasedItems(redemptionInfo.redemptionCampaign, purchasedProductId);
            redeemedProductId = createRedeemedProducts(redemptionInfo);
            redemptionId = createRedemption(redemptionInfo, purchasedProductId,redeemedProductId);
            //SD-2045 update END

            createAssets(redemptionInfo,redemptionId);

        } catch(Exception ex) {
            hasError = true;
            exceptionObj = ex;
        }

        if (!hasError) {
            try {
                updateContact(JSON.serialize(redemptionInfo.contact));
                //Added By: KB - SD-2045 (part of solution for multiline redemption)
                updatePurchasedAndRedeemedProduct(redemptionId, purchasedProductId, redeemedProductId);
                //SD-2045 update END

            } catch(Exception ex) {
                system.debug('*** 2nd catch');
                hasError = true;
                exceptionObj = ex;
            }
        }

        if (hasError) {
            Database.rollback(sp);
            LoggerUtility.logException(exceptionObj, JSON.serialize(redemptionInfo));
            // throw new MlRedemptionFormControllerException(Label.Generic_Error_Message);
            
            throw new MlRedemptionFormControllerException(exceptionObj.getMessage() + ', Line number: ' + exceptionObj.getLineNumber() );
        }
    }

    //Added By: KB - SD-2045 (part of solution for multiline redemption)
    private static void updatePurchasedAndRedeemedProduct(String redemptionId, String purchasedProductId, String redeemedProductId) {
        List<Redemptions__c> lstRedemptions = [Select Id FROM Redemptions__c WHERE ID =: redemptionId];
        List<PurchasedProducts__c> lstPurchasedProducts = [Select Id,Related_Redemption__c FROM PurchasedProducts__c WHERE ID =: purchasedProductId];
        List<RedeemedProducts__c> lstRedeemProducts = [Select Id,Related_Redemption__c FROM RedeemedProducts__c WHERE ID =: redeemedProductId];

        PurchasedProducts__c purProd = new PurchasedProducts__c();
        if(lstPurchasedProducts.size() > 0){
            purProd.Id = lstPurchasedProducts[0].Id;
        }
        if(lstRedemptions.size() > 0){
            purProd.Related_Redemption__c = lstRedemptions[0].Id;
        }
        service.upsertRecord(purProd);

        RedeemedProducts__c redProd = new RedeemedProducts__c();
        if(lstRedeemProducts.size() > 0){
            redProd.Id = lstRedeemProducts[0].Id;
        }
        if(lstRedemptions.size() > 0){
            redProd.Related_Redemption__c = lstRedemptions[0].Id;
        }
        service.upsertRecord(redProd);
    }

    private static String createPurchasedProduct() {
        PurchasedProducts__c purchasedProd = new PurchasedProducts__c();
        return service.upsertRecord(purchasedProd);
    }

    private static void createPurchasedItems(Redemption_Campaigns__c campaign, String purchasedProductId) {
        List<PurchasedProductLineItem__c> lstPPLI = new List<PurchasedProductLineItem__c>();
        List<PurchasedProductLineItem__c> lstPPLIToCreate = new List<PurchasedProductLineItem__c>();

        lstPPLI = [SELECT Id, PurchasedProduct__c, Product__c, Quantity__c, Required__c, Purchased__c FROM PurchasedProductLineItem__c WHERE PurchasedProduct__c =: campaign.PurchasedProducts__c];
        
        if(lstPPLI.size() > 0){
            for(PurchasedProductLineItem__c ppli : lstPPLI){
                PurchasedProductLineItem__c newppli = new PurchasedProductLineItem__c();
                newppli.Product__c = ppli.Product__c;
                newppli.Quantity__c = ppli.Quantity__c;
                newppli.Required__c = ppli.Required__c;
                newppli.PurchasedProduct__c = purchasedProductId;
                if(ppli.Required__c){
                    newppli.Purchased__c = true;
                }
                lstPPLIToCreate.add(newppli);
            }
            if(lstPPLIToCreate.size() > 0){
                service.upsertRecords(lstPPLIToCreate);
            }
        }
    }
    //SD-2045 update END

    /**********************************************************************
     * @description                 Create and insert asset record related 
     *                              to contact and account
     * 
     *                              Execute asset, redemption, and
     *                              receipt record creation in @future
     *                              context
     * 
     * @param redemptionInfo        Redemption info wrapper class
     */
    private static void createAssets(RedemptionInfo redemptionInfo, String redemptionId) {

        List<Asset> assetsToCreate = new List<Asset>();
        //String redeemedProductId = createRedeemedProducts(redemptionInfo);
        //String redemptionId = createRedemption(redemptionInfo, purchasedProductId,redeemedProductId);
        String receiptId = null;

        if (redemptionInfo.fileId != null) {
            receiptId = createReceipt(redemptionInfo);
        }

        for (PurchasedProductLineItem__c purchasedProductLineItem : redemptionInfo.purchasedProducts) {
            Asset asset = new Asset();
            asset.Product2Id = purchasedProductLineItem.Product__c;
            asset.AccountId = redemptionInfo.account.Id;
            asset.ContactId = redemptionInfo.contact.Id;
            asset.Name = 'Temporary Name';
            asset.Purchased_Online__c = 'In-Store';
            asset.Redeemed__c = true;
            asset.Redemption__c = redemptionId;
            asset.Receipt__c = receiptId;
            assetsToCreate.add(asset); 
        }

        service.upsertRecords(assetsToCreate);
    }

    /**********************************************************************
     * @description                 Create and insert redemption record
     * 
     * @param redemptionInfo        Redemption info wrapper class
     * 
     * @return                      Record Id
     */
    private static String createRedemption(RedemptionInfo redemptionInfo, String purchasedProductId, String redeemedProductId) {
        Redemptions__c redemption = new Redemptions__c();
        redemption.Status__c = 'Submitted';
        redemption.PurchasedProducts__c = purchasedProductId; //Added By: KB 12/13/22 - SD-2045 (part of solution for multiline redemption)
        //redemption.PurchasedProducts__c = redemptionInfo.redemptionCampaign.PurchasedProducts__c;
        redemption.RedeemedProducts__c = redeemedProductId; //Added By: KB 12/13/22 - SD-2045 (part of solution for multiline redemption)
        //redemption.RedeemedProducts__c = createRedeemedProducts(redemptionInfo);
        redemption.Name__c = redemptionInfo.contact.Id; 
        redemption.Brand__c = redemptionInfo.contact.Brand__c;
        redemption.Redemption_Campaign__c = redemptionInfo.redemptionCampaign.Id;

        redemption.Store_Name_Free_Text__c = redemptionInfo.storeName;
        redemption.Store_Suburb_Free_Text__c = redemptionInfo.storeSuburb;

        redemption.Captured_FirstName__c = redemptionInfo.account.FirstName;
        redemption.Captured_Surname__c = redemptionInfo.account.LastName;
        redemption.Captured_Company__c = redemptionInfo.account.Company_Name__c;
        redemption.Captured_Mobile__c = redemptionInfo.account.PersonMobilePhone;
        redemption.Captured_Phone__c = redemptionInfo.account.Phone;
        redemption.Captured_Email_Address__c = redemptionInfo.account.PersonEmail;
        redemption.Captured_Street_Number__c = redemptionInfo.account.MRAddressStreetNumber__c;
        redemption.Captured_Street_Address__c = redemptionInfo.account.MRAddressRoute__c;
        redemption.Captured_Suburb__c = redemptionInfo.account.PersonMailingCity;
        redemption.Captured_Region__c = redemptionInfo.account.PersonMailingState;
        redemption.Captured_Postcode__c = redemptionInfo.account.PersonMailingPostalCode;

        return service.upsertRecord(redemption);
    }

    /**********************************************************************
     * @description                 Create and insert receipt record
     * 
     * @param redemptionInfo        Redemption info wrapper class
     * 
     * @return                      Record Id
     */
    private static String createReceipt(RedemptionInfo redemptionInfo) {
        ContentVersion file = service.fetchContentVersion(redemptionInfo.fileId);
        Receipts__c receipt = new Receipts__c(
            Account__c = redemptionInfo.account.Id,
            Receipt_Name__c = file.Title.substringAfter(CONTENT_DOCUMENT_PREFIX)
        );
        String recordId = service.upsertRecord(receipt);
        linkAttachmentToReceipt(file, recordId);
        service.deleteContentDocuments(DOCUMENT_DELETE_FILTER);
        return recordId;
    }

    /**********************************************************************
     * @description                 Update contact record. 
     * 
     *                              Will execute in different thread to 
     *                              lessen processing time.
     * 
     * @param payload               JSON string of contact
     */
    private static void updateContact(String contactJSON) {
        service.upsertRecord((Contact)JSON.deserialize(contactJSON, Contact.class));
    }

    /**********************************************************************
     * @description                 Convert content document to attachment
     * 
     *                              Will execute in different thread
     * 
     * @param  parentId             Parent record of attachment
     * @param  fileName             Attachment name
     * @param  contentDocumentId    Content document Id
     * 
     */
    public static void linkAttachmentToReceipt(ContentVersion file, String parentId) {
        if (String.isNotBlank(parentId)) {
            Attachment nAttachment = new Attachment();
            String fileExtension = file.FileExtension.equalsIgnoreCase('jpg') ? 'jpeg' : file.FileExtension;
            String fileName = file.Title.substringAfter(CONTENT_DOCUMENT_PREFIX);
            nAttachment.ParentId = parentId;
            nAttachment.Body = file.VersionData;
            nAttachment.Name = fileName;
            nAttachment.ContentType = (fileExtension == 'pdf' ? 'application/' : 'image/') + fileExtension;
            service.upsertRecord(nAttachment);
        }
    }

    /**********************************************************************
     * @description                 Update the Content Document Record
     */
    @AuraEnabled
    public static void changeContentDocuments(Id recordId) {
        updateDocumentName(recordId);
    }

    /**********************************************************************
     * @description                 Add 'stopgap-' at the the start of document
     *                              title for deletion later
     * 
     * @param documentId            Document record Id to update
     * 
     */
    @future
    private static void updateDocumentName(String documentId) {
        ContentDocument document = service.fetchContentDocument(documentId);
        document.Title = CONTENT_DOCUMENT_PREFIX + document.Title;
        service.upsertRecord(document);
    } 

    /**********************************************************************
     * @description                 Delete content document records
     */
    @AuraEnabled
    public static void removeContentDocuments() {
        deleteContentDocuments();
    }

    /**********************************************************************
     * @description                 Delete content document with
     *                              'stopgap-' in title
     */
    @future
    private static void deleteContentDocuments() {
        service.deleteContentDocuments(DOCUMENT_DELETE_FILTER);
    }

    private static Id createRedeemedProducts(RedemptionInfo redemptionInfo) {
        String parentId = createRedeemedProduct();
        Boolean isAllRedeemable = redemptionInfo.redemptionCampaign.RedeemableProducts__r.RedeemType__c == 'All';
        List<RedeemedProductItem__c> redeemedProducts = new List<RedeemedProductItem__c>();
        for (RedeemableProductItem__c redeemableProduct : [SELECT Id, 
                                                                  Product__c, 
                                                                  Quantity__c,
                                                                  Required__c
                                                          FROM RedeemableProductItem__c 
                                                          WHERE RedeemableProduct__c = :redemptionInfo.redemptionCampaign.RedeemableProducts__c]) {
            if (isAllRedeemable) {
                redeemedProducts.add(createRedeemedProduct(redeemableProduct, parentId));
            } else {
                if(redeemableProduct.Required__c == true){
                    redeemedProducts.add(createRedeemedProduct(redeemableProduct, parentId));
                }else{
                    if (redeemableProduct.Id == redemptionInfo.selectedItem) {
                        redeemedProducts.add(createRedeemedProduct(redeemableProduct, parentId));
                    }
                }
            }
        }

        insert redeemedProducts;
        return parentId;
    }

    private static String createRedeemedProduct() {
        RedeemedProducts__c redeemedProduct = new RedeemedProducts__c();
        insert redeemedProduct;
        return redeemedProduct.Id;
    }

    private static RedeemedProductItem__c createRedeemedProduct(RedeemableProductItem__c item, String parentId) {
        return new RedeemedProductItem__c(
                Product__c = item.Product__c,
                Quantity__c = item.Quantity__c,
                RedeemedProduct__c = parentId
        );
    }

    /**
     * Redemption Info wrapper class
     */
    public class RedemptionInfo {
        public Account account;
        public Contact contact;
        public Redemption_Campaigns__c redemptionCampaign;
        public List<PurchasedProductLineItem__c> purchasedProducts;
        public List<RedeemableProductItem__c> redeemableProducts;
        public List<RedeemableProductItem__c> redeemableRequiredProducts;
        public String storeName;
        public String storeSuburb;
        public String fileId;
        public String selectedItem;
    }

    /**
     * File Info wrapper class
     */
    public class FileData {
        public String name;
        public String blobData;
        public String fileExtension;
        public String id;
    }

    public class MlRedemptionFormControllerException extends Exception {}
}