trigger MemberBenefitTrigger on Member_Benefit__c (before insert, after insert, after update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            MemberBenefitTriggerHandler.onBeforeInsert(Trigger.new);
        } 
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            MemberBenefitTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        } 
    }

    new MetadataTriggerManager()
    .setsObjectType('Member_Benefit__c')
    .run();
}