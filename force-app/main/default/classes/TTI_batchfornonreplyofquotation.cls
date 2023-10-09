global class TTI_batchfornonreplyofquotation implements Database.Batchable<sObject>{

    // Start Method Query all the Case daigonised issues
    global Database.QueryLocator start(Database.BatchableContext BC){
     return Database.getQueryLocator([SELECT Id, CaseNumber, Diagnosed_Date__c, Diagnosed_User__c , Brand__c, TTI_Brand_Logo_URL__c, TTI_Brand_Service_Phone__c, TTI_Quote_to_Retailer__c,
                 Origin , Retailer_Account__c, SuppliedEmail,  TTI_Quote_to_Customer__c, TTI_Is_notification_date__c, Contact.Name,TTI_Awaiting_Approval_Datetime__c,
                Product_Name__c, Product_Name__r.Name,Asset.Name, TTI_CaseFromEmailId__c, Claim_Type__c, Service_Request_Milestone__c, Retailer_Account__r.Name FROM Case WHERE 
                Service_Request_Milestone__c = 'Awaiting Approval' AND TTI_Is_notification_date__c = True]);
    }
    
    
    // Changes the status of record to deactivated if end date is more than current date
   global void execute(Database.BatchableContext BC, List<Case> lstCase){
    
    // Variables Defined
    // Logic to be Executed batch wise 
    // Accessing Custom setting value
    Set<String> SetofOWE= new Set<String>();
    Map<String,OrgWideEmailAddress> mapIdwithOWEA = new Map<String,OrgWideEmailAddress>();
    Map<String,Attachment> mapTaskwithAttac = new Map<String,Attachment>();
    
    
    TTI_Non_Warranty_Auto_Reject_Days__c NWARDCS = TTI_Non_Warranty_Auto_Reject_Days__c.getValues('Non Warranty Auto Reject Days');
    Integer Totaldays =  Integer.valueof(NWARDCS.TTI_Non_Warranty_Auto_Reject_Days__c);
    
    Set<String> setOfId = new Set<String>();
    for(Case objCase:lstCase){
        setOfId.add(objCase.id);
        if(objCase.TTI_CaseFromEmailId__c != '')
                SetofOWE.add(objCase.TTI_CaseFromEmailId__c);
    }
    
    if(SetofOWE.size() >0)
    {
        List<OrgWideEmailAddress> lstOrgWiseEmail = [SELECT ID, DisplayName,Address FROM OrgWideEmailAddress WHERE Id IN :SetofOWE];
    
        for(OrgWideEmailAddress objOWEmail:lstOrgWiseEmail){
            mapIdwithOWEA.put(objOWEmail.id,objOWEmail);
            System.debug('++++++++InsideIF MapOWD======');
        }
    }
    
    Map<String,List<Attachment>> mapParIdWithAttach = new Map<String,List<Attachment>>();
    List<Attachment> lstAttachment;
    if(setOfId != null && setOfId.size() > 0)
    {
        lstAttachment = [SELECT id, Name, Body, ParentId FROM Attachment WHERE ParentId IN : setOfId AND Name LIKE '%_Quote%'  ORDER BY CreatedDate DESC];
        for(Attachment objAtt:lstAttachment){
            if(mapParIdWithAttach.get(objAtt.ParentId) == null){
                mapParIdWithAttach.put(objAtt.ParentId,new Attachment[] {objAtt});
            }
            else{
                List<Attachment> lstA = mapParIdWithAttach.get(objAtt.ParentId);
                lstA.add(objAtt);
                mapParIdWithAttach.put(objAtt.ParentId,lstA);
            }
        }
    }
    System.debug('lstCase.size()'+lstCase.size());
    System.debug('lstCase'+lstCase);
    List <Messaging.SingleEmailMessage> lstemail = new List <Messaging.SingleEmailMessage>();
    List<EmailMessage> lstEmailMess = new List<EmailMessage>();
    // List Email template
    List<EmailTemplate> lstOfTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name ='TTI Remainder for quote approval'];
    
    if(lstCase != null && lstOfTemplate != null && !lstOfTemplate.isEmpty() && !lstCase.isEmpty())
    {
        for(Case objCase:lstCase)
        {
            Messaging.SingleEmailMessage objmSEM = new Messaging.SingleEmailMessage();
            List<String> toAddress = new List<String>();
            List<String> ccAddress = new List<String>();
            List<String> bccAddress = new List<String>();
            String emailSubjectReplaceCaseNo;
            
            if(mapParIdWithAttach != null && mapParIdWithAttach.get(objCase.id) != null )
            {
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(mapParIdWithAttach.get(objCase.id)[0].Name);
                efa.setBody(mapParIdWithAttach.get(objCase.id)[0].Body);
                fileAttachments.add(efa);
                objmSEM.setFileAttachments(fileAttachments);
            }
            String emailBody = '';
            String emailSubject = '';
            if(lstOfTemplate.size() > 0){
                if(lstOfTemplate[0].HtmlValue != null && lstOfTemplate[0].HtmlValue != ''){
                    emailBody = lstOfTemplate[0].HtmlValue; 
                }
                if(lstOfTemplate[0].Subject != null && lstOfTemplate[0].Subject != ''){
                    emailSubject = lstOfTemplate[0].Subject; 
                    emailSubjectReplaceCaseNo = emailSubject.replace('Case_Number', objCase.CaseNumber);
                    if(objCase.Asset.Name != null && objCase.Asset.Name != ''){
                        emailSubjectReplaceCaseNo = emailSubjectReplaceCaseNo.replace('Product_Name', objCase.Asset.Name);
                    }
                    objmSEM.setSubject(emailSubjectReplaceCaseNo);
                }
                if(emailBody !=null && emailBody !=''){
                        emailBody = emailBody.replace('IMG_URL', objCase.TTI_Brand_Logo_URL__c);
                        if(objCase.TTI_Awaiting_Approval_Datetime__c != null ){
                            emailBody = emailBody.replace('daigonise_date', objCase.TTI_Awaiting_Approval_Datetime__c.format('dd-MM-yyyy'));
                        }
                        else{
                            emailBody = emailBody.replace('daigonise_date','');
                        }
                        
                        if(objCase.AssetId != null && objCase.Asset.Name != null && objCase.Asset.Name != ''){
                           emailBody = emailBody.replace('Product_Name', objCase.Asset.Name);
                        }
                        else{
                            emailBody = emailBody.replace('Product_Name','');
                        }
                        
                        if(objCase.CaseNumber != null && objCase.CaseNumber != ''){
                           emailBody = emailBody.replace('Case_Number', objCase.CaseNumber);
                        }
                        else{
                            emailBody = emailBody.replace('Case_Number','');
                        }
                        
                        if(objCase.Brand__c != null && objCase.Brand__c != ''){
                           emailBody = emailBody.replace('BRAND_NAME', objCase.Brand__c);
                        }
                        else{
                            emailBody = emailBody.replace('BRAND_NAME','');
                        }
                        Integer daysleft;
                        Date Todaydate = Date.today();
                        if(objCase.Diagnosed_Date__c != null ){
                            daysleft =   objCase.Diagnosed_Date__c.date().daysBetween(Date.today());
                        }
                         
                        if(Totaldays != null && daysleft  != null){
                           emailBody = emailBody.replace('X_DAYS',  String.valueOf(Totaldays - daysleft));
                        }
                        else{
                            emailBody = emailBody.replace('X_DAYS','');
                        }
                       
                    }
                if(objCase.SuppliedEmail != null && objCase.SuppliedEmail != '')    
                {
                    toAddress.add(objCase.SuppliedEmail);
                    objmSEM.setToAddresses(toAddress);
                    objmSEM.setHtmlBody(emailBody);
                    objmSEM.setOrgWideEmailAddressId(objCase.TTI_CaseFromEmailId__c);
                    lstemail.add(objmSEM);
                    
                    EmailMessage objEMesg = new EmailMessage();
                    objEMesg.RelatedToId = objCase.Id;
                    objEMesg.Subject = emailSubjectReplaceCaseNo;
                    objEMesg.Status = '3';
                    objEMesg.FromAddress = (mapIdwithOWEA.get(objCase.TTI_CaseFromEmailId__c).Address != null)?mapIdwithOWEA.get(objCase.TTI_CaseFromEmailId__c).Address:null;
                    objEMesg.FromName = (mapIdwithOWEA.get(objCase.TTI_CaseFromEmailId__c).DisplayName != null)?mapIdwithOWEA.get(objCase.TTI_CaseFromEmailId__c).DisplayName:null;
                    objEMesg.HtmlBody = emailBody;
                    objEMesg.MessageDate = system.now();
                    objEMesg.ToAddress = string.join(toAddress,',');
                    lstEmailMess.add(objEMesg);
                    
                    if(mapParIdWithAttach != null && mapParIdWithAttach.get(objCase.id) != null && mapParIdWithAttach.get(objCase.id).size()>0){
                        Attachment ObjAttach = new Attachment();
                        ObjAttach.Name = mapParIdWithAttach.get(objCase.id)[0].Name;
                        ObjAttach.Body = mapParIdWithAttach.get(objCase.id)[0].Body;
                        ObjAttach.IsPrivate = false;
                        mapTaskwithAttac.put(objCase.id,ObjAttach);
                    }
                        
                }
            }
            
        }
    }
     
    
    /*try
      {
          if(lstemail != null && lstemail.size() >0)
          {*/
            Messaging.SendEmail(lstemail); 
            if(lstEmailMess.size() >0)
            {
                insert lstEmailMess;
                List<Attachment> lstAtt= new List<Attachment>();
                for(EmailMessage objEM:lstEmailMess){
                    if(objEM.RelatedToId != null && mapTaskwithAttac != null && mapTaskwithAttac.get(objEM.RelatedToId) != null)
                    {
                        Attachment objA = mapTaskwithAttac.get(objEM.RelatedToId);
                        objA.ParentId = objEM.id;
                        lstAtt.add(objA);
                    }
                }
                if(lstAtt.size() > 0)
                    insert lstAtt;
            }   
            System.debug('lstemail'+lstemail); 
            System.debug('lstemail.size()'+lstemail.size()); 
        /*  }
      }
    catch(Exception e)
            {
                e.getMessage();
            }*/

 }  
global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
}