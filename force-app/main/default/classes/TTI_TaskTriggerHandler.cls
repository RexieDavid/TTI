/**
    * @author: Shivam Singh
    * @date: December 2017
 */

public without sharing class TTI_TaskTriggerHandler {
    Public Static Boolean stopRecusion=false;
    
    public void runTrigger(){
        if(Trigger.isInsert && Trigger.isbefore){
            beforeInsert((list<Task>) trigger.New);
        }
        if(Trigger.isInsert && Trigger.isafter){
            sendEmailAndMergeToActivity((list<Task>) trigger.New);
        }
        if(trigger.isUpdate && Trigger.isafter){
            updateNumberOfinteractions ((list<Task>) trigger.New, (map<Id, Task>)trigger.oldMap);
        }
        if(trigger.isDelete && Trigger.isafter){
        }
        if(Trigger.isInsert && Trigger.isafter){
            updateNumberOfinteractions ((list<Task>) trigger.New, (map<Id, Task>)trigger.oldMap);
        }
        
    }
    
    public void beforeInsert(list<Task> triggerNew){
        taskFieldsMapping( triggerNew);
    }
    
    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Mapping the task field from respective case.
    */
    
    public  void taskFieldsMapping(list<Task> triggerNew){
        set<Id> caseId = new set<ID>();
        for(Task task: triggerNew){
            caseId.add(task.WhatId);
        }
        map<Id, Case> caseObjMap = new map<Id, Case>([SELECT Id,CaseNumber,TTI_Customer_Contact__r.Name,TTI_Customer_Account__r.Name,Retailer_Account__r.Name,Product_Name__r.Name,Account.Name,Contact.Name,OwnerId,RecordTypeId,Subject,Diagnosed_User__c,AccountId,Brand__c,Claim_Type__c,ContactId,Manual_Approval_Reason__c,Manual_Invoice_Approval_Reason__c,Product_Name__c,Retailer_Account__c,Service_Request_Milestone__c FROM Case where id IN: caseId]);
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Id RecordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        List<Group> queueId = [select id,Name,type from group where type='Queue' AND Name='Warranty Service Request Approval'];
        
        for(Task task: triggerNew){
            if(task.WhatId != null && caseObjMap.containsKey(task.WhatId)){
                case objcase = caseObjMap.get(task.WhatId);
                if(RecordTypeIdCase == objcase.RecordTypeId){
                    task.TTI_Service_Claim__c = objcase.CaseNumber;
                    task.RecordTypeId = RecordTypeIdTask; 
                    task.TTI_Brand__c = objcase.Brand__c;
                    task.ActivityDate = Date.valueof((system.now()).addHours(24));
                    task.Claim_Type__c = objcase.Claim_Type__c;
                    task.TTI_Product__c = objcase.Product_Name__r.Name;
                    task.TTI_Retailer__c = objcase.Retailer_Account__r.Name;
                    task.TTI_Customer_Account__c = objcase.TTI_Customer_Account__r.Name;
                    task.TTI_Customer_Contact__c = objcase.TTI_Customer_Contact__r.Name;
                    task.TTI_Milestone__c = objcase.Service_Request_Milestone__c;
                    if(objcase.Service_Request_Milestone__c == 'Awaiting Approval'){
                        task.TTI_Non_Approval_Reason__c = objcase.Manual_Approval_Reason__c;
                    }
                    else if(objcase.Service_Request_Milestone__c == 'Invoice Awaiting Approval'){
                        task.TTI_Non_Approval_Reason__c = objcase.Manual_Invoice_Approval_Reason__c;
                    }
                    if(task.Subject == 'Service Request Approval More Information Required' || task.Subject == 'Service Request Invoice Approval More Information Required'){
                        if(objcase.Diagnosed_User__c !=null){
                           task.OwnerId = objcase.Diagnosed_User__c; 
                        }
                        task.type = 'Request for more Information';
                        if(queueId.size() > 0){
                            caseObjMap.get(task.WhatId).OwnerId = queueId[0].Id;
                        }
                        caseObjMap.get(task.WhatId).Status = 'In Progress - Pending with External';
                    }
                }   
            }
        }
        
        if(caseObjMap.size() > 0){
            update caseObjMap.values();
        }
    }
    
    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Sending email to task owner and mergeing to activity history.
    */
    
    Public void sendEmailAndMergeToActivity(list<Task> triggerNew){
        if(!stopRecusion){
            stopRecusion = true;
            set<Id> caseId = new set<ID>();
            set<Id> taskOwnerId = new set<ID>();
            for(Task task: triggerNew){
                caseId.add(task.WhatId);
                taskOwnerId.add(task.OwnerId);
            }
            TTI_Template__c template = TTI_Template__c.getValues('TTI_EmailsentToTheServiceAgentTemplate');
            list<EmailTemplate> templateAGE = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name =: template.Name];
            String emailBody = '';
            String emailSubject = '';
            if(templateAGE.size() > 0){
                if(templateAGE[0].HtmlValue != null && templateAGE[0].HtmlValue != ''){
                    emailBody = templateAGE[0].HtmlValue; 
                }
                if(templateAGE[0].Subject != null && templateAGE[0].Subject != ''){
                    emailSubject = templateAGE[0].Subject; 
                }
            }
            map<Id, User> contactIdOfUser = new  map<Id, User>([SELECT Id, ContactId, Contact.FirstName FROM USer WHERE Id IN: taskOwnerId]);
            system.debug(contactIdOfUser+'contactIdOfUser');
            List<Messaging.SingleEmailMessage> emailToSent = new List<Messaging.SingleEmailMessage>();
            Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            map<Id, Case> caseObjMap = new map<Id, Case>([SELECT Id,TTI_CaseFromEmailId__c,TTI_Brand_Logo_URL__c,Brand__c,CaseNumber,RecordTypeId FROM Case WHERE Id IN: caseId]);
            for(Task task: triggerNew){
                if(task.WhatId != null && caseObjMap.containsKey(task.WhatId) && contactIdOfUser.containsKey(task.OwnerId) && contactIdOfUser.get(task.OwnerId).contactid != null){
                    case objcase = caseObjMap.get(task.WhatId);
                    if(RecordTypeIdCase == objcase.RecordTypeId && (task.Subject == 'Service Request Approval More Information Required' || task.Subject == 'Service Request Invoice Approval More Information Required') && task.TTI_Brand__c != null && task.TTI_Brand__c != ''){
                        Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
                        emailTobeSent.setSaveAsActivity(true);
                        string emailSubjectReplaceCaseNo ='';
                        if(emailSubject !=null && emailSubject !=''){
                            emailSubjectReplaceCaseNo = emailSubject.replace('caseCaseNumber', objcase.CaseNumber); 
                            //emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('brandName', objcase.Brand__c);
                        }
                        emailTobeSent.setSubject(emailSubjectReplaceCaseNo);
                        
                        string emailBodyReplaceSubject ='';
                        if(emailBody !='' && emailBody !=null){
                            emailBodyReplaceSubject = emailBody.replace('TaskSubject', task.Subject);
                            string description = '';
                            if(task.Description != null && task.Description != ''){
                                emailBodyReplaceSubject = emailBodyReplaceSubject.replace('TaskDescription', task.Description);
                            }
                            else {
                                emailBodyReplaceSubject = emailBodyReplaceSubject.replace('TaskDescription', description);
                            }
                            if((contactIdOfUser.get(task.OwnerId)).Contact.FirstName !=null && (contactIdOfUser.get(task.OwnerId)).Contact.FirstName !=''){
                                emailBodyReplaceSubject = emailBodyReplaceSubject.replace('taskContactName', (contactIdOfUser.get(task.OwnerId)).Contact.FirstName);
                            }
                            else{
                                emailBodyReplaceSubject = emailBodyReplaceSubject.replace('taskContactName', '');
                            }
                            
                            emailBodyReplaceSubject = emailBodyReplaceSubject.replace('brandName', objcase.Brand__c); 
                            emailBodyReplaceSubject = emailBodyReplaceSubject.replace('caseCaseNumber', objcase.CaseNumber);
                            if(objcase.TTI_Brand_Logo_URL__c != null){
                               emailBodyReplaceSubject = emailBodyReplaceSubject.replace('Brand_LogoURL', objcase.TTI_Brand_Logo_URL__c); 
                            }   
                        }
                        emailTobeSent.setHtmlBody(emailBodyReplaceSubject);
                        emailTobeSent.setTargetObjectId((contactIdOfUser.get(task.OwnerId)).ContactId);
                        emailTobeSent.setWhatId(task.WhatId);
                        emailTobeSent.setOrgWideEmailAddressId(objcase.TTI_CaseFromEmailId__c);
                        emailToSent.add(emailTobeSent);
                    }
                }
            }
            if(emailToSent.size() > 0){
                Messaging.SendEmailResult [] r1 = Messaging.sendEmail(emailToSent);  
            }  
        }
    }
    
    /**
    * @author: Shivam Singh
    * @date: December 2017
    * @description: Updateing NumberOfinteractions when task is completed.
    */
    
    Public void updateNumberOfinteractions(list<Task> triggerNew, map<Id, Task> triggeroldMap){
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        map<Id, Case> caseObjMap = new map<Id, Case>();
        if(trigger.isUpdate || trigger.isinsert ){
            set<Id> idOfcase = new set<ID>();
            for(Task task: triggerNew){
                idOfcase.add(task.WhatId);
            }
            List<Case> caseOfNewTask = new List<Case>();
            if(idOfcase.size()>0){
               caseOfNewTask = [SELECT Id, OwnerId,RecordTypeId FROM Case where id IN: idOfcase];
            }
            if(caseOfNewTask.size() > 0){
                for(Case theCase : caseOfNewTask){
                    caseObjMap.put(theCase.Id, theCase); 
                } 
            }
        }
        
        set<Id> caseId = new set<Id>();
        if(trigger.isUpdate){
            for( Task taskObj : triggerNew){
                if(taskObj.WhatId != null && caseObjMap.containsKey(taskObj.WhatId) && RecordTypeIdCase == (caseObjMap.get(taskObj.WhatId)).RecordTypeId && (taskObj.WhatId).getSObjectType().getDescribe().getName() =='Case'){
                    if(triggeroldMap.get(taskObj.Id).Status !='Completed' && taskObj.Status =='Completed' && (taskObj.Subject =='Service Request Approval More Information Required' || taskObj.Subject =='Service Request Invoice Approval More Information Required')){ 
                        caseId.add(taskObj.WhatId); 
                    }   
                }  
            }
        }
        
        if(trigger.isinsert){
            for( Task taskObj : triggerNew){
                if(taskObj.WhatId != null && caseObjMap.containsKey(taskObj.WhatId) && RecordTypeIdCase == (caseObjMap.get(taskObj.WhatId)).RecordTypeId && (taskObj.Subject =='Service Request Approval More Information Required' || taskObj.Subject =='Service Request Invoice Approval More Information Required') && (taskObj.WhatId).getSObjectType().getDescribe().getName() =='Case'){
                    caseId.add(taskObj.WhatId);
                }
            }
        }
        list<Case> caseObj = new list<Case>();
        if(caseId.size()>0){
            caseObj =[SELECT id, Number_of_Interactions__c FROM Case WHERE id IN :caseId]; 
        }
        
        list<Case> caseObjToUpdateInteractions = new list<Case>();
        if(caseObj.size() > 0){
            for(Case objCase : caseObj){
                objCase.Number_of_Interactions__c = objCase.Number_of_Interactions__c + 1; 
                caseObjToUpdateInteractions.add(objCase);
            }
        }
        if(caseObjToUpdateInteractions.size() > 0){
            update caseObjToUpdateInteractions;
        }
    }
    
}