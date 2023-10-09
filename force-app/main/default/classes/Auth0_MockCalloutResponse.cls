@isTest
global class Auth0_MockCalloutResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(req.getMethod() == 'POST'){
            res.setBody('{"access_token":"testToken"}');
        }
        else if(req.getMethod() == 'GET'){
            List<Auth0_ResponseWrapper> resWrpList = new List<Auth0_ResponseWrapper>();
            Auth0_ResponseWrapper resWrp = new Auth0_ResponseWrapper();
            resWrp.user_id = 'auth0|123456790';
            resWrpList.add(resWrp);
            res.setBody(JSON.Serialize(resWrpList));
        }
        else if(req.getMethod() == 'PATCH'){
            Auth0_ResponseWrapper resWrp = new Auth0_ResponseWrapper();
            resWrp.user_id = 'auth0|123456790';
            res.setBody(JSON.Serialize(resWrp));
        }
        res.setStatusCode(200);
        return res;
    }
}