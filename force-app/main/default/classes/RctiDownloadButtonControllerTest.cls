/**
* @author                           Francis Nasalita
* @date                             2020-10-14
* @description                      Test class for RCTI Download Button Controller
*/
@IsTest
public with sharing class RctiDownloadButtonControllerTest {
    
    @IsTest
    static void testGetRCTIPdf() {
        Test.setMock(HttpCalloutMock.class, new AwsServiceHttpCalloutMockImpl());
        
        Test.startTest();
            String pdf = RctiDownloadButtonController.getRCTIPdf('key');

            System.assert(pdf != null, 'Retrieving the RCTI pdf failed.');
        Test.stopTest();
        
    }
}