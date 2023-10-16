/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: Batch Class to invoke Blackhawk API
*/ 
global class BlackhawkAPIBatch implements database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    public List<Member_Benefit__c> memberBenefitListToProcess = new List<Member_Benefit__c>();
    public List<Member_Benefit__c> memberBenefitToUpdateList = new List<Member_Benefit__c>();
    public String integAction = '';
    public static final String APPROVEDGIFTCARDSUCCESS = 'Approved - Gift Card Platform Success';
    public static final String APPROVEDGIFTCARDERROR = 'Approved - Gift Card Platform Error';
    public static final String SUCCESSCODE = '201';
 
    global BlackhawkAPIBatch(String integAction, List<Member_Benefit__c> memberBenefitList) {
        this.integAction = integAction;
        memberBenefitListToProcess = memberBenefitList;
    }

    global BlackhawkAPIBatch(List<Member_Benefit__c> memberBenefitList) {
        memberBenefitListToProcess = memberBenefitList;
    }

    global Database.querylocator start(Database.BatchableContext BC){
        string query = 'SELECT Id, Name, Gift_Card_Request_Counter__c, Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__c, Member_Benefit_Program__c, Member_Benefit_Program__r.Gift_Card_Value__c, Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__r.Content_Provider_Code__c FROM Member_Benefit__c WHERE Id IN: memberBenefitListToProcess';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Member_Benefit__c> memberBenefitList = (List<Member_Benefit__c>)scope;
        MembershipLoyaltyController.WithoutShare membershipControllerElevContext = new MembershipLoyaltyController.WithoutShare();

        for(Member_Benefit__c memberBenefit : memberBenefitList){
           
            if(LIMITS.getCallouts() < LIMITS.getLimitCallouts()){
        
                if(memberBenefit.Member_Benefit_Program__r.Gift_Card_Value__c != NULL && memberBenefit.Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__c != NULL){
                    // BlackhawkAPIService.RealTimeEgiftBulkResponseWrapper giftCardWrap = BlackhawkAPIService.submitRealTimeEgiftBulk(memberBenefit);
                    // if(giftCardWrap.hasError == FALSE){
                    memberBenefit = membershipControllerElevContext.updateMemberBenefitFields(memberBenefit,  BlackhawkAPIService.submitRealTimeEgiftBulk(memberBenefit));
                    System.debug('memberBenefit >>> '+memberBenefit);
                    memberBenefitToUpdateList.add(memberBenefit);
                    // }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        if(!memberBenefitToUpdateList.isEmpty()){
            try{
                update memberBenefitToUpdateList;
            }
            catch (Exception ex){
                System.debug(ex);
            }    
        }
    }

}