global class QuarterlyRebate implements Schedulable {
    global void execute(SchedulableContext sc) {
        QuarterRebateCalculation quarter = new QuarterRebateCalculation(this.getQuery());
        Id batchprocessid = Database.executeBatch(quarter);
    }

    private String getQuery() {
        return 'SELECT Id, EndDate, '
                + '(SELECT Id, Account__c FROM Contract_Accounts__r), '
                + '(SELECT Id, Contract__c, Max__c, Min__c, Auto_Number__c, Rebate__c FROM Contract_Tiers__r ORDER BY Auto_Number__c) '
                + 'FROM Contract '
                + 'WHERE EndDate >= :qEndDate '
                + 'AND RecordTypeId = :approvedRecordTypeId';
    }
}