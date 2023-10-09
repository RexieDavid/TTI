/**
* @author           Francis Nasalita
* @date             2020-10-16
* @description      Test class for SpRctiGenerationTriggerHandler
*/
@IsTest
public with sharing class SpRctiGenerationTriggerHandlerTest {

    @IsTest
    static void testPdfGeneration() {

        Test.startTest();

            Id rtServiceAgent = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service_Agent').getRecordTypeId();
            Account acct = new Account();
            acct.Name = 'Test Acct';
            acct.Internal_Service_Agent__c = false;
            acct.RecordtypeId = rtServiceAgent;
            acct.Company_Code__c = 'BP01';
            insert acct;

            Id rtServiceRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
            List<Case> cases = new List<Case>();
            for (Integer ctr = 0; ctr < 50; ctr++) {
                cases.add(new Case(
                    AccountId = acct.Id,
                    RecordTypeId = rtServiceRequest,
                    Service_Request_Milestone__c = 'Closed',
                    Status = 'Closed',
                    Invoice_Number_PC__c = '088-2011-000' + String.valueOf(ctr)
                ));
            }
            insert cases;

            Set<Id> caseIds = new Map<Id, Case>(cases).keySet();
            cases.clear();

            Map<Id, Case> oldMap = new Map<Id, Case>();
            for(Case c : [SELECT Invoice_Number_PC__c, Ready_for_RCTI_Processing__c FROM Case WHERE Id IN :caseIds]) {
                cases.add(c);

                Case cl = c.clone(true, true, true, true);
                cl.Invoice_Number_PC__c = 'dummy';
                oldMap.put(cl.Id, cl);
            }

            new SpRctiGenerationTriggerHandler(cases, oldMap).afterUpdate();
        Test.stopTest();


        List<ContentDocumentLink> docs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :oldMap.keySet()];

        System.assert(!docs.isEmpty(), 'No documents are created.');
    }

    private static List<Case> createServiceRequest(Integer count, Account parentAccount) {
        Id rtServiceRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        List<Case> cases = new List<Case>();
        
        for (Integer ctr = 0; ctr < count; ctr++) {
            cases.add(new Case(
                AccountId = parentAccount.Id,
                RecordTypeId = rtServiceRequest,
                Service_Request_Milestone__c = 'Closed',
                Status = 'Closed'
            ));
        }

        return cases;
    }
}