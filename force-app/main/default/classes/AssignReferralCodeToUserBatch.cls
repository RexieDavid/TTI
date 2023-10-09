global class AssignReferralCodeToUserBatch implements Database.Batchable<sObject> {
    private String query;
    
    global AssignReferralCodeToUserBatch (String soql){
        query = soql;
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator(query);
    } 
    
    global void execute(Database.BatchableContext bc, List<User> userList){
        for (User user: userList){
            user.Referral_Code__c = LightningSelfRegisterController.generateReferralCode(6);
        }
        update userList;
    } 
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    }
}