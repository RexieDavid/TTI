public class AgProductExposureSurveyParticipation implements AgSurveyParticipation {
    
    public Boolean hasParticipated(Id personAccountId) {
        if (String.isBlank(personAccountId)) {
            // throw new Exception();
            System.debug('DBG: ERROR - account id should be populated');
        }

        List<Account> accounts = [SELECT Is_survey_completed__c FROM Account WHERE Id = :personAccountId];

        if (accounts.isEmpty()) {
            // throw new Exception();
            System.debug('DBG: ERROR - no account found');
        }
        
        return accounts.get(0).Is_survey_completed__c;
    }

    public void save(AgSurveyParticipationEntity surveyParticipationEntity) {
        if (surveyParticipationEntity == null) {
            // throw new Exception();
            System.debug('DBG: ERROR - surveyParticipationEntity should be populated');
        }

        if (String.isBlank(surveyParticipationEntity.respondentId)) {
            // throw new Exception();
            System.debug('DBG: ERROR - respondentId should be populated');
        }

        Savepoint sp = Database.setSavepoint();

        Account personAccount = new Account();
        personAccount.Id = surveyParticipationEntity.respondentId;
        personAccount.Is_survey_completed__c = true;

        // DML - update (1)
        try {
            update personAccount;
        } catch (Exception ex) {
            // throw new Exception();
            System.debug('DBG: ERROR - account update error --- ' + ex.getMessage());
            Database.rollback(sp);
        }

        Marketing_Campaign__c mc;
        if (surveyParticipationEntity.answers != null && !surveyParticipationEntity.answers.isEmpty()) {
            mc = new Marketing_Campaign__c();
            mc.RecordTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName().get('AEG_Purchasing_Information').getRecordTypeId();
            mc.Person_Account__c = surveyParticipationEntity.respondentId;

            List<String> answerList = new List<String>();
            for (AgSurveyParticipationEntity.Answer answer : surveyParticipationEntity.answers) {
                answerList.add(answer.value);
            }

            mc.AG_Product_Information_Source__c = String.join(answerList, '; ');

            // DML - insert (1)
            try {
                insert mc;
            } catch (Exception ex) {
                // throw new Exception();
                System.debug('DBG: ERROR - marketing campaign insert error --- ' + ex.getMessage());
                Database.rollback(sp);
            }
        }


    }

}