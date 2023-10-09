/** 
 * @description:        Controller Membership Loyalty Program Automations
 * 
 * @author:             Rexie David
 * @date:               10/3/2023
*/
public with sharing class MembershipLoyaltyContoller {
    
    public static WithoutShare withoutSharing = new WithoutShare();
    
    public static List<Member_Benefit__c> generateMemberBenefits (Set<String> assetIds){

        List<Member_Benefit__c> memberBenefitToInsertList = new List<Member_Benefit__c>();
        List<Asset> registeredProductList = withoutSharing.getAssets(assetIds); // Retrieve Assets (Registered Products)
        Set<String> assetCustomerAccountIds = new Set<String>();
        // Set<String> productCodes = new Set<String>();
        Set<String> eligibleProductIds = new Set<String>();
        List<String> brandSet = new List<String>{'Ryobi'};
        // Map<String,List<memberBenefitProgramWrapper>> memberBenefitProgramWrapMap = new Map<String,List<memberBenefitProgramWrapper>>(); //Member Benefit Id - Member Benefit Wrapper Map
        Map<String,memberBenefitProgramWrapper> memberBenefitProgramWrapMap = new Map<String,memberBenefitProgramWrapper>();
        Map<Id,List<Eligible_Product_Line_Item__c>> memberBenefitProgramEligiblePliMap = new Map<Id,List<Eligible_Product_Line_Item__c>>();
        Map<String,List<Asset>> customerAssetListMap = new Map<String,List<Asset>>();

        //Loop through Registered Products
        for(Asset assetRecord : registeredProductList){
            if(assetRecord.AccountId != NULL) assetCustomerAccountIds.add(assetRecord.AccountId);
            if(customerAssetListMap.containsKey(assetRecord.ContactId)) customerAssetListMap.get(assetRecord.ContactId).add(assetRecord);
            else customerAssetListMap.put(assetRecord.ContactId, new List<Asset> {assetRecord});
        }

        for(Member_Benefit_Program__c memberBenefit : withoutSharing.getMemberBenefitPrograms(brandSet,assetCustomerAccountIds).values()){ //Loop Member_Benefit_Program__c
            if(memberBenefit.Eligible_Customers__r != NULL && memberBenefit.Eligible_Customers__r.size() > 0){

                // memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper();
                // memberBenefitWrap.memberBenefitProgramRec = memberBenefit;
                // // memberBenefitWrap.customerAssetListMap
                // memberBenefitWrap.exactProductMatch = false;

                Map<String,List<Asset>> filteredCustomerAssetListMap = new Map<String,List<Asset>>(); //Map of CustomerId(Contact Id) - List of Asset();

                for(Eligible_Customer__c eligibleCustomer : memberBenefit.Eligible_Customers__r){ //Loop Eligible_Customer__c
                    if(customerAssetListMap.containsKey(eligibleCustomer.Customer_ContactId__c)){
                        
                        for(Asset assetRec : customerAssetListMap.get(eligibleCustomer.Customer_ContactId__c)){ //Loop through Assets per Eligible Customers
                            DateTime regDateTime = assetRec.Registered_Date_Formula__c;
                            Date regDate = date.newinstance(regDateTime.year(), regDateTime.month(), regDateTime.day());

                            if(meetsDateRange(assetRec,eligibleCustomer)){ //Check if Meet Date Range
                                System.debug(eligibleCustomer.Customer_Name__c + ' meets the date range for ' + eligibleCustomer.Member_Benefit_Program__r.Name + ' by Purchasing '+assetRec.ProductCode+' - '+assetRec.ProductDescription + ' last ' +assetRec.PurchaseDate + ' and Registered it on ' +regDate +'. Campaign Purchase Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Start_Date__c + ' until ' +eligibleCustomer.Member_Benefit_Program__r.End_Date__c +' and Registration Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Valid_From__c + ' until ' + eligibleCustomer.Member_Benefit_Program__r.Valid_To__c);
                                
                                if(filteredCustomerAssetListMap.containsKey(eligibleCustomer.Customer_ContactId__c)){
                                    filteredCustomerAssetListMap.get(eligibleCustomer.Customer_ContactId__c).add(assetRec);
                                }   
                                else{
                                    filteredCustomerAssetListMap.put(eligibleCustomer.Customer_ContactId__c,new List<Asset>{assetRec});
                                }
                                // memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper(memberBenefit,null,eligibleCustomer,false); //Build memberBenefitProgramWrapper Wrapper
                                
                                // if(memberBenefitProgramWrapMap.containsKey(memberBenefit.Id)){
                                //     memberBenefitProgramWrapMap.get(memberBenefit.Id).add(memberBenefitWrap);
                                // }   
                                // else{
                                //     memberBenefitProgramWrapMap.put(memberBenefit.Id,new List<memberBenefitProgramWrapper>{memberBenefitWrap});
                                // }
                                eligibleProductIds.add(memberBenefit.Eligible_Products__c); 
                            }
                        }
                    }
                }
                if(!filteredCustomerAssetListMap.isEmpty()){
                    memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper(memberBenefit,filteredCustomerAssetListMap,false); //Build memberBenefitProgramWrapper Wrapper
                    memberBenefitProgramWrapMap.put(memberBenefit.Id,memberBenefitWrap);
                }      
                // if(memberBenefitProgramWrapMap.containsKey(memberBenefit.Id)){
                //     memberBenefitProgramWrapMap.get(memberBenefit.Id).add(memberBenefitWrap);
                // }   
                // else{
                //     memberBenefitProgramWrapMap.put(memberBenefit.Id,new List<memberBenefitProgramWrapper>{memberBenefitWrap});
                // }
            }
        }

        //Retrieve Eligible Products
        for(Eligible_Products__c eligibleProduct : withoutSharing.getEligibleProducts(eligibleProductIds,memberBenefitProgramWrapMap.keySet())){
            
            if(eligibleProduct.Member_Benefit_Programs__r != NULL && eligibleProduct.Member_Benefit_Programs__r.size() > 0
            && eligibleProduct.Eligible_Product_Line_Items__r != NULL && eligibleProduct.Eligible_Product_Line_Items__r.size() > 0){ //Check Member_Benefit_Programs__r and Eligible_Product_Line_Items__r

                for(Member_Benefit_Program__c memberBenefit : eligibleProduct.Member_Benefit_Programs__r){ //Loop Member_Benefit_Program__c under Eligible_Products__c
                    if(memberBenefitProgramWrapMap.containsKey(memberBenefit.Id)){//Check memberBenefit Program if Exist in Wrapper
                        memberBenefitProgramEligiblePliMap.put(memberBenefit.Id,eligibleProduct.Eligible_Product_Line_Items__r);
                    } 
                }
            }
        }

        //Map<String,Member_Benefit__c> customerMemberBenefitMap = new Map<String,Member_Benefit__c>();

        for(String memberBenefitProgramId : memberBenefitProgramWrapMap.keySet()){ //Loop through Member Benefit Program Id

            Set<String> contactProductSet = new Set<String>(); //to check if Product is not duplicated
            
            // Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Member_Benefit_Program__c = memberBenefitProgramId); 
            // String memberBenefitProductCode = '';
            memberBenefitProgramWrapper memberBenefitProgramWrap = memberBenefitProgramWrapMap.get(memberBenefitProgramId);

            String currEligibleProductId = memberBenefitProgramWrap.memberBenefitProgramRec.Eligible_Products__c;

            if(memberBenefitProgramWrap.customerAssetListMap != NULL && memberBenefitProgramWrap.customerAssetListMap.keySet().size() > 0){

                for(String customerId : memberBenefitProgramWrap.customerAssetListMap.keySet()){ //Loop through Contact Ids
                    
                    Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Member_Benefit_Program__c = memberBenefitProgramId); 
                    String productCodes = '';
                    String currBrand = '';//memberBenefitProgramWrap.assetRec.Brand__c;
                    for(Asset assetRecord : memberBenefitProgramWrap.customerAssetListMap.get(customerId)){
                        //Check asset if assetRecord is an Eligible Product
                        if(memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId) != NULL){
                            if(currBrand == '') currBrand = assetRecord.Brand__c;
                            for(Eligible_Product_Line_Item__c elPli : memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId)){ //Loop through Eligible PLI
                                if(assetRecord.ProductCode == elPli.Product_Model__c){
                                    if(!productCodes.containsIgnoreCase(assetRecord.ProductCode)) productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                                    System.debug('CUSTOMER '+assetRecord.Account.Name + ' MATCH VIA PRODUCT CODE >>> '+ 'eligiblePli.Product_Model__c >>> '+elPli.Product_Model__c + ' assetRecord.ProductCode >>> '+assetRecord.ProductCode);
                                    // eligibleProduct = elPli.Eligible_Product__c; //memberBenefitToInsert.Registered_Products__c = elPli.Eligible_Product__c;
                                    memberBenefitProgramWrap.exactProductMatch = true;
                                    memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                                }
                            }
                        }

                        if(assetRecord.SAPProductHeirarchy__c != NULL && memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c != NULL 
                        && memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.containsIgnoreCase(assetRecord.SAPProductHeirarchy__c)){// && memberBenefitProgramWrap.exactProductMatch == false){
                            if(!productCodes.containsIgnoreCase(assetRecord.ProductCode)) productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                            System.debug('CUSTOMER '+assetRecord.Account.Name +' MATCH VIA PRODUCT HIERARCHY >>> '+ 'memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c >>> '+memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c + ' assetRecord.SAPProductHeirarchy__c >>> '+assetRecord.SAPProductHeirarchy__c);
                            // Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Brand__c=memberBenefitProgramWrap.assetRec.Brand__c, Member_Benefit_Program__c = memberBenefitProgramId);
                            // memberBenefitToInsert.Customer_Name__c = memberBenefitProgramWrap.assetRec.ContactId;
                            // memberBenefitToInsertList.add(memberBenefitToInsert);
                        }

                    }

                    if(productCodes.length()>0){
                        memberBenefitToInsert.Product_Model__c = productCodes;
                        memberBenefitToInsert.Brand__c = currBrand;
                        memberBenefitToInsert.Customer_Name__c = customerId;
                        memberBenefitToInsertList.add(memberBenefitToInsert);
                    }

                }    
            
            }
            
            //for(memberBenefitProgramWrapper memberBenefitProgramWrap : memberBenefitProgramWrapMap.get(memberBenefitProgramId)){ //Loop Wrapper

                // if(memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId) != NULL){
                    
                //     String currContactId = memberBenefitProgramWrap.assetRec.ContactId;

                //     String currBrand = memberBenefitProgramWrap.assetRec.Brand__c;
                //     String currEligibleProductId = memberBenefitProgramWrap.memberBenefitProgramRec.Eligible_Products__c;
                    
                //     // String eligibleProduct = '';
                //     for(Eligible_Product_Line_Item__c elPli : memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId)){ //Loop through Eligible PLI
                //         if(memberBenefitProgramWrap.assetRec.ProductCode == elPli.Product_Model__c && !contactProductSet.contains(memberBenefitProgramId+memberBenefitProgramWrap.assetRec.ContactId+memberBenefitProgramWrap.assetRec.ProductCode)){
                //             memberBenefitProductCode += (memberBenefitProductCode != '') ? ';'+memberBenefitProgramWrap.assetRec.ProductCode : memberBenefitProgramWrap.assetRec.ProductCode;
                //             contactProductSet.add(memberBenefitProgramId+memberBenefitProgramWrap.assetRec.ContactId+memberBenefitProgramWrap.assetRec.ProductCode);
                //             System.debug('CUSTOMER '+memberBenefitProgramWrap.assetRec.Account.Name + ' MATCH VIA PRODUCT CODE >>> '+ 'eligiblePli.Product_Model__c >>> '+elPli.Product_Model__c + ' memberBenefitProgramWrap.assetRec.ProductCode >>> '+memberBenefitProgramWrap.assetRec.ProductCode);
                //             // eligibleProduct = elPli.Eligible_Product__c; //memberBenefitToInsert.Registered_Products__c = elPli.Eligible_Product__c;
                //             memberBenefitProgramWrap.exactProductMatch = true;
                //         }
                //     }
                    
                //     // memberBenefitToInsert.Member_Benefit_Program__c = memberBenefitProgramId;
                //     // memberBenefitToInsert.Product_Model__c = memberBenefitProductCode;
                //     // memberBenefitToInsert.Brand__c = currBrand;
                //     // memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                //     // memberBenefitToInsert.Customer_Name__c = currContactId;

                //     // if(customerMemberBenefitMap.containsKey(currContactId)){
                //     //     Member_Benefit__c existMemberBenefit = customerMemberBenefitMap.get(currContactId);
                //     //     existMemberBenefit.Product_Model__c += memberBenefitToInsert.Product_Model__c;
                //     //     customerMemberBenefitMap.put(currContactId,existMemberBenefit);
                //     // } 
                //     // else{
                //     //     customerMemberBenefitMap.put(currContactId,memberBenefitToInsert);
                //     // }

                // }

                // if(memberBenefitProgramWrap.assetRec.SAPProductHeirarchy__c != NULL && memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c != NULL 
                // && memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.containsIgnoreCase(memberBenefitProgramWrap.assetRec.SAPProductHeirarchy__c) &&
                // memberBenefitProgramWrap.exactProductMatch == false){
                //     System.debug('CUSTOMER '+memberBenefitProgramWrap.assetRec.Account.Name +' MATCH VIA PRODUCT HIERARCHY >>> '+ 'memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c >>> '+memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c + ' memberBenefitProgramWrap.assetRec.SAPProductHeirarchy__c >>> '+memberBenefitProgramWrap.assetRec.SAPProductHeirarchy__c);
                //     Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Brand__c=memberBenefitProgramWrap.assetRec.Brand__c, Member_Benefit_Program__c = memberBenefitProgramId);
                //     memberBenefitToInsert.Customer_Name__c = memberBenefitProgramWrap.assetRec.ContactId;
                //     memberBenefitToInsertList.add(memberBenefitToInsert);
                // }
            //}
        }
        // System.debug('customerMemberBenefitMap >>> '+customerMemberBenefitMap);
        System.debug('memberBenefitProgramWrapMap >>> '+memberBenefitProgramWrapMap);
        System.debug('memberBenefitToInsertList.size() >>> '+memberBenefitToInsertList.size());
        System.debug('memberBenefitToInsertList >>> '+memberBenefitToInsertList);
        System.debug('memberBenefitProgramEligiblePliMap >>> '+memberBenefitProgramEligiblePliMap);
        // insert memberBenefitToInsertList;
        return memberBenefitToInsertList;

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

    public class memberBenefitProgramWrapper {
        public Member_Benefit_Program__c memberBenefitProgramRec {get; set;}
        //public Asset assetRec {get; set;}
        public Map<String,List<Asset>> customerAssetListMap {get; set;} 
        public Boolean exactProductMatch {get; set;}
        // public Eligible_Customer__c eligibleCustomerRec {get; set;}
        
        public memberBenefitProgramWrapper(Member_Benefit_Program__c memberBenefitProgramRec, Map<String,List<Asset>> customerAssetListMap, Boolean exactProductMatch){
            this.memberBenefitProgramRec = memberBenefitProgramRec;
            //this.assetRec = assetRec;
            this.customerAssetListMap = customerAssetListMap;
            // this.eligibleCustomerRec = eligibleCustomerRec;
            this.exactProductMatch = exactProductMatch;
        }
    }

    public without sharing class WithoutShare {

        public List<Eligible_Products__c> getEligibleProducts(Set<String> eligibleProductIds, Set<String> campaignIds){
            return [SELECT  Id,
                            Name,
                            (SELECT Id, 
                                    Product__c,
                                    Product__r.SAP_Product_Heirarchy__c,
                                    Product__r.ProductCode,
                                    Product_Model__c, 
                                    Customer_Facing_Name__c,
                                    Eligible_Product__c
                            FROM Eligible_Product_Line_Items__r),
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
                            FROM Member_Benefit_Programs__r 
                            WHERE Id IN: campaignIds)
                    FROM Eligible_Products__c
                    WHERE Id IN: eligibleProductIds];  
        }

        public Map<Id,Member_Benefit_Program__c> getMemberBenefitPrograms(List<String> brands, Set<String> assetCustomerAccountIds){
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
                                                                            Customer_ContactId__c,
                                                                            Customer_Name__c,
                                                                            Member_Benefit_Program__r.Start_Date__c,
                                                                            Member_Benefit_Program__r.End_Date__c,
                                                                            Member_Benefit_Program__r.Valid_From__c,
                                                                            Member_Benefit_Program__r.Valid_To__c,
                                                                            Member_Benefit_Program__r.Name
                                                                    FROM Eligible_Customers__r
                                                                    WHERE Customer__c IN: assetCustomerAccountIds 
                                                                    ORDER BY CreatedDate ASC)          
                                                            FROM Member_Benefit_Program__c 
                                                            WHERE Brand__c IN: brands]);  
        }

        public List<Asset> getAssets(Set<String> assetIds){
            return [SELECT  Id, 
                            AccountId,
                            Brand__c,
                            Account.Name, 
                            ContactId,
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
                    WHERE Id IN: assetIds
                    ORDER BY CreatedDate ASC];  
        }

    }   
}