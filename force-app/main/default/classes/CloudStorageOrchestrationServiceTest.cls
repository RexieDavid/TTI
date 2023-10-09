/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
@isTest
private class CloudStorageOrchestrationServiceTest {
    private static final CloudStorageOrchestrationService SERVICE = new CloudStorageOrchestrationService();
    private static final String ERR_CLOUD_PROVIDERS_REQUIRED = 'External Cloud Providers are required.';
    private static final String ERR_LOG_PAYLOADS_REQUIRED = 'Log payloads are required.';
    private static final Set<String> PROVIDERS = new Set<String>{'AWS'};

    /**
     * @description                 Fetch metadata with required parameters:
     *                                  - External Cloud provider
     *                                  - Process context
     */
    @isTest
    private static void fetchMetadataWithProvider() {
        List<External_Cloud_Provider_Process__mdt> processes;
        Test.startTest();
            processes = SERVICE.fetchProvidersMedata(PROVIDERS);
        Test.stopTest();
        System.assert(processes != null, 'Failed to fetch provider processes');
    }

    /**
     * @description                 Fetch metadata with missing required parameter:
     *                                  - External Cloud provider
     * 
     *                              Will throw an error
     */
    @isTest
    private static void fetchMetadataWithoutProvider() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.fetchProvidersMedata(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ERR_CLOUD_PROVIDERS_REQUIRED, errMessage, 'Successfully fetch provider processes');
    }


    /**
     * @description                 Fetch metadata with required parameters:
     *                                  - External Cloud provider
     *                                  - Process context
     */
    @isTest
    private static void publishLogWithPayload() {
        Test.startTest();
            SERVICE.publishLogs(new List<String>());
        Test.stopTest();
        // returns void - don't need to assert
    }

    /**
     * @description                 Fetch metadata with missing required parameter:
     *                                  - External Cloud provider
     * 
     *                              Will throw an error
     */
    @isTest
    private static void publishLogWithoutPayload() {
        String errMessage;
        Test.startTest();
            try {
                SERVICE.publishLogs(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ERR_LOG_PAYLOADS_REQUIRED, errMessage, 'Successfully publish system log events');
    }
}