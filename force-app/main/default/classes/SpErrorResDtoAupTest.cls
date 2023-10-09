@IsTest
public class SpErrorResDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"errors\": ['+
        '        {'+
        '            \"code\": \"44003\",'+
        '            \"name\": \"DANGEROUS_GOODS_NOT_SUPPORTED_BY_PRODUCT_ERROR\",'+
        '            \"field\": \"shipments[0].items[0]\",'+
        '            \"message\": \"The product T28S specified in an item has indicated that dangerous goods will be included in the parcel, however, the product does not allow dangerous goods to be sent using the service.  Please choose a product that allows dangerous goods to be included within the parcel to be sent.\",'+
        '            \"context\": {'+
        '                \"request_id\": \"d9d1445d-cd1b-452d-9d68-29dbb3967acf\",'+
        '                \"shipment_id\": \"mrKsEAOvKWEAAAFH_s82k9cR\",'+
        '               \"contract_id\": \"0123456789\"'+
        '            }'+
        '        }'+
        '    ]'+
        '}';
        SpErrorResDtoAup r = SpErrorResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpErrorResDtoAup.Context objContext = new SpErrorResDtoAup.Context(System.JSON.createParser(json));
        System.assert(objContext != null);
        System.assert(objContext.request_id == null);
        System.assert(objContext.shipment_id == null);
        System.assert(objContext.contract_id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpErrorResDtoAup.Errors objErrors = new SpErrorResDtoAup.Errors(System.JSON.createParser(json));
        System.assert(objErrors != null);
        System.assert(objErrors.code == null);
        System.assert(objErrors.name == null);
        System.assert(objErrors.field == null);
        System.assert(objErrors.message == null);
        System.assert(objErrors.context == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpErrorResDtoAup objSpErrorResDtoAup = new SpErrorResDtoAup(System.JSON.createParser(json));
        System.assert(objSpErrorResDtoAup != null);
        System.assert(objSpErrorResDtoAup.errors == null);
    }
}