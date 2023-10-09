@isTest
public class Test_AccountPlanExtension {
	
	@testSetup static void testData(){
    	AccountPlan__c ap = new AccountPlan__c();
    	Account act = new Account();
    	act.Name = 'TestAccount';
    	insert act;		
    		
    	ap.Account__c = act.Id;
    	insert ap;
    		
	}

    static testMethod void testPopupMethods() {
        
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c from AccountPlan__c where account__c = :acc.Id];
    	ApexPages.StandardController sc = new ApexPages.standardController(ap);
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);	
		ApexPages.currentPage().getParameters().put('Id',ap.Id);
		
        ctrl.showPopup();
	    system.assertEquals(ctrl.displayPopup, true);   
	    ctrl.closePopup();
	    system.assertEquals(ctrl.displayPopup, false);       
    }
    
    static testMethod void testRelatedListMethods() {
        
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c from AccountPlan__c where account__c = :acc.Id];
    	ApexPages.StandardController sc = new ApexPages.standardController(ap);		
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);		
		List<AcctPlanTargetProd__c> products = ctrl.getRelatedTargetProducts();
		system.assertEquals(products.size(), 0);
		List<AcctPlanStraTarget__c> targets = ctrl.getRelatedStrategicTargets();
		system.assertEquals(targets.size(), 0);		
    }
      
    static testMethod void testRelatedProductListMethods() {
        
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c from AccountPlan__c where account__c = :acc.Id];
    	ApexPages.StandardController sc = new ApexPages.standardController(ap);		
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);	
		ctrl.createTargetProduct();
		ctrl.addProduct();
		ctrl.recordID = ctrl.newTargetProduct.Id;
		ctrl.removeProduct();    
    }
    
    static testMethod void testRelatedTargetListMethods() {
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c from AccountPlan__c where account__c = :acc.Id];
    	ApexPages.StandardController sc = new ApexPages.standardController(ap);		
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);
			
    	ctrl.createStrategicTarget();
    	
    	System.assertEquals(ctrl.newStrategicTarget.AccountPlan__c, ctrl.plan.Id);
    	System.assertEquals(ctrl.newStrategicTarget.id, null);
				
		ctrl.newStrategicTarget();
		ctrl.saveStrategicTarget();
		ctrl.recordID = ctrl.newStrategicTarget.Id;
			
		ctrl.editStrategicTarget();
		
		ctrl.removeStrategicTarget();    
    }  
    
     static testMethod void testPageRefMethods() {
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c, Account__r.Id from AccountPlan__c where account__c = :acc.Id];
     	ApexPages.StandardController sc = new ApexPages.standardController(ap);		
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);
     	ctrl.saveAndContinue();
     	ctrl.backToAccount();
     	ctrl.reviewAccountPlan();
     	
     	system.assertEquals(ctrl.isEditable(), true);
		system.assertEquals(ctrl.isApproved(), false);
     	
     }
     
     static testMethod void testYearsMethods() {
        Account acc = [Select Id from Account where name = 'TestAccount'];
        AccountPlan__c ap = [Select Id,account__c from AccountPlan__c where account__c = :acc.Id];
     	ApexPages.StandardController sc = new ApexPages.standardController(ap);		
		AccountPlanExtension ctrl = new AccountPlanExtension(sc);
		
		ctrl.years.add('2014');		
		ctrl.getYears();
     }
     

}