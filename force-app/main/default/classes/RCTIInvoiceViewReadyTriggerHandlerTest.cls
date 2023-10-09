@isTest
private class RCTIInvoiceViewReadyTriggerHandlerTest {

     /**
     * @description                 Bulk publish Invoice View Ready events
     */
    @isTest
    private static void publishInvoiceViewReadyEvent() {
        List<Database.SaveResult> result;
        Test.startTest();
            result = EventBus.publish(fetchEvents());
        Test.stopTest();
        System.assert(isSuccess(result), 'Error publishing platform events');
    }

    /**
     * @description                 Fetch logs to publish
     * 
     * @return                      RCTI Invoice View Ready events
     */
    private static List<RCTI_Invoice_View_Ready__e> fetchEvents() {
        List<RCTI_Invoice_View_Ready__e> events = new List<RCTI_Invoice_View_Ready__e>();
        for (Integer i = 0; i < 20; i++) {
            events.add(new RCTI_Invoice_View_Ready__e(
                Case_Number__c = '0000' + i
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