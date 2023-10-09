/**
 * @author                              Francis Nasalita
 * @date                                2020-10-14
 * @group                               AWS
 */
@isTest
global class AwsServiceHttpCalloutMockImpl implements HttpCalloutMock {
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/pdf');
        

        if (req.getEndpoint().endsWith('fail')) {
            res.setStatusCode(404);
            res.setBody('Not Found');
        } else {
            res.setStatusCode(200);
            res.setBody('Test File');
        }

        return res;
    }

}