/**********************************************************************
 * @author                  Ericka Cajucom
 * @date                    2020-09-29
 *
 * @description             a sub-process of Cloud Storage Orchestration
 *                          which performs RCTI operations once the process
 *                          detects successful rcti-invoice
 */
public class SpRCTIProcess implements ICloudStorageProcess {
    
    @TestVisible private static String ERRORLEVEL = 'error';
    private final String INFOLEVEL = 'info';
    
    /**
     * @description         Execute processes per payload
     * 
     * @param payloads      List of payload strings passed from Cloud Storage Orchestration
     */
    public void run(List<String> payloads) {
        Set<Id> contentDocumentToDelete = new Set<Id>();
        Map<String, String> caseRecordMap = new Map<String, String>();
        String caseNumber;
        String awsKey;
        String status;
        
        for (String payload : payloads) {
            SpRCTIPayloadData payloadData = 
                (SpRCTIPayloadData) JSON.deserialize(payload, SpRCTIPayloadData.class);
                
            caseNumber = payloadData.attributes.caseNumber;
            awsKey = payloadData.attributes.awsKey;
            contentDocumentToDelete.add(payloadData.attributes.documentId);
            
            if (caseNumber != null && awsKey != null) {
                caseRecordMap.put(caseNumber, awsKey);
            }
        }
        fetchContentDocuments(contentDocumentToDelete);
        updateCaseRecord(caseRecordMap);
    }
    
    /**
     * @description                 Fetch temporary Content Document from
     *                              Set of Content Version Ids
     *
     * param contentVersionIdList   Set of ids extracted from payload
     */
    @TestVisible
    private void fetchContentDocuments(Set<Id> contentVersionIdList) {
        List<ContentDocument> contentDocumentsToDelete;
        List<ContentVersion> contentVersionList = [SELECT Id,
                                                          ContentDocumentId 
                                                   FROM ContentVersion 
                                                   WHERE Id IN: contentVersionIdList];
        Set<Id> contentDocumentsIds = new Set<Id>();
        
        for (ContentVersion contentVersion : contentVersionList) {
            contentDocumentsIds.add(contentVersion.ContentDocumentId);
        }
        contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN: contentDocumentsIds];
        
