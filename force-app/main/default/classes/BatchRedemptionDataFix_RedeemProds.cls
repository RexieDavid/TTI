/*******************************************************************************************************
* Class Name        : BatchRedemptionDataFix_RedeemProds
* Description       : Batch Apex class to run once for new Redemption data model to update data
* Author            : AFDigital - Lawrence Catan
* Created On        : 04-26-2023
* Modification Log  : 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Modification ID     Description
* -----------------------------------------------------------------------------------------------------
* Lawrence Catan        04-26-2023      1000                Initial version
* Lawrence Catan        05-18-2023      2000                Restructured query to avoid subquery too many rows
******************************************************************************************************/
global class BatchRedemptionDataFix_RedeemProds implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        // Query Redeemed Products and Redemptions
        return Database.getQueryLocator([
            SELECT Id, Related_Redemption__c
            FROM RedeemedProducts__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> redeemProds = new Set<Id>();
        
        //Get Redeemed Products Ids
        for(RedeemedProducts__c rp: (List<RedeemedProducts__c>)scope){
            redeemProds.add(rp.id);
        }
        
        //Query Redeemed Products and Line Items
        List<RedeemedProducts__c> rpLineItemsList = [SELECT id, (SELECT Id, Name, Product__c, Quantity__c, RedeemedProduct__c FROM Redeemed_Product_Items__r) FROM RedeemedProducts__c WHERE Id=: redeemProds];
        
        //Map for Redeemed Products and Line Items
        Map<Id, List<RedeemedProductItem__c>> redeemProd_LineItemMap = new Map<Id, List<RedeemedProductItem__c>>();
        
        //List for updating Redeemed Products
        List<RedeemedProducts__c> toUpdateRedeemProd_List = new List<RedeemedProducts__c>();
        
        //List for new Redeemed Products
        List<RedeemedProducts__c> newRedeemProd_List = new List<RedeemedProducts__c>();
        
        //List for new Redeemed Products Line Items
        List<RedeemedProductItem__c> newRedeemProd_Item_List = new List<RedeemedProductItem__c>();
        
        //List for updating Redemptions from Redeemed Products
        List<Redemptions__c> toUpdateRP_Redemption = new List<Redemptions__c>();
        
        //Map for Redeemed Products and Line Items
        Map<Id, List<RedeemedProductItem__c>> rpiPLI_Map = new Map<Id, List<RedeemedProductItem__c>>();
        
        //Map Redeemed Products and Line Items
        for(RedeemedProducts__c rp: rpLineItemsList){
            redeemProd_LineItemMap.put(rp.id, rp.Redeemed_Product_Items__r);
        }
        
        //List for Redemptions from Redeemed Products
        List<Redemptions__c> currentRP_Redemptions = new List<Redemptions__c>();
        
        //Query Redemptions from Redeemed Products
        currentRP_Redemptions = [SELECT Id, RedeemedProducts__c, CreatedDate FROM Redemptions__c 
                                 WHERE RedeemedProducts__c =: redeemProds ORDER BY CreatedDate];
        
        //Map of Redeemed Products with Redemptions
        Map<Id, List<Redemptions__c>> redeemProd_RedemptionMap = new Map<Id, List<Redemptions__c>>();
        
        //Map for new Redeemed Products to Redemptions
        Map<Id, Id> newRP_RedemptionMap = new Map<Id, Id>();
            
        //Loop through Redeemed Products Ids to Map with Redemption
        for(ID rpid : redeemProds){
            
            //Loop on Redemptions and check if same RedeemedProducts__c ID
            for(Redemptions__c redemption: currentRP_Redemptions){
                
                if(rpid == redemption.RedeemedProducts__c){
                    
                    if(redeemProd_RedemptionMap.containskey(rpid)){
                        redeemProd_RedemptionMap.get(rpid).add(redemption);
                    } else {
                        redeemProd_RedemptionMap.put(rpid, new List<Redemptions__c>{redemption});   
                    }
                    
                }
            }
        }
        
        //Loop through Redeemed Products
        for(RedeemedProducts__c rp: (List<RedeemedProducts__c>)scope){
            System.debug('rp = ' + rp);
            System.debug('map = ' + redeemProd_RedemptionMap);
            //System.debug('map size = ' + redeemProd_RedemptionMap.get(rp.id).size());
            //System.debug('rp related redemption = ' + rp.Related_Redemption__c);
            //Check if only 1 Redemption
            if(redeemProd_RedemptionMap.get(rp.id) != NULL && redeemProd_RedemptionMap.get(rp.id).size()==1 && rp.Related_Redemption__c == NULL){
                
                //Loop on Redemption
                for(Redemptions__c redemption: redeemProd_RedemptionMap.get(rp.id)){
                    
                    //Update Purchased Product's 
                    rp.Related_Redemption__c = redemption.id;
                    toUpdateRedeemProd_List.add(rp);
                }            
            }
            
            //Check for multiple redemptions
            if(redeemProd_RedemptionMap.get(rp.id) != NULL && redeemProd_RedemptionMap.get(rp.id).size()>1){
                
                //if Related_Redemption__c == NULL, assign Oldest Redemption record
                if(rp.Related_Redemption__c == NULL){
                    rp.Related_Redemption__c = redeemProd_RedemptionMap.get(rp.id)[0].id;
                    toUpdateRedeemProd_List.add(rp);
                }
                
                //Oldest Redemption record retains Purchased Product so start from index[1]  
                for(Integer i = 1; i < redeemProd_RedemptionMap.get(rp.id).size(); i++ ){
                    
                    //Create Redeemed Product and clone Line Items
                    RedeemedProducts__c newRP = new RedeemedProducts__c();
                    newRP.Related_Redemption__c = redeemProd_RedemptionMap.get(rp.id)[i].id;
                    newRedeemProd_List.add(newRP);
                    //newRP_RedemptionMap.put(newRP.Related_Redemption__c, newRP.id);
                    
                    //Map Line Items to Redemption for update later
                    rpiPLI_Map.put(redeemProd_RedemptionMap.get(rp.id)[i].id, new List<RedeemedProductItem__c>(redeemProd_LineItemMap.get(rp.id).deepclone()));
                }
                
            }
        }

        //Insert new Redeemed Products
        if(!newRedeemProd_List.isEmpty()){
            insert newRedeemProd_List;
        }
        
        Set<Id> newRedeemProdsRedemption = new Set<Id>();
        for(RedeemedProducts__c rp: newRedeemProd_List){
            newRedeemProdsRedemption.add(rp.Related_Redemption__c);
            newRP_RedemptionMap.put(rp.Related_Redemption__c, rp.id);
        }
        
        //Loop through new Redeemed Products to update Redemption
        //for(RedeemedProducts__c rp: newRedeemProd_List){
            for(Redemptions__c redemption: [SELECT id, RedeemedProducts__c FROM Redemptions__c WHERE Id=: newRedeemProdsRedemption]){
                redemption.RedeemedProducts__c = newRP_RedemptionMap.get(redemption.id);
                toUpdateRP_Redemption.add(redemption);
            }
        //}
        
        if(!toUpdateRP_Redemption.isEmpty()){
            update toUpdateRP_Redemption;
        }
        
        //Loop through Redemption Map to insert Purchased Product Line Items
        for(Redemptions__c redemption: [SELECT id, RedeemedProducts__c FROM Redemptions__c WHERE Id =: rpiPLI_Map.keyset()]){
            
            for(RedeemedProductItem__c rpi: rpiPLI_Map.get(redemption.id)){
                rpi.RedeemedProduct__c = redemption.RedeemedProducts__c;
                newRedeemProd_Item_List.add(rpi);
            }
        }
        
        if(!newRedeemProd_Item_List.isEmpty()){
            insert newRedeemProd_Item_List;
        }
        
        if(!toUpdateRedeemProd_List.isEmpty()){
            update toUpdateRedeemProd_List;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}