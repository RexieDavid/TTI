/**
* @author           Regine Paredes
* @date             2022-10-28
* @description      Off Location Product Search Controller Test 
*/
@isTest
public class OffLocationProdSearchControllerTest {

    @IsTest
    static void testGetSAPMaterialGroups() {
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
            OffLocationProdSearchController.getSAPMaterialGroups();
        Test.stopTest();
        
    }
    
    @isTest
    static void testgetProductByBarcode() {
        List<String> fields = new List<String>{'SAP_MaterialNumber__c'};
        String exp = 'WHERE Sales_Transaction_Flow_Supported__c = true';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
            List<sObject> productList = OffLocationProdSearchController.getProductByBarcode(fields, exp);
        Test.stopTest();
        
        System.assertNotEquals(null, productList);
    }
}