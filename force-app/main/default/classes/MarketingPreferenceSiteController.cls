/**
* @author:                          Stephen James Laylo
* @date:                            July 2017
* @description:                     This class handles Marketing Preference Subscriptions
*/ 
public class MarketingPreferenceSiteController {

    private String personContactId;
    public String accountEmail { get; set; }
    public String accountMobile { get; set; }
    public String accountBrand { get; set; }
    public Boolean mpSMS { get; set; }
    public Boolean mpEmails { get; set; }
    public Boolean mpNewsletter { get; set; }
    public Boolean mpNewProductUpdates { get; set; }
    public Boolean mpDIYInspiration { get; set; }
    public Boolean mpFeedbackSurveys { get; set; }
    public Boolean mpResearchSurveys { get; set; }

    public Boolean mpMarketResearch {get; set;}
    public Boolean mpToolTesting {get; set;}

    public Boolean papResearch {get; set;}

    public Boolean hasMarketingCloud {get; set; }
    public Account personAccount { get; set; }
    public String personName { get; set; } 
    public Marketing_Preference__c marketingPreference { get; set; }
    public PersonAccountPreference__c personAccountPreference { get; set; }
    
    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static final Set<String> ACCOUNT_FIELDS = new Set<String>{'Id', 
                                                                        'Name',
                                                                        'PersonEmail',
                                                                        'PersonMobilePhone',
                                                                        'PersonHasOptedOutOfEmail'};
    
    private Map<String, PersonAccountPreference__c> accountPreferencesMap {get; set;}
    private Map<String, PersonAccountPreference__c> ryAccountPreferencesMap {get; set;}
    private Map<String, String> preferencesMap {get; set;}
    
    /**
     * @description                 Constructor
     * 
     *                              Initialize data on load of page
     */
    public MarketingPreferenceSiteController() {
        this.preferencesMap = new Map<String, String>();
        this.accountPreferencesMap = new Map<String, PersonAccountPreference__c>();
        this.accountPreferencesMap.put('MarketResearch', new PersonAccountPreference__c());
        this.accountPreferencesMap.put('ToolTesting', new PersonAccountPreference__c());
        this.ryAccountPreferencesMap = new Map<String, PersonAccountPreference__c>();
        this.ryAccountPreferencesMap.put('Research', new PersonAccountPreference__c());
        List<Marketing_Preference__c> marketingPreferences = new List<Marketing_Preference__c>();
        this.marketingPreference = new Marketing_Preference__c();
        this.accountBrand = ApexPages.currentPage().getParameters().get('Brand');
        this.personContactId = ApexPages.currentPage().getParameters().get('Id');
        this.accountEmail = ApexPages.currentPage().getUrl().substringAfter('Email=').substringBefore('&').replace('%40','@');
        this.accountMobile = ApexPages.currentPage().getParameters().get('Mobile');
        this.personAccount = this.fetchPersonAccount();
        //this.accountEmail = this.personAccount.PersonEmail;
        this.personName = this.personAccount.Name;
        marketingPreferences = this.fetchMarketingPreference();
        this.setMarketingPreference(marketingPreferences);
    }

    /**
     * @author                      Kristopher Veraces
     * @since                       March 05, 2020
     * @description                 Fetch marketing preference link to 
     *                              person account
     */
    private List<Marketing_Preference__c> fetchMarketingPreference() {
        return [SELECT Id,
                       Newsletter__c,
                       Feedback__c,
                       SMS__c,
                       DIY_Inspiration__c,
                       Promotion_Updates__c,
                       Product_Updates__c,
                       New_Product_Updates__c,
                       Person_Account__c,
                       Feedback_Surveys__c,
                       Research_Surveys__c,
                       Maintenance__c
                FROM Marketing_Preference__c
                WHERE Person_Account__c = :this.personAccount.Id 
                LIMIT 1];
    }

    /**
     * @author                      Kristopher Veraces
     * @since                       March 05, 2020
     * @description                 Fetch person account record
     */
    private Account fetchPersonAccount() {
        this.hasMarketingCloud = [SELECT COUNT() FROM PackageLicense WHERE NamespacePrefix = 'et4ae5'] > 0;
        if (hasMarketingCloud && !ACCOUNT_FIELDS.contains('et4ae5__HasOptedOutOfMobile__pc')) {
            ACCOUNT_FIELDS.add('et4ae5__HasOptedOutOfMobile__pc');
        }
        
        System.debug('DBG: --- fetchPersonAccount --- this.accountEmail --- ' + this.accountEmail);

        String soqlQuery = 'SELECT '+ String.join(new List<String>(ACCOUNT_FIELDS), ',') +' FROM Account WHERE PersonContactId = \''+ this.personContactId +'\' AND Brand__pc = \''+ this.accountBrand +'\' AND RecordTypeId = :b2cConsumerContactAccRecTypeId ';
        if (String.isNotBlank(this.accountEmail)) {
            soqlQuery += 'AND PersonEmail = \''+ this.accountEmail +'\' ';
        }

        if (String.isNotBlank(this.accountMobile)) {
            soqlQuery += 'AND PersonMobilePhone = \''+ this.accountMobile +'\' ';
        }

        return Database.query(soqlQuery + 'LIMIT 1');
    }

