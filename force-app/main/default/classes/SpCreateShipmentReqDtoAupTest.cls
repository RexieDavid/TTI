@IsTest
public class SpCreateShipmentReqDtoAupTest {
        
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"shipments\": ['+
        '        {'+
        '            \"shipment_reference\": \"TTI_CASE_00196151\",'+
        '            \"customer_reference_1\": \"00196151\",'+
        '            \"customer_reference_2\": \"\",'+
        '            \"email_tracking_enabled\": true,'+
        '            \"consolidate\": false,'+
        '            \"from\": {'+
        '                \"name\": \"External Agent\",'+
        '                \"lines\": ['+
        '                    \"21 Kelletts Road\"'+
        '                ],'+
        '                \"suburb\": \"Rowville\",'+
        '                \"state\": \"VIC\",'+
        '                \"postcode\": \"3178\",'+
        '                \"phone\": \"\",'+
        '                \"email\": \"fnasalita@ttibrands.com.au\"'+
        '            },'+
        '            \"to\": {'+
        '                \"name\": \"Jack Codling\",'+
        '                \"lines\": ['+
        '                    \"67 Bayfield Street\"'+
        '                ],'+
        '                \"suburb\": \"CRANBROOK\",'+
        '                \"state\": \"TAS\",'+
        '                \"postcode\": \"7190\",'+
        '                \"phone\": \"\",'+
        '                \"email\": \"jack.codling@yopmail.com\"'+
        '            },'+
        ''+
        '            \"dangerous_goods\":{'+
        '               \"un_number\":\"3090\", '+
        '               \"technical_name\":\"Lithium Metal Batteries\",'+
        '               \"net_weight\":\"5\", '+
        '               \"class_division\":\"9\",'+
        '               \"outer_packaging_type\":\"BOX\",'+
        '               \"outer_packaging_quantity\":\"1\"'+
        '            },'+
        '            \"items\": ['+
        '                {'+
        '                    \"item_reference\": \"M18FDD-0\",'+
        '                    \"product_id\": \"PRM\",'+
        '                    \"length\": \"40\",'+
        '                    \"height\": \"35\",'+
        '                    \"width\": \"14\",'+
        '                    \"weight\": \"5\",'+
        '                    \"allow_partial_delivery\": false,'+
        '                    \"packaging_type\": \"ITM\",'+
        '                    \"authority_to_leave\": false,'+
        '                    \"contains_dangerous_goods\":true'+
        '                }'+
        '            ]'+
        '        }'+
        '    ]'+
        '}';
        SpCreateShipmentReqDtoAup r = SpCreateShipmentReqDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup.Dangerous_goods objDangerous_goods = new SpCreateShipmentReqDtoAup.Dangerous_goods(System.JSON.createParser(json));
        System.assert(objDangerous_goods != null);
        System.assert(objDangerous_goods.un_number == null);
        System.assert(objDangerous_goods.technical_name == null);
        System.assert(objDangerous_goods.net_weight == null);
        System.assert(objDangerous_goods.class_division == null);
        System.assert(objDangerous_goods.outer_packaging_type == null);
        System.assert(objDangerous_goods.outer_packaging_quantity == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup.Source source = new SpCreateShipmentReqDtoAup.Source(System.JSON.createParser(json));
        System.assert(source != null);
        System.assert(source.name == null);
        System.assert(source.lines == null);
        System.assert(source.suburb == null);
        System.assert(source.state == null);
        System.assert(source.postcode == null);
        System.assert(source.phone == null);
        System.assert(source.email == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup.Destination destination = new SpCreateShipmentReqDtoAup.Destination(System.JSON.createParser(json));
        System.assert(destination != null);
        System.assert(destination.name == null);
        System.assert(destination.lines == null);
        System.assert(destination.suburb == null);
        System.assert(destination.state == null);
        System.assert(destination.postcode == null);
        System.assert(destination.phone == null);
        System.assert(destination.email == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup.Items objItems = new SpCreateShipmentReqDtoAup.Items(System.JSON.createParser(json));
        System.assert(objItems != null);
        System.assert(objItems.item_reference == null);
        System.assert(objItems.product_id == null);
        System.assert(objItems.length == null);
        System.assert(objItems.height == null);
        System.assert(objItems.width == null);
        System.assert(objItems.weight == null);
        System.assert(objItems.allow_partial_delivery == null);
        System.assert(objItems.packaging_type == null);
        System.assert(objItems.authority_to_leave == null);
        System.assert(objItems.contains_dangerous_goods == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup.Shipments objShipments = new SpCreateShipmentReqDtoAup.Shipments(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_reference == null);
        System.assert(objShipments.customer_reference_1 == null);
        System.assert(objShipments.customer_reference_2 == null);
        System.assert(objShipments.email_tracking_enabled == null);
        System.assert(objShipments.consolidate == null);
        System.assert(objShipments.source == null);
        System.assert(objShipments.destination == null);
        System.assert(objShipments.dangerous_goods == null);
        System.assert(objShipments.items == null);
        System.assert(objShipments.movement_type == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentReqDtoAup objSpCreateShipmentReqDtoAup = new SpCreateShipmentReqDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateShipmentReqDtoAup != null);
        System.assert(objSpCreateShipmentReqDtoAup.shipments == null);
    }
}