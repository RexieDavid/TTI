/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: This class handles all service logic for BlackhawkAPI NZ
*/ 
public class BlackhawkNZAPIService {

    public class BlackhawkNZApiServiceException extends Exception {} 

    public static void test (){
        String clientId = 'OEYH2B4zO0XY0c9/N3Zm';
        String clientSecret = 'FKqdY+MySAH0RgK8mPAx';
        string body = 'grant_type=client_credentials&'+'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8');
        http http = new http();
        httpRequest request = new httpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://deis-oidc.dguat.com/connect/token'); 
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        System.debug(request.getBody());
        System.debug(request.getEndpoint());
        System.debug(request.getHeader('Authorization'));
        httpResponse res = http.send(request);
        System.debug(res.getStatus());
        System.debug(res.getStatusCode());
        System.debug(res.getBody());
    }

    public static void test2(){
        // String clientId = 'OEYH2B4zO0XY0c9/N3Zm';
        // String clientSecret = 'FKqdY+MySAH0RgK8mPAx';
        // string body = 'grant_type=client_credentials&'+'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8');
        http http = new http();
        httpRequest request = new httpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:BlackhawkAPINZPreProd'+'/api/v2/catalogue'); 
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        // request.setBody(body);
        // System.debug(request.getBody());
        System.debug(request.getEndpoint());
        // System.debug(request.getHeader('Authorization'));
        httpResponse res = http.send(request);
        System.debug(res.getStatus());
        System.debug(res.getStatusCode());
        System.debug(res.getBody());
    }
}



	// static testMethod void testParse() {
	// 	String json=		'{'+
	// 	'    "OrderReferenceNumber": "Test0003",'+
	// 	'    "Recipient": {'+
	// 	'        "Email": "test@client.com.au",'+
	// 	'        "FirstName": "",'+
	// 	'        "LastName": "",'+
	// 	'        "MobileNumber": "",'+
	// 	'        "PhoneNumber": ""'+
	// 	'    },'+
	// 	'    "DigitalStoreCardOrder": {'+
	// 	'        "PersonalisationInfo": {'+
	// 	'            "To": "",'+
	// 	'            "Message": "",'+
	// 	'            "From": ""'+
	// 	'        },'+
	// 	'        "OrderItems": ['+
	// 	'            {'+
	// 	'                "Quantity": 1,'+
	// 	'                "Amount": 1,'+
	// 	'                "SKU": "AUJBHJNZC003",'+
	// 	'                "ReferenceNumber": "t0003"'+
	// 	'            }'+
	// 	'        ]'+
	// 	'    }'+
	// 	'}';
	// 	BlackhawkOrderRequestInputWrapper obj = parse(json);
	// 	System.assert(obj != null);
	// }
//}