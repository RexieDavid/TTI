/**
 * @author                          Kristopher Veraces
 * @date                            2020-05-04
 *
 * @group                           Tooling API
 *
 * @description                     Tooling API Mock Response
*/
global class ToolingAPICalloutMock implements HttpCalloutMock {

    private final String ERROR_RESPONSE =
        '[{' +
            '"errorCode" : "400",' +
            '"message" : "Bad Request"' +
        '}]';
    
    private final String FIELD_RESPONSE =
        '{' +
            '"size" : 1,' +
            '"totalSize" : 1,' +
            '"done" : true,' +
            '"queryLocator" : null,' +
            '"records" : [ {' +
                '"attributes" : {' +
                    '"type" : "CustomField",' +
                    '"url" : "/services/data/v29.0/tooling/sobjects/CustomField/00NXXXXXXXXXXXXXX"' +
                '},' +
                '"DeveloperName" : "A_Lookup",' +
                '"Id" : "00NXXXXXXXXXXXXXX",' +
                '"Metadata" : { ' +
                    '"lookupFilter" : { ' +
                        '"booleanFilter" : "1 OR 2",' +
                        '"filterItems" : [ {' +
                            '"field" : "Contact.Account.Customer_Group_4_Code__c",' +
                            '"operation" : "equals",' +
                            '"value" : "BU",' +
                            '"valueField" : null' +
                            '}, {' +
                            '"field" : "Contact.Account.Name",' +
                            '"operation" : "contains",' +
                            '"value" : "Account Test Name 1",' +
                            '"valueField" : null' +
                            '}, {' +
                            '"field" : "Contact.Account.Name",' +
                            '"operation" : "notContain",' +
                            '"value" : "Dummy",' +
                            '"valueField" : null' +
                        '} ],' +
                        '"active" : true' +
                    '}' +
                '} ' +
            '} ],' +
            '"entityTypeName" : "CustomFieldDefinition"' +
        '}';
    
        
    private Integer statusCode;
    private String method;
    

    /**********************************************************************
     * @description                 Class constructor
     * 
     * @param method                Request method type
     * @param statusCode            Response status code
     * 
     * @example
     * Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
    */
    global ToolingAPICalloutMock(String method, Integer statusCode) {
        this.method = method;
        this.statusCode = statusCode;
    }

    /**********************************************************************
     * @description                 Form the body of the response
     * 
     * @param request               HTTPRequest
    */
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(this.statusCode);

        if (this.method == 'GET') {
            response.setBody(this.getResponseBody());
        }
        
        return response; 
    }

    /**********************************************************************
     * @description                 Set GET response body
     * 
     * @return                      response body in form of string
    */
    private String getResponseBody() {
        String responseBody;
        if (this.statusCode == 200) {
            responseBody = this.FIELD_RESPONSE;
        } else {
            responseBody = this.ERROR_RESPONSE;
        }
        return responseBody;
    }
}