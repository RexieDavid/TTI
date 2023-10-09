/**
 * @author: TTI
 * @date: December 2022
 * @description: This class handles logic for the AddProductRedemption component
 */
 
 public with sharing class AddProductRedemptionController {
    
    @AuraEnabled (cacheable=true)
    public static redemptionProductWrapper getRedemptionCampaignProductItem(String redempCampaignId, String redeemedProductId){
        List<RedeemableProductItem__c> listOfRedeemableProductItem = new List<RedeemableProductItem__c>();
        List<PurchasedProductLineItem__c> listOfPurchaseProductItem = new List<PurchasedProductLineItem__c>();
        List<Redemption_Campaigns__c> listOfRedempCampaign = new List<Redemption_Campaigns__c>();
        List<RedeemedProductItem__c> listOfRedeemedProductItem = new List<RedeemedProductItem__c>();
        Set<Id> setRedeemedProductIds = new Set<Id>();

        try {

            listOfRedeemedProductItem = [SELECT Id, Product__c, RedeemedProduct__c
                                           FROM RedeemedProductItem__c 
                                          WHERE RedeemedProduct__c =: redeemedProductId];

            if(listOfRedeemedProductItem.size() > 0){
                for(RedeemedProductItem__c rpi : listOfRedeemedProductItem){
                    setRedeemedProductIds.add(rpi.Product__c);
                }
            }

            listOfRedempCampaign = [SELECT Id, PurchasedProducts__c, RedeemableProducts__c 
                                      FROM Redemption_Campaigns__c 
                                     WHERE Id =: redempCampaignId 
                                       AND PurchasedProducts__c != null
                                       AND RedeemableProducts__c != null
                                     LIMIT 1];

            if (listOfRedempCampaign.size() > 0) {
                listOfRedeemableProductItem = [SELECT Id, Name, Product__c, Product__r.Name, Product_Name__c,
                                                      Quantity__c, RedeemableProduct__c, Required__c  
                                                 FROM RedeemableProductItem__c 
                                                WHERE RedeemableProduct__c = : listOfRedempCampaign[0].RedeemableProducts__c
                                                  AND Product__c NOT IN: setRedeemedProductIds
                                                  AND Required__c = FALSE];
            
                listOfPurchaseProductItem = [SELECT Id, Name, Product__c, Product__r.Name, Product_Name__c,
                                                      Quantity__c, PurchasedProduct__c  
                                                 FROM PurchasedProductLineItem__c 
                                                WHERE PurchasedProduct__c = : listOfRedempCampaign[0].PurchasedProducts__c];
            }

            redemptionProductWrapper wrap = new redemptionProductWrapper();
            wrap.purchaseProductItem = listOfPurchaseProductItem;
            wrap.redeemableProductItem = listOfRedeemableProductItem;

            return wrap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static void createPurchasedAndRedeemProducts(String redemptionId, String redemptionCampaignId, List<String> lstPurchasedProductItem, List<String> lstRedeemedProductItem){
        List<Redemptions__c> lstRedemptions = new List<Redemptions__c>();
        List<RedeemedProductItem__c> lstRedeemedProductItemToUpdate = new List<RedeemedProductItem__c>();
        List<Redemption_Campaigns__c> lstRedempCampaign = new List<Redemption_Campaigns__c>();
        List<PurchasedProductLineItem__c> lstPPLI = new List<PurchasedProductLineItem__c>();
        List<PurchasedProductLineItem__c> lstPPLIToCreate = new List<PurchasedProductLineItem__c>();
        List<RedeemableProductItem__c> listOfRequiredRedeemableProductItem = new List<RedeemableProductItem__c>();
        RedeemedProducts__c rp;
        PurchasedProducts__c ppCopy;
        Redemptions__c redemp;
        String newRedeemedProductModel = '';
        String finalRedeemedProductModel = '';
        Id pp;
        Id redeemedProdId;

        try{

            if(String.isNotBlank(redemptionId) && String.isNotBlank(redemptionCampaignId)){

                lstRedemptions = [SELECT Id, RedeemedProducts__c 
                                    FROM Redemptions__c 
                                   WHERE Id = :redemptionId 
                                     AND RedeemedProducts__c != null 
                                   LIMIT 1];

                lstRedempCampaign = [SELECT Id, PurchasedProducts__c, RedeemableProducts__c 
                                           FROM Redemption_Campaigns__c 
                                          WHERE Id = :redemptionCampaignId 
                                            AND PurchasedProducts__c != null
                                            AND RedeemableProducts__c != null 
                                          LIMIT 1];
                
                if(lstRedemptions.size() > 0){
                    redeemedProdId = lstRedemptions[0].RedeemedProducts__c;
                }else{
                    rp = new RedeemedProducts__c();
                    rp.Related_Redemption__c = redemptionId;
                    insert rp;
                    redeemedProdId = rp.id;
                }
            
                if(lstRedeemedProductItem.size() > 0){
                    for(String rpis : lstRedeemedProductItem){
                        String[] str = rpis.split(';');
                        RedeemedProductItem__c rpi = new RedeemedProductItem__c();
                        rpi.RedeemedProduct__c = redeemedProdId;
                        rpi.Product__c = str[0];
                        rpi.Quantity__c = Integer.valueOf(str[1]);
                        lstRedeemedProductItemToUpdate.add(rpi);
                    }

                    listOfRequiredRedeemableProductItem = [SELECT Id, Name, Product__c, Product__r.Name, Product_Name__c,
                                                                Quantity__c, RedeemableProduct__c, Required__c  
                                                            FROM RedeemableProductItem__c
                                                            WHERE RedeemableProduct__c = :lstRedempCampaign[0].RedeemableProducts__c
                                                            AND Required__c = TRUE];
                
                    for(RedeemableProductItem__c reqrpi : listOfRequiredRedeemableProductItem){
                        RedeemedProductItem__c rpi = new RedeemedProductItem__c();
                        rpi.RedeemedProduct__c = redeemedProdId;
                        rpi.Product__c = reqrpi.Product__c;
                        rpi.Quantity__c = reqrpi.Quantity__c;
                        rpi.Required__c = true;
                        lstRedeemedProductItemToUpdate.add(rpi);
                    }
                
                    if(lstRedeemedProductItemToUpdate.size() > 0){
                        insert lstRedeemedProductItemToUpdate;
                        for(RedeemedProductItem__c rpi : [Select Id, RedeemedProduct__c, Product_Model__c, Quantity__c FROM RedeemedProductItem__c WHERE RedeemedProduct__c = : redeemedProdId]){
                            newRedeemedProductModel += rpi.Product_Model__c + '(' + rpi.Quantity__c + ')' + ', ';
                        }
                        finalRedeemedProductModel = newRedeemedProductModel.removeEnd(', ');
                    }
                }

                if(lstRedempCampaign.size() > 0){
                    pp = lstRedempCampaign[0].PurchasedProducts__c;

                    redemp = new Redemptions__c();
                    redemp.Id = redemptionId;
                    redemp.RedeemedProducts__c = redeemedProdId;
                    redemp.RedeemedProductModel__c = finalRedeemedProductModel;

                    lstRedemptions = [SELECT Id, RedeemedProducts__c FROM Redemptions__c WHERE Id = :redemptionId AND PurchasedProducts__c = null LIMIT 1];
                    if(lstRedemptions.size() > 0){
                        ppCopy = new PurchasedProducts__c();
                        ppCopy.Related_Redemption__c = redemptionId;
                        insert ppCopy;

                        lstPPLI = [SELECT Id, PurchasedProduct__c, Product__c, Quantity__c, Required__c FROM PurchasedProductLineItem__c WHERE PurchasedProduct__c =: pp];
                        if(lstPPLI.size() > 0){
                            for(PurchasedProductLineItem__c ppli : lstPPLI){
                                PurchasedProductLineItem__c newppli = new PurchasedProductLineItem__c();
                                newppli.Product__c = ppli.Product__c;
                                newppli.Quantity__c = ppli.Quantity__c;
                                newppli.Required__c = ppli.Required__c;
                                newppli.PurchasedProduct__c = ppCopy.Id;
                                lstPPLIToCreate.add(newppli);
                            }
                            if(lstPPLIToCreate.size() > 0){
                                insert lstPPLIToCreate;
                            }
                        }
                        redemp.PurchasedProducts__c = ppCopy.Id;
                    }
                    update redemp;
                }
            }
        }catch(Exception e){
            AuraHandledException ae = new AuraHandledException('Error: '+ e.getLineNumber() + ' ' + e.getMessage());
            ae.setMessage('Error: '+ e.getLineNumber() + e.getMessage());
            throw ae;
        }

    }

    // wrapper class 
    public class redemptionProductWrapper {
        @auraEnabled public List<PurchasedProductLineItem__c> purchaseProductItem {get;set;}
        @auraEnabled public List<RedeemableProductItem__c> redeemableProductItem {get;set;}
      }
}