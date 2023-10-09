public class AgSurveyEntity {

    /**********************************************************************
    * @description A survey's indentifier. If the survey is queried from a Survey custom object, value will be the survey 
    *              record's id. But if other implementations introduce other forms of survey, like via the old 
    *              Marketing_Campaign__c object, then this property can be the marketing campaign record's id.
    */
    @AuraEnabled
    public String surveyIdentifier { get; set; }

    /**********************************************************************
    * @description 
    */
    @AuraEnabled
    public List<Question> questions { get; set; }
    
    public class Question {
        @AuraEnabled
        public String identifier { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public List<QuestionOption> options { get; set; }
    }
    
    public class QuestionOption {
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }
    }

}