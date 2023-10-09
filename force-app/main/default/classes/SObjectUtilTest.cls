/**
 * author:      Francis Nasalita
 * date:        2021-05-18
 * 
 */
@isTest
public class SObjectUtilTest {
    
    private static final String objectType = 'Account';

    @IsTest
    static void testSObjectExist() {
        
        Test.startTest();
            Boolean isObjectExist = SObjectUtil.isObjectExist(objectType);
        Test.stopTest();

        System.assert(isObjectExist, 'Invalid object.');
    }

    @IsTest
    static void testSObjectExistNegative() {
        String invalidSObject = 'Test Object';
        
        Test.startTest();
            Boolean isObjectExist = SObjectUtil.isObjectExist(invalidSObject);
        Test.stopTest();

        System.assert(!isObjectExist, 'Valid object.');
    }

    @IsTest
    static void testIsFieldExistRecordType() {
        
        Test.startTest();
            Boolean isFieldExist = SObjectUtil.isFieldExist(objectType, 'RecordType.Id');
        Test.stopTest();

        System.assert(isFieldExist, 'RecordType field does not exist.');
    }

    @IsTest
    static void testIsFieldExist() {
        List<String> fields = new List<String>{
            'FirstName',
            'LastName'
        };

        Test.startTest();
            Boolean isFieldExist = true;

            for (String field : fields) {
                isFieldExist &= SObjectUtil.isFieldExist(objectType, field);
            }
        Test.stopTest();

        String assertMessage = String.format(
            '{0} fields does not exist.', 
            new List<Object>{
                String.join(fields, ', ')
            }
        );
        System.assert(isFieldExist, assertMessage);
    }

    @IsTest
    static void testIsFieldExistInvalidField() {
        String invalidField = 'Test Field';

        Test.startTest();
            Boolean isFieldExist = SObjectUtil.isFieldExist(objectType, invalidField);
        Test.stopTest();
        
        System.assert(!isFieldExist, invalidField + ' field exist.');
    }
}