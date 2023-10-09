/**
 * author:      Francis Nasalita
 * date:        2021-05-18
 */
public class SoqlService {
    
    private final String QUERY_TEMPLATE = 'SELECT {0} FROM {1} {2} {3}';
    private final String SOQL_LOGICAL_OPERATORS = '( [aA][nN][dD] )|( [oO][rR] )';
    private final String SOQL_COMPARISON_OPERATORS = '( (!=|=|>|>=|<|<=) )| ([lL][iI][kK][eE]) |( [iI][nN] )|( [nN][oO][tT] [iI][nN] )';
    private final String SOQL_FIELDS_DELIMITER = ', ';
    private final String SOQL_CONDITION_EXPRESSION_PREFIX = 'WHERE ';
    
    private final String ERR_MSG_NO_OBJECT_TYPE = 'No object type passed.';
    private final String ERR_MSG_INVALID_OBJECT_TYPE = 'Invalid object type.';
    private final String ERR_MSG_INVALID_FIELDS = 'Invalid field/s: {0} does not exist in {1} object.';
    private final String ERR_MSG_MUST_SET_OBJECT_TYPE = 'Object type must be set first.';
    private final String ERR_MSG_NO_FIELDS = 'No fields passed.';
    private final String ERR_MSG_INVALID_CONDITION_EXPRESSION = 'Invalid condition expression.';
    private final String ERR_MSG_NO_CONDITION_EXPRESSION = 'No condition expression passed.';
    private final String ERR_MSG_CONDITION_EXPRESSION_MUST_START_WHERE = 'Condition expression must start with \'WHERE\'';
    private final String ERR_MSG_OBJECT_TYPE_MUST_BE_SET = 'Atleast object type must be set.';

    private String objectType;
    private String query;
    private String conditionExpression;
    private String maxRows = '200';

    private Set<String> fieldList;

    public String getQuery() {
        return this.query;
    }

    public SoqlService setObjectType(String objectType) {
        if (String.isBlank(objectType)) {
            throw new SoqlServiceException(ERR_MSG_NO_OBJECT_TYPE);
        }

        if (!SObjectUtil.isObjectExist(objectType)) {
            throw new SoqlServiceException(ERR_MSG_INVALID_OBJECT_TYPE);
        }

        this.objectType = objectType;

        constructQuery();

        return this;
    }

    public SoqlService setFieldList(List<String> fieldList) {
        if (String.isBlank(this.objectType)) {
            throw new SoqlServiceException(ERR_MSG_MUST_SET_OBJECT_TYPE);
        }

        if (fieldList.isEmpty()) {
            throw new SoqlServiceException(ERR_MSG_NO_FIELDS);
        }

        validateFieldsIfExist(fieldList);

        this.fieldList = new Set<String>(fieldList);

        constructQuery();

        return this;
    }

    public SoqlService setConditionExpression(String conditionExpression) {
        if (String.isBlank(this.objectType)) {
            throw new SoqlServiceException(ERR_MSG_MUST_SET_OBJECT_TYPE);
        }

        if (String.isBlank(conditionExpression)) {
            throw new SoqlServiceException(ERR_MSG_NO_CONDITION_EXPRESSION);
        }

        if (!conditionExpression.startsWith(SOQL_CONDITION_EXPRESSION_PREFIX)) {
            throw new SoqlServiceException(ERR_MSG_CONDITION_EXPRESSION_MUST_START_WHERE);
        }

        this.conditionExpression = conditionExpression;
        
        validateConditionExpression();

        constructQuery();

        return this;
    }

    public SoqlService setMaxRows(String maxRows) {
        this.maxRows = maxRows;

        return this;
    }

    private String getMaxRows() {
        return 'LIMIT ' + this.maxRows;
    }

    public SoqlService() {
        this.fieldList = new Set<String>();
        this.conditionExpression = '';
    }

    public List<SObject> run() {
        if (String.isBlank(this.objectType)) {
            throw new SoqlServiceException(ERR_MSG_OBJECT_TYPE_MUST_BE_SET);
        }

        return Database.query(this.query.trim());
    }

    public List<SObject> run(String query) {
        return Database.query(query.trim());
    }

