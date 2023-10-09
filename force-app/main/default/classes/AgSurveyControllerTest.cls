@isTest
public class AgSurveyControllerTest {

    private static final String AEG_BRAND = 'AEG';
    private static final String PORTAL_USER_NAME = 'svenson@yopmail.com';
    
    @TestSetup
    static void initData() {
        Id aegCommunityProfileId = [SELECT Id FROM Profile WHERE Name = '~Customer Community AEG' LIMIT 1].Id;

        List<Account> newPersonAccount = AgTestDataFactory.buildPersonAccountList(1);
        newPersonAccount[0].Is_survey_completed__c = true;
        insert newPersonAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId = :newPersonAccount[0].Id];
        eContact.Brand__c = AEG_BRAND;
        update eContact;

        User newUser = AgTestDataFactory.buildUser(aegCommunityProfileId, eContact.Id, PORTAL_USER_NAME);
        insert newUser;
    }

    @IsTest
    static void fetchTest() {        
        Test.startTest();
        AgSurveyEntity surveyEntity = AgSurveyController.getSurveyDetails();
        Test.stopTest();    

        System.assert(surveyEntity != null, 'The surveyEntity must not be null.');
        
    }

    @IsTest
    static void accountHasParticipatedTest() {
        User aegUser = [SELECT Id FROM User WHERE Username = :PORTAL_USER_NAME];
        
        Test.startTest();
        Boolean accountHasParticipated;
        System.runAs(aegUser) {
            accountHasParticipated = AgSurveyController.hasParticipated();
        }
        Test.stopTest();

        System.assert(accountHasParticipated, 'The Account must be already participated survey.');        
    }

    @IsTest
    static void saveSurveyTest() {
        User aegUser = [SELECT Id, AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        
        Test.startTest();
        System.runAs(aegUser) {
            AgSurveyController.saveSurvey('', new List<String>{ '' }, new List<String>{ 'On the Radio' });
        }
        Test.stopTest();
        
        Account aegAccount = [SELECT Is_survey_completed__c FROM Account WHERE Id = :aegUser.AccountId];
        System.assert(aegAccount.Is_survey_completed__c, 'The Account must be completed survey.');   
    }
}