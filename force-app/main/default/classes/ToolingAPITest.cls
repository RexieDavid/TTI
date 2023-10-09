/**
 * @author                          Kristopher Veraces
 * @date                            2020-04-30
 *
 * @group                           Tooling API
*/
@isTest
private class ToolingAPITest {

    private static final String GET_TYPE = 'GET';
    private static final String FIELD_QUERY = 'SELECT Id, Metadata FROM CustomField WHERE DeveloperName = XXXX';
    private static final String METHOD_TYPE_MISSING_ERR = 'Must Provide HTTP Method Type';
    private static final String QUERY_MISSING_ERR = 'Must Provide Tooling API Query';
    private static final String SUCCESS_REST_CALLOUT = 'Succesfully initiated REST callout';
    private static final String FAILED_REST_CALLOUT = 'Failed to initiate REST callout';
    
    /**********************************************************************
     * @description                 Initiate tooling api without query
     * 
     *                              Will throw QUERY_MISSING_ERR exception
     */
    @isTest
    static void toolingAPIMissingQuery() {
        String errMessage;
        ToolingAPI tAPI = new ToolingAPI(false);
        Test.startTest();
            try {
                tAPI.initializeHttpRequest();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(QUERY_MISSING_ERR, errMessage, SUCCESS_REST_CALLOUT);
    }

    /**********************************************************************
     * @description                 Initiate tooling api without method type
     * 
     *                              Will throw METHOD_TYPE_MISSING_ERR exception
     */
    @isTest
    static void toolingAPIMissingMethodType() {
        String errMessage;
        ToolingAPI tAPI = new ToolingAPI(UserInfo.getSessionId());
        tAPI.query = FIELD_QUERY;
        Test.startTest();
            try {
                tAPI.initializeHttpRequest();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(METHOD_TYPE_MISSING_ERR, errMessage, SUCCESS_REST_CALLOUT);
    }
    
    /**********************************************************************
     * @description                 Fetch custom field metadata using 
     *                              tooling api
     */
    @isTest
    static void fetchCustomField() {
        List<ToolingAPI.Records> results = new List<ToolingAPI.Records>();
        ToolingAPI tAPI = new ToolingAPI();
        tAPI.objectAPIName = 'XXXX__c';
        tAPI.query = FIELD_QUERY;
        tAPI.methodType = GET_TYPE;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
            results = tAPI.initializeHttpRequest();
        Test.stopTest();
        System.assert(!results.isEmpty(), FAILED_REST_CALLOUT);
    }

    /**********************************************************************
     * @description                 Fetch custom field metadata using 
     *                              tooling api 
     * 
     *                              Will result to bad request error
     */
    @isTest
    static void fetchCustomFieldNegativeTest() {
        String errMessage;
        ToolingAPI tAPI = new ToolingAPI();
        tAPI.objectAPIName = 'XXXX__c';
        tAPI.query = FIELD_QUERY;
        tAPI.methodType = GET_TYPE;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 400));
            try {
                tAPI.initializeHttpRequest();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('400 : Bad Request', errMessage, SUCCESS_REST_CALLOUT);
    }
}