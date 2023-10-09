@isTest
private class MilwaukeeBatteryControllerTest {
  
  //Dynamic method to get Record type id
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName(); //Generate a map of tokens for all the Record Types for the desired object
       return recordTypeInfo.get(recordTypeName).getRecordTypeId(); //Retrieve the record type id by name
    }

    @testSetup static void setup() {
      Account acc = new Account(Firstname = 'Loven', Lastname = 'Reyes', PersonEmail = 'lovenreyes@ttibrands.com', PersonMobilePhone = '0912412512', Country__pc = 'Australia', Brand__pc = 'Milwaukee', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'));
      insert acc;
    }

    static testMethod void testdoSubmit() {
      Account acc = [SELECT Name, PersonEmail, PersonMobilePhone, Country__pc, Brand__pc, RecordTypeId FROM Account WHERE Name =: 'Loven Reyes' LIMIT 1];

      PageReference pageRef = Page.MilwaukeeBattery;
        Test.setCurrentPage(pageRef);

        MilwaukeeBatteryController con = new MilwaukeeBatteryController();
        con.firstName = 'Loven';
        con.lastName = 'Reyes';
        con.emailAdd = 'lovenreyes@ttibrands.com';
        con.contactNumber = '012951928312';
        con.contactCountry = 'Australia';
        con.productName = 'M18B9';
        con.productQuantity = '23';
        con.productDatePurchased = String.valueOf(Date.newInstance(2016, 12, 9));
        con.productDescription = 'battery not working';

        con.doSubmit();
    }

    static testMethod void testDuplicate() {
      Account acc = [SELECT Name, PersonEmail, PersonMobilePhone, Country__pc, Brand__pc, RecordTypeId FROM Account WHERE Name =: 'Loven Reyes' LIMIT 1];

      PageReference pageRef = Page.MilwaukeeBattery;
        Test.setCurrentPage(pageRef);

        MilwaukeeBatteryController con = new MilwaukeeBatteryController();
        con.firstName = 'Loven';
        con.lastName = 'Reyes';
        con.emailAdd = 'lovenreyes@ttibrands.com';
        con.contactNumber = '0912412512';
        con.contactCountry = 'Australia';
        con.productName = 'M18B9';
        con.productQuantity = '35';
        con.productDatePurchased = String.valueOf(Date.newInstance(2017, 12, 7));
        con.productDescription = 'battery not working';

        con.doSubmit();
    }

    static testMethod void testIfElse() {
      Account acc = [SELECT Name, PersonEmail, PersonMobilePhone, Country__pc, Brand__pc, RecordTypeId FROM Account WHERE Name =: 'Loven Reyes' LIMIT 1];

      PageReference pageRef = Page.MilwaukeeBattery;
        Test.setCurrentPage(pageRef);

        MilwaukeeBatteryController con = new MilwaukeeBatteryController();
        con.firstName = '';
        con.lastName = '';
        con.emailAdd = '';
        con.contactNumber = '';
        con.contactCountry = '';

        con.doSubmit();
    }
}