@isTest
private class PostcodeTriggerHandlerTest {
    
    @testSetup static void testData() {
        
		Region__c region = new Region__c(Region_Name__c = 'testTegion');
		insert region;	
		
        List<Postcode__c> pcs = new List<Postcode__c>();
        for (integer i = 0; i < 10; i++) {
            pcs.add(new Postcode__c(Postcode__c = '111'+i, Territory__c = 'testTegion'));
        }
        insert pcs;
        
    }

    private static testMethod void testPostcodeTrigger() {
        
        Region__c region = [SELECT id, Region_Name__c FROM Region__c WHERE Region_Name__c = 'testTegion' LIMIT 1];
        Postcode__c postcode = [SELECT id, name, JSS_Region__c, Postcode__c FROM Postcode__c WHERE Territory__c = 'testTegion' LIMIT 1];
        System.assertEquals(postcode.JSS_Region__c, region.Id);
        
        update postcode;
        
        System.assertEquals(postcode.JSS_Region__c, region.Id);

    }
}