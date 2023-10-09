/**
* @author: Stephen James Laylo
* @date: May 2018
* @description: This class handles all CRUD operations for the
* Content Document Trigger. All logic should be placed here and not in the
* trigger itself
*/
public with sharing class ContentDocumentTriggerHandler implements ITriggerHandler {
    private final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
     
    /**
    * Checks if trigger is enabled to the current user
    * 
    * @return  Boolean value if trigger is enabled to current user
    */
    public static Boolean isEnabled() {
        return Trigger_Settings__c.getInstance(UserInfo.getUserId()).ContentDocumentTrigger__c;
    }
    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles all on Before Insert
    * functionalities of the ContentDocument
    */
    public void beforeInsert(List<SObject> newContentDocuments) { }

    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles all on After Insert
    * functionalities of the ContentDocument
    */
    public void afterInsert(Map<Id, SObject> newContentDocuments) { }
     
    /**
    * Method to be executed before update of record
    * 
    * @param newItems - List of records updated
    * @param oldItems - List of old records updated
    */
    public void beforeUpdate(Map<Id, SObject> newContentDocuments, Map<Id, SObject> oldContentDocumentsMap) { }
    
    /**
    * Method to be executed after update
    * 
    * @param newItems - List of records updated
    * @param oldItems - List of old records updated
    */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles all on After Delete
    * functionalities of the ContentDocument
    */
    public void beforeDelete(Map<Id, SObject> oldContentDocumentsMap) {
        updateRelatedObjDocumentAttachedFlag(oldContentDocumentsMap);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles all on After Delete
    * functionalities of the ContentDocument
    */
    public void afterDelete(Map<Id, SObject> oldContentDocumentsMap) { }

    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles all on After Undelete
    * functionalities of the ContentDocument
    */
    public void afterUndelete(Map<Id, SObject> oldContentDocumentsMap) { }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles the flag of Document Attached field in Opportunity
    */
    public void updateRelatedObjDocumentAttachedFlag(Map<Id, SObject> oldContentDocumentsMap) {
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> offLocationIds = new Set<Id>();
        Set<Id> salesTransactionIds = new Set<Id>();
        String queryLinkedEntityStr = '(SELECT Id, LinkedEntityId FROM ContentDocumentLinks)';
        String fieldsToQuery;
        
        for (ContentDocumentLink cDocLink : [
                                                SELECT LinkedEntityId 
                                                FROM ContentDocumentLink
                                                WHERE ContentDocumentId IN :oldContentDocumentsMap.keySet()
                                            ]) {
            if (cDocLink.LinkedEntityId != null) {
                String sObjectType = TTIUtilClass.findObjectNameFromRecordIdPrefix(cDocLink.LinkedEntityId);
                if (sObjectType == 'Opportunity') {
                    opportunityIds.add(cDocLink.LinkedEntityId);
                }
                if (sObjectType == 'Off_Location__c') {
                    offLocationIds.add(cDocLink.LinkedEntityId);
                }
                if (sObjectType == 'Sales_Transactions__c') {
                    salesTransactionIds.add(cDocLink.LinkedEntityId);
                }
            }
        }
        
        List<SObject> relObjectToUpdate = new List<SObject>();
        Map<Id, SObject> sObjectToUpdateMap = new Map<Id, SObject>();
        try {
            if (opportunityIds.size() > 0) {
                fieldsToQuery = 'Id, Document_Attached__c, ' + queryLinkedEntityStr;
            
                for (sObject oppty : setFlagToUpdate('Opportunity', fieldsToQuery, 'Document_Attached__c', opportunityIds)) {
                    relObjectToUpdate.add(oppty);
                }
            }
            
            if (offLocationIds.size() > 0) {
                fieldsToQuery = 'Id, Document_Attached__c, ' + queryLinkedEntityStr;               
                for (sObject offLoc : setFlagToUpdate('Off_Location__c', fieldsToQuery, 'Document_Attached__c', offLocationIds)) {
                    relObjectToUpdate.add(offLoc);
                }
            }

            if (salesTransactionIds.size() > 0) {
                fieldsToQuery = 'Id, File_Attached__c, ' + queryLinkedEntityStr;               
                for (sObject slsTrans : setFlagToUpdate('Sales_Transactions__c', fieldsToQuery, 'File_Attached__c', salesTransactionIds)) {
                    relObjectToUpdate.add(slsTrans);
                }
            }
            
            if (!relObjectToUpdate.isEmpty()) {
                updateRelatedObjectAsynchronously(JSON.serialize(relObjectToUpdate));
            }
        } catch (Exception e) { 
            throw new ContentDocumentTriggerHandlerException(ERR_GENERIC_MESSAGE); 
        }
    }
    
    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-06-22
    * @description: This method queries and returns list of updated related record if other ContentDocumentLinks are existing in related record
    * and set flag field to true/false.
    * @param objAPIName the name of the object to query
    * @param fieldsToQuery the fields to be selected in the query
    * @param flagToUpdate the (checkbox) field to be populated 
    * @param relatedObjectIds sets of related record Ids to be queried 
    * @example: setFlagToUpdate('Opportunity', 'Id, Document_Attached__c', 'Document_Attached__c', new Set<Id>());
    */
    private List<sObject> setFlagToUpdate(String objAPIName, String fieldsToQuery, String flagToUpdate, Set<Id> relatedObjectIds) {
        String soql = 'SELECT {0} FROM {1} WHERE ID IN :relatedObjectIds';
        List<String> args = new List<String>{
            fieldsToQuery,
            objAPIName,
            flagToUpdate
        };
        String queryString = String.format(soql, args);
        
        List<SObject> updatedRecords = new List<SObject>();
        for (SObject record : Database.query(queryString)) {
            List<SObject> contentDocs = record.getSObjects('ContentDocumentLinks');
            SObject sObjectType = Schema.getGlobalDescribe().get(objAPIName).newSObject();
            
            if (sObjectType.getSobjectType().getDescribe().fields.getMap().containsKey(flagToUpdate)) {
                record.put(flagToUpdate, contentDocs.size() > 1); 
                updatedRecords.add(record);
            }
            
        }
        return updatedRecords;
    }
    
    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-06-22
    * @description: This method performs record update on related record 
    * @param serializedObjIds Json serialized values of object to be updated
    * @example: updateRelatedObjectAsynchronously(JSON.serialize(new Opportunity()));
    */
    @future
    private static void updateRelatedObjectAsynchronously(String serializedObjIds) {
        List<SObject> sobjects = 
        (List<SObject>) JSON.deserialize(serializedObjIds, List<SObject>.class);
        
        try {
            update sobjects;
        } catch (Exception err) { 
            throw new ContentDocumentTriggerHandlerException(err.getMessage()); 
        }
    }
    
    public class ContentDocumentTriggerHandlerException extends Exception {}
}