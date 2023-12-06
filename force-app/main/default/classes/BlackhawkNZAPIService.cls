/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: This class handles all service logic for BlackhawkAPI NZ
*/ 
public class BlackhawkNZAPIService {

    public class BlackhawkApiServiceException extends Exception {} 
    public static final String SUCCESSEGIFTCODE = '200';

    public static BlackhawkNZOrderWrapper submitNZGiftCardOrder(Member_Benefit__c memberBenefitRecord){

        LogException logger = new LogException();
        BlackhawkNZOrderWrapper nzWrap;
        try{
            memberBenefitRecord.Request_Id__c = memberBenefitRecord.Name+'-'+generateRandomString(6);
            HttpResponse responseInstance = getOrderGiftCardUrl(memberBenefitRecord);
            nzWrap = BlackhawkNZOrderWrapper.parse(responseInstance.getBody()); 
            System.debug('nzWrap >>> ' + nzWrap);

            String statusCode = String.valueOf(responseInstance.getStatusCode());
            if(statusCode == SUCCESSEGIFTCODE){
                if(nzWrap.Response != NULL && nzWrap.Result == 0){
                    System.debug('if >>>');
                    String url = getGiftCardUrl(nzWrap);
                    System.debug('success >>> '+url);
                }
                else{
                    System.debug('else >>>');
                    if(memberBenefitRecord.Gift_Card_Request_Counter__c == NULL || memberBenefitRecord.Gift_Card_Request_Counter__c == 0) throw new BlackhawkApiServiceException('Status Code: '+statusCode + ' - ' + JSON.serialize(nzWrap));
                }
                
            }
            else if(statusCode.startsWith('4') || statusCode.startsWith('5')){
                System.debug('error >>> '+statusCode);
                if(memberBenefitRecord.Gift_Card_Request_Counter__c == 0) throw new BlackhawkApiServiceException('Status Code: '+statusCode + ' - ' + JSON.serialize(nzWrap));
            }

        }
        catch(Exception e){
            logger.Module('Integration')
                    .ExceptionCause('ApiError')
                    .SourceObject('Member_Benefit__c')
                    .SourceRecord(memberBenefitRecord.Id)
                    .log(e);
        }
        return nzWrap;

    }

    public static void createNZProductCatalogue(){
        
        http http = new http();
        httpRequest request = new httpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:BlackhawkAPINZPreProd'+'/api/v2/catalogue'); 
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        System.debug(request.getEndpoint());
        httpResponse res = http.send(request);
        System.debug(res.getStatus());
        System.debug(res.getStatusCode());
        System.debug(res.getBody());
        if(res.getStatusCode() == 200){
            BlackhawkNZCatalogueWrapper nzCatalogue = BlackhawkNZCatalogueWrapper.parse(res.getBody());
            if(nzCatalogue != NULL && nzCatalogue.Result == 0){
                List<Blackhawk_Card_Product__c> nzProductCatalogueList = getNZProductCatalogueList(nzCatalogue);
                if(nzProductCatalogueList.size() > 0){
                    insert nzProductCatalogueList;
                    System.debug('Successfully created.');
                } 
            }
        }
        else{
            System.debug(res.getStatus());
            System.debug(res.getStatusCode());
        }  

    }

    public static HttpResponse getOrderGiftCardUrl(Member_Benefit__c memberBenefitRecord){

        http http = new http();
        httpRequest request = new httpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:BlackhawkAPINZPreProd'+'/api/v1/order'); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setBody(JSON.serializePretty(getOrderRequestBody(memberBenefitRecord)).replace('From_Z', 'From'));
        System.debug(request.getBody());
        System.debug(request.getEndpoint());
        httpResponse res = http.send(request);
        System.debug(res.getStatus());
        System.debug(res.getStatusCode());
        System.debug(res.getBody());        
        return res;
    }

    public static String getGiftCardUrl(BlackhawkNZOrderWrapper nzOrder){
        if(nzOrder.Response.DigitalStoreCardOrder.OrderItems != NULL){
            for(BlackhawkNZOrderWrapper.OrderItems order : nzOrder.Response.DigitalStoreCardOrder.OrderItems){
                if(order.Metadata != NULL){
                    for(BlackhawkNZOrderWrapper.Metadata meta : order.Metadata){
                        if(meta.CardUrl != NULL){
                            return meta.CardUrl;
                        }
                    }
                }
            }
        }
        return null;
    }

