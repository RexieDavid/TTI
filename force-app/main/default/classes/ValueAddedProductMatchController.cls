/**
* @author: Jerome Liwanag
* @date: Feb 2017
* @description: This class is the controller for the (Name)VF page. It handles the logic
* required to display the page. Takes care of the insert operation of a Value Added Product
* record using a search method and a wrapper class
*/ 
public class ValueAddedProductMatchController {
    
    // Class variables
    public List<Catalogue_Product__c> catProdList {get;set;}
    public List<Loyalty_Added_Product__c> vAprodsToCheck {get;set;}
    public Catalogue_Submission__c catSub {get;set;}
    public List<Catalogue_Submission__c> catSubmissionList {get;set;}
    public List<Loyalty_Added_Product__c> vAprods {get;set;}
    public String selectedRowIndex { get; set; }
    public List<Loyalty_Added_Product__c> deletedVAP { get; set; }
    public Integer count = 1;
    public List<Loyalty_Added_Product__c> prods = new List<Loyalty_Added_Product__c>();
    
    
    // Constructor
    public ValueAddedProductMatchController(){
        deletedVAP = new List<Loyalty_Added_Product__c>();
        selectedRowIndex = '0';
        vAprodsToCheck = new List<Loyalty_Added_Product__c>();
        vAprods = new List<Loyalty_Added_Product__c>();
        catSubmissionList = new List<Catalogue_Submission__c>();
        runQuery();
    }
    
