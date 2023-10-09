global class DailyRebate implements Schedulable {
    global void execute(SchedulableContext sc) {
        DailyRebateCalculation daily = new DailyRebateCalculation(this.getQuery());
        Database.executeBatch(daily);
    }

    private String getQuery() {
        return 'SELECT Id, EndDate, StartDate, '
                + '(SELECT Id, Account__c FROM Contract_Accounts__r), '
                + '(SELECT Id, Contract__c, Max__c, Min__c, Auto_Number__c, Rebate__c FROM Contract_Tiers__r ORDER BY Auto_Number__c), '
                + '(SELECT Id, Rebate_Unique_Id__c, Sales__c, Contract__c FROM Rebates__r WHERE Rebate_Type__c=\'Daily\') '
                + 'FROM Contract '
                + 'WHERE EndDate>= :rDate '
                + 'AND RecordTypeId= :approvedRecordTypeId ';
    }   
}