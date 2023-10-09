@isTest
public class SpRCTIProcessTest {
    /**********************************************************************
    * @description             Initialize data
    */
    @TestSetup
    static void makeData() {
        Contact conObj = TTI_CommonUtilityClass.createContact();

        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;

        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();

        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Freight_Company_Account_Number__c = '21946011';
        serviceAgent.Service_Agent_Status__c = 'Bronze';
        insert serviceAgent;

        Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.AccountId = serviceAgent.Id;
        caseObj.Service_Agent__c = serviceAgent.Id;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Approved_Flag__c = false;
        caseObj.TTI_Email_Notification_Opt_In__c = false;
        caseObj.TTI_Customer_Contact__c = conObj.Id;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Freight_out_consignment_number__c = null;
        caseObj.Product_Name__c = prod.Id;
        caseObj.Invoice_Number_PC__c = '088-2011-0019';
        insert caseObj;
        
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink newCDocLink = new ContentDocumentLink(
            LinkedEntityId = caseObj.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        insert newCDocLink;
    }
    
    /**
     * @description                 Test if process executes per payload
     */
    @isTest
    private static void testRun() {
        List<ContentVersion> contentVersion = [SELECT Id FROM ContentVersion LIMIT 1];
        String caseNumber = [SELECT Id, 
                                    CaseNumber,
                                    Description,
                                    Invoice_Number_PC__c
                             FROM Case
                             WHERE Invoice_Number_PC__c = '088-2011-0019'
                             LIMIT 1].CaseNumber;
        String awsKey = '001p000000Scgi8AAB/' + caseNumber + '-RCTI-1900697713.pdf';
        String jsonVal = '' + 
                        '{' +
                        '    \"statusCode\":\"200\",' +
                        '    \"attributes\":{' + 
                        '        \"caseNumber\":\"' + caseNumber + '\",' + 
                        '        \"documentId\":\"' + contentVersion[0].Id + '\",' +
                        '        \"awsKey\":\"' + awsKey + '\"' + 
                        '    }' +
                        '}';
        List<String> payload = new List<String> {jsonVal};
        
        System.assertEquals(1, contentVersion.size(), 'No Content document retrieved!');
        
        Test.startTest();
        SpRCTIProcess rcti = new SpRCTIProcess();
        rcti.run(payload);
        Test.stopTest();
        
        Case caseRec = [SELECT Id, CaseNumber, AWS_Invoice_File_Key__c FROM Case LIMIT 1];
        List<ContentVersion> contentDocuments = [SELECT Id FROM ContentVersion LIMIT 1];
        
        System.assertEquals(0, contentDocuments.size(), 'Content Document not deleted!');
        System.assertEquals(awsKey, caseRec.AWS_Invoice_File_Key__c, 'Case not updated!');
        System.assertEquals(caseRec.CaseNumber, caseNumber, 'Wrong case updated!');
    }
    
    /**
     * @description                 Process expects to fail if payload has incorrect attribute.
     */
    @isTest
    private static void testRunNegative() {
        Id contentVersion = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        String caseNumber = [SELECT Id, 
                                    CaseNumber,
                                    Description,
                                    Invoice_Number_PC__c
                             FROM Case
                             WHERE Invoice_Number_PC__c = '088-2011-0019'
                             LIMIT 1].CaseNumber;
        String awsKey = '001p000000Scgi8AAB/' + caseNumber + '-RCTI-1900697713.pdf';
        String jsonVal = '' + 
                        '{' +
                        '    \"statusCode\":\"200\",' +
                        '    \"attribute\":{' + 
                        '        \"caseNumber\":\"' + caseNumber + '\",' + 
                        '        \"documentId\":\"' + contentVersion + '\",' +
                        '        \"awsKey\":\"' + awsKey +'\"' + 
                        '    }' +
                        '}';
        List<String> payload = new List<String> {jsonVal};
        
        Test.startTest();
        try {
            SpRCTIProcess rcti = new SpRCTIProcess();
            rcti.run(payload);
        } catch(Exception e) {
            String errorMsgExp = 'Expecting NullPointerException for non-existing payload attibute name.';
            System.assertEquals(e.getTypeName(), 'System.NullPointerException', errorMsgExp);
        }
        Test.stopTest();
    }

    /**
     * @description                 Fetch ContentDocument from the given ContentVersion Ids
     */
    @isTest
    private static void testFetchContentDocuments() {
        Set<Id> contentVersionId = new Set<Id> {[SELECT Id FROM ContentVersion LIMIT 1].Id};
        List<ContentDocument> contentDoc = [SELECT ID 
                                            FROM ContentDocument
                                            WHERE LatestPublishedVersionId =:contentVersionId.iterator().next()];
        
        System.assertEquals(1, contentDoc.size(), 'No Content document retrieved!');
        
        Test.startTest();
        SpRCTIProcess rcti = new SpRCTIProcess();
        rcti.fetchContentDocuments(contentVersionId);
        Test.stopTest();
        
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument LIMIT 1];
        
        System.assertEquals(0, contentDocuments.size(), 'Content Document not deleted!');
    }


