@isTest
private class MyAEGDataCollectionControllerTest {
    
    @isTest
    private static void test_method_one() {
        MyAEGDataCollectionController controller = new MyAEGDataCollectionController();
        controller.getTradeSelectOptions();
        controller.getAppSelectOptions();
        controller.firstName = 'Ann';
        controller.lastName = 'Monterey';
        controller.email = 'ann.monterey@gmail.test.com';
        controller.mobilePhone = '09129638520';
        
        controller.submitForm();
    }
}