    public List<SObject> getRecentlyViewedRecords() {
        List<RecentlyViewed> recentRecords = getRecentRecords();

        Set<String> recentRecordIds = new Set<String>();
        for (RecentlyViewed record : recentRecords) {
            recentRecordIds.add(encloseWithSingleQuotes(record.Id));
        }
        
        if (recentRecordIds.isEmpty()) {
            return new List<SObject>();
        }

        String conditionTemplate = 'WHERE Id IN ({0})';
        this.conditionExpression = String.format(
            conditionTemplate, 
            new List<Object>{
                String.join(new List<String>(recentRecordIds), SOQL_FIELDS_DELIMITER)
            }
        );

        constructQuery();

        Map<Id, SObject> records = new Map<Id, SObject>(run());

        List<SObject> sortedRecords = new List<SObject>();
        for (RecentlyViewed record : recentRecords) {
            if (records.containsKey(record.Id)) {
                sortedRecords.add(records.get(record.Id));
            }
        }

        return sortedRecords;
    }

    private static String encloseWithSingleQuotes(String text) {
        return '\'' + String.escapeSingleQuotes(text) + '\'';
    }

    private List<RecentlyViewed> getRecentRecords() {
        return [
            SELECT Id 
              FROM RecentlyViewed 
             WHERE Type = :this.objectType 
          ORDER BY LastViewedDate DESC
             LIMIT 15
        ];
    }
    
    private void constructQuery() {
        addIdtoFields();

        List<Object> args = new List<Object>{
            String.join(new List<String>(this.fieldList), SOQL_FIELDS_DELIMITER),
            this.objectType,
            this.conditionExpression,
            getMaxRows()
        };

        this.query = String.format(this.QUERY_TEMPLATE, args);
    }

    private void addIdtoFields() {
        if (this.fieldList.isEmpty()) {
            this.fieldList.add('Id');
            return;
        }

        List<String> tempFieldList = new List<String>(this.fieldList);
        if (!containsIgnoreCase(tempFieldList, 'id')) {
            this.fieldList.add('Id');
        }
    }

    private Boolean validateFieldsIfExist(List<String> fields) {
        List<String> invalidFields = new List<String>();
        Boolean allFieldsIsValid = true;

        for (String field : fields) {
            Boolean isFieldExist = SObjectUtil.isFieldExist(this.objectType, field);
            if (!isFieldExist) {
                invalidFields.add(field);
            }

            allFieldsIsValid &= isFieldExist;
        }

        if (!invalidFields.isEmpty()) {
            List<Object> args = new List<Object>{
                String.join(invalidFields, SOQL_FIELDS_DELIMITER), 
                this.objectType
            };
            throw new SoqlServiceException(String.format(ERR_MSG_INVALID_FIELDS, args));
        }

        return allFieldsIsValid;
    }

    private Boolean validateConditionExpression() {
        List<String> conditionFields = new List<String>();
        List<String> conditions = this.conditionExpression
                                    .substringAfter(SOQL_CONDITION_EXPRESSION_PREFIX)
                                    .split(SOQL_LOGICAL_OPERATORS);

        for (String condition : conditions) {
            if (hasOperators(condition)) {
                List<String> conditionParts = condition.split(SOQL_COMPARISON_OPERATORS);
                String field = conditionParts[0].replace('(', '').replace(')', '');
            
                conditionFields.add(field);

                // add fields filtered to the fields to be queried
                if (!this.fieldList.contains(field)) {
                    this.fieldList.add(field);
                }
            } else {
                throw new SoqlServiceException(ERR_MSG_INVALID_CONDITION_EXPRESSION);
            }
        }

        return validateFieldsIfExist(conditionFields);
    }
    
    private Boolean hasOperators(String expression) {
        Pattern pattern = Pattern.compile(SOQL_COMPARISON_OPERATORS.trim());
        Matcher matcher = pattern.matcher(expression);
        return matcher.find();
    }

    private Boolean containsIgnoreCase(List<String> arrToCheck, String text) {
        Boolean exist = false;
        Pattern pattern = Pattern.compile('(?i)' + text);

        for (Integer counter = 0; counter < arrToCheck.size(); counter++) {
            Matcher matcher = pattern.matcher(arrToCheck[counter]);
            if (matcher.matches()) {
                exist = true;
                break;
            }
        }

        return exist;
    }

    public class SoqlServiceException extends Exception {}
    
}