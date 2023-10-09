/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
@isTest
public class CloudStorageOrchestrationServiceMock implements System.StubProvider {
    public static String errorMessage;

    /*
     * @description         Return dummy response per method name
     */
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) {

        switch on stubbedMethodName {
            when 'fetchProvidersMedata' {
                if (String.isNotBlank(errorMessage)) {
                    throw new CloudStorageOrchestrationServiceMockException(errorMessage);
                }
                return this.fetchProviderProcesses();
            }
            when 'publishLogs' {
                return 'success';
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    /*
     * @description         Fetch list of provider processes to be executed
     */
    public List<External_Cloud_Provider_Process__mdt> fetchProviderProcesses() {
        List<External_Cloud_Provider_Process__mdt> processes = new List<External_Cloud_Provider_Process__mdt>();
        for (Integer i = 0; i < 5; i++) {
            processes.add(this.createProviderProcess(i));
        }
        return processes;
    }

    /*
     * @description         Create dummy External_Cloud_Provider_Process__mdt record
     */
    public External_Cloud_Provider_Process__mdt createProviderProcess(Integer uniqueIdentifier) {
        String recordJson = '{' + 
                '"Active": "true", ' +
                '"Context__c": "Process-' + uniqueIdentifier + '", ' + 
                '"Process_Name__c": "CloudStorageOrchestrationServiceMock.CloudStorageProcessMock", ' +
                '"Provider__r": {' + 
                    '"DeveloperName": "Provider-'+ uniqueIdentifier + '"' +
                '}' +
            '}';
        return (External_Cloud_Provider_Process__mdt)JSON.deserialize(recordJson, External_Cloud_Provider_Process__mdt.class);
    }

    /*
     * @description         Dummy class for dependency injection
     */
    public class CloudStorageProcessMock implements ICloudStorageProcess {
        public void run(List<String> payload) {}
    }

    /*
     * @description         Custom Exception
     */
    public class CloudStorageOrchestrationServiceMockException extends Exception {}
}