/**
* @author Anuja Singh
* @date 2021-12-07
* @description create store visit checklist on a new Event creation
*/
public class CreateStoreVisitChecklist {
    /**
    * 
	* @description 
    */ 
    public static void createSVC(List <Event> newEventRecords) {
        
        Action_Plan_Template_Header__c planTemplateHeader = getplanTemplateHeader(newEventRecords);
        Id planTemplateHeaderID = planTemplateHeader.id;
       // Map<Id, Action_Plan_Template__c> PlanTemplateMap = getactionPlanTemplate(planTemplateHeaderID);
        //system.debug('getactionPlanTemplate ::'+PlanTemplateMap.size());
        
    }
    
     /**
    * 
	* @description 
    */ 
    public static Action_Plan_Template_Header__c getplanTemplateHeader(List <Event> newEventRecords) {
        User userchannel = [SELECT id,Name,Channel__c from User where id =: UserInfo.getUserId()];
        Id StoreVisitTemplateRecTypeId = Schema.SObjectType.Action_Plan_Template_Header__c.getRecordTypeInfosByName().get('Store Visit Template').getRecordTypeId();
        if(userchannel.Channel__c != null && StoreVisitTemplateRecTypeId != null){        	
                List<Action_Plan_Template_Header__c> planTemplateHeader = [SELECT id 
                                                                   FROM Action_Plan_Template_Header__c 
                                                                   WHERE IsActive__c = true
                                                                   AND RecordTypeId = :StoreVisitTemplateRecTypeId
                                                                   AND Sales_Representative_Channel__c =: userchannel.Channel__c
                                                                   order by createddate DESC limit 1];
        return planTemplateHeader.isEmpty() ? null : planTemplateHeader.get(0);
        }
        else
        {
            return null;
        }
    }
     /**
    * 
	* @description 
    */ 
    public static Map<Id, list<Action_Plan_Template__c>> getactionPlanTemplate(id planTemplateHeaderID) {
       	system.debug('PlanTemplateMap ::'+planTemplateHeaderID);
        Map<Id, list<Action_Plan_Template__c>> PlanTemplateMap = new Map<id, list<Action_Plan_Template__c>>(); 
		for(Action_Plan_Template__c actionPlanTemplate : [SELECT id,Name,
                                                          Action_Plan_Header_Template_Id__c,
                                                          Title__c,
                                                          Summary__c
                                                          FROM Action_Plan_Template__c 
                                                          WHERE Action_Plan_Header_Template_Id__c =: planTemplateHeaderID])
            if(PlanTemplateMap.containskey(actionPlanTemplate.Action_Plan_Header_Template_Id__c)) { 
        //PlanTemplateMap.add(actionPlanTemplate.Action_Plan_Header_Template_Id__c, actionPlanTemplate);
            system.debug('PlanTemplateMap ::'+PlanTemplateMap);
        }
        
        return PlanTemplateMap.isEmpty() ? null : PlanTemplateMap;
    }
}