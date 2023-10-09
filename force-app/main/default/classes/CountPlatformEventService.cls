public class CountPlatformEventService {
    private DescribeSObjectResult describe;

    /**
     * @description                 Start count of published platform events
     * 
     * @param peEvents              List of published platform events
     * 
     * @return                      Map of PE Object and Created Date
     */
    public void run(List<SObject> peEvents) {
        Map<Datetime, List<SObject>> eventsMap = this.mapPEObjectsAndDateTime(peEvents);
        if (!eventsMap.isEmpty()) {
            List<CountPlatformEvent__c> countPEObjects = this.fetchCountPlatformEvents(eventsMap.keySet());
            for (CountPlatformEvent__c countPEObject : countPEObjects) {
                if (eventsMap.containsKey(countPEObject.pedatetime__c)) {
                    countPEObject.pecount__c += eventsMap.get(countPEObject.pedatetime__c).size();
                    eventsMap.remove(countPEObject.pedatetime__c);
                }
            }

            if (!eventsMap.isEmpty()) {
                for (Datetime dt : eventsMap.keySet()) {
                    CountPlatformEvent__c count = new CountPlatformEvent__c(
                        pecount__c = eventsMap.get(dt).size(),
                        pedatetime__c = dt,
                        pename__c = describe.getName(),
                        pelabel__c = describe.getLabel()
                    );
                    countPEObjects.add(count);
                }
            }

            try {
                upsert countPEObjects;
            } catch (Exception ex) {
                System.debug('An unexpected error has occurred: '+ ex.getMessage()); 
            }
        }
    }

    /**
     * @description                 Map PE Object and Created Date
     * 
     * @param peEvents              List of published platform events
     * 
     * @return                      Map of PE Object and Created Date
     */
    private Map<Datetime, List<SObject>> mapPEObjectsAndDateTime(List<SObject> peEvents) {
        Map<Datetime, List<SObject>> eventsMap = new Map<Datetime, List<SObject>>();
        for (SObject pe : peEvents) {
            DateTime createdDateTime = (Datetime) pe.get('CreatedDate');
            DateTime key = DateTime.newInstance(
                createdDateTime.year(), 
                createdDateTime.month(), 
                createdDateTime.day(), 
                createdDateTime.hour(), 
                createdDateTime.minute(), 
                0
            );

            if (!eventsMap.containsKey(key)) {
                eventsMap.put(key, new List<SObject>());
            }
            eventsMap.get(key).add(pe);
        }
        return eventsMap;
    }

    /**
     * @description                 Fetch platform events that have the same datetime
     *                              and pe name
     * 
     * @param dateTimes             Set of date times
     * 
     * @return                      Map of PE Object and Created Date
     */
    private List<CountPlatformEvent__c> fetchCountPlatformEvents(Set<Datetime> dateTimes) {
        return [SELECT Id, 
                       pecount__c, 
                       pename__c, 
                       pedatetime__c 
                FROM CountPlatformEvent__c
                WHERE pedatetime__c IN :dateTimes
                AND pename__c = :this.describe.getName()];
    }

    /** 
     * @description                 Set Describe Result
     * @param describe              Describe SObject Result
     * 
     * @return                      this (class itself)
     */
    public CountPlatformEventService setDescribeObjectResult(DescribeSObjectResult describe) {
        this.describe = describe; 
        return this;
    }
}