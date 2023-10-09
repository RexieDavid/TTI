@isTest
public class TTI_FileViewAndUploadControllerTest {
    
    private static Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();

    @TestSetup
    public static void createRecords() {
          
        Case objCase = new Case();
        objCase.Subject =  'Service Request for M18FID-0';
        objCase.Status  =   'In Progress';
        objCase.Priority =  'Critical';
        objCase.RecordTypeId = recordTypeId;
        insert objCase;
        
        ContentVersion conVersion = new ContentVersion();
        conVersion.Title = objCase.CaseNumber + '.pdf';
        conVersion.PathOnClient = objCase.CaseNumber + '.pdf';
        conVersion.VersionData = blob.valueOf('Testing');
        conVersion.IsMajorVersion = true;
        insert conVersion;

        ContentVersion conVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :conVersion.Id LIMIT 1];
        
        ContentDocumentLink objDocumentLink = new ContentDocumentLink();
        objDocumentLink.ContentDocumentId = conVersion2.ContentDocumentId;
        objDocumentLink.LinkedEntityId = objCase.Id;
        objDocumentLink.ShareType = 'V';
        insert objDocumentLink;
    }
    public static testMethod void insertContentDocument() {
        Case getCaseRecord = [SELECT Id, Subject FROM Case WHERE Subject = 'Service Request for M18FID-0' LIMIT 1];
        ContentVersion getConVersion = [SELECT Id,ContentDocumentId, Title FROM ContentVersion LIMIT 1];
        
        Test.startTest();
        TTI_FileViewAndUploadController.handleOnuploadfinished(getCaseRecord.id);
        Test.stopTest();

        List<ContentDocument> verifyDocuments = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =: getConVersion.Id];
        system.assertEquals(verifyDocuments.size(), 1, 'File is too large, Please attach another file');
        system.assertEquals(verifyDocuments[0].Id, getConVersion.ContentDocumentId, 'Content Document Id did not match');
        system.assertEquals(verifyDocuments[0].LatestPublishedVersionId, getConVersion.Id, 'Content Document version did not match');
    }
      
    public static testMethod void removeContentDocument() {
        Case getCaseRecord = [SELECT Id, Subject FROM Case WHERE Subject = 'Service Request for M18FID-0' LIMIT 1];
        ContentDocumentLink getContentDocumentLink = [SELECT Id , ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: getCaseRecord.Id];
        ContentVersion getConVersion = [SELECT Id,ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId =: getContentDocumentLink.ContentDocumentId];
        
        Test.startTest();
        TTI_FileViewAndUploadController.handleRemoveDocument(getCaseRecord.id,getContentDocumentLink.ContentDocumentId);
        Test.stopTest();
            
        List<ContentDocument> verifyDocuments = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =: getConVersion.Id];
        List<ContentDocumentLink> verifyCaseDocumentLink = [Select Id  FROM ContentDocumentLink WHERE LinkedEntityId =: getCaseRecord.Id];
        system.assertEquals(verifyDocuments.size(), 0, 'Unable to delete File, Please contact your administrator');
        system.assertEquals(verifyCaseDocumentLink.size(), 0, 'Unable to delete File, Please contact your administrator');
    }
    
    public static testMethod void removeMethodException() {
        Case getCaseRecord = [SELECT Id, Subject, CaseNumber FROM Case WHERE Subject = 'Service Request for M18FID-0' LIMIT 1];

        try {
            Test.startTest();
            TTI_FileViewAndUploadController.handleRemoveDocument(getCaseRecord.Id, getCaseRecord.Id);
            Test.stopTest();
        } catch (AuraHandledException e) {
            system.assertEquals('An error was encountered, Please contact your administrator', e.getMessage(), 'Error message does not match');
        }
    }
    
      public static testMethod void insertMethodException() {
        try {
            Test.startTest();
            TTI_FileViewAndUploadController.handleOnuploadfinished(null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            system.assertEquals('An error was encountered, Please contact your administrator', e.getMessage(), 'Error message does not match');
        }
    }
}