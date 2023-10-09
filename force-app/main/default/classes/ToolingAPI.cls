/**
 * @author                          Kristopher Veraces
 * @date                            2020-04-30
 *
 * @group                           Tooling API
 *
 * @description                     Tooling API Request Backbone using REST callout
 * 
 * @Note                            This is only a part of whole tooling api,
 *                                  if there are confusions, kindly visit this
 *                                  github: 
 *                                  https://github.com/afawcett/apex-toolingapi/blob/apex-toolingapi-rest/src/classes/ToolingAPI.cls
*/
public class ToolingAPI {
    /**
     * Private variables
     */
    private final String INVALID_SESSION_ID_ERR = 'Invalid Session Id';
    private final String METHOD_TYPE_MISSING_ERR = 'Must Provide HTTP Method Type';
    private final String QUERY_MISSING_ERR = 'Must Provide Tooling API Query';
    private final String TOOLING_API_URI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v47.0/tooling/query/?q=';
    
    private Boolean isLightning = false;
    private String sessionId;
    private Integer successCode;

    /**
     * Class dependencies
     */
    public String query { get; set; }
    public String methodType { get; set; }
    public String objectAPIName { get; set; } // For heirarchial lookups

    /**********************************************************************
     * @description                 Default constructor
     */
    public ToolingAPI() {
        this.sessionId = UserInfo.getSessionId();
        if (String.isBlank(sessionId)) {
            throw new ToolingAPIException(this.INVALID_SESSION_ID_ERR);
        }
    }

    /**********************************************************************
     * @description                 Constructor for lightning components
     */
    public ToolingAPI(Boolean isLightning) {
        this.isLightning = isLightning;
        if (!this.isLightning) {
            this();
        }
    }

    /**********************************************************************
     * @description                 Constructor that uses the given Session Id, 
     *                              useful when using the API in a batch context 
     */
    public ToolingAPI(String sessionId) {
        if (String.isBlank(sessionId)) {
            throw new ToolingAPIException(this.INVALID_SESSION_ID_ERR);
        }
        this.sessionId = sessionId;
    }



    /**********************************************************************
     * @description                 Validate class dependencies have value
     *                              and start HTTP request
     * 
     *                              For more information on status code, 
     *                              refer to this link:
     *                              https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
     * 
     * @return                      List of records return by HTTP request
     * 
     * @example
     * ToolingAPIClass toolingAPI = new ToolingAPIClass();
     * toolingAPI.initializeHttpRequest();
    */
    public List<Records> initializeHttpRequest() {
        if (String.isBlank(this.query)) {
            throw new ToolingAPIException(this.QUERY_MISSING_ERR);
        } else {
            this.query = EncodingUtil.urlEncode(this.query, 'UTF-8');
        }

        if (String.isBlank(this.methodType)) {
            throw new ToolingAPIException(this.METHOD_TYPE_MISSING_ERR);
        } else {
            if (this.methodType.equals('POST')) {
                this.successCode = 201;
            } else if (this.methodType.equals('DELETE')) {
                this.successCode = 204;
            } else {
                this.successCode = 200;
            }
        }

        return this.startHTTPRequest();
    }

    /**********************************************************************
     * @description                 Start ToolingAPI HTTP Request and 
     *                              parse the http response
     * 
     * @return                      List of records return by HTTP request
     * 
     * @example
     * this.startHTTPRequest();
    */
    private List<Records> startHTTPRequest() {
        String response = this.submitHttpRequest();
        ToolingAPIResult payload = (ToolingAPIResult) JSON.deserialize(response, ToolingAPIResult.class);
        if (payload.size != 0 
                && payload.records[0].metadata != null 
                && payload.records[0].metadata.lookupFilter != null
                && payload.records[0].metadata.lookupFilter.filterItems != null) {
            for (FilterItems fItem : payload.records[0].metadata.lookupFilter.filterItems) {
                fItem.soqlFilter = this.filterToSOQLParser(fItem);
            }
        } 
        
        return payload.records;
    }
    /**********************************************************************
     * @description                 Will create a new http request to 
     *                              current salesforce environment
     * 
     * @param endpoint              HTTP Request endpoint
     * @param httpHeadersMap        HTTP Request header values
     * @param methodType            HTTP Request method type ('GET', 'POST', etc.)
     * 
     * @return                      HTTP response body in form of string
     * 
     * @example
     * this.submitHttpRequest();
    */
    private String submitHttpRequest() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setHeader('Content-Type', 'application/json');
        if (!this.isLightning) {
            request.setHeader('Authorization', 'Bearer ' + this.sessionId);
            request.setEndpoint(this.TOOLING_API_URI + this.query);
        } else {
            request.setEndpoint('callout:ToolingAPI?q=' + this.query);
        }
        request.setMethod(this.methodType);
        
        try {
            response = http.send(request);
        } catch (CalloutException ce) {
            throw ce;
        }

        if (response.getStatusCode() != this.successCode) {
            if( response.getBody().length() > 0 ) {
                throw new ToolingAPIException((List<ErrorResponse>) JSON.deserialize(response.getBody(), List<ErrorResponse>.class));
            } else {
                throw new ToolingAPIException('Unexpected HTTP Status ' + response.getStatusCode());
            }
        }

