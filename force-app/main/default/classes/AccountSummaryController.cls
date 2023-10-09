public with sharing class AccountSummaryController{
	
//Declare Variables
    //Account Deatils
      public String accountID = '';
      public Account accountItem{get;set;} //Account Details
      public String accountTTISAP = ''; //Account SAP number

    //Date Variables
      public Integer currentYear = System.today().year();
      public Integer previousYear = System.today().year()-1;
      public Integer currentMonth = System.today().month();
      public Integer currentDay = System.today().day();
      public Date dateCYTD = date.newInstance(currentYear,currentMonth,currentDay);
      public Date dateLYTD = date.newInstance(previousYear,currentMonth,currentDay);
      public Date summaryDate = System.today().addDays(-1);

    //Sales Achievement Variables
      public Decimal salesYTD;
      public Decimal budgetYTD;
    
    //Marketing Material Spending
      public Id promoFormRecID = Schema.Sobjecttype.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
      public Decimal mmsYTD;
      public Decimal mmsLYTD;

    //Budget
      public List<Sales_History__c> budgetHistYTD {get;set;} //Budget History YTD
      public List<Sales_History__c> budgetHistCFY {get;set;} //Budget History CFY

    //Sales History Summary
      public List<AggregateResult> salesHistoryCYTD = new List<AggregateResult>();
      public List<AggregateResult> salesHistoryLYTD = new List<AggregateResult>();
  
    //Training Hot
      public List<Contact> contactList{get;set;}//AccountList Contacts
      public Set<Id> trainingSessionIds{get;set;}//All Training Sessions IDs for this Account Group

      public List<TrainingSession__c> tSessionYTD {get;set;}//Training Session YTD
      public List<TrainingSession__c> tSessionLYTD {get;set;}//Training Session LYTD
      public List<TrainingSession__c> tSessionLCY {get;set;}//Training Session LCY

      public List<Event> tSesEventYTD {get;set;}//Training Session Events YTD
      public List<Event> tSesEventLYTD {get;set;}//Training Session Events LYTD
      public List<Event> tSesEventLCY {get;set;}//Training Session Events LCY

    //Product Training
      public AggregateResult ptYTD {get;set;}
      public AggregateResult ptLYTD {get;set;}
      public AggregateResult ptLCY {get;set;}
  
    //Init Wrappers
      public cTotalSales ts {get; set;} //Total Sales
      public List<gaugeData> sa {get;set;} //Sales Achievements
      public cItemTotalSales runningItem {get;set;} //Running Item Sales
      public List<cItemTotalSales> SalesACS {get;set;} //Accessories Sales
      public List<cItemTotalSales> SalesTools {get;set;} //Tools Sales
      public List<cCategoryBD> CatSalesPercent {get;set;} //Category Sales Percentage
      public List<cItemTotalSales> Top10ACS {get;set;} //Top 10 Accessories Sales
      public List<cItemTotalSales> Top10HTools {get;set;} //Top 10 Handtool Sales
      public List<cItemTotalSales> Top10Tools {get;set;} //Top 10 Tools Sales

    //Hand Tools Variables
      Decimal qryCFYHandtool = 0;
      Decimal qryLFYHandtool = 0;
      Decimal qryCFYHandtoolQTY = 0;
      Decimal qryLFYHandtoolQTY = 0;

//Constructor
    public AccountSummaryController(){
      
      list<account> accountList = new list<account>();
      
      accountID = System.currentPageReference().getParameters().get('Id');  
      
      accountList = [Select ID, Name, M12_Hub__c,TTI_SAP_Cust_No__c, Hammer_Club__c, Owner.Name, Meters_Of_Display__c, Mini_Display__c, JSS_Dealer_Referred_Sales_CFY__c, JSS_Dealer_Referred_Sales_PFY__c,Shockwave__c,Sawzall__c,Holesaws__c,Carbide__c,Wood_Drilling__c,Other_Accessories__c,Handtools__c,M12__c,M18__c,Hammer_AC__c,Grinders_AC__c,AC__c,Other_Tools__c From Account Where ID = :accountID];
      if(accountList.isEmpty() == false){
        accountItem = accountList[0];
        accountTTISAP = accountList[0].TTI_SAP_Cust_No__c;
      }else{
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Account was not found.');
        ApexPages.addMessage(msg);
      }

      // Sales History Budget Population
        budgetHistYTD = [SELECT Posting_Date__c,RecordType.Name,Product__c,Brand_Code__c,Category_Code__c,Sub_Category_Code__c,Product_Category_Code__c,Sold_To__c,Qty__c,Revenue__c,Budget__c FROM Sales_History__c WHERE Sold_To__c = :accountId AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND CALENDAR_MONTH(Posting_Date__c) <= :currentMonth];
        budgetHistCFY = [SELECT Posting_Date__c,RecordType.Name,Product__c,Brand_Code__c,Category_Code__c,Sub_Category_Code__c,Product_Category_Code__c,Sold_To__c,Qty__c,Revenue__c,Budget__c FROM Sales_History__c WHERE Sold_To__c = :accountId AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear];

      // Sales History Summary Population
      if ( [SELECT Count() FROM SalesHistSummary__c WHERE Account__c = :accountID] > 0){
        summaryDate = (Date)[SELECT DateSummarised__c FROM SalesHistSummary__c WHERE Account__c = :accountID GROUP BY DateSummarised__c ORDER BY DateSummarised__c DESC LIMIT 1][0].get('DateSummarised__c');
      }
        salesHistoryCYTD = [SELECT Product_Group__c, SUM(Qty__c) Qty, Sum(Sales__c) Sales FROM SalesHistSummary__c 
                            WHERE Account__c = :accountID AND RecType__c = 'CYTD' AND DateSummarised__c = :summaryDate
                            GROUP BY Product_Group__c];
        salesHistoryLYTD = [SELECT Product_Group__c, SUM(Qty__c) Qty, Sum(Sales__c) Sales FROM SalesHistSummary__c 
                            WHERE Account__c = :accountID AND RecType__c = 'LYTD' AND DateSummarised__c = :summaryDate
                            GROUP BY Product_Group__c];

      //Training HOT
        contactList = [SELECT Id FROM Contact WHERE AccountId = :accountID];
        //***Get all training sessions that people in this group have attended
        trainingSessionIds = new Set<Id>();
        for (AggregateResult ar:[SELECT TrainingSessionID__c tsid FROM TrainingAttendance__c WHERE TrainingAttendent__c IN :contactList GROUP BY TrainingSessionID__c]){
          trainingSessionIds.add((Id)ar.get('tsid'));
        }
        //**************************
        tSessionYTD = [SELECT Id FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :currentYear AND TrainingSessionDate__c <= :dateCYTD];
        tSessionLYTD = [SELECT Id FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :previousYear AND TrainingSessionDate__c <= :dateLYTD];
        tSessionLCY = [SELECT Id FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :previousYear];

        tSesEventYTD = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionYTD];
        tSesEventLYTD = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionLYTD];
        tSesEventLCY = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionLCY];

      //Product Training
        ptYTD = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
        ptLYTD = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD];
        ptLCY = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :previousYear];
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
//Budget from Accounts
    public Decimal getBudgetTotalYTD(){
      Decimal bud = 0;
        for (Sales_History__c b: budgetHistYTD){
          if (b.Revenue__c > 0){
            bud = bud + b.Revenue__c;
          }
        }
      return bud;
    }
    public Decimal getBudgetTotalCFY(){
      Decimal bud = 0;
        for (Sales_History__c b: budgetHistCFY){
          if (b.Revenue__c > 0){
            bud = bud + b.Revenue__c;
          }
        }
      return bud;
    }

