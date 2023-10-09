public with sharing class RebateCalculationsExtension {
    private final String ERR_CALCULATE_REBATES_MESSAGE = 'Unable to calculate the rebates. Reason: {0}';

    public Contract theContract { get; set; }
    public List<Period> allQuarters { get; set; }
    public List<Rebate__c> rebates { get; set; }
    public List<Rebate__c> dailyrebates{ get; set; }
    private ApexPages.StandardController stdcon;
    private Map<String, Period> periods { get; set; }

    @TestVisible
    private RebateCalculationsExtensionDataService service  = new RebateCalculationsExtensionDataService();

    public RebateCalculationsExtension(ApexPages.StandardController controller) {
        this.stdcon = controller;
        this.initPayload();
    }

    /**
     * Contructor to override service class with mock data
     */
    public RebateCalculationsExtension(ApexPages.StandardController controller, RebateCalculationsExtensionDataService service) {
        this.service = service;
        this.stdcon = controller;
        this.initPayload();
    }

    private void initPayload() {
        this.theContract = this.service.fetchApprovedContract(this.stdcon.getRecord().Id);
        this.periods = this.service.fetchFiscalYearPeriods();
        this.allQuarters = this.fetchQuarterPeriods();
        this.runRebateCalculations();
    }

    private List<Period> fetchQuarterPeriods() {
        List<Period> quarterPeriods = new List<Period>();
        for (String key : this.periods.keySet()) {
            Period period = this.periods.get(key);
            if (this.isValidPeriod(key, period)) {
                if (key == 'Current') {
                    break;
                }
                quarterPeriods.add(period);
            }
        }
        return quarterPeriods;
    }

    private Boolean isValidPeriod(String key, Period period) {
        Boolean hasContractStartDate = this.theContract.StartDate != null;
        Boolean isPeriodStartDateValid = period.StartDate != null && period.StartDate >= this.theContract.StartDate;
        return hasContractStartDate && isPeriodStartDateValid;
    }

    private void runRebateCalculations() {
        try{
            this.rebates = this.runQuarterlyRebateCalculations();
            this.dailyrebates = this.runDailyRebateCalculation();
        } catch(Exception ex) {
            this.showUIMessage(
                ApexPages.Severity.Error, 
                String.format(ERR_CALCULATE_REBATES_MESSAGE, new List<String>{ex.getMessage()})
            );
        }
    }

    private List<Rebate__c> runQuarterlyRebateCalculations() {
        List<Rebate__c> rebates = new List<Rebate__c>();
        Date lastQuarterEndDate = this.periods.get('Current').StartDate.addDays(-1);
        RebateCalculationsUtility.contracts = new List<Contract>{this.theContract};
        RebateCalculationsUtility.prepareCollections();
        RebateCalculationsUtility.retreiveOpportunityRollup(this.theContract.StartDate, lastQuarterEndDate);
        for(String key : this.fetchFiscalYearQuarters()) {
            RebateCalculationsUtility.caluclateRebates(key, this.theContract.Id);
            RebateCalculationsUtility.evaluteNextYearSpends(key, this.theContract.Id);
            Rebate__c rebate = RebateCalculationsUtility.createRebate(true, key, this.theContract.Id);
            if (rebate != null) {
                rebates.add(rebate);
            }
        }
        return rebates;
    }

    private Set<String> fetchFiscalYearQuarters() {
        Set<String> quarters = new Set<String>();
        for (Period period : this.allQuarters) {
            String key = period.StartDate.year() + ':' + period.Number;
            quarters.add(key);
        }
        return quarters;
    }

    private List<Rebate__c> runDailyRebateCalculation() {
        Date dateToday = Date.Today();
        RebateCalculations.contracts = new List<Contract>{this.theContract};
        RebateCalculations.isDailyretrospective = true;
        RebateCalculations.isDailyRebate = true;
        RebateCalculations.prepareCollections();
        RebateCalculations.retreiveDailyOpportunityRollup(dateToday);
        RebateCalculations.caluclateRebate();
        RebateCalculations.evaluteNextYearSpend();
        RebateCalculations.createRebate(false, null);
        return RebateCalculations.rebates;
    }

    public PageReference createRebate() {
        try {
            List<Rebate__c> allRebates = new List<Rebate__c>();
            allRebates.addAll(rebates);
            allRebates.addAll(dailyrebates);
            if (!allRebates.isEmpty()) {
                this.service.upsertRebates(allRebates);
            }
        } catch(Exception ex) {
            this.showUIMessage(
                ApexPages.Severity.Error, 
                String.format(ERR_CALCULATE_REBATES_MESSAGE, new List<String>{ex.getMessage()})
            );
        }
        return this.redirectOnSave();
    }

    private void showUIMessage(ApexPages.Severity type, String message) {
        ApexPages.addMessage(new ApexPages.Message(type, message));
    }

    private PageReference redirectOnSave() {
        PageReference redirectPage = new PageReference('/' + this.stdcon.getRecord().Id);
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public PageReference doCancel() {
        return stdcon.cancel();
    }
}