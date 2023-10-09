/**
* @author                Samuel Oberes
* @date                  2020-03-11
* @description           Test class for SpRctiReprocessingController
*/
@IsTest
public with sharing class SpRctiReprocessingControllerTest {
    
    @TestSetup
    private static void makeData() {

        Id rtServiceAgent = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service_Agent').getRecordTypeId();
        Account acct = new Account();
        acct.Name = 'Test Acct';
        acct.Internal_Service_Agent__c = false;
        acct.RecordtypeId = rtServiceAgent;
        insert acct;

        Id rtServiceRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Case c = new Case();
        c.AccountId = acct.Id;
        c.RecordTypeId = rtServiceRequest;
        c.Service_Request_Milestone__c = 'Closed';
        c.Status = 'Closed';
        c.Invoice_Number_PC__c = 'testInvoiceNumber';
        c.AWS_Invoice_File_Key__c = 'testInvoiceFileKey';
        insert c;

        c = [SELECT CaseNumber FROM Case LIMIT 1];

        ContentVersion cv = new Contentversion();
        cv.Title = 'rcti-migration-';
        cv.PathOnClient = 'file.pdf';

        String dataString = 'CaseNumber\n' + c.CaseNumber;
        cv.VersionData = Blob.valueOf(dataString);
        cv.Origin = 'H';
        insert cv;

    }

    @IsTest
    private static void testGetFilesToLoad() {
        
        List<String> fileTitlesList = new List<String>();
        Test.startTest();
            fileTitlesList = SpRctiReprocessingController.getFilesToLoad();
        Test.stopTest();

        System.assertEquals(1, fileTitlesList.size(), 'Incorrect file count');
        System.assertEquals('rcti-migration-', fileTitlesList.get(0), 'Incorrect file count');

    }

    @IsTest
    private static void testGetClaimsForReprocessing() {

        List<SpRctiReprocessingController.Claim> claims = new List<SpRctiReprocessingController.Claim>();
        Test.startTest();
            claims = SpRctiReprocessingController.getClaimsForReprocessing('rcti-migration-');
        Test.stopTest();

        System.assertEquals(1, claims.size(), 'Incorrect files queried.');
        System.assertEquals('testInvoiceNumber', claims.get(0).invoiceNumber, 'Incorrect invoice number.');
        System.assertEquals('Closed', claims.get(0).status, 'Incorrect status.');
        System.assertEquals('testInvoiceFileKey', claims.get(0).invoiceFileKey, 'Incorrect invoice file key.');

    }

    @IsTest
    private static void testStartReprocessing() {

        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
            SpRctiReprocessingController.startReprocessing(new List<Id>{ c.Id });
        Test.stopTest();

        List<ContentDocumentLink> docs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];

        System.assert(!docs.isEmpty(), 'No documents are created.');

    }
}