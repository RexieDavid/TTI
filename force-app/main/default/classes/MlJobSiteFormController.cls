/**********************************************************************
 * @author                  Kristopher Veraces
 * @date                    2021-12-08
 *
 * @description             Apex Controller for Job Site Form Lighgnint web component
 */
public with sharing class MlJobSiteFormController {
    private static final String JOB_SITE_RECORDTYPE_ID = Schema.SObjectType.Marketing_Campaign__c
                                                            .getRecordTypeInfosByDeveloperName()
                                                            .get('Job_Site_to_Camp_Site_Competition')
                                                            .getRecordTypeId();
    
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
                   Contact.Account.RecordTypeId
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
        JobSiteFormWrapper wrapper = (JobSiteFormWrapper)JSON.deserializeStrict(payload, JobSiteFormWrapper.class);
        wrapper.marketingCampaign.RecordTypeId = JOB_SITE_RECORDTYPE_ID;
        List<SObject> sobjects = new List<SObject>{ wrapper.marketingCampaign };
        if (wrapper.account != null) {
            sobjects.add(wrapper.account);
        }

        if (wrapper.user != null) {
            sobjects.add(wrapper.user);
        }

        try {
            upsert sobjects;
            uploadFile(wrapper.file, wrapper.marketingCampaign.Id);
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new JobSiteFormControllerException(ex.getMessage());
        }
    }

    /**
     * @description                 Save file from the form
     */
    private static void uploadFile(FileWrapper file, String recordId) {
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
    public class JobSiteFormWrapper {
        public Account account { get; set; }
        public Marketing_Campaign__c marketingCampaign { get; set; }
        public User user { get; set; }
        public FileWrapper file { get; set; }
    }

    /**
     * @description                 File wrapper class
     */
    public class FileWrapper {
        public String base64 { get; set; }
        public String fileName { get; set; }
    }

    public class JobSiteFormControllerException extends Exception {}
}