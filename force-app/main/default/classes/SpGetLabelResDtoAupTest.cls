@IsTest
public class SpGetLabelResDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"labels\": ['+
        '        {'+
        '            \"request_id\": \"b3ed5e7a-e5fa-45cb-b482-dca37a5d5716\",'+
        '            \"url\": \"https://ap-prod-ddc-stack-content.s3-ap-southeast-2.amazonaws.com/pccbatch-prod3/b3ed5e7a-e5fa-45cb-b482-dca37a5d5716.pdf?AWSAccessKeyId=AKIAJZ2VLLVH5FAWOGYA&Expires=1552012161&Signature=bOFq6iqHqhdgUG7%2FiJ0HptRz%2BT8%3D\",'+
        '            \"status\": \"AVAILABLE\",'+
        '            \"request_date\": \"07-03-2019 13:29:17\",'+
        '            \"url_creation_date\": \"07-03-2019 13:29:21\",'+
        '            \"shipments\": ['+
        '                {'+
        '                    \"shipment_id\": \"1g8K0E6mBEsAAAFpAGUg7EZn\",'+
        '                    \"options\": {}'+
        '                }'+
        '            ],'+
        '            \"shipment_ids\": ['+
        '                \"1g8K0E6mBEsAAAFpAGUg7EZn\"'+
        '            ]'+
        '        }'+
        '    ]'+
        '}';
        SpGetLabelResDtoAup r = SpGetLabelResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpGetLabelResDtoAup.Option objOptions = new SpGetLabelResDtoAup.Option(System.JSON.createParser(json));
        System.assert(objOptions != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpGetLabelResDtoAup.Label objLabels = new SpGetLabelResDtoAup.Label(System.JSON.createParser(json));
        System.assert(objLabels != null);
        System.assert(objLabels.request_id == null);
        System.assert(objLabels.url == null);
        System.assert(objLabels.status == null);
        System.assert(objLabels.request_date == null);
        System.assert(objLabels.url_creation_date == null);
        System.assert(objLabels.shipments == null);
        System.assert(objLabels.shipment_ids == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpGetLabelResDtoAup objSpGetLabelResDtoAup = new SpGetLabelResDtoAup(System.JSON.createParser(json));
        System.assert(objSpGetLabelResDtoAup != null);
        System.assert(objSpGetLabelResDtoAup.labels == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpGetLabelResDtoAup.Shipment objShipments = new SpGetLabelResDtoAup.Shipment(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_id == null);
        System.assert(objShipments.option == null);
    }
}