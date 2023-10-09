global class SampleBatch implements Database.Batchable<sObject> {

  private String query;
  
  global SampleBatch (String soql){
    query = soql;
  }
  
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    //String query = 'SELECT Id, Name FROM Account';
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
    System.debug('>>>> execute ' + scope.size());

  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}