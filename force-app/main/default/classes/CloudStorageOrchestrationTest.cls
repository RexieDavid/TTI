/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
@isTest
private class CloudStorageOrchestrationTest {
    private static final CloudStorageOrchestrationService MOCK_SERVICE = 
        (CloudStorageOrchestrationService) Test.createStub(CloudStorageOrchestrationService.class, 
        new CloudStorageOrchestrationServiceMock());
    private static final String ERR_APEX_CLASS_NOT_FOUND = 'Apex class not found';
    private static final String ERR_CLOUD_PROVIDERS_REQUIRED = 'External Cloud Providers are required.';


    /**
     * @description                 Run all active registered apex class/process
     *                              for specific provider and context
     */
    @isTest
    private static void runProcessesWithSucessPayload() {
        CloudStorageOrchestration cso = new CloudStorageOrchestration(fetchData(true));
        Test.startTest();
            cso.service = MOCK_SERVICE;
            cso.run();
        Test.stopTest();
        // Don't need to assert
    }

    /**
     * @description                 Run all active registered apex class/process
     *                              for specific provider and context
     */
    @isTest
    private static void runProcessesWithFailPayload() {
        CloudStorageOrchestration cso = new CloudStorageOrchestration(fetchData(false));
        Test.startTest();
            cso.service = MOCK_SERVICE;
            cso.run();
        Test.stopTest();
        // Don't need to assert
    }

    /**
     * @description                 Run all active registered apex class/process
     *                              for specific provider and context
     * 
     *                              Will fail due to non-existent apex class
     */
    @isTest
    private static void runProcessesWithNonExistentClass() {
        CloudStorageOrchestration cso = new CloudStorageOrchestration(fetchData(true));
        String errMessage;
        CloudStorageOrchestrationServiceMock.errorMessage = ERR_CLOUD_PROVIDERS_REQUIRED;
        Test.startTest();
            try {
                cso.service = MOCK_SERVICE;
                cso.run();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(Label.Generic_Error_Message, errMessage, 'Succesfully executed processes without providers.');
    }

    /**
     * @description                 Run all active registered apex class/process
     *                              for specific provider and context
     * 
     *                              Will fail due to empty providers
     */
    @isTest
    private static void runProcessesWithoutProviders() {
        CloudStorageOrchestration cso = new CloudStorageOrchestration(fetchData(true));
        String errMessage;
        CloudStorageOrchestrationServiceMock.errorMessage = ERR_APEX_CLASS_NOT_FOUND;
        Test.startTest();
            try {
                cso.service = MOCK_SERVICE;
                cso.run();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(Label.Generic_Error_Message, errMessage, 'Found apex class');
    }

    /**
     * @description                 Fetch dummy CloudStorageOrchestrationData
     */
    private static List<CloudStorageOrchestration.CloudStorageOrchestrationData> fetchData(Boolean isSuccess) {
        List<CloudStorageOrchestration.CloudStorageOrchestrationData> payload = 
            new List<CloudStorageOrchestration.CloudStorageOrchestrationData>();
        for (Integer i = 0; i < 5; i++) {
            payload.add(createData(i, isSuccess));
        }
        return payload;
    }

    /**
     * @description                 Create dummy CloudStorageOrchestrationData
     */
    private static CloudStorageOrchestration.CloudStorageOrchestrationData createData(Integer uniqueIdentifer, Boolean isSuccess) {
        CloudStorageOrchestration.CloudStorageOrchestrationData data = 
            new CloudStorageOrchestration.CloudStorageOrchestrationData();
        data.provider = 'Provider-' + uniqueIdentifer;
        data.context = 'Process-' + uniqueIdentifer;
        data.payload = 'Payload-' + uniqueIdentifer;
        data.level = 'info';
        data.status = isSuccess ? CloudStorageOrchestration.Status.SUCCESS : CloudStorageOrchestration.Status.FAILURE;
        return data;
    }
}