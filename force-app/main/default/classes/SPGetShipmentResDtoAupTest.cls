@IsTest
public class SPGetShipmentResDtoAupTest {
        
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"warnings\": ['+
        '        {'+
        '            \"name\": \"NO_CONTRACT_PRICING_AVAILABLE_FOR_SHIPMENT\",'+
        '            \"message\": \"Your account currently does not have a contracted rate for this product, \'from\' and \'to\' lane combination in shipment GqkK0EHhrxUAAAFsgNwfzrek.  Please contact your account manager for further information.\",'+
        '            \"field\": \"\",'+
        '            \"context\": {'+
        '                \"weight\": \"2.0\",'+
        '                \"shipment_internal_ref\": null,'+
        '                \"shipment_id\": \"GqkK0EHhrxUAAAFsgNwfzrek\",'+
        '                \"product_id\": \"EXP\",'+
        '                \"location_id\": \"00673416\"'+
        '            },'+
        '            \"code\": \"66004\"'+
        '        }'+
        '    ],'+
        '    \"shipments\": ['+
        '        {'+
        '            \"to\": {'+
        '                \"type_Z\": \"STANDARD_ADDRESS\",'+
        '                \"suburb\": \"Carlton\",'+
        '                \"state\": \"VIC\",'+
        '                \"postcode\": \"3053\",'+
        '                \"name\": \"Jack Codling\",'+
        '                \"lines\": ['+
        '                    \"555 Swanston Street\"'+
        '                ],'+
        '                \"email\": \"jack.codling@yopmail.com\",'+
        '                \"country\": \"AU\",'+
        '                \"business_name\": null'+
        '            },'+
        '            \"shipment_summary\": {'+
        '                \"tracking_summary\": {'+
        '                    \"Created\": null'+
        '                },'+
        '                \"status\": \"Sealed\",'+
        '                \"number_of_items\": 1'+
        '            },'+
        '            \"shipment_reference\": \"TTI_CASE_00196628\",'+
        '            \"shipment_id\": \"GqkK0EHhrxUAAAFsgNwfzrek\",'+
        '            \"shipment_creation_date\": \"2019-08-22T14:45:30+10:00\",'+
        '            \"sender_references\": ['+
        '                \"00196628\"'+
        '            ],'+
        '            \"options\": {},'+
        '            \"movement_type\": \"DESPATCH\",'+
        '            \"items\": ['+
        '                {'+
        '                    \"width\": 115,'+
        '                    \"weight\": 2,'+
        '                    \"tracking_details\": {'+
        '                        \"consignment_id\": \"111Z50060413\",'+
        '                        \"barcode_id\": \"111Z50060413EXP00001\",'+
        '                        \"article_id\": \"111Z50060413EXP00001\"'+
        '                    },'+
        '                    \"product_id\": \"EXP\",'+
        '                    \"postage_details\": {'+
        '                        \"price\": {'+
        '                            \"calculated_price_ex_gst\": 0,'+
        '                            \"calculated_price\": 0,'+
        '                            \"calculated_gst\": 0'+
        '                        }'+
        '                    },'+
        '                    \"packaging_type\": \"ITM\",'+
        '                    \"length\": 218,'+
        '                    \"label\": {'+
        '                        \"status\": \"Available\",'+
        '                        \"label_url\": \"https://ap-prod-ddc-stack-content.s3-ap-southeast-2.amazonaws.com/pccbatch-prod3/8f56fd52-50dc-4118-bb63-07bde5c73de0.pdf?AWSAccessKeyId=AKIAJZ2VLLVH5FAWOGYA&Expires=1566538632&Signature=dqSJxNgFWr12xBUCwfU7GwbEizQ%3D\",'+
        '                        \"label_creation_date\": \"2019-08-22T15:37:12+10:00\",'+
        '                        \"errors\": []'+
        '                    },'+
        '                    \"item_summary\": {'+
        '                        \"status\": \"Sealed\"'+
        '                    },'+
        '                    \"item_reference\": \"M18FDD-0\",'+
        '                    \"item_id\": \"SNcK0E_2UIMAAAFsUyggP7fU\",'+
        '                    \"item_contents\": [],'+
        '                    \"height\": 270,'+
        '                    \"contains_dangerous_goods\": false,'+
        '                    \"authority_to_leave\": false,'+
        '                    \"allow_partial_delivery\": false'+
        '                }'+
        '            ],'+
        '            \"from_Z\": {'+
        '                \"type_Z\": \"MERCHANT_LOCATION\",'+
        '                \"suburb\": \"Rowville\",'+
        '                \"state\": \"VIC\",'+
        '                \"postcode\": \"3178\",'+
        '                \"phone\": \"0412345678\",'+
        '                \"name\": \"Service Agent - External\",'+
        '                \"lines\": ['+
        '                    \"21 Kelletts Road\"'+
        '                ],'+
        '                \"email\": \"fnasalita@ttibrands.com.au\",'+
        '                \"country\": \"AU\"'+
        '            },'+
        '            \"email_tracking_enabled\": true,'+
        '            \"customer_reference_2\": null,'+
        '            \"customer_reference_1\": \"00196628\",'+
        '            \"consolidate\": false,'+
        '            \"charge_to_account\": \"00673416\"'+
        '        }'+
        '    ],'+
        '    \"pagination\": {'+
        '        \"total_number_of_records\": 1,'+
        '        \"number_of_records_per_page\": 1,'+
        '        \"current_page_number\": 1'+
        '    }'+
        '}';
        SPGetShipmentResDtoAup r = SPGetShipmentResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Context objContext = new SPGetShipmentResDtoAup.Context(System.JSON.createParser(json));
        System.assert(objContext != null);
        System.assert(objContext.weight == null);
        System.assert(objContext.shipment_internal_ref == null);
        System.assert(objContext.shipment_id == null);
        System.assert(objContext.product_id == null);
        System.assert(objContext.location_id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Item_summary objItem_summary = new SPGetShipmentResDtoAup.Item_summary(System.JSON.createParser(json));
        System.assert(objItem_summary != null);
        System.assert(objItem_summary.status == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Label objLabel = new SPGetShipmentResDtoAup.Label(System.JSON.createParser(json));
        System.assert(objLabel != null);
        System.assert(objLabel.status == null);
        System.assert(objLabel.label_url == null);
        System.assert(objLabel.label_creation_date == null);
        System.assert(objLabel.errors == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.From_Z objFrom_Z = new SPGetShipmentResDtoAup.From_Z(System.JSON.createParser(json));
        System.assert(objFrom_Z != null);
        System.assert(objFrom_Z.type_Z == null);
        System.assert(objFrom_Z.suburb == null);
        System.assert(objFrom_Z.state == null);
        System.assert(objFrom_Z.postcode == null);
        System.assert(objFrom_Z.phone == null);
        System.assert(objFrom_Z.name == null);
        System.assert(objFrom_Z.lines == null);
        System.assert(objFrom_Z.email == null);
        System.assert(objFrom_Z.country == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Tracking_details objTracking_details = new SPGetShipmentResDtoAup.Tracking_details(System.JSON.createParser(json));
        System.assert(objTracking_details != null);
        System.assert(objTracking_details.consignment_id == null);
        System.assert(objTracking_details.barcode_id == null);
        System.assert(objTracking_details.article_id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Postage_details objPostage_details = new SPGetShipmentResDtoAup.Postage_details(System.JSON.createParser(json));
        System.assert(objPostage_details != null);
        System.assert(objPostage_details.price == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Pagination objPagination = new SPGetShipmentResDtoAup.Pagination(System.JSON.createParser(json));
        System.assert(objPagination != null);
        System.assert(objPagination.total_number_of_records == null);
        System.assert(objPagination.number_of_records_per_page == null);
        System.assert(objPagination.current_page_number == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Price objPrice = new SPGetShipmentResDtoAup.Price(System.JSON.createParser(json));
        System.assert(objPrice != null);
        System.assert(objPrice.calculated_price_ex_gst == null);
        System.assert(objPrice.calculated_price == null);
        System.assert(objPrice.calculated_gst == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Items objItems = new SPGetShipmentResDtoAup.Items(System.JSON.createParser(json));
        System.assert(objItems != null);
        System.assert(objItems.width == null);
        System.assert(objItems.weight == null);
        System.assert(objItems.tracking_details == null);
        System.assert(objItems.product_id == null);
        System.assert(objItems.postage_details == null);
        System.assert(objItems.packaging_type == null);
        System.assert(objItems.length == null);
        System.assert(objItems.label == null);
        System.assert(objItems.item_summary == null);
        System.assert(objItems.item_reference == null);
        System.assert(objItems.item_id == null);
        System.assert(objItems.item_contents == null);
        System.assert(objItems.height == null);
        System.assert(objItems.contains_dangerous_goods == null);
        System.assert(objItems.authority_to_leave == null);
        System.assert(objItems.allow_partial_delivery == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.To objTo = new SPGetShipmentResDtoAup.To(System.JSON.createParser(json));
        System.assert(objTo != null);
        System.assert(objTo.type_Z == null);
        System.assert(objTo.suburb == null);
        System.assert(objTo.state == null);
        System.assert(objTo.postcode == null);
        System.assert(objTo.name == null);
        System.assert(objTo.lines == null);
        System.assert(objTo.email == null);
        System.assert(objTo.country == null);
        System.assert(objTo.business_name == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Tracking_summary objTracking_summary = new SPGetShipmentResDtoAup.Tracking_summary(System.JSON.createParser(json));
        System.assert(objTracking_summary != null);
        System.assert(objTracking_summary.Created == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Shipment_summary objShipment_summary = new SPGetShipmentResDtoAup.Shipment_summary(System.JSON.createParser(json));
        System.assert(objShipment_summary != null);
        System.assert(objShipment_summary.tracking_summary == null);
        System.assert(objShipment_summary.status == null);
        System.assert(objShipment_summary.number_of_items == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Warnings objWarnings = new SPGetShipmentResDtoAup.Warnings(System.JSON.createParser(json));
        System.assert(objWarnings != null);
        System.assert(objWarnings.name == null);
        System.assert(objWarnings.message == null);
        System.assert(objWarnings.field == null);
        System.assert(objWarnings.context == null);
        System.assert(objWarnings.code == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup objSPGetShipmentResDtoAup = new SPGetShipmentResDtoAup(System.JSON.createParser(json));
        System.assert(objSPGetShipmentResDtoAup != null);
        System.assert(objSPGetShipmentResDtoAup.warnings == null);
        System.assert(objSPGetShipmentResDtoAup.shipments == null);
        System.assert(objSPGetShipmentResDtoAup.pagination == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SPGetShipmentResDtoAup.Shipments objShipments = new SPGetShipmentResDtoAup.Shipments(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.to == null);
        System.assert(objShipments.shipment_summary == null);
        System.assert(objShipments.shipment_reference == null);
        System.assert(objShipments.shipment_id == null);
        System.assert(objShipments.shipment_creation_date == null);
        System.assert(objShipments.sender_references == null);
        System.assert(objShipments.options == null);
        System.assert(objShipments.movement_type == null);
        System.assert(objShipments.items == null);
        System.assert(objShipments.from_Z == null);
        System.assert(objShipments.email_tracking_enabled == null);
        System.assert(objShipments.customer_reference_2 == null);
        System.assert(objShipments.customer_reference_1 == null);
        System.assert(objShipments.consolidate == null);
        System.assert(objShipments.charge_to_account == null);
    }
}