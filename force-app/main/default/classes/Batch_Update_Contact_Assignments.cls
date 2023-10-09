global class Batch_Update_Contact_Assignments implements Database.Batchable<SObject>, Database.Stateful{
    
    Double failedUpdates{get; set;}
    
    global Batch_Update_Contact_Assignments(){
        failedUpdates = 0;
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([SELECT c.Id, c.OwnerId, c.Account.ID, c.BCI_Contact_ID__c FROM Contact c where c.BCI_Contact_ID__c != null]);
        //return Database.getQueryLocator([SELECT a.Id, a.OwnerId, a.BillingPostalCode, a.AccountSource From Account a where AccountSource = 'BCI Data' AND a.BillingPostalCode != null AND a.BillingPostalCode != '0']);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope){
        List<Contact> contacts = (List<Contact>)scope;
        

        
        List<Account> accounts = [ Select  a.Id, a.OwnerID From Account a ];
        
        Map<String, String> accounts_map = new Map<String, String>();
        for (Account act:accounts){
            accounts_map.put( String.valueOf(act.id), String.valueOf(act.OwnerID) );    
        }
        
        for(Integer i = 0; i < contacts.size(); i++){
            if(accounts_map.get(contacts[i].AccountID) != null){
                contacts[i].OwnerId = accounts_map.get(contacts[i].Account.ID);
            }
            //else{
            //  contacts[i].OwnerId = '00590000000qf8u';
            //}
        }
        
        
        List<Database.SaveResult> dsrs = Database.update(contacts, false);
        
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
             + 'Batch_UpdateContactAssignments '
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