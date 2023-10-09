/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-30
 * 
 * @group                               Cloud Storage Log
 */
@isTest
private class CloudStorageLogTriggerHandlerTest {

    /**
     * @description                 Bulk publish cloud storage log events
     */
    @isTest
    private static void publishCloudStorageEvent() {
        List<Database.SaveResult> result;
        Test.startTest();
            result = EventBus.publish(fetchLogs());
        Test.stopTest();
        System.assert(isSuccess(result), 'Error publishing platform events');
    }

    /**
     * @description                 Fetch logs to publish
     * 
     * @return                      Cloud storage log events
     */
    private static List<Cloud_Storage_Log__e> fetchLogs() {
        List<Cloud_Storage_Log__e> logs = new List<Cloud_Storage_Log__e>();
        for (Integer i = 0; i < 20; i++) {
            logs.add(createLogs(i));
        }
        return logs;
    }

    /**
     * @description                 Create Cloud Storage log event
     * 
     * @param uniqueIdentifier      Unique identifier for unique values
     * 
     * @return                      Mock Cloud Storage Log event
     */
    private static Cloud_Storage_Log__e createLogs(Integer uniqueIdentifier) {
        return new Cloud_Storage_Log__e(
            Provider__c = 'Provider - ' + uniqueIdentifier,
            Context__c = 'Context - ' + uniqueIdentifier,
            Response_Payload__c = 'Sample Payload - ' + uniqueIdentifier,
            Status__c = Math.mod(uniqueIdentifier, 2) == 0 ? 'success' : 'failure',
            Level__c = 'info'
        );
    }

    private static Boolean isSuccess(List<Database.SaveResult> result) {
        Boolean isSuccess = true;
        for (Database.SaveResult sr : result) {
            if (!sr.isSuccess()) {
                isSuccess = sr.isSuccess();
            }
        }
        return isSuccess;
    }
    
}