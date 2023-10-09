/**
* @author                           Kristopher Veraces
* @date                             2020-09-07
*
* @group                            AEG Community
*
* @description                      AEG Redemptions list controller
*/
public without sharing class AgRedemptionsListController {
    private static final String DATE_FORMAT = Label.Default_Date_Format;
    private static final String STATUSES_REQUIRED = 'Redemption status is required.';

    /**********************************************************************
     * @description                 Fetch redemptions of the current user
     * 
     * @param  statuses             Status of records to be fetch
     * @return                      Serialize list of records
     */
    @AuraEnabled
    public static String fetchRedemptions(String statuses) {
        validateData(statuses, STATUSES_REQUIRED);
        List<RedemptionWrapper> wrappers = new List<RedemptionWrapper>();
        Set<String> statusSet = (Set<String>)JSON.deserialize(statuses, Set<String>.class);
        List<Redemptions__c> redemptions = fetchContactRedemptions(statusSet);
        Map<String, Set<String>> recordIds = fetchRecordIds(redemptions);
        Map<String, List<RedeemedProductItem__c>> redeemedItems = fetchRedeemedItems(recordIds.get('redeemedIds'));
        Map<String, List<PurchasedProductLineItem__c>> purchasedProductItems = fetchPurchasedItems(recordIds.get('purchasedIds'));
        for (Redemptions__c redemption : redemptions) {
            RedemptionWrapper wrapper = new RedemptionWrapper(redemption);
            wrapper.redeemedProducts = redeemedItems.get(redemption.RedeemedProducts__c);
            wrapper.purchasedProducts = purchasedProductItems.get(redemption.PurchasedProducts__c);
            wrappers.add(wrapper);
        }
        return JSON.serialize(wrappers);
    }

    private static List<Redemptions__c> fetchContactRedemptions(Set<String> statuses) {
        Contact contact = fetchUserContact();
        return [SELECT Id,
                       Name,
                       Status__c,
                       CreatedDate,
                       Freight_Tracking_URL__c,
                       RedeemedProducts__c,
                       PurchasedProducts__c	
               FROM Redemptions__c
               WHERE Status__c IN :statuses
               AND Name__c = :contact.Id
               AND PurchasedProducts__c != NULL
               AND RedeemedProducts__c != NULL
               ORDER BY CreatedDate
               LIMIT 50000];
    }

    private static Map<String, Set<String>> fetchRecordIds(List<Redemptions__c> redemptions) {
        Map<String, Set<String>> recordsIds = new Map<String, Set<String>>{'redeemedIds' => new Set<String>(), 'purchasedIds' => new Set<String>()} ;
        for (Redemptions__c redemption : redemptions) {
            recordsIds.get('redeemedIds').add(redemption.RedeemedProducts__c);
            recordsIds.get('purchasedIds').add(redemption.PurchasedProducts__c);
        }
        return recordsIds;
    }

    private static Map<String, List<RedeemedProductItem__c>> fetchRedeemedItems(Set<String> recordIds) {
        Map<String, List<RedeemedProductItem__c>> items = new Map<String, List<RedeemedProductItem__c>>();
        for (RedeemedProductItem__c item : [SELECT RedeemedProduct__c, 
                                                   Product__r.Id,
                                                   Product__r.Name,
                                                   Product__r.Image_URL__c 
                                            FROM RedeemedProductItem__c 
                                            WHERE RedeemedProduct__c IN :recordIds
                                            AND Product__c != NULL]) {
            String key = item.RedeemedProduct__c;
            if (!items.containsKey(key)) {
                items.put(key, new List<RedeemedProductItem__c>());
            }
            items.get(key).add(item);
        }
        return items;
    }

    private static Map<String, List<PurchasedProductLineItem__c>> fetchPurchasedItems(Set<String> recordIds) {
        Map<String, List<PurchasedProductLineItem__c>> items = new Map<String, List<PurchasedProductLineItem__c>>();
        for (PurchasedProductLineItem__c item : [SELECT PurchasedProduct__c, 
                                                        Product__r.Id,
                                                        Product__r.Name,
                                                        Product__r.Image_URL__c
                                                 FROM PurchasedProductLineItem__c 
                                                 WHERE PurchasedProduct__c IN :recordIds
                                                 AND Product__c != NULL]) {
            String key = item.PurchasedProduct__c;
            if (!items.containsKey(key)) {
                items.put(key, new List<PurchasedProductLineItem__c>());
            }
            items.get(key).add(item);
        }
        return items;
    }

    /**********************************************************************
     * @description                 Validate Data
     * 
     * @param  value                Value to validate - in string format
     * @param  errorMessage         Error message to display
     */
    private static void validateData(String value, String errorMessage) {
        if (String.isBlank(value)) {
            throw new AgRedemptionsListControllerException(errorMessage);
        }
    }

    /**********************************************************************
     * @description                 Fetch user contact
     * 
     * @return                      Contact record
     */
    private static Contact fetchUserContact() {
        return [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
    }

    /**********************************************************************
     * @description                 Redemption wrapper which will contain
     *                              redemption record and formatted createddate
     */
    public class RedemptionWrapper {
        private Redemptions__c redemption;
        private List<RedeemedProductItem__c> redeemedProducts;
        private List<PurchasedProductLineItem__c> purchasedProducts;
        private String formattedCreatedDate;
        public RedemptionWrapper(Redemptions__c redemption) {
            this.redemption = redemption;
            this.formattedCreatedDate = redemption.CreatedDate.format(DATE_FORMAT);
        }
    }

    public class AgRedemptionsListControllerException extends Exception {}
}