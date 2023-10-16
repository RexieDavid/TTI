/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: This class handles all service logic for BlackhawkAPI
*/ 
public class BlackhawkAPIService {

    public static final String SUCCESSCODE = '201';

    public class BlackhawkApiServiceException extends Exception {} 
    
    public static RealTimeEgiftBulkResponseWrapper submitRealTimeEgiftBulk(Member_Benefit__c memberBenefitRecord){
        
        RealTimeEgiftBulkResponseWrapper rtebrWrap;// = new RealTimeEgiftBulkResponseWrapper();
        try{
            HttpResponse responseInstance = getRealTimeEgiftBulk(getBlackhawkEGiftRequestWInputWrapper(memberBenefitRecord));
            String statusCode = String.valueOf(responseInstance.getStatusCode());
            if(statusCode == SUCCESSCODE){
                System.debug('SUCCESSCODE >>> '+statusCode);
                RealTimeEgiftBulkSuccessWrapper successWrap = new RealTimeEgiftBulkSuccessWrapper();
                rtebrWrap = new RealTimeEgiftBulkResponseWrapper(false,statusCode,successWrap.parse(responseInstance.getBody()),null);
            }
            else if(statusCode.startsWith('4') || statusCode.startsWith('5')){
                System.debug('responseInstance >>> '+responseInstance); 
                System.debug('ERRORCODE >>> '+responseInstance.getStatusCode()); 
                RealTimeEgiftBulkErrorWrapper errorWrap = new RealTimeEgiftBulkErrorWrapper();
                rtebrWrap = new RealTimeEgiftBulkResponseWrapper(false,statusCode,null,errorWrap.parse(responseInstance.getBody()));
            }
        }
        catch(Exception e){
            throw new BlackhawkApiServiceException('Error in BlackhawkAPIService. '+' Line Number: '+e.getLineNumber() + ' - ' +e.getMessage());
        }
        return rtebrWrap;
    }

    public static HttpResponse monitorRewards(){
        Blackhawk_API_Settings__c bhAPISetting = getActiveBlackhawkApiSetting();
        System.debug('bhAPISetting >>> '+bhAPISetting);
        Http httpInstance = new Http();
        HttpRequest httpRequestInstance = new HttpRequest();
        httpRequestInstance.setEndpoint('callout:BlackhawkAPI'+bhAPISetting.Monitoring_Status_Endpoint__c);
        httpRequestInstance.setClientCertificateName(bhAPISetting.Client_Certificate_Name__c);
        httpRequestInstance.setHeader('Content-Type','application/json');
        httpRequestInstance.setHeader('Merchantid',bhAPISetting.Merchant_Id__c);
        httpRequestInstance.setHeader('Requestid',String.valueOf(DateTime.now().millisecond()));
        httpRequestInstance.setMethod('GET');
        HttpResponse httpResponse = httpInstance.send(httpRequestInstance);  
        System.debug(httpResponse.getBody());
        return httpResponse;        
    }

    public static HttpResponse getCatalogByKey(String clientProgramId){
        Blackhawk_API_Settings__c bhAPISetting = getActiveBlackhawkApiSetting();
        bhAPISetting = getActiveBlackhawkApiSetting();
        Http httpInstance = new Http();
        HttpRequest httpRequestInstance = new HttpRequest();
        httpRequestInstance.setEndpoint('callout:BlackhawkAPI'+bhAPISetting.Catalog_API_Endpoint__c+'?clientProgramId='+clientProgramId);//rewardsCatalogProcessing/v1/clientProgram/byKey'+'?clientProgramId='+clientProgramId);
        httpRequestInstance.setClientCertificateName(bhAPISetting.Client_Certificate_Name__c);
        httpRequestInstance.setHeader('Content-Type','application/json');
        httpRequestInstance.setHeader('Merchantid',bhAPISetting.Merchant_Id__c);
        httpRequestInstance.setHeader('Requestid',String.valueOf(DateTime.now().millisecond())); 
        httpRequestInstance.setMethod('GET');
        HttpResponse httpResponse = httpInstance.send(httpRequestInstance);  
        BlackhawkClientProgramWrapper bhcpWrapObj = BlackhawkClientProgramWrapper.parse(httpResponse.getBody());
        return httpResponse;
    }

