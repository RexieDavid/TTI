/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
@isTest
private class CloudStorageOrchestrationLoggerTest {
    private static final String ERR_PAYLOADS_REQUIRED = 'System Log Payloads are required.';

    /**
     * @description                 Publish System Log platform
     *                              event with payload
     */
    @isTest
    private static void publishSystemLogWithPayload() {
        CloudStorageOrchestrationLogger logger = new CloudStorageOrchestrationLogger();
        Test.startTest();
            logger.run(fetchLogs());
        Test.stopTest();
        // No need to assert
    }

    /**
     * @description                 Publish System Log platform
     *                              event without payload
     * 
     *                              Will throw error due to null payload
     */
    @isTest
    private static void publishSystemLogWithEmptyPayload() {
        CloudStorageOrchestrationLogger logger = new CloudStorageOrchestrationLogger();
        String errMessage;
        Test.startTest();
            try {
                logger.run(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ERR_PAYLOADS_REQUIRED, errMessage, 'Successfully publish system log events');
    }

    /**
     * @description                 Create List of Logs
     */
    private static List<String> fetchLogs() {
        List<String> logs = new List<String>();
        for (Integer i = 0; i < 10; i++) {
            logs.add(createSystemLog(i));
        }
        return logs;
    }

    /**
     * @description                 Create System Log
     * 
     * @param uniqueIdentifier      entry number
     * 
     * @return                      Serialize record
     */
    private static String createSystemLog(Integer uniqueIdentifier) {
        System_Log__e log = new System_Log__e(
            Level__c = 'info',
            Payload__c = 'payload-' + uniqueIdentifier
        );
        return JSON.serialize(log);
    }
}