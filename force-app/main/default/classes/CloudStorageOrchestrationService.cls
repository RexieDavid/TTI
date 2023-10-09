/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
public with sharing class CloudStorageOrchestrationService {
    private final String ERR_CLOUD_PROVIDERS_REQUIRED = 'External Cloud Providers are required.';
    private final String ERR_LOG_PAYLOADS_REQUIRED = 'Log payloads are required.';

    /**
     * @description                 Fetch provider processes in custom metadata
     * 
     * @return                      List of External Cloud providers with child processes
     */
    public List<External_Cloud_Provider_Process__mdt> fetchProvidersMedata(Set<String> providers) {
        if (providers == null) {
            throw new CloudStorageOrchestrationServiceException(this.ERR_CLOUD_PROVIDERS_REQUIRED);
        }

        return [SELECT Id, 
                       Process_Name__c,
                       Provider__r.DeveloperName,
                       Context__c
                FROM External_Cloud_Provider_Process__mdt
                WHERE Provider__r.DeveloperName IN :providers
                AND Active__c = TRUE];
    }
    /**
     * @description                 Publish system log platform event
     * 
     * @param payloads              List of payloads
     */
    public void publishLogs(List<String> payloads) {
        if (payloads == null) {
            throw new CloudStorageOrchestrationServiceException(this.ERR_LOG_PAYLOADS_REQUIRED);
        }

        new CloudStorageOrchestrationLogger().run(payloads);
    }

    /**
     * @description                 Custom Exception
     */
    public class CloudStorageOrchestrationServiceException extends Exception {}
}