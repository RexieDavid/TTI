/**
* @author: Stephen James Laylo
* @date: June 2017
* @description: This class handles all CRUD operations for the
* Commercial Opportunity Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class CommercialOpportunityTriggerHandler {
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Commercial Opportunity
    */ 
    public static void onBeforeInsert(List<Commercial_Opportunity__c> newCommercialOpportunities) {
        
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on Before Update
    * functionalities of the Commercial Opportunity
    */ 
    public static void onBeforeUpdate(List<Commercial_Opportunity__c> newCommercialOpportunities, Map<Id, Commercial_Opportunity__c> oldCommercialOpportunitiesMap) {
        
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on After Insert
    * functionalities of the Commercial Opportunity
    */ 
    public static void onAfterInsert(List<Commercial_Opportunity__c> newCommercialOpportunities) {
        //copyCommercialOpportunityAccountIdToSalesPitchesAccountId(newCommercialOpportunities, null);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on After Update
    * functionalities of the Commercial Opportunity
    */ 
    public static void onAfterUpdate(List<Commercial_Opportunity__c> newCommercialOpportunities, Map<Id, Commercial_Opportunity__c> oldCommercialOpportunitiesMap) {
        copyCommercialOpportunityAccountIdToSalesPitchesAccountId(newCommercialOpportunities, oldCommercialOpportunitiesMap);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles the value of Commercial Opportunity Account Id
    */ 
    public static void copyCommercialOpportunityAccountIdToSalesPitchesAccountId(List<Commercial_Opportunity__c> newCommercialOpportunities, Map<Id, Commercial_Opportunity__c> oldCommercialOpportunitiesMap) {
        /*Set<Id> commercialOpportunityIds = new Set<Id>();
        if (oldCommercialOpportunitiesMap == null) {
            oldCommercialOpportunitiesMap = new Map<Id, Commercial_Opportunity__c>();
        }
        
        for (Commercial_Opportunity__c commercialOpportunity : newCommercialOpportunities) {
            Commercial_Opportunity__c oldCommercialOpportunity = (oldCommercialOpportunitiesMap.containsKey(commercialOpportunity.Id) ? oldCommercialOpportunitiesMap.get(commercialOpportunity.Id) : null);
            
            if (oldCommercialOpportunity == null) {
                commercialOpportunityIds.add(commercialOpportunity.Id);
            } else {
                if (oldCommercialOpportunity.Account__c != commercialOpportunity.Account__c) {
                    commercialOpportunityIds.add(commercialOpportunity.Id);
                }
            }
        }*/
        
        List<Sales_Pitch__c> salesPitchesToBeUpdated = [SELECT Id, Account__c, Opportunity_Product_Category__c FROM Sales_Pitch__c WHERE Commercial_Opportunity__c IN :newCommercialOpportunities];
        
        update salesPitchesToBeUpdated;
    }
    
}