/**
* @author                   Francis Nasalita
* @date                     2021-11-26
*
* @description              Lead Trigger Handler to check matching AEG Person Account
*/
public without sharing class AEGLeadAccountMatchTriggerHandler extends TriggerHandler {
    
    private List<Lead> leads;
    private List<String> leadEmails;
    
    public AEGLeadAccountMatchTriggerHandler() {
        this.leads = new List<Lead>();
        this.leadEmails = new List<String>();
    
        for (Lead lead : (List<Lead>) Trigger.new) {
    
            // skip if first name, last name or email is blank
            if (String.isBlank(lead.FirstName) || String.isBlank(lead.LastName) || String.isBlank(lead.Email)) {
                continue;
            }
            
            this.leadEmails.add(lead.Email);
            this.leads.add(lead);
        }
    
    }
    
    public override void beforeInsert() {
        for (Lead lead : getLeadsWithMatchingAccount()) {
            lead.My_AEG_User__c = true;
        }

        assignLeadToMatchedContactOwner();
    }

    private List<Lead> getLeadsWithMatchingAccount() {
        Id b2cRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        List<Account> accountsMatched = [
            SELECT Id,
                   FirstName,
                   LastName,
                   PersonEmail,
                   IsCustomerPortal
              FROM Account
             WHERE PersonEmail IN :this.leadEmails
               AND IsCustomerPortal = true
               AND Brand__pc = 'AEG'
               AND FirstName != NULL
               AND LastName != NULL
               AND PersonEmail != NULL
               AND RecordTypeId = :b2cRecordTypeId
        ];

        Set<String> matchedAccounts = new Set<String>();

        for (Account acct : accountsMatched) {
            matchedAccounts.add(acct.FirstName.toLowerCase() + acct.LastName.toLowerCase() + acct.PersonEmail);
        }

        List<Lead> leadsWithMatchingAccount = new List<Lead>();

        for (Lead lead : this.leads) {
            if (matchedAccounts.contains(lead.FirstName.toLowerCase() + lead.LastName.toLowerCase() + lead.Email)) {
                leadsWithMatchingAccount.add(lead);
            }
        }

        return leadsWithMatchingAccount;
    }

    
    private void assignLeadToMatchedContactOwner() {
        Id aegOnsiteAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AEG Onsite Account').getRecordTypeId();
        List<Contact> contactsMatched = [
            SELECT Id, 
                   FirstName, 
                   LastName, 
                   Email,
                   OwnerId
              FROM Contact 
             WHERE Email IN :this.leadEmails
               AND Account.RecordTypeId = :aegOnsiteAcctRtId
               AND FirstName != NULL
               AND LastName != NULL
               AND Email != NULL
          ORDER BY CreatedDate DESC
        ];

        Map<String, Contact> matchedContactsNameEmail = new Map<String, Contact>();

        for (Contact contact : contactsMatched) {
            String key = contact.FirstName.toLowerCase() + contact.LastName.toLowerCase() + contact.Email;
            matchedContactsNameEmail.put(key, contact);
        }

        for (Lead lead : this.leads) {
            String key = lead.FirstName.toLowerCase() + lead.LastName.toLowerCase() + lead.Email;
            if (matchedContactsNameEmail.containsKey(key)) {
                lead.OwnerId = matchedContactsNameEmail.get(key).OwnerId;
            }
        }

    }
}