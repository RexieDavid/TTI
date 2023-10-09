/**
* @author                Samuel Oberes
* @date                  2020-03-11
* @description           Test class for SpRctiGenerationService
*/
@IsTest
public with sharing class SpRctiGenerationServiceTest {

    @TestSetup
    private static void makeData() {

        Id rtServiceAgent = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service_Agent').getRecordTypeId();
        Account acct = new Account();
        acct.Name = 'Test Acct';
        acct.Internal_Service_Agent__c = false;
        acct.RecordtypeId = rtServiceAgent;
        insert acct;

        List<Case> cases = createServiceRequest(50, acct);
        insert cases;
    }

    @IsTest
    private static void testStart() {
        Id rtServiceRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();

        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = new Case(
            AccountId = a.Id,
            RecordTypeId = rtServiceRequest,
            Service_Request_Milestone__c = 'Closed',
            Status = 'Closed',
            Invoice_Number_PC__c = 'testInvoiceNumber'
        );
        insert c;

        Test.startTest();
            SpRctiGenerationService.start(new Set<Id> { c.Id });
        Test.stopTest();
        

        List<ContentDocumentLink> docs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];

        System.assertEquals(1, docs.size(), 'No documents are created.');
    }

    @IsTest
    private static void testBuildPdf() {

        Case claim = [SELECT Id, CaseNumber, Invoice_Number_PC__c FROM Case LIMIT 1];
        claim.Invoice_Number_PC__c = 'testinvoice';

        String title = claim.CaseNumber + '-RCTI(' + claim.Invoice_Number_PC__c + ')';
        String pathOnClient = 'file.pdf';
        Blob versionData = Blob.valueOf('Test Data');
        String origin = 'H';

        ContentVersion cv = new ContentVersion();
        Test.startTest();
            cv = SpRctiGenerationService.buildPdf(claim);
        Test.stopTest();

        System.assertEquals(title, cv.Title, 'Incorrect document title.');
        System.assertEquals(pathOnClient, cv.PathOnClient, 'Incorrect path.');
        System.assertEquals(versionData, cv.VersionData, 'Incorrect data.');
        System.assertEquals(origin, cv.Origin, 'Incorrect origin.');
    }

    @IsTest
    private static void testPublishRctiInvoiceUploadReady() {
        
        Case claim = [SELECT Id, AccountId, CaseNumber, Invoice_Number_PC__c FROM Case LIMIT 1];
        claim.Invoice_Number_PC__c = 'testinvoice';

        Set<Id> docIds = new Set<Id> { '0682O000000MCxtQAG' };
        Map<Id, Case> mapDocIdandCase = new Map<Id, Case> { '0682O000000MCxtQAG' => claim };

        List<Database.SaveResult> sr = new List<Database.SaveResult>();
        Test.startTest();
            sr = SpRctiGenerationService.publishRctiInvoiceUploadReady(docIds, mapDocIdandCase);
        Test.stopTest();

        System.assertEquals(true, sr.get(0).isSuccess(), 'Platform event delivery failed.');
    }

    @IsTest
    private static void testBuildRctiInvoiceUploadReadyPayload() {

        Test.startTest();
            Case claim = [SELECT Id, CaseNumber, AccountId FROM Case LIMIT 1];
            claim.Invoice_Number_PC__c = '088-2011-001';
        Test.stopTest();

        SpRctiInvoiceUploadReadySsaDtoAws dto = SpRctiGenerationService.buildRctiInvoiceUploadReadyPayload(claim);
        SpRctiInvoiceUploadReadySsaDtoAws.Aws aws = dto.Aws;

        System.assertEquals(claim.CaseNumber, aws.caseNumber, 'Wrong casenumber mapping.');
        System.assertEquals(claim.AccountId, aws.accountId, 'Wrong accountId mapping.');
        System.assertEquals(claim.Invoice_Number_PC__c, aws.invoiceNumber, 'Wrong invoiceNumber mapping.');
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