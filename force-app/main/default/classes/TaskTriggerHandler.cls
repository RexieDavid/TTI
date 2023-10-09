/**
* @author: Jerome Liwanag
* @date: Aug 2017
* @description: This class handles all CRUD operations for the
* Task Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class TaskTriggerHandler {
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Account
    */ 
    public static void onBeforeInsert(List<Task> newTasks) {
        updatePostCallSurvey(newTasks);
    }
    
    public static void updatePostCallSurvey(List<Task> taskList) {
        
        Set<String> callObjectSet = new Set<String>();
        Set<Id> ownerIdSet = new Set<Id>();
        
        for(Task taskLoop : taskList){
            if(taskLoop.CallObject != null){
                callObjectSet.add(taskLoop.CallObject);
                ownerIdSet.add(taskLoop.OwnerId);
            }
        }
         
        // Find PCS record
        List<Post_Call_Survey__c> pcs = [select id from Post_Call_Survey__c where Post_Call_Survey__c.Call_Guid__c IN :callObjectSet LIMIT 1];
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, NVMContactWorld__NVM_Agent_Id__c FROM User WHERE Id IN :ownerIdSet]);
        //If no PCS record found then nothing to link
        if(pcs.isEmpty()){
            return; 
        }
        
        else{
            for(Task taskLoop : taskList){
                // Update information on PCS
                if(userMap.containsKey(taskLoop.OwnerId)){
                    pcs[0].Agent__c = taskLoop.OwnerId;
                    pcs[0].Agent_ID__c = Integer.valueOf(userMap.get(taskLoop.OwnerId).NVMContactWorld__NVM_Agent_Id__c);
                    pcs[0].Account__c = taskLoop.WhatId;
                }
            }
            update pcs[0];
        }
    }
}