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
    public static final String CURRENTLYUNAVAILABLE = 'The service is not currently available';
    public static final String ORDERISCANCELLED = 'Order is cancelled due to failure to meet SLA for this SYNCHRONOUS_ONLY order';
    public static final String REQUESTCANNOTBEPROCESSED = 'Request cannot be processed at this time';
    public static final String ORDERNOTSUBMITTED = 'An error has occurred and your order has not been submitted';
    public static final String NOPERMISSION = 'Does not have permissions to submit order using this quote';
    
    public Blackhawk_API_Settings__c blackhawkApiSetting = new Blackhawk_API_Settings__c();
    public String query = 'SELECT Id, Name, Gift_Card_URL__c, Status__c, Gift_Card_Request_Counter__c, Gift_Card_Provider_Error_Message__c, Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__c, Member_Benefit_Program__c, Member_Benefit_Program__r.Gift_Card_Value__c, Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__r.Content_Provider_Code__c, Request_Id__c FROM Member_Benefit__c ';

    global BlackhawkAPIBatch(String action, List<Member_Benefit__c> memberBenefitList) {
        integAction = action;
        memberBenefitListToProcess = memberBenefitList;
        if(blackhawkApiSetting.Id == NULL) blackhawkApiSetting = BlackhawkAPIService.getActiveBlackhawkApiSetting();
    }

    global Database.querylocator start(Database.BatchableContext BC){
        
        Integer maxRetry = Integer.valueOf(blackhawkApiSetting.Maximum_Retry_Count__c);
        if(integAction == 'submit') query += ' WHERE Id IN: memberBenefitListToProcess';
        else if(integAction == 'retry') query += ' WHERE Id IN: memberBenefitListToProcess AND Status__c =: APPROVEDGIFTCARDERROR AND Gift_Card_Request_Counter__c != 0 AND Gift_Card_Request_Counter__c != NULL AND Gift_Card_Request_Counter__c <: maxRetry';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Member_Benefit__c> memberBenefitList = (List<Member_Benefit__c>)scope;
        MembershipLoyaltyController.WithoutShare membershipControllerElevContext = new MembershipLoyaltyController.WithoutShare();

        for(Member_Benefit__c memberBenefit : memberBenefitList){
            if(LIMITS.getCallouts() < LIMITS.getLimitCallouts()){
                System.debug('integAction >>> '+integAction);
                if(integAction == 'submit' && memberBenefit.Member_Benefit_Program__r.Gift_Card_Value__c != NULL && memberBenefit.Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__c != NULL && memberBenefit.Request_Id__c == NULL){
                    System.debug('submit');
                    memberBenefit = membershipControllerElevContext.updateMemberBenefitFields(memberBenefit,  BlackhawkAPIService.submitRealTimeEgiftBulk(memberBenefit));
                    memberBenefitToUpdateList.add(memberBenefit);
                }
                else if(integAction == 'retry' && memberBenefit.Request_Id__c != NULL && memberBenefit.Gift_Card_Provider_Error_Message__c != NULL 
                && (memberBenefit.Gift_Card_Provider_Error_Message__c.containsIgnoreCase(BlackhawkAPIService.RETRYSTATUSCODE) || memberBenefit.Gift_Card_Provider_Error_Message__c.containsIgnoreCase(BlackhawkAPIService.REQUESCANNOTBEPROCESSEDATTHISTIME))){
                    System.debug('retry');
                    Member_Benefit__c memberBenefitInstance = membershipControllerElevContext.updateMemberBenefitFields(memberBenefit, BlackhawkAPIService.getEGiftBulkCodeRetrievalInfo(memberBenefit).successEGiftWrap);
                    System.debug('not a new request >>> ');
                    if(memberBenefitInstance == NULL){
                        System.debug('new request >>> ');
                        memberBenefit = membershipControllerElevContext.updateMemberBenefitFields(memberBenefit,  BlackhawkAPIService.submitRealTimeEgiftBulk(memberBenefit));
                    } 
                    memberBenefitToUpdateList.add(memberBenefit);
                }
                else{
                    System.debug('integAction >>> '+integAction);
                    System.debug('no action');
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
                System.debug('BlackhawkAPIBatch >>> finish >>> '+ex.getMessage());
            }    
        }
    }

}