@isTest
private class TTIFormMXBonusProductTest {
    private static final Integer MAX_RECORDS = 3;
    private static final String MX_BONUS_PRODUCT_RECORDTYPE = 'MX_Bonus_Product';

    @TestSetup
    private static void init() {
        disableTriggers();

        List<Product2> products = getProducts();
        insert products;

        List<MX_Fuel_Registration__c> registrations = getMXRegistrations();
        insert registrations;

        List<MX_Fuel_Registration_Product__c> registeredProducts = new List<MX_Fuel_Registration_Product__c>();
        for (MX_Fuel_Registration__c registration : registrations) {
            registeredProducts.addAll(getRegisteredProducts(products, registration.Id));
        }
        insert registeredProducts;
        insert getTTIForms();
    }

    @isTest
    private static void matchFormsWithNullReceipts() {
        updateTTIFormReceipts();
        Test.startTest();
            matchForms(null);
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(forms.isEmpty(), 'Linked wrong mx registration');
    }

    @isTest
    private static void matchFormsWithInvalidReceipts() {
        Set<String> receipts = new Set<String>{ 'XXXX1', 'XXXX2', 'XXXX3' };
        updateTTIFormReceipts();
        Test.startTest();
            matchForms(receipts);
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(forms.isEmpty(), 'Linked wrong mx registration');
    }

    @isTest
    private static void matchFormsWithValidReceipts() {
        Set<String> receipts = new Set<String>{ '00000', '00001', '00002' };
        updateTTIFormReceipts();
        Test.startTest();
            matchForms(receipts);
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(!forms.isEmpty(), 'Failed to link mx registration');
    }

    private static List<Product2> getProducts() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
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

    private static List<TTI_Form__c> getTTIForms() {
        String recordtypeId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByDeveloperName().get(MX_BONUS_PRODUCT_RECORDTYPE).getRecordTypeId();
        List<TTI_Form__c> ttiForms = new List<TTI_Form__c>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
            ttiForms.add(getTTIForm(recordtypeId));
        }
        return ttiForms;
    }

    private static TTI_Form__c getTTIForm(String recordtypeId) {
        return new TTI_Form__c(
            Purpose_of_order__c = 'Direct Marketing',
            Required_by_date__c = System.today(),
            RecordTypeId = recordtypeId,
            Cost_Centre__c = null
        );
    }

    private static List<MX_Fuel_Registration__c> getMXRegistrations() {
        List<MX_Fuel_Registration__c> registrations = new List<MX_Fuel_Registration__c>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
            registrations.add(getRegistration(i));
        }
        return registrations;
    }

    private static MX_Fuel_Registration__c getRegistration(Integer uniqueId) {
        return new MX_Fuel_Registration__c(
            Status__c = 'Submitted',
            Sales_Rep_Name__c = 'Demo Salse Rep',
            Receipt_Invoice_Number__c = '0000' + uniqueId
        );
    }

    private static List<MX_Fuel_Registration_Product__c> getRegisteredProducts(List<Product2> products, String parentId) {
        List<MX_Fuel_Registration_Product__c> registeredProducts = new List<MX_Fuel_Registration_Product__c>();
        for (Integer i = 0; i < products.size(); i++) {
            registeredProducts.add(getRegisteredProduct(i, products[i].Id, parentId));
        }
        return registeredProducts;
    }

    private static MX_Fuel_Registration_Product__c getRegisteredProduct(Integer identifier, String productId, String parentId) {
        return new MX_Fuel_Registration_Product__c(
            MX_Fuel_Product__c = productId,
            Serial_Number_Status__c = 'Serial Number OK',
            Serial_Number__c = 'XXXX' + identifier,
            MX_Fuel_Registration__c = parentId
        );
    }

    private static void updateTTIFormReceipts() {
        disableTriggers();
        Set<String> recordIds = new Set<String>();
        List<TTI_Form__c> forms = [SELECT Id, ReceiptInvoiceNumber__c FROM TTI_Form__c];
        for (Integer i = 0; i < forms.size(); i++) {
            recordIds.add(forms[i].Id);
            forms[i].ReceiptInvoiceNumber__c = '0000' + i;
        }
        TTIFormMXBonusProduct.processedForms.addAll(recordIds);
        update forms;
    }

    private static void disableTriggers() {
        TTIFormTriggerHandler.runAssignDeliveryAddressOnce = true;
        TTIFormTriggerHandler.assignApproverAndAccountsOnce = true;
    }

    private static void matchForms(Set<String> receipts) {
        TTIFormMXBonusProduct.processedForms.clear();
        new TTIFormMXBonusProduct(receipts)
            .match();
    }
}