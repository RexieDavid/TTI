/**
* @author: Jerome Liwanag
* @date: Feb 2017
* @description: This class is the controller for the (Name)VF page. It handles the logic
* required to display the page. Takes care of the insert operation of a Value Added Product
* record using a search method and a wrapper class
*/ 
public class ValueAddedProductCreateController {
    
    // Class variables
    public Loyalty_Added_Product__c valueAddedProduct {get;set;}
    public List<Catalogue_Product__c> catProdList {get;set;}
    public List<productWrapper> prodWrap{get; set;}
    public List<Catalogue_Product__c> prods = new List<Catalogue_Product__c>();
    public List<Loyalty_Added_Product__c> vAprods {get;set;}
    public List<Loyalty_Added_Product__c> vAprodsToCheck {get;set;}
    public List<Catalogue_Submission__c> catSubmissionList {get; set;}
    public boolean isMatched{get;set;}
    public List<Loyalty_Added_Product__c> valueAddedProductList = new List<Loyalty_Added_Product__c>();
    public String str {get;set;}
    
    
    // Constructor
    public ValueAddedProductCreateController(){
        str = 'If the Ratio of Purchase Quantity of the Catalogued Product and Bonus Product is not 1 for 1. Please outline the ratio in the Purchase and Bonus Quantity Fields. \n \n' + 
        'For Example: If the customer will receive 1 Bonus Product for every 2 Catalogue Products purchased, please place “2” in the Purchase Quantity Field and “1” in the Bonus Quantity Field';
        catSubmissionList = new List<Catalogue_Submission__c>();
        vAprodsToCheck = new List<Loyalty_Added_Product__c>();
        vAprods = new List<Loyalty_Added_Product__c>();
        valueAddedProduct = new Loyalty_Added_Product__c();
        valueAddedProduct.Catalogue_Submission__c = ApexPages.currentPage().getParameters().get('Id');
        prodWrap=new list<productWrapper>();
        
        runQuery();
    }
    
    private void runQuery() {
        
        prods = [Select Name,Product__c,Product__r.ProductCode from Catalogue_Product__c where Catalogue__c = :valueAddedProduct.Catalogue_Submission__c];
        
        for(Catalogue_Product__c a:prods){
            productWrapper aw = new productWrapper(a);
            prodWrap.add(aw);
        }

        if(ApexPages.currentPage().getParameters().containsKey('vapId0')){
            for(productWrapper prodWrapLoop : prodWrap){
                for(Integer j=0; j<prodWrap.size(); j++){
                    if(prodWrapLoop.prod.Id == ApexPages.currentPage().getParameters().get('catprodId'+j)){
                            prodWrapLoop.bonusProd.Bonus_Product__c = ApexPages.currentPage().getParameters().get('vapId'+j);
                            prodWrapLoop.bonusProd.Purchase_Quantity__c = Integer.valueOf(ApexPages.currentPage().getParameters().get('vapPq'+j));
                            prodWrapLoop.bonusProd.Bonus_Quantity__c = Integer.valueOf(ApexPages.currentPage().getParameters().get('vapBq'+j));
                    }
                }
            }
        }
        
        
    }
    
    
    public void test(){
        
        for(productWrapper pwrap:prodWrap){
            if(pwrap.bonusProd.Bonus_Product__c != null && pwrap.bonusProd.Bonus_Quantity__c != null && pwrap.bonusProd.Purchase_Quantity__c != null){
            valueAddedProductList.add(new Loyalty_Added_Product__c(Catalogue_Submission__c = ApexPages.currentPage().getParameters().get('Id'),
            Catalogue_Product__c = pwrap.prod.Id,  Bonus_Product__c = pwrap.bonusProd.Bonus_Product__c, Bonus_Quantity__c = pwrap.bonusProd.Bonus_Quantity__c, Purchase_Quantity__c = pwrap.bonusProd.Purchase_Quantity__c));
            }
        }
        
        if(!valueAddedProductList.isEmpty()){
            List<Loyalty_Added_Product__c> vAprodsToCheck = matchingCatalogues(valueAddedProductList);

            if(!vAprodsToCheck.isEmpty()){
                isMatched = true;
            }else{
                isMatched = false;
                insert valueAddedProductList;  
            }
        }  
    }
    
