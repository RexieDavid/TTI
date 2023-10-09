@isTest
private class MxProductRegistrationControllerTest {
    private static final String ACCOUNT_PERSON_EMAIL = 'demo@milwakee.com';
    private static final Integer MAX_COUNT = 10;

    @testSetup
    private static void makeData(){
        List<Product2> products = getProducts();
        insert products;

        List<MX_Serial_Numbers__c> serialNumbers = getSerialNumbers(products);
        insert serialNumbers;
    }


    @isTest
    private static void registerWithNewAccountTest() {
        String payload = getPayload();
        Test.startTest();
            MxProductRegistrationController.register(payload);
        Test.stopTest();
        assertRegistration();
    }

    @isTest
    private static void registerWithExistingAccountTest() {
        Account account =  fetchAccount();
        insert account;

        String payload = getPayload();
        Test.startTest();
            MxProductRegistrationController.register(payload);
        Test.stopTest();
        assertRegistration();
    }

    private static void assertRegistration() {
        List<Account> accounts = [SELECT Id FROM Account WHERE PersonEmail = :ACCOUNT_PERSON_EMAIL];
        List<MX_Fuel_Registration__c> registrations = [SELECT Id 
                                                       FROM MX_Fuel_Registration__c 
                                                       WHERE Customer_Account__c IN :accounts];
        List<MX_Fuel_Registration_Product__c> products = [SELECT Id 
                                                          FROM MX_Fuel_Registration_Product__c 
                                                          WHERE MX_Fuel_Registration__c IN :registrations];
        List<MX_Serial_Numbers__c> consumedSerialNumbers = [SELECT Id
                                                            FROM MX_Serial_Numbers__c
                                                            WHERE Status__c = 'Consumed'];
        Map<Id, Boolean> results = Approval.isLocked(registrations);
        System.assert(!accounts.isEmpty(), 'Failed to create person account');
        System.assertEquals(1, accounts.size(), 'Created duplicate account with same email');
        System.assert(!registrations.isEmpty(), 'Failed to create mx fuel registrations');
        System.assert(!products.isEmpty(), 'Failed to create mx fuel registration products');
        System.assert(!consumedSerialNumbers.isEmpty(), 'Failed to update status of consumed serial numbers');
        for (Boolean isLocked : results.values()) {
            System.assert(isLocked, 'Failed to submit record to approval process');
        }
    }


    private static List<Product2> getProducts() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < MAX_COUNT; i++) {
            products.add(getProduct(i));
        }
        return products;
    }

    private static Product2 getProduct(Integer identifier) {
        return new Product2(
            Name = 'Demo Product: ' + identifier,
            ProductCode = 'XXXX' + identifier,
            SAP_MaterialNumber__c = 'XXXX' + identifier,
            SAP_Material_Group__c = 'MQ-TL'
        );
    }

    private static List<MX_Serial_Numbers__c> getSerialNumbers(List<Product2> products) {
        List<MX_Serial_Numbers__c> serialNumbers = new List<MX_Serial_Numbers__c>();
        for (Integer i = 0; i < MAX_COUNT; i++) {
            serialNumbers.add(getSerialNumber(i, products[i].Id));
        }
        return serialNumbers;
    } 

    private static MX_Serial_Numbers__c getSerialNumber(Integer identifier, sTRING productId) {
        return new MX_Serial_Numbers__c(
            MX_Product__c = productId,
            Serial_Number__c = 'XXXX' + identifier,
            Status__c = 'Available',
            Unique_Id__c = String.valueOf(System.now().getTime()) + identifier
        );
    }

    private static String getPayload() {
        MxProductRegistrationController.MxRegistrationDetails data = new MxProductRegistrationController.MxRegistrationDetails();
        data.externalId = String.valueOf(System.now().getTime());
        data.account = fetchAccount();
        data.registration = fetchRegistration();
        data.products = fetchRegisteredProducts();
        data.consumedSerialNumbers = fetchConsumedSerialNumbers();
        return JSON.serialize(data);
    }

    private static Account fetchAccount() {
        return new Account(
            FirstName = 'Demo',
            LastName = 'Account',
            Brand__pc = 'Milwaukee',
            PersonEmail = ACCOUNT_PERSON_EMAIL
        );
    }

    private static MX_Fuel_Registration__c fetchRegistration() {
        return new MX_Fuel_Registration__c(
            Status__c = 'Submitted',
            Sales_Rep_Name__c = 'Demo Salse Rep',
            Receipt_Invoice_Number__c = 'XXXXX'
        );
    }

    private static List<MX_Fuel_Registration_Product__c> fetchRegisteredProducts() {
        List<Product2> products = [SELECT Id FROM Product2 WHERE CreatedDate = TODAY];
        List<MX_Fuel_Registration_Product__c> registeredProducts = new List<MX_Fuel_Registration_Product__c>();
        for (Integer i = 0; i < products.size(); i++) {
            registeredProducts.add(fetchRegisteredProduct(i, products[i].Id));
        }
        return registeredProducts;
    }

    private static MX_Fuel_Registration_Product__c fetchRegisteredProduct(Integer identifier, String productId) {
        return new MX_Fuel_Registration_Product__c(
            MX_Fuel_Product__c = productId,
            Serial_Number_Status__c = 'Serial Number OK',
            Serial_Number__c = 'XXXX' + identifier
        );
    }

    private static Set<String> fetchConsumedSerialNumbers() {
        Set<String> ids = new Set<String>();
        for (MX_Serial_Numbers__c serialNumber : [SELECT Id 
                                                  FROM MX_Serial_Numbers__c 
                                                  WHERE CreatedDate = TODAY]) {
            ids.add(serialNumber.Id);
        }
        return ids;
    }
}