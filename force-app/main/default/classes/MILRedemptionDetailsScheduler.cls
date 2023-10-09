public class MILRedemptionDetailsScheduler implements Schedulable {

    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
           
        String soql ='SELECT Id, SAP_Order_Number__c FROM Redemptions__c WHERE Carrier_Tracking_Number__c = null AND SAP_Order_Number__c != null';
            
        MILRedemptionDetailsBatch batch = new MILRedemptionDetailsBatch(soql);
        Database.executebatch(batch);
    }
}