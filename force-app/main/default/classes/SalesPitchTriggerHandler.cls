/**
* @author: Stephen James Laylo
* @date: June 2017
* @description: This class handles all CRUD operations for the
* Sales Pitch Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class SalesPitchTriggerHandler {
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on Before Insert
    * functionalities of the SalesPitch
    */ 
    public static void onBeforeInsert(List<Sales_Pitch__c> newSalesPitches) {
        copyCommercialOpportunityAccountIdToSalesPitchAccountId(newSalesPitches);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on Before Update
    * functionalities of the Sales Pitch
    */ 
    public static void onBeforeUpdate(List<Sales_Pitch__c> newSalesPitches, Map<Id, Sales_Pitch__c> oldSalesPitchesMap) {
        copyCommercialOpportunityAccountIdToSalesPitchAccountId(newSalesPitches);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on After Insert
    * functionalities of the Sales Pitch
    */ 
    public static void onAfterInsert(List<Sales_Pitch__c> newSalesPitches) {
        
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles all on After Update
    * functionalities of the Sales Pitch
    */ 
    public static void onAfterUpdate(List<Sales_Pitch__c> newSalesPitches, Map<Id, Sales_Pitch__c> oldSalesPitchesMap) {
        
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: June 2017
    * @description: This method handles the value of Sales Pitch Account Id
    */ 
    public static void copyCommercialOpportunityAccountIdToSalesPitchAccountId(List<Sales_Pitch__c> newSalesPitches) {
        Set<Id> commercialOpportunityIds = new Set<Id>();
        
        for (Sales_Pitch__c salesPitch : newSalesPitches) {
            commercialOpportunityIds.add(salesPitch.Commercial_Opportunity__c);
        }
        
        Map<Id, Commercial_Opportunity__c> commercialOpportunitiesMap = new Map<Id, Commercial_Opportunity__c>([SELECT Id, Account__c FROM Commercial_Opportunity__c WHERE Id IN :commercialOpportunityIds]);
        
        for (Sales_Pitch__c salesPitch : newSalesPitches) {
            if (salesPitch.Commercial_Opportunity__c != null) {
                if (commercialOpportunitiesMap.containsKey(salesPitch.Commercial_Opportunity__c)) {
                    if (commercialOpportunitiesMap.get(salesPitch.Commercial_Opportunity__c).Account__c != salesPitch.Account__c) {
                        salesPitch.Account__c = commercialOpportunitiesMap.get(salesPitch.Commercial_Opportunity__c).Account__c;
                    }
                }
            }  
        }
    }
    
}