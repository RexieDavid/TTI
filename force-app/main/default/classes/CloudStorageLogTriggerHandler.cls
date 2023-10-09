/**
 * @author Samuel Oberes
 * @date 2020-09-16
 *
 * @description The handler for the trigger CloudUploadReadyTrigger
 *
 * @history
 * <Date>         <Author>       <Description>
 * YYYY-MM-DD     -              -
*/
public class CloudStorageLogTriggerHandler extends TriggerHandler {
    
    /**
     * @description                 Run after insert trigger
     */
    public override void afterInsert() {
        List<Cloud_Storage_Log__e> logs = (List<Cloud_Storage_Log__e>) Trigger.new;
        this.runCloudOrchestrator(logs);
        this.countPlatformEventService(logs);
    }

    /**
     * @description                 Run Cloud Storage Orchestration
     * 
     * @param logs                  Cloud_Storage_Log__e records
     */
    private void runCloudOrchestrator(List<Cloud_Storage_Log__e> logs) {
        List<CloudStorageOrchestration.CloudStorageOrchestrationData> csData = 
            new List<CloudStorageOrchestration.CloudStorageOrchestrationData>();
        for(Cloud_Storage_Log__e log : logs) {
            csData.add(this.buildCSOData(log));
        }
        CloudStorageOrchestration cso = new CloudStorageOrchestration(csData);
        cso.run();
    }

    /**
     * @description                 Create Cloud Storage Orchestration Data
     * 
     * @param log                   Cloud_Storage_Log__e record
     * 
     * @return                      CloudStorageOrchestration.CloudStorageOrchestrationData
     */
    private CloudStorageOrchestration.CloudStorageOrchestrationData buildCSOData(Cloud_Storage_Log__e log) {
        CloudStorageOrchestration.CloudStorageOrchestrationData data =
            new CloudStorageOrchestration.CloudStorageOrchestrationData();
        data.provider = log.Provider__c.toUpperCase();
        data.context = log.Context__c;
        data.level = log.Level__c;
        data.payload = log.Response_Payload__c;
        data.status = log.Status__c == 'success' ? 
                        CloudStorageOrchestration.Status.SUCCESS : 
                        CloudStorageOrchestration.Status.FAILURE;
        return data;
    }

    /**
     * @description                 Count published cloud storage log events
     * 
     * @param logs                  List of published Cloud_Storage_Log__e records
     */
    private void countPlatformEventService(List<Cloud_Storage_Log__e> logs) {
        new CountPlatformEventService()
            .setDescribeObjectResult(Cloud_Storage_Log__e.sObjectType.getDescribe())
            .run(logs);
    }
}