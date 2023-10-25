/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: Schedulable class for BlackhawkAPI
*/ 
global class BlackhawkAPISchedule implements Schedulable {

    global void execute(SchedulableContext ctx) {

        MembershipLoyaltyController.WithoutShare membershipLoyaltyCtrl = new MembershipLoyaltyController.WithoutShare();
        List<Member_Benefit__c> memberBenefitToResubmitList = membershipLoyaltyCtrl.getMemberBenefitToResubmit();
        System.debug('memberBenefitToResubmitList size >>> '+memberBenefitToResubmitList.size());
        if(memberBenefitToResubmitList.size() > 0){
            Database.executeBatch(new BlackhawkAPIBatch('retry',memberBenefitToResubmitList),10);
        }
        else{
            System.debug('No Member Benefit to Re Submit '+memberBenefitToResubmitList.size());
        }

    }   
}