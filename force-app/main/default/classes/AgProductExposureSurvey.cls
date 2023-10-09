public class AgProductExposureSurvey implements AgSurvey {
    
    public AgSurveyEntity fetch() {
        AgSurveyEntity surveyEntity = new AgSurveyEntity();

        AgSurveyEntity.Question question = new AgSurveyEntity.Question();
        question.label = System.Label.AG_Product_Information_Source;
        question.options = new List<AgSurveyEntity.QuestionOption>();

        for (Schema.PicklistEntry entry : Marketing_Campaign__c.AG_Product_Information_Source__c.getDescribe().getPicklistValues()) {
            AgSurveyEntity.QuestionOption option = new AgSurveyEntity.QuestionOption();
            option.label = entry.getLabel();
            option.value = entry.getValue();
            question.options.add(option);
        }

        surveyEntity.questions = new List<AgSurveyEntity.Question>{ question };

        return surveyEntity;
    }

}