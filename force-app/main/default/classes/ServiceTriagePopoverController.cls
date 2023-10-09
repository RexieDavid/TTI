/**
* @author           Francis Nasalita
* @date             2021-04-16
* @description      Service Triage Popover Controller
*/
public with sharing class ServiceTriagePopoverController {
    
    @AuraEnabled
    public static Case getCaseRecord(Id recordId) {
        return [SELECT Description, Subject FROM Case WHERE Id = :recordId LIMIT 1];
    }
}