    public pagereference redirectMethod(){
        Set<Id> catIds = new Set<Id>();
        valueAddedProductList.clear();
        Integer counter = 0;
        for(productWrapper pwrap:prodWrap){
            if(pwrap.bonusProd.Bonus_Product__c != null && pwrap.bonusProd.Bonus_Quantity__c != null && pwrap.bonusProd.Purchase_Quantity__c != null){
                valueAddedProductList.add(new Loyalty_Added_Product__c(Catalogue_Submission__c = ApexPages.currentPage().getParameters().get('Id'),
                Catalogue_Product__c = pwrap.prod.Id,  Bonus_Product__c = pwrap.bonusProd.Bonus_Product__c, Purchase_Quantity__c = pwrap.bonusProd.Purchase_Quantity__c,
                Bonus_Quantity__c = pwrap.bonusProd.Bonus_Quantity__c));

                catIds.add(pwrap.prod.Id);
            }else{
                if(pwrap.bonusProd.Bonus_Product__c != null){
                    counter++;
                }
            }
        }

        if(!valueAddedProductList.isEmpty()){
            List<Loyalty_Added_Product__c> vAprodsToCheck = matchingCatalogues(valueAddedProductList);
        }
        
        else if(valueAddedProductList.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a product to insert or put a quantity to each product');
            ApexPages.addMessage(myMsg);
            PageReference pr = new PageReference('/apex/ValueAddedProductCreate?Id=' + this.valueAddedProduct.Catalogue_Submission__c);
            return pr;
            
        }
        Map<Id,Catalogue_Product__c> catMap = new Map<Id,Catalogue_Product__c>([SELECT Id, Product_Code__c FROM Catalogue_Product__c WHERE ID IN: catIds]);
        if(!vAprodsToCheck.isEmpty() && counter == 0){
            PageReference pageRef=new PageReference('/apex/ValueAddedProductMatchEdit?Id=' + this.valueAddedProduct.Catalogue_Submission__c);
            for(Integer j = 0;j<valueAddedProductList.size();j++){
                pageRef.getParameters().put('catprodId'+j, valueAddedProductList[j].Catalogue_Product__c);
                pageRef.getParameters().put('vapId'+j, valueAddedProductList[j].Bonus_Product__c);
                pageRef.getParameters().put('vapPq'+j, ''+valueAddedProductList[j].Purchase_Quantity__c+'');
                pageRef.getParameters().put('vapBq'+j, ''+valueAddedProductList[j].Bonus_Quantity__c+'');
                pageRef.getParameters().put('catprodCode'+j, catMap.get(valueAddedProductList[j].Catalogue_Product__c).Product_Code__c);
                pageRef.getParameters().put('vapSize', ''+valueAddedProductList.size()+'');
            }
            return pageRef;
        }else{
            PageReference pr = new PageReference('/' + this.valueAddedProduct.Catalogue_Submission__c);
            return pr;
        }
        
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Initiates the 'Save' button to insert
    * the Value Added Product(s) depending on the product(s) selected
    */ 
    
    
    public List<Loyalty_Added_Product__c> matchingCatalogues(List<Loyalty_Added_Product__c> prods){
        Map<String,List<Loyalty_Added_Product__c>> vAPMap = new Map<String,List<Loyalty_Added_Product__c>>();
        
        for(Loyalty_Added_Product__c vAPLoop : [SELECT Id,Catalogue_Product__c, Catalogue_Product__r.Product__c,Catalogue_Submission__c, Catalogue_Submission__r.Catalogue_Name__c,
                                                     Catalogue_Submission__r.Advertising_Start_Date__c, Catalogue_Submission__r.Status__c,
                                                     Catalogue_Submission__r.OwnerId,
                                                     Catalogue_Submission__r.Advertising_End_Date__c, Bonus_Product_Code__c, Bonus_Product__c
                                              FROM Loyalty_Added_Product__c 
                                              WHERE Catalogue_Submission__c != :ApexPages.currentPage().getParameters().get('Id')]){
            
            if(!vAPMap.containsKey(vAPLoop.Bonus_Product__c)) {                                     
                vAPMap.put(vAPLoop.Bonus_Product__c, new List<Loyalty_Added_Product__c> {vAPLoop} );
            }else{
                vAPMap.get(vAPLoop.Bonus_Product__c).add(vAPLoop);
            }
            
        }
                      
                      
        Set<Id> catProds = new Set<Id>();
        for(Loyalty_Added_Product__c vAPLoop : prods){
            catProds.add(vAPLoop.Catalogue_Product__c);
        }
        
        Map<Id,Catalogue_Product__c> catProdMap = new Map<Id,Catalogue_Product__c>([SELECT Id,Product__c FROM Catalogue_Product__c WHERE ID IN :catProds]);
        
        Catalogue_Submission__c catSub = [SELECT Id,Advertising_Start_Date__c,Advertising_End_Date__c FROM Catalogue_Submission__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        vAprodsToCheck.clear();
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
                       vAprodsToCheck.add(vAPLoop);    
                       catSubmissionList.add(new Catalogue_Submission__c(Id = vapLoop2.Catalogue_Submission__c, 
                                                                          Advertising_Start_Date__c = vapLoop2.Catalogue_Submission__r.Advertising_Start_Date__c,
                                                                          Advertising_End_Date__c = vapLoop2.Catalogue_Submission__r.Advertising_End_Date__c,
                                                                          Catalogue_Name__c = vapLoop2.Catalogue_Submission__r.Catalogue_Name__c,
                                                                          Status__c = vapLoop2.Catalogue_Submission__r.Status__c,
                                                                          OwnerId = vapLoop2.Catalogue_Submission__r.OwnerId));
                        
                        vAprods.add(new Loyalty_Added_Product__c(Id = vapLoop2.Id, Catalogue_Product__c = vapLoop2.Catalogue_Product__c,
                                                                Bonus_Product__c = vapLoop2.Bonus_Product__c));
                           
                    }                                        
                }
            }
        }
        
        return vAprodsToCheck;
    }
    public void setQuantityMethod(){
        for(productWrapper pwrap : prodWrap) {
            if(pwrap.bonusProd.Bonus_Product__c != null){
                pwrap.bonusProd.Bonus_Quantity__c = 1;
                pwrap.bonusProd.Purchase_Quantity__c = 1;
            }else{
                pwrap.bonusProd.Bonus_Quantity__c = null;
                pwrap.bonusProd.Purchase_Quantity__c = null;
            }
        }
    }
    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Initiates the 'Cancel' button to go redirect
    * to previous page
    */ 
    public PageReference cancel(){
        PageReference reRend = new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        reRend.setRedirect(true);
        return reRend;
    }
    
    
    public class productWrapper{
        public Catalogue_Product__c prod{get; set;}
        public Loyalty_Added_Product__c bonusProd{get; set;}
 
        public productWrapper(Catalogue_Product__c p){
            prod=p;
            bonusProd= new Loyalty_Added_Product__c();
        }
    }
   
}