    private void runQuery() {
        Map<String,List<Loyalty_Added_Product__c>> vAPMap = new Map<String,List<Loyalty_Added_Product__c>>();

        if(ApexPages.currentPage().getUrl().left(32) == '/apex/ValueAddedProductMatchEdit'){
            Map<Id, Catalogue_Product__c> catProdMaps = new Map<Id,Catalogue_Product__c>();
            Set<Id> catProdIds = new Set<Id>();
            for(Integer j=0; j<Integer.valueOf(ApexPages.currentPage().getParameters().get('vapSize')); j++){
                prods.add(new Loyalty_Added_Product__c(Bonus_Product__c = ApexPages.currentPage().getParameters().get('vapId'+j), Catalogue_Product__c = ApexPages.currentPage().getParameters().get('catprodId'+j),
                                                    Catalogue_Submission__c = ApexPages.currentPage().getParameters().get('Id'), Bonus_Quantity__c = Integer.valueOf(ApexPages.currentPage().getParameters().get('vapBq'+j)),
                                                    Purchase_Quantity__c = Integer.valueOf(ApexPages.currentPage().getParameters().get('vapPq'+j)), VF_Temp_Catalogue_Product_Code__c = ApexPages.currentPage().getParameters().get('catprodCode'+j)));
                catProdIds.add(ApexPages.currentPage().getParameters().get('catprodId'+j));
            }

            for(Catalogue_Product__c catLoop : [SELECT Id, Product_Code__c FROM Catalogue_Product__c WHERE ID IN: catProdIds]){
                catProdMaps.put(catLoop.Id,catLoop);
            }

            for(Loyalty_Added_Product__c vapLoop : prods){
                vapLoop.Catalogue_Product__c = catProdMaps.get(vapLoop.Catalogue_Product__c).Id;
            }
        }
        else{
            prods = [SELECT Id,Catalogue_Product__c, Catalogue_Product__r.Product__c,Catalogue_Submission__c, Catalogue_Submission__r.Catalogue_Name__c,
                        Catalogue_Submission__r.Advertising_Start_Date__c, Catalogue_Submission__r.Status__c,
                        Catalogue_Submission__r.OwnerId,
                        Catalogue_Submission__r.Advertising_End_Date__c, Bonus_Product_Code__c, Bonus_Product__c, VF_Temp_Catalogue_Product_Code__c
                FROM Loyalty_Added_Product__c 
                WHERE Catalogue_Submission__c = :ApexPages.currentPage().getParameters().get('Id')];
        }

        for(Loyalty_Added_Product__c vAPLoop : [SELECT Id,Catalogue_Product__c, Catalogue_Product__r.Product__c,Catalogue_Submission__c, Catalogue_Submission__r.Catalogue_Name__c,
                                                     Catalogue_Submission__r.Advertising_Start_Date__c, Catalogue_Submission__r.Status__c,
                                                     Catalogue_Submission__r.OwnerId,
                                                     Catalogue_Submission__r.Advertising_End_Date__c, Bonus_Product_Code__c, Bonus_Product__c,
                                                     Catalogue_Product__r.Product_Code__c
                                              FROM Loyalty_Added_Product__c 
                                              WHERE Catalogue_Submission__c != :ApexPages.currentPage().getParameters().get('Id')]){
            
            if(!vAPMap.containsKey(vAPLoop.Bonus_Product__c)) {                                     
                vAPMap.put(vAPLoop.Bonus_Product__c, new List<Loyalty_Added_Product__c> {vAPLoop} );
            }else{
                vAPMap.get(vAPLoop.Bonus_Product__c).add(vAPLoop);
            }
            
        }
                      
        Set<Id> vapProdsSet = new Set<Id>();
        Set<Id> catProds = new Set<Id>();
        for(Loyalty_Added_Product__c vAPLoop : prods){
            catProds.add(vAPLoop.Catalogue_Product__c);
        }
        
        Set<Loyalty_Added_Product__c> vapSet = new Set<Loyalty_Added_Product__c>();
        Map<Id,Catalogue_Product__c> catProdMap = new Map<Id,Catalogue_Product__c>([SELECT Id,Product__c,Product_Code__c FROM Catalogue_Product__c WHERE ID IN :catProds]);
        
        Catalogue_Submission__c catSub = [SELECT Id,Advertising_Start_Date__c,Advertising_End_Date__c  FROM Catalogue_Submission__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        for(Loyalty_Added_Product__c vAPLoop : prods){
            if(vAPMap.containsKey(vAPLoop.Bonus_Product__c)){
                for(Loyalty_Added_Product__c vapLoop2 : vAPMap.get(vAPLoop.Bonus_Product__c)){
                    if(vapLoop.Bonus_Product__c == vapLoop2.Bonus_Product__c && 
                       vapLoop2.Catalogue_Product__r.Product__c == catProdMap.get(vAPLoop.Catalogue_Product__c).Product__c &&
                       ((vapLoop2.Catalogue_Submission__r.Advertising_Start_Date__c <= catSub.Advertising_Start_Date__c &&
                       vapLoop2.Catalogue_Submission__r.Advertising_End_Date__c >= catSub.Advertising_Start_Date__c) || 
                       (vapLoop2.Catalogue_Submission__r.Advertising_Start_Date__c <= catSub.Advertising_End_Date__c &&
                       vapLoop2.Catalogue_Submission__r.Advertising_End_Date__c >= catSub.Advertising_End_Date__c) || 
                       (vapLoop2.Catalogue_Submission__r.Advertising_Start_Date__c >= catSub.Advertising_Start_Date__c &&
                       vapLoop2.Catalogue_Submission__r.Advertising_End_Date__c <= catSub.Advertising_End_Date__c))){
                           
                        vapSet.add(vAPLoop);
                   
                        catSubmissionList.add(new Catalogue_Submission__c(Id = vapLoop2.Catalogue_Submission__c, 
                                                                          Advertising_Start_Date__c = vapLoop2.Catalogue_Submission__r.Advertising_Start_Date__c,
                                                                          Advertising_End_Date__c = vapLoop2.Catalogue_Submission__r.Advertising_End_Date__c,
                                                                          Catalogue_Name__c = vapLoop2.Catalogue_Submission__r.Catalogue_Name__c,
                                                                          Status__c = vapLoop2.Catalogue_Submission__r.Status__c,
                                                                          OwnerId = vapLoop2.Catalogue_Submission__r.OwnerId));
                        
                        vapProdsSet.add(vapLoop2.Id);
                           
                    }                                        
                }
            }
        }
        
        vAprods = [SELECT Id, Catalogue_Product__c, Bonus_Product__c, Catalogue_Product__r.Product_Code__c FROM Loyalty_Added_Product__c WHERE ID IN :vapProdsSet];
        
        vAprodsToCheck.addAll(vapSet);    
    }
    
    public PageReference returnBack(){
        Integer count = 0; 
        if(ApexPages.currentPage().getUrl().left(32) == '/apex/ValueAddedProductMatchEdit'){
            PageReference pageRef=new PageReference(ApexPages.currentPage().getUrl().replace('ValueAddedProductMatchEdit', 'ValueAddedProductCreate'));
            return pageRef;
        }
        else{
            PageReference reRend = new PageReference ('/' + ApexPages.currentPage().getParameters().get('Id'));
            reRend.setRedirect(true);
            return reRend;
        }
    }
	
	public PageReference proceed(){
	    Catalogue_Submission__c catSubToUpdate = new Catalogue_Submission__c(Id = ApexPages.currentPage().getParameters().get('Id'));
	    if(catSubToUpdate.HasMatch__c == false){
            catSubToUpdate.HasMatch__c = true;
            update catSubToUpdate;
	    }
        try{
            insert prods;
        }catch(DmlException e){
            System.debug('ERROR: ' + e.getMessage());
        }
        PageReference pageRef=new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        pageRef.setRedirect(true);
        return pageRef;
        
    }
   
}