        deleteContentDocuments(contentDocumentsToDelete);
    }
    
    /**
     * @description                 Delete temporary Content Documents
     *
     * param contentVersionIdList   Set of ids extracted from payload
     */
    @TestVisible
    private void deleteContentDocuments(List<ContentDocument> contentDocumentsToDelete) {
        System_Log__e logEvent = new System_Log__e();
        String sysLogPayload;
        try {
            delete contentDocumentsToDelete;

            sysLogPayload = buildLogPayload(INFOLEVEL, JSON.serialize(contentDocumentsToDelete), 'deleteContentDocuments');
            logEvent = createSystemLog(INFOLEVEL, sysLogPayload);
        } catch (Exception e) {
            sysLogPayload = buildLogPayload(e.getTypeName(),
                                                e.getMessage() + ': ' + e.getStackTraceString(),
                                                'deleteContentDocuments');                     
            logEvent = createSystemLog(ERRORLEVEL, sysLogPayload);  
        }
        
        System.debug('System Log: ' + logEvent);
        // SD-1286 - Disable System Logs
        // List<Database.Error> errors = this.publishEvents(new List<System_Log__e> {logEvent});
        // if (!errors.isEmpty()) {
        //     this.insertErrorLogs(errors);
        //     throw new SpRCTIProcessException(Label.Generic_Error_Message);
        // }
    }
        
    /**
     * @description         Update AWS Invoice File Key from Case Record
     *
     * param caseRecordMap  Map of case details
     *                      - key is caseNumber
     *                      - value is awsKey
     */
    @TestVisible
    private void updateCaseRecord(Map<String, String> caseRecordMap) {
        List<Case> casesToUpdate = new List<Case>();
        List<String> caseNumbers = new List<String>();
        caseNumbers.addAll(caseRecordMap.keySet());
        String sysLogPayload;
        System_Log__e logEvent = new System_Log__e();
        
        for (Case caseToUpdate : [SELECT Id, 
                                         CaseNumber,
                                         AWS_Invoice_File_Key__c 
                                  FROM Case
                                  WHERE CaseNumber IN: caseRecordMap.keySet()]) {
            caseToUpdate.AWS_Invoice_File_Key__c = caseRecordMap.get(caseToUpdate.CaseNumber);
            casesToUpdate.add(caseToUpdate);
        }
        try {
            update casesToUpdate;
            
            sysLogPayload = buildLogPayload(INFOLEVEL, JSON.serialize(casesToUpdate), 'updateCaseRecord');
            logEvent = createSystemLog(INFOLEVEL, sysLogPayload);
        } catch (Exception e) {
            sysLogPayload = buildLogPayload(e.getTypeName(), 
                                              e.getMessage() + ': ' + e.getStackTraceString(),
                                              'updateCaseRecord');
            logEvent = createSystemLog(ERRORLEVEL, sysLogPayload);
        }
        publishRCTIInvoiceViewReadyMessage(caseNumbers);
        
        System.debug('System Log: ' + logEvent);
        // SD-1286 - Disable System Logs
        // List<Database.Error> errors = this.publishEvents(new List<System_Log__e> {logEvent});
        // if (!errors.isEmpty()) {
        //     this.insertErrorLogs(errors);
        //     throw new SpRCTIProcessException(Label.Generic_Error_Message);
        // }
    }
    
    /**
     * @description         Publish RCTI(view-ready) event after case is updated
     * @param caseNumber    List of case numbers
     */
    @TestVisible
    private void publishRCTIInvoiceViewReadyMessage(List<String> caseNumbers) {
        List<RCTI_Invoice_View_Ready__e> events = new List<RCTI_Invoice_View_Ready__e>();
        List<SObject> rctiInvViewReadyObjects = new List<SObject>();
        
        for (String caseNumber : caseNumbers) {
            events.add(new RCTI_Invoice_View_Ready__e(
                Case_Number__c = caseNumber
            ));
        }
        
        rctiInvViewReadyObjects.addAll(events);
        List<Database.Error> errors = this.publishEvents(rctiInvViewReadyObjects);
        if (!errors.isEmpty()) {
            this.insertErrorLogs(errors);
            throw new SpRCTIProcessException(Label.Generic_Error_Message);
        }
    }
    
    /**
     * @description         Create System Log with level and payload
     *                      
     * @param level         System log level
     * @param payload       System log value/payload
     * 
     * @return              Serialized JSON of System Log record
     */
    @TestVisible
    private System_Log__e createSystemLog(String level, String payload) {
        Schema.DescribeFieldResult payloadDfr = System_Log__e.Payload__c.getDescribe();
        Integer payloadLmt = payloadDfr.getLength();
        return new System_Log__e(
            Level__c = level,
            Payload__c = payload.length() < payloadLmt ? payload : payload.left(payloadLmt)
        );
    }
    
    /**
     * @description         Build system log payload value
     * 
     * @param logType       System log payload level
     * @param logValue      System log payload value
     * @param methodName    System log payload module
     * 
     * @return              Serialized JSON of system log payload value
     */
    @TestVisible
    private String buildLogPayload(String logType, String logValue, String methodName) {
        List<Map<String, String>> payloadValue = new List<Map<String, String>> {
            new Map<String,String> {
                'type' => logType, 
                'value' => logValue,
                'module' => 'Class.SpRCTIProcess.' + methodName
            }
        };
        return JSON.serialize(payloadValue);
    }
    
    /**
     * @description                 Insert error logs internally(Salesforce)
     * 
     * @param errors                Publish Event errors
     */
    @TestVisible
    private void insertErrorLogs(List<Database.Error> errors) {
        List<Log__c> errorLogs = new List<Log__c>();
        for (Database.Error err : errors) {
            errorLogs.add( new Log__c(
                Level__c = ERRORLEVEL,
                Message__c = err.getMessage(),
                Stack_Trace__c = JSON.serialize(err.getFields())
            ));
        }
        insert errorLogs;
    }
    
    /**
     * @description                 Publish Events
     * 
     * @param eventObjects          list of events to be published
     * 
     * @return                      List of errors on publish
     */
    @TestVisible
    private List<Database.Error> publishEvents(List<SObject> eventObjects) {
        List<Database.Error> errors = new List<Database.Error>();
            List<Database.SaveResult> results = EventBus.publish(eventObjects);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    errors.addAll(sr.getErrors());
                }
            }
        return errors;
    }
    
    /**
     * @description     RCTI Payload data
     */
    public class SpRCTIPayloadData {
        public Integer statusCode;  
        public SpRCTIPayloadDataAttributes attributes;
    }
    
    /**
     * @description     RCTI Payload Attributes data
     */
    public class SpRCTIPayloadDataAttributes {
        public String caseNumber; 
        public String documentId; 
        public String awsKey; 
    }
    
    /**
     * @description                 Custom Exception
     */
    public class SpRCTIProcessException extends Exception {}
    
}