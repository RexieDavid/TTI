@IsTest
public class AgSurveyServiceTest {

    private static final AgSurveyService service = (AgSurveyService) Test.createStub(AgSurveyService.class, new AgSurveyServiceMocker());

    @TestSetup
    static void initData() {
        // 
    }

    private static testMethod void constructorMissingSurveyTypeTest() {

        Test.startTest();

        String errorMessage = '';
        try {
            AgSurveyService surveyService = new AgSurveyService('');
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals(AgSurveyService.ERR_MISSING_SURVEY_TYPE, errorMessage, 'Resulting error message must match the default.');

    }

    private static testMethod void constructorMissingImplemClassTest() {

        Test.startTest();

        String errorMessage = '';
        try {
            AgSurveyService surveyService = new AgSurveyService('nonexistent_implementation');
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals(AgSurveyService.ERR_MISSING_IMPLEM_CLASS, errorMessage, 'Resulting error message must match the default.');

    }

    // private static testMethod void constructorPositiveTest() {

    //     Ag_Survey_Implementation__mdt surveyImplemMetadata = new Ag_Survey_Implementation__mdt();
    //     surveyImplemMetadata.Survey_Class_Name__c = 'SampleSurveyClassname';
    //     surveyImplemMetadata.Survey_Participation_Class_Name__c = 'SampleSurveyParticipationClassname';
    //     surveyImplemMetadata.Label = 'Survey Test';
    //     surveyImplemMetadata.DeveloperName = 'Survey_Test';
    //     insert surveyImplemMetadata;

    //     Test.startTest();

    //     AgSurveyService surveyService;
    //     String errorMessage = 'no_errors_thrown';
    //     try {
    //         surveyService = new AgSurveyService('Survey_Test');
    //     } catch (AgSurveyService.AgSurveyServiceException ex) {
    //         errorMessage = ex.getMessage();
    //     }

    //     Test.stopTest();

    //     // assertions
    //     System.assert(surveyService.survey != null, 'The survey must already be instantiated.');
    //     System.assertEquals('no_errors_thrown', errorMessage, 'Errors thrown where it shouldn\'t be. Kindly check your setup.');

    // }

    private static testMethod void fetchNegativeTest() {
        
        Test.startTest();

        String errorMessage = '';
        try {
            AgSurveyService.testMockingHelperVariable = 'fail_the_fetch_method';
            service.fetch();
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals(AgSurveyService.ERR_SURVEY_FETCH, errorMessage, 'Resulting error message must match the default.');

    }

    private static testMethod void fetchPositiveTest() {
        
        Test.startTest();

        AgSurveyEntity se = new AgSurveyEntity();
        String errorMessage = 'no_errors_thrown';
        try {
            se = service.fetch();
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assert(se.surveyIdentifier == 'i_am_a_valid_survey', 'The surveyIdentifier must contain the valid value.');
        System.assertEquals('no_errors_thrown', errorMessage, 'Errors thrown where it shouldn\'t be. Kindly check your setup.');

    }

    private static testMethod void saveNegativeTest() {
        
        Test.startTest();

        AgSurveyParticipationEntity spe = new AgSurveyParticipationEntity();
        spe.surveyIdentifier = 'i_am_an_invalid_survey';

        String errorMessage = '';
        try {
            service.save(spe);
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals(AgSurveyService.ERR_SURVEY_SAVE, errorMessage, 'Resulting error message must match the default.');

    }

    private static testMethod void savePositiveTest() {
        
        Test.startTest();

        AgSurveyParticipationEntity spe = new AgSurveyParticipationEntity();
        spe.surveyIdentifier = 'i_am_a_valid_survey';

        String errorMessage = 'no_errors_thrown';
        try {
            service.save(spe);
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals('no_errors_thrown', errorMessage, 'Errors thrown where it shouldn\'t be. Kindly check your setup.');

    }

    private static testMethod void hasParticipatedNegativeTest() {
        
        Test.startTest();

        Id randomPersonAccountId = '0015O000003FAIL';
        String errorMessage = '';
        try {
            service.hasParticipated(randomPersonAccountId);
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals(AgSurveyService.ERR_SURVEY_PARTICIPATED, errorMessage, 'Resulting error message must match the default.');

    }

    private static testMethod void hasParticipatedPositiveTest() {
        
        Test.startTest();

        Id randomPersonAccountId = '0015O000SUCCESS';
        String errorMessage = 'no_errors_thrown';
        Boolean hasParticipated = false;
        try {
            hasParticipated = service.hasParticipated(randomPersonAccountId);
        } catch (AgSurveyService.AgSurveyServiceException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        // assertions
        System.assertEquals('no_errors_thrown', errorMessage, 'Errors thrown where it shouldn\'t be. Kindly check your setup.');
        System.assert(hasParticipated, 'There must be a valid participation');

    }

}