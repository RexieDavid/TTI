/**
* @author Francis Nasalita
* @date 2020-06-18
*
* @description Order Details controller
*/
public class OrderDetailsController {
    private static final String ORDER_EXTERNAL_OBJECT = 'SF_Order_DetailsSet__x';
    private static final String DEFAULT_SORTBY_FIELD = 'Posnr__c';
    private static final String DEFAULT_SORT_DIRECTION = 'asc';
    private static final String QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE {2}';
    private static final String QUERY_FILTER_TEMPLATE = 'IVbeln__c = {0}';
    private static final String FIELD_SET_DESKTOP_VIEW = 'Sales_Order_Information';
    private static final String FIELD_SET_MOBILE_VIEW = 'Sales_Order_Information_Salesforce1';
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';

    private static Integer materialNumberWidth = 115;
    private static Integer materialDescWidth = 300;
    private static Boolean materialNoIsWrapText = false;
    private static Boolean etaDateIsWrapText = false;

    private static Set<String> sortableFIelds = new Set<String>{'ConNote__c', 'OrderStatus__c'};

    private static List<Column> columns = new List<Column>();

    /**
    * @author: Francis Nasalita
    * @date: 2020-06-18
    * @description: This method retrieves orders from external object
    * @example: updateOpportunityDocumentAttachedCheckbox(new Map<Id, SObject>);
    */
    //05-07-2023:RBT:Diabling AuraEnabled for testing external object query
    @AuraEnabled
    public static OrderDetailsResponseData getOrderDetails(Boolean isUserInDesktop, String orderNumber) {

        if (!isUserInDesktop) {
            sortableFIelds = new Set<String>();
            materialNumberWidth = 0;
            materialNoIsWrapText = true;
            etaDateIsWrapText = true;
        }

        List<SF_Order_DetailsSet__x> lstOrderDetails;
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ORDER_EXTERNAL_OBJECT).getDescribe().fields.getMap();
        
        List<String> fieldNames = new List<String>();
        fieldNames.addAll(fieldMap.keySet());
        
        List<String> args = new List<String>{
            String.join(fieldNames, ','),
            ORDER_EXTERNAL_OBJECT,
            String.format(QUERY_FILTER_TEMPLATE, new List<String>{ 
                '\'' + String.escapeSingleQuotes(orderNumber) + '\'' 
            })
        };

        columns = getColumns(isUserInDesktop ? FIELD_SET_DESKTOP_VIEW : FIELD_SET_MOBILE_VIEW);
        TableValues tableValues = new TableValues(columns, DEFAULT_SORTBY_FIELD, DEFAULT_SORT_DIRECTION);

        if (!Test.isRunningTest()) {
            system.debug('This is the string'  +String.format(QUERY_TEMPLATE, args));
            lstOrderDetails = database.query(String.format(QUERY_TEMPLATE, args));
            system.debug('This is the result '+lstOrderDetails);
        } else {
            lstOrderDetails = new List<SF_Order_DetailsSet__x>();
            lstOrderDetails.add(SAPQASOrderDetailsControllerTest.createOrderDetailSetRecord());
        }

        Map<String, String> mapCarrierTrackingUrl = getCarrierTrackingUrl(lstOrderDetails);

        return new OrderDetailsResponseData(lstOrderDetails, tableValues, mapCarrierTrackingUrl);
    }

    /**
    * @author: Francis Nasalita
    * @date: 2020-06-18
    * @description: This method retrieves tracking url
    * @example: getCarrierTrackingUrl(new List<SF_Order_DetailsSet__x>());
    */
    private static Map<String, String> getCarrierTrackingUrl(List<SF_Order_DetailsSet__x> lstOrderDetails) {
        Map<String, String> mapCarrierTrackingUrl = new Map<String, String> ();
        Set<String> carriers = new Set<String> ();
        for (SF_Order_DetailsSet__x orderDetail : lstOrderDetails) {
            carriers.add(orderDetail.Carrier__c);
        }

        if (!carriers.isEmpty()) {
            for (Carrier_Tracking_URL__mdt carrier : [SELECT DeveloperName, 
                                                             TrackingURL__c
                                                        FROM Carrier_Tracking_URL__mdt
                                                       WHERE DeveloperName IN :carriers]) {
                mapCarrierTrackingUrl.put(carrier.DeveloperName, carrier.TrackingURL__c);
            }
        }      

        return mapCarrierTrackingUrl;
    }

    /**
    * @author: Francis Nasalita
    * @date: 2020-06-18
    * @description: This method constructs columns by fieldset
    * @example: getColumns('fieldSetAPIName');
    */
    private static List<Column> getColumns(String fieldSetAPIName) {
        List<Column> columns = new List<Column>();
        List<Schema.FieldSetMember> fields = Schema.getGlobalDescribe().get(ORDER_EXTERNAL_OBJECT).getDescribe()
            .FieldSets.getMap().get(fieldSetAPIName).getFields();

        for (Schema.FieldSetMember field : fields) {
            columns.add(new Column(field));
        }

        return columns;
    }

    /**
     * @description Wrapper class for Order details
     */
    public class OrderDetailsResponseData {
        @AuraEnabled
        public Map<String, String> mapCarrierTrackingUrl;

        @AuraEnabled
        public List<SF_Order_DetailsSet__x> lstOrderDetails;

        @AuraEnabled
        public TableValues tableValues;

        public OrderDetailsResponseData(List<SF_Order_DetailsSet__x> lstOrderDetails, TableValues tableValues, Map<String, String> mapCarrierTrackingUrl) {
            this.tableValues = tableValues;
            this.lstOrderDetails = lstOrderDetails;
            this.mapCarrierTrackingUrl = mapCarrierTrackingUrl;
        }
    }

    /**
     * @description Wrapper class for table
     */
    public class TableValues {
        @AuraEnabled
        public String sortBy;

        @AuraEnabled
        public String sortDirection;

        @AuraEnabled
        public List<Column> columns;

        public TableValues(List<Column> columns, String sortBy, String sortDirection) {
            this.sortBy = sortBy;
            this.sortDirection = sortDirection;
            this.columns = columns;
        }
    }

    /**
     * @description Wrapper class for table columns
     */
    public class Column {
        @AuraEnabled
        public String label;

        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public Boolean hideDefaultActions;

        @AuraEnabled
        public Boolean sortable;

        @AuraEnabled
        public Integer initialWidth;
        
        @AuraEnabled
        public Boolean wrapText;

        public Column(Schema.FieldSetMember field) {
            this.label = field.getLabel();
            this.fieldName = field.getFieldPath();
            this.hideDefaultActions = true;
            this.sortable = sortableFIelds.contains(field.getFieldPath());
            this.wrapText = false;

            if (field.getFieldPath() == 'Maktx__c') {
                this.initialWidth = materialDescWidth;
            }

            if (field.getFieldPath() == 'Matnr__c') {
                this.initialWidth = materialNumberWidth;
                this.wrapText = materialNoIsWrapText;
            }

            if (field.getFieldPath() == 'DateText__c') {
                this.wrapText = etaDateIsWrapText;
            }

            if (field.getType() == Schema.DisplayType.STRING) {
                this.type = 'text';
            } else if (field.getType() == Schema.DisplayType.DOUBLE) {
                this.type = 'number';
            } else if (field.getType() == Schema.DisplayType.DATE) {
                this.type = 'date';
            } else {
                this.type = 'text';
            }
        }
    }
}