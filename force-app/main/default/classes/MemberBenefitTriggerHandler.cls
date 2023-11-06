/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: This class handles all CRUD operations for the
* Member_Benefit__c Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class MemberBenefitTriggerHandler {

    public static final String APPROVEDAWAITINGACTIVATION = 'Approved - Awaiting Activation';
    public static final String APPROVEDACTIVATED = 'Approved - Activated';
    public static final String APPROVEDGIFTCARDPLATFORMSUCCESS = 'Approved - Gift Card Platform Success';
    public static final String APPROVEDGIFTCARDPLATFORMPENDING = 'Approved - Gift Card Pending Request';
    public static final String APPROVEDGIFTCARDISSUED = 'Approved - Gift Card Issued';

    /**
    * @author: Rexie Aaron David
    * @date: October 2023
    * @description: This method handles all on Before Insert
    * functionalities of the Case
    */
    public static void onBeforeInsert(List<Member_Benefit__c> newMemberBenefitList) {
        populateUUId(newMemberBenefitList);
    }

    /**
    * @author: Rexie Aaron David
    * @date: October 2023
    * @description: This method handles all on Before Update
    * functionalities of the Case
    */ 
    public static void onBeforeUpdate(List<Member_Benefit__c> newMemberBenefitList, Map<Id, Member_Benefit__c> oldMemberBenefitMap) {
        populateExpiryDate(newMemberBenefitList,oldMemberBenefitMap);
    }

    /**
    * @author: Rexie Aaron David
    * @date: October 2023
    * @description: This method handles all on After Update
    * functionalities of the Case
    */ 
    public static void onAfterUpdate(List<Member_Benefit__c> newMemberBenefitList, Map<Id, Member_Benefit__c> oldMemberBenefitMap) {
        processBlackhawkIntegration(newMemberBenefitList,oldMemberBenefitMap);
    }

    private static void populateUUId(List<Member_Benefit__c> newMemberBenefitList){

        for(Member_Benefit__c memberBenefit : newMemberBenefitList){
            if(memberBenefit.Member_Benefit_UUID__c == NULL)  memberBenefit.Member_Benefit_UUID__c = MembershipLoyaltyController.getUUID();
        }

    }

    private static void processBlackhawkIntegration(List<Member_Benefit__c> newMemberBenefitList, Map<Id, Member_Benefit__c> oldMemberBenefitMap) {

        try{
            List<Member_Benefit__c> validMemberBenefitRecords = getValidMemberBenefitRecords(newMemberBenefitList,oldMemberBenefitMap);
            if(validMemberBenefitRecords.size() > 0) Database.executeBatch(new BlackhawkAPIBatch('submit',validMemberBenefitRecords),10);
        }
        catch(Exception e){
            System.debug('Error in MemberBenefitTriggerHandler >>> processBlackhawkIntegration >>> ' +' Line Number: '+e.getLineNumber() + ' - ' +e.getMessage());
        }
        
    }

    private static List<Member_Benefit__c> getValidMemberBenefitRecords(List<Member_Benefit__c> newMemberBenefitList, Map<Id, Member_Benefit__c> oldMemberBenefitMap) {
        
        List<Member_Benefit__c> validMemberBenefitRecords = new List<Member_Benefit__c>();

        for(Member_Benefit__c memberBenefit : newMemberBenefitList){
            if(memberBenefit.Status__c != oldMemberBenefitMap.get(memberBenefit.Id).Status__c){
                if(oldMemberBenefitMap.get(memberBenefit.Id).Status__c == APPROVEDAWAITINGACTIVATION && memberBenefit.Status__c == APPROVEDGIFTCARDPLATFORMPENDING){
                    validMemberBenefitRecords.add(memberBenefit);
                }
            }
        }

        return validMemberBenefitRecords;

    }

    private static void populateExpiryDate(List<Member_Benefit__c> newMemberBenefitList, Map<Id, Member_Benefit__c> oldMemberBenefitMap) {

        for(Member_Benefit__c memberBenefit : newMemberBenefitList){
            if(memberBenefit.Expiry_Date__c == NULL && memberBenefit.Status__c == APPROVEDGIFTCARDPLATFORMSUCCESS && oldMemberBenefitMap.get(memberBenefit.Id).Status__c != memberBenefit.Status__c){
                memberBenefit.Expiry_Date__c = System.today().addMonths(6);
            }
            if(memberBenefit.Status__c == APPROVEDACTIVATED && oldMemberBenefitMap.get(memberBenefit.Id).Status__c == APPROVEDAWAITINGACTIVATION){
                memberBenefit.Status__c = APPROVEDGIFTCARDPLATFORMPENDING;
            }
            if(memberBenefit.Gift_Card_Issued__c == TRUE && oldMemberBenefitMap.get(memberBenefit.Id).Gift_Card_Issued__c == FALSE){
                memberBenefit.Status__c = APPROVEDGIFTCARDISSUED;
            }
            
        }
        
    }

}