    /**
     * @author                      Kristopher Veraces
     * @since                       March 05, 2020
     * @description                 Set account preference
     */
    private void setAccountPreferences() {
        Set<String> accountPrefNames = new Set<String>();
        if (accountBrand == 'Ryobi') {
            accountPrefNames.addAll(this.ryAccountPreferencesMap.keySet());
        } else {
            accountPrefNames.addAll(this.accountPreferencesMap.keySet());
        }
        for (Preference__c pref : [SELECT Id, 
                                          Name,
                                          Brand__c,
                                          PreferenceTopic__c,
                                          PreferenceTopic__r.Name
                                   FROM Preference__c 
                                   WHERE Name IN :accountPrefNames]) {
            if (pref.Name == 'Research') {
                if (pref.Brand__c == 'RY' && pref.PreferenceTopic__r.Name == 'Communication Subscriptions') {
                    preferencesMap.put(pref.Name, pref.Id);
                }
            }
            else {
                preferencesMap.put(pref.Name, pref.Id);
            }
        }

        for (PersonAccountPreference__c actPref : [SELECT Id, 
                                                          PreferenceId__c,
                                                          PreferenceId__r.Name,
                                                          OptOut__c
                                                   FROM PersonAccountPreference__c 
                                                   WHERE PersonAccountId__c = :this.personAccount.Id
                                                   AND PreferenceId__c IN :preferencesMap.values()]) {
            if (accountBrand == 'Ryobi' && actPref.PreferenceId__r.Name == 'Research') {
                ryAccountPreferencesMap.put(actPref.PreferenceId__r.Name, actPref);
            } else {
                accountPreferencesMap.put(actPref.PreferenceId__r.Name, actPref);
            }

            if (actPref.PreferenceId__r.Name == 'MarketResearch') {
                this.mpMarketResearch = actPref.OptOut__c;
            } else if (actPref.PreferenceId__r.Name == 'Research') {
                this.papResearch = actPref.OptOut__c;
            } else {
                this.mpToolTesting = actPref.OptOut__c;
            }
        }

        for (String key : accountPreferencesMap.keySet()) {
            PersonAccountPreference__c tActPref = accountPreferencesMap.get(key);
            if (key == 'MarketResearch') {
                this.mpMarketResearch = tActPref.Id != null ? !tActPref.OptOut__c : false;
            } else if (key == 'Research') {
                this.papResearch = tActPref.Id != null ? !tActPref.OptOut__c : false;
            } else {
                this.mpToolTesting = tActPref.Id != null ? !tActPref.OptOut__c : false;
            }
        }

        for (String key : ryAccountPreferencesMap.keySet()) {
            PersonAccountPreference__c tActPref = ryAccountPreferencesMap.get(key);
            if (key == 'Research') {
                this.papResearch = tActPref.Id != null ? !tActPref.OptOut__c : false;
            }
        }
    }

    /**
     * @author                      Kristopher Veraces
     * @since                       March 05, 2020
     * @description                 Set marketing preferences
     */
    private void setMarketingPreference(List<Marketing_Preference__c> marketingPreferences) {
        if (!marketingPreferences.isEmpty()) {
            this.marketingPreference = marketingPreferences[0];
            if (accountBrand == 'Milwaukee') {
                this.setAccountPreferences();
                this.mpFeedbackSurveys = marketingPreference.Feedback_Surveys__c;
                this.mpEmails = !this.personAccount.PersonHasOptedOutOfEmail;
                this.mpSMS = this.hasMarketingCloud ? !this.personAccount.et4ae5__HasOptedOutOfMobile__pc : false;
            } else if (accountBrand == 'Ryobi' || accountBrand == 'AEG') {
                if (accountBrand == 'Ryobi') {
                    this.setAccountPreferences();
                }
                this.mpNewsletter = marketingPreference.Newsletter__c;
                this.mpSMS = this.hasMarketingCloud ? !this.personAccount.et4ae5__HasOptedOutOfMobile__pc : false;
                this.mpNewProductUpdates = marketingPreference.New_Product_Updates__c;
                this.mpDIYInspiration = marketingPreference.DIY_Inspiration__c;
                this.mpEmails = !this.personAccount.PersonHasOptedOutOfEmail;
                this.mpFeedbackSurveys = marketingPreference.Feedback_Surveys__c;
                this.mpResearchSurveys = marketingPreference.Research_Surveys__c;
            } else {
                this.mpEmails = !this.personAccount.PersonHasOptedOutOfEmail;
                this.mpSMS = this.hasMarketingCloud ? !this.personAccount.et4ae5__HasOptedOutOfMobile__pc : false;
                this.mpFeedbackSurveys = marketingPreference.Feedback_Surveys__c;
                this.mpResearchSurveys = marketingPreference.Research_Surveys__c;
            }
        }
    }
    
