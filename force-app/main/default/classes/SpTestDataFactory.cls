/**
* @author      : Samuel Oberes
* @date        : 2018-01-09
* @description : Service Portal's test data factory
*/
@IsTest
public class SpTestDataFactory {

    public static String generateOrderErrorResponse() {
        return '' +
        '{' +
        '    "errors": [' +
        '        {' +
        '            "code": "44026",' +
        '            "name": " ORDER_NOT_FOUND ",' +
        '            "message": "An order with order id AP0000002422 cannot be found. Please check that the identifier is correct and submit the request again."' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateUpdateShipmentResponse() {
        return '' +
        '{' +
        '    "shipment_id": "t4AK0EhQTu4AAAFeVsxGqhLO",' +
        '    "shipment_reference": "TTI_CASE_000111",' +
        '    "shipment_creation_date": "2020-02-27T10:25:12+11:00",' +
        '    "email_tracking_enabled": true,' +
        '    "items": [' +
        '        {' +
        '            "weight": 1.000,' +
        '            "authority_to_leave": false,' +
        '            "allow_partial_delivery": false,' +
        '            "item_id": "jdkK0E4WGokAAAFwUyksOIj_",' +
        '            "item_reference": "M18B6",' +
        '            "tracking_details": {' +
        '                "article_id": "111Z50169488EXP00001",' +
        '                "consignment_id": "111Z50169488"' +
        '            },' +
        '            "product_id": "EXP",' +
        '            "item_summary": {' +
        '                "status": "Created"' +
        '            },' +
        '            "item_contents": [],' +
        '            "packaging_type": "ITM"' +
        '        }' +
        '    ],' +
        '    "shipment_modified_date": "2020-02-28T10:33:08+11:00",' +
        '    "options": {},' +
        '    "shipment_summary": {' +
        '        "status": "Created",' +
        '        "tracking_summary": {' +
        '            "Created": 1' +
        '        },' +
        '        "number_of_items": 1' +
        '    },' +
        '    "movement_type": "DESPATCH",' +
        '    "consolidate": false,' +
        '    "charge_to_account": "00673416",' +
        '    "warnings": [' +
        '        {' +
        '            "message": "Safe Drop is not available for use with this product.",' +
        '            "field": "items[0].safe_drop_enabled"' +
        '        },' +
        '        {' +
        '            "message": "One or more shipments have a cubic weight more than 4 times greater than dead weight"' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateUpdateShipmentRequest() {
        return '' +
        '{' +
        '    "shipment_reference": "My first shipment",' +
        '    "customer_reference_2": "cb2345",' +
        '    "email_tracking_enabled":true,' +
        '    "source": {' +
        '        "name": "John Citizen",' +
        '        "lines": [' +
        '            "1 Main Street"' +
        '        ],' +
        '        "suburb": "Melbourne",' +
        '        "postcode": "3000",' +
        '        "state": "VIC",' +
        '        "phone": "0401234567",' +
        '        "email":"john.citizen@citizen.com"' +
        '    },' +
        '    "destination": {' +
        '        "name": "Jane Citizen",' +
        '        "business_name": "Abc Pty Ltd",' +
        '        "lines": [' +
        '            "Level 1",' +
        '            "1 Smith Street"' +
        '        ],' +
        '        "suburb": "Sydney",' +
        '        "state": "VIC",' +
        '        "postcode": "2000",' +
        '        "phone": "0312345678",' +
        '        "email":"jane.smith@smith.com"' +
        '    },' +
        '    "items": [' +
        '        {' +
        '            "length": "10",' +
        '            "height": "10",' +
        '            "width": "10",' +
        '            "weight": "10",' +
        '            "item_reference": "SKU-1",' +
        '            "product_id": "T28S",' +
        '            "authority_to_leave": false,' +
        '            "allow_partial_delivery": true' +
        '        },' +
        '        {' +
        '            "length": "10",' +
        '            "height": "10",' +
        '            "width": "10",' +
        '            "weight": "10",' +
        '            "item_reference": "SKU-2",' +
        '            "product_id": "T28S",' +
        '            "authority_to_leave": false,' +
        '            "allow_partial_delivery": true' +
        '        },' +
        '        {' +
        '            "length": "10",' +
        '            "height": "10",' +
        '            "width": "10",' +
        '            "weight": "10",' +
        '            "item_reference": "SKU-3",' +
        '            "product_id": "T28S",' +
        '            "authority_to_leave": false,' +
        '            "allow_partial_delivery": true' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateCreateOrderRequest() {
        return '' + 
        '{' +
        '    "order_reference":"My order reference",' +
        '    "payment_method":"CHARGE_TO_ACCOUNT",' +
        '    "shipments": [' +
        '        {' +
        '        "shipment_id": "569b9a3accdc791c4ba34d6f"' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateExpectedCreateOrderResponse() {
        return '' +
        '{' +
        '    "order":{' +
        '        "order_id":"AP0000002422",' +
        '        "order_reference":"My order reference",' +
        '        "order_creation_date":"2014-08-27T13:55:47+10:00",' +
        '        "order_summary":{' +
        '            "total_cost":63.1,' +
        '            "total_cost_ex_gst":57.36,' +
        '            "total_gst":5.74,' +
        '            "status":"Initiated",' +
        '            "tracking_summary":{' +
        '                "Initiated":1' +
        '            },' +
        '            "number_of_shipments":1' +
        '        },' +
        '        "shipments":[' +
        '            {' +
        '                "shipment_id":"gskK1UrUQPMAAAFSUuRKdt9Y",' +
        '                "email_tracking_enabled":false,' +
        '                "shipment_summary":{' +
        '                    "total_cost":7.2,' +
        '                    "total_cost_ex_gst":6.55,' +
        '                    "fuel_surcharge":2.10,' +
        '                    "total_gst":0.65,' +
        '                    "status":"Sealed",' +
        '                    "tracking_summary":{' +
        '                        "Sealed":1' +
        '                    },' +
        '                    "number_of_items":1' +
        '                }' +
        '            }' +
        '        ],' +
        '        "payment_method":"CHARGE_TO_ACCOUNT"' +
        '    }' +
        '}';
    }

    public static String generateExpectedGetOrderResponse() {
        return '' +
        '{' +
        '    "order":{' +
        '        "order_id":"AP0000002422",' +
        '        "order_reference":"XYZ-001",' +
        '        "order_creation_date":"2014-08-27T13:55:47+10:00",' +
        '        "order_summary":{' +
        '            "total_cost":74,' +
        '            "total_cost_ex_gst":67.27,' +
        '            "total_gst":6.73,' +
        '            "status":"Initiated",' +
        '            "tracking_summary":{' +
        '                "Initiated":1' +
        '            },' +
        '            "number_of_shipments":1' +
        '        },' +
        '        "shipments":[' +
        '            {' +
        '                "shipment_id":"m.cK1UrU_t0AAAFSz8ZKdt.K",' +
        '                "email_tracking_enabled":true,' +
        '                "from":{' +
        '                    "type":"MERCHANT_LOCATION",' +
        '                    "lines":[' +
        '                        "1 Main Street"' +
        '                    ],' +
        '                    "suburb":"Blackburn",' +
        '                    "postcode":"3130",' +
        '                    "state":"VIC",' +
        '                    "name":"John Citizen",' +
        '                    "email":"john.citizen@citizen.com",' +
        '                    "phone":"0401234567"' +
        '                },' +
        '                "to":{' +
        '                    "lines":[' +
        '                        "123 Centre Road"' +
        '                    ],' +
        '                    "suburb":"Sydney",' +
        '                    "postcode":"2000",' +
        '                    "state":"NSW",' +
        '                    "name":"Jane Smith",' +
        '                    "business_name":"Smith Pty Ltd",' +
        '                    "email":"jane.smith@smith.com",' +
        '                    "phone":"0412345678"' +
        '                },' +
        '                "shipment_summary":{' +
        '                    "total_cost":37,' +
        '                    "total_cost_ex_gst":33.64,' +
        '                    "fuel_surcharge":2.15,' +
        '                    "total_gst":3.36,' +
        '                    "status":"Sealed",' +
        '                    "tracking_summary":{' +
        '                        "Initiated":1' +
        '                    },' +
        '                    "number_of_items":1' +
        '                }' +
        '            }' +
        '        ],' +
        '        "payment_method":"CHARGE_TO_ACCOUNT",' +
        '        "consignor":"1234567890123456789012345678901234567890"' +
        '    }' +
        '}';
    }
    
    public static String generateExpectedGetLabelResponse() {
        return '' +
        '{' +
        '    \"message\": \"Your label printing is now in progress. Please wait...;\",' +
        '    \"code\": \"Request actioned\",' +
        '    \"labels\": [' +
        '        {' +
        '            \"request_id\": \"d9d1445d-cd1b-452d-9d68-29dbb3967acf\",' +
        '            \"status\": \"PENDING\",' +
        '            \"request_date\": \"01-04-2016 05:09:14\",' +
        '            \"shipments\": [' +
        '                {' +
        '                    \"shipment_id\": \"t4AK0EhQTu4AAAFeVsxGqhLO\",' +
        '                    \"items\": [' +
        '                        {' +
        '                            \"item_id\": \"2vsK0EhQT1YAAAFeWMxGqhLO\"' +
        '                        }' +
        '                    ]' +
        '                }' +
        '            ],' +
        '            \"shipment_ids\": [' +
        '                \"t4AK0EhQTu4AAAFeVsxGqhLO\"' +
        '            ]' +
        '        }' +
        '    ]' +
        '}';
    }
    
    public static String generateExpectedCreateShipmentsResponse() {

        return '' +
            '{' + 
            '    "warnings": [' + 
            '        {' + 
            '            "message": "Safe Drop is not available for use with this product.",' + 
            '            "field": "shipments[0].items[0].safe_drop_enabled"' + 
            '        }' + 
            '    ],' + 
            '    "shipments": [' + 
            '        {' + 
            '            "shipment_id": "1g8K0E6mBEsAAAFpAGUg7EZn",' + 
            '            "shipment_reference": "TTI_CASE_2020203",' + 
            '            "shipment_creation_date": "2019-03-04T12:52:55+11:00",' + 
            '            "email_tracking_enabled": true,' + 
            '            "items": [' + 
            '                {' + 
            '                    "weight": 1,' + 
            '                    "authority_to_leave": false,' + 
            '                    "allow_partial_delivery": false,' + 
            '                    "item_id": "mVoK0E6mgW4AAAFpAmUg7EZn",' + 
            '                    "item_reference": "M18FID-0",' + 
            '                    "tracking_details": {' + 
            '                        "article_id": "111Z50024734PRM00001",' + 
            '                        "consignment_id": "111Z50024734"' + 
            '                    },' + 
            '                    "product_id": "PRM",' + 
            '                    "item_summary": {' + 
            '                        "status": "Created"' + 
            '                    },' + 
            '                    "item_contents": [],' + 
            '                    "packaging_type": "ITM"' + 
            '                }' + 
            '            ],' + 
            '            "options": {},' + 
            '            "shipment_summary": {' + 
            '                "total_cost": 49.37,' + 
            '                "total_cost_ex_gst": 44.88,' + 
            '                "total_gst": 4.49,' + 
            '                "freight_charge": 44.88,' + 
            '                "status": "Created",' + 
            '                "tracking_summary": {' + 
            '                    "Created": 1' + 
            '                },' + 
            '                "number_of_items": 1' + 
            '            },' + 
            '            "movement_type": "DESPATCH",' + 
            '            "consolidate": false,' + 
            '            "charge_to_account": "00673416"' + 
            '        }' + 
            '    ]' + 
            '}';
    }

    public static String generateExpectedCreateLabelsResponse() {

        return '' +
            '{' +
            '    "message": "Your label printing is now in progress. Please wait...;",' +
            '    "code": "Request actioned",' +
            '    "labels": [' +
            '        {' +
            '            "request_id": "b3ed5e7a-e5fa-45cb-b482-dca37a5d5716",' +
            '            "status": "PENDING",' +
            '            "request_date": "07-03-2019 13:29:17",' +
            '            "shipments": [' +
            '                {' +
            '                    "shipment_id": "1g8K0E6mBEsAAAFpAGUg7EZn",' +
            '                    "options": {}' +
            '                }' +
            '            ],' +
            '            "shipment_ids": [' +
            '                "1g8K0E6mBEsAAAFpAGUg7EZn"' +
            '            ]' +
            '        }' +
            '    ]' +
            '}';
    }

    public static String generateExpectedGetLabelAvailableResponse() {
        return '' +
        '{' +
        '    "labels": [' +
        '        {' +
        '            "request_id": "b3ed5e7a-e5fa-45cb-b482-dca37a5d5716",' +
        '            "url": "https://ap-prod-ddc-stack-content.s3-ap-southeast-2.amazonaws.com/pccbatch-prod3/2587d2be-d466-46d1-8075-171d57db7b6e.pdf?AWSAccessKeyId=AKIAJZ2VLLVH5FAWOGYA&Expires=1549674115&Signature=sFNU1mtc8tQ9PDFSFNTH%2Bvn4RDo%3D",' +
        '            "status": "AVAILABLE",' +
        '            "request_date": "07-03-2019 13:29:17",' +
        '            "url_creation_date": "08-02-2019 12:01:55",' +
        '            "shipments": [' +
        '                {' +
        '                    "shipment_id": "1g8K0E6mBEsAAAFpAGUg7EZn",' +
        '                    "options": {}' +
        '                }' +
        '            ],' +
        '            "shipment_ids": [' +
        '                "1g8K0E6mBEsAAAFpAGUg7EZn"' +
        '            ]' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateExpectedGetShipmentResponse() {
        return '' +
        '{' +
        '    "shipments":[' +
        '        {' +
        '            "shipment_id":"9lesEAOvOm4AAAFI3swaDRYB",' +
        '            "shipment_reference":"XYZ-001-01",' +
        '            "shipment_creation_date":"2014-08-27T15:48:09+10:00",' +
        '            "customer_reference_1":"Order 001",' +
        '            "sender_references":[' +
        '                "Order 001"' +
        '            ],' +
        '            "email_tracking_enabled":false,' +
        '            "from":{' +
        '                "type":"MERCHANT_LOCATION",' +
        '                "lines":[' +
        '                    "1 Main Street"' +
        '                ],' +
        '                "suburb":"Geelong",' +
        '                "postcode":"3220",' +
        '                "state":"VIC",' +
        '                "name":"John Citizen",' +
        '                "email":"john.citizen@citizen.com",' +
        '                "phone":"0401234567"' +
        '            },' +
        '            "to":{' +
        '                "lines":[' +
        '                    "123 Centre Road"' +
        '                ],' +
        '                "suburb":"Sydney",' +
        '                "postcode":"2000",' +
        '                "state":"NSW",' +
        '                "name":"Jane Smith",' +
        '                "business_name":"Smith Pty Ltd",' +
        '                "email":"jane.smith@smith.com",' +
        '                "phone":"0412345678"' +
        '            },' +
        '            "items":[' +
        '                {' +
        '                    "weight":1,' +
        '                    "height":10,' +
        '                    "length":10,' +
        '                    "width":10,' +
        '                    "contains_dangerous_goods": false,' +
        '                    "allow_partial_delivery":false,' +
        '                    "authority_to_leave":false,' +
        '                    "item_id":"LDCsEAOvU_oAAAFI6MwaDRYB",' +
        '                    "item_reference":"SKU-1",' +
        '                    "product_id":"T28S",' +
        '                    "tracking_details":{' +
        '                        "article_id":"ABC803349001000931404",' +
        '                        "consignment_id":"ABC5033490",' +
        '                        "barcode_id":"01111126...|4202000|8008160214215137"' +
        '                    },' +
        '                    "item_summary":{' +
        '                        "total_cost":5.00,' +
        '                        "total_cost_ex_gst":4.55,' +
        '                        "total_gst":0.45,' +
        '                        "status":"Initiated"' +
        '                    },' +
        '                    "label":{' +
        '                        "label_url":"https://auspost.com.au/ABC0028165DA.pdf?Expires=1422918363&Signature=123123%3D",' +
        '                        "status":"Available",' +
        '                        "errors":[' +
        '                        ],' +
        '                        "label_creation_date":"2015-02-03T09:06:03+11:00"' +
        '                    },' +
        '                    "packaging_type": "ITM"' +
        '                },' +
        '                {' +
        '                    "weight":1,' +
        '                    "height":10,' +
        '                    "length":10,' +
        '                    "width":10,' +
        '                    "contains_dangerous_goods": false,' +
        '                    "allow_partial_delivery":false,' +
        '                    "authority_to_leave":false,' +
        '                    "item_id":"ynesEAOvnlAAAAFI88waDRYB",' +
        '                    "item_reference":"SKU-3",' +
        '                    "product_id":"T28S",' +
        '                    "tracking_details":{' +
        '                        "article_id":"ABC503349001000931403",' +
        '                        "consignment_id":"ABC5033490",' +
        '                        "barcode_id":"01111126...|4202000|8008160214215136"' +
        '                    },' +
        '                    "item_summary":{' +
        '                        "total_cost":4.00,' +
        '                        "total_cost_ex_gst":3.64,' +
        '                        "total_gst":0.36,' +
        '                        "status":"Initiated"' +
        '                    },' +
        '                    "label":{' +
        '                        "label_url":"https://auspost.com.au/ABC0028164DA.pdf?Expires=1422918363&Signature=123123%3D",' +
        '                        "status":"Available",' +
        '                        "errors":[' +
        '                        ],' +
        '                        "label_creation_date":"2015-02-03T09:06:03+11:00"' +
        '                    },' +
        '                    "packaging_type": "ITM"' +
        '                },' +
        '                {' +
        '                    "weight":1,' +
        '                    "height":10,' +
        '                    "length":10,' +
        '                    "width":10,' +
        '                    "contains_dangerous_goods": false,' +
        '                    "allow_partial_delivery":false,' +
        '                    "authority_to_leave":false,' +
        '                    "item_id":"TkGsEAOv9a4AAAFI8MwaDRYB",' +
        '                    "item_reference":"SKU-2",' +
        '                    "product_id":"T28S",' +
        '                    "tracking_details":{' +
        '                        "article_id":"ABC503349001000931402",' +
        '                        "consignment_id":"MHK5033490",' +
        '                        "barcode_id":"0111126...|4202000|8008160214215135"' +
        '                    },' +
        '                    "item_summary":{' +
        '                        "total_cost":4.00,' +
        '                        "total_cost_ex_gst":3.64,' +
        '                        "total_gst":0.36,' +
        '                        "status":"Initiated"' +
        '                    },' +
        '                    "label":{' +
        '                        "label_url":"https://auspost.com.au/ABC0028163DA.pdf?Expires=1422918363&Signature=123123%3D",' +
        '                        "status":"Available",' +
        '                        "errors":[' +
        '                        ],' +
        '                        "label_creation_date":"2015-02-03T09:06:03+11:00"' +
        '                    },' +
        '                    "packaging_type": "ITM"' +
        '                }' +
        '            ],' +
        '            "shipment_summary":{' +
        '                "total_cost":13.00,' +
        '                "total_cost_ex_gst":11.82,' +
        '                "fuel_surcharge":2.00,' +
        '                "total_gst":1.18,' +
        '                "status":"Initiated",' +
        '                "number_of_items":3,' +
        '                "tracking_summary":{' +
        '                    "Initiated":3' +
        '                }' +
        '            },' +
        '            "order_id":"AP0000002999"' +
        '        }' +
        '    ]' +
        '}';
    }
    
    public static String generateShipmentErrorResponse() {
        return '' +
        '{' +
        '    "errors": [' +
        '        {' +
        '            "code": "44026",' +
        '            "name": " SHIPMENT_NOT_FOUND ",' +
        '            "message": "An order with shipment id 9lesEAOvOm4AAAFI3swaDRYB cannot be found. Please check that the identifier is correct and submit the request again."' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateExpectedCreateAdhocPickupResponse() {
        return '' +
        '{' +
        '    "adhoc_pickups": ['+
        '        {' +
        '            "booking_id": "1234567"' +
        '        }' +
        '    ]' +
        '}';
    }

    public static String generateAdhocPickupErrorResponse() {
        return '' +
        '{' +
        '    "errors": [' +
        '        {' +
        '            "code": "400",' +
        '            "name": "INVALID_PRODUCT_ID",' +
        '            "message": "The product ID ABC is not available",' +
        '            "field": "adhocPickup.productId"' +
        '        }' +
        '    ]' +
        '}';
    }

    public static SpCreateShipmentReqDtoAup generateCreateShipmentRequest() {
        
        SpCreateShipmentReqDtoAup reqDto = new SpCreateShipmentReqDtoAup();

        SpCreateShipmentReqDtoAup.Shipments shipment = new SpCreateShipmentReqDtoAup.Shipments();
        shipment.consolidate = false;
        shipment.customer_reference_1 = '222222';
        shipment.customer_reference_2 = 'CDEFGH';
        shipment.email_tracking_enabled = true;
        shipment.shipment_reference = 'TTI_CASE_2020203';

        SpCreateShipmentReqDtoAup.Source source = new SpCreateShipmentReqDtoAup.Source();
        source.email = 'john.doe@yopmail.com';
        source.name = 'TTI Service Centre';
        source.phone = '0401234567';
        source.postcode = '3000';
        source.state = 'VIC';
        source.suburb = 'MELBOURNE';
        source.lines = new List<String>{ '1 Main Street' };
        shipment.source = source;

        SpCreateShipmentReqDtoAup.Destination destination = new SpCreateShipmentReqDtoAup.Destination();
        destination.business_name = 'Smith Pty Ltd';
        destination.email = 'jane.smith@smith.com';
        destination.name = 'Jane Smith';
        destination.phone = '0412345678';
        destination.postcode = '2000';
        destination.state = 'NSW';
        destination.suburb = 'Sydney';
        destination.lines = new List<String>{ '123 Centre Road' };
        shipment.destination = destination;

        SpCreateShipmentReqDtoAup.Items item = new SpCreateShipmentReqDtoAup.Items();
        item.allow_partial_delivery = false;
        item.authority_to_leave = false;
        item.height = '10';
        item.item_reference = 'M18FID-0';
        item.length = '10';
        item.packaging_type = 'ITM';
        item.product_id = 'PRM';
        item.weight = '1';
        item.width = '10';
        shipment.items = new List<SpCreateShipmentReqDtoAup.Items>{ item };

        reqDto.shipments = new List<SpCreateShipmentReqDtoAup.Shipments>{ shipment };

        return reqDto;
    }

    public static SpCreateLabelReqDtoAup generateCreateLabelRequest() {
        
        SpCreateLabelReqDtoAup label = new SpCreateLabelReqDtoAup();
        label.preferences = new List<SpCreateLabelReqDtoAup.Preference>{
            new SpCreateLabelReqDtoAup.Preference('PRINT', 'PDF',
                new List<SpCreateLabelReqDtoAup.LabelGroup>{
                    new SpCreateLabelReqDtoAup.LabelGroup('Startrack', 'A6-1pp', true, 0, 0),
                    new SpCreateLabelReqDtoAup.LabelGroup('Startrack Courier', 'A6-1pp', false, 0, 0)
                }
            )
        };

        label.shipments = new List<SpCreateLabelReqDtoAup.Shipment>();
        label.shipments.add(new SpCreateLabelReqDtoAup.Shipment('1g8K0E6mBEsAAAFpAGUg7EZn'));

        return label;
    }

    public static SpCreateAdhocPickupReqDtoAup generateCreateAdhocPickupRequest() {
        
        SPCreateAdhocPickupReqDtoAup reqDto = new SPCreateAdhocPickupReqDtoAup();
        
        SPCreateAdhocPickupReqDtoAup.Adhoc_pickup adhoc_pickup = new SPCreateAdhocPickupReqDtoAup.Adhoc_pickup();
        adhoc_pickup.product_id = 'EXP';
        adhoc_pickup.pickup_reference = '1444444444442345678'; 
        adhoc_pickup.pickup_date = '2021-01-31';
        adhoc_pickup.pickup_starttime = '14:00:00';
        adhoc_pickup.pickup_endtime = '20:00:00';
        adhoc_pickup.pickup_instructions = 'heavy items';

        SPCreateAdhocPickupReqDtoAup.Source source = new SPCreateAdhocPickupReqDtoAup.Source();
        source.lines = new List<String>{ 'Unit 1, 234 Park St'};
        source.suburb = 'Fitzroy';
        source.postcode = '3065';
        source.state = 'VIC';
        source.business_name = 'Jenchanel Pty Ltd';
        source.booking_name = 'Hank Park';
        source.pickup_name = 'Lily Smith';
        source.pickup_area = 'reception on level 10';
        source.private_address = false;
        source.email = 'lilysmith@smith.com';
        source.phone = '0412222222';
        adhoc_pickup.source = source;

        SPCreateAdhocPickupReqDtoAup.Parcel_details parcel_detail1 = new SPCreateAdhocPickupReqDtoAup.Parcel_details();
        parcel_detail1.packaging_type = 'ITM';
        parcel_detail1.comments = 'test item details';
        parcel_detail1.length = 10;
        parcel_detail1.height = 19;
        parcel_detail1.width = 30;
        parcel_detail1.count = 1;
        parcel_detail1.weight = 17;
        parcel_detail1.heaviest_item = 17;

        SPCreateAdhocPickupReqDtoAup.Parcel_details parcel_detail2 = new SPCreateAdhocPickupReqDtoAup.Parcel_details();
        parcel_detail2.packaging_type = 'SAT';
        parcel_detail2.comments = 'test satchel details';
        parcel_detail2.length = 20;
        parcel_detail2.height = 29;
        parcel_detail2.width = 15;
        parcel_detail2.count = 5;
        parcel_detail2.weight = 7;
        parcel_detail2.heaviest_item = 3;

        adhoc_pickup.contains_dangerous_goods = false;
        adhoc_pickup.consignment_id = 'EXP1234567890';

        List<SPCreateAdhocPickupReqDtoAup.Parcel_details> parcels = new List<SPCreateAdhocPickupReqDtoAup.Parcel_details>();
        parcels.add(parcel_detail1);
        parcels.add(parcel_detail2);
        
        adhoc_pickup.parcel_details = parcels;
        reqDto.adhoc_pickup = adhoc_pickup;

        return reqDto;
    }
}