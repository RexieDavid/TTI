/**
 * author:                  Francis Nasalita
 * date:                    2021-04-20
 * 
 */
public class TriageConsoleHelperController {
    private static final String GROUP_TYPE_QUEUE = 'Queue';
    private static final String QUEUE_SPAM = 'Spam';
    private static final String CASE_STATUS_CLOSED = 'Closed';

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        Map<Id, Profile> profileIds = new Map<Id, Profile>([
            SELECT Id, 
                   UserLicenseId 
              FROM Profile 
             WHERE UserLicenseId IN (SELECT Id FROM UserLicense WHERE Name = 'Salesforce')
        ]);

        return [SELECT Id, Name FROM User WHERE ProfileId IN :profileIds.Keyset() AND IsActive = true];
    }

    @AuraEnabled(cacheable=true)
    public static List<Group> getQueues() {
        return [SELECT Id, Name from Group where Id IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case')];
    }

    @AuraEnabled
    public static List<Case> changeOwner(List<Id> caseIds, Id newOwnerId) {
        return process(caseIds, newOwnerId, false);
    }

    @AuraEnabled
    public static List<Case> closeSpamCase(List<Id> caseIds) {
        return process(caseIds, getQueueId(QUEUE_SPAM), true);
    }

    @AuraEnabled
    public static List<Case> closeCase(List<Id> caseIds) {
        return process(caseIds, true);
    }

    @TestVisible
    private static Id getQueueId(String queueName) {
        return [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case' AND Queue.Name = :queueName LIMIT 1].QueueId;
    }

    private static List<Case> process(List<Id> caseIds, Boolean isClosed) {
        return process(caseIds, null, isClosed);
    }

    private static List<Case> process(List<Id> caseIds, Id newOwnerId, Boolean isClosed) {
        List<Case> cases = [SELECT Id, 
                                   CaseNumber
                              FROM Case
                             WHERE Id IN :caseIds];

        for (Case record : cases) {
            if (isClosed) {
                record.Status = CASE_STATUS_CLOSED;
                record.Service_Request_Milestone__c = CASE_STATUS_CLOSED;
            }

            if (String.isNotEmpty(newOwnerId)) {
                record.OwnerId = newOwnerId;
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            update cases;
        } catch(Exception e) {
            Database.rollback(sp);
            new AuraHandledException(Label.Generic_Error_Message);
        }

        return cases;
    }
}