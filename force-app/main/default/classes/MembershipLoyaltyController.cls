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
                                eligibleProductIds.add(memberBenefit.Eligible_Products__c); 
                            }
                        }
                    }
                }
                if(!filteredCustomerAssetListMap.isEmpty()){
                    memberBenefitProgramWrapper memberBenefitWrap = new memberBenefitProgramWrapper(memberBenefit,filteredCustomerAssetListMap,false); //Build memberBenefitProgramWrapper Wrapper
                    memberBenefitProgramWrapMap.put(memberBenefit.Id,memberBenefitWrap);
                }      
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

        for(String memberBenefitProgramId : memberBenefitProgramWrapMap.keySet()){ //Loop through Member Benefit Program Id
       
            memberBenefitProgramWrapper memberBenefitProgramWrap = memberBenefitProgramWrapMap.get(memberBenefitProgramId);

            String currEligibleProductId = memberBenefitProgramWrap.memberBenefitProgramRec.Eligible_Products__c;

            if(memberBenefitProgramWrap.customerAssetListMap != NULL && memberBenefitProgramWrap.customerAssetListMap.keySet().size() > 0){

                for(String customerId : memberBenefitProgramWrap.customerAssetListMap.keySet()){ //Loop through Contact Ids
                    
                    Member_Benefit__c memberBenefitToInsert = new Member_Benefit__c(Status__c = 'Submitted', Member_Benefit_UUID__c = getUUID()); 
                    String productCodes = '';
                    String currBrand = '';
                    for(Asset assetRecord : memberBenefitProgramWrap.customerAssetListMap.get(customerId)){
                        //Check asset if assetRecord is an Eligible Product
                        Asset assetRecToUpdate = new Asset();//Receipt__c = 'a2SAD000000BlZt2AK');
                        if(memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId) != NULL){
                            if(currBrand == '') currBrand = assetRecord.Brand__c;
                            for(Eligible_Product_Line_Item__c elPli : memberBenefitProgramEligiblePliMap.get(memberBenefitProgramId)){ //Loop through Eligible PLI
                                if(assetRecord.ProductCode == elPli.Product_Model__c){
                                    if(!productCodes.containsIgnoreCase(assetRecord.ProductCode)) productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
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
                            for(String hierarchy : memberBenefitProgramWrap.memberBenefitProgramRec.Product_Hierarchies__c.split(';')){
                                System.debug('hierarchy >>> '+hierarchy);
                                System.debug('assetRecord.SAPProductHeirarchy__c >>> '+assetRecord.SAPProductHeirarchy__c);
                                if(assetRecord.SAPProductHeirarchy__c.containsIgnoreCase(hierarchy)){ //Check if the asset match any of the Product Heirarchy 
                                    if(!productCodes.containsIgnoreCase(assetRecord.ProductCode)){
                                        productCodes += (productCodes != '') ? ';'+assetRecord.ProductCode : assetRecord.ProductCode;
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
                        memberBenefitToInsert.Product_Model__c = productCodes;
                        memberBenefitToInsert.Brand__c = currBrand;
                        memberBenefitToInsert.Customer_Name__c = customerId;
                        memberBenefitToInsertList.add(memberBenefitToInsert);
                    }

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
            System.debug('memberBenefitProgramEligiblePliMap >>> '+memberBenefitProgramEligiblePliMap);
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

    public class memberBenefitProgramWrapper {
        public Member_Benefit_Program__c memberBenefitProgramRec {get; set;}
        public Map<String,List<Asset>> customerAssetListMap {get; set;} 
        public Boolean exactProductMatch {get; set;}
        
        public memberBenefitProgramWrapper(Member_Benefit_Program__c memberBenefitProgramRec, Map<String,List<Asset>> customerAssetListMap, Boolean exactProductMatch){
            this.memberBenefitProgramRec = memberBenefitProgramRec;
            this.customerAssetListMap = customerAssetListMap;
            this.exactProductMatch = exactProductMatch;
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

        public Member_Benefit__c updateMemberBenefitFields(Member_Benefit__c memberBenefit, BlackhawkAPIService.RealTimeEgiftBulkResponseWrapper giftCardWrap){
        
            memberBenefit.Gift_Card_Request_Counter__c = memberBenefit.Gift_Card_Request_Counter__c != NULL ? memberBenefit.Gift_Card_Request_Counter__c+1 : 1;
            
            if(giftCardWrap.hasError == FALSE && giftCardWrap.statusCode == SUCCESSCODE){
                if(giftCardWrap.successWrap.url != NULL && giftCardWrap.successWrap.isCompleted == true){
                    memberBenefit.Gift_Card_URL__c = giftCardWrap.successWrap.url;
                    memberBenefit.Status__c = APPROVEDGIFTCARDSUCCESS;
                    memberBenefit.Gift_Card_Provider_Order_Number__c = giftCardWrap.successWrap.orderNumber;
                    memberBenefit.Gift_Card_Provider_Transaction_Id__c = giftCardWrap.successWrap.transactionId;
                }
            }
            else {
                if(giftCardWrap.statusCode.startsWith('4')){
                    memberBenefit.Status__c = APPROVEDGIFTCARDERROR;
                    memberBenefit.Gift_Card_Provider_Error_Message__c = '';
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

    }   
}