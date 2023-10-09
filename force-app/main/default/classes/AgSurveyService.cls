public class AgSurveyService {

    private AgSurvey survey;
    private AgSurveyParticipation surveyParticipation;

    public static String testMockingHelperVariable = '';

    public static final String ERR_MISSING_SURVEY_TYPE = 'You must define the type of survey you want to call.';
    public static final String ERR_MISSING_IMPLEM_CLASS = 'Setup error. Please check the survey implementations custom metadata.';
    public static final String ERR_SURVEY_FETCH = 'Survey fetching error. Please contact your administrator.';
    public static final String ERR_SURVEY_SAVE = 'Survey saving error. Please contact your administrator.';
    public static final String ERR_SURVEY_PARTICIPATED = 'Survey participation checking error. Please contact your administrator.';

    public AgSurveyService(String surveyType) {

        if (String.isBlank(surveyType)) {
            throw new AgSurveyServiceException(ERR_MISSING_SURVEY_TYPE);
        }

        List<Ag_Survey_Implementation__mdt> implementations = [SELECT Survey_Class_Name__c, Survey_Participation_Class_Name__c
                                                                 FROM Ag_Survey_Implementation__mdt
                                                                WHERE DeveloperName = :surveyType
                                                                LIMIT 1];

        if (implementations.isEmpty()) {
            throw new AgSurveyServiceException(ERR_MISSING_IMPLEM_CLASS);
        }

        Ag_Survey_Implementation__mdt implementation = implementations.get(0);

        survey = (AgSurvey) Type.forName(implementation.Survey_Class_Name__c).newInstance();
        surveyParticipation = (AgSurveyParticipation) Type.forName(implementation.Survey_Participation_Class_Name__c).newInstance();
    }

    public AgSurveyEntity fetch() {
        try {
            return survey.fetch();
        } catch (Exception ex) {
            throw new AgSurveyServiceException(ERR_SURVEY_FETCH);
        }
    }

    public void save(AgSurveyParticipationEntity surveyParticipationEntity) {
        try {
            surveyParticipation.save(surveyParticipationEntity);
        } catch (Exception ex) {
            throw new AgSurveyServiceException(ERR_SURVEY_SAVE);
        }
    }

    public Boolean hasParticipated(Id personAccountId) {
        try {
            return surveyParticipation.hasParticipated(personAccountId);
        } catch (Exception ex) {
            throw new AgSurveyServiceException(ERR_SURVEY_PARTICIPATED);
        }
    }

    public class AgSurveyServiceException extends Exception {}
}