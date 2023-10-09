@IsTest
public class SpCreateLabelResDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"message\": \"Your label printing is now in progress. Please wait...;\",'+
        '    \"code\": \"Request actioned\",'+
        '    \"labels\": ['+
        '        {'+
        '            \"request_id\": \"d88406b0-f110-4279-b08f-2c341bb0cb2b\",'+
        '            \"status\": \"PENDING\",'+
        '            \"request_date\": \"06-03-2019 18:36:49\",'+
        '            \"shipments\": ['+
        '                {'+
        '                    \"shipment_id\": \"DY0K0E6mBdYAAAFojWwg7Ma3\",'+
        '                    \"options\": {}'+
        '                }'+
        '            ],'+
        '            \"shipment_ids\": ['+
        '                \"DY0K0E6mBdYAAAFojWwg7Ma3\"'+
        '            ]'+
        '        }'+
        '    ]'+
        '}';
        SpCreateLabelResDtoAup r = SpCreateLabelResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelResDtoAup.Option objOptions = new SpCreateLabelResDtoAup.Option(System.JSON.createParser(json));
        System.assert(objOptions != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelResDtoAup.Label objLabels = new SpCreateLabelResDtoAup.Label(System.JSON.createParser(json));
        System.assert(objLabels != null);
        System.assert(objLabels.request_id == null);
        System.assert(objLabels.status == null);
        System.assert(objLabels.request_date == null);
        System.assert(objLabels.shipments == null);
        System.assert(objLabels.shipment_ids == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelResDtoAup objSpCreateLabelResDtoAup = new SpCreateLabelResDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateLabelResDtoAup != null);
        System.assert(objSpCreateLabelResDtoAup.message == null);
        System.assert(objSpCreateLabelResDtoAup.code == null);
        System.assert(objSpCreateLabelResDtoAup.labels == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelResDtoAup.Shipment objShipments = new SpCreateLabelResDtoAup.Shipment(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_id == null);
        System.assert(objShipments.option == null);
    }
}