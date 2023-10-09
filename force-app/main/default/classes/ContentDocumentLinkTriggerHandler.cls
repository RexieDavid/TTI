/**
 * @author:                         Ericka Jan Cajucom
 * @date:                           2020-06-02
 * @description:                    Handles all CRUD operations for the
 *                                  Content Document Link Trigger. All logic should 
 *                                  be placed here and not in the trigger itself
 */
public with sharing class ContentDocumentLinkTriggerHandler implements ITriggerHandler {
    private final String FILETYPE_ERROR = 'Unable to upload a file: This file type is not supported. Please upload JPEG(*.jpeg, *.jpg, *.jpe, *.jfif, *.jif) or PNG(*.png) file format.';

    /**
    * Checks if trigger is enabled to the current user
    * 
    * @return  Boolean value if trigger is enabled to current user
    */
    public static Boolean isEnabled() {
        return Trigger_Settings__c.getInstance(UserInfo.getUserId()).ContentDocumentLinkTrigger__c;
    }

    /**
     * Method to be executed before insert of record
     * 
     * @param newItems - List of records inserted
     */
    public void beforeInsert(List<SObject> newItems) { }

    /**
     * Method to be executed after insert
     * 
     * @param newItems - List of records inserted
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        updateRelatedObjDocumentAttachedFlag(newItems.values());
    }

     /**
     * Method to be executed before update of record
     * 
     * @param newItems - List of records updated
     * @param oldItems - List of old records updated
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    /**
     * Method to be executed after update
     * 
     * @param newItems - List of records updated
     * @param oldItems - List of old records updated
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    /**
     * Method to be executed after delete
     * 
     * @param oldItems - List of records deleted
     */
    public void beforeDelete(Map<Id, SObject> oldItems) { }

    /**
     * Method to be executed after delete
     * 
     * @param oldItems - List of records deleted
     */
    public void afterDelete(Map<Id, SObject> oldItems) { }

    /**
     * Method to be executed after undelete
     * 
     * @param oldItems - List of records undeleted/recovered
     */
    public void afterUndelete(Map<Id, SObject> oldItems) { }

    /**
     * @author:                     Ericka Jan Cajucom
     * @date:                       2020-06-02
     * @description:                Handles the flag of Document Attached field
     * 
     * @example:                    updateRelatedObjDocumentAttachedFlag(new Map<Id, SObject>);
    */
    public void updateRelatedObjDocumentAttachedFlag(List<ContentDocumentLink> contentDocumentLinks) {
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> offLocationIds = new Set<Id>();
        Set<Id> offLocationCDocIds = new Set<Id>();
        Set<Id> salesTransactionIds = new Set<Id>();
        Set<Id> salesTransactionCDocIds = new Set<Id>();
        Map<Id, SObject> sObjectsMap = new Map<Id, SObject>();
        
        List<String> supportedImagesFileTypes = new List<String>{
            'jpeg',
            'jpg',
            'jpe',
            'jfif',
            'png'
        };

        for (ContentDocumentLink cDocLink : contentDocumentLinks) {
            if (cDocLink.LinkedEntityId != null) { 
                String sObjectType = TTIUtilClass.findObjectNameFromRecordIdPrefix(cDocLink.LinkedEntityId);
                if (sObjectType == 'Opportunity') {
                    opportunityIds.add(cDocLink.LinkedEntityId);
                }
                if (sObjectType == 'Off_Location__c') {
                    offLocationIds.add(cDocLink.LinkedEntityId);
                    offLocationCDocIds.add(cDocLink.ContentDocumentId);
                }
                if (sObjectType == 'Sales_Transactions__c') {
                    salesTransactionIds.add(cDocLink.LinkedEntityId);
                    salesTransactionCDocIds.add(cDocLink.ContentDocumentId);
                }
            }
        }

        if (offLocationCDocIds.size() > 0) {
            for (ContentDocument cdoc : [SELECT Id, FileExtension FROM ContentDocument WHERE Id IN :offLocationCDocIds]) {
                if (!supportedImagesFileTypes.contains(cdoc.FileExtension)) {
                    contentDocumentLinks[0].addError(this.FILETYPE_ERROR);
                }
            }
        }

        if (salesTransactionCDocIds.size() > 0) {
            for (ContentDocument cdoc : [SELECT Id, FileExtension FROM ContentDocument WHERE Id IN :salesTransactionCDocIds]) {
                if (!supportedImagesFileTypes.contains(cdoc.FileExtension)) {
                    contentDocumentLinks[0].addError(this.FILETYPE_ERROR);
                }
            }
        }

        if (opportunityIds.size() > 0) {
            for (sObject oppty : setFlagToUpdate('Opportunity', 'Document_Attached__c', opportunityIds)) {
                sObjectsMap.put(oppty.Id, oppty);
            }
        }

        if (offLocationIds.size() > 0) {
            for (sObject offLoc : setFlagToUpdate('Off_Location__c', 'Document_Attached__c', offLocationIds)) {
                sObjectsMap.put(offLoc.Id, offLoc);
            }
        }

        if (salesTransactionIds.size() > 0) {
            for (sObject slsTrans : setFlagToUpdate('Sales_Transactions__c', 'File_Attached__c', salesTransactionIds)) {
                sObjectsMap.put(slsTrans.Id, slsTrans);
            }
        }

        try {
            if (!sObjectsMap.isEmpty()) {
                update sObjectsMap.values();
            }
        } catch (Exception e) {
            contentDocumentLinks[0].addError(Label.Generic_Error_Message);
        }
    }

    /**
     * @author:                     Ericka Jan Cajucom
     * @date:                       2020-06-22
     * @description:                Queries and returns list of updated related record 
     *                              if other ContentDocumentLinks are existing in related record
     *                              and set flag field to true.
     * 
     * @param objAPIName            the name of the object to query
     * @param field                 the (checkbox) field to be populated 
     * @param relatedObjectIds      sets of related record Ids to be queried 
     * 
     * @example:                    setFlagToUpdate('Opportunity', 'Document_Attached__c', new Set<Id>());
     */
    private List<sObject> setFlagToUpdate(String objAPIName, String field, Set<Id> relatedObjectIds) {
        String soql = 'SELECT Id, {0} FROM {1} WHERE ID IN : relatedObjectIds  AND {0} = false';
        List<String> args = new List<String> {
            field,
            objAPIName
        };
        String queryString = String.format(soql, args);
        List<SObject> updatedRecords = new List<SObject>();
        for (SObject record : Database.query(queryString)) {
            SObject sObjectType = Schema.getGlobalDescribe().get(objAPIName).newSObject();
            if (sObjectType.getSobjectType().getDescribe().fields.getMap().containsKey(field)) {
                record.put(field, true);
                updatedRecords.add(record);
            }
        }
        return updatedRecords;
    }
}