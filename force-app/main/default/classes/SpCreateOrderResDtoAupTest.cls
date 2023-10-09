@IsTest
public class SpCreateOrderResDtoAupTest {          
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"order\": {'+
        '        \"shipments\": ['+
        '            {'+
        '                \"shipment_summary\": {'+
        '                    \"tracking_summary\": {'+
        '                        \"Sealed\": 1'+
        '                    },'+
        '                    \"total_gst\": null,'+
        '                    \"total_cost_ex_gst\": null,'+
        '                    \"total_cost\": null,'+
        '                    \"status\": \"Sealed\",'+
        '                    \"number_of_items\": 1,'+
        '                    \"fuel_surcharge\": null'+
        '                },'+
        '                \"shipment_id\": \"cyMK0E_2qogAAAFsMgIgP7dZ\",'+
        '                \"email_tracking_enabled\": true'+
        '            }'+
        '        ],'+
        '        \"payment_method\": \"CHARGE_TO_ACCOUNT\",'+
        '        \"order_summary\": {'+
        '            \"tracking_summary\": {'+
        '                \"Initiated\": null'+
        '            },'+
        '            \"total_gst\": null,'+
        '            \"total_cost_ex_gst\": null,'+
        '            \"total_cost\": null,'+
        '            \"status\": \"Initiated\",'+
        '            \"number_of_shipments\": 1'+
        '        },'+
        '        \"order_reference\": \"TTI-S1234-20198231251\",'+
        '        \"order_id\": \"TB00106718\",'+
        '        \"order_creation_date\": \"2019-08-23T12:51:17+10:00\"'+
        '    }'+
        '}';
        SpCreateOrderResDtoAup r = SpCreateOrderResDtoAup.parse(json);
        System.assert(r != null);

        r = new SpCreateOrderResDtoAup();
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Order objOrder = new SpCreateOrderResDtoAup.Order(System.JSON.createParser(json));
        System.assert(objOrder != null);
        System.assert(objOrder.shipments == null);
        System.assert(objOrder.payment_method == null);
        System.assert(objOrder.order_summary == null);
        System.assert(objOrder.order_reference == null);
        System.assert(objOrder.order_id == null);
        System.assert(objOrder.order_creation_date == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Tracking_summary_Z objTracking_summary_Z = new SpCreateOrderResDtoAup.Tracking_summary_Z(System.JSON.createParser(json));
        System.assert(objTracking_summary_Z != null);
        System.assert(objTracking_summary_Z.sealed == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup objSpCreateOrderResDtoAup = new SpCreateOrderResDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateOrderResDtoAup != null);
        System.assert(objSpCreateOrderResDtoAup.order == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Tracking_summary objTracking_summary = new SpCreateOrderResDtoAup.Tracking_summary(System.JSON.createParser(json));
        System.assert(objTracking_summary != null);
        System.assert(objTracking_summary.initiated == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Shipment_summary objShipment_summary = new SpCreateOrderResDtoAup.Shipment_summary(System.JSON.createParser(json));
        System.assert(objShipment_summary != null);
        System.assert(objShipment_summary.tracking_summary == null);
        System.assert(objShipment_summary.total_gst == null);
        System.assert(objShipment_summary.total_cost_ex_gst == null);
        System.assert(objShipment_summary.total_cost == null);
        System.assert(objShipment_summary.status == null);
        System.assert(objShipment_summary.number_of_items == null);
        System.assert(objShipment_summary.fuel_surcharge == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Order_summary objOrder_summary = new SpCreateOrderResDtoAup.Order_summary(System.JSON.createParser(json));
        System.assert(objOrder_summary != null);
        System.assert(objOrder_summary.tracking_summary == null);
        System.assert(objOrder_summary.total_gst == null);
        System.assert(objOrder_summary.total_cost_ex_gst == null);
        System.assert(objOrder_summary.total_cost == null);
        System.assert(objOrder_summary.status == null);
        System.assert(objOrder_summary.number_of_shipments == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateOrderResDtoAup.Shipments objShipments = new SpCreateOrderResDtoAup.Shipments(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_summary == null);
        System.assert(objShipments.shipment_id == null);
        System.assert(objShipments.email_tracking_enabled == null);
    }
}