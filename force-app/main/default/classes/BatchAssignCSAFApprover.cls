/**
 * @author:                         Ericka Jan Cajucom
 * @date:                           2021-03-25
 * @description:                    Batch Apex to Send Email Reminder to
 *                                  CSAF(Catalogue Submission) Approver
 *                                  if not approved within 3 days
 */
global class BatchAssignCSAFApprover implements Database.Batchable<sObject> {
    /**
     * Collect records to pass to the interface method execute
     *
     * @param BC - contains the batch job ID
     * @return  List of Pending ProcessInstance
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> csafIds = new Set<Id>();
        List<Catalogue_Submission__c> csafLst = 
            [SELECT Id,
                    Stage__c,
                    Status__c,
                    Initial_Proposal_Approved__c,
                    IsApproved__c
             FROM Catalogue_Submission__c
             WHERE (Initial_Proposal_Approved__c = false 
                        AND Stage__c = 'Initial Proposal'
                        AND Status__c = 'Submitted')
                    OR (Initial_Proposal_Approved__c = true
                        AND IsApproved__c = false
                        AND Stage__c = 'Accepted Proposal'
                        AND Status__c = 'Submitted')
                    OR (IsApproved__c = true
                        AND Status__c = 'Approved - Final Proposal'
                        AND Date_of_Approval__c != null
                        AND SAP_Status__c = null)
                    ];
        for (Catalogue_Submission__c csaf : csafLst) {
            csafIds.add(csaf.Id);
        }
        String query = ''
            + 'SELECT Id, '
            + '       TargetObjectId, '
            + '       Status, '
            + '       (SELECT Id, '
            + '               ActorId, '
            + '               Actor.Email, '
            + '               StepStatus, '
            + '               Comments, '
            + '               ProcessInstanceId '
            + '         FROM StepsAndWorkitems)'
            + '       FROM ProcessInstance '
            + '       WHERE TargetObjectId IN :csafIds'
            + '       AND Status = \'Pending\'';
        return Database.getQueryLocator(query);
        
    }
    
    /**
     * Send email to current CSAF Approver if approval is due
     *
     * @param BC - contains the batch job ID
     * @param approvalInstanceLst - List of pending approvalProcess
     *                              of un-approved Catalogue Submissions
     */
    global void execute(Database.BatchableContext BC, List<ProcessInstance> approvalInstanceLst) {
        Map<Id, String> emailMap = new Map<Id, String>();
        for (ProcessInstance pi : approvalInstanceLst) {
            for(ProcessInstanceHistory str : pi.StepsAndWorkitems) {
                if(str.Actor.Email != null && str.StepStatus == 'Pending') {
                    emailMap.put(pi.TargetObjectId, str.Actor.Email);
                }
            }
        }
        
        List<Catalogue_Submission__c> csafs = [SELECT Id, 
                                                      Name,
                                                      Catalogue_Name__c,
                                                      Owner.Name,
                                                      Account_Name__c,
                                                      Stage__c,
                                                      Advertising_Start_Date__c,
                                                      Advertising_End_Date__c,
                                                      Next_Approval_Reminder__c
                                                    FROM Catalogue_Submission__c
                                                    WHERE Id IN: emailMap.keySet()];
        List <Messaging.SingleEmailMessage> emailsToSend = new List <Messaging.SingleEmailMessage>();
        EmailTemplate reminderEmailTemplate = [SELECT Id,
                                                      Body,
                                                      Subject
                                                FROM EmailTemplate 
                                                WHERE DeveloperName = 'Approval_Notification'];
        
        for (Catalogue_Submission__c cs : csafs) {
            if (cs.Next_Approval_Reminder__c != null && cs.Next_Approval_Reminder__c == System.today()) {
                String emailSubject = reminderEmailTemplate.Subject.replace('{!Catalogue_Submission__c.Name}', cs.Name);
                String emailBody = reminderEmailTemplate.Body;
                emailbody = emailBody.replace('{!Catalogue_Submission__c.OwnerFullName}', cs.Owner.Name);
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Name}', cs.Name);
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Account_Name__c}', cs.Account_Name__c);
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Catalogue_Name__c}', cs.Catalogue_Name__c);
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Stage__c}', cs.Stage__c);
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Advertising_Start_Date__c}',
                        String.valueOf(cs.Advertising_Start_Date__c));
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Advertising_End_Date__c}',
                        String.valueOf(cs.Advertising_End_Date__c));
                emailbody = emailBody.replace('{!Catalogue_Submission__c.Link}', 
                        URL.getSalesforceBaseUrl().toExternalForm() + '/' + cs.Id);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setWhatId(cs.Id);
                email.setToAddresses(new String[] {emailMap.get(cs.Id)});
                email.setSubject('REMINDER: ' + emailSubject); 
                email.setPlainTextBody(emailbody);
                emailsToSend.add(email);
            }
        }
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    /**
     * Execute post-processing operations after all batches are processed
     *
     * @param BC - contains the batch job ID
     */
    global void finish(Database.BatchableContext BC) { }
}