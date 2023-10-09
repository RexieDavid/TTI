/**
* @author Samuel Oberes
* @date 2018-11-15
*
* @description Queable apex for the bulk generation of Stocktake records and list items
*
* @history
* <Date>         <Author>       <Description>
* YYYY-MM-DD     -              -
*/
public class BulkGenerateStocktakeRecordsAsyncQ implements Queueable {

    private Integer year;
    private String quarter;

    public BulkGenerateStocktakeRecordsAsyncQ(String quarter, Integer year) {
        this.quarter = quarter;
        this.year = year;
    }

    public void execute(QueueableContext context) {

        Long d1;
        List<Stocktake__c> bulkStocktake = new List<Stocktake__c>();
        List<Stocktake_Items__c> bulkStocktakeItem = new List<Stocktake_Items__c>(); // user's new stocktake items
        List<Inventory__c> usrInventory = new List<Inventory__c>(); // users' inventory
        List<AggregateResult> bulkUniqueOwners = new List<AggregateResult>(); // unique user list from Active inventory
        List<Stocktake__c> bulkUpdateStocktake = new List<Stocktake__c>(); // deactivate Stocktake list
        Map<String, String> executionStatus = new Map<String, String>{
            'success' => 'false',
            'message' => '',
            'stackTrace' => '',
            'duration' => ''
        };

        d1 = Datetime.now().getTime();

        // If no records found for quarter, deactivate all active stocktake
        for (Stocktake__c st : [SELECT Name, Stocktake_Identity__c, Active__c FROM Stocktake__c WHERE Active__c =: true]) {
            st.Active__c = false;
            bulkUpdateStocktake.add(st);
        }

        try {
            update bulkUpdateStocktake;
        } catch (Exception e) {
            executionStatus.put('message', e.getMessage());
            executionStatus.put('stackTrace', e.getStackTraceString());
            executionStatus.put('duration', String.valueOf(getDuration(d1)));
            sendEmail(executionStatus);
            return;
        }
            
        // Generate new Stocktake
        // Get unique owners
        String active  = 'Active';
        String selectA = 'SELECT OwnerId, User_Account__r.TTI_SAP_Cust_No__c SAP ';
        String fromA   = 'FROM Inventory__c ';
        String whereA  = 'WHERE Status__c = :active AND IsDeleted = false ';
        String groupA  = 'GROUP BY Ownerid, User_Account__r.TTI_SAP_Cust_No__c';
        String queryA  = selectA + fromA + whereA + groupA;
        bulkUniqueOwners = Database.query(queryA);
        
        // Generate Stocktake for unique owners
        if (bulkUniqueOwners != null) {
            for (AggregateResult ar : bulkUniqueOwners) {
                Stocktake__c st = new Stocktake__c();
                st.OwnerId = String.valueOf(ar.get('OwnerId'));
                st.Stocktake_Identity__c = String.valueOf(ar.get('OwnerId')) + '-' + String.valueOf(ar.get('SAP')) + '-' + quarter + '-' + year;
                st.Active__c = true;
                st.Due_Date__c = date.today().addMonths(1);
                bulkStocktake.add(st);
            }

            try {
                insert bulkStocktake;
            } catch (Exception e) {
                executionStatus.put('message', e.getMessage());
                executionStatus.put('stackTrace', e.getStackTraceString());
                executionStatus.put('duration', String.valueOf(getDuration(d1)));
                sendEmail(executionStatus);
                return;
            }

        }

        // Generate Stocktake Items for bulkStocktake Owners
        if (bulkStocktake != null) {
            bulkStocktakeItem.clear();
            Set<Id> ownerIds = new Set<Id>();

            for (Stocktake__c st : bulkStocktake) {
                ownerIds.add(st.OwnerId);
            }

            Map<Id, List<Inventory__c>> inventoriesMap = new Map<Id, List<Inventory__c>>();
            for (Inventory__c inv : [SELECT Id,
                                            Quantity__c,
                                            Qty_On_Loan__c,
                                            Product__c,
                                            OwnerId
                                       FROM Inventory__c 
                                      WHERE OwnerId IN :ownerIds 
                                        AND Status__c = 'Active']) {
                if (inventoriesMap.containsKey(inv.OwnerId)) {
                    inventoriesMap.get(inv.OwnerId).add(inv);
                } else {
                    inventoriesMap.put(inv.OwnerId, new List<Inventory__c>{ inv });
                }
            }

            for (Stocktake__c st : bulkStocktake) {
                if (inventoriesMap.containsKey(st.OwnerId)) {
                    usrInventory = inventoriesMap.get(st.OwnerId);
                }
                
                if (usrInventory != null) {
                    for (Inventory__c ui : usrInventory) {
                        Stocktake_Items__c sti = new Stocktake_Items__c();
                        sti.Stocktake_Link__c = st.Id;
                        sti.Owner__c = st.OwnerId;
                        sti.Product__c = ui.Product__c;
                        sti.SAP_Quantity__c = ui.Quantity__c;
                        sti.On_Loan_Quantity__c = ui.Qty_On_Loan__c;
                        bulkStocktakeItem.add(sti);
                    }
                }
            }

            try {
                // as of 2018-11-15, this runs around 11 to 13 seconds. for monitoring.
                insert bulkStocktakeItem;
                System.debug('ttttt>>> ' + bulkStocktakeItem.size());
            } catch (Exception e) {
                executionStatus.put('message', e.getMessage());
                executionStatus.put('stackTrace', e.getStackTraceString());
                executionStatus.put('duration', String.valueOf(getDuration(d1)));
                sendEmail(executionStatus);
                return;
            }
        }

        executionStatus.put('success', 'true');
        executionStatus.put('message', String.valueOf(bulkStocktake.size()));
        executionStatus.put('duration', String.valueOf(getDuration(d1)));
        sendEmail(executionStatus);
    }

