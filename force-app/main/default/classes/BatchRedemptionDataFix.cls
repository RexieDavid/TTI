/*******************************************************************************************************
* Class Name      	: BatchRedemptionDataFix
* Description		: Batch Apex class to run once for new Redemption data model to update data
* Author          	: AFDigital - Lawrence Catan
* Created On      	: 04-18-2023
* Modification Log	: 
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Lawrence Catan     	04-18-2023		1000				Initial version
******************************************************************************************************/
global class BatchRedemptionDataFix implements Database.Batchable<sObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc){
        // Query Purchased Products and Redemptions
        return Database.getQueryLocator([
			SELECT Id, Related_Redemption__c, 
            (SELECT Id, PurchasedProducts__c, createddate FROM Redemptions__r ORDER BY CreatedDate) 
            FROM PurchasedProducts__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //Query Purchased Products and Line Items
        List<PurchasedProducts__c> PP_LineItemList = [SELECT id, (SELECT Id, Product__c,Purchased__c, Quantity__c, Required__c, PurchasedProduct__c FROM Purchased_Product_Line_Items__r) FROM PurchasedProducts__c];
        
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
        
        //Map Purchased Products and Line Items
        for(PurchasedProducts__c p: PP_LineItemList){
            PP_LineItemMap.put(p.id, p.Purchased_Product_Line_Items__r);
        }
        
        //Loop through Purchased Products
        for(PurchasedProducts__c p: (List<PurchasedProducts__c>)scope){
            
            
            //Check if only 1 Redemption
            if(p.Redemptions__r.size()==1 && p.Related_Redemption__c == NULL){
              System.debug('called');
              //Loop on Redemption
              for(Redemptions__c redemption: p.Redemptions__r){
                
                //Update Purchased Product's 
                p.Related_Redemption__c = redemption.id;
                toUpdatePP_List.add(p);
              }
              
            }
            
            //Check for multiple redemptions
            if(p.Redemptions__r.size()>1){
                             
              //if Related_Redemption__c == NULL, assign Oldest Redemption record
              if(p.Related_Redemption__c == NULL){
                  p.Related_Redemption__c = p.Redemptions__r[0].id;
                  toUpdatePP_List.add(p);
              }  
                
              //Oldest Redemption record retains Purchased Product so start from index[1]  
                for(Integer i = 1; i < p.Redemptions__r.size(); i++ ){
                    
                    //Create Purchased Product and clone Line Items
                    PurchasedProducts__c newPurchase = new PurchasedProducts__c();
                    newPurchase.Related_Redemption__c = p.Redemptions__r[i].id;
                    newPP_List.add(newPurchase);
                    
                    //Map Line Items to Redemption for update later
                    redPLI_Map.put(p.Redemptions__r[i].id, new List<PurchasedProductLineItem__c>(PP_LineItemMap.get(p.id).deepclone()));
                    
                    //List<PurchasedProductLineItem__c> lineItemCopy = PP_LineItemMap.get(p.id).deepclone();
                    
                    //System.debug('line item map = ' + PP_LineItemMap.get(p.id));
                    //System.debug('lineItemCopy= ' + lineItemCopy);
                    //Loop through cloned list
                    /*for(PurchasedProductLineItem__c pli: lineItemCopy){
                        //pli.PurchasedProduct__c = newPurchase.id;
                        newPP_Item_List.add(pli);
                    }*/
                    
                }
                
            }
        }
        
        //Insert new Purchased Products
        if(!newPP_List.isEmpty()){
            insert newPP_List;
        }
        
        //Loop through new Purchased Products to update Redemption
        for(PurchasedProducts__c p: newPP_List){
            for(Redemptions__c redemption: [SELECT id, PurchasedProducts__c FROM Redemptions__c WHERE Id=: p.Related_Redemption__c]){
                redemption.PurchasedProducts__c = p.id;
                toUpdateRedemption.add(redemption);
            }
        }
        
        
        
        if(!toUpdateRedemption.isEmpty()){
            update toUpdateRedemption;
        }
        
         //Loop through Redemption Map to insert Purchased Product Line Items
        for(Redemptions__c redemption: [SELECT id, purchasedproducts__c FROM Redemptions__c WHERE Id =: redPLI_Map.keyset()]){
            
            for(PurchasedProductLineItem__c pli: redPLI_Map.get(redemption.id)){
                pli.PurchasedProduct__c = redemption.purchasedproducts__c;
				newPP_Item_List.add(pli);
            }
        }
                
        if(!newPP_Item_List.isEmpty()){
            insert newPP_Item_List;
        }
        
        if(!toUpdatePP_List.isEmpty()){
            update toUpdatePP_List;
        }
        
        //Query Redeemed Products and Redemptions
        List<RedeemedProducts__c> rpRedempList = [SELECT Id, Related_Redemption__c, (SELECT Id, RedeemedProducts__c, CreatedDate FROM Redemptions__r ORDER BY CreatedDate) FROM RedeemedProducts__c];
        
        //Query Redeemed Products and Line Items
        List<RedeemedProducts__c> rpLineItemsList = [SELECT id, (SELECT Id, Name, Product__c, Quantity__c, RedeemedProduct__c FROM Redeemed_Product_Items__r) FROM RedeemedProducts__c];
		
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
        
        //Loop through Redeemed Products
        for(RedeemedProducts__c rp: rpRedempList){
            
            //Check if only 1 Redemption
            if(rp.Redemptions__r.size()==1 && rp.Related_Redemption__c == NULL){
                System.debug('called');
                //Loop on Redemption
                for(Redemptions__c redemption: rp.Redemptions__r){
                    
                    //Update Purchased Product's 
                    rp.Related_Redemption__c = redemption.id;
                    toUpdateRedeemProd_List.add(rp);
                }            
        	}
            
            //Check for multiple redemptions
            if(rp.Redemptions__r.size()>1){
                
                //if Related_Redemption__c == NULL, assign Oldest Redemption record
                if(rp.Related_Redemption__c == NULL){
                    rp.Related_Redemption__c = rp.Redemptions__r[0].id;
                    toUpdateRedeemProd_List.add(rp);
                }
                
                //Oldest Redemption record retains Purchased Product so start from index[1]  
                for(Integer i = 1; i < rp.Redemptions__r.size(); i++ ){
                    
                    //Create Redeemed Product and clone Line Items
                    RedeemedProducts__c newRP = new RedeemedProducts__c();
                    newRP.Related_Redemption__c = rp.Redemptions__r[i].id;
                    newRedeemProd_List.add(newRP);
                    
                    //Map Line Items to Redemption for update later
                    rpiPLI_Map.put(rp.Redemptions__r[i].id, new List<RedeemedProductItem__c>(redeemProd_LineItemMap.get(rp.id).deepclone()));
                }
                
            }
        }
        
        //Insert new Redeemed Products
        if(!newRedeemProd_List.isEmpty()){
            insert newRedeemProd_List;
        }
        
        //Loop through new Redeemed Products to update Redemption
        for(RedeemedProducts__c rp: newRedeemProd_List){
            for(Redemptions__c redemption: [SELECT id, RedeemedProducts__c FROM Redemptions__c WHERE Id=: rp.Related_Redemption__c]){
                redemption.RedeemedProducts__c = rp.id;
                toUpdateRP_Redemption.add(redemption);
            }
        }
        
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