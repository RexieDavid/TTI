public class RCTIInvoiceUploadReadyTriggerHandler extends TriggerHandler {

    /**
     * @description                 Run after insert trigger
     */
    public override void afterInsert() {
        List<RCTI_Invoice_Upload_Ready__e> logs = (List<RCTI_Invoice_Upload_Ready__e>) Trigger.new;
        this.countPlatformEventService(logs);
    }

    /**
     * @description                 Count published cloud storage log events
     * 
     * @param logs                  List of published Cloud_Storage_Log__e records
     */
    private void countPlatformEventService(List<RCTI_Invoice_Upload_Ready__e> logs) {
        new CountPlatformEventService()
            .setDescribeObjectResult(RCTI_Invoice_Upload_Ready__e.sObjectType.getDescribe())
            .run(logs);
    }
}