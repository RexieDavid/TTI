/*
* @author Rex Joseph Egoc
* @date 2020-02-11
*
* group: AEG Community
* group-content: ../../ApexDocContent/aeg-community.html
*
* @description Test Class for AEGProfileCenterController
*/

@isTest
private class AEGProfileCenterControllerTest {

    private static final String ERR_MESSAGE_NO_PREFERENCES = 'An error occured while getting the preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_USER_NO_PREFERENCES = 'An error occured while getting the user\'s preferences. Please contact your administrator';
    private static final String ERR_MESSAGE_RETURN_NONE = 'List has no rows for assignment to SObject';
    private static final String AEG_BRAND = 'AEG';
    private static final String PORTAL_USER_NAME = '1t4e7s8t3@yahoo.com.Aeg';
    private static final String USER_NO_ACCESS_NAME = '2t4e7s8t3@yahoo.com.Aeg';

    @TestSetup
    static void makeData() {
        List<CommunityProfileCompletionRuleset__c> rulesets = new List<CommunityProfileCompletionRuleset__c>();
        List<CommunityProfileCompletionRule__c> rules = new List<CommunityProfileCompletionRule__c>();
        List<Preference__c> newPreferenceList = new List<Preference__c>();
        List<PreferenceTopic__c> newPrefTopicsList = new List<PreferenceTopic__c>();
        List<PersonAccountPreference__c> newPersonAcctPrefList = new List<PersonAccountPreference__c>();
        List<User> userList = new List<User>();
        Profile profileWithoutAccess = [SELECT Id FROM Profile WHERE Name = '~System Administrator' LIMIT 1];
        Profile aegCommunityProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community AEG' LIMIT 1];

        rulesets.add(new CommunityProfileCompletionRuleset__c(
            Brand__c = 'AG',
            Description__c = 'Business'
        ));
        rulesets.add(new CommunityProfileCompletionRuleset__c(
            Brand__c = 'AG',
            Description__c = 'Individual'
        ));
        insert rulesets;

        List<String> fields = new List<String>{'FirstName', 'LastName'};
        for (Integer counter = 0; counter < 2; counter++) {
            rules.add(new CommunityProfileCompletionRule__c(
                CommunityProfileCompletionRuleset__c = rulesets[0].Id,
                FieldAPIName__c = 'Account.' + fields[counter],
                Weightage__c = 50

            ));
            rules.add(new CommunityProfileCompletionRule__c(
                CommunityProfileCompletionRuleset__c = rulesets[1].Id,
                FieldAPIName__c = 'Account.' + fields[counter],
                Weightage__c = 50

            ));
        }
        insert rules;


        List<Account> newPersonAccount = AgTestDataFactory.buildPersonAccountList(2);
        insert newPersonAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId = :newPersonAccount[0].Id];
        eContact.Brand__c = AEG_BRAND;
        update eContact;

        for (Integer counter = 0; counter < 5; counter++) {
            PreferenceTopic__c newPrefTopic = AgTestDataFactory.buildPreferenceTopic(counter, counter < 2 ? 'Communication Subscriptions' : 'Market Research');
            newPrefTopicsList.add(newPrefTopic);
        }
        insert newPrefTopicsList;

        for (Integer counter = 0; counter < 5; counter++) {
            Preference__c newPreference = AgTestDataFactory.buildPreference(counter, newPrefTopicsList.get(counter).Id);
            newPreferenceList.add(newPreference);
        }
        insert newPreferenceList;

        for (Integer counter = 0; counter < 1; counter++) {
            PersonAccountPreference__c newPersonAccountPref = AgTestDataFactory.buildPersonAccountPreference(newPersonAccount[0].Id,
                                                                                                            newPreferenceList.get(counter).Id);
            newPersonAcctPrefList.add(newPersonAccountPref);
        }
        insert newPersonAcctPrefList;

        for (Integer counter = 0; counter < 2; counter ++) {
            Boolean separator = counter == 0;
            User newUser = AgTestDataFactory.buildUser(separator ? aegCommunityProfile.Id : profileWithoutAccess.Id, 
                                                       separator ? eContact.Id : null,
                                                       separator ? PORTAL_USER_NAME : USER_NO_ACCESS_NAME);
            userList.add(newUser);
        }
        insert userList;
    }

    @isTest
    private static void getPersonAccountPreferencesTest() {
        List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                preferences = AEGProfileCenterController.getPersonAccountPreferences();
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
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                try {
                    preferences = AEGProfileCenterController.getPersonAccountPreferences();
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
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                preferences = AEGProfileCenterController.getTopicsAndPreferences('AU', 'Communication');
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
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                try {
                    preferences = AEGProfileCenterController.getTopicsAndPreferences('AU', 'test');
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
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                accRetrieved = AEGProfileCenterController.getAccount(new List<String>{'Id'});
            }
        Test.stopTest();
        System.assertEquals(accRetrieved.Id, acc.Id, 'User returned no Account');
    }

    /**********************************************************************
     * @description             Perform Negative Test in WHERE user has no returned Account
     */
    @isTest
    private static void getAccountNegativeTest() {
        String errorMessage;
        Account accRetrieved = new Account();
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(aegUser) {
                try {
                    accRetrieved = AEGProfileCenterController.getAccount(new List<String>{'Id'});
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
    private static void updateDetailsTest() {
        AEGProfileCenterController.ProfileCenterData profileCenterData = new AEGProfileCenterController.ProfileCenterData();
        List<PersonAccountPreference__c> preferences = new List<PersonAccountPreference__c>();
        User aegUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Account acc = [SELECT Id, FirstName, LastName FROM Account WHERE FirstName = 'test0'];

        System.runAs(aegUser) {
            preferences = AEGProfileCenterController.getPersonAccountPreferences();

            acc.FirstName = 'test00';
            acc.LastName = 'test00';
            acc.Type = 'Individual';
            preferences[0].optOut__c = true;
    
            AEGProfileCenterController.ProfileCenterData profileData = new AEGProfileCenterController.ProfileCenterData();
            profileData.acct = acc;
            profileData.fields = new List<String>{'PersonHasOptedOutOfEmail'};
            profileData.personAccPrefs = preferences;
            String data = JSON.serialize(profileData);
    
            Test.startTest();
                profileCenterData = AEGProfileCenterController.updateDetails(data);
            Test.stopTest();
        }

        Account accVerify = [SELECT Id, FirstName, LastName FROM Account WHERE FirstName = 'test00'];
        PersonAccountPreference__c preferenceVerify = [SELECT Id, optOut__c FROM PersonAccountPreference__c WHERE Id = :preferences[0].Id];

        System.assertEquals('test00', accVerify.FirstName, 'Account has not been updated!');
        System.assertEquals('test00', accVerify.LastName, 'Account has not been updated!');
        System.assert(profileCenterData.personAccPrefs[0].optOut__c, 'Preference has not been updated!');
        System.assert(preferenceVerify.optOut__c, 'Preference has not been udpated');
    }
}