public without sharing class RYLoginSurveyModalController {
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
    private static final String CURRENT_USER_ACCOUNTID = [SELECT AccountId FROM User WHERE Id = :Userinfo.getUserId()][0].AccountId;
    private static SubscriptionAndPreference subscriptionPreferenceClass = new SubscriptionAndPreference();
    
    /**********************************************************************
     * @description             Retrieve current user's account record
     *                          
     * @return                  Account object  
     *
     * 
    */
    @AuraEnabled
    public static Account getAccount(List<String> fields) {
        String queryTemplate = 'SELECT {0} FROM Account WHERE Id = :CURRENT_USER_ACCOUNTID';

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
    * @description             Will Update Person Account
    *    
    * @param acct              account to be updated
    */
    @AuraEnabled
    public static Account updateAccount(Account acct) {
        try { 
            update acct;
            } 
        catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ERR_GENERIC_MESSAGE);
            ahe.setMessage(ERR_GENERIC_MESSAGE);
            throw ahe;
        }
        return acct;
    }

    // Methods previously in ProductDetailCC, used by LandingPageMain aura cmp

    /**********************************************************************
     * @description             retrieves user record of logged in user
     * 
     * @param                   id of current user
     * @return                  user with fields used for myRyobi customer 
     *                          survey
    */
    @AuraEnabled
    public static User getSurveyDetails(String userId) {
        return [SELECT AccountId, Account.Is_survey_completed__c, Country FROM User WHERE Id = :userId];
    }

    @AuraEnabled
    public static CommunitySettingsHelperClass.SiteSettingsResult getSiteSettings() {
        return CommunitySettingsHelperClass.getSiteAndUserSettings(site.getMasterLabel());
    }
}