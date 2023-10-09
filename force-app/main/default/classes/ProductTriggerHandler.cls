public class ProductTriggerHandler extends TriggerHandler { 
    private Map<String, Id> heirachy_map;
    private Map<String, Id> recordtype_map;
    private Map<String, Id> pricebook_map;
    private Id stdID ;

    public ProductTriggerHandler() {
        
        //this.setMaxLoopCount(1);
        
        
        // Get the Product Heirachies and map
        List<Product_Heirachy__c> heirachys = [SELECT Id, Name FROM Product_Heirachy__c];
        heirachy_map = new Map<String, Id>();      
        for ( Product_Heirachy__c ph:heirachys  ){
            heirachy_map.put( ph.Name, ph.id);
        }
        
        // Get the RecordTypes and map
        List<RecordType> recordtypes = [Select Name, Id From RecordType WHERE SobjectType = 'Product2'];
        recordtype_map = new Map<String, Id>();           
        for ( RecordType rcd:recordtypes  ){
           recordtype_map.put( rcd.Name, rcd.id);  
        }
        
        // Get the Pricebooks and map
        List<Pricebook2> pricebooks = [Select ID, Name From Pricebook2];               
        pricebook_map = new Map<String, Id>();    
        for ( Pricebook2 pb:pricebooks ){
            pricebook_map.put( pb.Name, pb.id);      
        }
        
        stdID = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id From Pricebook2 WHERE IsStandard = true].Id;
    
    }// END CONSTRUCTOR


    
    public override void beforeInsert() {
        for(Product2 prod : (List<Product2>) Trigger.new) {
            if(this.heirachy_map.containsKey(prod.SAP_Product_Heirarchy__c)) {
                prod.Heirachy__c = this.heirachy_map.get(prod.SAP_Product_Heirarchy__c);             
            } 
        }    
    }
      
      


    public override void afterInsert() {      
        List<PriceBookEntry> pbentries = new List<PriceBookEntry>();
         
        for(Product2 prod : (List<Product2>) Trigger.new) { 
            if (ProductTriggerHelper.getResetIndicator()){    
                pbentries.add(new PriceBookEntry(Product2Id = prod.Id, PriceBook2Id = stdID, UnitPrice=1.0, UseStandardPrice=false, IsActive = true));           
                if ( !Test.isRunningTest() && pricebook_map.containsKey(prod.Division__c) )pbentries.add(new PriceBookEntry(Product2Id = prod.Id, PriceBook2Id = pricebook_map.get(prod.Division__c), UnitPrice=2.0, UseStandardPrice=false, IsActive = true));         
            }
            ProductTriggerHelper.setResetIndicator(false);
        }
        insert pbentries;
    }


      
    public override void beforeUpdate() {
        List<PriceBookEntry> pbentries = new List<PriceBookEntry>();
       	Set<id> productId = new Set<id>();
        map<id,product2> productMap = new map<id,product2>();
    	for(Product2 prod : (List<Product2>) Trigger.new) {
            productId.add(prod.id);
            productMap.put(prod.id, prod);
            if (ProductTriggerHelper.getResetIndicator()){
                if(heirachy_map.containsKey(prod.SAP_Product_Heirarchy__c)) {
                   prod.Heirachy__c = heirachy_map.get(prod.SAP_Product_Heirarchy__c);             
                }
                
                // Look to see if this product already exists in Standard Pricebook
                List<PriceBookEntry> std_entries = [select Id from PriceBookEntry where Product2Id = :prod.id and PriceBook2Id = :stdID];
                    
                // If not already in Standard Pricebook add              
                if(std_entries.isEmpty()){
                   //PriceBookEntry newStdEntry = new PriceBookEntry(Product2Id = prod.Id, PriceBook2Id = stdID, UnitPrice=1.0, UseStandardPrice=false, IsActive = true);              
                   pbentries.add( new PriceBookEntry(Product2Id = prod.Id, PriceBook2Id = stdID, UnitPrice=1.0, UseStandardPrice=false, IsActive = true) );
                }
                

                // is there a custom pricebook entry for this product?
                if(pricebook_map.containsKey(prod.Division__c)){
                    String pricebookID = pricebook_map.get(prod.Division__c); 
                    List<PriceBookEntry> currentEntries = [select Id, PriceBook2Id from PriceBookEntry where Product2Id = :prod.id and PriceBook2Id = :pricebookID];                       
                    if(currentEntries.isEmpty()){
                            pbentries.add( new PriceBookEntry(Product2Id = prod.Id, PriceBook2Id = pricebookID, UnitPrice=2.0, UseStandardPrice=false, IsActive = true) );               
                    }
                        
                }
            }    
                
            ProductTriggerHelper.setResetIndicator(false);
                           
        } 
        AggregateResult[] kits = [SELECT kit__c,SUM(quantity__c) qty FROM Product_Kit__C WHERE kit__c IN :productId GROUP BY kit__c];
        map<id,Decimal> kitCount = new map<id,Decimal>();
        for(AggregateResult kit:kits){
            kitCount.put((id)kit.get('kit__c'), (Decimal)kit.get('qty'));
        }
        for(product2 prd : (List<Product2>) trigger.new){
            prd.product_kit_count__c = kitCount.get(prd.id);
        }
        if(!pbentries.isEmpty()){insert pbentries;}
         
    }
      
    
} // END CLASS