//Sales Histories YTD
  //Total Sales LYTD vs CYTD
    public cTotalSales getTotalSales(){
      Decimal cYTD = 0;
      Decimal lYTD = 0;
      Decimal variance = 0;
      String change = 'new String';

      cYTD = (Decimal) [SELECT Sum(Revenue__c) TotalSales FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND Posting_Date__c <= :dateCYTD][0].get('TotalSales');

      lYTD = (Decimal) [SELECT Sum(Revenue__c) TotalSales FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :previousYear AND Posting_Date__c <= :dateLYTD][0].get('TotalSales');

      if (cYTD != null){
        if (lYTD != null){
          try{
            variance = ((cYTD - lYTD) / lYTD) * 100;
            } catch (Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }        
        }
      }

      change = variance.setScale(2, RoundingMode.HALF_UP) + '%';

      ts = new cTotalSales(lYTD,cYTD, Change);

      return ts;
    }

  //Total Acessories Sales LFY vs CFY
    public List<cItemTotalSales> getTotalSalesACS(){
      //Declare Variables
        SalesACS = new List<cItemTotalSales>();

        Decimal runningSalesCYTD = 0;
        Decimal runningSalesLYTD = 0;
        Decimal runningQtyCYTD = 0;
        Decimal runningQtyLYTD = 0;
        Decimal variance = 0;
        Decimal varianceQTY = 0;
        String change = 'test';

      //Shockwave Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Shockwave'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Shockwave'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Shockwave',accountItem.Shockwave__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Sawzall Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Sawzall'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Sawzall'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Sawzall',accountItem.Sawzall__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Holesaw Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Holesaws'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Holesaws'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Holesaws',accountItem.Holesaws__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Carbide Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Carbide'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Carbide'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Carbide',accountItem.Carbide__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Wood Drilling Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Wood Drilling'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Wood Drilling'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Wood Drilling',accountItem.Wood_Drilling__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Handtools Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Handtools'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Handtools'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Handtools',accountItem.Handtools__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      //Other Accessories
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Other Accessories'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Other Accessories'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Other Accessories',accountItem.Other_Accessories__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesACS.add(runningItem);

      return SalesACS;
    }

  //Total Tools Sales LFY vs CFY
    public List<cItemTotalSales> getTotalSalesTools(){
      //Declare Variables
        SalesTools = new List<cItemTotalSales>();

        Decimal runningSalesCYTD = 0;
        Decimal runningSalesLYTD = 0;
        Decimal runningQtyCYTD = 0;
        Decimal runningQtyLYTD = 0;
        Decimal variance = 0;
        Decimal varianceQTY = 0;
        String change = 'test';

      //M12 Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'M12'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'M12'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('M12',accountItem.M12__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      //M18 Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'M18'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'M18'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('M18',accountItem.M18__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      //Hammer (AC) Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Hammer (AC)'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Hammer (AC)'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Hammer (AC)',accountItem.Hammer_AC__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      //Grinders (AC) Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Grinders (AC)'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Grinders (AC)'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Grinders (AC)',accountItem.Grinders_AC__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      //AC Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Other (AC)'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Other (AC)'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Other (AC)',accountItem.AC__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      //Other Tools Sales
        runningSalesCYTD = 0;
        runningSalesLYTD = 0;
        runningQtyCYTD = 0;
        runningQtyLYTD = 0;
        variance = 0;
        varianceQTY = 0;
        change = '0%';
        
        for (AggregateResult ar: salesHistoryCYTD){
          if (ar.get('Product_Group__c') == 'Other Tools'){
            runningSalesCYTD = runningSalesCYTD + (Decimal)ar.get('Sales');
            runningQtyCYTD = runningQtyCYTD + (Decimal)ar.get('Qty');
          }
        }
        for (AggregateResult ar: salesHistoryLYTD){
          if (ar.get('Product_Group__c') == 'Other Tools'){
            runningSalesLYTD = runningSalesLYTD + (Decimal)ar.get('Sales');
            runningQtyLYTD = runningQtyLYTD + (Decimal)ar.get('Qty');
          }
        }

        if (runningSalesLYTD != 0){
          variance = ((runningSalesCYTD - runningSalesLYTD) / runningSalesLYTD) * 100;
        }
        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        varianceQTY = runningQtyCYTD - runningQtyLYTD;

        runningItem = new cItemTotalSales('Other Tools',accountItem.Other_Tools__c,runningSalesLYTD,runningSalesCYTD,change,runningQtyLYTD,runningQtyCYTD,varianceQTY,'test');
        SalesTools.add(runningItem);

      return SalesTools;
    }

  //Category Breakdown by Percentage
    public List<cCategoryBD> getCategoryBreakdown(){
      //Declare Variables
      CatSalesPercent = new List<cCategoryBD>();
      Decimal salesYTD = ts.CFY;
      Decimal salesRT = 0;
      Decimal percentage = 0;

      //If SalesYTD is null, ignor all
      if (SalesYTD != null && salesYTD != 0){
        //Calculate Accessories YTD Sales percentage
          for (cItemTotalSales acs:SalesACS){
            if (acs.Item != 'Handtools'){
              salesRT = salesRT + acs.CFY;
            }
          }
          if (salesRT != null){
              percentage = ((salesRT/salesYTD)*100).setScale(2, RoundingMode.HALF_UP);
              CatSalesPercent.add(new cCategoryBD('Accessories',salesRT, percentage, percentage + '%'));
          }
        // Calculate Handtools YTD Sales percentage
          salesRT = 0;
          percentage = 0;
          for (cItemTotalSales htool:SalesACS){
            if (htool.Item == 'Handtools'){
              salesRT = salesRT + htool.CFY;
            }
          }
          if (salesRT != null){
              percentage = ((salesRT/salesYTD)*100).setScale(2, RoundingMode.HALF_UP);
              CatSalesPercent.add(new cCategoryBD('Handtools',salesRT, percentage, percentage + '%'));
          }
        //Calculate Tool Group YTD Sales percentage
          salesRT = 0;
          percentage = 0;
          for (cItemTotalSales tools:SalesTools){
            if (tools.CFY != null){
              percentage = ((tools.CFY/salesYTD)*100).setScale(2, RoundingMode.HALF_UP);
              CatSalesPercent.add(new cCategoryBD(tools.Item,tools.CFY, percentage, percentage + '%'));
            }
          }      
      }

      return CatSalesPercent;
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Top 10 Products - Accessories & Tools

  //Top 10 Accessories
    public List<cItemTotalSales> getTop10Accessories(){
        //Declare Variables
          list<AggregateResult> qryYTD10Acc = new list<AggregateResult>();
          list<AggregateResult> qryLYTD10Acc = new list<AggregateResult>();
          
          Top10ACS = new List<cItemTotalSales>();

          String runningName;
          String runningCode;
          Decimal runningTotalYTD;
          Decimal runningTotalLYTD;
          Decimal runningTotalQtyYTD;
          Decimal runningTotalQtyLYTD;
          Decimal variance;
          Decimal varianceQTY;
          String change;

        // Query Database ****************
          qryYTD10Acc = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:currentYear AND Posting_Date__c <= :dateCYTD 
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'PT' AND Product__r.Sub_Category__c = 'ACS'
            GROUP BY Product__c, Product__r.Name,Product__r.ProductCode ORDER BY Sum(Revenue__c) DESC LIMIT 10];

          qryLYTD10Acc = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:previousYear AND Posting_Date__c <= :dateLYTD 
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'PT' AND Product__r.Sub_Category__c = 'ACS'
            GROUP BY Product__c, Product__r.Name, Product__r.ProductCode];

        //top 10 Accessories YTD & LYTD by QTY & Sales
            for (AggregateResult ar: qryYTD10Acc){
              //Clear variables
                runningName = 'test';
                runningCode = 'test';
                runningTotalYTD = 0;
                runningTotalLYTD = 0;
                runningTotalQtyYTD = 0;
                runningTotalQtyLYTD = 0;

                variance = 0;
                varianceQTY = 0;
              //***************
              runningTotalYTD = (Decimal)ar.get('TotalSales');
              runningTotalQtyYTD = (Decimal)ar.get('TotalQty');
              runningName = (String)ar.get('PName');
              runningCode = (String)ar.get('PCode');

              for (AggregateResult ar1: qryLYTD10Acc){
                if (ar.get('Product__c') == ar1.get('Product__c')){
                  runningTotalLYTD = (Decimal)ar1.get('TotalSales');
                  runningTotalQtyLYTD = (Decimal)ar1.get('TotalQty');
                }
              }
              
              if (runningTotalLYTD != 0){
                variance = ((runningTotalYTD - runningTotalLYTD) / runningTotalLYTD) * 100;
              }

              change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
              varianceQTY = runningTotalQtyYTD - runningTotalQtyLYTD;

              runningItem = new cItemTotalSales(runningName,False,runningTotalLYTD,runningTotalYTD,change,runningTotalQtyLYTD,runningTotalQtyYTD,varianceQTY,runningCode);
              Top10ACS.add(runningItem);
            }
   
          return Top10ACS;
    }

  //Top 10 Handtools
    public List<cItemTotalSales> getTop10Handtools(){
        //Declare Variables
          list<AggregateResult> qryYTD10ht = new list<AggregateResult>();
          list<AggregateResult> qryLYTD10ht = new list<AggregateResult>();
          
          Top10HTools = new List<cItemTotalSales>();

          String runningName;
          String runningCode;
          Decimal runningTotalYTD;
          Decimal runningTotalLYTD;
          Decimal runningTotalQtyYTD;
          Decimal runningTotalQtyLYTD;
          Decimal variance;
          Decimal varianceQTY;
          String change;

        // Query Database ****************
          qryYTD10ht = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:currentYear AND Posting_Date__c <= :dateCYTD
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'HT' AND Product__r.Sub_Category__c = 'NPW'
            GROUP BY Product__c, Product__r.Name,Product__r.ProductCode ORDER BY Sum(Revenue__c) DESC LIMIT 10];

          qryLYTD10ht = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:previousYear AND Posting_Date__c <= :dateLYTD
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'HT' AND Product__r.Sub_Category__c = 'NPW'
            GROUP BY Product__c, Product__r.Name, Product__r.ProductCode];

        //top 10 Accessories YTD & LYTD by QTY & Sales
            for (AggregateResult ar: qryYTD10ht){
              //Clear variables
                runningName = 'test';
                runningCode = 'test';
                runningTotalYTD = 0;
                runningTotalLYTD = 0;
                runningTotalQtyYTD = 0;
                runningTotalQtyLYTD = 0;

                variance = 0;
                varianceQTY = 0;
              //***************
              runningTotalYTD = (Decimal)ar.get('TotalSales');
              runningTotalQtyYTD = (Decimal)ar.get('TotalQty');
              runningName = (String)ar.get('PName');
              runningCode = (String)ar.get('PCode');

              for (AggregateResult ar1: qryLYTD10ht){
                if (ar.get('Product__c') == ar1.get('Product__c')){
                  runningTotalLYTD = (Decimal)ar1.get('TotalSales');
                  runningTotalQtyLYTD = (Decimal)ar1.get('TotalQty');
                }
              }
              
              if (runningTotalLYTD != 0){
                variance = ((runningTotalYTD - runningTotalLYTD) / runningTotalLYTD) * 100;
              }

              change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
              varianceQTY = runningTotalQtyYTD - runningTotalQtyLYTD;

              runningItem = new cItemTotalSales(runningName,False,runningTotalLYTD,runningTotalYTD,change,runningTotalQtyLYTD,runningTotalQtyYTD,varianceQTY,runningCode);
              Top10HTools.add(runningItem);
            }
   
          return Top10HTools;
    }

  //Top 10 Tools
    public List<cItemTotalSales> getTop10PowerTools(){
        //Declare Variables
          list<AggregateResult> qryYTD10Tool = new list<AggregateResult>();
          list<AggregateResult> qryLYTD10Tool = new list<AggregateResult>();
          
          Top10Tools = new List<cItemTotalSales>();
          
          String runningName;
          String runningCode;
          Decimal runningTotalYTD;
          Decimal runningTotalLYTD;
          Decimal runningTotalQtyYTD;
          Decimal runningTotalQtyLYTD;
          Decimal variance;
          Decimal varianceQTY;
          String change;

        // Query Database ****************
          qryYTD10Tool = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:currentYear AND Posting_Date__c <= :dateCYTD 
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'PT' AND Product__r.Sub_Category__c != 'ACS'
            GROUP BY Product__c, Product__r.Name, Product__r.ProductCode ORDER BY Sum(Revenue__c) DESC LIMIT 10];

          qryLYTD10Tool = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:previousYear AND Posting_Date__c <= :dateLYTD 
            AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'PT' AND Product__r.Sub_Category__c != 'ACS'
            GROUP BY Product__c, Product__r.Name, Product__r.ProductCode];

        //Top 10 tools YTD & LYTD by QTY & Sales
            for (AggregateResult ar: qryYTD10Tool){
              //Clear variables
                runningName = 'test';
                runningCode = 'test';
                runningTotalYTD = 0;
                runningTotalLYTD = 0;
                runningTotalQtyYTD = 0;
                runningTotalQtyLYTD = 0;
                variance = 0;
                varianceQTY = 0;
              //***************
              runningTotalYTD = (Decimal)ar.get('TotalSales');
              runningTotalQtyYTD = (Decimal)ar.get('TotalQty');
              runningName = (String)ar.get('PName');
              runningCode = (String)ar.get('PCode');

              for (AggregateResult ar1: qryLYTD10Tool){
                if (ar.get('Product__c') == ar1.get('Product__c')){
                  runningTotalLYTD = (Decimal)ar1.get('TotalSales');
                  runningTotalQtyLYTD = (Decimal)ar1.get('TotalQty');
                }
              }
              
              if (runningTotalLYTD != 0){
                variance = ((runningTotalYTD - runningTotalLYTD) / runningTotalLYTD) * 100;
              }

              change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
              varianceQTY = runningTotalQtyYTD - runningTotalQtyLYTD;

              runningItem = new cItemTotalSales(runningName,False,runningTotalLYTD,runningTotalYTD,change,runningTotalQtyLYTD,runningTotalQtyYTD,varianceQTY,runningCode);
              Top10Tools.add(runningItem);
            }
      
        return Top10Tools;
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Marketing Material Spending (TTI Promo Forms)
    //Get YTD Promo Form value
      public Decimal getMMSYTD(){
        mmsYTD = (Decimal)[SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c = :accountID AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :currentYear AND Date_Approved__c <= :dateCYTD][0].get('Spending');

        return mmsYTD;
      }
    //Get LYTD Promo Form value
      public Decimal getMMSLYTD(){
        mmsLYTD = (Decimal)[SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c = :accountID AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :previousYear AND Date_Approved__c <= :dateLYTD][0].get('Spending');

        return mmsLYTD;
      }
    //Get LCY Promo Form value
      public Decimal getMMSLCY(){
        Decimal mmsLCY = (Decimal)[SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c = :accountID AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :previousYear][0].get('Spending');

        return mmsLCY;
      }
    //Get Promo Form variance
      public Decimal getMMSVariance(){
        Decimal variance = 0;

        if (mmsLYTD != null && mmsLYTD != 0){
          if (mmsYTD != null){
            variance = (mmsYTD / mmsLYTD) * 100;
          }
        }

        return variance;
      }

