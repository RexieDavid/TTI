/**
 * author:      Francis Nasalita
 * date:        2021-05-25
 */
@isTest
public class CustomLookupControllerTest {
    
    private static final String objectType = 'Account';
    private static final List<String> fieldList = new List<String>{ 'Name', 'OwnerId' };
    private static final String conditionExpression = 'WHERE Name = \'Batman\'';
    
    @IsTest
    static void testInit() {

        Test.startTest();
            CustomLookupController.CustomLookupResponse response = CustomLookupController.init(objectType, fieldList, conditionExpression);
        Test.stopTest();
        
        System.assertEquals('SELECT Name, OwnerId, Id FROM Account WHERE Name = \'Batman\' LIMIT 200', response.query, 'Query does not match.');
    }

    @IsTest
    static void testInitWithMaxRows() {
        String maxRows = '10';

        Test.startTest();
            CustomLookupController.CustomLookupResponse response = CustomLookupController.init(objectType, fieldList, conditionExpression, maxRows);
        Test.stopTest();
        
        System.assertEquals('SELECT Name, OwnerId, Id FROM Account WHERE Name = \'Batman\' LIMIT 10', response.query, 'Query does not match.');
    }

    @IsTest
    static void testSearchRecords() {
        Account newAcct = new Account(Name = 'Batman');
        insert newAcct;
        
        CustomLookupController.CustomLookupResponse response = CustomLookupController.init(objectType, fieldList, conditionExpression);
        
        Test.startTest();
            CustomLookupController.CustomLookupResponse searchResponse = CustomLookupController.searchRecords(response.query);
        Test.stopTest();
        
        System.assert(!searchResponse.records.isEmpty(), 'No records found.');
    }
}