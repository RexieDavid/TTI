global class Batch_UpdateProjectAssignments implements Database.Batchable<SObject>, Database.Stateful{
    
    Double failedUpdates{get; set;}
    
    global Batch_UpdateProjectAssignments(){
        failedUpdates = 0;
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([Select p.Postcode__c, p.State__c,p.Project_Category__c, p.Id, p.OwnerId, p.Lock_Record_Owner__c From Project__c p where p.Postcode__c != '0'  AND p.Postcode__c != null AND p.Lock_Record_Owner__c != true]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope){
       List<Project__c> projs = (List<Project__c>)scope;
        
        RecordType rt = [Select r.Name, r.Id From RecordType r WHERE r.Name = 'Industrial MOG Region'];
        List<Region__c> regions = [Select r.Region_State__c, r.Region_Name__c, r.RecordTypeId, r.Id, r.Assigned_to__c From Region__c r WHERE r.RecordTypeId = :rt.Id];      
        Map<String, String> region_map = new Map<String, String>();     
        for(Region__c r:regions){
            region_map.put( String.valueOf(r.Region_State__c), String.valueOf(r.Assigned_to__c) );
        }

        
        List<String> pcs = new List<String>();
       
        for (Project__c p:projs){
            pcs.add(String.valueOf(p.Postcode__c));         
        }
        
        List<Postcode__c> pcodes = [ Select  p.Id, p.Postcode__c, p.JSS_Region__r.Assigned_to__c From Postcode__c p WHERE p.Postcode__c IN :pcs ORDER BY p.Postcode__c];
        
        Map<String, String> postcode_map = new Map<String, String>();
        
        for (Postcode__c pc:pcodes){
            postcode_map.put( String.valueOf(pc.Postcode__c), String.valueOf(pc.JSS_Region__r.Assigned_to__c) );    
        }
        
        for(Integer i = 0; i < projs.size(); i++){          
            if( projs[i].Project_Category__c == 'Mining' || projs[i].Project_Category__c == 'Oil and Gas' ){
                projs[i].OwnerId = region_map.get( projs[i].State__c);
            }else{
                if(postcode_map.get(projs[i].Postcode__c) != null){
                    projs[i].OwnerId = postcode_map.get(projs[i].Postcode__c);
                }
            }
            
            //else{
            //  projs[i].OwnerId = '00590000000qf8u';
            //}
        }
        
        
        List<Database.SaveResult> dsrs = Database.update(projs, false);
        
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
             + 'Batch_UpdateProjectAssignments '
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