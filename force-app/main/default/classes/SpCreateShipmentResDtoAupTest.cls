@IsTest
public class SpCreateShipmentResDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"warnings\": ['+
        '        {'+
        '            \"message\": \"Safe Drop is not available for use with this product.\",'+
        '            \"field\": \"shipments[0].items[0].safe_drop_enabled\"'+
        '        }'+
        '    ],'+
        '    \"shipments\": ['+
        '        {'+
        '            \"shipment_id\": \"DY0K0E6mBdYAAAFojWwg7Ma3\",'+
        '            \"shipment_reference\": \"TTI_CASE_2020203\",'+
        '            \"shipment_creation_date\": \"2019-02-07T17:48:56+11:00\",'+
        '            \"email_tracking_enabled\": true,'+
        '            \"items\": ['+
        '                {'+
        '                    \"weight\": 1,'+
        '                    \"authority_to_leave\": false,'+
        '                    \"allow_partial_delivery\": false,'+
        '                    \"item_id\": \"fToK0E6mInUAAAFoj2wg7Ma3\",'+
        '                    \"item_reference\": \"M18FID-0\",'+
        '                    \"tracking_details\": {'+
        '                        \"article_id\": \"111Z50020694PRM00001\",'+
        '                        \"consignment_id\": \"111Z50020694\"'+
        '                    },'+
        '                    \"product_id\": \"PRM\",'+
        '                    \"item_summary\": {'+
        '                        \"status\": \"Created\"'+
        '                    },'+
        '                    \"item_contents\": [],'+
        '                    \"packaging_type\": \"ITM\"'+
        '                }'+
        '            ],'+
        '            \"options\": {},'+
        '            \"shipment_summary\": {'+
        '                \"total_cost\": 49.37,'+
        '                \"total_cost_ex_gst\": 44.88,'+
        '                \"total_gst\": 4.49,'+
        '                \"freight_charge\": 44.88,'+
        '                \"status\": \"Created\",'+
        '                \"tracking_summary\": {'+
        '                    \"Created\": 1'+
        '                },'+
        '                \"number_of_items\": 1'+
        '            },'+
        '            \"movement_type\": \"DESPATCH\",'+
        '            \"consolidate\": false,'+
        '            \"charge_to_account\": \"00673416\"'+
        '        }'+
        '    ]'+
        '}';
        SpCreateShipmentResDtoAup r = SpCreateShipmentResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.ItemSummary objItem_summary = new SpCreateShipmentResDtoAup.ItemSummary(System.JSON.createParser(json));
        System.assert(objItem_summary != null);
        System.assert(objItem_summary.status == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.ItemContent objItem_contents = new SpCreateShipmentResDtoAup.ItemContent(System.JSON.createParser(json));
        System.assert(objItem_contents != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup objSpCreateShipmentResDtoAup = new SpCreateShipmentResDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateShipmentResDtoAup != null);
        System.assert(objSpCreateShipmentResDtoAup.warnings == null);
        System.assert(objSpCreateShipmentResDtoAup.shipments == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.Item objItems = new SpCreateShipmentResDtoAup.Item(System.JSON.createParser(json));
        System.assert(objItems != null);
        System.assert(objItems.weight == null);
        System.assert(objItems.authority_to_leave == null);
        System.assert(objItems.allow_partial_delivery == null);
        System.assert(objItems.item_id == null);
        System.assert(objItems.item_reference == null);
        System.assert(objItems.tracking_details == null);
        System.assert(objItems.product_id == null);
        System.assert(objItems.item_summary == null);
        System.assert(objItems.item_contents == null);
        System.assert(objItems.packaging_type == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.TrackingSummary objTracking_summary = new SpCreateShipmentResDtoAup.TrackingSummary(System.JSON.createParser(json));
        System.assert(objTracking_summary != null);
        System.assert(objTracking_summary.Created == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.ShipmentSummary objShipment_summary = new SpCreateShipmentResDtoAup.ShipmentSummary(System.JSON.createParser(json));
        System.assert(objShipment_summary != null);
        System.assert(objShipment_summary.total_cost == null);
        System.assert(objShipment_summary.total_cost_ex_gst == null);
        System.assert(objShipment_summary.total_gst == null);
        System.assert(objShipment_summary.freight_charge == null);
        System.assert(objShipment_summary.status == null);
        System.assert(objShipment_summary.tracking_summary == null);
        System.assert(objShipment_summary.number_of_items == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.Warning objWarnings = new SpCreateShipmentResDtoAup.Warning(System.JSON.createParser(json));
        System.assert(objWarnings != null);
        System.assert(objWarnings.message == null);
        System.assert(objWarnings.field == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.TrackingDetail objTracking_details = new SpCreateShipmentResDtoAup.TrackingDetail(System.JSON.createParser(json));
        System.assert(objTracking_details != null);
        System.assert(objTracking_details.article_id == null);
        System.assert(objTracking_details.consignment_id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateShipmentResDtoAup.Shipment objShipments = new SpCreateShipmentResDtoAup.Shipment(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_id == null);
        System.assert(objShipments.shipment_reference == null);
        System.assert(objShipments.shipment_creation_date == null);
        System.assert(objShipments.email_tracking_enabled == null);
        System.assert(objShipments.items == null);
        System.assert(objShipments.options == null);
        System.assert(objShipments.shipment_summary == null);
        System.assert(objShipments.movement_type == null);
        System.assert(objShipments.consolidate == null);
        System.assert(objShipments.charge_to_account == null);
    }
}