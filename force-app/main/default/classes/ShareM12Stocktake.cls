/**
 * Created by Haider Raza on 20/01/2017.
 */

public class ShareM12Stocktake {
    
    public String currentId {
        get{
            if (currentId == null) {
                currentId = ApexPages.currentPage().getParameters().get('Id');
            }
            return currentId;
        }
        set;
    }
    
    public String accountId {
        get {
            if (accountId == null) {
                accountId = [SELECT Account__c FROM M12_Stocktake__c WHERE Id= :currentId].Account__c;
            }
            return accountId;
        }
        set;
    }

    public String accountName {
        get {
            if (accountName == null) {
                accountName = [SELECT Account__r.Name FROM M12_Stocktake__c WHERE Id= :currentId].Account__r.Name;
            }
            return accountName;
        }
        set;
    }

    private String StocktakeOwner;
    private String SubmittedMonth;
    public String M12StocktakeName { get; set; }
    public Datetime M12StocktakeDate { get; set; }

    private String qry = 'SELECT Id, M12_Inventory__r.Product__r.ProductCode, M12_Inventory__r.Product__r.Description, M12_Stocktake__r.Total_Order_Value__c, ' +
                         'M12_Inventory__r.M12_Hub_Price_per_unit__c, M12_Inventory__r.Required_Quantity__c, Stocktake_Quantity__c, Variation__c, Total_Price__c, ' +
                         'M12_Stocktake__r.Owner.Name, M12_Stocktake__c, M12_Stocktake__r.Submitted_Date__c, M12_Stocktake__r.OwnerId, M12_Stocktake__r.LastModifiedDate, M12_Stocktake__r.Name '+
                         'FROM M12_Stocktake_Inventory__c  ' +
                         'WHERE M12_Stocktake__c =\'' + currentId + '\'';

    private User ownerUser;
    private String ownerId;

    public List<M12_Stocktake_Inventory__c> getstocktakes() {
        List<M12_Stocktake_Inventory__c> stocks = Database.query(qry);
        TotalOrderValue = stocks[0].M12_Stocktake__r.Total_Order_Value__c;
        StocktakeOwner = stocks[0].M12_Stocktake__r.Owner.Name;
        if (stocks[0].M12_Stocktake__r.Submitted_Date__c != null) {
            SubmittedMonth = stocks[0].M12_Stocktake__r.Submitted_Date__c.format('MMMMM') + '/' + stocks[0].M12_Stocktake__r.Submitted_Date__c.format('YYYY');
        } else {
            SubmittedMonth = System.now().format('MMMMM');
        }
        ownerId = stocks[0].M12_Stocktake__r.OwnerId;
        M12StocktakeName = stocks[0].M12_Stocktake__r.Name;
        M12StocktakeDate = stocks[0].M12_Stocktake__r.LastModifiedDate;

        return stocks;
    }

    public Double TotalOrderValue { get; set; }

    public List<cContact> contactList { get; set; }

    public List<cContact> getContacts() {
        if (contactList == null) {
            contactList = new List<cContact>();
            for (Contact c : [SELECT Id, FirstName, LastName, Name, Email, Record_Status__c, Title, Trade__c, Account.Name
                                FROM Contact
                                WHERE AccountId = :accountId
                                AND Email!=null]) {
                contactList.add(new cContact(c));
            }
        }
        return contactList;
    }

    public class cContact{
        public Contact contact { get; set; }
        public Boolean selected { get; set; }
        public cContact(Contact c) {
            this.contact = c;
            this.selected = false;
        }
    }

    public void M12SharePDF() {
        PageReference pdf = new PageReference('/apex/ShareM12Stocktake?accId='+accountId+'&Id='+currentId+'&sendEmail=1');
        pdf.setRedirect(true);

        Blob b;
        if (Test.isRunningTest()) {
            b = Blob.valueOf('Unit Test');
        } else {
            b = pdf.getContentAsPDF();
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        

        ownerUser = [SELECT Id, MobilePhone, Email, Title FROM User WHERE Id = :ownerId LIMIT 1];

        try {

            String[] emailReciepents = getContactEmails().values();
            String customerName = (AccountName == null ? 'Customer' : AccountName);

            if (String.isNotEmpty(additionalEmails)) {
                emailReciepents.addAll(additionalEmails.split(','));
            }

            email.setToAddresses(emailReciepents);
            email.setPlainTextBody('Dear '+ customerName +', \n\n'+
                                    'Please refer to the attached PDF for your suggested M12 Hub Order for the period of ' + SubmittedMonth + ' \n\n'+
                                    'Kind Regards, \n'+
                                    (StocktakeOwner==null ? '' : StocktakeOwner) + '\n'+
                                    (ownerUser.MobilePhone==null || ownerUser.MobilePhone=='' ? '' : ownerUser.MobilePhone)+'\n'+
                                    (ownerUser.Email==null ? '' : ownerUser.Email)+'\n'+
                                    (ownerUser.Title==null ? '' : ownerUser.Title)
            );

            // Create an email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setContentType('application/pdf');
            efa.setFileName('M12Hub.pdf'); // neat - set name of PDF
            efa.Body = b;
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
            email.setSubject(customerName + ' - M12 Hub Suggest Order – ' + SubmittedMonth);

            // send it, ignoring any errors (bad!)
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }

            isEmailSent = true;

            flagContacts(getContactEmails().keySet(), accountId, currentId);

            Set<String> si = new Set<String>();
            for (M12_Stocktake_Inventory__c i : getstocktakes()) {
                si.add(i.M12_Stocktake__c);
            }
            flagStocktakeInventory(si);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email sent successfully.'));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to send email. '+ex.getMessage()));
        }
    }

    public Boolean isEmailSent {
        get{
            if (isEmailSent == null) {
                isEmailSent = false;
            }
            return isEmailSent;
        }
        set;
    }

    public String additionalEmails { get; set; }

    public Map<String, String> getContactEmails() {
        Map<String, String> selectedEmailIds = new Map<String, String>();
        for (cContact c : getContacts()) {
            if (c.selected) {
                selectedEmailIds.put(c.contact.Id, c.contact.Email);
            }
        }

        return selectedEmailIds;
    }

    @future
    public static void flagStocktakeInventory(Set<String> si) {
        List<M12_Stocktake__c> m12i = new List<M12_Stocktake__c>();

        for (String i : si) {
            m12i.add(new M12_Stocktake__c(Id = i, Emailed__c=true, Emailed_Date__c=System.Now()));
        }
        
        update m12i;
    }

    @future(callout=true)
    public static void flagContacts(Set<String> contactIds, String accId, String cId) {
        PageReference pdf = new PageReference('/apex/ShareM12Stocktake?accId='+accId+'&Id='+cId+'&sendEmail=1');

        Blob b;
        if (Test.isRunningTest()) {
            b = Blob.valueOf('Unit Test');
        } else {
            b = pdf.getContent();
        }

        List<Attachment> att = new List<Attachment>();

        for (String c : contactIds) {
            att.add(new Attachment(Body = b, ParentId=c, Name='M12 Hub'+System.Now()));
        }

        if (att.size() > 0) {
            insert att;
        }
    }

}