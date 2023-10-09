public without sharing class MyRyobiCustomerSurveyController {

	@AuraEnabled
    public static String getCurrentUser(String contactId) {
        if (contactId != null && contactId != '') {
            List<User> users = [SELECT Id, ContactId, Contact.Account.Name, Profile.Name FROM User WHERE ContactId = :contactId];

            if (!users.isEmpty()) {
                return users[0].Contact.Account.Name + '=::=' + [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Name;
            }
        } else {
            List<User> users = [SELECT Id, ContactId, Contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()];

            if (!users.isEmpty()) {
                return users[0].ContactId;
            }
        }

        return 'User';
    }

    @AuraEnabled
    public static Boolean hasCustomerFinishedSurvey(String contactId) {
        Id userId = UserInfo.getUserId();
        if (contactId != null && contactId != '') {
            List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId];

            if (!users.isEmpty()) {
                userId = users[0].Id;
            }
        } 

        Id userPersonAccountId = [SELECT Id, AccountId FROM User WHERE Id = :userId LIMIT 1][0].AccountId;

        Account userPersonAccount = [SELECT Id, Is_survey_completed__c FROM Account WHERE Id = :userPersonAccountId LIMIT 1][0];

        if (userPersonAccount.Is_survey_completed__c) {
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static String saveSurvey(String contactId, String q1, String q2) {
        Id userId = UserInfo.getUserId();
        if (contactId != null && contactId != '') {
            List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId];

            if (!users.isEmpty()) {
                userId = users[0].Id;
            }
        }  

        User currentUser = [SELECT Id, AccountId, Profile.Name FROM User WHERE Id = :userId LIMIT 1][0];

        Account userPersonAccount = [SELECT Id, Confidence_in_Power_Tools__c, DIY_Enjoyment__c, Is_survey_completed__c FROM Account WHERE Id = :currentUser.AccountId LIMIT 1][0];

        userPersonAccount.Confidence_in_Power_Tools__c = q1;
        userPersonAccount.DIY_Enjoyment__c = q2;
        userPersonAccount.Is_survey_completed__c = true;

        try {
            update userPersonAccount;
        } catch (Exception err) {
            return err + ' - ' + userPersonAccount.Id;
        }

        return 'SUCCESS';
    }

    @AuraEnabled
    public static String cancelSurvey(String contactId) {
        Id userId = UserInfo.getUserId();
        if (contactId != null && contactId != '') {
            List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId];

            if (!users.isEmpty()) {
                userId = users[0].Id;
            }
        }

        try {

            User currentUser = [SELECT Id, AccountId, Profile.Name FROM User WHERE Id = :userId LIMIT 1][0];

            Account userPersonAccount = [SELECT Id, Confidence_in_Power_Tools__c, DIY_Enjoyment__c, Is_survey_completed__c FROM Account WHERE Id = :currentUser.AccountId LIMIT 1][0];

            userPersonAccount.Confidence_in_Power_Tools__c = null;
            userPersonAccount.DIY_Enjoyment__c = null;
            userPersonAccount.Is_survey_completed__c = true;

            
            update userPersonAccount;
        } catch (Exception err) {
            return err + ' ';
        }

        return 'SUCCESS';
    }

}