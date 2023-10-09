/**
 * author:      Francis Nasalita
 * date:        2021-05-18
 */
public class CustomLookupController {

    @TestVisible
    private static SoqlService service = new SoqlService();

    @AuraEnabled
    public static CustomLookupResponse init(String objectType, List<String> fieldList, String conditionExpression, String maxRows) {
        service.setObjectType(objectType).setFieldList(fieldList).setMaxRows(maxRows);

        if (String.isNotBlank(conditionExpression)) {
            service.setConditionExpression(conditionExpression);
        }

        return new CustomLookupResponse()
            .setQuery(service.getQuery())
            .setRecords(service.getRecentlyViewedRecords());
    }

    @AuraEnabled
    public static CustomLookupResponse init(String objectType, List<String> fieldList, String conditionExpression) {
        service.setObjectType(objectType).setFieldList(fieldList);

        if (String.isNotBlank(conditionExpression)) {
            service.setConditionExpression(conditionExpression);
        }

        return new CustomLookupResponse()
            .setQuery(service.getQuery())
            .setRecords(service.getRecentlyViewedRecords());
    }

    @AuraEnabled
    public static CustomLookupResponse searchRecords(String query){
        return new CustomLookupResponse()
            .setRecords(service.run(query));
    }

    public class CustomLookupResponse {

        @AuraEnabled
        public String query { get; set;}

        @AuraEnabled
        public List<SObject> records { get; set;}

        public CustomLookupResponse() {
            this.query = '';
            this.records = new List<SObject>();
        }

        public CustomLookupResponse setQuery(String query) {
            this.query = query;

            return this;
        }

        public CustomLookupResponse setRecords(List<SObject> records) {
            this.records = records;

            return this;
        }
    }
}