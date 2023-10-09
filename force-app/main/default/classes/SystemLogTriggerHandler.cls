/**
* @author Samuel Oberes
* @date 2020-09-24
*
* @description The handler for the platform event SystemLogTrigger
*/
public class SystemLogTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        // TODO: bulkify
        // for (System_Log__e log : (List<System_Log__e>) Trigger.new)  {
        //     SystemLogOrchestration slo = new SystemLogOrchestration();
        //     slo.run(log.Level__c, log.Payload__c);
        // }
        this.countPlatformEventService(Trigger.new);
    }

    /**
     * @description                 Count published system log events
     * 
     * @param logs                  List of published System_Log__e records
     */
    private void countPlatformEventService(List<System_Log__e> logs) {
        new CountPlatformEventService()
            .setDescribeObjectResult(System_Log__e.sObjectType.getDescribe())
            .run(logs);
    }

}