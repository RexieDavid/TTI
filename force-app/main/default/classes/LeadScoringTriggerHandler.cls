/**
* @author           Francis Nasalita
* @date             2021-11-22
* @description      Lead trigger handler for score calculation
*/
public without sharing class LeadScoringTriggerHandler extends TriggerHandler {

    private List<Lead> leads;
    private Map<Id, Lead> mapOldLeads;
    
    public LeadScoringTriggerHandler() {
        this.leads = (List<Lead>) Trigger.new;
        this.mapOldLeads = (Map<Id, Lead>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        populateLeadScore();
    }


    private void populateLeadScore() {
        for (Lead lead : this.leads) {
            lead.Lead_Score__c = LeadScoringHelper.calculateLeadScore(lead);
        }
    }
}