@isTest
public class MILRedemptionDetailsBatchTest {

    private static Id recType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();

    @isTest
    public static void testSchedule() {
        Test.StartTest();
            MILRedemptionDetailsScheduler sh1 = new MILRedemptionDetailsScheduler();
            String sch = '0 0 23 * * ?'; 
            System.schedule('Test batch', sch, sh1); 
        Test.stopTest(); 
    }

    @isTest
    public static void batchTest() {
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Record_Status__c = 'Active';
        acc.TTI_SAP_Cust_No__c = '303085';
        acc.RecordTypeId = recType;
        insert acc;

        Redemption_Campaigns__c redCamp= new Redemption_Campaigns__c();
        insert redCamp;

        Redemptions__c redemption = new Redemptions__c();
        redemption.SAP_Order_Number__c = '0012345';
        redemption.Store_Name__c = acc.Id;
        redemption.Redemption_Campaign__c = redCamp.Id;
        insert redemption;

        SF_Order_DetailsSet__x order = new SF_Order_DetailsSet__x();
        order.IVbeln__c = '0012345';
        order.Carrier__c = 'AUS';
        order.ConNote__c = 'W6S1106856';
        Database.insertAsync(order);

        Test.startTest();
			String soql ='SELECT Id, SAP_Order_Number__c FROM Redemptions__c WHERE Carrier_Tracking_Number__c = null AND SAP_Order_Number__c != null';
            MILRedemptionDetailsBatch obj = new MILRedemptionDetailsBatch(soql);
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }

    @isTest
    public static void setRedemptionDetailsTest() {
        Map<String, Redemptions__c> redemptionMap = new  Map<String, Redemptions__c>();
        Redemptions__c redemption = new Redemptions__c();
        redemption.SAP_Order_Number__c = '0012345';
        redemptionMap.put(redemption.SAP_Order_Number__c, redemption);

        Map<String, SF_Order_DetailsSet__x> orderMap = new Map<String, SF_Order_DetailsSet__x>();
        SF_Order_DetailsSet__x order = new SF_Order_DetailsSet__x();
        order.IVbeln__c = '0012345';
        order.Carrier__c = 'AUS';
        order.ConNote__c = 'W6S1106856';
        orderMap.put(order.IVbeln__c, order);

        redemptionMap = MILRedemptionDetailsHelper.setRedemptionDetails(redemptionMap, orderMap);
        System.assertEquals('AUS', redemptionMap.get('0012345').Carrier_Code__c);
        System.assertEquals('W6S1106856', redemptionMap.get('0012345').Carrier_Tracking_Number__c);
    }
}