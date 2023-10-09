@isTest
private class RCTIInvoiceUploadReadyTriggerHandlerTest {
    /**
     * @description                 Bulk publish Invoice Upload Ready events
     */
    @isTest
    private static void publishInvoiceUploadReadyEvent() {
        List<Database.SaveResult> result;
        Test.startTest();
            result = EventBus.publish(fetchEvents());
        Test.stopTest();
        System.assert(isSuccess(result), 'Error publishing platform events');
    }

    /**
     * @description                 Fetch logs to publish
     * 
     * @return                      Invoice upload ready events
     */
    private static List<RCTI_Invoice_Upload_Ready__e> fetchEvents() {
        List<RCTI_Invoice_Upload_Ready__e> events = new List<RCTI_Invoice_Upload_Ready__e>();
        for (Integer i = 0; i < 20; i++) {
            events.add(new RCTI_Invoice_Upload_Ready__e(
                Document_Identifier__c = 'id-' + i,
                Storage_Specific_Attributes__c = 'storage specific attribute -' + i
            ));
        }
        return events;
    }

    private static Boolean isSuccess(List<Database.SaveResult> result) {
        Boolean isSuccess = true;
        for (Database.SaveResult sr : result) {
            if (!sr.isSuccess()) {
                isSuccess = sr.isSuccess();
                break;
            }
        }
        return isSuccess;
    }
}