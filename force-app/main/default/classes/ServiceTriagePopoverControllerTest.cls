/**
* @author           Francis Nasalita
* @date             2021-04-27
* @description      Service Triage Popover Controller Test
*/
@isTest
public with sharing class ServiceTriagePopoverControllerTest {

    public static final String DESCRIPTION = 'Test Description';
    public static final String SUBJECT = 'Test Subject';
    private static final Integer CASE_COUNT = 1;

    @TestSetup
    static void makeData() {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            createCases(CASE_COUNT);
        }
    }

    @IsTest
    static void testGetCaseRecord() {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        
        Test.startTest();
            ServiceTriagePopoverController.getCaseRecord(caseId);
        Test.stopTest();
        
    }
    
    private static void createCases(Integer count) {
        List<Case> cases = new List<Case>();
        Id serviceReqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();

        for (Integer i = 0; i < count; i++) {
            cases.add(new Case(
                recordTypeId = serviceReqRTId,
                Description = DESCRIPTION,
                Subject = SUBJECT
            ));
        }

        insert cases;
    }
}