    public static HttpResponse getRealTimeEgiftBulk(BlackhawkEGiftRequestWInputWrapper requestWrap){
        Blackhawk_API_Settings__c bhAPISetting = getActiveBlackhawkApiSetting();
        bhAPISetting = getActiveBlackhawkApiSetting();
        Http httpInstance = new Http();
        HttpRequest httpRequestInstance = new HttpRequest();
        httpRequestInstance.setTimeout(120000);
        httpRequestInstance.setEndpoint('callout:BlackhawkAPI'+bhAPISetting.Real_time_eGift_Endpoint__c);
        httpRequestInstance.setClientCertificateName(bhAPISetting.Client_Certificate_Name__c);
        httpRequestInstance.setHeader('Content-Type','application/json');
        httpRequestInstance.setHeader('Merchantid',bhAPISetting.Merchant_Id__c);
        httpRequestInstance.setHeader('Requestid',requestWrap.requestId);
        httpRequestInstance.setHeader('millisecondsToWait',bhAPISetting.Milliseconds_To_Wait__c);
        httpRequestInstance.setHeader('SYNCHRONOUS_ONLY',String.valueOf(bhAPISetting.SYNCHRONOUS_ONLY__c));
        httpRequestInstance.setMethod('POST');
        httpRequestInstance.setBody(generateRequest(requestWrap,bhAPISetting));  
        HttpResponse httpResponse = httpInstance.send(httpRequestInstance); 
        System.debug(httpResponse.getStatusCode());
        System.debug(httpResponse.getBody());
        return httpResponse; 
    }

    public static BlackhawkEGiftRequestWInputWrapper getBlackhawkEGiftRequestWInputWrapper(Member_Benefit__c memberBenefitRecord){
        return new BlackhawkEGiftRequestWInputWrapper(memberBenefitRecord.Id, memberBenefitRecord.Name, memberBenefitRecord.Member_Benefit_Program__r.Gift_Card_Value__c, memberBenefitRecord.Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__r.Content_Provider_Code__c); 
    }

    public List<Blackhawk_Card_Product__c> generateBlackhawkCardProducts (BlackhawkClientProgramWrapper blackhawkClientWrapObj){

        List<Blackhawk_Card_Product__c> blackHawkCardProductListToInsert = new List<Blackhawk_Card_Product__c>();

        if(blackhawkClientWrapObj.products.size() > 0){
            for(BlackhawkClientProgramWrapper.Products product : blackhawkClientWrapObj.products){
                Blackhawk_Card_Product__c bcp = new Blackhawk_Card_Product__c();
                bcp.Name = product.contentProviderCode;
                bcp.Client_Program_Id__c = blackhawkClientWrapObj.clientProgramId;
                bcp.Content_Provider_Code__c = product.contentProviderCode;
                bcp.Currency__c = blackhawkClientWrapObj.currency_Z;
                bcp.Locale__c = product.locale;
                bcp.Logo_Image__c = product.logoImage;
                bcp.VR_Maximum__c = product.valueRestrictions.maximum;
                bcp.VR_Minimum__c = product.valueRestrictions.minimum;
                bcp.Parent_Brand_Name__c = product.parentBrandName;
                bcp.Product_Description__c = product.productDescription;
                bcp.Product_Image__c = product.productImage;
                bcp.Product_Name__c = product.productName;
                bcp.Program_Name__c = blackhawkClientWrapObj.programName;
                bcp.Program_Type__c = blackhawkClientWrapObj.programType;
                bcp.Redemption_Info__c = blackhawkClientWrapObj.programType;
                bcp.TNC_Text__c = product.termsAndConditions.text;
                bcp.TNC_Type__c = product.termsAndConditions.type;
                blackHawkCardProductListToInsert.add(bcp);
            }
        }
        
        return blackHawkCardProductListToInsert;
    }

