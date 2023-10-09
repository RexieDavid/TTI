/**
* @author: Christopher Camilon
* @date: November 2018
* @description: Test class for TriggerHelperClass
*/
@isTest
private class TriggerHelperClassTest {   

    @isTest
    static void hasAlreadyfiredTest() {
        Test.startTest();
        Boolean triggerflag = TriggerHelperClass.hasAlreadyfired();
        System.assertEquals(false, triggerflag);
        Test.stopTest();
    }
    
    @isTest
    static void setAlreadyfiredtesT() {
        Test.startTest();
        TriggerHelperClass.setAlreadyfired();
        Boolean triggerflag = TriggerHelperClass.hasAlreadyfired();        
        System.assertEquals(true, triggerflag);
        Test.stopTest();
    }
}