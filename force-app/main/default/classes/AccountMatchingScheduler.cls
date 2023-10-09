public class AccountMatchingScheduler implements Schedulable {
    
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
           
      String soql ='SELECT ID FROM Account WHERE ParentContact__c = Null AND isPersonAccount = true';
        
      AccountMatchingScheduleBatch batch = new AccountMatchingScheduleBatch(soql);
      Database.executebatch(batch, 1);
    }
}