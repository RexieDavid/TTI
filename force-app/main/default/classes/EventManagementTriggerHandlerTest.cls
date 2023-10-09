/**
* @author Edgar Dalupan
* @date 2018-10-16
* @description Test class for the Event Management trigger handler
*/
@isTest
public class EventManagementTriggerHandlerTest {

    static testMethod void updateDateFieldsTest() {
        
        Event_Management__c testEM = new Event_Management__c();
        testEM.Event_Location__c = 'Victoria';
        testEM.Location_Type__c = 'Single Location';
        testEM.Start_Date_Time__c = Datetime.newInstance(2018, 1, 1, 12, 30, 0);
        testEM.End_Date_Time__c = Datetime.newInstance(2018, 1, 1, 13, 30, 0);
        insert testEM;

        // ---------------------------------------
        // SCENARIO: Insert

        testEM = [SELECT Start_Date_Date_Only_TEXT__c, End_Date_Date_Only_TEXT__c 
                    FROM Event_Management__c 
                   LIMIT 1].get(0);

        System.assertEquals('2018-01-01 12:30:00', testEM.Start_Date_Date_Only_TEXT__c);
        System.assertEquals('2018-01-01 13:30:00', testEM.End_Date_Date_Only_TEXT__c);

        // ---------------------------------------
        // SCENARIO: Update

        testEM.Start_Date_Time__c = Datetime.newInstance(2018, 1, 1, 14, 30, 0);
        testEM.End_Date_Time__c = Datetime.newInstance(2018, 1, 1, 15, 30, 0);
        update testEM;

        testEM = [SELECT Start_Date_Date_Only_TEXT__c, End_Date_Date_Only_TEXT__c 
                    FROM Event_Management__c 
                   LIMIT 1].get(0);
        
        System.assertEquals('2018-01-01 14:30:00', testEM.Start_Date_Date_Only_TEXT__c);
        System.assertEquals('2018-01-01 15:30:00', testEM.End_Date_Date_Only_TEXT__c);
    }
}