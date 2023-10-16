trigger MemberBenefitTrigger on Member_Benefit__c (after insert, after update) {
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            MemberBenefitTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        } 
     }

    new MetadataTriggerManager()
    .setsObjectType('Member_Benefit__c')
    .run();
}