/*
 * Name: Batch_MergeMarketingPreferences
 * Description: Merged Duplicate Marketing Preferences per Account
 */
global class Batch_MergeMarketingPreferences implements Database.Batchable<AggregateResult>, Database.Stateful {

    Integer i = 0;
    String query =  'SELECT COUNT(Id), Person_Account__c, MAX(Person_Account__r.CreatedDate), MIN(CreatedBy.Name) FROM Marketing_Preference__c GROUP BY Person_Account__c';
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        // String query = 'SELECT COUNT(Id) cnt, AccountId FROM Contact GROUP BY AccountId';
        return new AggregateResultIterable(query);
    } 

    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        for(sObject sObj : scope) {
            AggregateResult ar = (AggregateResult)sObj;
            System.debug('>>>> COUNT : ' + ar.get('Person_Account__c'));
            i += 1;
        }
    }

    // The batch job finishes
    global void finish(Database.BatchableContext bc){
        AggregateResult [] results = Database.query(query);  
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch_MergeMarketingPreferences ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.' + '\n' + ' Number of Account with Multiple Marketing Preference '+i);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        if(results.size() > 0 && System.Label.runBatch == 'TRUE'){
            Batch_MergeMarketingPreferences batch = new Batch_MergeMarketingPreferences();
            Database.executebatch(batch, 200);
        }
    }
}