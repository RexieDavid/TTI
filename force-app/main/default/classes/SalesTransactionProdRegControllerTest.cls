/**
* @author           Francis Nasalita
* @date             2021-03-10
* @description      Sales transaction Product Registration Controller Test
*/
@isTest
public class SalesTransactionProdRegControllerTest {

    @IsTest
    static void testGetSAPMaterialGroups() {
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
            SalesTransactionProdRegController.getSAPMaterialGroups();
        Test.stopTest();
        
    }
}