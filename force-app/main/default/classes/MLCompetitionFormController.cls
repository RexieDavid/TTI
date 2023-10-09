/**********************************************************************
 * @author                  Kristopher Veraces
 * @date                    2022-06-27
 *
 * @description             Apex Controller for MLCompetitionForm lightning web component
 *                          Disregard sharing rules due to the limitations wherein
 *                          community user can't access lead records. See link for
 *                          reference:
 *                          https://help.salesforce.com/s/articleView?id=sf.users_license_types_communities.htm&type=5
 */
public without sharing class MLCompetitionFormController {
    /*
     * @description                 Get user account details
     */
    @AuraEnabled(cacheable=true)
    public static String getUserAccountDetails() {
        return JSON.serialize([
            SELECT Contact.Account.FirstName,
                   Contact.Account.LastName,
                   Contact.Account.PersonEmail,
                   Contact.Account.PersonMobilePhone,
                   Contact.Account.PersonMailingStreet,
                   Contact.Account.PersonMailingCity,
                   Contact.Account.PersonMailingState,
                   Contact.Account.PersonMailingPostalCode,
                   Contact.Account.Trade__pc,
                   Contact.Account.Industry,
                   Contact.Account.Industry_Type__c,
                   Contact.Account.Company_Name__c,
                   Contact.Account.RecordTypeId,
                   //KBERT 08/04/23 - Added Employment Type and Experience Level for auto retrieval on the form
                   Contact.Account.ExperienceLevel__pc,
                   Contact.Account.EmploymentType__pc
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ]);
    }

    /**
     * @description                 Commit information to database, such as:
     *                              - Update account/user if there are any changes
     *                              - Create marketing campaign record with attachment
     */
    @AuraEnabled
    public static void save(String payload) {
        Savepoint sp = Database.setSavepoint();
        MLCompetitionFormWrapper wrapper = (MLCompetitionFormWrapper)JSON.deserializeStrict(payload, MLCompetitionFormWrapper.class);
        System.debug('RDAVID 5/4/23 >>> wrapper >>> '+wrapper);
        Marketing_Campaign__c campaign = processMarketingCampaign(wrapper);
        List<SObject> sobjects = new List<SObject>{ campaign };
        if (!wrapper.sobjects.isEmpty()) {
            sobjects.addAll(wrapper.sobjects);
        }

        try {
            upsert sobjects;
            uploadFile(wrapper.file, campaign.Id);
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new MLCompetitionFormControllerException(ex.getMessage());
        }
    }

    /**
     * @description                 Process additional details for the
     *                              marketing campaign record
     */
    private static Marketing_Campaign__c processMarketingCampaign(MLCompetitionFormWrapper wrapper) {
        Marketing_Campaign__c marketingCampaign = wrapper.marketingCampaign;
        System.debug('JAC marketingCampaignType : ' + wrapper.marketingCampaignType);
        System.debug('JAC object : ' + Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName());
        String recordTypeId = Schema.SObjectType.Marketing_Campaign__c
            .getRecordTypeInfosByDeveloperName()
            .get(wrapper.marketingCampaignType)
            .getRecordTypeId();
        System.debug('JAC recordType : ' + recordTypeId);
        marketingCampaign.RecordTypeId = recordTypeId;
        return marketingCampaign;
    }

    /**
     * @description                 Save file from the form
     */
    private static void uploadFile(FileWrapper file, String recordId) {
        if (file == null) {
            return;
        }
        String versionId = createContentVersion(file);
        linkFileToMarketingCampaign(versionId, recordId);
    }

    /**
     * @description                 Create file version
     */
    private static Id createContentVersion(FileWrapper file) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(file.base64);
        cv.Title = file.fileName;
        cv.PathOnClient = file.fileName;
        insert cv;
        return cv.Id;
    }

    /**
     * @description                 Link uploaded file to marketing campaign
     */
    private static void linkFileToMarketingCampaign(String contentVersionId, String recordId) {
        ContentVersion file = [SELECT ContentDocumentId 
                                FROM ContentVersion 
                                WHERE Id = :contentVersionId
                                LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = file.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        insert cdl;
    }

    /**
     * @description                 Wrapper class for Job Site form
     */
    public class MLCompetitionFormWrapper {
        public Marketing_Campaign__c marketingCampaign { get; set; }
        public String marketingCampaignType { get; set; }
        public FileWrapper file { get; set; }
        public List<SObject> sobjects { get; set; }
    }

    /**
     * @description                 File wrapper class
     */
    public class FileWrapper {
        public String base64 { get; set; }
        public String fileName { get; set; }
    }

    public class MLCompetitionFormControllerException extends Exception {}
}