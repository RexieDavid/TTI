/**
 * @description                     Main controller for MlCatalogueForm lightning web component
 *  
 *                                  Disregard sharing rules due to the limitations wherein
 *                                  community user can't access lead records. See link for
 *                                  reference:
 *                                  https://help.salesforce.com/s/articleView?id=sf.users_license_types_communities.htm&type=5
 */
public without sharing class MlCatalogueFormController {
    private static final String LEAD_QUEUE_OWNER = 'Catalogue_Campaign_Submissions';
    private static final String SEARCH_LEAD_ERROR = 'Must provide email and campaign year.';
    private static final String SEARCH_MARKETING_CAMPAIGN_ERROR = 'Must provide account details.';
    private static final String LEAD_SOURCE = 'Web Page - Milwaukee';
    private static final String LEAD_COMMENT_WILDCARD = '%Catalogue 2022%';
    private static final String MARKETING_TYPE = 'Catalogue_Campaign_2022';

    /**
     * @description                 Fetch existing lead for user. Determined by
     *                              the following:
     *                                  - Email
     *                                  - LeadSource
     *                                  - Comments__c
     */
    @AuraEnabled(cacheable=true)
    public static String fetchExistingLeadId(String email, Integer startCampaignYear) {
        if (String.isBlank(email) || startCampaignYear == null) {
            throw new MlCatalogueFormControllerException(SEARCH_LEAD_ERROR);
        }

        List<Lead> leads = [SELECT Id
                            FROM Lead
                            WHERE Email = :email
                            AND LeadSource = :LEAD_SOURCE
                            AND Comments__c LIKE :LEAD_COMMENT_WILDCARD
                            AND CALENDAR_YEAR(CreatedDate) >= :startCampaignYear
                            LIMIT 1];
        if (leads.isEmpty()) {
            return '';
        }
        return leads[0].Id;
    }

    /**
     * @description                 Fetch existing lead for user. Determined by
     *                              the following:
     *                                  - Person Account
     */
    @AuraEnabled(cacheable=true)
    public static String fetchExistingMarketingCampaignId(String accountId) {
        if (String.isBlank(accountId)) {
            throw new MlCatalogueFormControllerException(SEARCH_MARKETING_CAMPAIGN_ERROR);
        }

        String recordtypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName().get(MARKETING_TYPE).getRecordTypeId();
        List<Marketing_Campaign__c> campaigns = [SELECT Id
                                                 FROM Marketing_Campaign__c
                                                 WHERE Person_Account__c = :accountId
                                                 AND RecordTypeId = :recordtypeId
                                                 LIMIT 1];
        if (campaigns.isEmpty()) {
            return '';
        }
        return campaigns[0].Id;
    }

    /**
     * @description                 Fetch lead queue owner
     */
    @AuraEnabled(cacheable=true)
    public static String fetchLeadOwnerId() {
        List<Group> groups = [SELECT Id 
                              FROM Group 
                              WHERE DeveloperName = :LEAD_QUEUE_OWNER
                              AND Type = 'Queue'];
        if (groups.isEmpty()) {
            return '';
        }
        return groups[0].Id;
    }

    /**
     * @description                 Custom exception
     */
    private class MlCatalogueFormControllerException extends Exception {}
}