/**
 * @author                          Kristopher Veraces
 * @date                            2020-10-26
 *
 * @group                           Milwaukee Community
 *
 * @description                     Milwaukee Redemption Form Service
*/
public class MlRedemptionFormControllerService {
    private final String ASSET_ID_REQUIRED = 'Asset record Ids are required.';
    private final String ACCESS_DENIED = 'Access denied for either User or Contact record.';
    private final String CONTENT_DOCUMENT_ID_REQUIRED = 'Content Document record Id is required.';
    private final String FILTER_REQUIRED = 'Filter is required.';
    private final String MASTER_LABEL_REQUIRED = 'Master Label is required.';
    private final String SOBJECT_REQUIRED = 'SObject record is required.';
    private final String SOBJECTS_REQUIRED = 'SObject records are required.';

    /**********************************************************************
     * @description                 Fetch person account details related
     *                              to the current user
     * 
     * @return                      JSON serialize contact
     */
    public String getPersonAccountDetails() {
        Boolean hasAccess = User.sObjectType.getDescribe().isQueryable() && Contact.sObjectType.getDescribe().isAccessible();
        if (!Test.isRunningTest() && !hasAccess) {
            throw new MlRedemptionFormControllerServiceException(this.ACCESS_DENIED);
        }

        Contact contact;
        try {
            contact = [SELECT Id,
                            Name,
                            MobilePhone,
                            Email,
                            MailingStreet,
                            MailingState,
                            MailingPostalCode,
                            MailingCountry,
                            MailingCity,
                            Brand__c,
                            FirstName,
                            LastName,
                            AccountId,
                            Account.Name,
                            Account.FirstName,
                            Account.LastName,
                            Account.Company_Name__c,
                            Account.PersonMobilePhone,
                            Account.Phone,
                            Account.PersonEmail,
                            Account.MRAddressStreetNumber__c,
                            Account.MRAddressRoute__c,
                            Account.PersonMailingCity,
                            Account.PersonMailingState,
                            Account.PersonMailingPostalCode
                        FROM Contact
                        WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()) 
                        LIMIT 1];
        } catch (Exception ex) {
            //TODO: Sentry logging implementation
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }

