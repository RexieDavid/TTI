public without sharing class RYProfileCenterController {
    private static final String ERR_MESSAGE_NO_PREFERENCES = 'An error occured while getting the preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_USER_NO_PREFERENCES = 'An error occured while getting the user\'s preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_NO_USER_RECORD = 'An error occure while getting user details. Please contact your administrator';
    private static final String ERR_MESSAGE_CREATING_PREFERENCE = 'An error occured while creating new preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_SUB_UNSUB = 'An error occured while subscribing/unsubscribing. Please contact your administrator';
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
    private static final String BRAND_CODE = 'RY';

    private static final String CURRENT_USER_ACCOUNTID = [SELECT AccountId FROM User WHERE Id = :Userinfo.getUserId()][0].AccountId;
    private static SubscriptionAndPreference subscriptionPreferenceClass = new SubscriptionAndPreference();
    private static final List<String> TOPICS = new List<String>{ 'Communication Subscriptions', 'Market Research' };


    /**********************************************************************
    * @description             Will fetch list of preferences based on brand and country
    * 
    * @param  country          Country of preference
    * @return                  Map of preference topic and preference
    * 
    * @example
    * getTopicsAndPreferences('AU')
    */
    @AuraEnabled
    public static Map<Id, PreferenceTopic__c> getTopicsAndPreferences(String country, String tabName) {
        try {
            return subscriptionPreferenceClass.fetchPreferences(BRAND_CODE, country, TOPICS);
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ERR_MESSAGE_NO_PREFERENCES);
            ahe.setMessage(ERR_MESSAGE_NO_PREFERENCES);
            throw ahe;
        }
    }
    
    /**********************************************************************
    * @description             Will fetch preferences of the user
    * 
    * @return                  List of preference that user subscribed
    * 
    * @example
    * getPersonAccountPreferences()
    */
    @AuraEnabled
    public static List<PersonAccountPreference__c> getPersonAccountPreferences() {
        try {
            return subscriptionPreferenceClass.fetchPersonAccountPreference(CURRENT_USER_ACCOUNTID);
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ERR_MESSAGE_USER_NO_PREFERENCES);
            ahe.setMessage(ERR_MESSAGE_USER_NO_PREFERENCES);
            throw ahe;
        }
    }

    /**********************************************************************
    * @description             Will Update Person Account and Person Account Preferences,
                               Create new preferences and create/delete Person Account Preferences 
    *    
    * @param data              json string for ProfileCenterData
    *
    * @example
    * updateDetails('"{"acct:{...}","personAccPrefs":...]}"')
    */
    @AuraEnabled
    public static ProfileCenterData updateDetails(String data) {

        Savepoint sp = Database.setSavepoint();
        ProfileCenterData parsedData = (ProfileCenterData) JSON.deserialize(data, ProfileCenterData.class);
        ProfileCenterData pcd = new ProfileCenterData();

        try {

            if (parsedData.acct != null) {
                update parsedData.acct;
                pcd.acct = parsedData.acct;
            }

            if (parsedData.marketingPrefs != null) {
                update parsedData.marketingPrefs;
                pcd.marketingPrefs = parsedData.marketingPrefs;
            }

        } catch (Exception ex) {
            Database.rollback(sp);
            AuraHandledException ahe = new AuraHandledException(ERR_GENERIC_MESSAGE);
            ahe.setMessage(ERR_GENERIC_MESSAGE);
            throw ahe;
        }

        try {

            if (parsedData.personAccPrefs != null && !parsedData.personAccPrefs.isEmpty()) {
                for (PersonAccountPreference__c personAcctPref : parsedData.personAccPrefs) {
                    if (personAcctPref.Id == null) {
                        personAcctPref.PersonAccountId__c = CURRENT_USER_ACCOUNTID;
                    }
                }
                pcd.personAccPrefs = subscriptionPreferenceClass.toggleSubscription(parsedData.personAccPrefs);
            }

            User customerUser = [SELECT Id, FirstName, LastName FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];

            if (pcd.acct.isSet('FirstName') && pcd.acct.get('FirstName') != null && customerUser.FirstName != pcd.acct.FirstName) {
                customerUser.FirstName = pcd.acct.FirstName;
            }

            if (pcd.acct.isSet('LastName') && pcd.acct.get('LastName') != null && customerUser.LastName != pcd.acct.LastName) {
                customerUser.LastName = pcd.acct.LastName;
            }

            update customerUser;
            return pcd;
        } catch (Exception ex) {
            Database.rollback(sp);
            AuraHandledException ahe = new AuraHandledException(ERR_GENERIC_MESSAGE);
            ahe.setMessage(ERR_GENERIC_MESSAGE);
            throw ahe;
        }
    }

    /**********************************************************************
     * @description             Retrieve current user's account record
     *                           
     *                          Added functionality where it will check
     *                          first if marketing cloud managed package
     *                          is existing in development environment
     * 
     * @return                 Account object  
     *
     * 
    */
    @AuraEnabled
    public static Account getAccount(List<String> fields) {
        Boolean hasMarketingCloud = [SELECT COUNT() FROM PackageLicense WHERE NamespacePrefix = 'et4ae5'] > 0;
        String queryTemplate = 'SELECT {0} FROM Account WHERE Id = :CURRENT_USER_ACCOUNTID';
        
        if (hasMarketingCloud) {
            fields.add('et4ae5__HasOptedOutOfMobile__pc');
        }

        return Database.query(
            String.format(
                queryTemplate,
                new List<String> {
                    String.join(fields, ', ')
                }
            )
        );
    }


    /**********************************************************************
     * @description             Retrieve Ryobi account records
     *                          for Local Bunnings field
     * 
     *
     * @return                 Account object  
     *
     * 
    */
    @AuraEnabled
    public static List<Account> getRyobiAccounts(String country) {
        Set<String> excludedAcctNames = new Set<String> { '%DC%', '%T/C%', '%NTT%', '%CREDIT%', '%POP UP%', '%HARDWARE%', '%TRADE EXPO%', '%FIELD DAYS%', '%HEAD OFFICE%'};
        String queryCondition = 'Bunnings_Formatted_Store_Name__c LIKE \'%' + 'BUNNINGS' + '%\'' +
                                'AND Name LIKE \'%' + 'BUNNINGS' + '%\'' +
                                'AND Record_Status__c = \'Active\'' +
                                'AND Record_Type_for_Account__c = \'Commercial\'' +
                                'AND Type = \'Retailer\'' +
                                'AND Customer_Group_1_Code__c = \'BU\'' +
                                'AND (NOT Name LIKE :excludedAcctNames)';

        if (country.toLowerCase() == 'au') {
            queryCondition += 'AND Company_Code__c = \'BP01\'';
        } else {
            queryCondition += 'AND Company_Code__c = \'NZ01\'';
        }

        String queryAccount = 'SELECT Bunnings_Formatted_Store_Name__c, Name, Id From Account WHERE ' + queryCondition + '';
        return Database.query(queryAccount);
    }
    
    /**********************************************************************
     * @description             Retrieve marketing preferences related to person account
     *
     * @param fields            List of fields
     * 
     * @return                  Marketing preferences of a person account
     * 
     */
    @AuraEnabled
    public static List<Marketing_Preference__c> getMarketingPreferences(List<String> fields) {
        String queryTemplate = 'SELECT {0} FROM Marketing_Preference__c WHERE Person_Account__c = :CURRENT_USER_ACCOUNTID';

        return Database.query(
            String.format(
                queryTemplate,
                new List<String> {
                    String.join(fields, ', ')
                }
            )
        );
    }

    public class ProfileCenterData {
        
        @AuraEnabled
        public Account acct;

        @AuraEnabled
        public List<PersonAccountPreference__c> personAccPrefs;

        @AuraEnabled
        public List<String> fields;

        @AuraEnabled
        public Marketing_Preference__c marketingPrefs;
    }
}