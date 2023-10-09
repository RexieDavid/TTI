/**
 * author:      Francis Nasalita
 * date:        2021-05-25
 */
@isTest
public class SoqlServiceTest {
    
    private static final SoqlService soqlService = new SoqlService();
    private static final String objectType = 'Account';
    private static final List<String> fieldList = new List<String>{ 'Name', 'OwnerId' };
    private static final String conditionExpression = 'WHERE Name = \'Batman\'';

    private static final String ERR_MSG_NO_OBJECT_TYPE = 'No object type passed.';
    private static final String ERR_MSG_INVALID_OBJECT_TYPE = 'Invalid object type.';
    private static final String ERR_MSG_INVALID_FIELDS = 'Invalid field/s: {0} does not exist in {1} object.';
    private static final String ERR_MSG_MUST_SET_OBJECT_TYPE = 'Object type must be set first.';
    private static final String ERR_MSG_NO_FIELDS = 'No fields passed.';
    private static final String ERR_MSG_INVALID_CONDITION_EXPRESSION = 'Invalid condition expression.';
    private static final String ERR_MSG_NO_CONDITION_EXPRESSION = 'No condition expression passed.';
    private static final String ERR_MSG_CONDITION_EXPRESSION_MUST_START_WHERE = 'Condition expression must start with \'WHERE\'';
    private static final String ERR_MSG_OBJECT_TYPE_MUST_BE_SET = 'Atleast object type must be set.';

    @TestSetup
    static void makeData() {

    }
    
    @IsTest
    static void testSetObjectType() {

        Test.startTest();
            soqlService.setObjectType(objectType);
        Test.stopTest();
        
        System.assert(soqlService.getQuery().contains('Account'), 'Setting object type failed.');
    }

    @IsTest
    static void testSetObjectTypeNoObject() {
        String errorMessage;

        Test.startTest();
            try {
                soqlService.setObjectType('');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set object type successfully without object type passed.');
        System.assertEquals(ERR_MSG_NO_OBJECT_TYPE, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetObjectTypeInvalidObject() {
        String errorMessage;

        String invalidObject = 'test invalid Object';
        Test.startTest();
            try {
                soqlService.setObjectType(invalidObject);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set object type successfully with invalid object type.');
        System.assertEquals(ERR_MSG_INVALID_OBJECT_TYPE, errorMessage, 'Error message does\'t match.');
    }
    
    @IsTest
    static void testSetFieldList() {

        soqlService.setObjectType(objectType);
        Test.startTest();
            soqlService.setFieldList(fieldList);
        Test.stopTest();
        
        System.assert(soqlService.getQuery().contains('Name, OwnerId, Id'), 'Setting fields failed.');
    }

    @IsTest
    static void testSetFieldListWithoutObject() {
        String errorMessage;

        Test.startTest();
            try {
                soqlService.setFieldList(fieldList);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set field list successfully without object type.');
        System.assertEquals(ERR_MSG_MUST_SET_OBJECT_TYPE, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetFieldListWithEmptyList() {
        String errorMessage;

        soqlService.setObjectType(objectType);
        Test.startTest();
            try {
                soqlService.setFieldList(new List<String>());
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set field list successfully with empty list.');
        System.assertEquals(ERR_MSG_NO_FIELDS, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetFieldListWithInvalidField() {
        String errorMessage;
        String invalidField = 'Test';

        soqlService.setObjectType(objectType);
        Test.startTest();
            try {
                soqlService.setFieldList(new List<String>{ invalidField });
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        String expectedErrorMessage = String.format(
            ERR_MSG_INVALID_FIELDS, 
            new List<Object>{
                invalidField,
                objectType
            }
        );

        System.assert(String.isNotBlank(errorMessage), 'Service set field list successfully with invalid field.');
        System.assertEquals(expectedErrorMessage, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetConditionExpression() {

        soqlService.setObjectType(objectType);
        Test.startTest();
            soqlService.setConditionExpression(conditionExpression);
        Test.stopTest();
        
        System.assert(soqlService.getQuery().contains('WHERE Name = \'Batman\''), 'Setting condition expression failed.');
    }

    @IsTest
    static void testSetConditionExpressionWithoutObject() {
        String errorMessage;

        Test.startTest();
            try {
                soqlService.setConditionExpression(conditionExpression);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set condition successfully without object.');
        System.assertEquals(ERR_MSG_MUST_SET_OBJECT_TYPE, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetConditionExpressionWithEmptyString() {
        String errorMessage;

        soqlService.setObjectType(objectType);
        Test.startTest();
            try {
                soqlService.setConditionExpression('');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set condition successfully with empty string.');
        System.assertEquals(ERR_MSG_NO_CONDITION_EXPRESSION, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetConditionExpressionWithoutWhere() {
        String errorMessage;

        soqlService.setObjectType(objectType);
        Test.startTest();
            try {
                soqlService.setConditionExpression('Name = \'Batman\'');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set condition successfully without "WHERE" prefix.');
        System.assertEquals(ERR_MSG_CONDITION_EXPRESSION_MUST_START_WHERE, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testSetConditionExpressionInvalidCondition() {
        String errorMessage;

        soqlService.setObjectType(objectType);
        Test.startTest();
            try {
                soqlService.setConditionExpression('WHERE Name \'Batman\'');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage), 'Service set condition successfully with invalid condition.');
        System.assertEquals(ERR_MSG_INVALID_CONDITION_EXPRESSION, errorMessage, 'Error message does\'t match.');
    }

    @IsTest
    static void testGetQuery() {
        
        soqlService
            .setObjectType(objectType)
            .setFieldList(fieldList)
            .setConditionExpression(conditionExpression);

            String query;
        Test.startTest();
            query = soqlService.getQuery();
        Test.stopTest();
        
        System.assertEquals('SELECT Name, OwnerId, Id FROM Account WHERE Name = \'Batman\'', query, 'Query does not match.');
    }

    @IsTest
    static void testRunNegative() {
        String errorMessage;

        Test.startTest();
            try {
                soqlService.run();
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        
        System.assert(String.isNotBlank(errorMessage), 'Service did not failed without setting object type.');
        System.assertEquals(ERR_MSG_OBJECT_TYPE_MUST_BE_SET, errorMessage, 'Error message doesn\'t match.');
    }

    @IsTest
    static void testRun() {
        List<SObject> records = new List<SObject>();

        createAccountRecords();

        soqlService.setObjectType(objectType);
        Test.startTest();
            records = soqlService.run();
        Test.stopTest();

        System.assert(!records.isEmpty(), 'No records retrieved.');
    }

    @IsTest
    static void testRunWithQuery() {
        List<SObject> records = new List<SObject>();

        createAccountRecords();

        String query = 'SELECT Id FROM Account';
        Test.startTest();
            records = soqlService.run(query);
        Test.stopTest();

        System.assert(!records.isEmpty(), 'No records retrieved.');
    }

    @IsTest
    static void testGetRecentlyViewedRecords() {
        List<SObject> recentlyViewedRecords = new List<SObject>();
        
        createAccountRecords();

        soqlService.setObjectType(objectType);
        Test.startTest();
            recentlyViewedRecords = soqlService.getRecentlyViewedRecords();
        Test.stopTest();
        
        System.assert(!recentlyViewedRecords.isEmpty(), 'No records retrieved.');
    }

    private static void createAccountRecords() {
        List<Account> newAccts = new List<Account>();

        for (Integer counter = 0; counter < 5; counter++) {
            newAccts.add(new Account(Name = 'Batman-' + counter));
        }

        insert newAccts;
    }
}