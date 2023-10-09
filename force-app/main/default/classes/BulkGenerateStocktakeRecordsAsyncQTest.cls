/**
* @author: Christopher Camilon
* @date: 2018-11-26
* @description: This class handles test class for bulkGen method in StocktakeGenController
*/
@isTest
private class BulkGenerateStocktakeRecordsAsyncQTest {

    /**********************************************************************
    * @description To run queclass from a user with a Stocktake record  
    */
    public static testMethod void testBulkGenerateStocktakeRecordsAsyncQ() {    

        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];        
      
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = sp.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'teststandard@testing.com', TTI_SAP_Cust_No__c = '12345', Division = 'Industrial', NVMContactWorld__NVM_Agent_Id__c = '12341');
        insert u;
   
        System.runAs(u) {
            
            String currQtr = 'QTR1';
            Integer mnth = Date.Today().month();
            if (mnth == 4 || mnth == 5 || mnth == 6 ) {
                currQtr = 'QTR2';    
            } else if (mnth == 7 || mnth == 8 || mnth == 9) {
                currQtr = 'QTR3';
            } else if (mnth == 10 || mnth == 11 || mnth == 12) {
                currQtr = 'QTR4';
            }
            String stid = '' + u.Id + '-001-' + currQtr + '-' + Date.Today().Year();
            Stocktake__c stc = new Stocktake__c(Active__c = true, Date_Submitted__c = Date.Today(), Due_Date__c = Date.Today().addDays(3), Stocktake_Identity__c = stid, Submitted__c = true );
            insert stc;
            
            Inventory__c Inv = new Inventory__c (
            Inventory_Link__c = u.TTI_SAP_Cust_No__c + '-Test',
                    Quantity__c = 1,
                    Status__c = 'Active',
                    Ownerid = u.Id);
            insert Inv;
            Test.startTest();
            BulkGenerateStocktakeRecordsAsyncQ  bgst = new BulkGenerateStocktakeRecordsAsyncQ(currQtr, Date.Today().Year());
            ID jobID = System.EnqueueJob(bgst);    
         
            Test.stopTest();
            List<Stocktake_Items__c> stList = [SELECT Id FROM Stocktake_Items__c];
            System.AssertEquals(1, stList.size());
        }
    }
    
    /**********************************************************************
    * @description To run queclass from a user without a Stocktake record  
    */    
    public static testMethod void testtestBulkGenerateStocktakeRecordsAsyncQ2() {
    
        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];
        
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = sp.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'teststandard@testing.com', TTI_SAP_Cust_No__c = '12345', Division = 'Industrial', NVMContactWorld__NVM_Agent_Id__c = '12341');
        insert u;
   
        System.runAs(u) {

            String currQtr = 'QTR1';
            Integer mnth = Date.Today().month();
            if (mnth == 4 || mnth == 5 || mnth == 6 ) {
                currQtr = 'QTR2';    
            } else if (mnth == 7 || mnth == 8 || mnth == 9) {
                currQtr = 'QTR3';
            } else if (mnth == 10 || mnth == 11 || mnth == 12) {
                currQtr = 'QTR4';
            }
            
           
            Inventory__c Inv = new Inventory__c (Inventory_Link__c = u.TTI_SAP_Cust_No__c + '-Test', Quantity__c = 1, Status__c = 'Active',  Ownerid = u.Id);
            insert Inv;
            Test.startTest();       
            BulkGenerateStocktakeRecordsAsyncQ  bgst = new BulkGenerateStocktakeRecordsAsyncQ(currQtr, Date.Today().Year());
            ID jobID = System.enqueueJob(bgst);     
            Test.stopTest();
            List<Stocktake_Items__c> stList = [SELECT Id FROM Stocktake_Items__c];
            System.AssertEquals(1, stList.size());
        }
        
    }
    

    public static testMethod void testsendEmail() {
           
        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];
        
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = sp.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'teststandard@testing.com', TTI_SAP_Cust_No__c = '12345', Division = 'Industrial', NVMContactWorld__NVM_Agent_Id__c = '12341');
        insert u;
   
        System.runAs(u) {
            Test.startTest();
            String currQtr = 'QTR1';
            Integer mnth = Date.Today().month();
            if (mnth == 4 || mnth == 5 || mnth == 6 ) {
                currQtr = 'QTR2';    
            } else if (mnth == 7 || mnth == 8 || mnth == 9) {
                currQtr = 'QTR3';
            } else if (mnth == 10 || mnth == 11 || mnth == 12) {
                currQtr = 'QTR4';
            }
            Map<String, String> executionStatus = new Map<String, String>{
                'success' => 'false',
                'message' => '',
                'stackTrace' => '',
                'duration' => ''
            };
            executionStatus.put('message', 'test only');
            executionStatus.put('success', 'true');
            executionStatus.put('duration', '10');  
            BulkGenerateStocktakeRecordsAsyncQ.sendEmail(executionStatus);
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            System.assertEquals(1, invocations, 'An email should be sent');
        }
    }
    
    public static testMethod void testbuildEmailDetails() {
             
        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = sp.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'teststandard@testing.com', TTI_SAP_Cust_No__c = '12345', Division = 'Industrial', NVMContactWorld__NVM_Agent_Id__c = '12341');
        insert u;
   
        System.runAs(u) {
            Test.startTest();
            String currQtr = 'QTR1';
            Integer mnth = Date.Today().month();
            if (mnth == 4 || mnth == 5 || mnth == 6 ) {
                currQtr = 'QTR2';    
            } else if (mnth == 7 || mnth == 8 || mnth == 9) {
                currQtr = 'QTR3';
            } else if (mnth == 10 || mnth == 11 || mnth == 12) {
                currQtr = 'QTR4';
            }
            Map<String, String> executionStatus = new Map<String, String>{
                'success' => 'false',
                'message' => '',
                'stackTrace' => '',
                'duration' => ''
                };
            executionStatus.put('message', 'test only');
            executionStatus.put('success', 'true');
            executionStatus.put('duration', '10');     
            Map<String, String> bgst = BulkGenerateStocktakeRecordsAsyncQ.buildEmailDetails(executionStatus);           
            String testMap =   bgst.get('body');  
            System.assertEquals(true, testMap.contains('test only'));
            Test.stopTest();
        }
    }  
    
    /**********************************************************************
    * @description To test method if called with error  
    */  
    public static testMethod void testbuildEmailDetailswithError() {
             
        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = sp.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'teststandard@testing.com', TTI_SAP_Cust_No__c = '12345', Division = 'Industrial', NVMContactWorld__NVM_Agent_Id__c = '12341');
        insert u;
   
        System.runAs(u) {
            Test.startTest();
            String currQtr = 'QTR1';
            Integer mnth = Date.Today().month();
            if (mnth == 4 || mnth == 5 || mnth == 6 ) {
                currQtr = 'QTR2';    
            } else if (mnth == 7 || mnth == 8 || mnth == 9) {
                currQtr = 'QTR3';
            } else if (mnth == 10 || mnth == 11 || mnth == 12) {
                currQtr = 'QTR4';
            }
            Map<String, String> executionStatus = new Map<String, String>{
                'success' => 'false',
                'message' => '',
                'stackTrace' => '',
                'duration' => ''
                };
            executionStatus.put('message', 'test only');
            executionStatus.put('stackTrace', 'error test');           
            Map<String, String> bgst = BulkGenerateStocktakeRecordsAsyncQ.buildEmailDetails(executionStatus);           
            String testMap = bgst.get('body');  
            System.assertEquals(true, testMap.contains('test only'));
            Test.stopTest();
        }
    }  
    
}