public interface AgSurveyParticipation {
    Boolean hasParticipated(Id personAccountId);
    void save(AgSurveyParticipationEntity surveyParticipationEntity);
}