//Sales Achievememt
    public List<gaugeData> getSalesAchievement(){
      Decimal achievememt = 100;
      sa = new list<gaugeData>();

      salesYTD = (Decimal) [SELECT Sum(Revenue__c) TotalSales FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) =:currentYear AND Posting_Date__c <= :dateCYTD][0].get('TotalSales');
      //budgetYTD = (Decimal) [SELECT Sum(Revenue__c) TotalSales FROM Sales_History__c WHERE Sold_To__c =:accountID AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) =:currentYear AND CALENDAR_MONTH(Posting_Date__c) <=:currentMonth][0].get('TotalSales');
      budgetYTD = getBudgetTotalYTD();

      if (budgetYTD != null){
        if (salesYTD != null){
          if (budgetYTD != 0){
            try{
              achievememt = ((salesYTD/budgetYTD) * 100).setScale(2, RoundingMode.HALF_UP);
              } catch (Exception e){
                  System.debug('The following exception has occurred: ' + e.getMessage());
              }
          }
        }
      }
      sa.add(new gaugeData('Sales Achievememt YTD',achievememt));
      return sa;
    }

//Account Contacts
    public List<Contact> getAContact(){
      list<Contact> c = new list<Contact>(); //Contact List
      c = [SELECT Id, Name, Title, Trade__c, Email, Record_Status__c FROM Contact WHERE AccountId = :accountID AND Record_Status__c = 'Active'];
      return c;
    }

