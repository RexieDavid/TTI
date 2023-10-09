/**
* @author: Francis Nasalita
* @date: 2020-10-14
* @description: AWS service class
*/
public class AwsService {

    private static final String AWS_NAMED_CREDENTIALS = 'callout:AWS_S3_Integration';
    private static final Integer OK_STATUS = 200;

    /**********************************************************************
     * @description                     Retrieves a file from AWS 
     * 
     * @param awsKey                    AWS Key
     * @param bucketName                Bucket Name (AWS_S3_Bucket__mdt Developer Name)
     * 
     * @return                          file in base64
     */
    @AuraEnabled(cacheable=true)
    public static String getFileFromS3Bucket(String awsKey, String bucketName) {
        AWS_S3_Bucket__mdt bucketData = getBucketData(bucketName);

        Map<String, String> headers = new Map<String, String>();
        headers.put('Host', bucketData.Bucket_Name__c + '.s3.' + bucketData.Region__c + '.amazonaws.com');

        String endpoint = AWS_NAMED_CREDENTIALS + '/' + bucketData.Bucket_Name__c + '/' + awsKey;
        String method = 'GET';

        Http http = new Http();
        HttpResponse res = execCallout(endpoint, method, headers);

        if (res.getStatusCode() != OK_STATUS) {
            String response = res.getBody();
            insertSystemlog('error', response, 'CLASS.AwsService.getFileFromS3Bucket');

            throw new AwsServiceException(response);
        }


        return EncodingUtil.base64Encode(res.getBodyAsBlob());
    }

    /**********************************************************************
     * @description                     Get Bucket Name
     * 
     * @param bucketName                Bucket Name
     *      
     * @return                          bucket data
     */
    private static AWS_S3_Bucket__mdt getBucketData(String bucketName) {
        if (Test.isRunningTest()) {
            return new AWS_S3_Bucket__mdt(
                DeveloperName = bucketName,
                Bucket_Name__c = bucketName,
                Region__c = 'test-region'
            );
        } else {
            return [SELECT Bucket_Name__c, Region__c FROM AWS_S3_Bucket__mdt WHERE DeveloperName = :bucketName LIMIT 1];
        }
    }

    @TestVisible
    private static HttpResponse execCallout(String endpoint, String method, Map<String, String> headers) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }

        HttpResponse response = http.send(request);

        return response;
    }

    private static String insertSystemlog(String logType, String logValue, String logModule) {
        List<System_Log__e> logEvents = new List<System_Log__e>();
        List<Map<String, String>> errorMap = new List<Map<String, String>> {
            new Map<String,String> {
                'type' => logType, 
                'value' => logValue,
                'module' => logModule
            }
        };

        logEvents.add(new System_Log__e(
            Level__c = 'error',
            Payload__c = JSON.serialize(errorMap)
        ));

        System.debug('System Log: ' + logEvents);
        return JSON.serialize(logEvents);
        // SD-1286 - Disable System Logs
        // List<Database.SaveResult> results = EventBus.publish(logEvents);
        // return JSON.serialize(results);
    }

    public class AwsServiceException extends Exception {}
}