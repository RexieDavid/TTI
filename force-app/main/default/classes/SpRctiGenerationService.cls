/**
* @author           Samuel Oberes
* @date             2021-02-23
* @description      Contains logic for pdf generation (abstracted from SpRctiGenerationTriggerHandler)
*/
public with sharing class SpRctiGenerationService {

    @Future(callout=true)
    public static void start(Set<Id> caseIds) {
        List<ContentVersion> newContentVersions = new List<ContentVersion>();
        Map<String, String> mapCaseAndContentVersion = new Map<String, String>();
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, CaseNumber, Invoice_Number_PC__c, AccountId 
                                                   FROM Case 
                                                  WHERE Id IN :caseIds]);

        for (Case claim : cases.values()) {
            ContentVersion cont = buildPdf(claim);

            newContentVersions.add(cont);
            mapCaseAndContentVersion.put(cont.Title, claim.Id);
        }

        if (!newContentVersions.isEmpty()) {
            try {
                insert newContentVersions;
            } catch (Exception ex) {
                System.debug('DBG: error in inserting newContentVersions --- message: ' + ex.getMessage());
                System.debug('DBG: error in inserting newContentVersions --- stacktrace: ' + ex.getStackTraceString());
            }

            Set<Id> docIds = new Set<Id>();
            docIds.addAll(new Map<Id, ContentVersion>(newContentVersions).keySet());

            List<ContentDocumentLink> newContentDocLinks = new List<ContentDocumentLink>();
            map<Id, Case> mapDocIdandCase = new Map<Id, Case>();
            for (ContentVersion cv : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :docIds]) {

                String caseId = mapCaseAndContentVersion.get(cv.Title);
                newContentDocLinks.add(
                    new ContentDocumentLink(
                        ContentDocumentId = cv.ContentDocumentId,
                        LinkedEntityId = caseId,
                        Visibility = 'AllUsers'
                    )
                );

                mapDocIdandCase.put(cv.Id, cases.get(caseId));
            }

            if (!newContentDocLinks.isEmpty()) {
                try {
                    insert newContentDocLinks;
                } catch (Exception ex) {
                    System.debug('DBG: error in inserting newContentDocLinks --- message: ' + ex.getMessage());
                    System.debug('DBG: error in inserting newContentDocLinks --- stacktrace: ' + ex.getStackTraceString());
                }
            }

            publishRctiInvoiceUploadReady(docIds, mapDocIdandCase);
        }
    }

    @TestVisible
    private static ContentVersion buildPdf(Case claim) {
        PageReference ref = new PageReference('/apex/TTI_Invoicepdf?id=' + claim.Id);
        String title = claim.CaseNumber + '-RCTI(' + claim.Invoice_Number_PC__c + ')';
        ContentVersion cv = new ContentVersion();
        
        cv.Title = title;
        cv.PathOnClient = 'file.pdf';
        cv.VersionData = Test.isRunningTest() ? Blob.valueOf('Test Data') : ref.getContentAsPdf();
        cv.Origin = 'H';

        return cv;
    }

    @TestVisible
    private static List<Database.SaveResult> publishRctiInvoiceUploadReady(Set<Id> docIds, Map<Id, Case> mapDocIdandCase) {
        List<RCTI_Invoice_Upload_Ready__e> events = new List<RCTI_Invoice_Upload_Ready__e>();

        for (Id id : docIds) {
            events.add(new RCTI_Invoice_Upload_Ready__e(
                Document_Identifier__c = id,
                Storage_Specific_Attributes__c = 
                    JSON.serialize(buildRctiInvoiceUploadReadyPayload(mapDocIdandCase.get(id)))
            ));
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(events);

        return results;
    }

    @TestVisible
    private static SpRctiInvoiceUploadReadySsaDtoAws buildRctiInvoiceUploadReadyPayload(Case claim) {
        SpRctiInvoiceUploadReadySsaDtoAws.Aws aws = new SpRctiInvoiceUploadReadySsaDtoAws.Aws();
        aws.accountId = claim.AccountId;
        aws.invoiceNumber = claim.Invoice_Number_PC__c;
        aws.caseNumber = claim.CaseNumber;

        SpRctiInvoiceUploadReadySsaDtoAws rctiInvoiceUploadReadyDto = new SpRctiInvoiceUploadReadySsaDtoAws();
        rctiInvoiceUploadReadyDto.aws = aws;

        return rctiInvoiceUploadReadyDto;
    }

}