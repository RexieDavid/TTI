public without sharing class StoreActionChecklistController {
    private static final String DEFAULT_RESPONSE_TOTAL_TIME = '8 hrs 0 mins ,480';

    @AuraEnabled
    public static String getTotalTime(Id eventId) {
        Event ev = [SELECT Id, StartDateTime, EndDateTime, IsAllDayEvent FROM Event WHERE Id = :eventId LIMIT 1];
        if (ev.IsAllDayEvent) {
            return DEFAULT_RESPONSE_TOTAL_TIME;
        }

        Integer daysDiff = ev.StartDateTime.date().daysBetween(ev.EndDateTime.date());
        Integer hoursDiff = ev.EndDateTime.hour() - ev.StartDateTime.hour();
        hoursDiff += daysDiff * 24;
        Integer minDiff = ev.EndDateTime.minute() - ev.StartDateTime.minute();
        String totalTime  = String.valueOf(hoursDiff) + ' hrs ' + String.valueOf(minDiff) + ' mins ';
        if (totalTime.containsIgnoreCase('-')) {
            totalTime = totalTime.remove('-');
        }

        Integer totalMinute = (hoursDiff * 60) + minDiff;
        String totalMinuteInString = String.valueOf(totalMinute); 

        return totalTime + ',' + totalMinuteInString;
    }

    @AuraEnabled
    public static List<Store_Action_Checklist__c> getChecklist(Id eventId) {
        return [SELECT Id, 
                       Title__c, 
                       Parent_Event__c,
                       Parent_Event_Name__c,
                       AccountId__c,
                       TimeTaken__c, 
                       Summary__c, 
                       IsLocked__c, 
                       IsStandard__c, 
                       IsCompleted__c 
                FROM Store_Action_Checklist__c 
                WHERE Parent_Event__c =: eventId
                Order By IsStandard__c desc];
    }

    @AuraEnabled
    public static List<Department_Detail__c> getDeptDetails(Id eventId) {
        return [SELECT Id,
                        Floorcare_Department_Time__c,
                        Garden_Department_Time__c,
                        Other_Department_Time__c,
                        Tools_Department_Time__c
                FROM Department_Detail__c
                WHERE Event_ID__c =: eventId
                LIMIT 1];
    }

    @AuraEnabled
    public static List<Off_Location__c> getOffLocation(Id accId, Id recordId){
        return [SELECT Id,
                    Name,
                    Off_Location_Product__r.Name,
                    SAP_Material_Number__c,
                    Bunnings_Fineline__c,
                    Trade_Area__c,
                    In_store_Location__c
                FROM Off_Location__c
                WHERE Account__c =: accId
                AND Status__c = 'Active'
                AND Event__c !=: recordId
                ORDER BY CreatedDate];
    }

    @AuraEnabled
    public static string doSaveChecklistActionItems(String inputArgument, String deptDetails) { 
        string result = 'SUCCESS';
        StoreChecklistSavedArgument inputWrapperJson = (StoreChecklistSavedArgument) System.JSON.deserialize(inputArgument, StoreChecklistSavedArgument.class);
        string outcome = saveStandardChecklist(inputWrapperJson.savedchecklist);
        if (outcome != result) {
            return outcome;
        }

        Store_Action_Checklist__c firstStandardChecklist = inputWrapperJson.savedchecklist[0];
        Event ev = [SELECT Id FROM Event WHERE Id = :firstStandardChecklist.Parent_Event__c LIMIT 1];
        ev.Objective_Checklist_Completed__c = true;
        update ev;

        System.debug('deptDetails: ' + deptDetails);
        DepartmentDetailsList deptWrapper = (DepartmentDetailsList) System.JSON.deserialize(deptDetails, DepartmentDetailsList.class);
        string response = saveDeptDetails(deptWrapper);
        if (response != result) {
            return response;
        }

        List<OtherStoreActionChecklistItem> otherChecklistItems = inputWrapperJson.otherItems;
        List<Store_Action_Checklist__c> checklistToBeAdded = new List<Store_Action_Checklist__c>();
        for (OtherStoreActionChecklistItem otherItem : otherChecklistItems) {
            if(otherItem.isDeleted) { 
                continue;
            }

            Store_Action_Checklist__c otherChecklist = new Store_Action_Checklist__c();
            otherChecklist.Parent_Event__c = firstStandardChecklist.Parent_Event__c;
            otherChecklist.Parent_Event_Name__c = firstStandardChecklist.Parent_Event_Name__c;
            otherChecklist.AccountId__c = firstStandardChecklist.AccountId__c;
            otherChecklist.Title__c = otherItem.title;
            otherChecklist.Summary__c = otherItem.summary;
            otherChecklist.IsStandard__c = false;
            otherChecklist.TimeTaken__c = otherItem.timeTaken;
            otherChecklist.IsCompleted__c = true;
            otherChecklist.IsLocked__c = true;
            checklistToBeAdded.add(otherChecklist);
        }

        try {
            insert checklistToBeAdded;
        } 
        catch(DmlException e) { 
            result = 'Operation Failed - '+ e.getMessage();
        }
        return result;
    }

    @AuraEnabled
    public static string doSaveOffLocationChanges(String inputArgument, String action, Id recordId){
        string result = 'SUCCESS';
        Boolean hasChanges = false;

        Off_Location__c[] offLocationList = (Off_Location__c[]) JSON.deserialize(inputArgument, List<Off_Location__c>.class);
        System.debug('action: ' + action);
        if('Reviewed'.equalsIgnoreCase(action)) {
            for(Off_Location__c rec : offLocationList) {
                rec.Reviewed__c = true;
                rec.Event__c = recordId;
            }
            hasChanges = true;
        }
        if('Deactivate'.equalsIgnoreCase(action)) {
            for(Off_Location__c rec : offLocationList) {
                rec.Active__c = false;
            }
            hasChanges = true;
        }

        if(hasChanges) {
            try {
                update offLocationList;
            } catch (Exception e) {
                result = 'Operation Failed - '+ e.getMessage();
            }
        }
        return result;
    }

    private static string saveStandardChecklist(List<Store_Action_Checklist__c> savedchecklist) { 
        string result = 'SUCCESS';
        try { 
            for (Store_Action_Checklist__c storeChecklist : savedchecklist) {
                storeChecklist.IsCompleted__c = true;
                storeChecklist.IsLocked__c = true;
            }
            update savedchecklist;
        } 
        catch(DmlException e) { 
            result = 'Operation Failed - '+ e.getMessage();
        }

        return result;
    }

    private static string saveDeptDetails(DepartmentDetailsList deptWrapper) { 
        string result = 'SUCCESS';
        try { 
            Id deptId = deptWrapper.deptId;
            Department_Detail__c rec = new Department_Detail__c();
            rec.Id = deptId;
            List<DepartmentDetailsItem> deptDetails = deptWrapper.departmentDetails;
            System.debug('deptDetails: ' + deptDetails);
            for(DepartmentDetailsItem dept : deptDetails) {
                system.debug('dept: ' + dept);
                if(dept.name == 'Builders') rec.Tools_Department_Time__c = dept.timeTaken;
                if(dept.name == 'Floorcare') rec.Floorcare_Department_Time__c = dept.timeTaken;
                if(dept.name == 'Power Garden') rec.Garden_Department_Time__c = dept.timeTaken;
                if(dept.name == 'Others') rec.Other_Department_Time__c = dept.timeTaken;
            }
            System.debug('deptRec: ' + rec);
            update rec;
        } 
        catch(DmlException e) { 
            result = 'Operation Failed - '+ e.getMessage();
        }

        return result;
    }

    public class StoreChecklistSavedArgument { 
        @AuraEnabled public List<StoreActionChecklistController.OtherStoreActionChecklistItem> otherItems {get;set;}
        @AuraEnabled public List<Store_Action_Checklist__c> savedchecklist {get;set;}       
    }

    public class OtherStoreActionChecklistItem { 
        @AuraEnabled public String parentEventId {get;set;}
        @AuraEnabled public String parentEventName {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public string title {get;set;}
        @AuraEnabled public String summary {get;set;}        
        @AuraEnabled public Decimal timeTaken {get;set;}
        @AuraEnabled public string isLocked {get;set;}
        @AuraEnabled public string isStandard {get;set;}
        @AuraEnabled public string isCompleted {get;set;}
        @AuraEnabled public Boolean isDeleted {get;set;} //used for internal Remove Button - if this flag is true, item will not be created
    }

    public class DepartmentDetailsList {
        @AuraEnabled public Id deptId {get;set;}
        @AuraEnabled public List<DepartmentDetailsItem> departmentDetails {get;set;}
    }
    public class  DepartmentDetailsItem {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Decimal timeTaken {get;set;}
        /*@AuraEnabled public Decimal floorcareTime {get;set;}
        @AuraEnabled public Decimal gardenTime {get;set;}
        @AuraEnabled public Decimal otherTime {get;set;}
        @AuraEnabled public Decimal toolsTime {get;set;}*/
    }

    public class OffLocationArgument {
        @AuraEnabled
        public List<Off_Location__c> offLocationList {get;set;}
    }
    
}