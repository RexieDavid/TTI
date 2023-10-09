/**
 * @author:                         Ericka Jan Cajucom
 * @date:                           2021-03-26
 */
global class ScheduleAssignCSAFApprover implements Schedulable {
    
    /**********************************************************************
     * @description             Scheduler for BatchAssignCSAFApprover
     */
    global void execute(SchedulableContext sc) {
        BatchAssignCSAFApprover batch = new BatchAssignCSAFApprover();
        database.executebatch(batch);
    }
}