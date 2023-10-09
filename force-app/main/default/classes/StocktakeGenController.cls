public with sharing class StocktakeGenController {
    //Class Variables
    public String usr = UserInfo.getUserId();
    public String usrProfile = UserInfo.getProfileId();
    public Integer bulkYr { get; set; } //Year for Bulk gen
    public String bulkQtr { get; set; } //Qtr for Bulk gen
    public Integer activeST { get; set; } 
    //Section render variables
    public boolean admin { get; set; } //variable for pg section render
    public boolean userRun { get; set; } //variable for pg section render
    public boolean userGen { get; set; } //variable for pg section render
    //Lists for user stock generation
    public List<Inventory__c> usrInventory { get; set; } //users inventory
    public List<Stocktake__c> usrStock { get; set; } 
    public List<Stocktake_Items__c> newUsrStockItem = new List<Stocktake_Items__c>(); //User new stocktake items
    //Lists for Bulk stock generation
    public List<Stocktake__c> bulkLookupST { get; set; } //Find existing Stocktake with bulk variables bulkQtr-bulkYr
    
    //Class Constructor
    public StocktakeGenController() {
        //Show Page Sections
        if (usrProfile == [SELECT Id FROM Profile WHERE Name = '~System Administrator'].Id) { //if '~System Administrator' profile
            admin = true; //variable for pg section render
            userRun = true; //variable for pg section render
            userGen = true; //variable for pg section render
        } else {
            admin = false; //variable for pg section render
            userRun = true; //variable for pg section render
            userGen = true; //variable for pg section render
        }
        
        //Year for Bulk gen
        bulkYr = Date.Today().Year();
        
        //Collect running user's active stocktake
        System.debug('DBG: CONTROLLER QUERY START');
        this.usrStock = [SELECT 
                             st.Stocktake_Identity__c,
                             st.Due_Date__c,
                             st.Name
                         FROM Stocktake__c st 
                         WHERE st.Ownerid = :usr AND st.Active__c = true];
        System.debug('DBG: CONTROLLER QUERY END');
        activeST = usrStock.size();
    }
    
    //Drop-down options for admin on Bulk Generation
    public List<SelectOption> getQtr() {
        List<SelectOption> qtrOptions = new List<SelectOption>();

        qtrOptions.add(new SelectOption('QTR1', 'QTR1'));
        qtrOptions.add(new SelectOption('QTR2', 'QTR2'));
        qtrOptions.add(new SelectOption('QTR3', 'QTR3'));
        qtrOptions.add(new SelectOption('QTR4', 'QTR4'));

        return qtrOptions;
    }

    //Generate User New
    public void GenNew() {
        //if no active stocktake *RUN CODE*
        if (activeST == 0) {
            //Create new Stocktake
            User usrNum = [SELECT TTI_SAP_Cust_No__c FROM User WHERE Id = :usr];
            Stocktake__c st = new Stocktake__c();
            st.Active__c = true;
            st.Due_Date__c = Date.today().addDays(14);

            //Check Unique Stocktake Identity
            String likeqry = usrNum.TTI_SAP_Cust_No__c+'-'+ Date.Today().Day() + Date.Today().Month()+'-'+Date.Today().Year() + '%';
            bulkLookupST = [SELECT Name, Stocktake_Identity__c FROM Stocktake__c WHERE IsDeleted = false AND Stocktake_Identity__c like :likeqry];
            if (bulkLookupST.size() >= 1) {
                st.Stocktake_Identity__c = usrNum.TTI_SAP_Cust_No__c+'-'+ Date.Today().Day() + Date.Today().Month()+'-'+Date.Today().Year() +'-V'+bulkLookupST.size();
            } else {
                st.Stocktake_Identity__c = usrNum.TTI_SAP_Cust_No__c+'-'+ Date.Today().Day() + Date.Today().Month()+'-'+Date.Today().Year();
            }

            st.OwnerId = usr;
            insert st;
            activeST = 1; //Update Active Stocktake count
            //Create new StockItems
                //Get User's Active Inventory Items
                usrInventory = [SELECT User_Account__c, Status__c, Quantity__c, Qty_On_Loan__c, Product__c, OwnerId, IsDeleted, Id FROM Inventory__c WHERE OwnerId = :usr AND Status__c = 'Active'];
                if (usrInventory != null) {
                    newUsrStockItem.clear();
                    
                    for (Inventory__c ui:usrInventory) {
                        Stocktake_Items__c sti = new Stocktake_Items__c();
                        sti.Stocktake_Link__c = st.Id;
                        sti.Product__c = ui.Product__c;
                        sti.Owner__c = usr;
                        sti.SAP_Quantity__c = ui.Quantity__c;
                        sti.On_Loan_Quantity__c = ui.Qty_On_Loan__c;
                        newUsrStockItem.add(sti);
                    }

                    insert newUsrStockItem;
                }
            
            //Set message and redirect
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'New stocktake has been created, to open click: <b><a href="/apex/vf_StocktakeEditPage" target="_blank">'+st.Stocktake_Identity__c+'</a></b>');
            //ApexPages.addMessage(myMsg);
            userRun = false;
            userGen = false;                
        }
        //if one active stocktake
        else if (activeST == 1) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You already have an active Stocktake. Can not create a new stocktake.');
            //ApexPages.addMessage(myMsg);
        }
        //if two or more active stocktake
        else if (activeST >= 2) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have multiple active Stocktake. Please contact your Salesforce Administrator to fix this issue.');
            //ApexPages.addMessage(myMsg);
        }
    }
    
    //Go to active stocktake
    public PageReference runStocktake() {
        PageReference pg = new PageReference('/apex/vf_Stocktake');

        //if one active stocktake *RUN CODE*
        if (activeST == 1) {
            pg = new PageReference('/apex/vf_StocktakeEditPage');
            pg.setRedirect(true);
        }
        //if no active stocktake
        if (activeST == 0) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have any active Stocktake. Create a new Stocktake or contact your Salesforce Administrator.');
            //ApexPages.addMessage(myMsg);
        }
        
        //if two or more active stocktake
        if (activeST >= 2) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have multiple active Stocktake. Please contact your Salesforce Administrator to fix this issue.');
            //ApexPages.addMessage(myMsg);
        }

        return pg;
    }
    
    //Bulk Generate
    public void bulkGen() {

        // Find existing Stocktake with bulk variables bulkQtr-bulkYr 
        String likeqry = '%' + bulkQtr + '-' + bulkYr;
        System.debug('blkQtr ' + bulkQtr);
        List<Stocktake__c> bulkLookupST = [SELECT Name, Stocktake_Identity__c FROM Stocktake__c WHERE IsDeleted = false AND Stocktake_Identity__c LIKE :likeqry];

        ApexPages.Message myMsg;
        if (bulkLookupST.size() >= 1) {
            
            // If records found for Generating Quarter
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Stocktake have been found for this Quarter. Please check if stocktake has been previously run for: ' + bulkQtr + '-' + bulkYr + ' (Total records found:' + bulkLookupST.size() + ')');

        } else {
            
            BulkGenerateStocktakeRecordsAsyncQ bulkGenerateJob = new BulkGenerateStocktakeRecordsAsyncQ(bulkQtr, bulkYr);
            Id jobID = System.enqueueJob(bulkGenerateJob);

            myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Bulk stocktake generation runs a bit longer than the other processes. We are processing it for you right now. We\'ll send you an email once done. Thank you.');

        }

        ApexPages.addMessage(myMsg);

    }
}