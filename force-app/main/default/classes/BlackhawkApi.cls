public class BlackhawkApi {

    public Blackhawk_API_Settings__c bhAPISetting = new Blackhawk_API_Settings__c();

    public BlackhawkApi(){
        bhAPISetting = getActiveBlackhawkApiSetting();
    }

    public void rewardsMonitoring(){
        System.debug('bhAPISetting >>> '+bhAPISetting);
        Http httpInstance = new Http();
        HttpRequest httpRequestInstance = new HttpRequest();
        httpRequestInstance.setEndpoint('callout:BlackhawkAPI'+bhAPISetting.Monitoring_Status_Endpoint__c);///rewardsOrderProcessing/v1/monitor');
        httpRequestInstance.setClientCertificateName(bhAPISetting.Client_Certificate_Name__c);
        httpRequestInstance.setHeader('Content-Type','application/json');
        httpRequestInstance.setHeader('Merchantid',bhAPISetting.Merchant_Id__c);
        httpRequestInstance.setHeader('Requestid',String.valueOf(DateTime.now().millisecond()));
        httpRequestInstance.setMethod('GET');
        HttpResponse httpResponse = httpInstance.send(httpRequestInstance);  
        System.debug(httpResponse.getBody());
    }

    public void getCatalogByKey(String clientProgramId){
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
        upsert generateBlackhawkCardProducts(bhcpWrapObj) Content_Provider_Code__c;
    }

    public void submitRealTimeEgiftBulk(){
        RealTimeEgiftBulkResponseWrapper rtebrWrap = new RealTimeEgiftBulkResponseWrapper();
        Http httpInstance = new Http();
        HttpRequest httpRequestInstance = new HttpRequest();
        httpRequestInstance.setTimeout(120000);
        httpRequestInstance.setEndpoint('callout:BlackhawkAPI'+bhAPISetting.Real_time_eGift_Endpoint__c);//rewardsOrderProcessing/v1/submitRealTimeEgiftBulk');
        httpRequestInstance.setClientCertificateName(bhAPISetting.Client_Certificate_Name__c);
        httpRequestInstance.setHeader('Content-Type','application/json');
        httpRequestInstance.setHeader('Merchantid',bhAPISetting.Merchant_Id__c);
        httpRequestInstance.setHeader('Requestid',String.valueOf(DateTime.now().millisecond()));
        httpRequestInstance.setHeader('millisecondsToWait',bhAPISetting.Milliseconds_To_Wait__c);
        httpRequestInstance.setHeader('SYNCHRONOUS_ONLY',String.valueOf(bhAPISetting.SYNCHRONOUS_ONLY__c));
        httpRequestInstance.setMethod('POST');
        httpRequestInstance.setBody(generateRequest(0,''));  
        HttpResponse httpResponse = httpInstance.send(httpRequestInstance);  
        System.debug(httpResponse.getStatusCode());
        System.debug(httpResponse.getBody());
        System.debug('rtebrWrap >>> '+rtebrWrap.parse(httpResponse.getBody()));
    }

    public String generateRequest(Decimal amount, String contentProvider){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('clientProgramNumber', bhAPISetting.Client_Program_Id__c);
        gen.writeStringField('paymentType', bhAPISetting.Payment_Type__c);
        gen.writeStringField('returnCardNumberAndPIN', String.valueOf(bhAPISetting.Return_Card_Number_and_PIN__c));
        gen.writeFieldName('orderDetails');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('clientRefId', String.valueOf(DateTime.now().millisecond()));
        gen.writeStringField('quantity', '1');
        gen.writeStringField('amount', '5.01');
        gen.writeStringField('contentProvider', 'IAGOnly1VirtualVisa_AUD_en_eGift');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        String pretty = gen.getAsString();
        System.debug(pretty);
        return pretty;
    }

    public class RealTimeEgiftBulkResponseWrapper{
        public String transactionId;	//435LYTF8GAS6NCB3R9TLCXWY30
        public boolean isCompleted;
        public Integer percentComplete;	//100
        public boolean success;
        public String orderNumber;	//401087978
        public String url;	//https://egiftpp.blackhawknetwork.com/egift?tid=657Q0RGVTJTZKC50AW2P8STYQC&gcm=n&gs=n&gw=n&eid=Z6BWA51S8BN9TZW4JPW719LNT8
        public String contentProviderCode;	//BestBuy_eGift
        public Decimal transactionAmount;	//25

        public RealTimeEgiftBulkResponseWrapper parse(String json){
            return (RealTimeEgiftBulkResponseWrapper) System.JSON.deserialize(json, RealTimeEgiftBulkResponseWrapper.class);
        }
    
    }

    public Blackhawk_API_Settings__c getActiveBlackhawkApiSetting (){
        return [SELECT  Id, Catalog_API_Endpoint__c, Client_Program_Id__c, Is_Active__c, Merchant_Id__c, 
                        Milliseconds_To_Wait__c, Monitoring_Status_Endpoint__c, Payment_Type__c, Real_time_eGift_Endpoint__c,
                        Return_Card_Number_and_PIN__c, SYNCHRONOUS_ONLY__c, Client_Certificate_Name__c
                FROM Blackhawk_API_Settings__c
                WHERE Is_Active__c = TRUE];
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
}