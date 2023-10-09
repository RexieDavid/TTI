/**
* @author: Jerome Liwanag
* @date: Apr 2017
* @description: This class handles all CRUD operations for the
* Postcode Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class PostcodeTriggerHandler {
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Postcode
    */ 
    public static void onBeforeInsert(List<Postcode__c> postList) {
        assignRegion(postList);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on Before Update
    * functionalities of the Postcode
    */ 
    public static void onBeforeUpdate(List<Postcode__c> postList, Map<Id,Postcode__c> postOldMap) {
        assignRegion(postList);
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method assigns region name for the
    * JSS region field for a postcode record
    */ 
    public static void assignRegion(List<Postcode__c> postList){
        
        List<Region__c> regionList = [SELECT Id, Region_Name__c FROM Region__c WHERE Region_Name__c != null];
    	
    	Map<String, String> regionMap = new Map<String, String>();
    
    	for (Region__c regionLoop : regionList){
    		regionMap.put(regionLoop.Region_Name__c, regionLoop.id);
    	}
    
    	for (Postcode__c postCodeLoop : postList){		
    		if (postCodeLoop.Territory__c != null && regionMap.containsKey(postCodeLoop.Territory__c)){		
    			postCodeLoop.JSS_Region__c = regionMap.get(postCodeLoop.Territory__c);
    		}		
    	}
    }
}