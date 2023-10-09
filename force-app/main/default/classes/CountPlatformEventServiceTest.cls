@isTest
private class CountPlatformEventServiceTest {
    @isTest
    private static void countSingePlatformEvent() {
        List<RCTI_Invoice_View_Ready__e> events = createPlatformEvents(1);
        Test.startTest();
            new CountPlatformEventService()
                .setDescribeObjectResult(RCTI_Invoice_View_Ready__e.sObjectType.getDescribe())
                .run(events);
        Test.stopTest();
        List<CountPlatformEvent__c> countPEs = [SELECT Id, pecount__c FROM CountPlatformEvent__c WHERE pename__c = 'RCTI_Invoice_View_Ready__e'];
        System.assertEquals(1, countPEs.size(), 'Failed to log count for published platform event');
        System.assertEquals(1, countPEs[0].pecount__c, 'Count did not match, should only be 1');
    }

    @isTest
    private static void countMultiplePlatformEvent() {
        List<RCTI_Invoice_View_Ready__e> events = createPlatformEvents(5);
        Test.startTest();
            new CountPlatformEventService()
                .setDescribeObjectResult(RCTI_Invoice_View_Ready__e.sObjectType.getDescribe())
                .run(events);
        Test.stopTest();
        List<CountPlatformEvent__c> countPEs = [SELECT Id, pecount__c FROM CountPlatformEvent__c WHERE pename__c = 'RCTI_Invoice_View_Ready__e'];
        System.assertEquals(1, countPEs.size(), 'Failed to log count published platform event');
        System.assertEquals(events.size(), countPEs[0].pecount__c, 'Count did not match, should only be ' + events.size());
    }

    /**
     * @description                 Create platform events to published
     * 
     * @return                      List of platform events to published
     */
    private static List<RCTI_Invoice_View_Ready__e> createPlatformEvents(Integer max) {
        List<RCTI_Invoice_View_Ready__e> events = new List<RCTI_Invoice_View_Ready__e>();
        for (Integer i = 0; i < max; i++) {
            events.add(createPlatformEvent(i));
        }
        return events;
    }


    private static RCTI_Invoice_View_Ready__e createPlatformEvent(Integer identifier) {
        String recordJson = '{' + 
            '"Case_Number__c": "000' + identifier + '",' +
            '"CreatedDate": "2021-01-01T00:00:00.000+0000"' +
        '}';
        return (RCTI_Invoice_View_Ready__e)JSON.deserialize(recordJson, RCTI_Invoice_View_Ready__e.class);
    }
}