/**
 * @author                              Francis Nasalita
 * @date                                2020-10-14
 * @group                               AWS
 */
@IsTest
public with sharing class AwsServiceTest {
    
    @IsTest
    static void testGetFileFromS3Bucket() {
        Test.setMock(HttpCalloutMock.class, new AwsServiceHttpCalloutMockImpl());
        
        Test.startTest();
            String pdf = AwsService.getFileFromS3Bucket('key', 'RCTI_Bucket');

            System.assert(pdf != null, 'Retrieving the file failed.');
        Test.stopTest();
        
    }

    @IsTest
    static void testGetFileFromS3BucketNegative() {
        Test.setMock(HttpCalloutMock.class, new AwsServiceHttpCalloutMockImpl());
        
        Test.startTest();
            try {
                String pdf = AwsService.getFileFromS3Bucket('fail', 'RCTI_Bucket');
            } catch (Exception e) {
                System.assertEquals('Not Found', e.getMessage(), 'Retrieving the file succeeded.');
            }
        Test.stopTest();
        
    }
}