        return JSON.serialize(contact);
    }

    /**********************************************************************
     * @description                 Fetch site settings
     * 
     * @return                      Community Settings metadata
     */
    public Community_Setting__mdt getSiteSettings(String masterLabel) {
        if (String.isBlank(masterLabel)) {
            throw new MlRedemptionFormControllerServiceException(this.MASTER_LABEL_REQUIRED);
        }
        return CommunitySettingsHelper.getSiteSettings(masterLabel);
    }

    /**********************************************************************
     * @description                 Fetch Purchased Product Line Items
     * 
     * @return                      List of Purchased Product Line Item
     */
    public List<PurchasedProductLineItem__c> getPurchaseProductLineItems(String purchasedProductsId) {
        List<PurchasedProductLineItem__c> purchasedProducts = new List<PurchasedProductLineItem__c>();

        try {
            purchasedProducts =  [
                SELECT Id,
                       ProductModel__c,
                       Product__c,
                       Product__r.Customer_Facing_Name__c,
                       Product__r.Name,
                       Quantity__c,
                       PurchasedProduct__c
                FROM PurchasedProductLineItem__c
                WHERE PurchasedProduct__c = :purchasedProductsId
            ];
        } catch (Exception ex) {
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }
        
        return purchasedProducts;
    }

    /**********************************************************************
     * @description                 Fetch Redeemable Product Items
     * 
     * @return                      List of Redeemable Product Item
     */
    public List<RedeemableProductItem__c> getRedeemableProducts(String redeemableProductsId, Boolean isRequired) {
        List<RedeemableProductItem__c> redeemableProducts = new List<RedeemableProductItem__c>();

        try {
            if(isRequired){
                redeemableProducts =  [
                    SELECT Id,
                        ProductModel__c,
                        Product__c,
                        Product__r.Customer_Facing_Name__c,
                        Product__r.Name,
                        Quantity__c,
                        Required__c
                    FROM RedeemableProductItem__c
                    WHERE RedeemableProduct__c = :redeemableProductsId
                      AND Required__c = TRUE
                ];
            }else{
                redeemableProducts =  [
                    SELECT Id,
                        ProductModel__c,
                        Product__c,
                        Product__r.Customer_Facing_Name__c,
                        Product__r.Name,
                        Quantity__c,
                        Required__c
                    FROM RedeemableProductItem__c
                    WHERE RedeemableProduct__c = :redeemableProductsId
                      AND Required__c = FALSE
                ];
            }
        } catch (Exception ex) {
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }
        
        return redeemableProducts;
    }

    /**********************************************************************
     * @description                 Upsert record
     * 
     * @param sobj                  Record to upsert
     * 
     * @return                      Id
     */
    public String upsertRecord(SObject sobj) {
        if (sobj == null) {
            throw new MlRedemptionFormControllerServiceException(this.SOBJECT_REQUIRED);
        }

        try {
            upsert sobj;
        } catch (Exception ex) {
            //TODO: Sentry logging implementation
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }
        return (String)sobj.get('Id');
    }

    /**********************************************************************
     * @description                 Upsert records
     * 
     * @param sobj                  Records to upsert
     * 
     * @return                      Ids
     */
    public List<String> upsertRecords(List<SObject> sobjs) {
        List<String> newIds = new List<String>();
        if (sobjs.isEmpty()) {
            throw new MlRedemptionFormControllerServiceException(this.SOBJECTS_REQUIRED);
        }

        try {
            upsert sobjs;
        } catch (Exception ex) {
            //TODO: Sentry logging implementation
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }

        for (SObject sobj : sobjs) {
            newIds.add((String)sobj.get('Id'));
        }

        return newIds;
    }

    /**********************************************************************
     * @description                 Fetch specific content version of 
     *                              specific content document
     * 
     * @param contentDocumentId     Content Document Id
     * 
     * @return                      Content Version
     */
    public ContentVersion fetchContentVersion(String contentDocumentId) {
        if (String.isBlank(contentDocumentId)) {
            throw new MlRedemptionFormControllerServiceException(this.CONTENT_DOCUMENT_ID_REQUIRED);
        }

        return [SELECT VersionData,
                       FileExtension,
                       Title
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId
                AND IsLatest = True 
                LIMIT 1];
    }

    /**********************************************************************
     * @description                 Fetch content document
     * 
     * @param contentDocumentId     Content Document Id
     * 
     * @return                      Content Document
     */
    public ContentDocument fetchContentDocument(String contentDocumentId) {
        if (String.isBlank(contentDocumentId)) {
            throw new MlRedemptionFormControllerServiceException(this.CONTENT_DOCUMENT_ID_REQUIRED);
        }

        return [SELECT Id, Title FROM ContentDocument WHERE Id = :contentDocumentId];
    }

    /**********************************************************************
     * @description                 Delete content documents with specific
     *                              filter
     * 
     * @param filter                SOQL filter
     */
    public void deleteContentDocuments(String filter) {
        if (String.isBlank(filter)) {
            throw new MlRedemptionFormControllerServiceException(this.FILTER_REQUIRED);
        }

        Set<String> contentDocumentIds = this.fetchToDeleteContentDocuments(filter);
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
        } catch (Exception ex) {
            //TODO: Sentry logging implementation
            throw new MlRedemptionFormControllerServiceException(Label.Generic_Error_Message);
        }
    }

    /**********************************************************************
     * @description                 Fetch to delete content documents
     *                              that matches the filter
     * 
     * @param filter                SOQL filter
     * 
     * @return                      Set of record Ids
     */
    private Set<String> fetchToDeleteContentDocuments(String filter) {
        Set<String> contentDocumentIds = new Set<String>();
        for (ContentDocumentLink conDocLink : [SELECT ContentDocumentId
                                               FROM ContentDocumentLink 
                                               WHERE LinkedEntityId = :UserInfo.getUserId() 
                                               AND ContentDocument.title LIKE :filter]) {
            contentDocumentIds.add(conDocLink.ContentDocumentId);
        }
        return contentDocumentIds;
    }

    public class MlRedemptionFormControllerServiceException extends Exception {}
}