public class AccountPlanExtension2 {

    public AccountPlan__c plan{get; set;}
    public AcctPlanTargetProd__c newTargetProduct{get; set;}
    public AcctPlanStraTarget__c newStrategicTarget{get; set;}

    public boolean displayPopup {get; set;}
    public Set<String> years = new Set<String>();

    // the variable being set from the commandbutton
    public String recordID{
        get;
        // *** setter is NOT being called ***
        set {
            recordID = value;
        }
    }

    String accountId;
    String planId;
    private final Integer START_YEAR = 2013;

    public AccountPlanExtension2(ApexPages.StandardSetController stdController){
        String prefixId = String.valueOf(ApexPages.currentPage().getParameters().get('id')).substring(0,3);
        if(prefixId == '001'){
            this.accountId = ApexPages.currentPage().getParameters().get('id');
        }else{
            this.planId = ApexPages.currentPage().getParameters().get('id');
        }
        initAccountPlan();
    }

    public PageReference editEndUser(){
        PageReference endUserEditPage = new PageReference('/apex/vf_AccountPlanEditEndUser?id=' + this.plan.id);

        endUserEditPage.setRedirect(true);
        return endUserEditPage;
    }

    public PageReference editRetail(){
        PageReference endUserEditPage = new PageReference('/apex/vf_AccountPlanEditRetail?id=' + this.plan.id);

        endUserEditPage.setRedirect(true);
        return endUserEditPage;
    }

    public void initAccountPlan(){

        String qry = 'SELECT Id, Account__c, isInited__c, Year__c, CallCycleFrequency__c, '+
                'Target_Product_Categories__c, AccessoriesSegmentsTarget__c, JSS_Value_Proposition__c, ' +
                'AccountNumber__c, AccountName__c, Account__r.Name, Current_Year_Sales_JSS__c, ' +
                'Last_Year_Sales_JSS__c, RelationshipSummary__c, KeyFactorsEffectingPerformanceLY__c,   ' +
                'Key_Trends__c, Projected_Outlook__c, SWOT_Strength__c, SWOT_Weaknesses__c, ' +
                'SWOT_Opportunities__c, SWOT_Threats__c, JSS_Engagement_Plan_Rich__c, Status__c, ' +
                'TrainingPlan__c, KeyMeasuresCurrentYear__c, M12HubTarget__c, HammerClubTarget__c, ' +
                'M12_Hub__c, Hammer_Club__c, ProductActionPlan__c, DisplayStandsActionPlan__c, ' +
                'JSS_EngagementPlan__c, PromotionStrategy__c, ShowsSaleDaysPlan__c, OtherComments__c, Account_Type__c ' +
                'FROM AccountPlan__c WHERE ';
        //if (accountId == null || accountId == '')
            qry += 'Id=\'' + this.planId + '\'';
        /*else
            qry += 'Account__c=\'' + this.accountId + '\'';*/

        try {
            this.plan = Database.query(qry);
        }catch (Exception ex){
            this.plan = new AccountPlan__c(Account__c=this.accountId);
        }

        this.createTargetProduct();
        this.createStrategicTarget();


        List<AccountPlan__c> ap_list = [Select a.Year__c, a.Id, a.Account__c From AccountPlan__c a WHERE  a.Account__c = :plan.Account__c];
        for(AccountPlan__c ap:ap_list){
            years.add(ap.Year__c);
        }

    }


    public AccountPlanExtension2(ApexPages.StandardController stdController){
        this.plan = (AccountPlan__c)stdController.getRecord();
    }

    public PageReference redirectPage(){
        PageReference redirectTo;

        if(this.plan.Account_Type__c == 'Retailer')
            redirectTo = new PageReference('/apex/vf_AccountPlanRetail?id=' + this.plan.Id);

        if(this.plan.Account_Type__c == 'End Consumer'|| this.plan.Account_Type__c == 'Head Office - End Consumer')
            redirectTo = new PageReference('/apex/vf_AccountPlanEndUser?id=' + this.plan.Id);

        redirectTo.setRedirect(true);
        return redirectTo;
    }

    public PageReference redirectEditPage(){
        PageReference redirectTo;

        if(this.plan.Account_Type__c == 'Retailer')
            redirectTo = new PageReference('/apex/vf_AccountPlanEditRetail?id=' + this.plan.Id);

        if(this.plan.Account_Type__c == 'End Consumer'|| this.plan.Account_Type__c == 'Head Office - End Consumer')
            redirectTo = new PageReference('/apex/vf_AccountPlanEditEndUser?id=' + this.plan.Id);

        redirectTo.setRedirect(true);
        return redirectTo;
    }


