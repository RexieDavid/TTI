/**
* @author: Jerome Liwanag
* @date: May 2017
* @description: This class handles all CRUD operations for the
* Asset Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class AssetTriggerHandler {
    
    /**
    * @author: Jerome Liwanag
    * @date: May 2017
    * @description: This method handles all on After Insert
    * functionalities of the Account
    */ 
    public static void onAfterInsert(List<Asset> assetList) {
        countAssetsBasedOnAccount(assetList, null);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: May 2017
    * @description: This method handles all on After Delete
    * functionalities of the Account
    */ 
    public static void onAfterDelete(List<Asset> oldAssetList) {
        countAssetsBasedOnAccount(null, oldAssetList);
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: May 2017
    * @description: This method handles the value of Number 
    * of Assets field for the Account
    */ 
    public static void countAssetsBasedOnAccount(List<Asset> assetList, List<Asset> oldAssetList){
        
        Set<Id> assetIds = new Set<Id>();
        Map<Id,List<Asset>> accountAssetsMap = new Map<Id,List<Asset>>();
        
        // On Insert of an Asset
        if(assetList != null){
            for(Asset assetLoop : assetList){
                assetIds.add(assetLoop.Id);
            }
            
            // Maps the list of asset to its matching Account
            for(Asset assetLoop : [SELECT Id, Contact.AccountId FROM Asset WHERE Id IN :assetIds]){
                if(assetLoop.contact.AccountId != null){
                    if(!accountAssetsMap.containsKey(assetLoop.contact.AccountId)){
                        
                        accountAssetsMap.put(assetLoop.contact.AccountId, new List<Asset>{assetLoop});
                    }else{
                        accountAssetsMap.get(assetLoop.contact.AccountId).add(assetLoop);
                    }
                }    
            }
            
            List<Account> accList = new List<Account>([SELECT Id,Number_of_Assets__c FROM Account WHERE Id IN :accountAssetsMap.keySet()]);
            
            // Updates the Number of Assets field on Account
            for(Account accLoop : accList){
                if(accLoop.Number_of_Assets__c != null){
                    accLoop.Number_of_Assets__c = accLoop.Number_of_Assets__c + accountAssetsMap.get(accLoop.Id).size();
                }else{
                    accLoop.Number_of_Assets__c = accountAssetsMap.get(accLoop.Id).size();
                }
            }
            
            try{
                // Update Account Update Flags
                AccountTriggerHandler.updateMarketingPreferenceSubscriptionsRunOnce = true;
                AccountTriggerHandler.updateUsernameFromPersonAccountEmailRunOnce = true;
                AccountTriggerHandler.assignRecTypesRunOnce = true;
                AccountTriggerHandler.assignParentAccountRunOnce = true;
                AccountTriggerHandler.changeNumberFormatRunOnce = true;
                update accList;
            }catch(DMLException e){
                System.debug('ERROR: ' + e.getMessage());
            }
        }
    
        assetIds.clear();
        accountAssetsMap.clear();
        
        // On Delete of an Asset
        if(oldAssetList != null){
            for(Asset assetLoop : oldAssetList){
                assetIds.add(assetLoop.ContactId);
            }
            
            Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,AccountId from Contact where Id IN :assetIds]);
            
            // Maps the list of asset to its matching Account
            for(Asset assetLoop : oldAssetList) {
                if(assetLoop.contactId != null){
                    if(!accountAssetsMap.containsKey(conMap.get(assetLoop.contactId).AccountId)){
                        accountAssetsMap.put(conMap.get(assetLoop.contactId).AccountId, new List<Asset>{assetLoop});
                    }else{
                        accountAssetsMap.get(conMap.get(assetLoop.contactId).AccountId).add(assetLoop);
                    }
                }    
            }
            
            List<Account> accList = new List<Account>([SELECT Id,Number_of_Assets__c FROM Account WHERE Id IN :accountAssetsMap.keySet()]);
            
            // Updates the Number of Assets field on Account
            for(Account accLoop : accList){
                if(accLoop.Number_of_Assets__c != null){
                    accLoop.Number_of_Assets__c = accLoop.Number_of_Assets__c - accountAssetsMap.get(accLoop.Id).size();
                }
            }
            
            try{
                AccountTriggerHandler.updateMarketingPreferenceSubscriptionsRunOnce = true;
                AccountTriggerHandler.updateUsernameFromPersonAccountEmailRunOnce = true;
                AccountTriggerHandler.assignRecTypesRunOnce = true;
                AccountTriggerHandler.assignParentAccountRunOnce = true;
                AccountTriggerHandler.changeNumberFormatRunOnce = true;
                update accList;
            }catch(DMLException e){
                System.debug('ERROR: ' + e.getMessage());
            }
        }
        
    }

}