//JSS Information

    public List<Opportunity> getAOpps(){
      list<Opportunity> o = new list<Opportunity>(); //Opportunity List
      o = [SELECT Amount, CloseDate, IsClosed, AccountId, Account.Name, Name, StageName, IsWon, Retailer__c, Owner.Name FROM Opportunity WHERE Retailer__c = :accountID AND IsClosed = False ORDER BY CloseDate ASC];
      return o;
    }

    public Decimal getJSSSalesYTD(){
      Decimal salesJSScYTD = 0;
      
      salesJSScYTD = (Decimal)[SELECT SUM(Amount) TotalSales FROM Opportunity WHERE Retailer__c = :accountID AND IsWon = True AND CALENDAR_YEAR(CloseDate) = :currentYear AND CloseDate <= :dateCYTD][0].get('TotalSales');

      return salesJSScYTD;
    }

    public Decimal getJSSSalesLYTD(){
      Decimal salesJSSlYTD = 0;
      
      salesJSSlYTD = (Decimal)[SELECT SUM(Amount) TotalSales FROM Opportunity WHERE Retailer__c = :accountID AND IsWon = True AND CALENDAR_YEAR(CloseDate) = :previousYear AND CloseDate <= :dateLYTD][0].get('TotalSales');

      return salesJSSlYTD;
    }

    public Decimal getJSSVariance(){
      Decimal variance=100;
      Decimal jssSalesYTD = getJSSSalesYTD();
      Decimal jssSalesLYTD = getJSSSalesLYTD();
      
      if (jssSalesLYTD != null){
        if (jssSalesYTD != null){
          if (jssSalesLYTD != 0){
            try{
              variance = (((jssSalesYTD-jssSalesLYTD)/jssSalesLYTD)*100).setScale(2, RoundingMode.HALF_UP);
            } catch (Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
              }
          }
        }
      }
      return variance;
    }

