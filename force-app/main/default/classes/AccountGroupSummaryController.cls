public with sharing class AccountGroupSummaryController {

//Declare Variables
    //Account Deatils
    public String accountIdHQ;
    public Id recTypeHQ = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Head Office Account').getRecordTypeId();
    public Account accountHQ { get; set; } //HQ Account Details
    public String group4 = '';
    public List<Account> accountList { get; set; } //Child Accounts for HQ
    public Integer groupCount { get; set; }

    //Marketing Material Spending
    public Id promoFormRecID = Schema.Sobjecttype.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
    public Decimal mmsYTD;
    public Decimal mmsLYTD;

    //Date Variables
    public Integer currentYear = System.today().year();
    public Integer previousYear = System.today().year() - 1;
    public Integer currentMonth = System.today().month();
    public Integer currentDay = System.today().day();
    public Date dateCYTD = date.newInstance(currentYear, currentMonth, currentDay);
    public Date dateLYTD = date.newInstance(previousYear, currentMonth, currentDay);
    public Date summaryDate = System.today();

    //Sales History
    public List<AggregateResult> salesHistYTD { get; set; } //Sales History YTD
    public List<AggregateResult> salesHistLYTD { get; set; } //Sales History LYTD

    public Decimal budgetHistYTD = 0; //Budget History YTD
    public Decimal budgetHistCFY = 0; //Budget History CFY
    public Decimal budgetHistLYTD = 0; //Budget History LYTD

    //Init Wrappers
    public cTotalSales ts { get; set; } //Total Sales
    public List<cItemTotalSales> salesACS { get; set; } //Accessory Sales
    public List<cItemTotalSales> salesTool { get; set; } //Tool Sales
    public List<cItemTotalSales> top10ACS { get; set; } //Top 10 Accessories Sales
    public List<cItemTotalSales> top10HTool { get; set; } //Top 10 Accessories Sales
    public List<cItemTotalSales> top10Tool { get; set; } //Top 10 Tools Sales

    //Training Information
    //Training Online
    public List<Contact> lae { get; set; } //Training Learn & Earn Contacts
    //Training Hot
    //Identify Account Contacts
    //**************************
    public List<Contact> contactList { get; set; }//AccountList Contacts
    public Set<Id> trainingSessionIds { get; set; }//All Training Sessions IDs for this Account Group

    public List<TrainingSession__c> tSessionYTD { get; set; }//Training Session YTD
    public List<TrainingSession__c> tSessionLYTD { get; set; }//Training Session LYTD
    public List<TrainingSession__c> tSessionLCY { get; set; }//Training Session LCY

    public List<Event> tSesEventYTD { get; set; }//Training Session Events YTD
    public List<Event> tSesEventLYTD { get; set; }//Training Session Events LYTD
    public List<Event> tSesEventLCY { get; set; }//Training Session Events LCY

    public List<AggregateResult> courseYTD { get; set; }//course YTD
    public List<TrainingAttendance__c> tHotYTD { get; set; }//Training Attendance YTD

    //Product Training
    public AggregateResult ptYTD { get; set; }
    public AggregateResult ptLYTD { get; set; }
    public AggregateResult ptLCY { get; set; }

//Constructor
    public AccountGroupSummaryController() {
        //Account Variable Population
        accountIdHQ = System.currentPageReference().getParameters().get('Id');
        System.debug(accountIdHQ);

        accountHQ = [SELECT ID, Name, Owner.Name, Customer_Group_4__c, M12_Hub__c, TTI_SAP_Cust_No__c, Hammer_Club__c, Meters_Of_Display__c, Mini_Display__c, Shockwave__c, Sawzall__c, Holesaws__c, Carbide__c, Wood_Drilling__c, Other_Accessories__c, Handtools__c, M12__c, M18__c, Hammer_AC__c, Grinders_AC__c, AC__c, Other_Tools__c FROM Account WHERE Id = :accountIdHQ];
        System.debug(accountHQ);

        group4 = accountHQ.Customer_Group_4__c;
        System.debug(group4);

        if(Test.isRunningTest())
            accountList = [Select ID, Name, Owner.Name, Customer_Group_4__c, M12_Hub__c, TTI_SAP_Cust_No__c, Hammer_Club__c, Meters_Of_Display__c, Mini_Display__c, Shockwave__c, Sawzall__c, Holesaws__c, Carbide__c, Wood_Drilling__c, Other_Accessories__c, Handtools__c, M12__c, M18__c, Hammer_AC__c, Grinders_AC__c, AC__c, Other_Tools__c, JSS_Dealer_Referred_Sales_CFY__c, JSS_Dealer_Referred_Sales_PFY__c From Account Where Customer_Group_4__c = :group4 AND RecordTypeId != :recTypeHQ LIMIT 10];
        else
            accountList = [Select ID, Name, Owner.Name, Customer_Group_4__c, M12_Hub__c, TTI_SAP_Cust_No__c, Hammer_Club__c, Meters_Of_Display__c, Mini_Display__c, Shockwave__c, Sawzall__c, Holesaws__c, Carbide__c, Wood_Drilling__c, Other_Accessories__c, Handtools__c, M12__c, M18__c, Hammer_AC__c, Grinders_AC__c, AC__c, Other_Tools__c, JSS_Dealer_Referred_Sales_CFY__c, JSS_Dealer_Referred_Sales_PFY__c From Account Where Customer_Group_4__c = :group4 AND RecordTypeId != :recTypeHQ];
        System.debug(accountList);

        if (accountList.isEmpty() == false) {
            groupCount = accountList.size();
            System.debug(groupCount);
        } else {
            groupCount = 0;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Customer Group 4 found no child accounts');
            ApexPages.addMessage(msg);
        }

        // Sales History Population
        summaryDate = Date.today().addDays(-1);
        //(Date)[SELECT DateSummarised__c FROM SalesHistSummary__c WHERE Account__c IN :accountList GROUP BY DateSummarised__c ORDER BY DateSummarised__c DESC LIMIT 1][0].get('DateSummarised__c');

        salesHistYTD = [
                SELECT Product_Group__c, SUM(Qty__c) Qty, Sum(Sales__c) Sales
                FROM SalesHistSummary__c
                WHERE Account__c IN :accountList AND RecType__c = 'CYTD' AND DateSummarised__c = :summaryDate
                GROUP BY Product_Group__c
        ];

        salesHistLYTD = [
                SELECT Product_Group__c, SUM(Qty__c) Qty, Sum(Sales__c) Sales
                FROM SalesHistSummary__c
                WHERE Account__c IN :accountList AND RecType__c = 'LYTD' AND DateSummarised__c = :summaryDate
                GROUP BY Product_Group__c
        ];

        budgetHistYTD = (Decimal) [SELECT SUM(Revenue__c) Budget FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND CALENDAR_MONTH(Posting_Date__c) <= :currentMonth][0].get('Budget');

        //budgetHistLYTD = (Decimal)[SUM(Revenue__c) Budget FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) = :previousYear AND Posting_Date__c <= :dateLYTD][0].get('Budget');

        budgetHistCFY = (Decimal) [SELECT SUM(Revenue__c) Budget FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Target-Custno' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear][0].get('Budget');

        // Training Information Population
        //Training Online
        lae = [SELECT Id, Name, LNE_AdjScore__c, LNE_AvgScore__c, LNE_Attempts__c, LNE_Completed__c FROM Contact WHERE AccountId IN :accountList AND Record_Status__c = 'Active' AND LNE_Attempts__c >= 1];

        //Training HOT
        contactList = [SELECT Id FROM Contact WHERE AccountId IN :accountList];
        //***Get all training sessions that people in this froup have attended
        trainingSessionIds = new Set<Id>();
        for (AggregateResult ar: [SELECT TrainingSessionID__c tsid FROM TrainingAttendance__c WHERE TrainingAttendent__c IN :contactList GROUP BY TrainingSessionID__c]) {
            trainingSessionIds.add((Id) ar.get('tsid'));
        }
        //**************************
        tSessionYTD = [SELECT Id, Training_Session_Name__c, CourseID__c, Course_Name__c FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :currentYear AND TrainingSessionDate__c <= :dateCYTD];
        tSessionLYTD = [SELECT Id, Training_Session_Name__c, CourseID__c, Course_Name__c FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :previousYear AND TrainingSessionDate__c <= :dateLYTD];
        tSessionLCY = [SELECT Id, Training_Session_Name__c, CourseID__c, Course_Name__c FROM TrainingSession__c WHERE Id IN :trainingSessionIds AND CALENDAR_YEAR(TrainingSessionDate__c) = :previousYear];

        tSesEventYTD = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionYTD];
        tSesEventLYTD = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionLYTD];
        tSesEventLCY = [SELECT WhatId, DurationInMinutes FROM Event WHERE WhatId IN :tSessionLCY];

        courseYTD = [SELECT CourseID__c, CourseID__r.CourseTitle__c title FROM TrainingSession__c WHERE Id IN :tSessionYTD GROUP BY CourseID__c, CourseID__r.CourseTitle__c];
        tHotYTD = [SELECT TrainingSessionID__c, Course_Name__c, Attend__c FROM TrainingAttendance__c WHERE TrainingAttendent__c IN :contactList AND TrainingSessionID__c IN :tSessionYTD];

        //Product Training
        ptYTD = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
        ptLYTD = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD];
        ptLCY = [SELECT COUNT(Id) total, SUM(DurationInMinutes) duration FROM Event WHERE Act_sub_type_Industrial__c = 'Product Training' AND AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear];
    }

