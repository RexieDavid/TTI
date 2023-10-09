@isTest (SeeAllData=true)
private class TestAccountSummaryController {

	//Account Summary Unit Test (Account with highest Sales History)
	static testMethod void myAccountSummaryUnitTest() {
		//Record Type
		Id recType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
	    //Set Account ID
	    Id acc = (Id)[Select Id From Account WHERE RecordTypeId =:recType AND LastActivityDate = LAST_N_DAYS:365 ORDER BY LastActivityDate][0].get('Id');

	    PageReference pageRef = New Pagereference('/'+acc);
	    Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',acc);

	    //Initiate Controller
	    AccountSummaryController controller = new AccountSummaryController();
	    
	    //************* Debug *************************************
	    system.debug('The selected account Id is: '+controller.accountID);
	    system.debug('The account details are as follows: '+controller.accountItem);
	    //*********************************************************
		controller.getBudgetTotalCFY();
		controller.getTotalSales();
		controller.getTotalSalesACS();
		controller.getTotalSalesTools();
		controller.getCategoryBreakdown();
		controller.getTop10Accessories();
		controller.getTop10Handtools();
		controller.getTop10PowerTools();
		controller.getMMSYTD();
		controller.getMMSLYTD();
		controller.getMMSLCY();
		controller.getMMSVariance();
		controller.getSalesAchievement();
		controller.getAContact();
		controller.getAOpps();
		controller.getJSSSalesYTD();
		controller.getJSSSalesLYTD();
		controller.getJSSVariance();
		controller.getALeads();
		controller.getAEvents();
		controller.getEventSizeYTD();
		controller.getEventSizeLYTD();
		controller.getLNEContact();
		controller.getAEventPTraining();
		controller.getTrainingAttendanceYTD();
		controller.getPracticalYTD();
		controller.getPracticalLYTD();
		controller.getPracticalVariance();
		controller.getPracticalLCY();
		controller.getJointDealerCountYTD();
		controller.getJointDealerCountLYTD();
		controller.getJointDealerVariance();
		controller.getJointDealerCountLCY();
		controller.getEndUsers();
    }
    //Account Summary Unit Test (Account with least Sales History)
	static testMethod void myAccountSummaryUnitTest1() {
		//Record Type
		Id recType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
	    //Set Account ID
	    Id acc = (Id)[Select Id From Account WHERE RecordTypeId =:recType AND LastActivityDate = LAST_N_DAYS:365 ORDER BY LastActivityDate DESC][0].get('Id');

	    PageReference pageRef = New Pagereference('/'+acc);
	    Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',acc);

	    //Initiate Controller
	    AccountSummaryController controller = new AccountSummaryController();
	    
	    //************* Debug *************************************
	    system.debug('The selected account Id is: '+controller.accountID);
	    system.debug('The account details are as follows: '+controller.accountItem);
	    //*********************************************************
		controller.getBudgetTotalCFY();
		controller.getTotalSales();
		controller.getTotalSalesACS();
		controller.getTotalSalesTools();
		controller.getCategoryBreakdown();
		controller.getTop10Accessories();
		controller.getTop10Handtools();
		controller.getTop10PowerTools();
		controller.getMMSYTD();
		controller.getMMSLYTD();
		controller.getMMSLCY();
		controller.getMMSVariance();
		controller.getSalesAchievement();
		controller.getAContact();
		controller.getAOpps();
		controller.getJSSSalesYTD();
		controller.getJSSSalesLYTD();
		controller.getJSSVariance();
		controller.getALeads();
		controller.getAEvents();
		controller.getEventSizeYTD();
		controller.getEventSizeLYTD();
		controller.getLNEContact();
		controller.getAEventPTraining();
		controller.getTrainingAttendanceYTD();
		controller.getPracticalYTD();
		controller.getPracticalLYTD();
		controller.getPracticalVariance();
		controller.getPracticalLCY();
		controller.getJointDealerCountYTD();
		controller.getJointDealerCountLYTD();
		controller.getJointDealerVariance();
		controller.getJointDealerCountLCY();
		controller.getEndUsers();
    }
    //Account Group Summary Unit Test (Account with least Sales History)
	static testMethod void myAccountGroupSummaryUnitTest() {
		//HQ Record Type
		Id recTypeHQ = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
	    //Set Account ID
	    Id acc = (Id)[Select Id From Account Where RecordTypeId =:recTypeHQ AND Customer_Group_4__c = 'REECE'][0].get('Id');
	    PageReference pageRef = New Pagereference('/'+acc);
	    Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id',acc);

	    //Initiate Controller
	    AccountGroupSummaryController controller = new AccountGroupSummaryController();
	    
	    //************* Debug *************************************
	    system.debug('The selected account Id is: '+controller.accountIdHQ);
	    system.debug('The account details are as follows: '+controller.accountHQ);
	    //*********************************************************
		controller.getM12Hub();
		controller.getHammerClub();
		controller.getMetersDisplay();
		controller.getRedRacks();
		controller.getBudgetTotal();
		controller.getBudgetTotalCFY();
		controller.getSalesTotal();
		controller.getAContact();
		controller.getSalesAchievement();
		controller.getTotalSales();
		controller.getAccessorySales();
		controller.getToolSales();
		controller.getCategoryBreakdown();
		controller.getTop10Accessories();
		controller.getTop10Handtools();
		controller.getTop10Tools();
		controller.getMMSYTD();
		controller.getMMSLYTD();
		controller.getMMSLCY();
		controller.getMMSVariance();
		//controller.getJSSSalesYTD();
		controller.getJSSSalesLYTD();
		controller.getJSSVariance();
		controller.getJSSSalesCFY();
		controller.getJSSSalesLFY();
		controller.getTopOpenOpps();
		controller.getTopClosedOpps();
		controller.getLeadsYTD();
		controller.getLeadsLYTD();
		controller.getLeadsVariance();
		controller.getLeadsLFY();
		controller.getActivityYTD();
		controller.getActivityLYTD();
		controller.getActivityVariance();
		controller.getActivityLFY();
		controller.getAEvents();
		controller.getTainingOnline();
		controller.getTrainingHot();
		controller.getPTraining();
		controller.getPracticalYTD();
		controller.getPracticalLYTD();
		controller.getPracticalVariance();
		controller.getPracticalLCY();
		controller.getJointDealerCountYTD();
		controller.getJointDealerCountLYTD();
		controller.getJointDealerVariance();
		controller.getJointDealerCountLCY();
    }
}