//Leads
    public List<Lead> getALeads(){
      list<Lead> l = new list<Lead>(); //Lead List
      l = [SELECT Company, IsConverted, Email, Name, LeadSource, Status, Preferred_Retailer__c, Owner.Name FROM Lead WHERE Preferred_Retailer__c = :accountID AND IsConverted = False];
      return l;
    }

//Activity History
    //Last 10 Activiites
    public List<Event> getAEvents(){
      list<Event> e = new list<Event>(); //Event List (Limit 10 records)
      e = [SELECT AccountId, Joint_Call_w_Dealer_Rep__c, Ride_Days_with_Staff__c, Subject, Type_IND__c, ActivityDate, RecordType.Name, Objective__c, Outcome__c, Owner.Name FROM Event WHERE AccountId = :accountID AND ActivityDate <= :dateCYTD ORDER BY ActivityDate DESC LIMIT 10];
      return e;
    }

    //Count of Activities YTD
    public Integer getEventSizeYTD(){
      list<Event> es = new list<Event>(); //Event Size
      es = [SELECT Id FROM Event WHERE AccountId = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
      return es.size();
    }

    //Count of Activities LYTD
    public Integer getEventSizeLYTD(){
      list<Event> es = new list<Event>(); //Event Size
      es = [SELECT Id FROM Event WHERE AccountId = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD];
      return es.size();
    }

//Training Information
  //Learn & Earn Contacts
    public List<Contact> getLNEContact(){
      list<Contact> lec = new list<Contact>(); //Learn & Earn Contact List
      lec = [SELECT Name, LNE_AdjScore__c, LNE_AvgScore__c, LNE_Attempts__c, LNE_Completed__c FROM Contact WHERE AccountId = :accountID AND Record_Status__c = 'Active' AND LNE_Attempts__c >= 1];
      return lec;
    }

  //Product Training ASM
    public List<Event> getAEventPTraining(){
      list<Event> et = new list<Event>(); //Event Product Training
      et = [SELECT AccountId, Id, ActivityDate, On_Behalf_Of__c, Act_sub_type_Industrial__c, Type_IND__c, Objective__c, Outcome__c, Subject, DurationInMinutes FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId= :accountID AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
      return et;
    }

  //Training Attendance
    public list<TrainingAttendance__c> getTrainingAttendanceYTD(){
      list<TrainingAttendance__c> ta = new list<TrainingAttendance__c>();
      ta = [SELECT Course_Name__c, Training_Session_Name__c, ContactAccountID__c, TrainingAttendent__r.Name, TrainingSessionID__r.TrainingSessionDate__c, Score__c, Attend__c FROM TrainingAttendance__c WHERE ContactAccountID__c = :accountID AND CALENDAR_YEAR(TrainingSessionID__r.TrainingSessionDate__c) = :currentYear];
      return ta;
    }

  //Practical Training
    //Practical YTD
      public Decimal getPracticalYTD(){
        Decimal total=0;
        Decimal th=0; //Training Hot Duration
        Decimal pt=0; //Training Product Duration

        for (Event e :tSesEventYTD){
          if (e.DurationInMinutes != null){
            th = th + (Decimal)e.DurationInMinutes;
          }
        }
        
        if (ptYTD.get('duration') != null){
          pt = (Decimal)ptYTD.get('duration');
        }
        total = ((th+pt)/60).setScale(2, RoundingMode.HALF_UP);
        return total;
      }
    //Practical LYTD
      public Decimal getPracticalLYTD(){
        Decimal total=0;
        Decimal th=0; //Training Hot Duration
        Decimal pt=0; //Training Product Duration

        for (Event e :tSesEventLYTD){
          if (e.DurationInMinutes != null){
            th = th + (Decimal)e.DurationInMinutes;
          }
        }
        if (ptLYTD.get('duration') != null){
          pt = (Decimal)ptLYTD.get('duration');
        }

        total = ((th+pt)/60).setScale(2, RoundingMode.HALF_UP);
        return total;
      }
    //Practical Variance
      public Decimal getPracticalVariance(){
        Decimal variance=0;
        Decimal ytd = getPracticalYTD();
        Decimal lytd = getPracticalLYTD();
        
        if (lytd != null){
          if (ytd != null){
            if (lytd != 0){
              try{
                variance = (((ytd-lytd)/lytd)*100).setScale(2, RoundingMode.HALF_UP);
              } catch (Exception e){
                  System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
          }
        }
        return variance;
      }
    //Practical LCY
      public Decimal getPracticalLCY(){
        Decimal total=0;
        Decimal th=0; //Training Hot Duration
        Decimal pt=0; //Training Product Duration

        for (Event e :tSesEventLCY){
          if (e.DurationInMinutes != null){
            th = th + (Decimal)e.DurationInMinutes;
          }
        }
        if (ptLCY.get('duration') != null){
          pt = (Decimal)ptLCY.get('duration');
        }
        total = ((th+pt)/60).setScale(2, RoundingMode.HALF_UP);
        return total;
      }

//Joint Dealer Calls
  //Joint Dealer Calls Count YTD
    public Integer getJointDealerCountYTD(){
      list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
      ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
      return ejdc.size();
    }
  //Joint Dealer Calls Count LYTD
    public Integer getJointDealerCountLYTD(){
      list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
      ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD];
      return ejdc.size();
    }
  //Joint Dealer Calls Variance
    public Decimal getJointDealerVariance(){
      Decimal variance=0;
      Decimal ytd = getJointDealerCountYTD();
      Decimal lytd = getJointDealerCountLYTD();
      
      if (lytd != null){
        if (ytd != null){
          if (lytd != 0){
            try{
              variance = (((ytd-lytd)/lytd)*100).setScale(2, RoundingMode.HALF_UP);
            } catch (Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
              }
          }
        }
      }
      return variance;
    }
  //Joint Dealer Calls Count LCY
    public Decimal getJointDealerCountLCY(){
      list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
      ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :previousYear];
      return ejdc.size();
    }

  //List of End Users
    public Set<String> getEndUsers(){
      list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
      ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c = :accountID AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
      Set<String> UniqueAcc = new Set<String>();
      for (Event evt: ejdc){
        UniqueAcc.add(evt.Account.Name);
      }
      return UniqueAcc;
    }

//#######################################################################################
//Wrapper Class for Total Sales History
  public class cTotalSales {
    public Decimal LFY {get; set;}
    public Decimal CFY {get; set;}
    public String Variance {get; set;}
    public cTotalSales (Decimal a, Decimal b, String c){
      this.LFY=a;
      this.CFY=b;
      this.Variance=c;
    }
  }

//Wrapper Class for Item Sales History
  public class cItemTotalSales {
    public String Item {get;set;}
    public Boolean Support {get;set;}
    public Decimal LFY {get; set;}
    public Decimal CFY {get; set;}
    public String Variance {get; set;}
    public Decimal qtyLYTD {get;set;}
    public Decimal qtyYTD {get;set;}
    public Decimal qtyVariance {get;set;}
    public String itemcode {get;set;}
    public cItemTotalSales (String a, Boolean b, Decimal c, Decimal d, String e, Decimal f, Decimal g, Decimal h, String i){
      this.Item=a;
      this.Support=b;
      this.LFY=c;
      this.CFY=d;
      this.Variance=e;
      this.qtyLYTD=f;
      this.qtyYTD=g;
      this.qtyVariance=h;
      this.itemcode = i;
    }
  }

//Wrapper Class for Category Percentage
  public class cCategoryBD {
    public String category {get; set;}
    public Decimal value {get; set;}
    public Decimal percent {get; set;}
    public String percentage {get; set;}
    public cCategoryBD (String a, Decimal b, Decimal c, String d){
      this.category=a;
      this.value=b;
      this.percent=c;
      this.percentage=d;
    }
  }

//Wrapper Class for Gauge Object
  public class gaugeData {
    public String name { get; set; }
    public Decimal value { get; set; }
    public gaugeData(String a, Decimal b) {
        this.name = a;
        this.value = b;
    }
  }
  

}