        return response.getBody();
    }

    /**********************************************************************
     * @description                 Parse the filter records and convert it to
     *                              SOQL filter
     * 
     * @param filter                Filter object that contains the field, 
     *                              operation and value
     * 
     * @return                      SOQL filter
     * 
     * @example
     * this.filterToSOQLParser();
    */
    private String filterToSOQLParser(FilterItems filter) {
        String criteria;
        Boolean isWildCardSearch = filter.operation.equals('notContain') || filter.operation.equals('contain');
        Schema.DisplayType fieldType = this.fieldType(filter.field.replace('$Source', this.objectAPIName));
        filter.field = filter.field.replace('$Source.', '');
        if (filter.operation.equals('notContain')) {
            criteria = 'NOT (' + filter.field;
        } else {
            criteria = filter.field;
        }

        criteria += this.operatorParser(filter.operation);
        if (fieldType == Schema.DisplayType.BOOLEAN 
                || fieldType == Schema.DisplayType.CURRENCY 
                || fieldType == Schema.DisplayType.DOUBLE
                || fieldType == Schema.DisplayType.INTEGER
                || fieldType == Schema.DisplayType.LONG
                || fieldType == Schema.DisplayType.PERCENT)
            criteria += filter.value;
        else if (fieldType == Schema.DisplayType.DATE) {
            criteria += Date.parse(filter.value);
        } else if (fieldType == Schema.DisplayType.DATETIME) { 
            criteria += Datetime.parse(filter.value);
        } else {
            if (isWildCardSearch) {
                criteria += (' \'%' + filter.value + '\'%');
            } else {
                criteria += (' \'' + filter.value + '\'');
            }
        }

        if (filter.operation.equals('notContain')) {
            criteria += ' )';
        }

        return criteria;
    }

    /**********************************************************************
     * @description                 Convert filter operation to SOQL logic operator
     *                              (e.g. 'equals' => ' = ', 'lessThan' => ' < ')
     * 
     * @param operatorValue         Filter operation
     * 
     * @return                      SOQL logical operator
     * 
     * @example
     * this.operatorParser();
    */
    private String operatorParser(String operatorValue) {
        String soqlOperator;
        switch on operatorValue {
            when 'equals', 'within' {
                soqlOperator = ' = ';
            }
            when 'notEqual' {
                soqlOperator = '!= ';
            }
            when 'lessThan' {
                soqlOperator = ' < ';
            }
            when 'greaterThan' {
                soqlOperator = ' > ';
            }
            when 'lessOrEqual' {
                soqlOperator = ' <= ';
            }
            when 'greaterOrEqual' {
                soqlOperator = ' >= ';
            }
            when 'includes' {
                soqlOperator = ' INCLUDES ';
            }
            when 'excludes' {
                soqlOperator = ' EXCLUDES ';
            }
            when else {
                soqlOperator = ' LIKE ';
            }
        }
        return soqlOperator;
    }

    /**********************************************************************
     * @description                 Fetch the field type of filter field
     * 
     *                              Field type will be use to determine if 
     *                              it's a String, Integer, Date, etc.
     * 
     * @param field                 Filter field
     * 
     * @return                      Enum Schema.DisplayType
     * 
     * @example
     * this.fieldType();
    */
    private Schema.DisplayType fieldType(String field) {
        List<String> objectField = field.split('\\.');
        Integer lastIndex = objectField.size() - 1;
        Schema.DescribeSObjectResult sObjectTypeDes = Schema.getGlobalDescribe().get(objectField[lastIndex - 1]).getDescribe();
        Schema.DisplayType fieldType = sObjectTypeDes.fields.getMap().get(objectField[lastIndex]).getDescribe().getType();
        return fieldType;
    }


    /**********************************************************************
     * @description                     Main Wrapper for Tooling API JSON 
     *                                  response
     */
    public class ToolingAPIResult {
        public Integer size { get; set; }
        public Integer totalSize { get; set; }
        public Boolean done { get; set; }
        public Object queryLocator { get; set; }
        public String entityTypeName { get; set; }
        public List<Records> records { get; set; }
    }

    /**********************************************************************
     * @description                     Records attribute for Tooling API JSON 
     *                                  response
     */
    public class Records {
        public Metadata metadata { get; set; }
        public String Id { get; set; }
    }

    /**********************************************************************
     * @description                     Metadata attribute for Tooling API JSON 
     *                                  response
     * 
     * @note                            For now it's only expecting lookupFilter
     *                                  but feel free to add other attributes 
     *                                  depending on your use case
     */
    public class Metadata {
        public LookupFilter lookupFilter { get; set; }
    }

    /**********************************************************************
     * @description                     LookupFilter attribute for Tooling API JSON 
     *                                  response
     */
    public class LookupFilter {
        public String booleanFilter { get; set; }
        public Boolean active { get; set; }
        public List<FilterItems> filterItems { get; set; } 
    }

    /**********************************************************************
     * @description                     FilterItems attribute for Tooling API JSON 
     *                                  response
     * 
     *                                  Added additional attribute soqlFilter
     */
    public class FilterItems {
        public String field { get; set; } 
        public String operation { get; set; } 
        public String value { get; set; } 
        public String valueField { get; set; }
        public String soqlFilter { get; set; }
    }

    /**********************************************************************
     * @description                     Error response wrapper
     */
    public class ErrorResponse {
        public List<String> fields { get; set; }
        public String errorCode { get; set; }
        public String message { get; set; }
    }

    /**********************************************************************
     * @description                     Custom Exception of ToolingAPIClass
     */
    public class ToolingAPIException extends Exception {
        public ToolingAPIException(List<ErrorResponse> errorResponses){
            this(errorResponses[0].errorCode + ' : ' + errorResponses[0].message);
        }
    }
}