@isTest // (SeeAllData=true)
private class Test_SalesBudgetTrigger {
	
	@isTest static void test_Rep_Budgets() {
        
        SalesBudgetTriggerHandler test = new SalesBudgetTriggerHandler();
        /*
		List<SalesBudget__c> repbudget_list = new List<SalesBudget__c>();

		String[] repids = new String[]{'32', '33', '138'};

		for (String i : repids) {
			SalesBudget__c rep_budget  = new SalesBudget__c();
			rep_budget.N	ame = 'IND_REP_test'+i+'_2016';
			rep_budget.RepID__c = i;
			rep_budget.Budget_Type__c = 'Rep';
			rep_budget.Budget_Year__c = '2016';
			rep_budget.Currency__c = 'AUD';
			//rep_budget.Customer_Group_Code__c = '';
			rep_budget.Customer_Group_2_Code__c = 'WA';
			//rep_budget.Customer_Group_4_Code__c = '';
			rep_budget.Sales_Office_Code__c = '6010';
			//rep_budget.Company_Code__c = '';
			rep_budget.Division__c = 'Industrial';

			rep_budget.Value_Jan__c = 100;
			rep_budget.Value_Feb__c = 200;
			rep_budget.Value_Mar__c = 300;
			rep_budget.Value_Apr__c = 400;
			rep_budget.Value_May__c = 500;
			rep_budget.Value_Jun__c = 600;
			rep_budget.Value_Jul__c = 700;
			rep_budget.Value_Aug__c = 800;
			rep_budget.Value_Sep__c = 900;
			rep_budget.Value_Oct__c = 1000;
			rep_budget.Value_Nov__c = 1100;
			rep_budget.Value_Dec__c = 1200;
			repbudget_list.add(rep_budget);
		}
 
        try{
            System.debug('Rep pre insert: ' + repbudget_list.size());
            insert repbudget_list;
            System.debug('Rep post insert: ' + repbudget_list.size());
        } catch (DmlException e){
            System.debug(e.getMessage());
        } */
	}

