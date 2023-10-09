/**
* @author:          Francis Nasalita
* @date:            May 2022
* @description:     Product Transactions Handler that evaulates and 
*                   count cordless and corded/petrol tools
*
*/
public without sharing class ProductTransactionToolCounter extends TriggerHandler {

    private Map<Id, Map<String, Integer>> salesTxnCounters;
    private Map<Id, Product2> productMap;
    private Map<Id, Sales_Transactions__c> salesTxnMap;
    private List<Product_Transactions__c> newProdTxns;

    public ProductTransactionToolCounter() {
        this.newProdTxns = (List<Product_Transactions__c>) Trigger.new;
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> prodTxnIds = new Set<Id>();
        Set<Id> salesTxnIds = new Set<Id>();
        this.salesTxnCounters = new Map<Id, Map<String, Integer>>();

        for (Product_Transactions__c prodTxn : this.newProdTxns) {            
            prodTxnIds.add(prodTxn.Id);
            productIds.add(prodTxn.Product__c);
            salesTxnIds.add(prodTxn.Sales_Transactions__c);
        }
        
        //UPDATED BY KB - 08/09/23 - Replace Product_Hierarchy__c field reference to SAP_Product_Heirarchy__c field
        // get product details. Trigger.new only have the product Ids
        this.productMap = new Map<Id, Product2>([SELECT Id, SAP_Product_Heirarchy__c, Brand_Name_Formula__c FROM Product2 WHERE Id IN :productIds AND SAP_Product_Heirarchy__c != null]);

        // get sales transactions with existing product transactions exluding records from Trigger.new
        this.salesTxnMap = new Map<Id, Sales_Transactions__c>(
            [SELECT Id, 
                Count_of_AEG_Cordless__c, 
                Count_of_AEG_Corded_Petrol__c, 
                Count_of_Ryobi_Cordless__c, 
                Count_of_Ryobi_Corded_Petrol__c, 
                (
                    SELECT Id,
                           Product__r.Brand_Name_Formula__c, 
                           Product__r.SAP_Product_Heirarchy__c,
                           Quantity__c
                    FROM Product_Transactions__r
                    WHERE Id NOT IN :prodTxnIds
                ) 
            FROM Sales_Transactions__c 
            WHERE Id IN :salesTxnIds]
        );
    }

    public override void afterInsert() {
        populateSalesTxnCounters();
    }

    public override void afterUpdate() {
        populateSalesTxnCounters();
    }

    private void populateSalesTxnCounters() {
        // evaluate existing product transactions
        for (Sales_Transactions__c salesTxn : this.salesTxnMap.values()) {
            if (!this.salesTxnCounters.containsKey(salesTxn.Id)) {
                this.salesTxnCounters.put(salesTxn.Id, new Map<String, Integer>{
                    'Count_of_AEG_Cordless__c' => 0,
                    'Count_of_AEG_Corded_Petrol__c' => 0,
                    'Count_of_Ryobi_Cordless__c' => 0,
                    'Count_of_Ryobi_Corded_Petrol__c' => 0
                });
            }
            
            for (Product_Transactions__c prodTxn : salesTxn.Product_Transactions__r) {
                Product2 product = prodTxn.Product__r;
                String productBrand = product.Brand_Name_Formula__c;

                evaluateProduct(productBrand, salesTxn.Id, prodTxn, product);
            }
        }

        // evaluate new/updated product transactions
        for (Product_Transactions__c prodTxn : newProdTxns) {
            if (prodTxn.Sales_Transactions__c != null) {
                Id salesTxnId = prodTxn.Sales_Transactions__c;
                
                //ADDED BY KB - 08/10/23 - Added checker for Product transactions related product
                if(productMap.containsKey(prodTxn.Product__c)){
                    Product2 product = productMap.get(prodTxn.Product__c);
                    String productBrand = product.Brand_Name_Formula__c;
                    evaluateProduct(productBrand, salesTxnId, prodTxn, product);
                }
                
            }
        }

        if (!this.salesTxnMap.values().isEmpty()) {    
            List<Sales_Transactions__c> salesTxns = this.salesTxnMap.values();
    
            for (Sales_Transactions__c salesTxn : salesTxns) {
                for (String fieldName : salesTxnCounters.get(salesTxn.Id).keySet()) {
                    salesTxn.put(fieldName, salesTxnCounters.get(salesTxn.Id).get(fieldName));
                }            
            }

            update salesTxns;
        }

    }
    
    //UPDATED BY KB - 08/09/23 - Replace Product_Hierarchy__c field reference to SAP_Product_Heirarchy__c field
    private void evaluateProduct(String productBrand, Id salesTxnId, Product_Transactions__c prodTxn, Product2 product) {
        if (String.isNotBlank(product.SAP_Product_Heirarchy__c)) {
            if (productBrand == 'Ryobi') {
                if (isRyobiCordless(product)) {
                    this.salesTxnCounters.put(salesTxnId, addCounter(this.salesTxnCounters.get(salesTxnId), 'Count_of_Ryobi_Cordless__c', prodTxn.Quantity__c));
                }
    
                if (isRyobiCordedPetrol(product)) {
                    this.salesTxnCounters.put(salesTxnId, addCounter(this.salesTxnCounters.get(salesTxnId), 'Count_of_Ryobi_Corded_Petrol__c', prodTxn.Quantity__c));
                }
            }
    
            if (productBrand == 'AEG') {
                if (isAEGCordless(product)) {
                    this.salesTxnCounters.put(salesTxnId, addCounter(this.salesTxnCounters.get(salesTxnId), 'Count_of_AEG_Cordless__c', prodTxn.Quantity__c));
                }
    
                if (isAEGCordedPetrol(product)) {
                    this.salesTxnCounters.put(salesTxnId, addCounter(this.salesTxnCounters.get(salesTxnId), 'Count_of_AEG_Corded_Petrol__c', prodTxn.Quantity__c));
                }
            }        
        }
    }

    private Map<String, Integer> addCounter(Map<String, Integer> counters, String fieldToIncrement, Decimal quantity) {
        counters.put(fieldToIncrement, counters.get(fieldToIncrement) + (Integer) quantity);
        return counters;
    }
    
    //UPDATED BY KB - 08/09/23 - Replace Product_Hierarchy__c field reference to SAP_Product_Heirarchy__c field
    private Boolean isRyobiCordless(Product2 product) {
        String productHierarchy = String.valueOf(product.SAP_Product_Heirarchy__c);
        List<String> ryobiCorlessProductHierarchy = new List<String>{ 'OPL', '36L', '6VL', '12L', '12VL', '48V', '72L' };
        return productHierarchy.startsWith('RY') && checkTextIfContainsTextFromList(ryobiCorlessProductHierarchy, productHierarchy);
    }

    private Boolean isRyobiCordedPetrol(Product2 product) {
        String productHierarchy = String.valueOf(product.SAP_Product_Heirarchy__c);
        List<String> ryobiCordedPetrolProductHierarchy = new List<String>{ 'PED', 'BTP', 'PNU', 'ACE' };
        return productHierarchy.startsWith('RY') && checkTextIfContainsTextFromList(ryobiCordedPetrolProductHierarchy, productHierarchy);
    }

    private Boolean isAEGCordless(Product2 product) {
        String productHierarchy = String.valueOf(product.SAP_Product_Heirarchy__c);
        List<String> aegCordlessProductHierarchy = new List<String>{ '18L', '12L', '58L', '36L' };
        return productHierarchy.startsWith('AG') && checkTextIfContainsTextFromList(aegCordlessProductHierarchy, productHierarchy);
    }

    private Boolean isAEGCordedPetrol(Product2 product) {
        String productHierarchy = String.valueOf(product.SAP_Product_Heirarchy__c);
        List<String> aegcordedPetrolProductHierarchy = new List<String>{ 'PED', 'BTP', 'PNU', 'ACE' };
        return productHierarchy.startsWith('AG') && checkTextIfContainsTextFromList(aegcordedPetrolProductHierarchy, productHierarchy);
    }

    private Boolean checkTextIfContainsTextFromList(List<String> productHierarchies, String text) {
        for (String productHierarchy : productHierarchies) {
            if (text.contains(productHierarchy)) {
                return true;
            }
        }

         return false;
    }

}