//Account Details
    //M12 Hub Count
    public Decimal getM12Hub() {
        Decimal m12 = 0;
        for (Account a: accountList) {
            if (a.M12_Hub__c == 'Yes') {
                m12 = m12 + 1;
            }
        }
        return m12;
    }
    //Hammer Club Count
    public Decimal getHammerClub() {
        Decimal hammer = 0;
        for (Account a: accountList) {
            if (a.Hammer_Club__c == 'Yes') {
                hammer = hammer + 1;
            }
        }
        return hammer;
    }
    //Meters of display
    public Decimal getMetersDisplay() {
        Decimal md = 0;
        for (Account a: accountList) {
            if (a.Meters_Of_Display__c > 0) {
                md = md + a.Meters_Of_Display__c;
            }
        }
        return md;
    }
    //Number of Red Racks
    public Decimal getRedRacks() {
        Decimal rr = 0;
        for (Account a: accountList) {
            if (a.Mini_Display__c > 0) {
                rr = rr + a.Mini_Display__c;
            }
        }
        return rr;
    }
    //Budget from Child Accounts
    public Decimal getBudgetTotal() {
        Decimal bud = 0;
        if (budgetHistYTD != Null) {
            bud = budgetHistYTD;
        }
        return bud;
    }
    public Decimal getBudgetTotalCFY() {
        Decimal bud = 0;
        if (budgetHistCFY != Null) {
            bud = budgetHistCFY;
        }
        return bud;
    }
    //Sales from Child Accounts
    public Decimal getSalesTotal() {
        Decimal sh = 0;
        for (AggregateResult s: salesHistYTD) {
            if (s.get('Sales') != null) {
                sh = sh + (Decimal) s.get('Sales');
            }
        }
        return sh;
    }

