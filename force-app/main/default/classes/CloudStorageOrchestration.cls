/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
public class CloudStorageOrchestration {
    public enum Status { SUCCESS, FAILURE }
    private final String ERROR_LEVEL = 'error';
    private List<CloudStorageOrchestrationData> data;
    @TestVisible
    private CloudStorageOrchestrationService service = new CloudStorageOrchestrationService();

    /**
     * @description                 Constructor
     * 
     * @param data                  List of data 
     */
    public CloudStorageOrchestration(List<CloudStorageOrchestrationData> data) {
        this.data = data;
    }

    /**
     * @description                 Execute processes per provider and context
     */
    public void run() {
        Map<String, ICloudStorageProcess> processes = this.fetchProviderProcesses();
        Map<String, List<String>> successPayloads = this.fetchSuccessPayloads();
        for (String key : successPayloads.keySet()) {
            if (processes.containsKey(key)) { 
                processes.get(key).run(successPayloads.get(key));
            }
        }
        this.publishFailLogs();
    }

    /**
     * @description                 Fetch provider processes
     * 
     * @return                      Map of processes
     *                                  - key is combination of provider and context
     *                                  - value is a class that implements ICloudStorageProcess
     */
    private Map<String, ICloudStorageProcess> fetchProviderProcesses() {
        Map<String, ICloudStorageProcess> providerContextProcesses = new Map<String, ICloudStorageProcess>();
        try {
            for (External_Cloud_Provider_Process__mdt process : 
                this.service.fetchProvidersMedata(this.fetchProviders())) {
                String key = this.fetchProcessKey(new List<String>{process.Provider__r.DeveloperName, process.Context__c});
                providerContextProcesses.put(key, this.parseProcess(process.Process_Name__c));
            }
        } catch (Exception ex) {
            this.service.publishLogs(new List<String>{ this.createExceptionPayload(ex) });
            throw new CloudStorageOrchestrationException(Label.Generic_Error_Message);
        }
        return providerContextProcesses;
    }

    /**
     * @description                 Fetch process key
     * 
     * @param values                Key values
     * 
     * @return                      Process key
     */
    private String fetchProcessKey(List<String> values) {
        String placeholder = '{0} - {1}';
        return String.format(placeholder, values);
    }

    /**
     * @description                 Fetch cloud providers
     * 
     * @return                      List of external providers
     */
    private Set<String> fetchProviders() {
        Set<String> providers = new Set<String>();
        for (CloudStorageOrchestrationData csod : this.data) {
            if (String.isNotBlank(csod.provider)) {
                providers.add(csod.provider);
            }
        }
        return providers;
    }

    /**
     * @description                 Cast apex class to ICloudStorageProcess
     * 
     * @return                      ICloudStorageProcess class
     */
    private ICloudStorageProcess parseProcess(String processName) {
        return (ICloudStorageProcess)Injector.instantiate(processName);
    }

    /**
     * @description                 Create exception payload
     * 
     * @param ex                    Exception details
     * 
     * @return                      JSON Error
     */
    private String createExceptionPayload(Exception ex) {
        Map<String, String> exceptionPayload = new Map<String, String>{
            'type' => ex.getTypeName(),
            'value' => ex.getMessage(),
            'module' => ex.getStackTraceString()
        };
        CloudStorageOrchestrationData csod = new CloudStorageOrchestrationData();
        csod.level = this.ERROR_LEVEL;
        csod.payload = JSON.serialize(exceptionPayload);
        return this.constructSystemLog(csod);
    }

    /**
     * @description                 Fetch success payloads
     * 
     *                              Will be use in sub process
     * 
     * @return                      Map of provider-context and list of payloads
     */
    private Map<String, List<String>> fetchSuccessPayloads() {
        Map<String, List<String>> successPayloads = new Map<String, List<String>>();
        for (CloudStorageOrchestrationData csod : this.data) {
            if (csod.status == Status.SUCCESS) {
                String key = this.fetchProcessKey(new List<String>{csod.provider, csod.context});
                if (!successPayloads.containsKey(key)) {
                    successPayloads.put(key, new List<String>());
                }
                successPayloads.get(key).add(csod.payload);
            }
        }
        return successPayloads;
    }

    /**
     * @description                 Publish failed payloads to 
     *                              System Log platform event
     */
    private void publishFailLogs() {
        List<String> logs = new List<String>();
        for (CloudStorageOrchestrationData csod : this.data) { 
            if (csod.status == Status.FAILURE) {
                logs.add(this.constructSystemLog(csod));
            }
        }
        this.service.publishLogs(logs);
    }

    /**
     * @description                 Create System Log with level
     *                              and payload
     * 
     * @param csod                  Cloud Orchestration Data
     * 
     * @return                      Serialize JSON of System Log record
     */
    private String constructSystemLog(CloudStorageOrchestrationData csod) {
        System_Log__e log = new System_Log__e(
            Level__c = csod.Level,
            Payload__c = '[' + csod.payload + ']'
        );
        return JSON.serialize(log);
    }

    /**
     * @description                 Orchestrator data
     */
    public class CloudStorageOrchestrationData {
        public String provider;
        public String level;
        public String context;
        public Status status;
        public String payload;
    }

    public class CloudStorageOrchestrationException extends Exception {}
}