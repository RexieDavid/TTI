/*******************************************************************************************************
* Class Name        : BatchRedemptionDataFix
* Description       : Batch Apex class to run once for new Redemption data model to update data
* Author            : AFDigital - Lawrence Catan
* Created On        : 04-18-2023
* Modification Log  : 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Modification ID     Description
* -----------------------------------------------------------------------------------------------------
* Lawrence Catan        04-18-2023      1000                Initial version
******************************************************************************************************/
global class BatchRedemptionDataFix_PurcProds implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // Query Purchased Products and Redemptions
        return Database.getQueryLocator([
            SELECT Id, Related_Redemption__c FROM PurchasedProducts__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> purcProds = new Set<Id>();
        
        //Query and Map Purchased Products and Line Items
        Map<Id, List<PurchasedProductLineItem__c>> PP_LineItemMap = new Map<Id, List<PurchasedProductLineItem__c>>();
        
        //List for updating Purchased Products
        List<PurchasedProducts__c> toUpdatePP_List = new List<PurchasedProducts__c>();
        
        //List for new Purchased Products
        List<PurchasedProducts__c> newPP_List = new List<PurchasedProducts__c>();
        
        //List for new Purchased Products Line Items
        List<PurchasedProductLineItem__c> newPP_Item_List = new List<PurchasedProductLineItem__c>();
        
        //List for updating Redemptions
        List<Redemptions__c> toUpdateRedemption = new List<Redemptions__c>();
        
        //Map for Purchased Products and Line Items
        Map<Id, List<PurchasedProductLineItem__c>> redPLI_Map = new Map<Id, List<PurchasedProductLineItem__c>>();
        
        //List for Redemptions from PP
        List<Redemptions__c> lstRelatedRedemptionsOfPP = new List<Redemptions__c>();

        //Map of Redeemed Products with Redemptions
        Map<Id, List<Redemptions__c>> mapPPandRedemption = new Map<Id, List<Redemptions__c>>();

        //Query Purchased Products and Line Items
        List<PurchasedProducts__c> PP_LineItemList = new List<PurchasedProducts__c>();

        //Map for new Redeemed Products to Redemptions
        Map<Id, Id> newPP_RedemptionMap = new Map<Id, Id>();

        //Set for new purchased products
        Set<Id> newPurchasedProdsRedemption = new Set<Id>();

        //Get Purchased Products Ids
        for(PurchasedProducts__c p: (List<PurchasedProducts__c>)scope){
            purcProds.add(p.id);
        }

        //Query Purchased Products and Line Items
        PP_LineItemList = [SELECT id, (SELECT Id, Product__c,Purchased__c, Quantity__c, Required__c, PurchasedProduct__c FROM Purchased_Product_Line_Items__r) FROM PurchasedProducts__c WHERE Id=: purcProds];

        system.debug('*** PP_LineItemList: '+PP_LineItemList);
        system.debug('*** PP_LineItemList.size(): '+PP_LineItemList.size());

        //Map Purchased Products and Line Items
        for(PurchasedProducts__c p: PP_LineItemList){
            PP_LineItemMap.put(p.id, p.Purchased_Product_Line_Items__r);
        }

        system.debug('*** PP_LineItemMap: '+PP_LineItemMap);
        system.debug('*** PP_LineItemMap.size(): '+PP_LineItemMap.size());

        //Loop through Purchased Products Ids to Map with Redemption
        if(purcProds.size() > 0){

            //Query related redemptions from PP
            lstRelatedRedemptionsOfPP = [SELECT Id, PurchasedProducts__c, CreatedDate FROM Redemptions__c WHERE PurchasedProducts__c =: purcProds ORDER BY CreatedDate LIMIT 3000];
            system.debug('*** lstRelatedRedemptionsOfPP: '+lstRelatedRedemptionsOfPP);
            system.debug('*** lstRelatedRedemptionsOfPP.size(): '+lstRelatedRedemptionsOfPP.size());
            for(ID ppid : purcProds){
                
                //Loop on Redemptions and check if same Purchased Products ID
                for(Redemptions__c redemption: lstRelatedRedemptionsOfPP){
                    
                    if(ppid == redemption.PurchasedProducts__c){
                        
                        if(mapPPandRedemption.containskey(ppid)){
                            mapPPandRedemption.get(ppid).add(redemption);
                        } else {
                            mapPPandRedemption.put(ppid, new List<Redemptions__c>{redemption});   
                        }
                    }
                }
            }
        }

        system.debug('*** mapPPandRedemption: '+mapPPandRedemption);
        system.debug('*** mapPPandRedemption.size(): '+mapPPandRedemption.size());
        
        //Loop through Purchased Products
        for(PurchasedProducts__c pp: (List<PurchasedProducts__c>)scope){

            if(mapPPandRedemption.size() > 0){

                //Check if only 1 Redemption
                if(mapPPandRedemption.get(pp.id) != NULL && mapPPandRedemption.get(pp.id).size()==1 && pp.Related_Redemption__c == NULL){
                    //Loop on Redemption
                    for(Redemptions__c redemption: mapPPandRedemption.get(pp.id)){
                        //Update Purchased Product's 
                        pp.Related_Redemption__c = redemption.id;
                        toUpdatePP_List.add(pp);
                    }
                }
                
                //Check for multiple redemptions
                if(mapPPandRedemption.get(pp.id) != NULL && mapPPandRedemption.get(pp.id).size()>1){
                                
                    //if Related_Redemption__c == NULL, assign Oldest Redemption record
                    if(pp.Related_Redemption__c == NULL){
                        pp.Related_Redemption__c = mapPPandRedemption.get(pp.id)[0].id;
                        toUpdatePP_List.add(pp);
                    }  
                        
                    //Oldest Redemption record retains Purchased Product so start from index[1]  
                    for(Integer i = 1; i < mapPPandRedemption.get(pp.id).size(); i++ ){
                        
                        //Create Purchased Product and clone Line Items
                        PurchasedProducts__c newPurchase = new PurchasedProducts__c();
                        newPurchase.Related_Redemption__c = mapPPandRedemption.get(pp.id)[i].id;
                        newPP_List.add(newPurchase);
                        
                        //Map Line Items to Redemption for update later
                        redPLI_Map.put(mapPPandRedemption.get(pp.id)[i].id, new List<PurchasedProductLineItem__c>(PP_LineItemMap.get(pp.id).deepclone()));  

                    }  
                }
            }
        }
        
        system.debug('*** newPP_List: '+newPP_List);
        system.debug('*** newPP_List.size(): '+newPP_List.size());

        //Insert new Purchased Products
        if(!newPP_List.isEmpty()){
            insert newPP_List;
        }

        for(PurchasedProducts__c pp: newPP_List){
            newPurchasedProdsRedemption.add(pp.Related_Redemption__c);
            newPP_RedemptionMap.put(pp.Related_Redemption__c, pp.id);
        }

        system.debug('*** newPurchasedProdsRedemption: '+newPurchasedProdsRedemption);
        system.debug('*** newPurchasedProdsRedemption.size(): '+newPurchasedProdsRedemption.size());
        
        //Loop through new Purchased Products to update Redemption
        for(Redemptions__c redemption: [SELECT id, PurchasedProducts__c FROM Redemptions__c WHERE Id=: newPurchasedProdsRedemption LIMIT 3000]){
            redemption.PurchasedProducts__c = newPP_RedemptionMap.get(redemption.id);
            toUpdateRedemption.add(redemption);
        }
        
        system.debug('*** toUpdateRedemption: '+toUpdateRedemption);
        system.debug('*** toUpdateRedemption.size(): '+toUpdateRedemption.size());

        if(!toUpdateRedemption.isEmpty()){
            update toUpdateRedemption;
        }

        system.debug('*** redPLI_Map: '+redPLI_Map);
        system.debug('*** redPLI_Map.size(): '+redPLI_Map.size());
        
         //Loop through Redemption Map to insert Purchased Product Line Items
        for(Redemptions__c redemption: [SELECT id, purchasedproducts__c FROM Redemptions__c WHERE Id =: redPLI_Map.keyset() LIMIT 3000]){
            
            for(PurchasedProductLineItem__c pli: redPLI_Map.get(redemption.id)){
                pli.PurchasedProduct__c = redemption.purchasedproducts__c;
                newPP_Item_List.add(pli);
            }
        }

        system.debug('*** newPP_Item_List: '+newPP_Item_List);
        system.debug('*** newPP_Item_List.size(): '+newPP_Item_List.size());
                
        if(!newPP_Item_List.isEmpty()){
            insert newPP_Item_List;
        }

        system.debug('*** toUpdatePP_List: '+toUpdatePP_List);
        system.debug('*** toUpdatePP_List.size(): '+toUpdatePP_List.size());
        
        if(!toUpdatePP_List.isEmpty()){
            update toUpdatePP_List;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}