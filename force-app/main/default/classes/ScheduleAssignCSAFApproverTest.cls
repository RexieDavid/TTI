/**
 * @author:                         Ericka Jan Cajucom
 * @date:                           2021-03-26
 */
@isTest
public class ScheduleAssignCSAFApproverTest {

    /**********************************************************************
     * @description             Schedule job every day at 5am
     */
    static testMethod void scheduleJob() {
        Test.startTest();    
        ScheduleAssignCSAFApprover scheduler = new ScheduleAssignCSAFApprover();
        String cron = '0 0 05 * * ?'; 
        System.schedule('Test Schedule Assign CSAF Approver batch', cron, scheduler); 
        Test.stopTest();
    }
}