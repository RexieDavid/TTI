@IsTest
public class AgSurveyServiceMocker implements System.StubProvider {
    
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) {

        switch on stubbedMethodName {
            when 'fetch' {
                if (AgSurveyService.testMockingHelperVariable == 'fail_the_fetch_method') {
                    throw new AgSurveyService.AgSurveyServiceException(AgSurveyService.ERR_SURVEY_FETCH);
                } else {
                    AgSurveyEntity se = new AgSurveyEntity();
                    se.surveyIdentifier = 'i_am_a_valid_survey';
                    return se;
                }
            }
            when 'save' {
                AgSurveyParticipationEntity spe = (AgSurveyParticipationEntity) listOfArgs.get(0);
                if (spe.surveyIdentifier == 'i_am_an_invalid_survey') {
                    throw new AgSurveyService.AgSurveyServiceException(AgSurveyService.ERR_SURVEY_SAVE);
                }

                return null;
            }
            when 'hasParticipated' {
                Id personAccountId = (Id) listOfArgs.get(0);
                if (personAccountId == '0015O000003FAIL') {
                    throw new AgSurveyService.AgSurveyServiceException(AgSurveyService.ERR_SURVEY_PARTICIPATED);
                }
                return true;
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }

    }

}