    public void closePopup() {
        displayPopup = false;
    }
    public void showPopup() {
        displayPopup = true;
    }

    public PageReference saveAP(){
        upsert this.plan;

        PageReference viewPage;
        if(this.plan.Account_Type__c == 'Retailer')
            viewPage = new PageReference('/apex/vf_AccountPlanRetail?id=' + this.plan.id);

        else if(this.plan.Account_Type__c == 'End Consumer' || this.plan.Account_Type__c == 'Head Office - End Consumer')
            viewPage = new PageReference('/apex/vf_AccountPlanEndUser?id=' + this.plan.id);

        else
            viewPage = new PageReference('/' + this.accountId);

        viewPage.setRedirect(true);
        return viewPage;
    }

    public PageReference saveAndContinue() {
        this.plan.isInited__c = true;
        upsert this.plan;

        String pageName = ApexPages.CurrentPage().getUrl();
        if(!Test.isRunningTest()) {
            pageName = pageName.replaceFirst('/apex/', '');
            pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
            string[] pageNameExtra = pageName.split('%3F', 0);
            pageName = pageNameExtra[0];
        }else{
            pageName = 'vf_AccountPlanEndUser';
        }

        PageReference editPage = new PageReference('/apex/'+pageName+'?id=' + this.plan.id);
        editPage.setRedirect(true);
        return editPage;
    }

    public PageReference backToAccount() {
        PageReference editPage = new PageReference('/' + this.plan.Account__r.id);
        editPage.setRedirect(true);
        return editPage;
    }

    public Boolean isEditable(){
        return true;
    }

    public Boolean isApproved(){
        return false;
    }

    public PageReference reviewAccountPlan(){
        return null;
    }

    public void createTargetProduct(){
        newTargetProduct = new AcctPlanTargetProd__c();
        newTargetProduct.AccountPlan__c = this.plan.Id;
    }

    public PageReference removeProduct() {
        newTargetProduct.id = this.recordID;
        delete newTargetProduct;
        this.createTargetProduct();
        return null;
    }

    public void addProduct(){
        newTargetProduct.id = null;
        insert newTargetProduct;
        closePopup();
    }

    public void newStrategicTarget(){
        this.createStrategicTarget();
        showPopup();
    }

    public void createStrategicTarget(){
        newStrategicTarget = new AcctPlanStraTarget__c();
        newStrategicTarget.AccountPlan__c = plan.Id;
        newStrategicTarget.Priority__c = 1;
        newStrategicTarget.id = null;
    }

    public PageReference removeStrategicTarget() {
        newStrategicTarget.id = this.recordID;
        delete newStrategicTarget;
        return null;
    }





    public void saveStrategicTarget(){
        upsert newStrategicTarget;
        closePopup();
    }


    public void editStrategicTarget(){
        if(this.recordID != null){
            newStrategicTarget = [SELECT Id, Priority__c, Description__c FROM AcctPlanStraTarget__c where Id = :this.recordID];
            showPopup();
        }

    }


    public List<AcctPlanTargetProd__c> getRelatedTargetProducts(){
        List<AcctPlanTargetProd__c> prodList = [SELECT Id, Material__c, Description__c, Category__c, AccountPlan__r.Id FROM AcctPlanTargetProd__c where AccountPlan__r.Id = :plan.Id];
        return prodList;
    }

    public List<AcctPlanStraTarget__c> getRelatedStrategicTargets(){
        List<AcctPlanStraTarget__c> targetList = [SELECT Id, Priority__c, Description__c FROM AcctPlanStraTarget__c where AccountPlan__r.Id = :plan.Id ORDER BY Priority__c];
        return targetList;
    }

    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer startYear = START_YEAR; startYear <= getCurrentYear(); startYear++) {
            options.add(new SelectOption(String.valueOf(startYear), String.valueOf(startYear), this.yearIsAvailable(String.valueOf(startYear))));
        }
        return options;
    }

    private Integer getCurrentYear() {
        Date dateToday = System.today();
        Integer currentYear = dateToday.year();

        return currentYear;
    }



    private Boolean yearIsAvailable(String val){
        return (years.contains(val))?true:false;
    }


}