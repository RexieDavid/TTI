public class AccountMatchingScheduleBatch implements Database.Batchable<sObject> {

  
	private String query;
  
    public AccountMatchingScheduleBatch (String soql){
        query = soql;
    }
  
  // The batch job starts
    public Database.Querylocator start(Database.BatchableContext bc){
   
        System.debug('>>>> start ' + query);
        return Database.getQuerylocator(query);
    } 
  
    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<Account> scope){
        
       RegistrationMatching.updatePersonAccount(scope);
        
    }
    
  
    // The batch job finishes
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }/**/
}