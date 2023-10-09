public class MXFuelRegistrationTTIFormHandler extends TriggerHandler {
    // Trigger recursion checker
    @TestVisible
    private static Set<String> hasBeenRun_After = new Set<String>();

    public override void afterInsert() {
        this.matchMXBonusTTIForms();
    }

    public override void afterUpdate() {
        this.matchMXBonusTTIForms();
    }

    /**
     * @description                 Match MX Fuel Registration with
     *                              MX Bonus Product TTI Form
     */
    private void matchMXBonusTTIForms() {
        Set<String> receipts = new Set<String>();
        receipts.addAll(this.fetchReceiptNumbers(Trigger.new));
        if (Trigger.oldMap != null) {
            receipts.addAll(this.fetchReceiptNumbers(Trigger.oldMap.values()));
        }
        updateTTIForms(receipts);
    }

    /**
     * @description                 Fetch receipt numbers of mx fuel registrations
     */
    private Set<String> fetchReceiptNumbers(List<MX_Fuel_Registration__c> registrations) {
        Set<String> receipts = new Set<String>();
        for (MX_Fuel_Registration__c registration : registrations) {
            if (!hasBeenRun_After.contains(registration.Id)) {
                if (String.isNotBlank(registration.Receipt_Invoice_Number__c)) {
                    receipts.add(registration.Receipt_Invoice_Number__c);
                }
                hasBeenRun_After.add(registration.Id);
            }
        }
        return receipts;
    }

    /**
     * @description                 Update MX Bonus Product TTI Form
     *
     * @param receipts              Receipt numbers 
     * 
     * @Notes                       Set to @future to give way for the
     *                              MX Products to be created and linked 
     *                              to MX Registration
     */
    @Future
    private static void updateTTIForms(Set<String> receipts) {
        if (!receipts.isEmpty()) {
            new TTIFormMXBonusProduct(receipts)
                .match();
        }
    }
}