    /*
	@isTest static void test_Account_Budgets() {
		List<SalesBudget__c> budget_list = new List<SalesBudget__c>();

		String[] ids = new String[]{'301296', '302687', '302686'};

		for (String i : ids) {
			SalesBudget__c budget  = new SalesBudget__c();

			budget.Name = 'IND_ACCT_test'+i+'_2016';
			budget.Budget_Type__c = 'Account';
			budget.AccountID__c = i;
			
			budget.Customer_Group_Code__c = 'TAS';
			budget.Customer_Group_2_Code__c = 'Z2';
			budget.Sales_Office_Code__c = '6010';
			budget.Company_Code__c = 'BP01';

			budget.Budget_Year__c = '2016';
			budget.Currency__c = 'AUD';
			budget.Division__c = 'Industrial';
			
			budget.Value_Jan__c = 100;
			budget.Value_Feb__c = 200;
			budget.Value_Mar__c = 300;
			budget.Value_Apr__c = 400;
			budget.Value_May__c = 500;
			budget.Value_Jun__c = 600;
			budget.Value_Jul__c = 700;
			budget.Value_Aug__c = 800;
			budget.Value_Sep__c = 900;
			budget.Value_Oct__c = 1000;
			budget.Value_Nov__c = 1100;
			budget.Value_Dec__c = 1200;
			budget_list.add(budget);
		}
 
        try{
            System.debug('Account pre insert: ' + budget_list.size());
            insert budget_list;
            System.debug('Account post insert: ' + budget_list.size());
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
	}


	@isTest static void test_MajorAccount_Budgets() {
		List<SalesBudget__c> budget_list = new List<SalesBudget__c>();

		String[] states = new String[]{'VIC', 'TAS', 'SA', 'QLD', 'NSW', 'WA', 'NT'};

		for (String i : states) {
			SalesBudget__c budget  = new SalesBudget__c();

			budget.Name = 'IND_MA_TT_'+i+'_2016';
			budget.Budget_Type__c = 'Major_Account';
			budget.Budget_State__c = i;
			budget.AccountID__c = 'TTHQ';
			
			budget.Customer_Group_4_Code__c = i;
			budget.Sales_Office_Code__c = '6010';
			

			budget.Budget_Year__c = '2016';
			budget.Company_Code__c = 'BP01';
			budget.Currency__c = 'AUD';
			budget.Division__c = 'Industrial';
			
			budget.Value_Jan__c = 100;
			budget.Value_Feb__c = 200;
			budget.Value_Mar__c = 300;
			budget.Value_Apr__c = 400;
			budget.Value_May__c = 500;
			budget.Value_Jun__c = 600;
			budget.Value_Jul__c = 700;
			budget.Value_Aug__c = 800;
			budget.Value_Sep__c = 900;
			budget.Value_Oct__c = 1000;
			budget.Value_Nov__c = 1100;
			budget.Value_Dec__c = 1200;
			budget_list.add(budget);
		}
 
        try{
            System.debug('Major Account pre insert: ' + budget_list.size());
            insert budget_list;
            System.debug('Major Account post insert: ' + budget_list.size());
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
	}



	@isTest static void test_State_Budgets() {
		List<SalesBudget__c> budget_list = new List<SalesBudget__c>();

		String[] states = new String[]{'VIC', 'TAS', 'SA', 'QLD', 'NSW', 'WA', 'NT'};

		for (String i : states) {
			SalesBudget__c budget  = new SalesBudget__c();

			budget.Name = 'IND_'+i+'_2016';
			budget.Budget_Type__c = 'State';
			budget.Budget_State__c = i;
			
			budget.Customer_Group_2_Code__c = i;
			budget.Sales_Office_Code__c = '6010';
			

			budget.Budget_Year__c = '2016';
			budget.Company_Code__c = 'BP01';
			budget.Currency__c = 'AUD';
			budget.Division__c = 'Industrial';
			
			budget.Value_Jan__c = 100;
			budget.Value_Feb__c = 200;
			budget.Value_Mar__c = 300;
			budget.Value_Apr__c = 400;
			budget.Value_May__c = 500;
			budget.Value_Jun__c = 600;
			budget.Value_Jul__c = 700;
			budget.Value_Aug__c = 800;
			budget.Value_Sep__c = 900;
			budget.Value_Oct__c = 1000;
			budget.Value_Nov__c = 1100;
			budget.Value_Dec__c = 1200;
			budget_list.add(budget);
		}
 
        try{
            System.debug('State pre insert: ' + budget_list.size());
            insert budget_list;
            System.debug('State post insert: ' + budget_list.size());
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
	}

	@isTest static void test_ProductBudgets() {
		List<SalesBudget__c> budget_list = new List<SalesBudget__c>();

		String[] cats = new String[]{'M12', 'M18', 'M28', 'CORDED', 'ACC', 'SPARES', 'HAND TOOLS'};

		for (String i : cats) {
			SalesBudget__c budget  = new SalesBudget__c();

			budget.Name = 'IND_PRODUCT_' + i +  '_2016';
			budget.Budget_Type__c = 'Product';
			budget.Product_Category__c = i;
			budget.Customer_Group_2_Code__c = 'QLD';
			budget.Sales_Office_Code__c = '6010';
			

			budget.Budget_Year__c = '2016';
			budget.Company_Code__c = 'BP01';
			budget.Currency__c = 'AUD';
			budget.Division__c = 'Industrial';
			
			budget.Value_Jan__c = 100;
			budget.Value_Feb__c = 200;
			budget.Value_Mar__c = 300;
			budget.Value_Apr__c = 400;
			budget.Value_May__c = 500;
			budget.Value_Jun__c = 600;
			budget.Value_Jul__c = 700;
			budget.Value_Aug__c = 800;
			budget.Value_Sep__c = 900;
			budget.Value_Oct__c = 1000;
			budget.Value_Nov__c = 1100;
			budget.Value_Dec__c = 1200;
			budget_list.add(budget);
		}
 
        try{
            System.debug('Product pre insert: ' + budget_list.size());
            insert budget_list;
            System.debug('Product post insert: ' + budget_list.size());
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
	}
	*/
	
}