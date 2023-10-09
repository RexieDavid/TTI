/**
 * @author                          Haider Raza
 * @date                            07/04/2016
 * @description                     Calculate rebates
**/
global class DailyRebateCalculation implements Database.Batchable<sObject>{
    String  query;
    Date rDate = Date.Today().addDays(-1);

    public DailyRebateCalculation(String query){
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String approvedRecordTypeId = TTIUtilClass.getRecordTypeId('Contract', 'Approved').get('Approved');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject>scope){
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.isDailyretrospective = false;
        RebateCalculations.contracts = (List<Contract>)scope;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveOpportunityRollup(null, null, rDate, false);
        RebateCalculations.caluclateRebate();
        RebateCalculations.evaluteNextYearSpend();
        RebateCalculations.createRebate(false, null);
    }

    global void finish(Database.BatchableContext BC) {}
}