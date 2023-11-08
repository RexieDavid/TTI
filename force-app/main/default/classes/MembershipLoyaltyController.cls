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
        Set<String> assetCustomerAccountIds = new Set<String>(); //CUSTOMER IDS (ACCOUNT) FROM REGISTERED ASSET
        Set<String> eligibleProductIds = new Set<String>();
        List<String> brandSet = new List<String>{'Ryobi'};
        Set<Id> activeMemberBenefitIds = new Set<Id>();
        Map<String,memberBenefitProgramWrapper> memberBenefitProgramWrapMap = new Map<String,memberBenefitProgramWrapper>();
        Map<String,List<Asset>> customerAssetListMap = new Map<String,List<Asset>>(); //CONTACT, LIST OF REGISTERED ASSET MAP
        Map<Id,Member_Benefit_Program__c> memberBenefitProgramsMap = new Map<Id,Member_Benefit_Program__c>();
        Map<Id,Set<String>> memberBenefitWithHierarchiesMap = new Map<Id,Set<String>>();

        //LOOP registeredProductList - LIST OF PRODUCTS FROM REGISTERED ASSETS
        for(Asset assetRecord : registeredProductList){
            if(assetRecord.AccountId != NULL) assetCustomerAccountIds.add(assetRecord.AccountId);
            if(customerAssetListMap.containsKey(assetRecord.ContactId)) customerAssetListMap.get(assetRecord.ContactId).add(assetRecord);
            else customerAssetListMap.put(assetRecord.ContactId, new List<Asset> {assetRecord});
        }
        memberBenefitProgramsMap = withoutSharing.getMemberBenefitPrograms(brandSet,assetCustomerAccountIds);
        if(!memberBenefitProgramsMap.isEmpty()){
            //Loop Member_Benefit_Program__c Records
            for(Member_Benefit_Program__c memberBenefitProgram : memberBenefitProgramsMap.values()){ 
                memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper();

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
                                    // System.debug(eligibleCustomer.Customer_Name__c + ' meets the date range for ' + eligibleCustomer.Member_Benefit_Program__r.Name + ' by Purchasing '+assetRec.ProductCode+' - '+assetRec.ProductDescription + ' last ' +assetRec.PurchaseDate + ' and Registered it on ' +regDate +'. Campaign Purchase Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Start_Date__c + ' until ' +eligibleCustomer.Member_Benefit_Program__r.End_Date__c +' and Registration Period starts at '+eligibleCustomer.Member_Benefit_Program__r.Valid_From__c + ' until ' + eligibleCustomer.Member_Benefit_Program__r.Valid_To__c);
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
                //Build memberBenefitWithHierarchiesMap
                if(memberBenefitProgram.Product_Hierarchies__c != NULL){
                    memberBenefitWithHierarchiesMap.put(memberBenefitProgram.Id,new Set<String>(memberBenefitProgram.Product_Hierarchies__c.split(';')));
                }
                //Build memberBenefitProgramWrapper
                if(memberBenefitWrap.memberBenefitProgramRec != NULL) memberBenefitProgramWrapMap.put(memberBenefitProgram.Id,memberBenefitWrap);
            }
        } 
        if(!memberBenefitProgramWrapMap.isEmpty()){
            //Get Active Member Benefits > Asset and Contact Id to identify what are the active ones to limit the creation of the Member Benefit
            Map<Id,Set<String>> contactWithProductCodesMap = getContactWithProductCodesMap(activeMemberBenefitIds);
            //RETRIEVE MAP OF MEMBER BENEFIT > ELIGIBLE PRODUCT > ELIGIBLE PRODUCT LINE ITEMS
            Map<Id, Set<String>> memberBenefitWithEligibleProductLineMap = getMemberBenefitWithEligibleProductLineMap(eligibleProductIds,memberBenefitProgramWrapMap.keySet());
            try{
                Set<String> customerAssetCode = new Set<String>();
                //Loop through Member Benefit Program Id
                for(String memberBenefitProgramId : memberBenefitProgramWrapMap.keySet()){                     
                    memberBenefitProgramWrapper memberBenefitProgramWrap = memberBenefitProgramWrapMap.get(memberBenefitProgramId);
                    System.debug('MEMBER BENEFIT PROGRAM >>> '+memberBenefitProgramWrap.memberBenefitProgramRec.Name);                    
                    String currEligibleProductId = memberBenefitProgramWrap.memberBenefitProgramRec.Eligible_Products__c;
                    System.debug('ELIGIBLE PRODUCT Id >>> '+currEligibleProductId);
                    if(memberBenefitProgramWrap.customerAssetListMap != NULL && memberBenefitProgramWrap.customerAssetListMap.keySet().size() > 0){
                        //Loop through Contact Ids via customerAssetListMap
                        for(String customerId : memberBenefitProgramWrap.customerAssetListMap.keySet()){ 
                            System.debug('CUSTOMER Id >>> '+customerId);
                            Integer numberOfMemberBenefitOfThisCustomer = 0;
                            if(memberBenefitProgramWrap.customerNumberMemberBenefitMap != NULL && memberBenefitProgramWrap.customerNumberMemberBenefitMap.containsKey(customerId)){
                                numberOfMemberBenefitOfThisCustomer += memberBenefitProgramWrap.customerNumberMemberBenefitMap.get(customerId);            
                            }                    
                            System.debug('CURRENT NUMBER OF MEMBER BENEFIT OF THIS CUSTOMER >>> '+numberOfMemberBenefitOfThisCustomer + ' UNDER '+memberBenefitProgramWrap.memberBenefitProgramRec.Name);
                            //CHECK Maximum_Gift_Card_Per_Customer__c 
                            if(numberOfMemberBenefitOfThisCustomer < memberBenefitProgramWrap.memberBenefitProgramRec.Maximum_Gift_Card_Per_Customer__c){
                                System.debug('CURRENT NUMBER OF MEMBER BENEFIT ('+numberOfMemberBenefitOfThisCustomer+') OF THIS CUSTOMER IS LESS THAN THE MAXIMUM GC PER CUSTOMER ('+memberBenefitProgramWrap.memberBenefitProgramRec.Maximum_Gift_Card_Per_Customer__c+')');
                                Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Member_Benefit_UUID__c = getUUID()); 
                                String productCodes = '';
                                String registeredToolName = '';
                                Date registeredToolPurchaseDate;
                                String currBrand = '';
                                System.debug('NUMBER OF ASSET OF '+customerId+' >>> '+memberBenefitProgramWrap.customerAssetListMap.get(customerId).size());
                                for(Asset assetRecord : memberBenefitProgramWrap.customerAssetListMap.get(customerId)){
                                    Asset assetRecToUpdate = new Asset();
                                    if(currBrand == '') currBrand = assetRecord.Brand__c;
                                    //CHECK IF CUSTOMER > ASSET > PRODUCT CODE IS ALREADY A MEMBER BENEFIT  
                                    if(contactWithProductCodesMap.containsKey(customerId)){
                                        if(contactWithProductCodesMap.get(customerId).contains(assetRecord.ProductCode)){
                                            System.debug('ASSET PRODUCT CODE ('+assetRecord.ProductCode+') EXIST IN contactWithProductCodesMap ('+contactWithProductCodesMap.get(customerId) + ') - SKIP THIS ASSET('+assetRecord.ProductCode+')');
                                            continue; //Do not add Member Benefit if the Customer is currently has a Member Benefit in the same Product Code
                                        }
                                        else 
                                        System.debug('ASSET PRODUCT CODE ('+assetRecord.ProductCode+') DOES NOT EXIST IN contactWithProductCodesMap ('+contactWithProductCodesMap.get(customerId) + ') - PROCESS THIS ASSET('+assetRecord.ProductCode+')');
                                    }
                                    //CHECK IF ASSET IS Eligible Product Line Item based on Product Code
                                    if(!memberBenefitWithEligibleProductLineMap.isEmpty() 
                                    && memberBenefitWithEligibleProductLineMap.containsKey(memberBenefitProgramId)
                                    && memberBenefitWithEligibleProductLineMap.get(memberBenefitProgramId).contains(assetRecord.ProductCode) 
                                    && !productCodes.containsIgnoreCase(assetRecord.ProductCode)
                                    && !customerAssetCode.contains(customerId+assetRecord.ProductCode)){
                                        System.debug('CUSTOMER ('+assetRecord.Account.Name + ') MATCH VIA PRODUCT CODE >>> '+ assetRecord.ProductCode + ' >>> ELIGIBLE PLI '+memberBenefitWithEligibleProductLineMap.get(memberBenefitProgramId));
                                        customerAssetCode.add(customerId+assetRecord.ProductCode);
                                        productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                                        if(!registeredToolName.containsIgnoreCase(assetRecord.Product2.Name))
                                        registeredToolName += (registeredToolName != '') ? ';'+assetRecord.Product2.Name : assetRecord.Product2.Name;
                                        if(registeredToolPurchaseDate == NULL)
                                        registeredToolPurchaseDate = assetRecord.PurchaseDate;
                                        memberBenefitProgramWrap.exactProductMatch = true;
                                        memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                                        memberBenefitToInsert.Member_Benefit_Program__c = memberBenefitProgramId;
                                        if(assetRecToUpdate.Id == NULL){
                                            assetRecToUpdate.Id = assetRecord.Id;
                                            assetRecToUpdate.Member_Benefit__r = new Member_Benefit__c(Member_Benefit_UUID__c = memberBenefitToInsert.Member_Benefit_UUID__c);
                                        }
                                    }
                                    //CHECK IF ASSET IS Eligible on SAPProductHeirarchy__c  
                                    if(assetRecord.SAPProductHeirarchy__c != NULL && !memberBenefitWithHierarchiesMap.isEmpty() 
                                    && memberBenefitWithHierarchiesMap.containsKey(memberBenefitProgramId) 
                                    && memberBenefitWithHierarchiesMap.get(memberBenefitProgramId).contains(assetRecord.SAPProductHeirarchy__c)
                                    && !productCodes.containsIgnoreCase(assetRecord.ProductCode) 
                                    && !customerAssetCode.contains(customerId+assetRecord.ProductCode)){
                                        System.debug('CUSTOMER ('+assetRecord.Account.Name+')'+' ASSET ('+assetRecord.ProductCode+ ' - ' +assetRecord.SAPProductHeirarchy__c+') MATCH VIA HIERARCHY memberBenefitWithHierarchiesMap ('+memberBenefitWithHierarchiesMap.get(memberBenefitProgramId)+')');     
                                        customerAssetCode.add(customerId+assetRecord.ProductCode);
                                        productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
                                        if(!registeredToolName.containsIgnoreCase(assetRecord.Product2.Name)) 
                                        registeredToolName += (registeredToolName != '') ? ';'+assetRecord.Product2.Name : assetRecord.Product2.Name;
                                        if(registeredToolPurchaseDate == NULL) 
                                        registeredToolPurchaseDate = assetRecord.PurchaseDate;
                                        memberBenefitToInsert.Registered_Products__c = currEligibleProductId;
                                        memberBenefitToInsert.Member_Benefit_Program__c = memberBenefitProgramId;
                                        if(assetRecToUpdate.Id == NULL){
                                            assetRecToUpdate.Id = assetRecord.Id;
                                            assetRecToUpdate.Member_Benefit__r = new Member_Benefit__c(Member_Benefit_UUID__c = memberBenefitToInsert.Member_Benefit_UUID__c);
                                        }
                                    } 
                                    
                                    if(assetRecToUpdate.Id != NULL){
                                        validRegisteredProductList.add(assetRecToUpdate);
                                    } 
                                }
                                if(productCodes.length()>0){
                                    memberBenefitToInsert.Brand__c = currBrand;
                                    memberBenefitToInsert.Customer_Name__c = customerId;
                                    memberBenefitToInsert.Registered_Tool_Name__c = registeredToolName;
                                    memberBenefitToInsert.Registered_Product_Code__c = productCodes;
                                    memberBenefitToInsert.Registered_Tool_Purchase_Date__c = registeredToolPurchaseDate;
                                    System.debug('MEMBER BENEFIT TO INSERT >>> '+memberBenefitToInsert);     
                                    memberBenefitToInsertList.add(memberBenefitToInsert);
                                }   
                            }
                            else 
                            System.debug('CURRENT NUMBER OF MEMBER BENEFIT ('+numberOfMemberBenefitOfThisCustomer+') OF THIS CUSTOMER MEETS THE MAXIMUM GC PER CUSTOMER ('+memberBenefitProgramWrap.memberBenefitProgramRec.Maximum_Gift_Card_Per_Customer__c+')');
                        }    
                    }
                    System.debug('\n ------------------------------------------------ \n');
                }
                if(validRegisteredProductList.size() > 0 && memberBenefitToInsertList.size() > 0){
                    System.debug('NUMBER OF MEMBER BENEFIT TO INSERT >>> '+memberBenefitToInsertList.size());     
                    System.debug('VALID REGISTERED PRODUCT LIST  >>> '+validRegisteredProductList);     
                    genMemberBenefitWrap = new GenerateMemberBenefitWrapper(memberBenefitToInsertList,validRegisteredProductList);
                }    
            }
            catch(Exception e){
                System.debug('generateMemberBenefits  >>> '+e.getLineNumber() + ' - '+ e.getMessage());
            }       
        }
        return genMemberBenefitWrap;
    }

    //Get Active Member Benefits and Eligible Product Line Item > Product Code Map
    private static Map<Id,Set<String>> getMemberBenefitWithEligibleProductLineMap(Set<String> eligibleProductIds, Set<String> memberBenefitIds){

        Map<Id,Set<String>> contactWithProductCodesMap = new Map<Id,Set<String>>();

        for(Eligible_Products__c eligibleProduct : withoutSharing.getEligibleProducts(eligibleProductIds,memberBenefitIds)){
            //Check Member_Benefit_Programs__r and Eligible_Product_Line_Items__r
            if(eligibleProduct.Member_Benefit_Programs__r != NULL && eligibleProduct.Member_Benefit_Programs__r.size() > 0
            && eligibleProduct.Eligible_Product_Line_Items__r != NULL && eligibleProduct.Eligible_Product_Line_Items__r.size() > 0){ 
                //Loop Member_Benefit_Program__c for Eligible Products
                for(Member_Benefit_Program__c memberBenefit : eligibleProduct.Member_Benefit_Programs__r){ //Loop Member_Benefit_Program__c under Eligible_Products__c
                    //Loop Eligible_Product_Line_Item__c for Eligible Products to get contactWithProductCodesMap
                    for(Eligible_Product_Line_Item__c eligiblePLI : eligibleProduct.Eligible_Product_Line_Items__r){
                        if(contactWithProductCodesMap.containsKey(memberBenefit.Id)) contactWithProductCodesMap.get(memberBenefit.Id).add(eligiblePLI.Product_Model__c);
                        else contactWithProductCodesMap.put(memberBenefit.Id,new Set<String> {eligiblePLI.Product_Model__c});
                    }
                }
            }
        }

        return contactWithProductCodesMap;
    }
    

    //Get Active Member Benefits > Asset and Contact Id to identify what are the active ones to limit the creation of the Member Benefit
    private static Map<Id,Set<String>> getContactWithProductCodesMap(Set<Id> activeMemberBenefitIds){

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

        return contactWithProductCodesMap;
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
        public Map<String,List<Asset>> customerAssetListMap {get; set;} 
        // public List<Eligible_Product_Line_Item__c> eligibleProductLinesList{get; set;} 
        // public Map<Id,Set<String>> memberBenefitWithEligibleProductLineMap {get; set;}  
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
                                                                    Active__c,
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

        public Member_Benefit__c updateMemberBenefitFields(Member_Benefit__c memberBenefit, BlackhawkEGiftWrapper blackhawkEGiftWrap){
            Boolean updateMemberBenefit = false;
            System.debug('blackhawkEGiftWrap >>> '+blackhawkEGiftWrap);
            if(blackhawkEGiftWrap != NULL && blackhawkEGiftWrap.orderNumber != NULL && blackhawkEGiftWrap.quantity == 1 && memberBenefit.Gift_Card_URL__c == NULL && memberBenefit.Status__c != APPROVEDGIFTCARDSUCCESS){
                for(BlackhawkEGiftWrapper.EGifts egift : blackhawkEGiftWrap.eGifts){
                    memberBenefit.Gift_Card_URL__c = egift.url;
                    memberBenefit.Gift_Card_Provider_Order_Number__c = blackhawkEGiftWrap.orderNumber;
                    memberBenefit.Gift_Card_Provider_Error_Message__c = '';
                    memberBenefit.Status__c = APPROVEDGIFTCARDSUCCESS;
                }
                updateMemberBenefit = true;
            }
            return updateMemberBenefit ? memberBenefit : null;
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