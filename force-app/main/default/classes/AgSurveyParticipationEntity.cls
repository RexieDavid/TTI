public class AgSurveyParticipationEntity {

    /**********************************************************************
    * @description A survey's indentifier. If the survey is queried from a Survey custom object, value will be the survey 
    *              record's id. But if other implementations introduce other forms of survey, like via the old 
    *              Marketing_Campaign__c object, then this property can be the marketing campaign record's id.
    */
    public String surveyIdentifier { get; set; }

    /**********************************************************************
    * @description The id of the person account record that responded to the survey
    */
    public String respondentId { get; set; }

    /**********************************************************************
    * @description 
    */
    public List<Answer> answers { get; set; }

    public class Answer {
        public String questionIdentifier { get; set; }
        public String value { get; set; }
    }

}