    public static List<Blackhawk_Card_Product__c> getNZProductCatalogueList(BlackhawkNZCatalogueWrapper nzCatalogueWrap){

        List<Blackhawk_Card_Product__c> nzProductCatalogueList = new List<Blackhawk_Card_Product__c>();

        if(nzCatalogueWrap.Result == 0){
            for(BlackhawkNZCatalogueWrapper.DigitalStoreCards digitalStoreCard : nzCatalogueWrap.Response.DigitalStoreCards){
                nzProductCatalogueList.add(new Blackhawk_Card_Product__c(
                    Content_Provider_Code__c = String.valueOf(digitalStoreCard.Identifier),
                    Locale__c = digitalStoreCard.Language,
                    Name = digitalStoreCard.SKU,
                    Product_Description__c = digitalStoreCard.ProductDescription,
                    Product_Image__c = digitalStoreCard.ProductThumbnailUrl,
                    Product_Name__c = digitalStoreCard.ProductDescription,
                    Program_Name__c = digitalStoreCard.ProductName,
                    Program_Type__c = 'DigitalStoreCards',
                    TNC_Text__c = digitalStoreCard.TermsAndConditions,
                    TNC_Type__c = 'DigitalStoreCards',
                    VR_Maximum__c = digitalStoreCard.VariableMaxValue,
                    VR_Minimum__c = digitalStoreCard.VariableMinValue
                ));
            }
        }

        return nzProductCatalogueList;
    } 

    public static String getOrderRequestBody(Integer amount, String sku){

        BlackhawkNZOrderRequestWrapper blackhawkNZOrder = new BlackhawkNZOrderRequestWrapper();
        blackhawkNZOrder.OrderReferenceNumber = 'Test000001';
        BlackhawkNZOrderRequestWrapper.Recipient recipient = new BlackhawkNZOrderRequestWrapper.Recipient();
        recipient.Email = 'Test000001@test.com';
        blackhawkNZOrder.Recipient = recipient;
        
        BlackhawkNZOrderRequestWrapper.DigitalStoreCardOrder digitalScoreCardOrder = new BlackhawkNZOrderRequestWrapper.DigitalStoreCardOrder();
        
        BlackhawkNZOrderRequestWrapper.PersonalisationInfo personInfo = new BlackhawkNZOrderRequestWrapper.PersonalisationInfo();
        personInfo.To = '';
        personInfo.Message = '';
        personInfo.From_Z = '';
        digitalScoreCardOrder.PersonalisationInfo = personInfo;

        List<BlackhawkNZOrderRequestWrapper.OrderItems> orderItemsList = new List<BlackhawkNZOrderRequestWrapper.OrderItems>();
        BlackhawkNZOrderRequestWrapper.OrderItems orderItem = new BlackhawkNZOrderRequestWrapper.OrderItems();
        orderItem.Quantity = 1;
        orderItem.Amount = amount;
        orderItem.SKU = sku;
        orderItem.ReferenceNumber = 'Test000001';
        orderItemsList.add(orderItem);
        digitalScoreCardOrder.OrderItems = orderItemsList;

        blackhawkNZOrder.DigitalStoreCardOrder = digitalScoreCardOrder;
        
        return JSON.serializePretty(blackhawkNZOrder); 

    }

    public static BlackhawkNZOrderRequestWrapper getOrderRequestBody(Member_Benefit__c memberBenefitRecord){

        String counter = (memberBenefitRecord.Gift_Card_Request_Counter__c != NULL) ? String.valueOf(memberBenefitRecord.Gift_Card_Request_Counter__c) : '0';

        BlackhawkNZOrderRequestWrapper blackhawkNZOrder = new BlackhawkNZOrderRequestWrapper();
        blackhawkNZOrder.OrderReferenceNumber = memberBenefitRecord.Request_Id__c;
        BlackhawkNZOrderRequestWrapper.Recipient recipient = new BlackhawkNZOrderRequestWrapper.Recipient();
        recipient.Email = 'Test000001@test.com';
        blackhawkNZOrder.Recipient = recipient;
        
        BlackhawkNZOrderRequestWrapper.DigitalStoreCardOrder digitalScoreCardOrder = new BlackhawkNZOrderRequestWrapper.DigitalStoreCardOrder();
        
        BlackhawkNZOrderRequestWrapper.PersonalisationInfo personInfo = new BlackhawkNZOrderRequestWrapper.PersonalisationInfo();
        personInfo.To = '';
        personInfo.Message = '';
        personInfo.From_Z = '';
        digitalScoreCardOrder.PersonalisationInfo = personInfo;

        List<BlackhawkNZOrderRequestWrapper.OrderItems> orderItemsList = new List<BlackhawkNZOrderRequestWrapper.OrderItems>();
        BlackhawkNZOrderRequestWrapper.OrderItems orderItem = new BlackhawkNZOrderRequestWrapper.OrderItems();
        orderItem.Quantity = 1;
        orderItem.Amount = memberBenefitRecord.Member_Benefit_Program__r.Gift_Card_Value__c;//amount;
        orderItem.SKU = memberBenefitRecord.Member_Benefit_Program__r.Blackhawk_Catalog_Lookup__r.Name;
        orderItem.ReferenceNumber = memberBenefitRecord.Name+'-'+counter;
        orderItemsList.add(orderItem);
        digitalScoreCardOrder.OrderItems = orderItemsList;

        blackhawkNZOrder.DigitalStoreCardOrder = digitalScoreCardOrder;
        return blackhawkNZOrder;
        
    }

    public static String generateRandomString(Integer len) {
        final String chars = '0123456789';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}