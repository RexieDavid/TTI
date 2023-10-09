public class Auth0_ResetPasswordController {
	public static void makeCallout(String recordId){
        Auth0_Metadata__mdt auth0Credentials = Auth0_Metadata__mdt.getInstance('Auth0_Credentials');
        Account customer = [SELECT Id, Name, Previous_Email__c, PersonEmail FROM Account Where Id =: recordId];
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
            //User Details Request
            HttpRequest getRequest = new HttpRequest();
            getRequest.setEndpoint('https://idtest.milwaukeetools.com.au/api/v2/users?q='+customer.PersonEmail+'&search_engine=v3');
            getRequest.setMethod('GET');
            getRequest.setHeader('Content-Type', 'application/json');
            getRequest.setHeader('Authorization', 'Bearer '+accessToken);
            HttpResponse response1 = http.send(getRequest);
            if (response1.getStatusCode() == 200) {
                List<Auth0_ResponseWrapper> results1 = (List<Auth0_ResponseWrapper>) JSON.deserialize(response1.getBody(), List<Auth0_ResponseWrapper>.Class);
                System.debug('Get Response User Id: '+results1[0].user_id);
                String userId = results1[0].user_id;
                String resetPwdEndpoint = 'https://idtest.milwaukeetools.com.au/api/v2/tickets/password-change';
                resetPasswordRequestBody resetPwdBody = new resetPasswordRequestBody();
                resetPwdBody.result_url = 'http://unauth/landing';
                resetPwdBody.user_id = userId;
                String resetPwdReqBody = JSON.serialize(resetPwdBody);
                system.debug('reset pwd req body : '+resetPwdReqBody);
                //User Update Request
                HttpRequest resetPwdRequest = new HttpRequest();
                resetPwdRequest.setEndpoint(resetPwdEndpoint);
                resetPwdRequest.setMethod('POST');
                resetPwdRequest.setHeader('Content-Type', 'application/json');
                resetPwdRequest.setHeader('Authorization', 'Bearer '+accessToken);
                resetPwdRequest.setBody(resetPwdReqBody);
                
                HttpResponse response2 = http.send(resetPwdRequest);
                if (response2.getStatusCode() == 201) {
                    Map<String, Object> resetPwdLink = (Map<String, Object>) JSON.deserializeUntyped(response2.getBody());
                    system.debug('reset pwd link : '+resetPwdLink);
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
    public class resetPasswordRequestBody{
        public string result_url;
        public string user_id;
    }
}