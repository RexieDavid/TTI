/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
public class CloudStorageOrchestrationLogger implements ICloudStorageProcess {
    private final String ERR_PAYLOADS_REQUIRED = 'System Log Payloads are required.';

    /**
     * @description                 Publish System log events
     * 
     * @param payloads              List of payloads to proces
     */
    public void run(List<String> payloads) {
        if (payloads == null) {
            throw new CloudStorageOrchestrationLoggerException(this.ERR_PAYLOADS_REQUIRED);
        }

        List<System_Log__e> logs = this.createSystemLogs(payloads);
        System.debug('System Log: ' + payloads);
        // SD-1286 - Disable System Logs
        // List<Database.SaveResult> results = EventBus.publish(logs);
        // for (Database.SaveResult sr : results) {
        //     if (!sr.isSuccess()) {
        //         throw new CloudStorageOrchestrationLoggerException(Label.Generic_Error_Message);
        //     }
        // }
    }

    /**
     * @description                 Create system logs with payload
     * 
     * @return                      System Log platform events
     */
    private List<System_Log__e> createSystemLogs(List<String> payloads) {
        List<System_Log__e> systemLogs = new List<System_Log__e>();
        for (String payload : payloads) {
            systemLogs.add((System_Log__e)JSON.deserialize(payload, System_Log__e.class));
        }
        return systemLogs;
    }

    /**
     * @description                 Custom Exception
     */
    public class CloudStorageOrchestrationLoggerException extends Exception {}
}