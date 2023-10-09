/**
* @author: Jerome Liwanag
* @date: Aug 2017
* @description: This class handles all CRUD operations for the
* Project Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class ProjectTriggerHandler {
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Project Object
    */ 
    public static void onBeforeInsert(List<Project__c> newProjects) {
        assignOwnerId(newProjects);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method handles all on After Insert
    * functionalities of the Project Object
    */ 
    public static void onAfterInsert(List<Project__c> newProjects) {
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method handles all on Before Update
    * functionalities of the Project Object
    */ 
    public static void onBeforeUpdate(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap) {
        assignOwnerId(newProjects);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method handles all on After Update
    * functionalities of the Project Object
    */ 
    public static void onAfterUpdate(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap) {
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Aug 2017
    * @description: This method assigns the region's Assigned_To__c value
    * to the records ownerid'
    */ 
    public static void assignOwnerId(List<Project__c> projList) {
        
        // Maps Id to project record
        Map<Id,Project__c> projMap = new Map<Id,Project__c>();
        Set<String> postCodeSet = new Set<String>(); 
        for(Project__c projLoop : projList) {
            if(projLoop.State__c != null && projLoop.State__c != '' && projLoop.Postcode__c != '' && projLoop.Postcode__c != null){
                postCodeSet.add(projLoop.Postcode__c);
                projMap.put(projLoop.Id,projLoop);
            }
        }
        
        // Get the list of post codes 
        List<Postcode__c> postCodeList = [SELECT ID,JSS_Region__r.Assigned_To__c, JSS_Region__r.Region_State__c,  MOG_Region__r.Region_State__c, MOG_Region__r.Assigned_To__c, Territory__c, Postcode__c FROM Postcode__c WHERE Postcode__c IN :postCodeSet];
        
        
        // Assigns postcode's region - Assigned_To__c to the record's OwnerId
        for(Project__c projLoop : projList) {
            for(Postcode__c postCodeLoop : postCodeList) {
                Integer counter = 0;
                for (State_Names__c stateNamesLoop : State_Names__c.getall().Values()) {
                    if(projLoop.Postcode__c == postCodeLoop.Postcode__c) {
                        if(postCodeLoop.JSS_Region__c != null && counter == 0 && 
                          (projLoop.State__c == postCodeLoop.JSS_Region__r.Region_State__c || (projLoop.State__c == stateNamesLoop.State__c && stateNamesLoop.State_ABV__c == postCodeLoop.JSS_Region__r.Region_State__c)) ) {
                            counter++;
                            projLoop.ownerId = postCodeLoop.JSS_Region__r.Assigned_to__c;
                        } else if(postCodeLoop.MOG_Region__c != null && projLoop.State__c == postCodeLoop.MOG_Region__r.Region_State__c && counter == 0) {
                            counter++;
                            projLoop.ownerId = postCodeLoop.MOG_Region__r.Assigned_to__c;
                        }
                    }
                }
            }
        }
        
        
    }
    
}