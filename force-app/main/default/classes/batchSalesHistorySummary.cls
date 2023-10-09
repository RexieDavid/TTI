global class batchSalesHistorySummary implements Database.Batchable<sObject>
{
// Declare Variables *******************
    //Date Variables
    public Datetime starttime = DateTime.now(); //Job Start Time
    public Integer currentYear = System.today().year();
    public Integer previousYear = System.today().year()-1;
    public Integer currentMonth = System.today().month();
    public Integer currentDay = System.today().day();
    public Date dateCYTD = date.newInstance(currentYear,currentMonth,currentDay);
    public Date dateLYTD = date.newInstance(previousYear,currentMonth,currentDay);

    //Global Variables
    global final List<Id> accId;

// Set Query Specifics
    global batchSalesHistorySummary(List<Id> a){
        accId=a;
    }

// Start batch - Get account List ******************
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('***** START: batchSalesHistorySummary *****');

        System.debug('Account Id List: ' + accId);

        String query = 'SELECT Id, Customer_Group_4__c, Name FROM Account WHERE Id in :accId';
        return Database.getQueryLocator(query);
    }

// Batch Processing - Summarise Sales History *******************
    global void execute(Database.BatchableContext BC, List<Account> accountList)
    {
    // Declare variables
        List<AggregateResult> salesHistCYTD = new List<AggregateResult>(); //Sales History YTD
        List<AggregateResult> salesHistLYTD = new List<AggregateResult>(); //Sales History LYTD
        List<SalesHistSummary__c> shsList = new List<SalesHistSummary__c>();
        List<SalesHistSummary__c> shsSummaryList = new List<SalesHistSummary__c>();//Summarise SHSList
        // Instantiate Product Variables
        String pBrand = '';
        String pCat = '';
        String pSubCat = '';
        String pProdCat = '';
        // Loop Variables
        SalesHistSummary__c shs;


    // Get Summarised YTD Sales History for Scope Accounts (200 Block)
        salesHistCYTD = [SELECT Sold_To__c, Product__r.Brand__c, Product__r.Category__c, Product__r.Sub_Category__c, Product__r.Product_Category__c, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty 
                        FROM Sales_History__c 
                        WHERE Sold_To__c IN :accountList 
                        AND RecordType.Name = 'Sales' 
                        AND CALENDAR_YEAR(Posting_Date__c) = :currentYear 
                        AND Posting_Date__c <= :dateCYTD 
                        GROUP BY Product__r.Brand__c, Product__r.Category__c, Product__r.Sub_Category__c, Product__r.Product_Category__c, Sold_To__c];
        System.debug('Sales History CYTD:' + salesHistCYTD);
    // Get Summarised LYTD Sales History for Scope Accounts (200 Block)
        salesHistLYTD = [SELECT Sold_To__c, Product__r.Brand__c, Product__r.Category__c, Product__r.Sub_Category__c, Product__r.Product_Category__c,Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty 
                        FROM Sales_History__c 
                        WHERE Sold_To__c IN :accountList 
                        AND RecordType.Name = 'Sales' 
                        AND CALENDAR_YEAR(Posting_Date__c) = :previousYear 
                        AND Posting_Date__c <= :dateLYTD 
                        GROUP BY Product__r.Brand__c, Product__r.Category__c, Product__r.Sub_Category__c, Product__r.Product_Category__c, Sold_To__c];
        System.debug('Sales History CYTD:' + salesHistLYTD);

    // Build Sales History Summary object values for Scope Accounts (200 Block)
        for(Account a : accountList)
        {
        // DeBug
            System.debug('Account: ' + a.Name);
        // Instantiate Account Loop Variables
            Set<String> set1 = new Set<String>();

        // Summarise YTD data *****
            for (AggregateResult ar:salesHistCYTD)
            {
                if(ar.get('Sold_To__c') == a.Id)
                {
                // Instantiate shs Variables
                        shs = new SalesHistSummary__c();
                    // Set Account Id
                        shs.Account__c = a.Id;
                    // Set Account Group
                        shs.Account_Group__c = a.Customer_Group_4__c;
                    // Set RecType
                        shs.RecType__c = 'CYTD';
                    // Set Qty
                        shs.Qty__c = (Decimal)ar.get('TotalQty');
                    // Set Sales
                        shs.Sales__c = (Decimal)ar.get('TotalSales');
                    //Set Date
                        shs.DateSummarised__c = dateCYTD;
                    // Set Brand Code
                        pBrand = (String)ar.get('Brand__c');
                    // Set Category Code
                        pCat = (String)ar.get('Category__c');
                    // Set Sub Category Code
                        pSubCat = (String)ar.get('Sub_Category__c');
                    // Set Product Category Code
                        pProdCat = (String)ar.get('Product_Category__c');
                    //**********
                        //Set Product Group
                            //Brand ML
                            if (pBrand == 'ML'){
                                // Category HT
                                if(pCat == 'HT'){
                                    // Sub Category NPW
                                    if(pSubCat == 'NPW'){
                                        shs.Product_Group__c = 'Handtools';
                                    }
                                    else {
                                        shs.Product_Group__c = 'Other Tools';                                    
                                    }
                                }
                                // Category PT
                                else if(pCat == 'PT'){
                                    //Sub Category ACS
                                    if(pSubCat == 'ACS'){
                                        //Shockwave
                                        if (pProdCat == 'SBT'){
                                            shs.Product_Group__c = 'Shockwave';     
                                        }
                                        //Sawzall
                                        else if (pProdCat == 'RBL'){
                                            shs.Product_Group__c = 'Sawzall';     
                                        }
                                        //Holesaws
                                        else if (pProdCat == 'HOS' || pProdCat == 'HSK'){
                                            shs.Product_Group__c = 'Holesaws';     
                                        }
                                        //Carbide
                                        else if (pProdCat == 'SDM' || pProdCat == 'SDP' || pProdCat == 'HEX'){
                                            shs.Product_Group__c = 'Carbide';     
                                        }
                                        //Wood Drilling
                                        else if (pProdCat == 'FSA'){
                                            shs.Product_Group__c = 'Wood Drilling';     
                                        }
                                        //Other Accessories
                                        else {
                                            shs.Product_Group__c = 'Other Accessories';
                                        }
                                    }
                                    //Sub Category 12L
                                    else if(pSubCat == '12L'){
                                        shs.Product_Group__c = 'M12';
                                    }
                                    //Sub Category 18L
                                    else if(pSubCat == '18L'){
                                        shs.Product_Group__c = 'M18';
                                    }
                                    //Sub Category ACE
                                    else if(pSubCat == 'ACE'){
                                        //Hammer AC
                                        if (pProdCat == 'RHM' || pProdCat == 'DHM'){
                                            shs.Product_Group__c = 'Hammer (AC)';     
                                        }
                                        //Grinder AC
                                        else if (pProdCat == 'AGR' || pProdCat == 'DGR'){
                                            shs.Product_Group__c = 'Grinders (AC)';
                                        }
                                        //AC Other
                                        else {
                                            shs.Product_Group__c = 'Other (AC)';
                                        }
                                    }
                                    //Sub Category Other Tools
                                    else {
                                        shs.Product_Group__c = 'Other Tools';
                                    }
                                }
                                // Category Not PT or HT
                                else {
                                    shs.Product_Group__c = 'Other Tools';    
                                }
                            }
                            // If not ML
                            else {
                                shs.Product_Group__c = 'Other Tools';
                            }
                    //**********
                    // Build Reference Field
                        shs.ReferenceField__c = shs.Account__c + '-' + shs.Product_Group__c + '-' + shs.RecType__c;
                        set1.add(shs.ReferenceField__c);
                    // Add to Upsert List
                        shsList.add(shs);
                    // DeBug
                    System.debug('shs: ' + shs);
                }
            }

        // Summarise LYTD data *****
            for (AggregateResult ar:salesHistLYTD)
            {
                if(ar.get('Sold_To__c') == a.Id)
                {
                    // Instantiate shs Variables
                        shs = new SalesHistSummary__c();
                    // Set Account Id
                        shs.Account__c = a.Id;
                    // Set Account Group
                        shs.Account_Group__c = a.Customer_Group_4__c;
                    // Set RecType
                        shs.RecType__c = 'LYTD';
                    // Set Qty
                        shs.Qty__c = (Decimal)ar.get('TotalQty');
                    // Set Sales
                        shs.Sales__c = (Decimal)ar.get('TotalSales');
                    //Set Date
                        shs.DateSummarised__c = dateCYTD;
                    // Set Brand Code
                        pBrand = (String)ar.get('Brand__c');
                    // Set Category Code
                        pCat = (String)ar.get('Category__c');
                    // Set Sub Category Code
                        pSubCat = (String)ar.get('Sub_Category__c');
                    // Set Product Category Code
                        pProdCat = (String)ar.get('Product_Category__c');
                    //**********
                        //Set Product Group
                            //Brand ML
                            if (pBrand == 'ML'){
                                // Category HT
                                if(pCat == 'HT'){
                                    // Sub Category NPW
                                    if(pSubCat == 'NPW'){
                                        shs.Product_Group__c = 'Handtools';
                                    }
                                    else {
                                        shs.Product_Group__c = 'Other Tools';                                    
                                    }
                                }
                                // Category PT
                                else if(pCat == 'PT'){
                                    //Sub Category ACS
                                    if(pSubCat == 'ACS'){
                                        //Shockwave
                                        if (pProdCat == 'SBT'){
                                            shs.Product_Group__c = 'Shockwave';     
                                        }
                                        //Sawzall
                                        else if (pProdCat == 'RBL'){
                                            shs.Product_Group__c = 'Sawzall';     
                                        }
                                        //Holesaws
                                        else if (pProdCat == 'HOS' || pProdCat == 'HSK'){
                                            shs.Product_Group__c = 'Holesaws';     
                                        }
                                        //Carbide
                                        else if (pProdCat == 'SDM' || pProdCat == 'SDP' || pProdCat == 'HEX'){
                                            shs.Product_Group__c = 'Carbide';     
                                        }
                                        //Wood Drilling
                                        else if (pProdCat == 'FSA'){
                                            shs.Product_Group__c = 'Wood Drilling';     
                                        }
                                        //Other Accessories
                                        else {
                                            shs.Product_Group__c = 'Other Accessories';
                                        }
                                    }
                                    //Sub Category 12L
                                    else if(pSubCat == '12L'){
                                        shs.Product_Group__c = 'M12';
                                    }
                                    //Sub Category 18L
                                    else if(pSubCat == '18L'){
                                        shs.Product_Group__c = 'M18';
                                    }
                                    //Sub Category ACE
                                    else if(pSubCat == 'ACE'){
                                        //Hammer AC
                                        if (pProdCat == 'RHM' || pProdCat == 'DHM'){
                                            shs.Product_Group__c = 'Hammer (AC)';     
                                        }
                                        //Grinder AC
                                        else if (pProdCat == 'AGR' || pProdCat == 'DGR'){
                                            shs.Product_Group__c = 'Grinders (AC)';
                                        }
                                        //AC Other
                                        else {
                                            shs.Product_Group__c = 'Other (AC)';
                                        }
                                    }
                                    //Sub Category Other Tools
                                    else {
                                        shs.Product_Group__c = 'Other Tools';
                                    }
                                }
                                // Category Not PT or HT
                                else {
                                    shs.Product_Group__c = 'Other Tools';    
                                }
                            }
                            // If not ML
                            else {
                                shs.Product_Group__c = 'Other Tools';
                            }
                    //**********
                    // Build Reference Field
                        shs.ReferenceField__c = shs.Account__c + '-' + shs.Product_Group__c + '-' + shs.RecType__c;
                        set1.add(shs.ReferenceField__c);
                    // Add to Upsert List
                        shsList.add(shs);
                    // DeBug
                    System.debug('shs: ' + shs);
                }
            }

        // Summarise Sales History Summary by Product Category
            for (String s1: set1){
                //***** DEBUG *****
                System.debug('Set Loop:' + s1);
                //*****
                //Running Summary Variables
                Id runningAccount;
                String runningAccGroup;
                String runningRecType;
                Date runningDate;
                String runningProdGroup;
                Decimal runningQTY = 0;
                Decimal runningSales = 0;
                String runningReference;

                for (SalesHistSummary__c s :shsList){
                    If(s1 == s.ReferenceField__c){
                        runningAccount = s.Account__c;
                        runningAccGroup = s.Account_Group__c;
                        runningRecType = s.RecType__c;
                        runningDate = s.DateSummarised__c;
                        runningProdGroup = s.Product_Group__c;
                        runningQTY = runningQTY + s.Qty__c;
                        runningSales = runningSales + s.Sales__c;
                        runningReference = s.ReferenceField__c;
                    }
                }

                shs = new SalesHistSummary__c();
                // Set Account Id
                    shs.Account__c = runningAccount;
                // Set Account Group
                    shs.Account_Group__c = runningAccGroup;
                // Set RecType
                    shs.RecType__c = runningRecType;
                //Set Date
                    shs.DateSummarised__c = runningDate;
                //Set Product Group
                    shs.Product_Group__c = runningProdGroup;
                // Set Qty
                    shs.Qty__c = runningQTY;
                // Set Sales
                    shs.Sales__c = runningSales;
                // Build Reference Field
                    shs.ReferenceField__c = runningReference;

                shsSummaryList.add(shs);
                //***** DEBUG *****
                System.debug('shs: ' + shs);
            }

        }


        // Upsert Sales History Summary
        try{
            upsert shsSummaryList ReferenceField__c;    
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
        
    }

// Batch Finish - Email Details *******************
    global void finish(Database.BatchableContext BC)
    {
        Datetime endtime = DateTime.now(); //Job End Time

        //Get job details
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, 
        ExtendedStatus, ApexClass.Name, CreatedBy.Email, CreatedBy.Name
        FROM AsyncApexJob
        WHERE id = :BC.getJobId()];

        // Build msg body text
        String emailMessage = 'Your batch job ('+ a.ApexClass.Name +') has finished.\n\n'
        + 'Start Time: ' + starttime.format() + '\n'
        + 'End Time: ' + endtime.format() + '\n\n'
        + 'It executed at a total of '
        + a.TotalJobItems 
        + ' batches of which, '
        + a.JobItemsProcessed
        + ' processed and '
        + a.NumberOfErrors 
        + ' batches threw unhandled exceptions.\n';

        // Email Message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[]{a.createdBy.email,'Matthew.Armstrong@ttibrands.com.au'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('mazahir.millwala@gmail.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Sales History Summary Batch Completed');
        mail.setPlainTextBody(emailMessage);
        //mail.setHtmlBody(emailMessage);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        System.debug('***** END: batchSalesHistorySummary *****');
    }
}