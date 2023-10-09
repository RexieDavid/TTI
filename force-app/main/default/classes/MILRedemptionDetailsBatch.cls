/**
* @author: Regine Paredes
* @date: June 2023
* @description: This batch handles population of the carrier code and consignment number on redemptions from SAP
*/

public class MILRedemptionDetailsBatch implements Database.Batchable<sObject> {

    private String query;
  
    public MILRedemptionDetailsBatch (String soql){
        query = soql;// select SAP_Order_Number__c
        //redemptions with null carrier number batch job
    }
  
  // The batch job starts
    public Database.Querylocator start(Database.BatchableContext bc){
   
        System.debug('>>>> start ' + query);
        return Database.getQuerylocator(query);
    } 
  
    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<Redemptions__c> scope){
        
       MILRedemptionDetailsHelper.updateRedemptions(scope);
        
    }
    
  
    // The batch job finishes
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }/**/
}