global class AssignReferralCodeToUserScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        List<String> profileList = new List<String> {'~Customer Community AEG', '~Customer Community AEG NZ'};
                
        String profileNameInSOQL='';
        for(String profile: profileList){
            profileNameInSOQL += 'Profile.Name =\'' +  profile + '\' or ';
        }
        profileNameInSOQL = profileNameInSOQL.substringBeforeLast(' or ');
        String soql = 'SELECT Id,name,Referral_Code__c FROM User WHERE ('+profileNameInSOQL+') and Referral_Code__c =\'\'' + (Test.isRunningTest()?' LIMIT 1':'');
        AssignReferralCodeToUserBatch batch = new AssignReferralCodeToUserBatch(soql);
        Database.executebatch(batch, 200);
    }
    
}