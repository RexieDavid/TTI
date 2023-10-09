/**
 * @author                          Haider Raza
 * @date                            07/04/2016
 * @description                     Calculate rebates
**/
global class QuarterRebateCalculation implements Database.Batchable<sObject> {
    Period quarterDates = TTIUtilClass.periods.get('Current');
    Date qStartDate = quarterDates.StartDate;
    Date qEndDate = quarterDates.EndDate;
    String qNumber = String.valueOf(quarterDates.Number);
    String query;

    public QuarterRebateCalculation(String query){
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String approvedRecordTypeId = TTIUtilClass.getRecordTypeId('Contract', 'Approved').get('Approved');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        RebateCalculations.isDailyretrospective = false;
        RebateCalculations.contracts = (List<Contract>)scope;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(qStartDate, qEndDate, null, true);
        RebateCalculations.caluclateRebate();
        RebateCalculations.evaluteNextYearSpend();
        RebateCalculations.createRebate(true, qNumber);
    }

    global void finish(Database.BatchableContext BC) {}
}