public without sharing class TTIFormMXBonusProduct {
    // For recursion
    @TestVisible
    private static Set<String> processedForms = new Set<String>();
    private final String MX_BONUS_PRODUCT_RECORDTYPE = 'MX_Bonus_Product';
    private Set<String> receipts;

    /**
     * @description                 Main Constructor
     *
     * @param receipts              Collection of receipt numbers
     */
    public TTIFormMXBonusProduct(Set<String> receipts) {
        this.receipts = receipts == null ? new Set<String>() : receipts;
    }

    /**
     * @description                 Main class entry point
     */
    public void match() {
        List<TTI_Form__c> forms = this.fetchForms();
        if (!forms.isEmpty()) {
            List<TTI_Form_Product__c> newProducts = new List<TTI_Form_Product__c>();
            List<TTI_Form_Product__c> oldProducts = new List<TTI_Form_Product__c>();
            Map<String, MX_Fuel_Registration__c> mxRegistrations = this.fetchMXRegistration();
            for (TTI_Form__c form : forms) {
                processedForms.add(form.Id);
                MX_Fuel_Registration__c registration = this.fetchMatchMXRegistration(form.ReceiptInvoiceNumber__c, mxRegistrations);
                this.updateFormDetails(form, registration);
                newProducts.addAll(this.createFormProducts(form.Id, registration));
                oldProducts.addAll(form.TTI_Form_Products__r);
            }
            this.save(forms, newProducts, oldProducts);
        }
    }

    /**
     * @description                 Retrieve MX Bonus TTI Forms that has receipt numbers
     *
     * @return                      MX Bonus TTI Form records
     */
    private List<TTI_Form__c> fetchForms() {
        return [SELECT Id,
                       ReceiptInvoiceNumber__c,
                       MXFuelRegistration__c,
                       Customer_Name__c,
                       Delivery_Street__c,
                       Delivery_Suburb__c,
                       Delivery_State__c,
                       Delivery_Postcode__c,
                       Delivery_Country__c,
                       Account__c,
                       (SELECT Id FROM TTI_Form_Products__r)
                FROM TTI_Form__c
                WHERE ReceiptInvoiceNumber__c IN :this.receipts
                AND RecordType.DeveloperName = :this.MX_BONUS_PRODUCT_RECORDTYPE
                AND Id NOT IN :processedForms];
    }

    /**
     * @description                 Retrieve MX Fuel Registration details along
     *                              with its products
     *
     * @return                      Map of Receipt number and MX Fuel Registration
     */
    private Map<String, MX_Fuel_Registration__c> fetchMXRegistration() {
        Map<String, MX_Fuel_Registration__c> registrations = new Map<String, MX_Fuel_Registration__c>();
        for (MX_Fuel_Registration__c mxRegistration : [SELECT Id,
                                                              Customer_Account__c,
                                                              Customer_Account__r.PersonMailingStreet,
                                                              Customer_Account__r.PersonMailingState,
                                                              Customer_Account__r.PersonMailingCity,
                                                              Customer_Account__r.PersonMailingPostalCode,
                                                              Customer_Account__r.PersonMailingCountry,
                                                              Receipt_Invoice_Number__c,
                                                              (SELECT Id,
                                                                      MX_Fuel_Product__c
                                                              FROM MX_Fuel_Registration_Products__r)
                                                      FROM MX_Fuel_Registration__c]) {
            registrations.put(mxRegistration.Receipt_Invoice_Number__c, mxRegistration);
        }
        return registrations;
    }

    /**
     * @description                 Retrieve MX Fuel Registration with specific receipt number
     *
     * @param receipt               Receipt number
     * @param mxRegistrations       Collection of MX Fuel Registrations
     *
     * @return                      Match MX Fuel Registration record
     */
    private MX_Fuel_Registration__c fetchMatchMXRegistration(String receipt, Map<String, MX_Fuel_Registration__c> mxRegistrations) {
        Boolean hasMatch = mxRegistrations.containsKey(receipt);
        return hasMatch ? mxRegistrations.get(receipt) : new MX_Fuel_Registration__c();
    }

    /**
     * @description                 Retrieve MX Fuel Registration with specific receipt number
     *
     * @param receipt               Receipt number
     * @param mxRegistrations       Collection of MX Fuel Registrations
     */
    private void updateFormDetails(TTI_Form__c form, MX_Fuel_Registration__c registration) {
        form.MXFuelRegistration__c = registration.Id;
        form.Customer_Name__c = registration.Customer_Account__c;
        form.Delivery_Street__c = registration.Customer_Account__r.PersonMailingStreet;
        form.Delivery_Suburb__c = registration.Customer_Account__r.PersonMailingCity;
        form.Delivery_State__c = registration.Customer_Account__r.PersonMailingState;
        form.Delivery_Postcode__c = registration.Customer_Account__r.PersonMailingPostalCode;
        form.Delivery_Country__c = registration.Customer_Account__r.PersonMailingCountry;
    }

    /**
     * @description                 Create TTI Form Products for the TTI Form record
     *
     * @param formId                TTI Form Record Id
     * @param registration          MX Fuel Registration details
     *
     * @return                      List of TTI Form Products
     */
    private List<TTI_Form_Product__c> createFormProducts(String formId, MX_Fuel_Registration__c registration) {
        List<TTI_Form_Product__c> products = new List<TTI_Form_Product__c>();
        for (MX_Fuel_Registration_Product__c product : registration.MX_Fuel_Registration_Products__r) {
            products.add(this.createFormProduct(formId, product));
        }
        return products;
    }

    /**
     * @description                 Build raw TTI Form Product record
     *
     * @param formId                TTI Form Record Id
     * @param product               MX Fuel Registration Product details
     *
     * @return                      Raw TTI Form Product
     */
    private TTI_Form_Product__c createFormProduct(String formId, MX_Fuel_Registration_Product__c product) {
        return new TTI_Form_Product__c(
            Form_Number__c = formId,
            SAP_Material_Number__c = product.MX_Fuel_Product__c,
            Quantity__c = 1
        );
    }

    /**
     * @description                 Main method for commiting changes to database. Will perform
     *                              the following operations:
     *                                  - Update of TTI Form record
     *                                  - Insert of TTI Form products
     *                                  - Delete of old TTI Form Products (in case the receipt number is changed)
     *
     * @param forms                 List of TTI Forms to be updated
     * @param newProducts           List of new TTI Form products to be insertd
     * @param oldProducts           List of old TTI Form PRoducts to be removed/deleted
     */
    private void save(List<TTI_Form__c> forms, List<TTI_Form_Product__c> newProducts, List<TTI_Form_Product__c> oldProducts) {
        this.bypassTTIFormTrigger();
        Savepoint sp = Database.setSavepoint();
        try {
            update forms;
            if (!newProducts.isEmpty()) {
                insert newProducts;
            }

            if (!oldProducts.isEmpty()) {
                delete oldProducts;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new TTIFormMXBonusProductException(Label.Generic_Error_Message);
        }
    }

    /**
     * @description                 Bypass some of the TTI Form trigger methods
     */
    private void bypassTTIFormTrigger() {
        // Disable assign of approver and accounts
        TTIFormTriggerHandler.runAssignDeliveryAddressOnce = true;
        TTIFormTriggerHandler.assignApproverAndAccountsOnce = true;
    }

    private class TTIFormMXBonusProductException extends Exception {}
}