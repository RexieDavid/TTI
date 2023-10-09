/**
* @author: Matthew Armstrong
* @date: Apr 2015
* @description: This class handles logic for vf_StocktakeEditPage and vf_StocktakePrintPage page
*/ 
public class StockTakeController { 
    String Usr = UserInfo.getUserId();
    public Stocktake_Items__c[] stockitems;
    public list <Stocktake__c> UsrStock {get; set;}
    public Stocktake_Items__c stkitm  {get; set;}
    public boolean displayPopup {get; set;}     
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for closing popup
    */
    public void closePopup() {        
        displayPopup = false;  
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for adding Stocktake record
    */
    public void addNewStocktakeItem() { 
        upsert this.stkitm;
        stockitems.add(stkitm);
        closePopup();   
    }
          
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles for showing popup
    */
    public void showPopup() {
        stkitm = getStockItem();
        displayPopup = true;    
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for displaying stocktake record
    */
    public Stocktake_Items__c getStockItem(){
        stkitm = new  Stocktake_Items__c();
        
        //ADDED BY KB - 08/23/23 - Stocktake Link Issue
        stkitm.Stocktake_Link__c = UsrStock[0].Id;
        
        stkitm.On_Loan_Quantity__c = 0;
        stkitm.Stocktake_Quantity__c = 0;
        stkitm.Owner__c = UserInfo.getUserId(); 

        return stkitm;
    }

    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for getting stocktake record owned by current user
    */
    public StockTakeController() {
        UsrStock = [SELECT st.Stocktake_Identity__c, st.Date_Submitted__c, st.Submitted__c, st.Active__c, st.Id FROM Stocktake__c st WHERE st.Ownerid = :Usr  AND st.Active__c = true];
        
        this.stockitems = [ SELECT sti.Name, sti.Stocktake_Link__c, sti.Product__r.Name, sti.Product__r.SAP_MaterialNumber__c, sti.Product__r.AU_MRPty__c, sti.On_Loan_Quantity__c, sti.Stocktake_Quantity__c, sti.Stocktake_Comments__c
                            FROM Stocktake_Items__c sti WHERE sti.Owner__c = :Usr AND sti.Stocktake_Link__r.Active__c = true];  
        
        this.stkitm = getStockItem();
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for getting users inventory
    */
    public Stocktake_Items__c[] getStock() { 
        this.stockitems = [ SELECT sti.Name, sti.Stocktake_Link__c, sti.Product__r.Name, sti.Product__r.SAP_MaterialNumber__c, sti.Product__r.AU_MRPty__c, sti.On_Loan_Quantity__c, sti.Stocktake_Quantity__c, sti.Stocktake_Comments__c
                            FROM Stocktake_Items__c sti WHERE sti.Owner__c = :Usr AND sti.Stocktake_Link__r.Active__c = true];
        return this.stockitems;
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for either inserting or updating stocktake record
    */
    // Action Methods called from VF page buttons
    public pagereference submitChanges() {
        try{
            upsert this.stockitems;
        }catch(exception e){
        }
                
        if (UsrStock.size() == 1){      
            Usrstock[0].Active__c = false;
            UsrStock[0].Submitted__c = true;
            UsrStock[0].Date_Submitted__c = date.today();
            try{
                upsert UsrStock[0];
            }catch(exception e){
            }
            
            PageReference page = new Pagereference('/apex/vf_Stocktake');
            page.setRedirect(true);
            return page;
        } else {
            //Set message and redirect
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have multiple active Stocktake. Please contact your Salesforce Administrator to fix this issue.');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for creating feeditem
    */
    public void messageUser(){
        //Adding a Text post
        FeedItem post = new FeedItem();
        post.ParentId = UsrStock[0].Id; //eg. Opportunity id, custom object id..
        post.Body = 'Enter post text here';
        insert post;
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for saving stocktake record
    */
    public pagereference saveChanges() {
        try{
            upsert this.stockitems;
        }catch(exception e){
        }
        PageReference page = new Pagereference('/apex/vf_StocktakePrintPage');
        page.setRedirect(true);
        return page;
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for redirecting current page to edit page
    */
    public PageReference editChanges() {
        PageReference page = new Pagereference('/apex/vf_StocktakeEditPage');
        page.setRedirect(true);
        return page;
    }
    
    /**
    * @author: Matthew Armstrong
    * @date: Apr 2015
    * @description: This method handles logic for redirecting current page fron edit to print page
    */
    public PageReference cancelChanges() {  
        PageReference page = new Pagereference('/apex/vf_StocktakePrintPage');
        page.setRedirect(true);
        return page;
    }
}