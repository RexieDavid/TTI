public class TTI_Form_productTriggerHandler {
	
    public static void beforeTrigger(list<TTI_Form_Product__c> product){
        if(Trigger.isDelete){
            for(TTI_Form_Product__c prd :product){
                if(prd.Form_Number__r.Form_Status__c != 'New'){
                   prd.addError('Cannot Delete product on this phase of the Form!');
                }
            }
        }
    }
}