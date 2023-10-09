/**
* @author           Francis Nasalita
* @date             2021-03-10
* @description      Sales transaction Product Registration Controller
*/
public without sharing class SalesTransactionProdRegController {
    
    private static final String LIKE_WILDCARD = '%';
    private static final String PRODUCT_TRANSACTION_API = 'Product_Transactions__c';
    private static final String PRODUCT_API = 'Product__c';
    private static final String PRODUCT_OBJECT_API = 'Product2';
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSAPMaterialGroups() {
        return fetchProdSAPMaterialGroups();
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getProductByBarcode(List<String> fieldList, String conditionExpression) {
        return new SoqlService()
            .setObjectType('Product2')
            .setFieldList(fieldList)
            .setConditionExpression(conditionExpression)
            .run();
    }

    /**********************************************************************
     * @description                 Fetch brands from Product Transaction 
     *                              Product field lookup filter
     * 
     * @return                      List of brand codes
     * 
     * @example
     * fetchProdSAPMaterialGroups('');
    */
    private static List<String> fetchProdSAPMaterialGroups() {
        String brandsFilter = fetchLookupFilter(PRODUCT_API);
        List<String> unformattedBrands = brandsFilter.substring(brandsFilter.indexOf('\'')).replace('\'', '').split(',');
        List<String> brands = new List<String>();

        for (String s :unformattedBrands) {
            brands.add(s + LIKE_WILDCARD);
        }

        return brands;
    }

    /**********************************************************************
     * @description                 Fetch lookup filter of specific lookup
     *                              field
     * 
     * @param fieldAPIName          Lookup field API Name
     * 
     * @return                      SOQL Filter
     * 
     * @example
     * TrainingAttendeeMassUpdateController.fetchLookupFilter('Product_Transactions__c');
    */
    private static String fetchLookupFilter(String fieldAPIName) {
        String soqlFilter = '';
        if (String.isNotBlank(fieldAPIName)) {
            fieldAPIName = fieldAPIName.replace('__c', '').trim();
            List<String> lookupCriteria = new List<String>();
            List<ToolingAPI.Records> result = fetchFieldDefinition(fieldAPIName);
            if (!result.isEmpty()) {
                ToolingAPI.Metadata metadata = result[0].metadata;
                ToolingAPI.LookupFilter lookupFilter = metadata.lookupFilter;
                if (lookupFilter.active && !lookupFilter.filterItems.isEmpty()) {
                    for (ToolingAPI.FilterItems filter : metadata.lookupFilter.filterItems) {
                        lookupCriteria.add(filter.soqlFilter); 
                    }
                    soqlFilter = combineSOQLFilters(lookupCriteria, lookupFilter.booleanFilter);
                }
            }
            
        }

        return soqlFilter;
    }

    /**********************************************************************
     * @description                 Fetch field definition of specific field
     * 
     * @param fieldAPIName          Field API Name
     * 
     * @return                      List of records return by ToolingAPI HTTP 
     *                              Request
     * 
     * @example
     * fetchFieldDefinition('TrainingAttendent__c');
    */
    private static List<ToolingAPI.Records> fetchFieldDefinition(String fieldAPIName) {
        String query = 'SELECT Id, Metadata FROM CustomField WHERE DeveloperName = \'' + fieldAPIName + '\'';
        query += ' AND TableEnumOrId = \'' + fetchProductTransactionId() + '\'';
        ToolingAPI toolingAPI = new ToolingAPI(true);
        if (Test.isRunningTest()) {
            toolingAPI = new ToolingAPI();
        } 

        toolingAPI.objectAPIName = PRODUCT_TRANSACTION_API;
        toolingAPI.query = query;
        toolingAPI.methodType = 'GET';
        return toolingAPI.initializeHttpRequest();
    } 

    /**********************************************************************
     * @description                 Fetch Product Transaction Object Id
     * 
     * @return                      Product Transaction Object Id
     * 
     * @example
     * fetchProductTransactionId('');
    */
    private static Id fetchProductTransactionId() {
        return [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName = :PRODUCT_TRANSACTION_API LIMIT 1].DurableId;
    }

    /**********************************************************************
     * @description                 Combine SOQL filters via booleanLogic
     * 
     * @param criteria              List of SOQL filters
     * @param booleanLogic          Boolean logic 
     * 
     * @return                      Combined SOQL filters
     * 
     * @example
     * combineSOQLFilters(new List<String>, '(1 OR 2) AND 3');
    */
    private static String combineSOQLFilters(List<String> criteria, String booleanLogic) {
        String soqlFilter;
        if (String.isNotBlank(booleanLogic)) {
            if (booleanLogic.containsIgnoreCase('OR') && booleanLogic.containsIgnoreCase('AND')) {
                // This will only work up to 9 lookup filters
                for (Integer ctr = 0; ctr < criteria.size(); ctr++) {
                    booleanLogic = booleanLogic.replace(String.valueOf(ctr+1), criteria[ctr]);
                }
                soqlFilter = booleanLogic;
            } else if (booleanLogic.containsIgnoreCase('AND')) {
                soqlFilter = String.join(criteria, ' AND ');
            } else {
                soqlFilter = String.join(criteria, ' OR ');
            }
        } else {
            soqlFilter = String.join(criteria, ' AND ');
        }
        return soqlFilter;
    }
    
}