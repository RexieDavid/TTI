public class TriageConsolePushTopicController {

    @AuraEnabled
    public static List<Group> getQueueIds (List<String> queueList) {
        return [SELECT Id FROM Group WHERE Type = 'Queue' AND Name IN :queueList];
    }
}