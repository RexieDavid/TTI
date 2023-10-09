@IsTest
public class SpCreateOrderReqDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"order_reference\": \"TTI-404230-201906301642\",'+
        '    \"payment_method\": \"CHARGE_TO_ACCOUNT\",'+
        '    \"shipments\": ['+
        '        {'+
        '            \"shipment_id\": \"2XoK0EyudTwAAAFrV0MgN5KK\"'+
        '        }'+
        '    ]'+
        '}';
        SpCreateOrderReqDtoAup r = SpCreateOrderReqDtoAup.parse(json);
        System.assert(r != null);
        
        r = new SpCreateOrderReqDtoAup();
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderReqDtoAup objSpCreateOrderReqDtoAup = new SpCreateOrderReqDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateOrderReqDtoAup != null);
        System.assert(objSpCreateOrderReqDtoAup.order_reference == null);
        System.assert(objSpCreateOrderReqDtoAup.payment_method == null);
        System.assert(objSpCreateOrderReqDtoAup.shipments == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderReqDtoAup.Shipments objShipments = new SpCreateOrderReqDtoAup.Shipments(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_id == null);

        objShipments = new SpCreateOrderReqDtoAup.Shipments();
        System.assert(objShipments != null);
    }
}