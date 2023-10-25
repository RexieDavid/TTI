/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: Mock for Integration BlackhawkAPIServiceMock
* @reference: BlackhawkAPIServiceMock
*/ 
@isTest
global class BlackhawkAPIServiceMock implements HttpCalloutMock {

    public static final String RESPONSE_HEADER_PARAM_NAME = 'Content-Type';
    public static final String RESPONSE_HEADER_CONTENT_TYPE = 'application/json';
    // private static final String EGIFT_RESPONSE_BODY ='{"transactionId" : "G8BD11WHSNC5MZPSZRQ8X023AW","isCompleted" : true,"percentComplete" : 100,"success" : true,"orderNumber" : "403062844","contentProviderCode" : "ASOS_AUD_en_eGift","transactionAmount" : 30.00,"url" : "https://egift.certification.blackhawknetwork.com/egift?tid=657Q0RGVTJTZKC50AW2P8STYQC&gcm=n&gs=n&gw=n&eid=YK15H5RBKC4NG97K48G3P98GW8"}';
    
    public Integer STATUSCODE = 201;
    public String RESPONSE_BODY = '';

    global BlackhawkAPIServiceMock(Integer statusCode, String responseBody){
        this.STATUSCODE = statusCode;
        this.RESPONSE_BODY = responseBody;
    }

    global HTTPResponse respond(HttpRequest req){

        HttpResponse resp=new HttpResponse();
        resp.setHeader(RESPONSE_HEADER_PARAM_NAME, RESPONSE_HEADER_CONTENT_TYPE);
        resp.setHeader('Merchantid', '60300009755');
        resp.setHeader('Requestid', '60300009755');
        resp.setHeader('millisecondsToWait', '30000');
        resp.setHeader('SYNCHRONOUS_ONLY', 'true');
        resp.setBody(RESPONSE_BODY);
        resp.setStatusCode(STATUSCODE);
        return resp;    
    
    }

}