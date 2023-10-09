@IsTest
private class RYProfileCenterControllerTest {

    private static final String ERR_MESSAGE_NO_PREFERENCES = 'An error occured while getting the preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_USER_NO_PREFERENCES = 'An error occured while getting the user\'s preferences. Please contact your administrator';
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
    private static final String ERR_MESSAGE_RETURN_NONE = 'List has no rows for assignment to SObject';
    private static final String RY_BRAND = 'Ryobi';
    private static final String PORTAL_USER_NAME = '1t4e7s8t3@yahoo.com.ryobi';
    private static final String USER_NO_ACCESS_NAME = '2t4e7s8t3@yahoo.com.ryobi';
    private static final String ERR_MESSAGE_INVALID_FIELD = 'No such column';

    @TestSetup
    static void makeData() {
        List<Preference__c> newPreferenceList = new List<Preference__c>();
        List<PreferenceTopic__c> newPrefTopicsList = new List<PreferenceTopic__c>();
        List<PersonAccountPreference__c> newPersonAcctPrefList = new List<PersonAccountPreference__c>();
        List<User> userList = new List<User>();
        Profile profileWithoutAccess = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile ryCommunityProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi' LIMIT 1];

        List<Account> newPersonAccount = RYTestDataFactory.buildPersonAccountList(2);
        insert newPersonAccount;

        List<Account> bussinessAccount = RYTestDataFactory.buildBussinessAccount(2);
        insert bussinessAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId = :newPersonAccount[0].Id];
        eContact.Brand__c = RY_BRAND;
        update eContact;

        for (Integer counter = 0; counter < 5; counter++) {
            PreferenceTopic__c newPrefTopic = RYTestDataFactory.buildPreferenceTopic(counter, counter < 2 ? 'Communication Subscriptions' : 'EmailProductInformationAndOffers');
            newPrefTopicsList.add(newPrefTopic);
        }
        insert newPrefTopicsList;

        for (Integer counter = 0; counter < 5; counter++) {
            Preference__c newPreference = RYTestDataFactory.buildPreference(counter, newPrefTopicsList.get(counter).Id);
            newPreferenceList.add(newPreference);
        }
        insert newPreferenceList;

        for (Integer counter = 0; counter < 1; counter++) {
            PersonAccountPreference__c newPersonAccountPref = RYTestDataFactory.buildPersonAccountPreference(newPersonAccount[0].Id,
                                                                                                            newPreferenceList.get(counter).Id);
            newPersonAcctPrefList.add(newPersonAccountPref);
        }
        insert newPersonAcctPrefList;

