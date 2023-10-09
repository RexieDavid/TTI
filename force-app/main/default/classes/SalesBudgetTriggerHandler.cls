public class SalesBudgetTriggerHandler extends TriggerHandler { 
   /* 
    private Map<String, Id> recordtype_map = new Map<String, Id>();
    private Map<String,String> user_map = new Map<String, ID>();
    private Map<String,Id> account_map = new Map<String, Id>();
    private List<Sales_History__c> sales_histories = new List<Sales_History__c>();
    private String div = 'IND';
    private List<String> months = new List<String> { '','Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' };
    */

    public SalesBudgetTriggerHandler() {
        /*
        //this.setMaxLoopCount(1);
        List<User> usrs = [Select Id, SRC_RepID__c From User WHERE SRC_RepID__c != null AND IsActive = true ];
        for ( User usr:usrs  ){
                user_map.put( usr.SRC_RepID__c, usr.id);
        }

        
        // Get the RecordTypes and map
        List<RecordType> recordtypes = [Select DeveloperName, Id From RecordType WHERE SobjectType = 'Sales_History__c' OR SobjectType = 'SalesBudget__c'];        
        for ( RecordType rcd:recordtypes  ){
           recordtype_map.put( rcd.DeveloperName, rcd.Id);  
        }

        List<Account> accts = [Select TTI_SAP_Cust_No__c, Id From Account WHERE TTI_SAP_Cust_No__c != null];
        for ( Account act:accts  ){
           account_map.put( act.TTI_SAP_Cust_No__c, act.Id);  
        }

    
    }// END CONSTRUCTOR
      
      public override void afterInsert() {

        for(SalesBudget__c budget: (List<SalesBudget__c>) Trigger.new) {

            if(budget.Division__c == 'Consumer') div = 'CON';

            if(budget.RecordTypeID != this.recordtype_map.get('JSS_Key_Account')){
        
                for(Integer i = 1; i <= 12; i++){
                    Sales_History__c sh = new Sales_History__c();


                    // --------------  REP BUDGET ----------------------------
                    if(budget.Budget_Type__c == 'Rep'){
                        sh.Name = div + '_' + budget.Customer_Group_2_Code__c + '_FY' + budget.Budget_Year__c + '_REP' + budget.RepID__c + '_' + months[i];
                        if(this.recordtype_map.containsKey('Target_Rep')) sh.RecordTypeID = this.recordtype_map.get('Target_Rep');             
                        if(user_map.containsKey(budget.RepID__c))  sh.OwnerId  = user_map.get(budget.RepID__c);
                    }

                    // --------------  ACCOUNT BUDGET ----------------------------
                    if(budget.Budget_Type__c == 'Account'){
                        sh.Name =  div + '_' + budget.AccountID__c + '_FY' + budget.Budget_Year__c + '_' + months[i]; 
                        if(this.recordtype_map.containsKey('Target_Custno')) sh.RecordTypeID = this.recordtype_map.get('Target_Custno'); 
                        if(account_map.containsKey(budget.AccountID__c))  sh.Sold_To__c  = account_map.get(budget.AccountID__c);                 
                    }

                    // --------------  STATE BUDGET ----------------------------
                    if(budget.Budget_Type__c == 'State'){
                        sh.Name =  div + '_' + budget.Budget_State__c + '_FY' + budget.Budget_Year__c + '_' + months[i];
                        if(this.recordtype_map.containsKey('Target_State')) sh.RecordTypeID = this.recordtype_map.get('Target_State');             
                        
                    }

                    // --------------  PRODUCT BUDGET ----------------------------
                    if(budget.Budget_Type__c == 'Product'){
                        sh.Name =  div + '_' + budget.Product_Category__c + '_FY' + budget.Budget_Year__c + '_' + months[i];
                        if(this.recordtype_map.containsKey('Target_Product')) sh.RecordTypeID = this.recordtype_map.get('Target_Product');  
                        sh.Brand_Code__c            = budget.Brand_Code__c;
                        sh.Category_Code__c         = budget.Category_Code__c;     
                        sh.Sub_Category_Code__c     = budget.Sub_Category_Code__c;
                    }

                    // --------------  MAJOR ACCOUNT BUDGET ----------------------------
                    if(budget.Budget_Type__c == 'Major_Account'){
                        sh.Name =  div + '_' + budget.AccountID__c +'_' + budget.Budget_State__c + '_FY' + budget.Budget_Year__c + '_' + months[i];
                        if(this.recordtype_map.containsKey('Target_Major_Account')) sh.RecordTypeID = this.recordtype_map.get('Target_Major_Account');             
                        if(account_map.containsKey(budget.AccountID__c))  sh.Sold_To__c  = account_map.get(budget.AccountID__c); 
                    }

                    sh.Sales_Office_Code__c     = budget.Sales_Office_Code__c;
                    sh.Company_Code__c          = budget.Company_Code__c;
                    sh.Currency__c              = budget.Currency__c;
                    sh.Customer_Group_Code__c   = budget.Customer_Group_Code__c;
                    sh.Customer_Group_2_Code__c = budget.Customer_Group_2_Code__c;
                    sh.Customer_Group_4_Code__c = budget.Customer_Group_4_Code__c;
                    sh.Posting_Date__c          = date.newinstance(Integer.valueOf(budget.Budget_Year__c), Integer.valueOf(i), 14);

                    if(i == 1) sh.Revenue__c    = budget.Value_Jan__c;
                    if(i == 2) sh.Revenue__c    = budget.Value_Feb__c;
                    if(i == 3) sh.Revenue__c    = budget.Value_Mar__c;
                    if(i == 4) sh.Revenue__c    = budget.Value_Apr__c;
                    if(i == 5) sh.Revenue__c    = budget.Value_May__c;
                    if(i == 6) sh.Revenue__c    = budget.Value_Jun__c;
                    if(i == 7) sh.Revenue__c    = budget.Value_Jul__c;
                    if(i == 8) sh.Revenue__c    = budget.Value_Aug__c;
                    if(i == 9) sh.Revenue__c    = budget.Value_Sep__c;
                    if(i == 10) sh.Revenue__c   = budget.Value_Oct__c;
                    if(i == 11) sh.Revenue__c   = budget.Value_Nov__c;
                    if(i == 12) sh.Revenue__c   = budget.Value_Dec__c;
                    
                     sales_histories.add(sh);
                }
            }
      
         }
         
         if(!sales_histories.isEmpty()){upsert sales_histories;}
             
      }// END METHOD

      public override void beforeInsert() {
        for(SalesBudget__c budget: (List<SalesBudget__c>) Trigger.new) {

            if(budget.Product_Category__c != null){
                if(budget.Division__c == 'Industrial'){

                    budget.Brand_Code__c = 'ML';

                    if(budget.Product_Category__c == 'M12'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = '12L';
                    } 
                    else if(budget.Product_Category__c == 'M18'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = '18L';
                    } 
                    else if(budget.Product_Category__c == 'M28'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = '28L';
                    } 
                    else if(budget.Product_Category__c == 'CORDED'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = 'ACE';
                    } 
                    else if(budget.Product_Category__c == 'ACC'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = 'ACS';
                    } 
                    else if(budget.Product_Category__c == 'SPARES'){
                        budget.Category_Code__c = 'PT';     
                        budget.Sub_Category_Code__c = 'SPT';
                    } 
                    else if(budget.Product_Category__c == 'HAND TOOLS'){
                        budget.Category_Code__c = 'HT';     
                    }

                } 
            }

            if(budget.Budget_Type__c == 'Rep'){
                if(this.recordtype_map.containsKey('Rep_Sales_Budget')) budget.RecordTypeID = this.recordtype_map.get('Rep_Sales_Budget');             
            }

                // --------------  ACCOUNT BUDGET ----------------------------
            if(budget.Budget_Type__c == 'Account'){
                if(this.recordtype_map.containsKey('Account_Sales_Budget')) budget.RecordTypeID = this.recordtype_map.get('Account_Sales_Budget');                
            }

                // --------------  STATE BUDGET ----------------------------
            if(budget.Budget_Type__c == 'State'){
                if(this.recordtype_map.containsKey('State_Sales_Budget')) budget.RecordTypeID = this.recordtype_map.get('State_Sales_Budget');             
                    
            }

                // --------------  PRODUCT BUDGET ----------------------------
            if(budget.Budget_Type__c == 'Product'){
                if(this.recordtype_map.containsKey('Product_Budget')) budget.RecordTypeID = this.recordtype_map.get('Product_Budget');  
            }

                // --------------  MAJOR ACCOUNT BUDGET ----------------------------
            if(budget.Budget_Type__c == 'Major_Account'){
                if(this.recordtype_map.containsKey('Major_Account_Budget')) budget.RecordTypeID = this.recordtype_map.get('Major_Account_Budget');             
            }

        }*/
      }
    
} // END CLASS