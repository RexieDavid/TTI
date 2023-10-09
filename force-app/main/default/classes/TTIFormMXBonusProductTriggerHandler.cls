public class TTIFormMXBonusProductTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        this.matchMXFuelRegistration();
    }

    public override void afterUpdate() {
        this.matchMXFuelRegistration();
    }

    /**
     * @description                 Match TTI Form and MX Fuel Registration
     */
    private void matchMXFuelRegistration() {
        Set<String> receipts = new Set<String>();
        Map<Id, TTI_Form__c> old = (Map<Id, TTI_Form__c>)Trigger.oldMap;
        for (TTI_Form__c form : (List<TTI_Form__c>)Trigger.new) {
            if (String.isNotBlank(form.ReceiptInvoiceNumber__c) &&
                (old == null || form.ReceiptInvoiceNumber__c != old.get(form.Id).ReceiptInvoiceNumber__c)) {
                receipts.add(form.ReceiptInvoiceNumber__c);
            }
        }
        if (!receipts.isEmpty()) {
            new TTIFormMXBonusProduct(receipts)
                .match();
        }
    }
}