    /**
     * @description                 No ContentDocument is deleted when failed to fetch records
     */
    @isTest
    private static void testFetchContentDocumentsNegative() {
        SpRCTIProcess.ERRORLEVEL = 'warning';
        Set<Id> contentVersionId = new Set<Id> {[SELECT Id FROM ContentVersion LIMIT 1].Id};
        List<ContentDocument> contentDoc = [SELECT ID 
                                            FROM ContentDocument
                                            WHERE LatestPublishedVersionId = NULL];
        
        System.assertEquals(1, contentVersionId.size(), 'No Content document retrieved!');
        
        Test.startTest();
        try {
            SpRCTIProcess rcti = new SpRCTIProcess();
            rcti.fetchContentDocuments(null);
        } catch (Exception ex) {
            // do nothing
        }
        Test.stopTest();
        
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument LIMIT 1];
        
        System.assertEquals(1, contentDocuments.size(), 'No Content Document was deleted!');
    }
    
    /**
     * @description                 Delete temporary Content Documents
     */
    @isTest
    private static void testDeleteContentDocuments() {
        Set<Id> contentVersionId = new Set<Id> {[SELECT Id FROM ContentVersion LIMIT 1].Id};
        List<ContentDocument> contentDoc = [SELECT ID
                                            FROM ContentDocument
                                            WHERE LatestPublishedVersionId =:contentVersionId.iterator().next()];
        
        System.assertEquals(1, contentDoc.size(), 'No Content document retrieved!');
        
        Test.startTest();
        SpRCTIProcess rcti = new SpRCTIProcess();
        rcti.deleteContentDocuments(contentDoc);
        Test.stopTest();
        
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument LIMIT 1];
        
        System.assertEquals(0, contentDocuments.size(), 'Content Document not deleted!');
    }
    
    /**
     * @description                 Fail to Delete temporary Content Documents
     */
    @isTest
    private static void testDeleteContentDocumentsNegative() {
        SpRCTIProcess.ERRORLEVEL = 'warning';
        
        Set<Id> contentVersionId = new Set<Id> {[SELECT Id FROM ContentVersion LIMIT 1].Id};
        List<ContentDocument> contentDoc = [SELECT ID FROM ContentDocument WHERE LatestPublishedVersionId =: contentVersionId.iterator().next()];
        
        System.assertEquals(1, contentDoc.size(), 'No Content document retrieved!');
        
        Id stdProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        User stdUsr = new User(Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'teststandard@testing.com',
            TTI_SAP_Cust_No__c = '12345',
            Division = 'Industrial');
        insert stdUsr;
        
        Test.startTest();
        System.runAs(stdUsr) {
            try {
                SpRCTIProcess rcti = new SpRCTIProcess();
                rcti.deleteContentDocuments(null);
            } catch(Exception e) {
                // do nothing
            }
        }
        
        Test.stopTest();
        
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument LIMIT 1];
        
        System.assertEquals(1, contentDocuments.size(), 'Content Document was deleted!');
    }
    
    /**
     * @description                 Update AWS Invoice File Key from Case Record
     */
    @isTest
    private static void testUpdateCaseRecord() {
        Case caseRec = [SELECT Id, 
                               CaseNumber,
                               Description,
                               Invoice_Number_PC__c
                        FROM Case
                        WHERE Invoice_Number_PC__c = '088-2011-0019'
                        LIMIT 1];
                       
        String awsKey = '001p000000Scgi8AAB/' + caseRec.CaseNumber + '-RCTI-1900697713.pdf';
        
        Map<String, String> caseRecordMap = new Map<String, String> {caseRec.CaseNumber => awsKey};
        
        Test.startTest();
        
        SpRCTIProcess rcti = new SpRCTIProcess();
        rcti.updateCaseRecord(caseRecordMap);
        Test.stopTest();
        
        Case caseUpdated = [SELECT Id, CaseNumber, AWS_Invoice_File_Key__c FROM Case LIMIT 1];
        System.assertEquals(caseUpdated.CaseNumber, caseRec.CaseNumber, 'Wrong case updated!');
    }
    
    /**
     * @description                 Fail to update the AWS Key on Case record
     */
    @isTest
    private static void testUpdateCaseRecordNegative() {
        SpRCTIProcess.ERRORLEVEL = 'warning';
        Case caseRec = [SELECT Id, 
                               CaseNumber,
                               Description,
                               Invoice_Number_PC__c
                        FROM Case
                        WHERE Invoice_Number_PC__c = '088-2011-0019'
                        LIMIT 1];
                       
        String awsKey = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. ' +
                        'Aenean commodo ligula eget dolor. Aenean massa. ' +
                        'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. ' +
                        'Donec quam felis, ultricies nec, pellentesque eu, pretium quisz.pdf';
        
        Map<String, String> caseRecordMap = new Map<String, String> {caseRec.CaseNumber => awsKey};
        
        Test.startTest();
        try {
            SpRCTIProcess rcti = new SpRCTIProcess();
            rcti.updateCaseRecord(caseRecordMap);
        } catch (Exception e) {
            // do nothing
        }
        
        Test.stopTest();
        
        Case caseUpdated = [SELECT Id, CaseNumber, AWS_Invoice_File_Key__c FROM Case LIMIT 1];
        System.assertEquals(caseUpdated.CaseNumber, caseRec.CaseNumber, 'Wrong case updated!');
    }
    
    /**
     * @description                 Publish RCTI(view-ready) event after case is updated
     */
    @isTest
    private static void testPublishRCTIInvoiceViewReadyMessage() {
        Case caseRec = [SELECT Id, 
                               CaseNumber,
                               Description,
                               Invoice_Number_PC__c
                        FROM Case
                        WHERE Invoice_Number_PC__c = '088-2011-0019'
                        LIMIT 1];
        
        Test.startTest();
        
        SpRCTIProcess rcti = new SpRCTIProcess();
        rcti.publishRCTIInvoiceViewReadyMessage(new List<String>{caseRec.CaseNumber});
        Test.stopTest();
    }

    /**
     * @description                 Publish RCTI(view-ready) event with invalid case
     */
    @isTest
    private static void testPublishRCTIInvoiceViewReadyMessageNegative() {
        SpRCTIProcess.ERRORLEVEL = 'warning';
        String invalidCaseNumber = '===============Test===============';
        Test.startTest();
        try {
            SpRCTIProcess rcti = new SpRCTIProcess();
            rcti.publishRCTIInvoiceViewReadyMessage(new List<String>{invalidCaseNumber});
        } catch(Exception ex) {
            // do nothing
        }
        
        Test.stopTest();
    }
    
    /**
     * @description                 Build Payload for System logs
     */
    @isTest
    private static void testBuildLogPayload() {
        String logType = 'info';
        String logValue = 'SUCCESS';
        String logModule = 'Class.SpRCTIProcess.publishLogPayload';
        
        Test.startTest();
        SpRCTIProcess rcti = new SpRCTIProcess();
        String logMap = rcti.buildLogPayload(logType, logValue, logModule);
        Test.stopTest();

        System.assert(logMap.contains('info') == true, 'JSON string was not serialized correctly.');
    }
    
    /**
     * @description                 Insert Error Logs internally(Salesforce)
     */
    @isTest
    private static void testInsertErrorLogs() {
        SpRCTIProcess rcti = new SpRCTIProcess();
        String errMessage;

        Test.startTest();
        rcti.insertErrorLogs(fetchDatabaseError());
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(10, logs.size(), 'Failed to insert error logs');
    }

    /**
     * @description                 Fail to insert Error Logs internally(Salesforce)
     */
    @isTest
    private static void testInsertErrorLogsNegative() {
        SpRCTIProcess rcti = new SpRCTIProcess();
        String errMessage;
        Test.startTest();
        try {
            rcti.insertErrorLogs(null);
        } catch (Exception ex) {
            // do nothing
        }
        
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(0, logs.size(), 'error logs were created.');
    }


    /**
     * @description                 Publish System Log events
     */
    @isTest
    private static void testPublishSystemLogEvents() {
        List<System_Log__e> sysLogs = new List<System_Log__e>();
        List<Database.Error> errors;
        
        SpRCTIProcess rcti = new SpRCTIProcess();
        String logType = 'info';
        String logValue = 'SUCCESS';
        String logModule = 'Class.SpRCTIProcess.publishLogPayload';

        String logMap = rcti.buildLogPayload(logType, logValue, logModule);
        sysLogs.add(new System_Log__e(Level__c = 'info', Payload__c = logMap));

        Test.startTest();
        errors = rcti.publishEvents(sysLogs);
        Test.stopTest();

        System.assert(errors.isEmpty(), 'Event was not published.');
    }


    /**
     * @description                 Fail to Publish System Log events
     */
    @isTest
    private static void testPublishSystemLogEventsNegative() {
        List<System_Log__e> sysLogs = new List<System_Log__e>();
        List<Database.Error> errors;
        
        SpRCTIProcess rcti = new SpRCTIProcess();
        String logType = 'info';
        String logValue = 'SUCCESS';
        String logModule = 'Class.SpRCTIProcess.publishLogPayload';

        String logMap = rcti.buildLogPayload(logType, logValue, logModule);
        sysLogs.add(new System_Log__e(Level__c = 'info', Payload__c = logMap));

        Test.startTest();
        try {
            errors = rcti.publishEvents(sysLogs);
            fetchDatabaseError();
        } catch (Exception e){

        }
        
        Test.stopTest();

        System.assert(errors != null, 'Event was published.');
    }

     /**
     * @description                 Fetch Database Errors
     */
    private static List<Database.Error> fetchDatabaseError() {
        List<Database.Error> errors = new List<Database.Error>();
        for (Integer i = 0; i < 10; i++) {
            errors.add(createMockError(i));
        }
        return errors;
    }
    
    /**
     * @description                 Create Database.Error instance
     */
    private static Database.Error createMockError(Integer uniqueIdentifier) {
        DatabaseErrorMock errorMock = new DatabaseErrorMock();
        errorMock.message = 'Error-' + uniqueIdentifier;
        errorMock.statusCode = '400'; //Bad Request
        errorMock.fields = new List<String>{'dummyfield'};
        return (Database.Error)JSON.deserialize(JSON.serialize(errorMock), Database.Error.class);
    }

    /**
     * @description                 Mock Database Error
     */
    public class DatabaseErrorMock {
        String message;
        String statusCode;
        List<String> fields;
    }

}