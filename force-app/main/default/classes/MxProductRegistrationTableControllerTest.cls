/**
 * @author                          Kristopher Veraces
 * @date                            2021-06-14
 */
@isTest
private class MxProductRegistrationTableControllerTest {
    private static final Integer MAX_COUNT = 10;

    @testSetup
    private static void makeData(){
        List<Product2> products = getProducts(MAX_COUNT);
        insert products;

        List<MX_Serial_Numbers__c> serialNumbers = getSerialNumbers(products);
        insert serialNumbers;
    }

    @isTest
    private static void getProductInformationTest() {
        String result;
        Test.startTest();
            result = MxProductRegistrationTableController.getProductInformation();
        Test.stopTest();
        List<Product2> products = (List<Product2>)JSON.deserialize(result, List<Product2>.class);
        System.assert(!products.isEmpty(), 'Failed to get mx product information');
        System.assertEquals(MAX_COUNT, products.size(), 'Failed to get all mx product information');
    }

    @isTest
    private static void getSerialNumberInformationTest() {
        String result;
        List<Product2> products = [SELECT Id, ProductCode FROM Product2];
        Set<String> serialNumbers = new Set<String>();
        for (Product2 product : products) {
            String serialNumber = product.ProductCode + '-XXXX';
            serialNumbers.add(serialNumber);
        }

        Test.startTest();
            result = MxProductRegistrationTableController.getSerialNumberInformation(JSON.serialize(serialNumbers));
        Test.stopTest();

        Map<String, List<MX_Serial_Numbers__c>> formattedResults = (Map<String, List<MX_Serial_Numbers__c>>)JSON.deserialize(result, Map<String, List<MX_Serial_Numbers__c>>.class);
        System.assert(!formattedResults.isEmpty(), 'Failed fetch serial numbers');
    }

    private static List<Product2> getProducts(Integer size) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < size; i++) {
            products.add(getProduct(i));
        }
        return products;
    }

    private static Product2 getProduct(Integer identifier) {
        return new Product2(
            Name = 'Demo Product: ' + identifier,
            ProductCode = 'XXXX' + identifier,
            SAP_MaterialNumber__c = 'XXXX' + identifier,
            SAP_Material_Group__c = 'MQ-TL',
            AU_MRPty__c = 'ZD',
            NZ_MRPty__c = 'ZD'
        );
    }

    private static List<MX_Serial_Numbers__c> getSerialNumbers(List<Product2> products) {
        List<MX_Serial_Numbers__c> serialNumbers = new List<MX_Serial_Numbers__c>();
        for (Product2 product : products) {
            serialNumbers.add(getSerialNumber(product));
        }
        return serialNumbers;
    }

    private static MX_Serial_Numbers__c getSerialNumber(Product2 product) {
        String identifier = product.ProductCode + '-XXXX';
        return new MX_Serial_Numbers__c(
            MX_Product__c = product.Id,
            Serial_Number__c = identifier,
            Status__c = 'Available',
            Unique_Id__c = identifier
        );
    }
}