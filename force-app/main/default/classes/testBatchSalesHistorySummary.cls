@isTest
private class testBatchSalesHistorySummary {

    static testMethod void testBatch () {
        System.debug('***** START: testBatchSalesHistorySummary *****');

    // Create Products
        List<Product2> pList = new List<Product2>();
        //Shockwave
            Product2 p1 = new Product2();
            p1.Name = 'P1';
            p1.Brand__c = 'ML';
            p1.Category__c = 'PT';
            p1.Sub_Category__c = 'ACS';
            p1.Product_Category__c = 'SBT';
            pList.add(p1);
        //Sawzall
            Product2 p2 = new Product2();
            p2.Name = 'P2';
            p2.Brand__c = 'ML';
            p2.Category__c = 'PT';
            p2.Sub_Category__c = 'ACS';
            p2.Product_Category__c = 'RBL';
            pList.add(p2);
        //Holesaws
            Product2 p3 = new Product2();
            p3.Name = 'P3';
            p3.Brand__c = 'ML';
            p3.Category__c = 'PT';
            p3.Sub_Category__c = 'ACS';
            p3.Product_Category__c = 'HOS';
            pList.add(p3);
        //Carbide
            Product2 p4 = new Product2();
            p4.Name = 'P4';
            p4.Brand__c = 'ML';
            p4.Category__c = 'PT';
            p4.Sub_Category__c = 'ACS';
            p4.Product_Category__c = 'SDP';
            pList.add(p4);
        //Wooddrill
            Product2 p5 = new Product2();
            p5.Name = 'P5';
            p5.Brand__c = 'ML';
            p5.Category__c = 'PT';
            p5.Sub_Category__c = 'ACS';
            p5.Product_Category__c = 'FSA';
            pList.add(p5);
        //Handtools
            Product2 p6 = new Product2();
            p6.Name = 'P6';
            p6.Brand__c = 'ML';
            p6.Category__c = 'HT';
            p6.Sub_Category__c = 'NPW';
            p6.Product_Category__c = 'HTO';
            pList.add(p6);
        //Other Acs
            Product2 p7 = new Product2();
            p7.Name = 'P7';
            p7.Brand__c = 'ML';
            p7.Category__c = 'PT';
            p7.Sub_Category__c = 'ACS';
            p7.Product_Category__c = 'WKL';
            pList.add(p7);
        //M12
            Product2 p8 = new Product2();
            p8.Name = 'P8';
            p8.Brand__c = 'ML';
            p8.Category__c = 'PT';
            p8.Sub_Category__c = '12L';
            p8.Product_Category__c = 'BAT';
            pList.add(p8);
        //M18
            Product2 p9 = new Product2();
            p9.Name = 'P9';
            p9.Brand__c = 'ML';
            p9.Category__c = 'PT';
            p9.Sub_Category__c = '18L';
            p9.Product_Category__c = 'BAT';
            pList.add(p9);
        //Hammer
            Product2 p10 = new Product2();
            p10.Name = 'P10';
            p10.Brand__c = 'ML';
            p10.Category__c = 'PT';
            p10.Sub_Category__c = 'ACE';
            p10.Product_Category__c = 'RHM';
            pList.add(p10);
        //Grinders
            Product2 p11 = new Product2();
            p11.Name = 'P11';
            p11.Brand__c = 'ML';
            p11.Category__c = 'PT';
            p11.Sub_Category__c = 'ACE';
            p11.Product_Category__c = 'AGR';
            pList.add(p11);
        //AC other
            Product2 p12 = new Product2();
            p12.Name = 'P12';
            p12.Brand__c = 'ML';
            p12.Category__c = 'PT';
            p12.Sub_Category__c = 'ACE';
            p12.Product_Category__c = 'ROS';
            pList.add(p12);
        //Other Tools
            Product2 p13 = new Product2();
            p13.Name = 'P13';
            p13.Brand__c = 'ML';
            p13.Category__c = 'PT';
            p13.Sub_Category__c = '28L';
            p13.Product_Category__c = 'BAT';
            pList.add(p13);
        //Insert Products   
        try{
            System.debug('pre insert: ' + pList);
            insert pList;
            System.debug('post insert: ' + pList);
        } catch (DmlException e){
            System.debug(e.getMessage());
        }

    // Create new Accounts
        List<Account> aList = new List<Account>();
        for (Integer i=1; i<=5; i++){
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            a.Customer_Group_4__c = 'TEST';
            a.Type='Retailer' ;
            a.Record_Status__c = 'Active';
            aList.add(a);
        }
        try{
            System.debug('pre insert: ' + aList);
            insert aList;
            System.debug('post insert: ' + aList);
        } catch (DmlException e){
            System.debug(e.getMessage());
        }

        // Account ID list for batch
        List<Id> idList = new List<Id>();

    // Create new Sales History
        RecordType recType = [SELECT Id from RecordType WHERE SobjectType = 'Sales_History__c' AND DeveloperName = 'Sales'];
        Date dateCYTD = date.newInstance(2022,3,15);

        List<Sales_History__c> shList = new List<Sales_History__c>();
        for (Account a:aList){
            idList.add(a.Id);//populate Account Id list for Batch run
            //Current Years Sales History
            for (Product2 p:pList){
                Sales_History__c sh = new Sales_History__c();
                sh.Posting_Date__c = Date.today();
                sh.Product__c = p.Id;
                sh.Sold_To__c = a.Id;
                sh.Qty__c = 1;
                sh.Revenue__c = 1;
                sh.RecordTypeId = recType.Id;
                shList.add(sh);
            }
            //Last Years Sales History
            for (Product2 p:pList){
                Sales_History__c sh = new Sales_History__c();
                sh.Posting_Date__c = Date.today().addDays(-365);
                sh.Product__c = p.Id;
                sh.Sold_To__c = a.Id;
                sh.Qty__c = 1;
                sh.Revenue__c = 1;
                sh.RecordTypeId = recType.Id;
                shList.add(sh);
            }
        }
        try{
            System.debug('pre insert: ' + shList);
            insert shList;
            System.debug('post insert: ' + shList);
        } catch (DmlException e){
            System.debug(e.getMessage());
        }

    //Test Batch & Scheduler
        Test.startTest();
        //batchSalesHistorySummary b = new batchSalesHistorySummary(idList);
        //Database.executeBatch(b); //Test just the batch
//*****************************
    // Schedule the test job
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new scheduledbatchSHS());

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.debug('CronTrigger ct: ' + ct);

    // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

    // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

    // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

    // Verify the scheduled job hasn't run yet.
        Integer expectedSHS = [SELECT Count() FROM SalesHistSummary__c WHERE Account__c IN :aList];
        System.assertEquals(expectedSHS,0);
//*****************************
        Test.stopTest();

    // Test SalesHistorySummary
        Integer expectedAccounts = [SELECT Count() FROM Account];
        System.debug('Accouunt List Size: ' + expectedAccounts);
        System.assertEquals(5,expectedAccounts);

        Integer expectedProducts = [SELECT Count() FROM Product2];
        System.debug('Product List Size: ' + expectedProducts);
        System.assertEquals(13,expectedProducts);       

        Integer expectedSalesHistory = [SELECT Count() FROM Sales_History__c];
        System.debug('Sales History List Size: ' + expectedSalesHistory);
        System.assertEquals(expectedSalesHistory, expectedAccounts * expectedProducts * 2);

        Integer expectedSHS1 = [SELECT Count() FROM SalesHistSummary__c];
        System.debug('Sales History Summary List Size: ' + expectedSHS1);

        Integer expectedSHScy = [SELECT Count() FROM SalesHistSummary__c WHERE Account__c IN :aList AND RecType__c = 'CYTD'];
        System.debug('Sales History Summary List Size CYTD: ' + expectedSHScy);
        
        Integer expectedSHSly = [SELECT Count() FROM SalesHistSummary__c WHERE Account__c IN :aList AND RecType__c = 'LYTD'];
        System.debug('Sales History Summary List Size LYTD: ' + expectedSHSly);

        //Test Sales History Summary Size
        //System.assertEquals(expectedAccounts * expectedProducts, expectedSHScy);
        //System.assertEquals(expectedAccounts * expectedProducts, expectedSHSly);
        System.debug('***** END: testBatchSalesHistorySummary *****');
    }
}