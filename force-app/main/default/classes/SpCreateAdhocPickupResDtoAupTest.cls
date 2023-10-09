@isTest
public with sharing class SpCreateAdhocPickupResDtoAupTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '    \"adhoc_pickups\": ['+
        '        {'+
        '            \"booking_id\": \"1234567\"'+
        '        }'+
        '    ]'+
        '}';
        SpCreateAdhocPickupResDtoAup r = SpCreateAdhocPickupResDtoAup.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupResDtoAup objSpCreateAdhocPickupResDtoAup = new SpCreateAdhocPickupResDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateAdhocPickupResDtoAup != null);
        System.assert(objSpCreateAdhocPickupResDtoAup.adhoc_pickups == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateAdhocPickupResDtoAup.Adhoc_pickups objAdhoc_pickups = new SpCreateAdhocPickupResDtoAup.Adhoc_pickups(System.JSON.createParser(json));
        System.assert(objAdhoc_pickups != null);
        System.assert(objAdhoc_pickups.booking_id == null);
    }
}