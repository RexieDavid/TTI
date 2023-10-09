@IsTest
public class SpCreateLabelReqDtoAupTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"preferences\": ['+
        '        {'+
        '            \"type\": \"PRINT\",'+
        '            \"format\": \"PDF\",'+
        '            \"groups\": ['+
        '                {'+
        '                    \"group\": \"StarTrack\",'+
        '                    \"layout\": \"A6-1pp\",'+
        '                    \"branded\": true,'+
        '                    \"left_offset\": 0,'+
        '                    \"top_offset\": 0'+
        '                },'+
        '                {'+
        '                    \"group\": \"StarTrack\",'+
        '                    \"layout\": \"A6-1pp\",'+
        '                    \"branded\": false,'+
        '                    \"left_offset\": 0,'+
        '                    \"top_offset\": 0'+
        '                }'+
        '            ]'+
        '        }'+
        '    ],'+
        '    \"shipments\": ['+
        '        {'+
        '            \"shipment_id\": \"DY0K0E6mBdYAAAFojWwg7Ma3\"'+
        '        }'+
        '    ]'+
        '}';
        SpCreateLabelReqDtoAup r = SpCreateLabelReqDtoAup.parse(json);
        System.assert(r != null);

        r = new SpCreateLabelReqDtoAup();
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelReqDtoAup.LabelGroup objGroups = new SpCreateLabelReqDtoAup.LabelGroup(System.JSON.createParser(json));
        System.assert(objGroups != null);
        System.assert(objGroups.group_name == null);
        System.assert(objGroups.layout == null);
        System.assert(objGroups.branded == null);
        System.assert(objGroups.left_offset == null);
        System.assert(objGroups.top_offset == null);

        objGroups = new SpCreateLabelReqDtoAup.LabelGroup();
        System.assert(objGroups != null);

        objGroups = new SpCreateLabelReqDtoAup.LabelGroup('test', 'test', true, 10, 10);
        System.assert(objGroups != null);
        System.assert(objGroups.group_name != null);
        System.assert(objGroups.layout != null);
        System.assert(objGroups.branded != null);
        System.assert(objGroups.left_offset != null);
        System.assert(objGroups.top_offset != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelReqDtoAup.Preference objPreferences = new SpCreateLabelReqDtoAup.Preference(System.JSON.createParser(json));
        System.assert(objPreferences != null);
        System.assert(objPreferences.preference_type == null);
        System.assert(objPreferences.format == null);
        System.assert(objPreferences.groups == null);

        objPreferences = new SpCreateLabelReqDtoAup.Preference();
        System.assert(objPreferences != null);

        objPreferences = new SpCreateLabelReqDtoAup.Preference('test', 'test', new List<SpCreateLabelReqDtoAup.LabelGroup>());
        System.assert(objPreferences != null);
        System.assert(objPreferences.preference_type != null);
        System.assert(objPreferences.format != null);
        System.assert(objPreferences.groups != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelReqDtoAup objSpCreateLabelReqDtoAup = new SpCreateLabelReqDtoAup(System.JSON.createParser(json));
        System.assert(objSpCreateLabelReqDtoAup != null);
        System.assert(objSpCreateLabelReqDtoAup.preferences == null);
        System.assert(objSpCreateLabelReqDtoAup.shipments == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpCreateLabelReqDtoAup.Shipment objShipments = new SpCreateLabelReqDtoAup.Shipment(System.JSON.createParser(json));
        System.assert(objShipments != null);
        System.assert(objShipments.shipment_id == null);

        objShipments = new SpCreateLabelReqDtoAup.Shipment();
        System.assert(objShipments != null);        

        objShipments = new SpCreateLabelReqDtoAup.Shipment('test');
        System.assert(objShipments != null);
    }
}