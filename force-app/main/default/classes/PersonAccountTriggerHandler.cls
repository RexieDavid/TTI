public class PersonAccountTriggerHandler {
    
	public static void onAfterInsert(List<Account> newRecords, Map<ID, Account> newMap) { 
        set<Id> guestProfileIdSet = new Set<Id>();
        List<Profile> guestProfiles = [Select Id, NAME, UserType  from Profile Where UserType  =: 'Guest'];
        for(Profile p : guestProfiles){
            if(p.Id != null ){
                guestProfileIdSet.add(p.Id);
            }
        }
        
        //Id userId = UserInfo.getUserId();
		for (Account a : newRecords){
            if(a.ParentContact__c == null  && a.IsPersonAccount== True && !guestProfileIdSet.contains(UserInfo.getUserId())){
                //process is not bulkified due to complex matching SOQL. Scheduled job will pick up accounts with no parent.
                List<Account> processAccounts = new List<Account>();
                processAccounts.add(a);
            	
                RegistrationMatching.updatePersonAccount(processAccounts);
                break;
                
            }
        }    
        
    }// End onAfterInsert Method
    
    /*
    public static void updatePersonAccount(List<Account> newAccList){
       	List<Account> accList= new List<Account>();
       	List<Parent_Contact__c> accParentContact = new List<Parent_Contact__c>();
       //accParentContact = RegistrationMatching.getParentContact();
       	Set<Id> accIdset = new set<id>();

       	for(Account acc : newAccList){
           
       		accIdset.add(acc.PersonEmail);
           
       	}
		
        
		//get person account record type
		//RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1]; 
       	//get newly inserted Person accounts
       	List<Account> aList =[SELECT ID,RecordTypeId, PersonEmail, CreatedDate, Brand__pc, PersonHomePhone,
                             PersonMobilePhone,FirstName, LastName, Parent_Contact__pc 
                             FROM Account WHERE PersonEmail In: accIdset];
       	system.debug('aList: '+ aList);
   		
		       
      //Update parent contact of person Account
       for(Account a : newAccList){
        
           	RegistrationMatching.RegistrationMatchResult matchresult = RegistrationMatching.getPersonAccounts(a.PersonEmail, a.FirstName, a.LastName, a.PersonMobilePhone, a.PersonHomePhone, null, a.RecordTypeId);
           system.debug('matchresult: ' + matchresult);
           if(matchresult.parentAccountMatchID == null ){
               a.Parent_Contact__pc = RegistrationHelper.createParentContact(a.FirstName, a.LastName).Id;
           } Else{
               a.Parent_Contact__pc = matchresult.parentAccountMatchID;
           }
           
           
           accList.add(a);
       }
       update accList;
    }
    */
}