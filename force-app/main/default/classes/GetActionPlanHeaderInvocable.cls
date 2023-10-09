public without sharing class GetActionPlanHeaderInvocable {
   
    @InvocableMethod(label='Get Action Plan Template Header' description='Get Action Plan Template Header By User Channel' category='Util')
    public static List <Results> execute(List<Requests> requestList) {
        List<Results> responseWrapper = new List<Results>();
        for(Requests curRequest : requestList) {
            Results results = new Results();
            string actionPlanTemplateHeaderId = '';
            String userChannel = curRequest.userChannel;
            if(string.isNotBlank(userChannel))
            {
                List<Action_Plan_Template_Header__c> actionPlanTemplate = [SELECT Id 
                                                                            FROM Action_Plan_Template_Header__c 
                                                                            WHERE IsActive__c = true 
                                                                                AND Sales_Representative_Channel__c INCLUDES (:userChannel) 
                                                                                AND RecordType.DeveloperName = 'Store_Visit_Template' 
                                                                            order by lastModifieddate desc 
                                                                            LIMIT 1];            
                if (actionPlanTemplate.size() > 0) {
                    actionPlanTemplateHeaderId = actionPlanTemplate[0].Id;
                }
            }
            results.actionPlanTemplateHeaderId = actionPlanTemplateHeaderId;
            responseWrapper.add(results);
        }
        return responseWrapper;
    }
    public class Requests {
        @InvocableVariable(description='Logged-in user channel' required=true)
        public String userChannel;
    }
    public class Results {
        @InvocableVariable(description='Active action plan template id')
        public string actionPlanTemplateHeaderId;
    }
}