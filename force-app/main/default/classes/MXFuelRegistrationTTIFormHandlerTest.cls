@isTest
private class MXFuelRegistrationTTIFormHandlerTest {
    private static final Integer MAX_RECORDS = 3;
    private static final String MX_BONUS_PRODUCT_RECORDTYPE = 'MX_Bonus_Product';

    @TestSetup
    private static void makeData() {
        disableTriggers();
        insert getTTIForms();
    }

    @isTest
    private static void insertMXRegistrationWithoutMatchForms() {
        Test.startTest();
            insert getMXRegistrations('XXXX');
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(forms.isEmpty(), 'Linked random mx registration to the MX Bonus Form');
    }

    @isTest
    private static void insertMXRegistrationWithMatchForms() {
        Test.startTest();
            insert getMXRegistrations('0000');
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(!forms.isEmpty(), 'Failed to link correct mx registration');
    }

    @isTest
    private static void updateMXRegistrationWithMatchForms() {
        Integer counter = 0;
        List<MX_Fuel_Registration__c> registrations = getMXRegistrations('XXXX');
        insert registrations;
        Test.startTest();
            MXFuelRegistrationTTIFormHandler.hasBeenRun_After.clear();
            for (MX_Fuel_Registration__c registration : registrations) {
                registration.Receipt_Invoice_Number__c = '0000' + counter;
                counter++;
            }
            update registrations;
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(!forms.isEmpty(), 'Failed to link correct mx registration');
    }

    private static List<MX_Fuel_Registration__c> getMXRegistrations(String receitPrefix) {
        List<MX_Fuel_Registration__c> registrations = new List<MX_Fuel_Registration__c>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
            registrations.add(getRegistration(receitPrefix + i));
        }
        return registrations;
    }

    private static MX_Fuel_Registration__c getRegistration(String receiptNumber) {
        return new MX_Fuel_Registration__c(
            Status__c = 'Submitted',
            Sales_Rep_Name__c = 'Demo Salse Rep',
            Receipt_Invoice_Number__c = receiptNumber
        );
    }

    private static List<TTI_Form__c> getTTIForms() {
        String recordtypeId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByDeveloperName().get(MX_BONUS_PRODUCT_RECORDTYPE).getRecordTypeId();
        List<TTI_Form__c> ttiForms = new List<TTI_Form__c>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
            ttiForms.add(getTTIForm(recordtypeId, i));
        }
        return ttiForms;
    }

    private static TTI_Form__c getTTIForm(String recordtypeId, Integer uniqueId) {
        return new TTI_Form__c(
            Purpose_of_order__c = 'Direct Marketing',
            Required_by_date__c = System.today(),
            RecordTypeId = recordtypeId,
            Cost_Centre__c = null,
            ReceiptInvoiceNumber__c = '0000' + uniqueId
        );
    }

    private static void disableTriggers() {
        TTIFormTriggerHandler.runAssignDeliveryAddressOnce = true;
        TTIFormTriggerHandler.assignApproverAndAccountsOnce = true;
    }
}