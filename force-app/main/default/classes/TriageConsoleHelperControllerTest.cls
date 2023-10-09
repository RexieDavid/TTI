/**
 * autor:                   Francis Nasalita
 * date:                    2021-04-20
 * 
 */
@isTest
public class TriageConsoleHelperControllerTest {
    
    private static final String QUEUE_SPAM = 'Spam';
    private static final Integer CASE_COUNT = 5;

    @TestSetup
    static void makeData() {
        Group g1 = new Group(
            Name = QUEUE_SPAM, 
            type = 'Queue'
        );
        insert g1;

        QueuesObject q1 = new QueueSObject(
            QueueID = g1.id, 
            SobjectType = 'Case'
        );
        insert q1;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            createCases(CASE_COUNT);
        }
    }

    @IsTest
    static void testGetUsers() {
        
        Test.startTest();
            List<User> salesforceUsers = TriageConsoleHelperController.getUsers();

            System.assert(!salesforceUsers.isEmpty(), 'No Salesforce users found.');
        Test.stopTest();
        
    }

    @IsTest
    static void testGetQueues() {
        
        Test.startTest();
            List<Group> queues = TriageConsoleHelperController.getQueues();

            System.assert(queues.size() > 0, 'No Queues found.');
        Test.stopTest();
        
    }

    @IsTest
    static void testCloseSpamCase() {
        List<Case> cases = [SELECT Id FROM Case LIMIT :CASE_COUNT];
        Id spamId = TriageConsoleHelperController.getQueueId(QUEUE_SPAM);

        Test.startTest();
            List<Case> spamCases = TriageConsoleHelperController.closeSpamCase(getIds(cases));
            
            for (Case c : spamCases) {
                System.assertEquals(spamId, c.OwnerId, 'Unable to change case owner to Spam.');
                System.assertEquals('Closed', c.Status, 'Unable to close the case.');
            }
            System.assertEquals(CASE_COUNT, spamCases.size(), 'Unable to process the case.');
        Test.stopTest();
        
    }

    @IsTest
    static void testCloseCase() {
        List<Case> cases = [SELECT Id FROM Case LIMIT :CASE_COUNT];
        
        Test.startTest();
            List<Case> closedCases = TriageConsoleHelperController.closeCase(getIds(cases));
            
            for (Case c : closedCases) {
                System.assertEquals('Closed', c.Status, 'Unable to close the case.');
            }
            System.assertEquals(CASE_COUNT, closedCases.size(), 'Unable to close the case.');
        Test.stopTest();
        
    }

    @IsTest
    static void testChangeOwner() {
        List<Case> cases = [SELECT Id FROM Case LIMIT :CASE_COUNT];
        Id spamId = TriageConsoleHelperController.getQueueId(QUEUE_SPAM);

        Test.startTest();
            List<Case> spamCases = TriageConsoleHelperController.changeOwner(getIds(cases), spamId);
            
            for (Case c : spamCases) {
                System.assertEquals(spamId, c.OwnerId, 'Unable to change case owner to Spam.');
            }
            System.assertEquals(CASE_COUNT, spamCases.size(), 'Unable to process the cases.');
        Test.stopTest();
        
    }

    private static void createCases(Integer count) {
        List<Case> cases = new List<Case>();
        Id serviceReqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();

        for (Integer i = 0; i < count; i++) {
            cases.add(new Case(
                recordTypeId = serviceReqRTId
            ));
        }

        insert cases;
    }

    private static List<Id> getIds(List<Case> cases) {
        List<Id> caseIds = new List<Id>();

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        return caseIds;
    }
}