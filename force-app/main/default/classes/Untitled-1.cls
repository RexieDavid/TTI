/** 
 * @description:        Controller Membership Loyalty Program Automations
 * 
 * @author:             Rexie David
 * @date:               10/3/2023
*/
public with sharing class MembershipLoyaltyContoller {
    
    public WithoutShare withoutSharing = new WithoutShare();
    
    public static List<Member_Benefit__c> generateMemberBenefits (Set<String> assetIds){

        List<Member_Benefit__c> memberBenefitToInsertList = new List<Member_Benefit__c>();

        List<Asset> registeredProductList = withoutSharing.getAssets(assetIds); // Retrieve Assets (Registered Products)

        Set<String> assetCustomerAccountIds = new Set<String>();
        Set<String> productCodes = new Set<String>();
        Set<String> productHierarchies = new Set<String>();
        Set<String> eligibleProductIds = new Set<String>();

        Map<String,List<Asset>> customerAssetListMap = new Map<String,List<Asset>>(); //Map of Key: Customer(PersonAccountId) - Value: List of Asset
        //Map<String,List<Eligible_Customer__c>> campaignEligibleCustomerListMap = new Map<String,List<Eligible_Customer__c>>();
        Map<String,List<Asset>> campaignAssetListMap = new Map<String,List<Asset>>(); //Map of Key: Campaign (Member_Benefit_Program__c) - Value: List of Asset

        // Map<String,List<Eligible_Product_Line_c> campaignEligibleProductMap = new Map<String,Eligible_Product_Line_c>();

        //Loop through Registered Products
        for(Asset assetRecord : registeredProductList){
            if(assetRecord.AccountId) assetCustomerAccountIds.add(assetRecord.AccountId);
            if(assetRecord.ProductCode) productCodeIds.add(assetRecord.ProductCode);
            if(assetRecord.SAPProductHeirarchy__c) productHierarchies.add(assetRecord.SAPProductHeirarchy__c);

            // //Populate Customer(PersonAccountId) - List of Asset
            // if(customerAssetListMap.containsKey(assetRecord.AccountId)){
            //     customerAssetListMap.put(assetRecord.AccountId,customerAssetListMap.get(assetRecord.AccountId).add(assetRecord));
            // }
            // else{
            //     customerAssetListMap.put(assetRecord.AccountId,new List<Asset>{asset});
            // }
        }
        
       




        if(assetCustomerAccountIds.size() > 0){
            //Loop through the Eligible_Customer__c records
            List<Eligible_Customer__c> eligibleCustomerList = withoutSharing.getEligibleCustomers(assetCustomerAccountIds);

            for(Eligible_Customer__c eligibleCustomer : eligibleCustomerList){

                if(customerAssetListMap.containsKey(eligibleCustomer.Customer__c)){

                    for(Asset assetRecord : customerAssetListMap.get(eligibleCustomer.Customer__c)){
                    
                        if(meetsDateRange(assetRecord,eligibleCustomer)){
                            //We have confirmed the assetRecord DATE eligibility based on the Eligible_Customer__c records, 
                            //next we have to confirm the assetRecord PRODUCT/PRODUCTHIERARCHY eligibility based on the Eligible Product
                            System.debug(eligibleCustomer.Customer_Name__c + ' is Eligible for ' + eligibleCustomer.Member_Benefit_Program__r.Name 
                            + ' by Purchasing '+assetRecord.ProductCode+' - '+assetRecord.ProductDescription + ' last ' +assetRecord.PurchaseDate + ' and Registered it on ' +regDate 
                            +'. Campaign Purchase Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Start_Date__c + ' until ' +eligibleCustomer.Member_Benefit_Program__r.End_Date__c 
                            +' and Registration Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Valid_From__c + ' until ' + eligibleCustomer.Member_Benefit_Program__r.Valid_To__c);
                            eligibleProductIds.add(eligibleCustomer.Member_Benefit_Program__r.Eligible_Products__c);
                            productCodes.add(assetRecord.ProductCode);
                            productHierarchies.add(assetRecord.SAPProductHeirarchy__c);

                            if(campaignAssetListMap.containsKey(eligibleCustomer.Member_Benefit_Program__c)){
                                //Map Key: Campaign (Member_Benefit_Program__c), Value: List<Eligible_Customer__c>
                                campaignAssetListMap.put(eligibleCustomer.Member_Benefit_Program__c,campaignAssetListMap.get(eligibleCustomer.Member_Benefit_Program__c).add(assetRecord));
                            }
                            else{
                                campaignAssetListMap.put(eligibleCustomer.Member_Benefit_Program__c,new List<Asset> {assetRecord});
                            }
                        }
                    }
                }
            }    

            for(Eligible_Product__c eligibleProduct : withoutSharing.getEligibleProducts(eligibleProductIds,productCodes,campaignAssetListMap.keySet())){
                campaignEligibleProductMap.put(eligibleProduct.);
            }

            //Loop through the Initial Eligible campaignAssetListMap
            for(String campaignId : campaignAssetListMap.keySet()){
                if(campaignAssetListMap.containsKey(campaignId)){
                    for(Asset assetRecord : campaignAssetListMap.get(campaignId)){

                    }

                }
            }

            //Query Eligible Product 
            //Map of Key: Campaign (Member_Benefit_Program__c) - Value: List of Eligible_Product_Line_Item__c
            //Map<String, List<Eligible_Product_Line_Item__c>> campaignEligibleProductLineItemListMap = new  Map<String, List<Eligible_Product_Line_Item__c>>();

        }
        
        System.debug('assetCustomerAccountIds >>> '+assetCustomerAccountIds);
        System.debug('productCodes >>> '+productCodes);
        System.debug('productHierarchies >>> '+productHierarchies);
        System.debug('eligibleProductIds >>> '+eligibleProductIds);

        //List<Member_Benefit_Program__c> memberBenefitProgramList = withoutSharing.getMemberBenefitPrograms(new List<String> {'Ryobi'});

        Boolean isEligible = false;

        try{

        }

        catch(Exception e){

        }

        return isEligible;

    }

    private static Boolean meetsDateRange(Asset assetRecord, Eligible_Customer__c eligibleCustomer){

        Boolean meetsDateRange = false;
        DateTime regDateTime = assetRecord.Registered_Date_Formula__c;
        Date regDate = date.newinstance(regDateTime.year(), regDateTime.month(), regDateTime.day());
        if(assetRecord.PurchaseDate >= eligibleCustomer.Member_Benefit_Program__r.Start_Date__c 
        && assetRecord.PurchaseDate <= eligibleCustomer.Member_Benefit_Program__r.End_Date__c
        && regDate >= eligibleCustomer.Member_Benefit_Program__r.Valid_From__c
        && regDate <= eligibleCustomer.Member_Benefit_Program__r.Valid_To__c){
            meetsDateRange = true;
        }
        return meetsDateRange;
    } 

    public class EligibleCustomer {

        public Member_Benefit_Program__c campaign {get; set;}
        public Asset asset {get; set;}

        public EligibleCustomer (Asset asset){
            this.asset = asset;
        }   

    }
    
    public without sharing class WithoutShare {

        public List<Eligible_Products__c> getEligibleProducts(Set<String> eligibleProductIds, Set<String> productCodes, Set<String> campaignIds){
            return [SELECT  Id,
                            Name,
                            (SELECT Id, 
                                    Product__c,
                                    Product__r.SAP_Product_Heirarchy__c,
                                    Product__r.ProductCode,
                                    Product_Model__c, 
                                    Customer_Facing_Name__c 
                            FROM Eligible_Product_Line_Items__r
                            WHERE Product__r.ProductCode IN: productCodes),
                            (SELECT Id,
                                    Name,
                                    Eligible_Products__c,
                                    Product_Hierarchies__c,
                                    Start_Date__c,
                                    End_Date__c,
                                    Valid_From__c,
                                    Valid_To__c,
                                    Brand__c,
                                    Country__c
                                    // (SELECT Id, 
                                    //         Customer__c, 
                                    //         Customer_ContactId__c 
                                    // FROM Eligible_Customers__r)       
                            FROM Member_Benefit_Programs__r 
                            WHERE Id IN: campaignIds)
                    FROM Eligible_Products__c
                    WHERE Id IN: eligibleProductIds];  
        }

        public List<Eligible_Customer__c> getEligibleCustomers(Set<String> customerAccountIds){
            return [SELECT  Id,
                            Name,
                            Customer__c,
                            Customer_ContactId__c,
                            Customer_Name__c,
                            Member_Benefit_Program__c,
                            Member_Benefit_Program__r.Name,
                            Member_Benefit_Program__r.Eligible_Products__c,
                            Member_Benefit_Program__r.Product_Hierarchies__c,
                            Member_Benefit_Program__r.Country__c,
                            Member_Benefit_Program__r.Start_Date__c,
                            Member_Benefit_Program__r.End_Date__c,
                            Member_Benefit_Program__r.Valid_From__c,
                            Member_Benefit_Program__r.Valid_To__c,
                            Member_Benefit_Program__r.Brand__c
                    FROM Eligible_Customer__c
                    WHERE Id IN: customerAccountIds];  
        }

        public Map<Id,Member_Benefit_Program__c> getMemberBenefitPrograms(List<String> brands){
            return new Map<Id,Member_Benefit_Program__c> ([ SELECT  Id,
                                                                    Name,
                                                                    Eligible_Products__c,
                                                                    Product_Hierarchies__c,
                                                                    Start_Date__c,
                                                                    End_Date__c,
                                                                    Valid_From__c,
                                                                    Valid_To__c,
                                                                    Brand__c,
                                                                    Country__c, 
                                                                    (SELECT Id, 
                                                                            Customer__c, 
                                                                            Customer_ContactId__c 
                                                                    FROM Eligible_Customers__r)         
                                                            FROM Member_Benefit_Program__c 
                                                            WHERE Brand__c IN: brands]);  
        }

        public List<Asset> getAssets(Set<String> assetIds){
            return [SELECT  Id, 
                            AccountId, 
                            Standard_Warranty_Months__c, 
                            Extended_Warranty_Months__c, 
                            Total_Warranty_Years__c,
                            AssetSource__c,
                            IdentifiedBy__c,
                            ProductDescription,
                            ProductCode,
                            SerialNumber,
                            PurchaseDate,
                            SerialNumberWeek__c, 
                            SerialNumberYear__c,
                            Registered_Date_Formatted__c,
                            Registered_Date_Formula__c,
                            SAPProductHeirarchy__c,
                            Product2.AU_ListPrice__c,
                            Product2.NZ_ListPrice__c,
                            Product2.Category_Customer_Level2__c
                    FROM Asset 
                    WHERE Id IN: assetIds];  
        }

    }   
}