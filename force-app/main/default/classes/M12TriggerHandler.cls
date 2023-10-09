/**
 * Created by Haider Raza on 25/01/2017.
 */

public with sharing class M12TriggerHandler {
    public static void beforeTrigger(List<M12_Inventory__c> inventories){
        for(M12_Inventory__c inv : inventories){
            if(inv.Is_Active__c){
                inv.Activation_Date__c = DateTime.now();
            }else if(!inv.Is_Active__c){
                inv.Deactivation_Date__c = DateTime.now();
            }
        }
    }

    public static void afterTrigger(List<M12_Inventory__c> inventories){
        if(checkRecursive.runOnce()) {
            Set<String> prodId = new Set<String>();

            for (M12_Inventory__c inv : [SELECT Product__c FROM M12_Inventory__c WHERE Id IN:inventories]) {
                prodId.add(inv.Product__c);
            }

            Map<String, M12_Inventory__c> inventoryMap = new Map<String, M12_Inventory__c>([
                    SELECT Id, Is_Active__c, M12_Hub_Price_per_unit__c, Product__c, Required_Quantity__c, Deactivation_Reason__c
                    FROM M12_Inventory__c
                    WHERE Product__c IN:prodId
                    AND Id NOT IN:inventories
                    AND Is_Active__c = TRUE
            ]);


            List<M12_Inventory__c> invToDeactivate = new List<M12_Inventory__c>();

            for (M12_Inventory__c inv : inventoryMap.values()) {
                String deactiveReason = inv.Deactivation_Reason__c == null ? 'Replaced with new specifications' : inv.Deactivation_Reason__c;
                invToDeactivate.add(new M12_Inventory__c(Id = inv.Id, Is_Active__c=FALSE, Deactivation_Reason__c = deactiveReason));
            }

            if (invToDeactivate.size() > 0) {
                update invToDeactivate;
            }
        }
    }
}