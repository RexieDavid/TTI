/**
* @author Francis Nasalita
* @date 2020-06-02
*
* @group Aeg Community
* @group-content ../../ApexDocContent/aeg-community.html
*
* @description The AEG survey modal controller
*/
public class AgSurveyController {

    private static final String ER_USER_HAS_NO_COUNTRY = 'User has no country';
    
    /**********************************************************************
    * @description Returns survey data
    *
    * @example
    * AgSurveyController.getSurveyDetails();
    */
    @AuraEnabled
    public static AgSurveyEntity getSurveyDetails() {
        AgSurveyService survey = new AgSurveyService('Product_Exposure');
        return survey.fetch();
    }
        
    /**********************************************************************
    * @description Returns if account has already participated survey
    *
    * @example
    * AgSurveyController.getSurveyDetails();
    */
    @AuraEnabled
    public static Boolean hasParticipated() {
        User agUser = [SELECT AccountId, Country FROM User Where Id = :UserInfo.getUserId()];

        if (String.isEmpty(agUser.Country)) {
            throw new AgSurveyControllerException(ER_USER_HAS_NO_COUNTRY);
        }

        if (agUser.Country.toLowerCase() != 'australia') {
            return true;
        }

        AgSurveyService survey = new AgSurveyService('Product_Exposure');
        return survey.hasParticipated(agUser.AccountId);
    }

    /**********************************************************************
    * @description Saves user's survey response
    * @param surveyIdentifier Survey Id
    * @param questionsIdentifier Survey question api name
    * @param questionsAnswer User's answers
    * @example
    * AgSurveyController.saveSurvey('surveyId', new List<String>{ 'q1', 'q2' }, new List<String>{ 'On the Radio', 'On Facebook; On Tv' });
    */
    @AuraEnabled
    public static void saveSurvey(String surveyIdentifier, List<String> questionsIdentifier, List<String> questionsAnswer) {
        Id accountId = [SELECT AccountId FROM User Where Id = :UserInfo.getUserId()].AccountId;

        AgSurveyService survey = new AgSurveyService('Product_Exposure');
        AgSurveyParticipationEntity surveyParticipationEntity = new AgSurveyParticipationEntity();
        
        List<AgSurveyParticipationEntity.Answer> tempAnswers = new List<AgSurveyParticipationEntity.Answer>();
        for (Integer ctr = 0; ctr < questionsAnswer.size(); ctr++) {
            if (String.isNotBlank(questionsAnswer[ctr])) {
                AgSurveyParticipationEntity.Answer answer = new AgSurveyParticipationEntity.Answer();
                answer.questionIdentifier = questionsIdentifier[ctr];
                answer.value = questionsAnswer[ctr];
                tempAnswers.add(answer);
            }
        }

        surveyParticipationEntity.answers = tempAnswers;            
        surveyParticipationEntity.respondentId = accountId;   
        surveyParticipationEntity.surveyIdentifier = surveyIdentifier;

        survey.save(surveyParticipationEntity);
    }

    public class AgSurveyControllerException extends Exception {}
}