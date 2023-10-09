/**
* @author                   Francis Nasalita
* @date                     2022-07-18
*
* @description              Account Trigger Handler to check if any lead source is updated
*/
public without sharing class AcctLeadSourceCheckerTriggerHandler extends TriggerHandler {

    private final static String ACCOUNT_LEAD_SOURCE_API_NAME = 'PersonLeadSource';
    private final static String B2C_CONSUMER_CONTACT = 'B2C Consumer Contact';

    private Map<Id, Account> newAccounts;
    private Map<Id, Account> oldAccounts;

    public AcctLeadSourceCheckerTriggerHandler() {
        this.newAccounts = new Map<Id, Account>();
        this.oldAccounts = new Map<Id, Account>();

        Id b2cRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(B2C_CONSUMER_CONTACT).getRecordTypeId();

        // process b2c accounts
        for (Id accountId : Trigger.newMap.keySet()) {
            Account account = (Account) Trigger.newMap.get(accountId);

            if (account.RecordTypeId == b2cRecordTypeId) {
                this.newAccounts.put(accountId, account);
                this.oldAccounts.put(accountId, (Account) Trigger.oldMap.get(accountId));
            }
        }
        
    }

    public override void beforeUpdate() {
        this.checkLeadSourceIfChanged();
    }

    public void checkLeadSourceIfChanged() {
        for (Id accountId : this.newAccounts.keySet()) {
            Account newAccount = this.newAccounts.get(accountId);
            Account oldAccount = this.oldAccounts.get(accountId);

            if (this.fieldHasChanged(newAccount, oldAccount, ACCOUNT_LEAD_SOURCE_API_NAME)) {
                this.revertFieldChange(newAccount, oldAccount, ACCOUNT_LEAD_SOURCE_API_NAME);
            }
        }
    }

    private Boolean fieldHasChanged(Account newAccount, Account oldAccount, String fieldName) {
        return oldAccount.get(fieldName) != newAccount.get(fieldName);
    }

    private void revertFieldChange(Account newAccount, Account oldAccount, String fieldName) {
        newAccount.put(fieldName, oldAccount.get(fieldName));
    }

}