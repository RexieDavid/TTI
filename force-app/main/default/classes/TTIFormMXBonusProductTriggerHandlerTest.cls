@isTest
private class TTIFormMXBonusProductTriggerHandlerTest {
    private static final Integer MAX_RECORDS = 3;
    private static final String MX_BONUS_PRODUCT_RECORDTYPE = 'MX_Bonus_Product';

    @TestSetup
    private static void makeData() {
        insert getMXRegistrations();
    }

    @isTest
    private static void insertTTIFormWithoutMatchMXRegistration() {
        Test.startTest();
            disableTriggers();
            insert getTTIForms('XXXX');
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(forms.isEmpty(), 'Linked random mx registration to the MX Bonus Form');
    }

    @isTest
    private static void insertTTIFormWithMXRegistration() {
        Test.startTest();
            disableTriggers();
            insert getTTIForms('0000');
        Test.stopTest();
        List<TTI_Form__c> forms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(!forms.isEmpty(), 'Failed to link correct mx registration');
    }

    @isTest
    private static void UPDATETTIFormWithMXRegistration() {
        Integer counter = 0;
        disableTriggers();
        List<TTI_Form__c> forms = getTTIForms('XXXX');
        insert forms;
        Test.startTest();
            TTIFormMXBonusProduct.processedForms.clear();
            for (TTI_Form__c form: forms) {
                form.ReceiptInvoiceNumber__c = '0000' + counter;
                counter++;
            }
            disableTriggers();
            update forms;
        Test.stopTest();
        List<TTI_Form__c> updateForms = [SELECT Id FROM TTI_Form__c WHERE MXFuelRegistration__c != NULL];
        System.assert(!updateForms.isEmpty(), 'Failed to link correct mx registration');
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

    private static List<TTI_Form__c> getTTIForms(String receiptPrefix) {
        String recordtypeId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByDeveloperName().get(MX_BONUS_PRODUCT_RECORDTYPE).getRecordTypeId();
        List<TTI_Form__c> ttiForms = new List<TTI_Form__c>();
        for (Integer i = 0; i < MAX_RECORDS; i++) {
            ttiForms.add(getTTIForm(recordtypeId, receiptPrefix + i));
        }
        return ttiForms;
    }

    private static TTI_Form__c getTTIForm(String recordtypeId, String receiptNumber) {
        return new TTI_Form__c(
            Purpose_of_order__c = 'Direct Marketing',
            Required_by_date__c = System.today(),
            RecordTypeId = recordtypeId,
            Cost_Centre__c = null,
            ReceiptInvoiceNumber__c = receiptNumber
        );
    }

    private static void disableTriggers() {
        TTIFormTriggerHandler.runAssignDeliveryAddressOnce = true;
        TTIFormTriggerHandler.assignApproverAndAccountsOnce = true;
    }
}