/**
* @author           Francis Nasalita
* @date             2020-10-15
* @description      Case trigger handler for the RCTI pdf generation process
*/
public with sharing class SpRctiGenerationTriggerHandler extends TriggerHandler {
    
    private List<Case> cases;
    private Map<Id, Case> oldCasesMap;

    public SpRctiGenerationTriggerHandler() {
        this.cases = (List<Case>) Trigger.new;
        this.oldCasesMap = (Map<Id, Case>) Trigger.oldMap;
    }

    public SpRctiGenerationTriggerHandler(List<Case> caseList, Map<Id, Case> oldCasesMap) {
        this.cases = caseList;
        this.oldCasesMap = oldCasesMap;
    }

    public override void afterUpdate() {
        checkForInvoiceNumber();
    }

    // Helper methods
    private void checkForInvoiceNumber() {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : this.cases) {
            if (c.Invoice_Number_PC__c != this.oldCasesMap.get(c.Id).Invoice_Number_PC__c && c.Ready_for_RCTI_Processing__c) {
                caseIds.add(c.Id);
            }
        }

        if (!caseIds.isEmpty()) {
            SpRctiGenerationService.start(caseIds);
        }
    }
}