public class AccountPlanExtension {
    
    public AccountPlan__c plan{ get; set; }
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
    
    private ApexPages.StandardController ctrl;
    
    public AccountPlanExtension(ApexPages.StandardController stdController){        
        this.ctrl = stdController;           
        initAccountPlan();
    }
    
    public void initAccountPlan(){
        this.plan = (AccountPlan__c)this.ctrl.getRecord();
        this.createTargetProduct();
        this.createStrategicTarget();
 
        
        List<AccountPlan__c> ap_list = [Select a.Year__c, a.Id, a.Account__c From AccountPlan__c a WHERE  a.Account__c = :plan.Account__c];     
        for(AccountPlan__c ap:ap_list){
            years.add(ap.Year__c);          
        } 
 
    }
       
    
    public void closePopup() {        
        displayPopup = false; 
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public PageReference saveAndContinue() {
        this.plan.isInited__c = true;
        upsert this.plan;      
        PageReference editPage = new PageReference('/apex/vf_AccountPlanEdit?id=' + this.plan.id);
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
        
        List<String> yearRange = Label.AccountPlanYearRange.split('-');
        Integer minYear = Integer.valueOf(yearRange[0]);
        Integer maxYear = Integer.valueOf(yearRange[1]);
        
        List<SelectOption> options = new List<SelectOption>();
        
        for (Integer i = minYear; i <= maxYear; i++) {
            String year = String.valueOf(i);
            options.add(new SelectOption(year, year, this.yearIsAvailable(year)));
        }
        
        return options;
    }
    

    
    private Boolean yearIsAvailable(String val){    
        return (years.contains(val))?true:false;
    }

     
}