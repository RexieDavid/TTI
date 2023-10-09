/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Cloud Storage Orchestration
 */
@isTest
private class InjectorTest {
    private static final String ERR_APEX_CLASS_NOT_FOUND = 'Apex class not found';
    private static final String ERR_CLASS_NAME_REQUIRED = 'Class Name is required';

    /**
     * @description                 Dynamically instantiate existing class
     */
    @isTest
    private static void instantiateExistingClass() {
        Object obj;
        Test.startTest();
            obj = Injector.instantiate('InjectorTest.MockInjector');
        Test.stopTest();
        System.assert(obj != null, 'Failed to instantiate class');
    }

    /**
     * @description                 Dynamically instantiate non-existing class
     */
    @isTest
    private static void instantiateUnexistingClass() {
        String errMessage;
        Test.startTest();
            try {
                Injector.instantiate('MockInjector' + Datetime.now().getTime());
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ERR_APEX_CLASS_NOT_FOUND, errMessage, 'Successfully instantiated class');
    }

    /**
     * @description                 Dynamically instantiate null value
     */
    @isTest
    private static void instantiateNullClass() {
        String errMessage;
        Test.startTest();
            try {
                Injector.instantiate(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ERR_CLASS_NAME_REQUIRED, errMessage, 'Successfully instantiated class');
    }

    /**
     * @description                 Mock class for instantiating
     */
    public class MockInjector {}
}