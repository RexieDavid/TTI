/**
* @author: Francis Nasalita
* @date: 2020-09-30
* @description: This class handles logic for downloading file from aws
*/
public class RctiDownloadButtonController {

    private static final String RCTI_BUCKET_NAME = 'RCTI_Bucket';
    
    /**********************************************************************
     * @description                     Retrieves a file from AWS 
     * 
     * @param awsKey                    AWS Key
     * 
     * @return                          pdf in base64
     */
    @AuraEnabled(cacheable=true)
    public static String getRCTIPdf(String awsKey) {
        return AwsService.getFileFromS3Bucket(awsKey, RCTI_BUCKET_NAME);
    }
}