    /**
    * @author:                      Stephen James Laylo
    * @date:                        July 2017
    * @description:                 This method handles the save button
    */ 
    public PageReference save() {
        Account eAccount = new Account(Id = this.personAccount.Id);
        //Line 182-186: update person account if there's opt for emails and sms not depending on brand
        eAccount.PersonHasOptedOutOfEmail = !this.mpEmails;
        if (hasMarketingCloud) {
            eAccount.et4ae5__HasOptedOutOfMobile__pc = !this.mpSMS;
        }

        Savepoint sp = Database.setSavepoint(); 
        if (accountBrand == 'AEG') {
            this.marketingPreference.Newsletter__c = this.mpEmails;
            this.marketingPreference.New_Product_Updates__c = this.mpEmails;
            this.marketingPreference.DIY_Inspiration__c = this.mpEmails;
            this.marketingPreference.Feedback_Surveys__c = this.mpFeedbackSurveys;
            this.marketingPreference.Research_Surveys__c = this.mpResearchSurveys;
            this.marketingPreference.SMS__c = this.mpSMS;
        } else if (accountBrand == 'VAX') {
            this.marketingPreference.Feedback_Surveys__c = this.mpFeedbackSurveys;
            this.marketingPreference.Research_Surveys__c = this.mpResearchSurveys;
        } else if (accountBrand == 'Milwaukee') {
            this.marketingPreference.Feedback_Surveys__c = this.mpFeedbackSurveys;
            for (String key : accountPreferencesMap.keySet()) {
                PersonAccountPreference__c tActPref = accountPreferencesMap.get(key);
                Boolean val = !(key == 'MarketResearch' ? this.mpMarketResearch : this.mpToolTesting);

                if (tActPref.Id == null) {
                    tActPref.PersonAccountId__c = this.personAccount.Id;
                    tActPref.PreferenceId__c = preferencesMap.get(key);
                }
                tActPref.OptOut__c = val;
            }
        } else if (accountBrand == 'Ryobi') {
            this.marketingPreference.SMS__c = this.mpSMS;
            this.marketingPreference.Feedback_Surveys__c = this.mpFeedbackSurveys;
            for (String key : ryAccountPreferencesMap.keySet()) {
                PersonAccountPreference__c tActPref = ryAccountPreferencesMap.get(key);
                Boolean val = !(key == 'Research' ? this.papResearch : false);

                if (tActPref.Id == null) {
                    tActPref.PersonAccountId__c = this.personAccount.Id;
                    tActPref.PreferenceId__c = preferencesMap.get(key);
                }
                tActPref.OptOut__c = val;
            }
        } else {
            this.marketingPreference.Newsletter__c = this.mpNewsletter;
            this.marketingPreference.New_Product_Updates__c = this.mpNewProductUpdates;
            this.marketingPreference.DIY_Inspiration__c = this.mpDIYInspiration;
            this.marketingPreference.SMS__c = this.mpSMS;
            this.marketingPreference.Feedback_Surveys__c = this.mpFeedbackSurveys;
            this.marketingPreference.Research_Surveys__c = this.mpResearchSurveys;
        }

        try {
            upsert this.marketingPreference;
            update eAccount;
            if (accountBrand == 'Milwaukee') {
                upsert this.accountPreferencesMap.values();
            } if (accountBrand == 'Ryobi') {
                upsert this.ryAccountPreferencesMap.values();
            }
        } catch (Exception err) {
            Database.rollback(sp);
            throw err;
        }
        return this.handleRedirectOnSave();
    }

    /**
     * @author                      Kristopher Veraces
     * @since                       March 05, 2020
     * @description                 Redirect on save of record
     */
    private Pagereference handleRedirectOnSave() {
        PageReference reRend = Page.MarketingPreferenceSite;
        reRend.getParameters().put('Brand', this.accountBrand);
        reRend.getParameters().put('Id', this.personContactId);

        if (String.isNotBlank(this.accountEmail)) {
            String url = EncodingUtil.urlDecode(this.accountEmail, 'UTF-8');
            reRend.getParameters().put('Email', url);  
        }

        if (String.isNotBlank(this.accountMobile)) {
            reRend.getParameters().put('Mobile', this.accountMobile);
        }

        reRend.setRedirect(true);
        return reRend;
    }
    
    /**
    * @author:                      Stephen James Laylo
    * @date:                        July 2017
    * @description:                 This method handles the cancel button
    */ 
    public PageReference cancel() {
        PageReference reRend = new PageReference((accountBrand == 'Ryobi' ? 'http://www.ryobi.com.au' : (accountBrand == 'AEG' ? 'https://www.aegpowertools.com.au/' : (accountBrand == 'Milwaukee' ? 'https://www.milwaukeetools.com.au/' : null))));
        reRend.setRedirect(true);
        return reRend;
    }

    /**
    * @author:                      Stephen James Laylo
    * @date:                        April 2018
    * @description:                 This method handles the retrieval of field based on Object
    */ 
    public String getFieldLabel(String objectKey, String fieldKey) {
        List<SelectOption> options = new List<SelectOption>();
        return Schema.getGlobalDescribe().get(objectKey).getDescribe().fields.getMap().get(fieldKey).getDescribe().getLabel();
    }
    
}