    /**********************************************************************
    * @description Sends an email to the user that initiated the bulk generation process
    * @param executionStatus contains the ff. keys: success (indicates whether the execution succeeded), message (anything to describe the execution),
    * stackTrace (used for errors only), and duration (how long the whole process ran)
    * @example
    * executionStatus.put('success', 'true');
    * executionStatus.put('message', String.valueOf(bulkStocktake.size()));
    * executionStatus.put('duration', String.valueOf(getDuration(d1)));
    * sendEmail(executionStatus);
    */
    @TestVisible private static void sendEmail(Map<String, String> executionStatus) {

        Map<String, String> emailDetails = buildEmailDetails(executionStatus);

        String recipient = UserInfo.getUserEmail();
        String emailSubject = emailDetails.get('subject');
        String emailBody = emailDetails.get('body');
        
        System.debug('DBG: recipient ' + recipient);
        System.debug('DBG: emailSubject ' + emailSubject);
        System.debug('DBG: emailBody ' + emailBody);
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(recipient);
        mail.setToAddresses(sendTo);

        // Step 3: Set who the email is sent from
        mail.setReplyTo('noreply@ttibrands.com.au');
        mail.setSenderDisplayName('TTI Auto-Mailer');

        // Step 4. Set email contents - you can use variables
        mail.setSubject(emailSubject);
        mail.setHtmlBody(emailBody);

        // Step 5. Add your email to the master list
        mails.add(mail);

        // Step 6: Send all emails in the master list
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(mails);

        // TODO: if email sending failed, story email in the 'exceptions' table and email the development team
        System.debug('DBG: SendEmailResult >>> ' + emailResults);
    }

    /**********************************************************************
    * @description Dynamically builds the subject and body of the email message to send, depending on the status of the execution process
    * @param executionStatus contains the ff. keys: success (indicates whether the execution succeeded), message (anything to describe the execution),
    * stackTrace (used for errors only), and duration (how long the whole process ran)
    * @example
    * Map<String, String> emailDetails = buildEmailDetails(executionStatus);
    */
    @TestVisible private static Map<String, String> buildEmailDetails(Map<String, String> executionStatus) {
        Map<String, String> returnValue = new Map<String, String>();
        String body = 'Hi ' + UserInfo.getFirstName() + ', <br /><br />';
        if (Boolean.valueOf(executionStatus.get('success'))) {
            returnValue.put('subject', 'Bulk Stocktake Job: COMPLETE');

            body += 'The Stocktake job has run successfully. Kindly find the details below:';
            body += '<br /><br /><br />';
            body += 'Total Stocktake records created: ' + executionStatus.get('message');
        } else {
            returnValue.put('subject', 'Bulk Stocktake Job: FAILED');

            body += 'The Stocktake job has failed. Kindly raise a ticket in our service desk application regarding this error.';
            body += '<br /><br /><br />';
            body += 'Message: ' + executionStatus.get('message') + '<br />';
            body += 'Stack Trace: ' + executionStatus.get('stackTrace');
        }
        body += '<br /><br /><br />';
        body += 'Execution duration: ' + executionStatus.get('duration');
        body += '<br /><br /><br />';
        body += 'Regards,';
        body += '<br />';
        body += 'Salesforce Team';
        body += '<br /><br /><br /><br />';
        body += 'NOTE: This is an auto-generated email. If you have concerns or queries, kindly raise a ticket in our service desk application.';
        body += '<br /><br /><br />';
        returnValue.put('body', body);
        return returnValue;
    }

    /**********************************************************************
    * @description Computes the run-time duration
    * @param dateInLong start time of the execution process
    * @example
    * Long duration = getDuration(<time_less_than_now>)
    */
    private Long getDuration(Long dateInLong) {
        return (Datetime.now().getTime() - dateInLong) / 1000;
    }
    /*
    public static void forTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }*/
}