@IsTest
private class SystemLogTriggerHandlerTest {

    /**
     * @description                 Bulk system log log events
     */
    @isTest
    private static void publishSystemLogEvent() {
        List<Database.SaveResult> result;
        Test.startTest();
            result = EventBus.publish(fetchEvents());
        Test.stopTest();
        System.assert(isSuccess(result), 'Error publishing platform events');
    }

    /**
     * @description                 Fetch logs to publish
     * 
     * @return                      Cloud storage log events
     */
    private static List<System_Log__e> fetchEvents() {
        List<System_Log__e> events = new List<System_Log__e>();
        for (Integer i = 0; i < 20; i++) {
            events.add(new System_Log__e(
                Level__c = 'Info',
                Payload__c = 'Payload ' + i
            ));
        }
        return events;
    }

    private static Boolean isSuccess(List<Database.SaveResult> result) {
        Boolean isSuccess = true;
        for (Database.SaveResult sr : result) {
            if (!sr.isSuccess()) {
                isSuccess = sr.isSuccess();
                break;
            }
        }
        return isSuccess;
    }
}