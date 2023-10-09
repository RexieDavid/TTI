public class Auth0_AccountUpdateCallout {
    
    public static boolean futureExecuted = false;
    public static void executeFutureMethod(Map<Id, Account> newmap, Map<Id, Account> oldMap){
        List<Id> customerIds = new List<Id>();
        futureExecuted = false;
        for(Id custmrId: newmap.keyset()){
            if(newmap.get(custmrId).PersonEmail != oldMap.get(custmrId).PersonEmail){                
                customerIds.add(custmrId);
            }
        }
        if(customerIds.size()>0 && !futureExecuted){
            makeCallout(customerIds);
            futureExecuted = true;
        }
    }
    
    @future(callout=true)
    public static void makeCallout(List<Id> customerIds){
        system.debug('Future Method Execution');
        if(customerIds != null){
            Auth0_Metadata__mdt auth0Credentials = Auth0_Metadata__mdt.getInstance('Auth0_Credentials');
            Account customer = [SELECT Id, Name, Previous_Email__c, PersonEmail FROM Account Where Id =: customerIds[0]];
            String accessToken ='';
            tokenRequestBody trb = new tokenRequestBody();
            trb.grant_type = auth0Credentials.Grant_Type__c;
            trb.client_id = auth0Credentials.Client_ID__c;
            trb.client_secret = auth0Credentials.Client_Secret__c;
            trb.audience = auth0Credentials.Audience__c;
            String tokenReqBody = JSON.serialize(trb);
            
            Http http = new Http();
            //Token Request
            HttpRequest postRequest = new HttpRequest();
            postRequest.setEndpoint('https://idtest.milwaukeetools.com.au/oauth/token');
            postRequest.setMethod('POST');
            postRequest.setHeader('Content-Type', 'application/json');
            postRequest.setHeader('Authorization', 'Bearer Token');
            postRequest.setBody(tokenReqBody);
            system.debug('Token Request Body : '+tokenReqBody);
            HttpResponse response = http.send(postRequest);        
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                accessToken = String.valueof(results.get('access_token'));   
                system.debug(accessToken + ' accessToken');
                //User Details Request
                HttpRequest getRequest = new HttpRequest();
                system.debug(customer.Previous_Email__c);
                getRequest.setEndpoint('https://idtest.milwaukeetools.com.au/api/v2/users?q='+customer.Previous_Email__c+'&search_engine=v3');
                getRequest.setMethod('GET');
                getRequest.setHeader('Content-Type', 'application/json');
                getRequest.setHeader('Authorization', 'Bearer '+accessToken);
                HttpResponse response1 = http.send(getRequest);
                if (response1.getStatusCode() == 200) {
                    List<Auth0_ResponseWrapper> results1 = (List<Auth0_ResponseWrapper>) JSON.deserialize(response1.getBody(), List<Auth0_ResponseWrapper>.Class);
                    System.debug('Get Response User Id: '+results1[0].user_id);
                    String userId = results1[0].user_id;
                    String patchEndpoint = EncodingUtil.urlEncode('https://idtest.milwaukeetools.com.au/api/v2/users/'+userId, 'UTF-8');
                    String finalEndpoint = EncodingUtil.urlDecode(patchEndpoint, 'UTF-8');
                    finalEndpoint = finalEndpoint.replace('|','%7C');
                    system.debug('endpoint url : '+finalEndpoint);
                    updateUserRequestBody patchReq = new updateUserRequestBody();
                    patchReq.email = customer.PersonEmail;
                    patchReq.name = customer.PersonEmail;
                    String patchReqBody = JSON.serialize(patchReq);
                    system.debug('Patch Request JSON : '+patchReqBody);
                    
                    //User Update Request
                    HttpRequest patchRequest = new HttpRequest();
                    patchRequest.setEndpoint(finalEndpoint);
                    patchRequest.setMethod('PATCH');
                    patchRequest.setHeader('Content-Type', 'application/json');
                    patchRequest.setHeader('Authorization', 'Bearer '+accessToken);
                    patchRequest.setBody(patchReqBody);
                    patchRequest.setTimeout(50000);
                    System.debug('Patch Request: ' + patchRequest);
                    HttpResponse response2 = http.send(patchRequest);
                    String result = response2.getBody();
                    system.debug('Result: ' + result);
                }
            }
        }
    }
    @future(callout=true)
    public static void makeCallout2(String email, String num){
        system.debug('Future Method Execution');
        if(email != null){
            Auth0_Metadata__mdt auth0Credentials = Auth0_Metadata__mdt.getInstance('Auth0_Credentials');
            //Account customer = [SELECT Id, Name, Previous_Email__c, PersonEmail FROM Account Where Id =: customerIds[0]];
            String accessToken ='';
            tokenRequestBody trb = new tokenRequestBody();
            trb.grant_type = auth0Credentials.Grant_Type__c;
            trb.client_id = auth0Credentials.Client_ID__c;
            trb.client_secret = auth0Credentials.Client_Secret__c;
            trb.audience = auth0Credentials.Audience__c;
            String tokenReqBody = JSON.serialize(trb);
            
            Http http = new Http();
            //Token Request
            HttpRequest postRequest = new HttpRequest();
            postRequest.setEndpoint('https://idtest.milwaukeetools.com.au/oauth/token');
            postRequest.setMethod('POST');
            postRequest.setHeader('Content-Type', 'application/json');
            postRequest.setHeader('Authorization', 'Bearer Token');
            postRequest.setBody(tokenReqBody);
            system.debug('Token Request Body : '+tokenReqBody);
            HttpResponse response = http.send(postRequest);        
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                accessToken = String.valueof(results.get('access_token'));   
                system.debug(accessToken + ' accessToken');
                //User Details Request
                HttpRequest getRequest = new HttpRequest();
                //system.debug(customer.Previous_Email__c);
                getRequest.setEndpoint('https://idtest.milwaukeetools.com.au/api/v2/users?q='+email+'&search_engine=v3');
                getRequest.setMethod('GET');
                getRequest.setHeader('Content-Type', 'application/json');
                getRequest.setHeader('Authorization', 'Bearer '+accessToken);
                HttpResponse response1 = http.send(getRequest);
                if (response1.getStatusCode() == 200) {
                    List<Auth0_ResponseWrapper> results1 = (List<Auth0_ResponseWrapper>) JSON.deserialize(response1.getBody(), List<Auth0_ResponseWrapper>.Class);
                    System.debug('Get Response User Email: '+results1[0].email);
                    System.debug('Get Response User Id: '+results1[0].user_id);
                    String userId = results1[0].user_id; //'6426384a07788ad10f0b6c5c';//
                    String patchEndpoint = EncodingUtil.urlEncode('https://idtest.milwaukeetools.com.au/api/v2/users/'+userId, 'UTF-8');
                    String finalEndpoint = EncodingUtil.urlDecode(patchEndpoint, 'UTF-8');
                    finalEndpoint = finalEndpoint.replace('|','%7C');
                    system.debug('endpoint url : '+finalEndpoint);
                    updateUserRequestBody patchReq = new updateUserRequestBody();
                    patchReq.email = num;//customer.PersonEmail;
                    patchReq.name = num;//customer.PersonEmail;
                    String patchReqBody = JSON.serialize(patchReq);
                    system.debug('Patch Request JSON : '+patchReqBody);
                    
                    //User Update Request
                    HttpRequest patchRequest = new HttpRequest();
                    patchRequest.setEndpoint(finalEndpoint);
                    patchRequest.setMethod('PATCH');
                    patchRequest.setHeader('Content-Type', 'application/json');
                    patchRequest.setHeader('Authorization', 'Bearer '+accessToken);
                    patchRequest.setBody(patchReqBody);
                    System.debug('Patch Request: ' + patchRequest);
                    HttpResponse response2 = http.send(patchRequest);
                    String result = response2.getBody();
                    system.debug('Result: ' + result);
                 }
            }
        }
    }
    public class tokenRequestBody{
        public string grant_type;
        public string client_id;
        public string client_secret;
        public string audience;        
    }
    public class updateUserRequestBody{
        public string email;
        public string name;
    }
}