/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2019-10-24
 *
 * @description             Controller for AEG Profile Center
 */
 
public class AEGProfileCenterController {

    private static final String ERR_MESSAGE_NO_PREFERENCES = 'An error occured while getting the preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_USER_NO_PREFERENCES = 'An error occured while getting the user\'s preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_NO_USER_RECORD = 'An error occure while getting user details. Please contact your administrator';
    private static final String ERR_MESSAGE_CREATING_PREFERENCE = 'An error occured while creating new preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_SUB_UNSUB = 'An error occured while subscribing/unsubscribing. Please contact your administrator';
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
    private static final String BRAND_CODE = 'AG';

    private static final String CURRENT_USER_ACCOUNTID = [SELECT AccountId FROM User WHERE Id = :Userinfo.getUserId()][0].AccountId;
    private static SubscriptionAndPreference subscriptionPreferenceClass = new SubscriptionAndPreference();
    private static final Map<String, List<String>> TOPICS = new Map<String, List<String>>{
        'COMMUNICATION' => new List<String>{
            'Communication Subscriptions',
            'Market Research'
        }
    };
    
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
            Map<Id, PreferenceTopic__c> returnedValueObserver = subscriptionPreferenceClass.fetchPreferences(BRAND_CODE, country, TOPICS.get(tabName.toUpperCase()));

            return returnedValueObserver;
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

        try {
            ProfileCenterData pcd = new ProfileCenterData();

            if (parsedData.acct != null) {
                update parsedData.acct;
                
                pcd.acct = getAccount(parsedData.fields);
            }

            if (parsedData.personAccPrefs != null && !parsedData.personAccPrefs.isEmpty()) {
                for (PersonAccountPreference__c personAcctPref :parsedData.personAccPrefs) {
                    if (personAcctPref.Id == null) {
                        personAcctPref.PersonAccountId__c = CURRENT_USER_ACCOUNTID;
                    }
                }
                
                pcd.personAccPrefs = subscriptionPreferenceClass.toggleSubscription(parsedData.personAccPrefs);
            }

            
            User customerUser = [SELECT Id, FirstName, LastName FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
            if ((pcd.acct.isSet('FirstName') && pcd.acct.get('FirstName') != null && customerUser.FirstName != pcd.acct.FirstName)
                    || (pcd.acct.isSet('LastName') && pcd.acct.get('LastName') != null && customerUser.LastName != pcd.acct.LastName)) {

                if (pcd.acct.isSet('FirstName')) {
                    customerUser.FirstName = pcd.acct.FirstName;
                }

                if (pcd.acct.isSet('LastName')) {
                    customerUser.LastName = pcd.acct.LastName;
                }
                update customerUser;
            }

            return pcd;
        } catch (Exception ex) {
            Database.rollback(sp);
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.setMessage(ex.getMessage());
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

    public class ProfileCenterData {
        
        @AuraEnabled
        public Account acct;

        @AuraEnabled
        public List<PersonAccountPreference__c> personAccPrefs;

        @AuraEnabled
        public List<String> fields;
    }
}