//Account Contacts
    public List<Contact> getAContact() {
        list<Contact> c = new list<Contact>(); //Contact List
        c = [SELECT Id, Name, Title, Trade__c, Email, Phone, Record_Status__c FROM Contact WHERE AccountId = :accountIdHQ AND Record_Status__c = 'Active'];
        return c;
    }

//Sales Achievement Gauge
    public List<gaugeData> getSalesAchievement() {
        Decimal achievememt = 100;
        Decimal salesYTD = 0;
        Decimal budgetYTD = 0;
        List<gaugeData> sa = new List<gaugeData>();

        salesYTD = getSalesTotal();
        budgetYTD = getBudgetTotal();

        if (budgetYTD != null) {
            if (salesYTD != null) {
                if (budgetYTD != 0) {
                    try {
                        achievememt = ((salesYTD / budgetYTD) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        sa.add(new gaugeData('Sales Achievememt YTD', achievememt));
        return sa;
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Sales Histories YTD

    //Total Sales LYTD vs CYTD
    public cTotalSales getTotalSales() {
        Decimal cYTD = 0;
        Decimal lYTD = 0;
        Decimal variance = 0;
        String change = 'new String';

        for (AggregateResult csh: salesHistYTD) {
            if (csh.get('Sales') != null) {
                cYTD = cYTD + (Decimal) csh.get('Sales');
            }
        }

        for (AggregateResult lsh: salesHistLYTD) {
            if (lsh.get('Sales') != null) {
                lYTD = lYTD + (Decimal) lsh.get('Sales');
            }
        }

        if (cYTD != null) {
            if (lYTD != null) {
                try {
                    variance = ((cYTD - lYTD) / lYTD) * 100;
                } catch (Exception e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }

        change = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        ts = new cTotalSales(cYTD, lYTD, Change);

        return ts;
    }

    //Accessories Sales (YTD vs LYTD)
    public List<cItemTotalSales> getAccessorySales() {
        //Declare Vaiables
        salesACS = new List<cItemTotalSales>();
        String item;
        String itemcode;
        Boolean support;
        String supportRatio;
        Decimal qtyYTD;
        Decimal qtyLYTD;
        Decimal qtyVariance;
        Decimal salesYTD;
        Decimal salesLYTD;
        String salesVariance;
        //Running Totals
        Decimal count;
        Decimal variance;

        //Shockwave
        //*************************
        //init variables
        item = 'Shockwave';
        itemcode = '';
        support = accountHQ.Shockwave__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Shockwave__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Sawzall
        //*************************
        //init variables
        item = 'Sawzall';
        itemcode = '';
        support = accountHQ.Sawzall__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Sawzall__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Holesaws
        //*************************
        //init variables
        item = 'Holesaws';
        itemcode = '';
        support = accountHQ.Holesaws__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Holesaws__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Carbide
        //*************************
        //init variables
        item = 'Carbide';
        itemcode = '';
        support = accountHQ.Carbide__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Carbide__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Wood Drilling
        //*************************
        //init variables
        item = 'Wood Drilling';
        itemcode = '';
        support = accountHQ.Wood_Drilling__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Wood_Drilling__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Handtools
        //*************************
        //init variables
        item = 'Handtools';
        itemcode = '';
        support = accountHQ.Handtools__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Handtools__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Other Accessories
        //*************************
        //init variables
        item = 'Other Accessories';
        itemcode = '';
        support = accountHQ.Other_Accessories__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Other_Accessories__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************
        return salesACS;
    }

    //Tool Sales (YTD vs LYTD)
    public List<cItemTotalSales> getToolSales() {
        //Declare Vaiables
        salesTool = new List<cItemTotalSales>();
        String item;
        String itemcode;
        Boolean support;
        String supportRatio;
        Decimal qtyYTD;
        Decimal qtyLYTD;
        Decimal qtyVariance;
        Decimal salesYTD;
        Decimal salesLYTD;
        String salesVariance;
        //Running Totals
        Decimal count;
        Decimal variance;

        //M12
        //*************************
        //init variables
        item = 'M12';
        itemcode = '';
        support = accountHQ.M12__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.M12__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //M18
        //*************************
        //init variables
        item = 'M18';
        itemcode = '';
        support = accountHQ.M18__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.M18__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Hammers (AC)
        //*************************
        //init variables
        item = 'Hammer (AC)';
        itemcode = '';
        support = accountHQ.Hammer_AC__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Hammer_AC__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Grinders (AC)
        //*************************
        //init variables
        item = 'Grinders (AC)';
        itemcode = '';
        support = accountHQ.Grinders_AC__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Grinders_AC__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //AC (Other)
        //*************************
        //init variables
        item = 'Other (AC)';
        itemcode = '';
        support = accountHQ.AC__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.AC__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************

        //Other Tools
        //*************************
        //init variables
        item = 'Other Tools';
        itemcode = '';
        support = accountHQ.Other_Tools__c;
        supportRatio = '';
        qtyYTD = 0;
        qtyLYTD = 0;
        qtyVariance = 0;
        salesYTD = 0;
        salesLYTD = 0;
        salesVariance = '0%';
        count = 0;
        variance = 0;

        //calculate Support Ratio
        for (Account a: accountList) {
            if (a.Other_Tools__c == true) {
                count = count + 1;
            }
        }
        supportRatio = '(' + count + ' / ' + groupCount + ')';

        //calculate YTD quantity and Sales
        for (AggregateResult ar: salesHistYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesYTD = salesYTD + (Decimal) ar.get('Sales');
                qtyYTD = qtyYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate LYTD quantity and Sales
        for (AggregateResult ar: salesHistLYTD) {
            if (ar.get('Product_Group__c') == item) {
                salesLYTD = salesLYTD + (Decimal) ar.get('Sales');
                qtyLYTD = qtyLYTD + (Decimal) ar.get('Qty');
            }
        }

        //calculate Variance
        qtyVariance = qtyYTD - qtyLYTD;

        if (salesLYTD <> 0) {
            variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
            salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
        }

        //add record to list
        SalesTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        //*************************
        return salesTool;
    }

    //Category Breakdown & Pie Chart
    public List<cCategoryBD> getCategoryBreakdown() {
        //Declare Variables
        List<cCategoryBD> catSalesPercent = new List<cCategoryBD>();
        Decimal totalSalesYTD = ts.salesYTD;
        Decimal salesACSYTD = 0;
        Decimal percentage = 0;

        if (totalSalesYTD != null && totalSalesYTD > 0) {

            if (salesACS.isEmpty() != true) {
                //Add Total Accessory Sales
                for (cItemTotalSales acs :salesACS) {
                    if (acs.Item != 'Handtools') {
                        salesACSYTD = salesACSYTD + acs.salesYTD;
                    }
                }
                percentage = ((salesACSYTD / totalSalesYTD) * 100).setScale(2, RoundingMode.HALF_UP);
                catSalesPercent.add(new cCategoryBD('Accessories', salesACSYTD, percentage, percentage + '%'));
                //Add Total Handtool Sales
                salesACSYTD = 0;
                percentage = 0;
                for (cItemTotalSales acs :salesACS) {
                    if (acs.Item == 'Handtools') {
                        salesACSYTD = salesACSYTD + acs.salesYTD;
                    }
                }
                percentage = ((salesACSYTD / totalSalesYTD) * 100).setScale(2, RoundingMode.HALF_UP);
                catSalesPercent.add(new cCategoryBD('Handtools', salesACSYTD, percentage, percentage + '%'));
            }

            //Add all Tool Sales
            salesACSYTD = 0;
            percentage = 0;
            if (salesTool.isEmpty() != true) {
                for (cItemTotalSales tools :salesTool) {
                    percentage = ((tools.salesYTD / totalSalesYTD) * 100).setScale(2, RoundingMode.HALF_UP);
                    catSalesPercent.add(new cCategoryBD(tools.item, tools.salesYTD, percentage, percentage + '%'));
                }
            }
        }
        return CatSalesPercent;
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Top 10 Products - Accessories and Tools by Sales

    //Top 10 Accessories by Sales Value
    public List<cItemTotalSales> getTop10Accessories() {
        //Declare Vaiables
        list<AggregateResult> qryYTD10Acc = new list<AggregateResult>();
        list<AggregateResult> qryLYTD10Acc = new list<AggregateResult>();

        top10ACS = new List<cItemTotalSales>();

        String item;
        String itemcode;
        Boolean support;
        String supportRatio;
        Decimal qtyYTD;
        Decimal qtyLYTD;
        Decimal qtyVariance;
        Decimal salesYTD;
        Decimal salesLYTD;
        String salesVariance;
        //Running Totals
        Decimal variance;

        // Query Database ****************
        qryYTD10Acc = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND Posting_Date__c <= :dateCYTD AND Brand_Code__c = 'ML' AND Category_Code__c = 'PT' AND Sub_Category_Code__c = 'ACS' GROUP BY Product__c, Product__r.Name, Product__r.ProductCode ORDER BY Sum(Revenue__c) DESC LIMIT 10];

        qryLYTD10Acc = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :previousYear AND Posting_Date__c <= :dateLYTD AND Brand_Code__c = 'ML' AND Category_Code__c = 'PT' AND Sub_Category_Code__c = 'ACS' GROUP BY Product__c, Product__r.Name, Product__r.ProductCode];

        //Summarise products
        for (AggregateResult ar:qryYTD10Acc) {
            item = (String) ar.get('PName');
            itemcode = (String) ar.get('PCode');
            qtyYTD = (Decimal) ar.get('TotalQty');
            salesYTD = (Decimal) ar.get('TotalSales');
            qtyLYTD = 0;
            salesLYTD = 0;
            qtyVariance = 0;
            salesVariance = '0%';

            //loop to get Last Year's QTY and SALES
            for (AggregateResult ar1:qryLYTD10Acc) {
                if (ar.get('PName') == ar1.get('PName')) {
                    qtyLYTD = (Decimal) ar1.get('TotalQty');
                    salesLYTD = (Decimal) ar1.get('TotalSales');
                }
            }

            //Calculate Variances for QTY
            if (qtyLYTD != null) {
                if (qtyYTD != null) {
                    qtyVariance = qtyYTD - qtyLYTD;
                }
            }

            //Calculate Variances for SALES
            if (salesLYTD != null && salesLYTD != 0) {
                if (salesYTD != null) {
                    variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
                    salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
                }
            }
            top10ACS.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        }

        return top10ACS;
    }

    //Top 10 Handtools by Sales Value
    public List<cItemTotalSales> getTop10Handtools() {
        //Declare Vaiables
        list<AggregateResult> qryYTD10ht = new list<AggregateResult>();
        list<AggregateResult> qryLYTD10ht = new list<AggregateResult>();

        top10HTool = new List<cItemTotalSales>();

        String item;
        String itemcode;
        Boolean support;
        String supportRatio;
        Decimal qtyYTD;
        Decimal qtyLYTD;
        Decimal qtyVariance;
        Decimal salesYTD;
        Decimal salesLYTD;
        String salesVariance;
        //Running Totals
        Decimal variance;

        // Query Database ****************
        qryYTD10ht = [
                SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty
                FROM Sales_History__c
                WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND Posting_Date__c <= :dateCYTD
                AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'HT' AND Product__r.Sub_Category__c = 'NPW'
                GROUP BY Product__c, Product__r.Name, Product__r.ProductCode
                ORDER BY Sum(Revenue__c) DESC
                LIMIT 10
        ];

        qryLYTD10ht = [
                SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty
                FROM Sales_History__c
                WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :previousYear AND Posting_Date__c <= :dateLYTD
                AND Product__r.Brand__c = 'ML' AND Product__r.Category__c = 'HT' AND Product__r.Sub_Category__c = 'NPW'
                GROUP BY Product__c, Product__r.Name, Product__r.ProductCode
        ];

        //Summarise products
        for (AggregateResult ar:qryYTD10ht) {
            item = (String) ar.get('PName');
            itemcode = (String) ar.get('PCode');
            qtyYTD = (Decimal) ar.get('TotalQty');
            salesYTD = (Decimal) ar.get('TotalSales');
            qtyLYTD = 0;
            salesLYTD = 0;
            qtyVariance = 0;
            salesVariance = '0%';

            //loop to get Last Year's QTY and SALES
            for (AggregateResult ar1:qryLYTD10ht) {
                if (ar.get('PName') == ar1.get('PName')) {
                    qtyLYTD = (Decimal) ar1.get('TotalQty');
                    salesLYTD = (Decimal) ar1.get('TotalSales');
                }
            }

            //Calculate Variances for QTY
            if (qtyLYTD != null) {
                if (qtyYTD != null) {
                    qtyVariance = qtyYTD - qtyLYTD;
                }
            }

            //Calculate Variances for SALES
            if (salesLYTD != null && salesLYTD != 0) {
                if (salesYTD != null) {
                    variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
                    salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
                }
            }
            top10HTool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        }

        return top10HTool;
    }

    //Top 10 Tools by Sales Value
    public List<cItemTotalSales> getTop10Tools() {
        //Declare Vaiables
        list<AggregateResult> qryYTD10Tool = new list<AggregateResult>();
        list<AggregateResult> qryLYTD10Tool = new list<AggregateResult>();

        top10Tool = new List<cItemTotalSales>();

        String item;
        String itemcode;
        Boolean support;
        String supportRatio;
        Decimal qtyYTD;
        Decimal qtyLYTD;
        Decimal qtyVariance;
        Decimal salesYTD;
        Decimal salesLYTD;
        String salesVariance;
        //Running Totals
        Decimal variance;

        // Query Database ****************
        qryYTD10Tool = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :currentYear AND Posting_Date__c <= :dateCYTD AND Brand_Code__c = 'ML' AND Category_Code__c = 'PT' AND Sub_Category_Code__c != 'ACS' GROUP BY Product__c, Product__r.Name, Product__r.ProductCode ORDER BY Sum(Revenue__c) DESC LIMIT 10];

        qryLYTD10Tool = [SELECT Product__c, Product__r.Name PName, Product__r.ProductCode PCode, Sum(Revenue__c) TotalSales, Sum(Qty__c) TotalQty FROM Sales_History__c WHERE Sold_To__c IN :accountList AND RecordType.Name = 'Sales' AND CALENDAR_YEAR(Posting_Date__c) = :previousYear AND Posting_Date__c <= :dateLYTD AND Brand_Code__c = 'ML' AND Category_Code__c = 'PT' AND Sub_Category_Code__c != 'ACS' GROUP BY Product__c, Product__r.Name, Product__r.ProductCode];

        //Summarise products
        for (AggregateResult ar:qryYTD10Tool) {
            item = (String) ar.get('PName');
            itemcode = (String) ar.get('PCode');
            qtyYTD = (Decimal) ar.get('TotalQty');
            salesYTD = (Decimal) ar.get('TotalSales');
            qtyLYTD = 0;
            salesLYTD = 0;
            qtyVariance = 0;
            salesVariance = '0%';

            //loop to get Last Year's QTY and SALES
            for (AggregateResult ar1:qryLYTD10Tool) {
                if (ar.get('PName') == ar1.get('PName')) {
                    qtyLYTD = (Decimal) ar1.get('TotalQty');
                    salesLYTD = (Decimal) ar1.get('TotalSales');
                }
            }

            //Calculate Variances for QTY
            if (qtyLYTD != null) {
                if (qtyYTD != null) {
                    qtyVariance = qtyYTD - qtyLYTD;
                }
            }

            //Calculate Variances for SALES
            if (salesLYTD != null && salesLYTD != 0) {
                if (salesYTD != null) {
                    variance = ((salesYTD - salesLYTD) / salesLYTD * 100);
                    salesVariance = variance.setScale(2, RoundingMode.HALF_UP) + '%';
                }
            }
            top10Tool.add(new cItemTotalSales(item, itemcode, support, supportRatio, qtyYTD, qtyLYTD, qtyVariance, salesYTD, salesLYTD, salesVariance));
        }

        return top10Tool;
    }

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//Marketing Material Spending (TTI Promo Forms)
    //Get YTD Promo Form value
    public Decimal getMMSYTD() {
        mmsYTD = (Decimal) [SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c IN :accountList AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :currentYear AND Date_Approved__c <= :dateCYTD][0].get('Spending');

        return mmsYTD;
    }

    //Get LYTD Promo Form value
    public Decimal getMMSLYTD() {
        mmsLYTD = (Decimal) [SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c IN :accountList AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :previousYear AND Date_Approved__c <= :dateLYTD][0].get('Spending');

        return mmsLYTD;
    }


    //Get LCY Promo Form value
    public Decimal getMMSLCY() {
        Decimal mmsLCY = (Decimal) [SELECT Sum(Total_Form_List_Price_Value__c) Spending FROM TTI_Form__c WHERE Customer_Name__c IN :accountList AND RecordTypeId = :promoFormRecID AND CALENDAR_YEAR(Date_Approved__c) = :previousYear][0].get('Spending');

        return mmsLCY;
    }
    //Get Promo Form variance
    public Decimal getMMSVariance() {
        Decimal variance = 0;

        if (mmsLYTD != null && mmsLYTD != 0) {
            if (mmsYTD != null) {
                variance = (mmsYTD / mmsLYTD) * 100;
            }
        }

        return variance;
    }

//JSS Information
    //JSS Dealer Reffered Sales (YTD)
    public Decimal getJSSSalesYTD() {
        Decimal salesJSScYTD = 0;
        salesJSScYTD = (Decimal) [SELECT SUM(Amount) TotalSales FROM Opportunity WHERE Retailer__c IN :accountList AND IsWon = True AND CALENDAR_YEAR(CloseDate) = :currentYear AND CloseDate <= :dateCYTD][0].get('TotalSales');
        return salesJSScYTD;
    }

    //JSS Dealer Reffered Sales (LYTD)
    public Decimal getJSSSalesLYTD() {
        Decimal salesJSSLYTD = 0;
        salesJSSLYTD = (Decimal) [SELECT SUM(Amount) TotalSales FROM Opportunity WHERE Retailer__c IN :accountList AND IsWon = True AND CALENDAR_YEAR(CloseDate) = :previousYear AND CloseDate <= :dateLYTD][0].get('TotalSales');
        return salesJSSLYTD;
    }

    //JSS Variance
    public Decimal getJSSVariance() {
        Decimal variance = 100;
        Decimal jssSalesYTD = getJSSSalesYTD();
        Decimal jssSalesLYTD = getJSSSalesLYTD();

        if (jssSalesLYTD != null) {
            if (jssSalesYTD != null) {
                if (jssSalesLYTD != 0) {
                    try {
                        variance = (((jssSalesYTD - jssSalesLYTD) / jssSalesLYTD) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        return variance;
    }

    //JSS Dealer Reffered Sales (CFY)
    public Decimal getJSSSalesCFY() {
        Decimal getJSSSalesCFY = 0;
        for (Account a: accountList) {
            if (a.JSS_Dealer_Referred_Sales_CFY__c != null) {
                getJSSSalesCFY = getJSSSalesCFY + a.JSS_Dealer_Referred_Sales_CFY__c;
            }
        }
        return getJSSSalesCFY;
    }

    //JSS Dealer Reffered Sales (LFY)
    public Decimal getJSSSalesLFY() {
        Decimal getJSSSalesLFY = 0;
        for (Account a: accountList) {
            if (a.JSS_Dealer_Referred_Sales_PFY__c != null) {
                getJSSSalesLFY = getJSSSalesLFY + a.JSS_Dealer_Referred_Sales_PFY__c;
            }
        }
        return getJSSSalesLFY;
    }

//Opportunity Information
    //Top 5 Open Opportunities
    public List<Opportunity> getTopOpenOpps() {
        List<Opportunity> o = new list<Opportunity>(); //Opportunity List
        o = [SELECT Name, Amount, Retailer__c, Owner.Name, StageName, CloseDate, IsClosed, AccountId, Account.Name, IsWon FROM Opportunity WHERE Retailer__c IN :accountList AND IsClosed = False ORDER BY Amount DESC NULLS LAST LIMIT 5];
        return o;
    }

    //Top 5 Closed Opportunities from last 12 months
    public List<Opportunity> getTopClosedOpps() {
        List<Opportunity> o = new list<Opportunity>(); //Opportunity List
        o = [SELECT Name, Amount, Retailer__c, Owner.Name, StageName, CloseDate, IsClosed, AccountId, Account.Name, IsWon FROM Opportunity WHERE Retailer__c IN :accountList AND IsWon = True AND CloseDate >= :dateLYTD AND CloseDate < :dateCYTD ORDER BY Amount DESC NULLS LAST LIMIT 5];
        return o;
    }

//Leads Created
    //Count of Leads YTD
    public Integer getLeadsYTD() {
        List<Lead> l = new List<Lead>(); //Lead List
        Integer lc = 0;
        l = [SELECT Id FROM Lead WHERE Preferred_Retailer__c IN :accountList AND CALENDAR_YEAR(CreatedDate) = :currentYear AND CreatedDate <= :dateCYTD];
        lc = l.size();
        return lc;
    }
    //Count of Leads LYTD
    public Integer getLeadsLYTD() {
        List<Lead> l = new List<Lead>(); //Lead List
        Integer lc = 0;
        l = [SELECT Id FROM Lead WHERE Preferred_Retailer__c IN :accountList AND CALENDAR_YEAR(CreatedDate) = :previousYear AND CreatedDate <= :dateLYTD];
        lc = l.size();
        return lc;
    }
    //Variance Leads YTD vs LYTD
    public Decimal getLeadsVariance() {
        Decimal variance = 0;
        Decimal ytd = getLeadsYTD();
        Decimal lytd = getLeadsLYTD();

        if (lytd != null) {
            if (ytd != null) {
                if (lytd != 0) {
                    try {
                        variance = (((ytd - lytd) / lytd) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        return variance;
    }
    //Count of Leads LFY
    public Integer getLeadsLFY() {
        List<Lead> l = new List<Lead>(); //Lead List
        Integer lc = 0;
        l = [SELECT Id FROM Lead WHERE Preferred_Retailer__c IN :accountList AND CALENDAR_YEAR(CreatedDate) = :previousYear];
        lc = l.size();
        return lc;
    }

//Activity History
    //Count of Activities YTD
    public Integer getActivityYTD() {
        list<Event> e = new list<Event>(); //Event List
        Integer ec = 0;
        if(Test.isRunningTest()){
            e = [SELECT Id FROM Event WHERE AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow') LIMIT 10];
        }else{
            e = [SELECT Id FROM Event WHERE AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow')];
        }
        ec = e.size();
        return ec;
    }
    //Count of Activities LYTD
    public Integer getActivityLYTD() {
        list<Event> e = new list<Event>(); //Event List
        Integer ec = 0;
        if(Test.isRunningTest()){
            e = [SELECT Id FROM Event WHERE AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow') LIMIT 10];
        }else{
            e = [SELECT Id FROM Event WHERE AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow')];
        }

        ec = e.size();
        return ec;
    }
    //Variance of Activities YTD vs LYTD
    public Decimal getActivityVariance() {
        Decimal variance = 0;
        Decimal ytd = getActivityYTD();
        Decimal lytd = getActivityLYTD();

        if (lytd != null) {
            if (ytd != null) {
                if (lytd != 0) {
                    try {
                        variance = (((ytd - lytd) / lytd) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        return variance;
    }
    //Count of Activities LFY
    public Integer getActivityLFY() {
        list<Event> e = new list<Event>(); //Event List
        Integer ec = 0;
        e = [SELECT Id FROM Event WHERE AccountId IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow')];
        ec = e.size();
        return ec;
    }
    //Last 10 Activiites on HQ
    public List<Event> getAEvents() {
        list<Event> e = new list<Event>(); //Event List (Limit 10 records)
        e = [SELECT ActivityDate, Objective__c, Outcome__c, Owner.Name FROM Event WHERE AccountId = :accountIdHQ AND ActivityDate <= :dateCYTD AND (Act_sub_type_Industrial__c = 'Sales Call' OR Act_sub_type_Industrial__c = 'Business Review' OR Act_sub_type_Industrial__c = 'Product Training' OR Act_sub_type_Industrial__c = 'Dealer Event' OR Act_sub_type_Industrial__c = 'Tradeshow') ORDER BY ActivityDate DESC LIMIT 10];
        return e;
    }

//Training Information
    //Training Online (Learn & Earn)
    public tableData getTainingOnline() {
        tableData td;
        Decimal parts = lae.size();
        Decimal exams = 0;
        Decimal avg = 0;
        Decimal rate = 0;

        for (Contact c:lae) {
            if (c.LNE_Completed__c != null) {
                exams = exams + c.LNE_Completed__c;
            }
        }

        if (parts != 0) {
            avg = ((exams / parts).setScale(2, RoundingMode.HALF_UP));
        }

        if (groupCount != 0) {
            rate = (((parts / groupCount) * 100).setScale(2, RoundingMode.HALF_UP));
        }

        td = new tableData(String.valueOf(parts), String.valueOf(exams), String.valueOf(avg), String.valueOf(rate), 'blank');

        return td;
    }

    //Training Hot
    public List<tableData> getTrainingHot() {
        List<tableData> td = new List<tableData>();
        String courseName = 'a';
        Decimal invited;
        Decimal attended;
        Decimal ratio;
        Decimal duration;
        //Loop through all courses this YTD
        for (AggregateResult ar :courseYTD) {
            courseName = (String) ar.get('title');
            invited = 0;
            attended = 0;
            duration = 0;
            ratio = 0;
            //Calculate Invited and Attended from this account group
            for (TrainingAttendance__c ta :tHotYTD) {
                if (ta.Course_Name__c == ar.get('title')) {
                    invited = invited + 1;
                    if (ta.Attend__c == True) {
                        attended = attended + 1;
                    }
                }
            }
            //Calculate Duration
            for (TrainingSession__c ts: tSessionYTD) {
                if (ts.CourseID__c == ar.get('CourseID__c')) {
                    for (Event e :tSesEventYTD) {
                        if (e.WhatId == ts.Id) {
                            duration = duration + e.DurationInMinutes;
                        }
                    }
                }
            }

            duration = (duration / 60).setScale(2, RoundingMode.HALF_UP);
            if (invited != 0) {
                ratio = ((attended / invited) * 100).setScale(2, RoundingMode.HALF_UP);
            }

            if (invited != 0) {
                td.add(new tableData(courseName, String.valueOf(invited), String.valueOf(attended), String.valueOf(ratio), String.valueOf(duration)));
            }
        }
        return td;
    }

    //Product Training by ASM
    public tableData getPTraining() {
        tableData td;
        Decimal count = 0;
        Decimal duration = 0;

        if (ptYTD.get('total') != null) {
            count = (Decimal) ptYTD.get('total');
        }
        if (ptYTD.get('duration') != null) {
            duration = (Decimal) ptYTD.get('duration');
            duration = (duration / 60).setScale(2, RoundingMode.HALF_UP);
        }

        td = new tableData(String.valueOf(count), String.valueOf(duration), 'blank', 'blank', 'blank');
        return td;
    }

    //Practical Training
    //Practical YTD
    public Decimal getPracticalYTD() {
        Decimal total = 0;
        Decimal th = 0; //Training Hot Duration
        Decimal pt = 0; //Training Product Duration

        for (Event e :tSesEventYTD) {
            if (e.DurationInMinutes != null) {
                th = th + (Decimal) e.DurationInMinutes;
            }
        }

        if (ptYTD.get('duration') != null) {
            pt = (Decimal) ptYTD.get('duration');
        }
        total = ((th + pt) / 60).setScale(2, RoundingMode.HALF_UP);
        return total;
    }

    //Practical LYTD
    public Decimal getPracticalLYTD() {
        Decimal total = 0;
        Decimal th = 0; //Training Hot Duration
        Decimal pt = 0; //Training Product Duration

        for (Event e :tSesEventLYTD) {
            if (e.DurationInMinutes != null) {
                th = th + (Decimal) e.DurationInMinutes;
            }
        }
        if (ptLYTD.get('duration') != null) {
            pt = (Decimal) ptLYTD.get('duration');
        }

        total = ((th + pt) / 60).setScale(2, RoundingMode.HALF_UP);
        return total;
    }

    //Practical Variance
    public Decimal getPracticalVariance() {
        Decimal variance = 0;
        Decimal ytd = getPracticalYTD();
        Decimal lytd = getPracticalLYTD();

        if (lytd != null) {
            if (ytd != null) {
                if (lytd != 0) {
                    try {
                        variance = (((ytd - lytd) / lytd) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        return variance;
    }

    //Practical LCY
    public Decimal getPracticalLCY() {
        Decimal total = 0;
        Decimal th = 0; //Training Hot Duration
        Decimal pt = 0; //Training Product Duration

        for (Event e :tSesEventLCY) {
            if (e.DurationInMinutes != null) {
                th = th + (Decimal) e.DurationInMinutes;
            }
        }
        if (ptLCY.get('duration') != null) {
            pt = (Decimal) ptLCY.get('duration');
        }
        total = ((th + pt) / 60).setScale(2, RoundingMode.HALF_UP);
        return total;
    }

    //Joint Dealer Sales Calls
    //Joint Dealer Calls Count YTD
    public Decimal getJointDealerCountYTD() {
        list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
        ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :currentYear AND ActivityDate <= :dateCYTD];
        return ejdc.size();
    }

    //Joint Dealer Calls Count LYTD
    public Decimal getJointDealerCountLYTD() {
        list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
        ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear AND ActivityDate <= :dateLYTD];
        return ejdc.size();
    }

    //Joint Dealer Calls Variance
    public Decimal getJointDealerVariance() {
        Decimal variance = 0;
        Decimal ytd = getJointDealerCountYTD();
        Decimal lytd = getJointDealerCountLYTD();

        if (lytd != null) {
            if (ytd != null) {
                if (lytd != 0) {
                    try {
                        variance = (((ytd - lytd) / lytd) * 100).setScale(2, RoundingMode.HALF_UP);
                    } catch (Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
            }
        }
        return variance;
    }

    //Joint Dealer Calls Count LCY
    public Decimal getJointDealerCountLCY() {
        list<Event> ejdc = new list<Event>(); //Event Joint Dealer Calls
        ejdc = [SELECT Id, Account.Name FROM Event WHERE Joint_Call_w_Dealer_Rep__c = True AND On_Behalf__c IN :accountList AND CALENDAR_YEAR(ActivityDateTime) = :previousYear];
        return ejdc.size();
    }

//#######################################################################################
//Wrapper Class for Total Sales History
    public class cTotalSales {
        public Decimal salesYTD { get; set; }
        public Decimal salesLYTD { get; set; }
        public String variance { get; set; }
        public cTotalSales(Decimal a, Decimal b, String c) {
            this.salesYTD = a;
            this.salesLYTD = b;
            this.variance = c;
        }
    }

//Wrapper Class for Total Item Sales History
    public class cItemTotalSales {
        public String item { get; set; }
        public String itemcode { get; set; }
        public Boolean support { get; set; }
        public String supportRatio { get; set; }
        public Decimal qtyYTD { get; set; }
        public Decimal qtyLYTD { get; set; }
        public Decimal qtyVariance { get; set; }
        public Decimal salesYTD { get; set; }
        public Decimal salesLYTD { get; set; }
        public String salesVariance { get; set; }
        public cItemTotalSales(String a, String b, Boolean c, String d, Decimal e, Decimal f, Decimal g, Decimal h, Decimal i, String j) {
            this.item = a;
            this.itemcode = b;
            this.support = c;
            this.supportRatio = d;
            this.qtyYTD = e;
            this.qtyLYTD = f;
            this.qtyVariance = g;
            this.salesYTD = h;
            this.salesLYTD = i;
            this.salesVariance = j;
        }
    }

//Wrapper Class for Category Percentage
    public class cCategoryBD {
        public String category { get; set; }
        public Decimal value { get; set; }
        public Decimal percent { get; set; }
        public String percentage { get; set; }
        public cCategoryBD(String a, Decimal b, Decimal c, String d) {
            this.category = a;
            this.value = b;
            this.percent = c;
            this.percentage = d;
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

//Wrapper Class for Training Objects
    public class tableData {
        public String a1 { get; set; }
        public String a2 { get; set; }
        public String a3 { get; set; }
        public String a4 { get; set; }
        public String a5 { get; set; }
        public tableData(String a, String b, String c, String d, String e) {
            this.a1 = a;
            this.a2 = b;
            this.a3 = c;
            this.a4 = d;
            this.a5 = e;
        }
    }

}