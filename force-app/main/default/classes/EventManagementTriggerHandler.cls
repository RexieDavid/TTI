/**
* @author Edgar Dalupan
* @date 2018-10-16
* @description Will update the text versions of both Start and End date fields.
*/
public class EventManagementTriggerHandler {

    /**
    * @author: Samuel Oberes
    * @date: 2018-12-06
    * @description: This method handles all methods that should be invoked in the Before Insert context
    */ 
    public static void onBeforeInsert(List<Event_Management__c> newEventManagementRecords) {
        updateDateFields(newEventManagementRecords);
    }

    /**
    * @author: Samuel Oberes
    * @date: 2018-12-06
    * @description: This method handles all methods that should be invoked in the Before Update context
    */ 
    public static void onBeforeUpdate(List<Event_Management__c> newEventManagementRecords) {
        updateDateFields(newEventManagementRecords);
    }

    /**
    * @author: Edgar Dalupan
    * @date 2018-10-16
    * @description: Updates the start date and end date text fields
    */ 
    private static void updateDateFields(List<Event_Management__c> emList) {
        for (Event_Management__c emObj : emList) {
            emObj.Start_Date_Date_Only_TEXT__c = String.valueOf(emObj.Start_Date_Time__c);
            emObj.End_Date_Date_Only_TEXT__c = String.valueOf(emObj.End_Date_Time__c);
        }
    }

}