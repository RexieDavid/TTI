public without sharing class TTI_SaveAndCompleteButtonOnTaskClass {
    @AuraEnabled
    public static String updateStatusOfTask(String recordId){
        Task taskObj = new Task(Id=recordId, Status='Completed');
        list<Task> Idcase = [SELECT Id, WhatId FROM Task WHERE Id=:recordId];
        Case caseobj = new Case();
        if(Idcase.size() >0){
            caseobj.id=Idcase[0].WhatId;
            caseobj.Status='Response Received';
        }
        
        try{
            update taskObj;
            update caseobj;
        }catch(Exception e){
            return e.getMessage();
        }
        return null;
    }
}