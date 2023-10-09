global class Batch_UpdateJSSBudgetTotalsSchedule implements Schedulable {
 global void execute(SchedulableContext SC) { 
  
  Batch_UpdateJSSBudgetTotals job = new Batch_UpdateJSSBudgetTotals();
  Database.executeBatch(job);
  
 }
}