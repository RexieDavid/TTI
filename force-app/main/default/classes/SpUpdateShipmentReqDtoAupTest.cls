@IsTest
public class SpUpdateShipmentReqDtoAupTest {
    
    @IsTest
    static void testParse() {
        
        String json = SpTestDataFactory.generateUpdateShipmentResponse();
        SpUpdateShipmentReqDtoAup spUpdateShipment;

        Test.startTest();
            spUpdateShipment = SpUpdateShipmentReqDtoAup.parse(json);
        Test.stopTest();
        
        System.assert(spUpdateShipment != null, 'No instance of SpUpdateShipmentReqDtoAup is found.');
    }

}