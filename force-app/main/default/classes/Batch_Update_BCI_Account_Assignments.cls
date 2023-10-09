global class Batch_Update_BCI_Account_Assignments implements Database.Batchable<SObject>, Database.Stateful{
    
    Double failedUpdates{get; set;}
    
    global Batch_Update_BCI_Account_Assignments(){
        failedUpdates = 0;
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([SELECT a.Id, a.OwnerId, a.BillingPostalCode, a.AccountSource, a.Lock_Record_Owner__c From Account a where AccountSource = 'BCI Data' AND a.BillingPostalCode != null AND a.BillingPostalCode != '0' AND a.Lock_Record_Owner__c != true]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope){
        List<Account> accts = (List<Account>)scope;

        List<String> pcs = new List<String>();

        for (Account a:accts){
            pcs.add(String.valueOf(a.BillingPostalCode));      
        }
    
        List<Postcode__c> pcodes = [ Select  p.Id, p.Postcode__c, p.JSS_Region__r.Assigned_to__c From Postcode__c p WHERE p.Postcode__c IN :pcs ORDER BY p.Postcode__c];
     
        Map<String, String> postcode_map = new Map<String, String>();
        for (Postcode__c pc:pcodes){
            postcode_map.put( String.valueOf(pc.Postcode__c), String.valueOf(pc.JSS_Region__r.Assigned_to__c) );  
        }

        for(Integer i = 0; i < accts.size(); i++){
            if(postcode_map.get(accts[i].BillingPostalCode) != null){
                accts[i].OwnerId = postcode_map.get(accts[i].BillingPostalCode);
            }
        }


        List<Database.SaveResult> dsrs = Database.update(accts, false);

        for(Database.SaveResult dsr : dsrs){
            if(!dsr.isSuccess()){
                failedUpdates++;
            }

        } 
    }
    
    global void finish(Database.BatchableContext ctx){
    
        AsyncApexJob a = [SELECT id, ApexClassId, 
                       JobItemsProcessed, TotalJobItems, 
                       NumberOfErrors, CreatedBy.Email 
                       FROM AsyncApexJob 
                       WHERE id = :ctx.getJobId()];
        
        String emailMessage ='Your batch job '
             + 'Batch_UpdateAccountAssignments '
             + 'has finished.  It executed ' 
             + a.totalJobItems 
             + ' batches.  Of which, ' + a.jobitemsprocessed 
             + ' processed without any exceptions thrown and ' 
             + a.numberOfErrors +
             ' batches threw unhandled exceptions.'
             + '  Of the batches that executed without error, ' 
             + failedUpdates 
             + ' records were not updated successfully.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.createdBy.email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Batch Job Summary');
        mail.setSubject('Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}