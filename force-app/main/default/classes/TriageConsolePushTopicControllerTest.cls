@isTest
public class TriageConsolePushTopicControllerTest {
    
    @TestSetup
    static void setup() {
        Group redemptions = new Group(Name='Redemptions Test', type='Queue');
        insert redemptions;
        QueuesObject queueObject1 = new QueueSObject(QueueID = redemptions.Id, SobjectType = 'Case');
        insert queueObject1;
        
        Group customerService = new Group(Name='Customer Service Test', type='Queue');
        insert customerService;
        QueuesObject queueObject2 = new QueueSObject(QueueID = customerService.Id, SobjectType = 'Case');
        insert queueObject2;
    }

    @isTest
    private static void getQueueIdsTest() {
        List<String> queueToFilterList = new List<String>{'Redemptions Test', 'Customer Service Test'};
        List<Group> queueList = new List<Group>();
        Test.startTest();
        	queueList = TriageConsolePushTopicController.getQueueIds(queueToFilterList);
        Test.stopTest();
        System.assertEquals(queueToFilterList.size(), queueList.size());
    }
}