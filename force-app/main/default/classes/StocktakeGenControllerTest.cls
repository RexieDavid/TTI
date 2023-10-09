/**
* @author: Christopher Camilon
* @date: 2018-11-26
* @description: This class handles test class for bulkGen method in StocktakeGenController
*/
@isTest
private class StocktakeGenControllerTest {

    /**********************************************************************
    * @description To test bulkGen method from a user with a Stocktake record  
    */
    public static testMethod void bulkGenTest1() {
    
        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];       
   
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
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
           
            String stid = '' + u.Id + '-001-' + currQtr + '-' + Date.Today().Year();
            Stocktake__c stc = new Stocktake__c(Active__c = false, Date_Submitted__c = Date.Today(), Due_Date__c = Date.Today().addDays(3), Stocktake_Identity__c = stid, Submitted__c = true );
            insert stc;
            
            PageReference pageRef = Page.vf_Stocktake;            
            Test.setCurrentPage(pageRef);
            StocktakeGenController stgc = new StocktakeGenController();
            stgc.bulkQtr = currQtr;
            stgc.bulkYr = Date.Today().Year();
            stgc.bulkGen();
            Boolean testCheck = false;
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for (ApexPages.Message msg :  ApexPages.getMessages()) {
                if (msg.getSummary().contains('Stocktake have been found for this Quarter.') && msg.getSeverity() == ApexPages.Severity.ERROR) {
                    System.AssertEquals(msg.getSummary(), 'Stocktake have been found for this Quarter. Please check if stocktake has been previously run for: ' + currQtr + '-' + Date.Today().Year() + ' (Total records found:1)');
                    testCheck = true;
                }
                
            }
            System.AssertEquals(true, testCheck); 
            Test.stopTest();
        }
  
    }
    
    /**********************************************************************
    * @description To test bulkGen method from a user without a Stocktake record  
    */
    public static testMethod void bulkGenTest2() {

        Profile sp = [SELECT Id FROM Profile WHERE Name = '~Industral BDM Sales'];       
        
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
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
           
                     
            PageReference pageRef = Page.vf_Stocktake;            
            Test.setCurrentPage(pageRef);
            StocktakeGenController stgc = new StocktakeGenController();
            stgc.bulkQtr = currQtr;
            stgc.bulkYr = Date.Today().Year();
            stgc.bulkGen();
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            Boolean testCheck = false;
            for (ApexPages.Message msg :  ApexPages.getMessages()) {
                if (msg.getSummary().contains('Bulk stocktake generation runs a bit longer') && msg.getSeverity() == ApexPages.Severity.CONFIRM) {                    
                    System.AssertEquals(msg.getSummary(), 'Bulk stocktake generation runs a bit longer than the other processes. We are processing it for you right now. We\'ll send you an email once done. Thank you.');
                    testCheck = true;
                }
            }
            
            System.AssertEquals(true, testCheck); 
            Test.stopTest();
            
        }  
        
    }
    
}