        for (Integer counter = 0; counter < 2; counter ++) {
            Boolean separator = counter == 0;
            User newUser = RYTestDataFactory.buildUser(separator ? ryCommunityProfile.Id : profileWithoutAccess.Id, 
                                                       separator ? eContact.Id : null,
                                                       separator ? PORTAL_USER_NAME : USER_NO_ACCESS_NAME);
            userList.add(newUser);
        }   
        insert userList;
    }

    /**********************************************************************
     * @description             Perform positive Test in WHERE user has Preferences
     */
    @isTest
    private static void getPersonAccountPreferencesPositiveTest() {
        List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                preferences = RYProfileCenterController.getPersonAccountPreferences();
            }
        Test.stopTest();
        System.assert(!preferences.isEmpty(), 'No preference found attached to user');
    }

    /**********************************************************************
     * @description             Perform Negative Test in WHERE user has no Preferences
     */
    @isTest
    private static void getPersonAccountPreferencesNegativeTest() {
        String errorMessage;
        List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                try {
                    preferences = RYProfileCenterController.getPersonAccountPreferences();
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(errorMessage, ERR_MESSAGE_USER_NO_PREFERENCES, 'Preference found attached to user');
    }
    
    /**********************************************************************
     * @description             Perform Test in WHERE user has Preferences
     */
    @isTest
    private static void getTopicsAndPreferencesTest() {
        Map<Id, PreferenceTopic__c> preferences = new Map<Id, PreferenceTopic__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                preferences = RYProfileCenterController.getTopicsAndPreferences('AU', 'Communication Subscriptions');
            }
        Test.stopTest();
        System.assert(!preferences.isEmpty(), 'User has no Preference returned');
    }

    /**********************************************************************
     * @description             Perform Negative Test in WHERE user has no Preferences
     */
    @isTest
    private static void getTopicsAndPreferencesNegativeTest() {
        String errorMessage;
        Map<Id, PreferenceTopic__c> preferences = new Map<Id, PreferenceTopic__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                try {
                    preferences = RYProfileCenterController.getTopicsAndPreferences('AU', 'test');
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(errorMessage, ERR_MESSAGE_NO_PREFERENCES, 'Preference found attached to user');
    }

    /**********************************************************************
     * @description             Test in WHERE user will return an Account
     */
    @isTest
    private static void getAccountTest() {
        Account accRetrieved = new Account();
        Account acc = [SELECT Id FROM Account WHERE FirstName = 'test0'];
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                accRetrieved = RYProfileCenterController.getAccount(new List<String>{'Id'});
            }
        Test.stopTest();
        System.assertEquals(accRetrieved.Id, acc.Id, 'User returned no Account');
    }

    /**********************************************************************
     * @description             Perform Test in WHERE class will return all bunning store account
     */
    @isTest
    private static void getBunningStoreAccountTest() {
        List<Account> acct = new List<Account>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
           System.runAs(ryUser) {
                acct = RYProfileCenterController.getRyobiAccounts('AU');
           }
        Test.stopTest();
        System.assert(!acct.isEmpty(), 'User returned no Account');
        System.assertEquals(acct[0].Name , 'Bunnings', 'No Bunnings account found');
    }
    
    /**********************************************************************
     * @description             Perform Negative Test in WHERE user has no returned Account
     */
    @isTest
    private static void getAccountNegativeTest() {
        String errorMessage;
        Account accRetrieved = new Account();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                try {
                    accRetrieved = RYProfileCenterController.getAccount(new List<String>{'Id'});
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(ERR_MESSAGE_RETURN_NONE, errorMessage, 'User returned Account');
    }

    /**********************************************************************
     * @description             Test in where it will return ProfileCenterData object
     */
    @isTest
    private static void updateDetailsTestPositive() {
        RYProfileCenterController.ProfileCenterData profileCenterData = new RYProfileCenterController.ProfileCenterData();
        List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
        List<Marketing_Preference__c> marketingPreferences = new List<Marketing_Preference__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Account acc = [SELECT Id, FirstName, LastName FROM Account WHERE FirstName = 'test0'];

        System.runAs(ryUser) {
            preferences = RYProfileCenterController.getPersonAccountPreferences();
            marketingPreferences = RYProfileCenterController.getMarketingPreferences(new List<String>{'Id','Feedback_Surveys__c'});
            acc.FirstName = 'test00';
            acc.LastName = 'test00';
            acc.Type = 'Individual';
            preferences[0].optOut__c = true;
            marketingPreferences[0].Feedback_Surveys__c = false;
    
            RYProfileCenterController.ProfileCenterData profileData = new RYProfileCenterController.ProfileCenterData();
            profileData.acct = acc;
            profileData.personAccPrefs = preferences;
            profileData.marketingPrefs = marketingPreferences[0];
            String data = JSON.serialize(profileData);
    
            Test.startTest();
                profileCenterData = RyProfileCenterController.updateDetails(data);
            Test.stopTest();
        }

        Account accVerify = [SELECT Id, FirstName, LastName FROM Account WHERE FirstName = 'test00'];
        PersonAccountPreference__c preferenceVerify = [SELECT Id, optOut__c FROM PersonAccountPreference__c WHERE Id = :preferences[0].Id];
        Marketing_Preference__c mktgPrefVerify = [SELECT Feedback_Surveys__c FROM Marketing_Preference__c WHERE Person_Account__c = :acc.Id];

        System.assertEquals('test00', accVerify.FirstName, 'Account has not been updated!');
        System.assertEquals('test00', accVerify.LastName, 'Account has not been updated!');
        System.assert(profileCenterData.personAccPrefs[0].optOut__c, 'Preference has not been updated!');
        System.assert(preferenceVerify.optOut__c, 'Preference has not been udpated');
        System.assert(!mktgPrefVerify.Feedback_Surveys__c, 'Marketing preference has not been updated');
    }
    
    /**********************************************************************
     * @description             Perform Negative Test in WHERE user wasn't 
     *                          able to update account or preference record
     */
    @isTest
    private static void updateDetailsTestNegative() {
       String errorMessage;
       Account acc = new Account();
       RYProfileCenterController.ProfileCenterData profileCenterData = new RYProfileCenterController.ProfileCenterData();
       List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
       Marketing_Preference__c marketingPreferences = new Marketing_Preference__c();
       User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
       RYProfileCenterController.ProfileCenterData profileData = new RYProfileCenterController.ProfileCenterData();
       profileData.acct = acc;
       profileData.personAccPrefs = preferences;
       profileData.marketingPrefs = marketingPreferences;
       String data = JSON.serialize(profileData);
       Test.startTest();
           System.runAs(ryUser) {
               try {
                    profileCenterData = RYProfileCenterController.updateDetails(data);
               } catch (Exception ex) {
                    errorMessage = ex.getMessage();
               }
            }
        Test.stopTest();
        System.assertEquals(errorMessage, ERR_GENERIC_MESSAGE, 'Successfully update user record');
    }

    /**********************************************************************
     * @description             Test to return Marketing Preferences of a Person Account
     */
    @isTest
    private static void getMarketingPreferencesTest() {
        List<Marketing_Preference__c> marketingPreferences = new List<Marketing_Preference__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];

        Test.startTest();
            System.runAs(ryUser) {
                marketingPreferences = RYProfileCenterController.getMarketingPreferences(new List<String>{'Id'});
            }
        Test.stopTest();
        System.assert(!marketingPreferences.isEmpty(), 'No marketing preferences for this person account');
    }

    /**********************************************************************
     * @description             Perform Negative Test in WHERE user has no Marketing Preferences
     */
    @isTest
    private static void getMarketingPreferencesNegativeTest() {
        String errorMessage;
        List<Marketing_Preference__c> marketingPreferences = new List<Marketing_Preference__c>();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                try {
                    marketingPreferences = RYProfileCenterController.getMarketingPreferences(new List<String>{'InvalidField'});
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(errorMessage.startsWith(ERR_MESSAGE_INVALID_FIELD), true, 'Marketing preferences found');
    }
}