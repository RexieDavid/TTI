/**
* @author                           Stephen James Laylo
* @date                             March 2018
*
* @group                            Direct Marketing Contact Preference
*
* @description                      This class handles Direct Marketing Contacts' Preferences
*/
public with sharing class DMCPreferencesController {
    private Account acc;
    private List<Contact> contacts;
    public List<DirectMarketingContactWrapper> directMarketingContacts { get; set; }
    private Boolean hasError = false;
    private Id industrialRetailPreferenceRecTypeId;

    /**********************************************************************
     * @description                 Contructor
     * 
     * @param controller            Standard Controller containing record
     * 
     * @example
     * DMCPreferencesController dmc = new DMCPreferencesController(new ApexPages.StandardController(sobject));
     */
    public DMCPreferencesController(ApexPages.StandardController controller) {
        this.instantiateValues(controller);
        this.fetchActiveContacts(this.acc.Id);
        this.createMarketingContactsWrapper();
    }

    /**********************************************************************
     * @description                 Instantiate values
     * 
     * @param controller            Standard Controller containing record
     * 
     * @example
     * this.instantiateValues(new ApexPages.StandardController(sobject));
     */
    private void instantiateValues(ApexPages.StandardController controller) {
        this.acc = (Account) controller.getRecord();
        this.directMarketingContacts = new List<DirectMarketingContactWrapper>();
        this.industrialRetailPreferenceRecTypeId = Schema.SObjectType.Marketing_Preference__c.getRecordTypeInfosByName().get('Industrial Retail Preferences').getRecordTypeId();
    }

    /**********************************************************************
     * @description                 Fetch active contact records related to the
     *                              account
     * 
     * @param accountId             Parent account Id
     * 
     * @example
     * this.fetchActiveContacts('001........');
     */
    private void fetchActiveContacts(Id accountId) {
        this.contacts = [SELECT Id,
                                AccountId,
                                Name,
                                (SELECT Id,
                                        General_Communication__c,
                                        Monthly_Communication__c,
                                        Image_Relay__c,
                                        Press_Release__c,
                                        Product_Launch_2_WEEK__c,
                                        Product_Launch_4_WEEK__c,
                                        MX_Communication__c,
                                        MX_New_Product_Development__c,
                                        MX_Commission_Report__c,
                                        Contact__c
                                FROM Marketing_Preferences__r
                                WHERE RecordTypeId = :industrialRetailPreferenceRecTypeId),
                                (SELECT Id,
                                        Account__c,
                                        Contact__c,
                                        Contact__r.Name
                                FROM Direct_Marketing_Contacts__r
                                WHERE Account__c = :accountId
                                LIMIT 1)
                        FROM Contact
                        WHERE AccountId = :accountId
                        AND Record_Status__c = 'Active'];
    }

    /**********************************************************************
     * @description                 Fetch active contact records related to the
     *                              account
     *
     * @example
     * this.createMarketingContactsWrapper();
     */
    private void createMarketingContactsWrapper() {
        for (Contact cont : this.contacts) {
            String key = cont.AccountId + '_' + cont.Id;
            Direct_Marketing_Contact__c dmc = this.createDirectMarketingContact(cont, key);
            List<Marketing_Preference__c> contactMarketingPreferences = this.createMarketingPreferences(cont);
            DirectMarketingContactWrapper dmcw = new DirectMarketingContactWrapper(dmc.Id != null,
                                                                                   cont.Name,
                                                                                   dmc,
                                                                                   contactMarketingPreferences);
            this.directMarketingContacts.add(dmcw);
        }
    }

    /**********************************************************************
     * @description                 Construct Direct Marketing Contact object
     * 
     * @param cont                  Contact record
     * @param key                   Map key to determine if contact have related
     *                              direct marketing contact record
     * 
     * @return                      Direct marketing contact record for contact
     * 
     * @example
     * this.createDirectMarketingContact(new Contact(Id='003...'), '001...-003....');
     */
    private Direct_Marketing_Contact__c createDirectMarketingContact(Contact cont, String key) {
        if (!cont.Direct_Marketing_Contacts__r.isEmpty()) {
            return cont.Direct_Marketing_Contacts__r[0];
        }
        Direct_Marketing_Contact__c dmc = new Direct_Marketing_Contact__c();
        dmc.Account__c = cont.AccountId;
        dmc.Contact__c = cont.Id;
        return dmc;
    }

    /**********************************************************************
     * @description                 Construct Marketing Preferences List
     * 
     * @param cont                  Parent contct record
     * 
     * @return                      Marketing Preference records for contact
     * 
     * @example
     * this.createMarketingPreferences(new Contact(Id = '003.....'));
     */
    private List<Marketing_Preference__c> createMarketingPreferences(Contact cont) {
        if (!cont.Marketing_Preferences__r.isEmpty()) {
            return cont.Marketing_Preferences__r;
        }
        Marketing_Preference__c contactMarketingPreference = new Marketing_Preference__c();
        contactMarketingPreference.RecordTypeId = this.industrialRetailPreferenceRecTypeId;
        contactMarketingPreference.Contact__c = cont.Id;
        return new List<Marketing_Preference__c>{ contactMarketingPreference };
    }

    /**********************************************************************
     * @description:                 This method handles the Save button
     * 
     * @return                      Page reference directed to account record
     * 
     * @example
     * DMCPreferencesController controller = new DMCPreferencesController(...);
     * controller.save();
     */ 
    public PageReference save() {
        this.processDirectMarketingContacts();
        Pagereference redirectPageOnSave = this.hasError ? null : this.createAccountPageReference();
        return redirectPageOnSave;
    }

    /**********************************************************************
     * @description                 Process data to determine which records
     *                              will be upserted/deleted in salesforce
     * 
     * @example
     * this.processDirectMarketingContacts();
     */
    private void processDirectMarketingContacts() {
        List<Marketing_Preference__c> mPrefencesToUpsert = new List<Marketing_Preference__c>();
        List<Direct_Marketing_Contact__c> dmContactToUpsert = new List<Direct_Marketing_Contact__c>();
        List<Direct_Marketing_Contact__c> dmContactToDelete = new List<Direct_Marketing_Contact__c>();

        for (DirectMarketingContactWrapper dmcWrapper : this.directMarketingContacts) {
            mPrefencesToUpsert.addAll(dmcWrapper.marketingPreferences);
            if (dmcWrapper.isSelected) {
                dmContactToUpsert.add(dmcWrapper.directMarketingContact);
            } else {
                if (dmcWrapper.directMarketingContact.Id != null) {
                    dmContactToDelete.add(dmcWrapper.directMarketingContact);
                }
            }
        }
        this.commitToDatabase(mPrefencesToUpsert, dmContactToUpsert, dmContactToDelete);
    }

    /**********************************************************************
     * @description                 Commit data to Salesforce database
     * 
     * @param mPrefToUpsert         To upsert marketing preferences
     * @param dmcToUpsert           To upsert direct marketing contacts
     * @param dmcToDelete           To delete direct marketing contacts
     * 
     * @example
     * this.commitToDatabase(new List<Marketing_Preference__c>{...},
     *                      new List<Direct_Marketing_Contact__c>{...},
     *                      new List<Direct_Marketing_Contact__c>{...});
     */
    private void commitToDatabase(List<Marketing_Preference__c> mPrefToUpsert, 
                                 List<Direct_Marketing_Contact__c> dmcToUpsert,
                                 List<Direct_Marketing_Contact__c> dmcToDelete) {
        Savepoint sp = Database.setSavepoint();
        try {
            this.hasError = false;
            if (!dmcToUpsert.isEmpty()) {
                DirectMarketingContactTriggerHandler.runTrigger = false;
                upsert dmcToUpsert;
                DirectMarketingContactTriggerHandler.runTrigger = true;
            }

            if (!dmcToDelete.isEmpty()) {
                delete dmcToDelete;
            }

            if (!mPrefToUpsert.isEmpty()) {
                upsert mPrefToUpsert;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            this.hasError = true;
            ApexPages.message errorMessage = new ApexPages.message(ApexPages.severity.Error, Label.Generic_Error_Message);
            ApexPages.addmessage(errorMessage);
        }
    }

    /**********************************************************************
     * @description:                 This method handles the Cancel button
     * 
     * @return                      Page reference directed to account record
     * 
     * @example
     * DMCPreferencesController controller = new DMCPreferencesController(...);
     * controller.cancel();
     */ 
    public PageReference cancel() {
        return this.createAccountPageReference();
    }

    /**********************************************************************
     * @description                 Construct account page reference
     * 
     * @return                      Page reference directed to account record
     * 
     * @example
     * this.createAccountPageReference();
     */
    private Pagereference createAccountPageReference() {
        PageReference accountPage = new PageReference('/' + this.acc.Id);
        accountPage.setRedirect(true);
        return accountPage;
    }

    /**
    * @author: Kristopher Veraces
    * @date:                        March 2018
    * @description:                 Wrapper Class for Direct Marketing Contact
    */ 
    public class DirectMarketingContactWrapper {
        public Boolean isSelected { get; set; }
        public String contactName { get; set; }
        public Direct_Marketing_Contact__c directMarketingContact { get; set; }
        public List<Marketing_Preference__c> marketingPreferences { get; set; }

        /**********************************************************************
         * @description                     Contructor
         * 
         * @param isSelected                Is contact selected
         * @param contactName               Contact name
         * @param directMarketingContact    Direct marketing contact related to contact
         * @param marketingPreferences      Contact marketing preferences
         * 
         * @example
         * DirectMarketingContactWrapper dmc = new DirectMarketingContactWrapper(true, 
         *                                                                       'contact', 
         *                                                                        new Direct_Marketing_Contact__c(...),
         *                                                                        new List<Marketing_Preference__c>{...});
         */
        public DirectMarketingContactWrapper(Boolean isSelected, 
                                             String contactName, 
                                             Direct_Marketing_Contact__c directMarketingContact, 
                                             List<Marketing_Preference__c> marketingPreferences) {
            this.isSelected = isSelected;
            this.contactName = contactName;
            this.directMarketingContact = directMarketingContact;
            this.marketingPreferences = marketingPreferences;
        }
    }
}