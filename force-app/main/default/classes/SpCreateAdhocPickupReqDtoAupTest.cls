@IsTest
public class SpCreateAdhocPickupReqDtoAupTest {

    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{' +
            '    \"adhoc_pickup\": {' +
            '        \"product_id\": \"EXP\",' +
            '        \"pickup_reference\": \"1444444444442345678\",' +
            '        \"pickup_date\": \"2018-05-22\",' +
            '        \"pickup_starttime\": \"15:30:00\",' +
            '        \"pickup_endtime\": \"16:00:00\",' +
            '        \"pickup_instructions\": \"heavy items\",' +
            '        \"from\": {' +
            '            \"lines\": [' +
            '                \"Unit 1\",' +
            '                \"123 Smith st\"' +
            '            ],' +
            '            \"suburb\": \"Fitzroy\",' +
            '            \"postcode\": \"3065\",' +
            '            \"state\": \"VIC\",' +
            '            \"business_name\": \"Smith Pty Ltd\",' +
            '            \"booking_name\": \"John Smith\",' +
            '            \"pickup_name\": \"Jane Smith\",' +
            '            \"pickup_area\": \"reception on level 10\",' +
            '            \"private_address\": true,' +
            '            \"email\": \"jane.smith@smith.com\",' +
            '            \"phone\": \"0412222222\"' +
            '        },' +
            '        \"contains_dangerous_goods\": false,' +
            '        \"consignment_id\": \"EXP1234567890\",' +
            '        \"parcel_details\": [' +
            '            {' +
            '                \"packaging_type\": \"CTN\",' +
            '                \"comments\": \"test carton details\",' +
            '                \"length\": 10,' +
            '                \"height\": 19,' +
            '                \"width\": 30,' +
            '                \"count\": 2,' +
            '                \"weight\": 17,' +
            '                \"heaviest_item\": 10' +
            '            },' +
            '            {' +
            '                \"packaging_type\": \"SAT\",' +
            '                \"comments\": \"test satchel details\",' +
            '                \"length\": 20,' +
            '                \"height\": 29,' +
            '                \"width\": 15,' +
            '                \"count\": 5,' +
            '                \"weight\": 7,' +
            '                \"heaviest_item\": 3' +
            '            }' +
            '        ]' +
            '    }' +
            '}';
        SpCreateAdhocPickupReqDtoAup r = SpCreateAdhocPickupReqDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupReqDtoAup objSpCreateAdhocPickupReqDtoAup = new SpCreateAdhocPickupReqDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateAdhocPickupReqDtoAup != null);
        System.assert(objSpCreateAdhocPickupReqDtoAup.adhoc_pickup == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupReqDtoAup.Source objSource = new SpCreateAdhocPickupReqDtoAup.Source(System.JSON.createParser(json));
        System.assert(objSource != null);
        System.assert(objSource.lines == null);
        System.assert(objSource.suburb == null);
        System.assert(objSource.postcode == null);
        System.assert(objSource.state == null);
        System.assert(objSource.business_name == null);
        System.assert(objSource.booking_name == null);
        System.assert(objSource.pickup_name == null);
        System.assert(objSource.pickup_area == null);
        System.assert(objSource.private_address == null);
        System.assert(objSource.email == null);
        System.assert(objSource.phone == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupReqDtoAup.Parcel_details objParcel_details = new SpCreateAdhocPickupReqDtoAup.Parcel_details(System.JSON.createParser(json));
        System.assert(objParcel_details != null);
        System.assert(objParcel_details.packaging_type == null);
        System.assert(objParcel_details.comments == null);
        System.assert(objParcel_details.length == null);
        System.assert(objParcel_details.height == null);
        System.assert(objParcel_details.width == null);
        System.assert(objParcel_details.count == null);
        System.assert(objParcel_details.weight == null);
        System.assert(objParcel_details.heaviest_item == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupReqDtoAup.Adhoc_pickup objAdhoc_pickup = new SpCreateAdhocPickupReqDtoAup.Adhoc_pickup(System.JSON.createParser(json));
        System.assert(objAdhoc_pickup != null);
        System.assert(objAdhoc_pickup.product_id == null);
        System.assert(objAdhoc_pickup.pickup_reference == null);
        System.assert(objAdhoc_pickup.pickup_date == null);
        System.assert(objAdhoc_pickup.pickup_starttime == null);
        System.assert(objAdhoc_pickup.pickup_endtime == null);
        System.assert(objAdhoc_pickup.pickup_instructions == null);
        System.assert(objAdhoc_pickup.source == null);
        System.assert(objAdhoc_pickup.contains_dangerous_goods == null);
        System.assert(objAdhoc_pickup.consignment_id == null);
        System.assert(objAdhoc_pickup.parcel_details == null);
    }
}