    private static String generateRequest(BlackhawkEGiftRequestWInputWrapper requestWrap, Blackhawk_API_Settings__c bhAPISetting){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('clientProgramNumber', bhAPISetting.Client_Program_Id__c);
        gen.writeStringField('paymentType', bhAPISetting.Payment_Type__c);
        gen.writeStringField('returnCardNumberAndPIN', String.valueOf(bhAPISetting.Return_Card_Number_and_PIN__c));
        gen.writeFieldName('orderDetails');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('clientRefId', requestWrap.clientReferenceId);
        gen.writeStringField('quantity', '1');
        gen.writeStringField('amount', String.valueOf(requestWrap.amount));
        gen.writeStringField('contentProvider', requestWrap.contentProvider);
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        String pretty = gen.getAsString();
        System.debug(pretty);
        return pretty;
    }

    public class RealTimeEgiftBulkResponseWrapper{

        public Boolean hasError {get;set;}
        public String statusCode {get;set;}
        public RealTimeEgiftBulkSuccessWrapper successWrap {get;set;}
        public RealTimeEgiftBulkErrorWrapper errorWrap {get;set;}

        public RealTimeEgiftBulkResponseWrapper (Boolean hasError, String statusCode, RealTimeEgiftBulkSuccessWrapper successWrap, RealTimeEgiftBulkErrorWrapper errorWrap){
            this.hasError = hasError;
            this.statusCode = statusCode;
            this.successWrap = successWrap;
            this.errorWrap = errorWrap;
        } 

    }

    public class RealTimeEgiftBulkSuccessWrapper{

        public String transactionId;	
        public Boolean isCompleted;
        public Integer percentComplete;	
        public boolean success;
        public String orderNumber;
        public String url;	
        public String contentProviderCode;	
        public Decimal transactionAmount;

        public RealTimeEgiftBulkSuccessWrapper parse(String json){
            return (RealTimeEgiftBulkSuccessWrapper) System.JSON.deserialize(json, RealTimeEgiftBulkSuccessWrapper.class);
        }
    
    }

    public class RealTimeEgiftBulkErrorWrapper {

        public List<Errors> errors;
    
        public RealTimeEgiftBulkErrorWrapper parse(String json) {
            return (RealTimeEgiftBulkErrorWrapper) System.JSON.deserialize(json, RealTimeEgiftBulkErrorWrapper.class);
        }
    }

    public class Errors {
        public String errorCode;
        public String message;
    }

    public class BlackhawkEGiftRequestWInputWrapper{

        public String requestId {get;set;} 
        public String clientReferenceId {get;set;} 
        public Decimal amount {get;set;} 
        public String contentProvider {get;set;} 
        
        public BlackhawkEGiftRequestWInputWrapper (String requestId, String clientReferenceId, Decimal amount, String contentProvider){
            this.requestId = requestId;
            this.clientReferenceId = clientReferenceId;
            this.amount = amount;
            this.contentProvider = contentProvider;
        }

    }

    private static Blackhawk_API_Settings__c getActiveBlackhawkApiSetting (){
        return [SELECT  Id, Catalog_API_Endpoint__c, Client_Program_Id__c, Is_Active__c, Merchant_Id__c, 
                        Milliseconds_To_Wait__c, Monitoring_Status_Endpoint__c, Payment_Type__c, Real_time_eGift_Endpoint__c,
                        Return_Card_Number_and_PIN__c, SYNCHRONOUS_ONLY__c, Client_Certificate_Name__c
                FROM Blackhawk_API_Settings__c
                WHERE Is_Active__c = TRUE];
    }

    // private static TTI_Error_Log__c generateErrorLog(){

    // }

}