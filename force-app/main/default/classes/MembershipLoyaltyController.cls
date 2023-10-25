/** 
 * @description:        Controller Membership Loyalty Program Automations
 * 
 * @author:             Rexie David
 * @date:               10/3/2023
*/
public with sharing class MembershipLoyaltyController {
    
    public static WithoutShare withoutSharing = new WithoutShare();
    public static final String APPROVEDGIFTCARDSUCCESS = 'Approved - Gift Card Platform Success';
    public static final String APPROVEDGIFTCARDERROR = 'Approved - Gift Card Platform Error';
    public static final String SUCCESSCODE = '201';
    
    public static GenerateMemberBenefitWrapper generateMemberBenefits (Set<String> assetIds){

        GenerateMemberBenefitWrapper genMemberBenefitWrap;
        List<Member_Benefit__c> memberBenefitToInsertList = new List<Member_Benefit__c>();
        List<Asset> validRegisteredProductList = new List<Asset>();
        List<Asset> registeredProductList = withoutSharing.getAssets(assetIds); // Retrieve Assets (Registered Products)
        Set<String> assetCustomerAccountIds = new Set<String>();
        Set<String> eligibleProductIds = new Set<String>();
        List<String> brandSet = new List<String>{'Ryobi'};
        Set<Id> activeMemberBenefitIds = new Set<Id>();
        Map<String,memberBenefitProgramWrapper> memberBenefitProgramWrapMap = new Map<String,memberBenefitProgramWrapper>();
        // Map<Id,List<Eligible_Product_Line_Item__c>> memberBenefitProgramEligiblePliMap = new Map<Id,List<Eligible_Product_Line_Item__c>>();
        Map<String,List<Asset>> customerAssetListMap = new Map<String,List<Asset>>();

        //Loop through Registered Products and build customerAssetListMap - Map of Customer(ContactId) and Asset registered
        for(Asset assetRecord : registeredProductList){
            if(assetRecord.AccountId != NULL) assetCustomerAccountIds.add(assetRecord.AccountId);
            if(customerAssetListMap.containsKey(assetRecord.ContactId)) customerAssetListMap.get(assetRecord.ContactId).add(assetRecord);
            else customerAssetListMap.put(assetRecord.ContactId, new List<Asset> {assetRecord});
        }

        Map<Id,Member_Benefit_Program__c> memberBenefitProgramsMap = withoutSharing.getMemberBenefitPrograms(brandSet,assetCustomerAccountIds);
        
        if(!memberBenefitProgramsMap.isEmpty()){
            //Loop Member_Benefit_Program__c Records
            for(Member_Benefit_Program__c memberBenefitProgram : memberBenefitProgramsMap.values()){ 
                memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper();
                // Set<Id> memberBenefitIds = new Set<Id>();
                Map<Id,Integer> customerMemberBenefitNumberMap = new Map<Id,Integer>();
                //Check if MBP has Eligible Customers
                if(memberBenefitProgram.Eligible_Customers__r != NULL && memberBenefitProgram.Eligible_Customers__r.size() > 0){
                    //Map of CustomerId(Contact Id) - List of Asset that meets the Date Range
                    Map<String,List<Asset>> filteredCustomerAssetListMap = new Map<String,List<Asset>>(); 
                    //Loop Eligible_Customers
                    for(Eligible_Customer__c eligibleCustomer : memberBenefitProgram.Eligible_Customers__r){ 
                        //Check if Eligible Customer registered an Asset (via customerAssetListMap)
                        if(customerAssetListMap.containsKey(eligibleCustomer.Customer_ContactId__c)){
                            //Loop through Assets per Eligible Customers to check Asset Dates
                            for(Asset assetRec : customerAssetListMap.get(eligibleCustomer.Customer_ContactId__c)){ 
                                DateTime regDateTime = assetRec.Registered_Date_Formula__c;
                                Date regDate = date.newinstance(regDateTime.year(), regDateTime.month(), regDateTime.day());
                                //Check if Meet Date Range
                                if(meetsDateRange(assetRec,eligibleCustomer)){ 
                                    System.debug(eligibleCustomer.Customer_Name__c + ' meets the date range for ' + eligibleCustomer.Member_Benefit_Program__r.Name + ' by Purchasing '+assetRec.ProductCode+' - '+assetRec.ProductDescription + ' last ' +assetRec.PurchaseDate + ' and Registered it on ' +regDate +'. Campaign Purchase Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Start_Date__c + ' until ' +eligibleCustomer.Member_Benefit_Program__r.End_Date__c +' and Registration Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Valid_From__c + ' until ' + eligibleCustomer.Member_Benefit_Program__r.Valid_To__c);
                                    //Build Map of CustomerId(Contact Id) - List of Asset that meets the Date Range
                                    if(filteredCustomerAssetListMap.containsKey(eligibleCustomer.Customer_ContactId__c)){
                                        filteredCustomerAssetListMap.get(eligibleCustomer.Customer_ContactId__c).add(assetRec);
                                    }   
                                    else{
                                        filteredCustomerAssetListMap.put(eligibleCustomer.Customer_ContactId__c,new List<Asset>{assetRec});
                                    }
                                    eligibleProductIds.add(memberBenefitProgram.Eligible_Products__c); 
                                }
                            }
                        }
                    }
                    //Build Wrapper memberBenefitProgramWrapper
                    if(!filteredCustomerAssetListMap.isEmpty()){
                        memberBenefitWrap.memberBenefitProgramRec = memberBenefitProgram;
                        memberBenefitWrap.customerAssetListMap = filteredCustomerAssetListMap;
                        memberBenefitWrap.exactProductMatch = false;
                        // if(memberBenefitProgramWrapMap.containsKey(memberBenefitProgram.Id)){
                        //     memberBenefitWrap = memberBenefitProgramWrapMap.get(memberBenefitProgram.Id);//= new memberBenefitProgramWrapper(memberBenefitProgram,filteredCustomerAssetListMap,false); //Build memberBenefitProgramWrapper Wrapper
                        // }
                        // else{
                        //     memberBenefitWrap = new memberBenefitProgramWrapper(memberBenefitProgram,filteredCustomerAssetListMap,false); //Build memberBenefitProgramWrapper Wrapper
                        //     memberBenefitProgramWrapMap.put(memberBenefitProgram.Id,memberBenefitWrap);
                        // }
                        // if(memberBenefitIds.size()>0) memberBenefitWrap.memberBenefitContactIdsSet = memberBenefitIds;            
                    }      
                }    
                //Check if MBP has existing Member Benefits
                if(memberBenefitProgram.Member_Benefits__r != NULL && memberBenefitProgram.Member_Benefits__r.size() > 0){
                    //Loop Member_Benefit__c records
                    for(Member_Benefit__c memberBenefit : memberBenefitProgram.Member_Benefits__r){
                        activeMemberBenefitIds.add(memberBenefit.Id);
                        // memberBenefitIds.add(memberBenefit.Customer_Name__c);
                        if(customerMemberBenefitNumberMap.containsKey(memberBenefit.Customer_Name__c)){
                            Integer currentNumber = customerMemberBenefitNumberMap.get(memberBenefit.Customer_Name__c);
                            currentNumber += 1;
                            customerMemberBenefitNumberMap.put(memberBenefit.Customer_Name__c,currentNumber);
                        }
                        else{
                            customerMemberBenefitNumberMap.put(memberBenefit.Customer_Name__c, 1);
                        }
                    }
                    if(!customerMemberBenefitNumberMap.isEmpty()) memberBenefitWrap.customerNumberMemberBenefitMap = customerMemberBenefitNumberMap;
                }
                //Build memberBenefitProgramWrapper
                if(memberBenefitWrap.memberBenefitProgramRec != NULL) memberBenefitProgramWrapMap.put(memberBenefitProgram.Id,memberBenefitWrap);
            }
        } 

        //Get Active Member Benefits > Asset and Contact Id to identify what are the active ones to limit the creation of the Member Benefit
        Map<Id,Set<String>> contactWithProductCodesMap = new Map<Id,Set<String>>();
        if(activeMemberBenefitIds.size()>0){
            for(Member_Benefit__c memberBenefit : withoutSharing.getActiveMemberBenefits(activeMemberBenefitIds)){
                if(memberBenefit.Assets__r != NULL && memberBenefit.Assets__r.size() > 0){
                    for(Asset assetRec : memberBenefit.Assets__r){
                        if(contactWithProductCodesMap.containsKey(assetRec.ContactId)){
                            contactWithProductCodesMap.get(assetRec.ContactId).add(assetRec.ProductCode);
                        }
                        else{
                            contactWithProductCodesMap.put(assetRec.ContactId, new Set<String> {assetRec.ProductCode});
                        }
                    }
                }
            }
        }
        
        System.debug('contactWithProductCodesMap >>> '+contactWithProductCodesMap);

        //Retrieve Eligible Products
        for(Eligible_Products__c eligibleProduct : withoutSharing.getEligibleProducts(eligibleProductIds,memberBenefitProgramWrapMap.keySet())){
            //Check Member_Benefit_Programs__r and Eligible_Product_Line_Items__r
            if(eligibleProduct.Member_Benefit_Programs__r != NULL && eligibleProduct.Member_Benefit_Programs__r.size() > 0
            && eligibleProduct.Eligible_Product_Line_Items__r != NULL && eligibleProduct.Eligible_Product_Line_Items__r.size() > 0){ 
                //Loop 
                for(Member_Benefit_Program__c memberBenefit : eligibleProduct.Member_Benefit_Programs__r){ //Loop Member_Benefit_Program__c under Eligible_Products__c
                    if(memberBenefitProgramWrapMap.containsKey(memberBenefit.Id)){//Check memberBenefit Program if Exist in Wrapper
                        // memberBenefitProgramEligiblePliMap.put(memberBenefit.Id,eligibleProduct.Eligible_Product_Line_Items__r);
                        memberBenefitProgramWrapMap.get(memberBenefit.Id).eligibleProductLinesList = eligibleProduct.Eligible_Product_Line_Items__r;
                    } 
                }
            }
        }

        // System.debug('memberBenefitProgramWrapMap >>> '+JSON.serializePretty(memberBenefitProgramWrapMap));
        try{
            Set<String> customerAssetCode = new Set<String>();
            //Loop through Member Benefit Program Id
            for(String memberBenefitProgramId : memberBenefitProgramWrapMap.keySet()){ 
                memberBenefitProgramWrapper memberBenefitProgramWrap = memberBenefitProgramWrapMap.get(memberBenefitProgramId);
                String currEligibleProductId = memberBenefitProgramWrap.memberBenefitProgramRec.Eligible_Products__c;
                if(memberBenefitProgramWrap.customerAssetListMap != NULL && memberBenefitProgramWrap.customerAssetListMap.keySet().size() > 0){
                    //Loop through Contact Ids via customerAssetListMap
                    for(String customerId : memberBenefitProgramWrap.customerAssetListMap.keySet()){ 
                        Integer numberOfMemberBenefitOfThisCustomer = 0;
                        if(memberBenefitProgramWrap.customerNumberMemberBenefitMap != NULL && memberBenefitProgramWrap.customerNumberMemberBenefitMap.containsKey(customerId)){
                            numberOfMemberBenefitOfThisCustomer += memberBenefitProgramWrap.customerNumberMemberBenefitMap.get(customerId);            
                        }
                        if(numberOfMemberBenefitOfThisCustomer < memberBenefitProgramWrap.memberBenefitProgramRec.Maximum_Gift_Card_Per_Customer__c){
                            Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Member_Benefit_UUID__c = getUUID()); 
                            String productCodes = '';
                            String registeredToolName = '';
                            Date registeredToolPurchaseDate;
                            String currBrand = '';
                            for(Asset assetRecord : memberBenefitProgramWrap.customerAssetListMap.get(customerId)){
                                if(contactWithProductCodesMap.containsKey(customerId)){
                                    if(contactWithProductCodesMap.get(customerId).contains(assetRecord.ProductCode)){
                                        break; //Do not add Member Benefit if the Customer is currently has a Member Benefit in the same Product Code
                                    }
                                }
                                // String contactAssetId = '';//customerId+assetRecord.Id;
                                //Check asset if assetRecord is an Eligible Product
                                Asset assetRecToUpdate = new Asset();//Receipt__c = 'a2SAD000000BlZt2AK');
                                if(memberBenefitProgramWrap.eligibleProductLinesList != NULL && memberBenefitProgramWrap.eligibleProductLinesList.size() > 0){
                                    if(currBrand == '') currBrand = assetRecord.Brand__c;
                                    for(Eligible_Product_Line_Item__c elPli : memberBenefitProgramWrap.eligibleProductLinesList){ //Loop through Eligible PLI
                                        if(assetRecord.ProductCode == elPli.Product_Model__c && !customerAssetCode.contains(customerId+assetRecord.ProductCode)){
                                            customerAssetCode.add(customerId+assetRecord.ProductCode);
                                            if(!productCodes.containsIgnoreCase(assetRecord.ProductCode)) productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                                            if(!registeredToolName.containsIgnoreCase(assetRecord.Product2.Name)) registeredToolName += (registeredToolName != '') ? ';'+assetRecord.Product2.Name : assetRecord.Product2.Name;
                                            if(registeredToolPurchaseDate == NULL) registeredToolPurchaseDate = assetRecord.PurchaseDate;
                                            System.debug('CUSTOMER '+assetRecord.Account.Name + ' MATCH VIA PRODUCT CODE >>> '+ 'eligiblePli.Product_Model__c >>> '+elPli.Product_Model__c + ' assetRecord.ProductCode >>> '+assetRecord.ProductCode);
                                            memberBenefitProgramWrap.exactProductMatch = true;
                                            memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                                            memberBenefitToInsert.Member_Benefit_Program__c = memberBenefitProgramId;
                                            if(assetRecToUpdate.Id == NULL){
                                                assetRecToUpdate.Id = assetRecord.Id;
                                                assetRecToUpdate.Member_Benefit__r = new Member_Benefit__c(Member_Benefit_UUID__c = memberBenefitToInsert.Member_Benefit_UUID__c);
                                            }
                                            System.debug('assetRecToUpdate loop >>> '+memberBenefitToInsert);
                                            System.debug('assetRecToUpdate.Member_Benefit__r loop >>> '+assetRecToUpdate.Member_Benefit__r);
                                        }
                                    }
                                }

                                if(assetRecord.SAPProductHeirarchy__c != NULL && memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c != NULL){
                                    System.debug('memberBenefitProgramWrapMap >>> '+memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.split(';'));
                                    if(currBrand == '') currBrand = assetRecord.Brand__c;
                                    for(String hierarchy : memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.split(';')){
                                        System.debug('hierarchy >>> '+hierarchy);
                                        System.debug('assetRecord.SAPProductHeirarchy__c >>> '+assetRecord.SAPProductHeirarchy__c);
                                        if(assetRecord.SAPProductHeirarchy__c.containsIgnoreCase(hierarchy)){ //Check if the asset match any of the Product Heirarchy 
                                            if(!productCodes.containsIgnoreCase(assetRecord.ProductCode) && !customerAssetCode.contains(customerId+assetRecord.ProductCode)){
                                                productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                                                if(!registeredToolName.containsIgnoreCase(assetRecord.Product2.Name)) registeredToolName += (registeredToolName != '') ? ';'+assetRecord.Product2.Name : assetRecord.Product2.Name;
                                                if(registeredToolPurchaseDate == NULL) registeredToolPurchaseDate = assetRecord.PurchaseDate;
                                                customerAssetCode.add(customerId+assetRecord.ProductCode);
                                                System.debug('registeredToolName >>> '+registeredToolName);
                                                System.debug('CUSTOMER '+assetRecord.Account.Name +' MATCH VIA PRODUCT HIERARCHY >>> '+ 'memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c >>> '+memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c + ' assetRecord.SAPProductHeirarchy__c >>> '+assetRecord.SAPProductHeirarchy__c);
                                                memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                                                memberBenefitToInsert.Member_Benefit_Program__c = memberBenefitProgramId;
                                                if(assetRecToUpdate.Id == NULL){
                                                    System.debug('assetRecToUpdate Id Set >>> '+assetRecToUpdate.Id);
                                                    assetRecToUpdate.Id = assetRecord.Id;
                                                    assetRecToUpdate.Member_Benefit__r = new Member_Benefit__c(Member_Benefit_UUID__c = memberBenefitToInsert.Member_Benefit_UUID__c);
                                                }
                                                System.debug('assetRecToUpdate Id >>> '+assetRecToUpdate.Id);
                                                System.debug('assetRecToUpdate loop >>> '+memberBenefitToInsert);
                                                System.debug('assetRecToUpdate.Member_Benefit__r loop >>> '+assetRecToUpdate.Member_Benefit__r);
                                                break;
                                            } 
                                        }
                                    }
                                    //&& memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.containsIgnoreCase(assetRecord.SAPProductHeirarchy__c)){
                                    // && memberBenefitProgramWrap.exactProductMatch == false){
                                }
                                if(assetRecToUpdate.Id != NULL){
                                    // System.debug('assetRecToUpdate >>> '+assetRecToUpdate);
                                    validRegisteredProductList.add(assetRecToUpdate);
                                } 
                            }

                            if(productCodes.length()>0){
                                // memberBenefitToInsert.Product_Model__c = productCodes;
                                System.debug('registeredToolName FINAL >>> '+registeredToolName);
                                memberBenefitToInsert.Brand__c = currBrand;
                                memberBenefitToInsert.Customer_Name__c = customerId;
                                memberBenefitToInsert.Registered_Tool_Name__c = registeredToolName;
                                memberBenefitToInsert.Registered_Product_Code__c = productCodes;
                                memberBenefitToInsert.Registered_Tool_Purchase_Date__c = registeredToolPurchaseDate;
                                memberBenefitToInsertList.add(memberBenefitToInsert);
                            }   
                        }
                        // }                   
                    }    
                }
            }

            if(validRegisteredProductList.size() > 0 && memberBenefitToInsertList.size() > 0){
                genMemberBenefitWrap = new GenerateMemberBenefitWrapper(memberBenefitToInsertList,validRegisteredProductList);
                System.debug('validRegisteredProductList >>> '+validRegisteredProductList);
                System.debug('memberBenefitProgramWrapMap >>> '+memberBenefitProgramWrapMap);
                System.debug('memberBenefitToInsertList.size() >>> '+memberBenefitToInsertList.size());
                System.debug('memberBenefitToInsertList >>> '+memberBenefitToInsertList);
                System.debug('genMemberBenefitWrap.memberBenefitList >>> '+genMemberBenefitWrap.memberBenefitList);
                System.debug('genMemberBenefitWrap.assetList >>> '+genMemberBenefitWrap.assetList);
                // System.debug('memberBenefitProgramEligiblePliMap >>> '+memberBenefitProgramEligiblePliMap);
            }    
        }

        catch(Exception e){
            System.debug('generateMemberBenefits  >>> '+e.getLineNumber() + ' - '+ e.getMessage());
        }
        

        return genMemberBenefitWrap;

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

    // private static Map<Id,Set<Id>> getMemberBenefitProgramExistingMemberMap(Map<Id,Member_Benefit_Program__c> memberBenefitMap){
    //     Map<Id,Set<Id>> memberBenefitProgramExistingMember = new Map<Id,Set<Id>>();
    //     for(Member_Benefit_Program__c mbp : memberBenefitMap.values()){
    //         if(mbp.Member_Benefits__r != NULL && mbp.Member_Benefits__r.size() > 0){
    //             for(Member_Benefit__c mb : mbp.Member_Benefits__r){
    //                 if(memberBenefitProgramExistingMember.containsKey(mbp.Id)){
    //                     memberBenefitProgramExistingMember.get(mbp.Id).add(mb.Customer_Name__c);
    //                 }
    //                 else{
    //                     memberBenefitProgramExistingMember.put(mbp.Id, new Set<Id> {mb.Customer_Name__c});
    //                 }
    //             }
    //         }
    //     }
    //     return memberBenefitProgramExistingMember;
    // }

    public class memberBenefitProgramWrapper {
        public Member_Benefit_Program__c memberBenefitProgramRec {get; set;}
        public Map<String,List<Asset>> customerAssetListMap {get; set;} 
        public List<Eligible_Product_Line_Item__c> eligibleProductLinesList{get; set;} 
        // public Set<Id> memberBenefitContactIdsSet {get; set;}
        Map<Id,Integer> customerNumberMemberBenefitMap {get; set;}
        public Boolean exactProductMatch {get; set;}
        
        public memberBenefitProgramWrapper(Member_Benefit_Program__c memberBenefitProgramRec, Map<String,List<Asset>> customerAssetListMap, Boolean exactProductMatch){
            this.memberBenefitProgramRec = memberBenefitProgramRec;
            this.customerAssetListMap = customerAssetListMap;
            this.exactProductMatch = exactProductMatch;
        }

        public memberBenefitProgramWrapper(){

        }
    }

    public class GenerateMemberBenefitWrapper {
        public List<Member_Benefit__c> memberBenefitList {get; set;}
        public List<Asset> assetList {get; set;}

        public GenerateMemberBenefitWrapper(List<Member_Benefit__c> memberBenefitList, List<Asset> assetList){
            this.memberBenefitList = memberBenefitList;
            this.assetList = assetList;
        }
    }

    public static String getUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
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
                                                                    Maximum_Gift_Card_Per_Customer__c,
                                                                    (SELECT Id,
                                                                            Customer_Name__c,
                                                                            Customer_Name__r.AccountId
                                                                    FROM Member_Benefits__r
                                                                    WHERE Customer_Name__r.AccountId IN: assetCustomerAccountIds),
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
                                                            WHERE Brand__c IN: brands 
                                                            AND Active__c = TRUE
                                                            ORDER BY CreatedDate DESC]);  
        }

        public List<Member_Benefit__c> getActiveMemberBenefits(Set<Id> memberBenefitIds){
            return [SELECT  Id, 
                            (SELECT Id, ContactId, ProductCode
                            FROM Assets__r)
                    FROM Member_Benefit__c 
                    WHERE Id 
                    IN: memberBenefitIds];
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
                            Product2.Name,
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

        public Member_Benefit__c updateMemberBenefitFields(Member_Benefit__c memberBenefit, BlackhawkAPIService.RealTimeEgiftBulkResponseWrapper giftCardWrap){
        
            memberBenefit.Gift_Card_Request_Counter__c = memberBenefit.Gift_Card_Request_Counter__c != NULL ? memberBenefit.Gift_Card_Request_Counter__c+1 : 1;
            
            if(giftCardWrap.hasError == FALSE && giftCardWrap.statusCode == SUCCESSCODE){
                if(giftCardWrap.successWrap.url != NULL && giftCardWrap.successWrap.isCompleted == true){
                    memberBenefit.Gift_Card_URL__c = giftCardWrap.successWrap.url;
                    memberBenefit.Status__c = APPROVEDGIFTCARDSUCCESS;
                    memberBenefit.Gift_Card_Provider_Order_Number__c = giftCardWrap.successWrap.orderNumber;
                    memberBenefit.Gift_Card_Provider_Transaction_Id__c = giftCardWrap.successWrap.transactionId;
                    memberBenefit.Gift_Card_Provider_Error_Message__c = '';
                }
            }
            else {
                if(giftCardWrap.statusCode.startsWith('4') || giftCardWrap.statusCode.startsWith('5')){
                    memberBenefit.Status__c = APPROVEDGIFTCARDERROR;
                    memberBenefit.Gift_Card_Provider_Error_Message__c = 'Status Code: '+giftCardWrap.statusCode + '\n';
                    if(giftCardWrap.errorWrap.errors.size() > 0){
                        for(BlackhawkAPIService.Errors errorLog : giftCardWrap.errorWrap.errors){
                            memberBenefit.Gift_Card_Provider_Error_Message__c += ('Error Code: '+errorLog.errorCode + '\n' + 'Message: '+errorLog.message + '\n\n');
                        }
                    }
                }
            }
    
            return memberBenefit;
        }

        public void insertMemberBenefits(List<Member_Benefit__c> memberBenefitList, List<Asset> assetList){
            try{
                insert memberBenefitList;
                update assetList;
            }
            catch(Exception e){
                System.debug('MembershipLoyaltyController >>> insertMemberBenefits >>> ' + e.getLineNumber() + ' - ' +e.getMessage());  
            }
        }

        public List<Member_Benefit__c> getMemberBenefitToResubmit(){

            List<TTI_Error_Log__c> ttiErrorLog = [  SELECT Id, Name, Class_Name__c, Method_Name__c, Source_Object__c, Source_Record_Id__c, TTI_Line_Number__c, TTI_Message__c, TTI_Stack_Trace_String__c, TTI_Type_Name__c
                                                    FROM TTI_Error_Log__c 
                                                    WHERE Source_Object__c = 'Member_Benefit__c' 
                                                    AND Module_Name__c = 'Integration' 
                                                    AND Class_Name__c = 'BlackhawkAPIService' 
                                                    AND Method_Name__c = 'submitRealTimeEgiftBulk'
                                                    AND CreatedDate >= LAST_N_DAYS:2];

            Set<Id> memberBenefitIds = new Set<Id>();
            List<Member_Benefit__c> memberBenefitList = new List<Member_Benefit__c>();
            Blackhawk_API_Settings__c blackhawkApiSetting = BlackhawkAPIService.getActiveBlackhawkApiSetting();

            for(TTI_Error_Log__c errorLog : ttiErrorLog){
                
                if(errorLog.Source_Record_Id__c != NULL && errorLog.TTI_Message__c.containsIgnoreCase(BlackhawkAPIService.RETRYSTATUSCODE)){
                    memberBenefitIds.add(errorLog.Source_Record_Id__c);
                }

            }

            memberBenefitList = [SELECT Id FROM Member_Benefit__c WHERE ID IN: memberBenefitIds AND Status__c = 'Approved - Gift Card Platform Error' AND Gift_Card_Request_Counter__c <: blackhawkApiSetting.Maximum_Retry_Count__c];

            return memberBenefitList;

        }

    }   
}