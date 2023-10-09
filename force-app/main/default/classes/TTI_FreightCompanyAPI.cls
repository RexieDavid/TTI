public class TTI_FreightCompanyAPI {
    
    public static TTI_CreateAPIPayload objPayload;
    public static string triggerPointButtonName;
    
    
    public static void sendFreightCompanyRequest(List<Case> lstCase,string triggerPoint,TTI_FreightCompanyAPIResponse objResponse){
        triggerPointButtonName=triggerPoint;
        if(lstCase[0].Service_Agent__r.Freight_Company__c == 'TNT'){
            TNT_API(lstCase,objResponse);
            system.debug('objResponse==='+objResponse);
        }
        if(lstCase[0].Service_Agent__r.Freight_Company__c == 'Courier Post'){
            CourierPost_API(lstCase,objResponse);
            system.debug('objResponse==='+objResponse);
        }
        
    }
    
    public static void CourierPost_API(List<Case> lstCase,TTI_FreightCompanyAPIResponse objResponse){
        List<TTI_CreateAPIPayload> lstPayloadClass = new List<TTI_CreateAPIPayload>();
        createCourierPostPayload(lstCase,lstPayloadClass);
        string jsonRequest = JSON.serialize(lstPayloadClass[0]);
        objResponse.inputRequest=jsonRequest;
        TTI_Frieght_Company_API_Details__c objFreightCompanyDetails = TTI_Frieght_Company_API_Details__c.getValues('Courier Post');
        string accessToken = getAccessToken(objFreightCompanyDetails.TTI_Grant_Type__c,objFreightCompanyDetails.TTI_Client_Id__c,objFreightCompanyDetails.TTI_Client_Secret__c,objFreightCompanyDetails.TTI_Access_Token_Generation_URL__c);
        system.debug(accessToken);
        sendAPI_Request(objFreightCompanyDetails.TTI_Client_Id__c,accessToken,jsonRequest,objFreightCompanyDetails.TTI_EndpointURL__c,objResponse);   
    }
    public static void TNT_API(List<Case> lstCase,TTI_FreightCompanyAPIResponse objResponse){
        TTI_Frieght_Company_API_Details__c objFreightCompanyDetails = TTI_Frieght_Company_API_Details__c.getValues('TNT');
        if((lstCase[0].Freight_in_consignment_number__c==null && triggerPointButtonName=='SubmitClaim')
           || (lstCase[0].Freight_out_consignment_number__c==null && triggerPointButtonName=='MarkAsComplete'))
        {
            TNT_ConsignmentWebService(lstCase,objResponse,objFreightCompanyDetails);
            if(objResponse.Success){
                TNT_BookingWebserivce(lstCase,objResponse,objFreightCompanyDetails);
            }
        }
        else
        {
            TNT_BookingWebserivce(lstCase,objResponse,objFreightCompanyDetails);
            
        }
        
    }
    public static void TNT_ConsignmentWebService(List<Case> lstCase,TTI_FreightCompanyAPIResponse objResponse,TTI_Frieght_Company_API_Details__c objFreightCompanyDetails){
        string xmlRequest = createTNTConsignmentWebServicePayload(lstCase[0],objFreightCompanyDetails);
        objResponse.inputRequest=xmlRequest;
        system.debug(xmlRequest);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type','text/xml; charset=utf-8');
        httpRequest.setHeader('SOAPAction','http://tempuri.org/IConsignmentService/ProcessConsignmentRequest');
        httpRequest.setEndpoint('http://www.tntexpress.com.au/Webservices/Conservice/Consignmentservice.svc');
        HttpRequest.setBody(xmlRequest);
        try {
            Http http = new Http();
            HttpResponse httpResponse ;
            if(!Test.isRunningTest())
                httpResponse= http.send(httpRequest);
            if (Test.isRunningTest() || httpResponse.getStatusCode() == 200)
            {
                objResponse.Success=true;
                string consignmentNumber;
                if(triggerPointButtonName=='SubmitClaim')
                    consignmentNumber=objFreightCompanyDetails.Prefix__c+'1'+lstCase[0].CaseNumber;
                if(triggerPointButtonName=='MarkAsComplete')
                    consignmentNumber=objFreightCompanyDetails.Prefix__c+'2'+lstCase[0].CaseNumber;
                
                objResponse.Tracking_references=consignmentNumber;
            }
            else{
                objResponse.Success=false;
                objResponse.Error_message=httpResponse.getBody();
            }
        }
        catch (Exception ex)
        {
            String error = String.format('StackTrace: {0} | Message: {1} ', new String[]{ex.getStackTraceString(), ex.getMessage()});
            objResponse.Success=false;
            objResponse.Error_message=error;
        }
    }
    public static void TNT_BookingWebserivce(List<Case> lstCase,TTI_FreightCompanyAPIResponse objResponse,TTI_Frieght_Company_API_Details__c objFreightCompanyDetails){
        string xmlRequest = createTNTBookingWebServicePayload(lstCase[0],objFreightCompanyDetails);
        objResponse.inputRequest=xmlRequest;
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type','text/xml; charset=utf-8');
        httpRequest.setHeader('SOAPAction',objFreightCompanyDetails.TTI_SOAP_Action_URL__c);
        httpRequest.setEndpoint(objFreightCompanyDetails.TTI_EndpointURL__c);
        system.debug(xmlRequest);
        HttpRequest.setBody(xmlRequest);
        try {
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse httpResponse = http.send(httpRequest);
                system.debug(httpResponse);
                if (httpResponse.getStatusCode() != 200 )
                {
                    objResponse.Success=false;
                    objResponse.Error_message=httpResponse.getBody();
                }
            }
        }
        catch (Exception ex)
        {
            String error = String.format('StackTrace: {0} | Message: {1} ', new String[]{ex.getStackTraceString(), ex.getMessage()});
            objResponse.Success=false;
            objResponse.Error_message=error;
        }
    }
    
    public static string getAccessToken(string grant_type,string client_id,string client_secret,string accessTokenURL)
    {
        //Create Http request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        accessTokenURL=accessTokenURL+'?grant_type='+grant_type+'&client_id='+client_id+'&client_secret='+client_secret;
        req.setEndpoint(accessTokenURL);//to be configured       
        //send request        
        Http http = new Http();
        HTTPResponse jsonResponse = new HTTPResponse();        
        string jsonResponseBody;
        if(Test.isRunningTest())
        {
            jsonResponseBody='{"access_token":"abcd"}';
        }
        else
        {
            jsonResponse = http.send(req);    
            jsonResponseBody = jsonResponse.getBody(); 
        }
        string accessToken='';
        JSONParser parser =JSON.createParser(jsonResponseBody);
        
        while(parser.nextToken() != null)
        {   
            if(parser.getText() == 'access_token')
            {
                parser.nextToken();
                accessToken = parser.getText();
                break;
            }
        }
        
        return accessToken;  
    }
    
    private static void sendAPI_Request(string client_id,string accessToken,string jsonRequest,string Endpoint,TTI_FreightCompanyAPIResponse objResponse)
    {
        system.debug(jsonRequest);
        //Create Authorization Header Key
        String strAuthorizationHeader = 'Bearer '+accessToken;
        //Create Http request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(Endpoint);//to be configured       
        req.setHeader('Authorization',strAuthorizationHeader);
        req.setHeader('client_id', client_id);
        req.setHeader('Content-Type', 'application/json');      
        req.setBody(jsonRequest);                
        //send request        
        Http http = new Http();
        HTTPResponse jsonResponse = new HTTPResponse(); 
        if(!Test.isRunningTest())
        {
        	jsonResponse = http.send(req);      
        }
        
        if(Test.isRunningTest() || jsonResponse.getStatusCode() == 200 )
        {
            String jsonResponseBody ;
            if(Test.isRunningTest())
            {
                jsonResponseBody='{"success":true,"message_id":"d20cf9f0-0592-11e8-a66e-06ef5e538d28","results":{"response_type":"AP","job_id":"27268346","job_number":"6643724","customer_reference":"91903017","reject_code":"0","tracking_references":[{"tracking_reference":"FF147685310NZ"}]}}';
            }else
            {
                jsonResponseBody= jsonResponse.getBody();
            }
            system.debug('jsonResponseBody=========='+jsonResponseBody);
            JSONParser parser =JSON.createParser(jsonResponseBody);
            string Tracking_references='';
            objResponse.objCourierPostResponse=(TTI_FreightCompanyAPIResponse.CourierPostResponse)JSON.deserialize(jsonResponseBody, TTI_FreightCompanyAPIResponse.CourierPostResponse.class);
            List<TTI_FreightCompanyAPIResponse.cls_tracking_references> lst=objResponse.objCourierPostResponse.results.tracking_references;       
            string trackingRefStr=lst[0].tracking_reference;
            objResponse.Success=true;
            objResponse.Tracking_references=trackingRefStr;  
        }
        else
        {
            objResponse.Success=false;
            objResponse.Error_message =jsonResponse.getBody();  
        }  
    } 
    
    public static void createCourierPostPayload(List<Case> lstCase,List<TTI_CreateAPIPayload> lstPayload){
        for(Case objCase : lstCase)
        {
            TTI_CreateAPIPayload objPayload = new TTI_CreateAPIPayload();
            Freight_Account_Details__c objFreightAccDetails = Freight_Account_Details__c.getValues(objCase.Service_Agent__r.Freight_Company_Account_Number__c);
            objPayload.carrier='COURIERPOST';
            objPayload.caller=objFreightAccDetails.Company_Name__c;
            objPayload.name=objFreightAccDetails.Contact_Name__c;
            objPayload.email=objFreightAccDetails.Contact_Email__c;
            objPayload.phone=objFreightAccDetails.Contact_Phone__c;
            objPayload.customer_reference=objCase.Service_Agent__r.Freight_Company_Account_Number__c;
            objPayload.service_code='CPOLFF';
            objPayload.is_label_required=true;
            objPayload.is_delivery_confirm_required=false;
            objPayload.is_booking_confirm_required=false;
            objPayload.pickup_address.name=objCase.TTI_Customer_Account__r.Name; 
            if(objCase.TTI_Customer_Account__r.PersonMobilePhone!=null){
                objPayload.pickup_address.phone=objCase.TTI_Customer_Account__r.PersonMobilePhone;
            }else{
                objPayload.pickup_address.phone='';
            }
            if(objCase.TTI_Customer_Account__r.PersonEmail!=null){
                objPayload.pickup_address.email=objCase.TTI_Customer_Account__r.PersonEmail;
            }else{
                objPayload.pickup_address.email='';
            }
            if(triggerPointButtonName=='SubmitClaim'){
                objPayload.pickup_address.street=objCase.TTI_Freight_In_PickUp_Address__c;
                objPayload.pickup_address.suburb=objCase.TTI_Freight_In_Pickup_Suburb__c;
                objPayload.pickup_address.postcode=objCase.TTI_Freight_In_Pickup_Postcode__c;
                objPayload.delivery_address.street=objCase.TTI_Freight_In_Delivery_Address__c;
                objPayload.delivery_address.suburb=objCase.TTI_Freight_In_Delivery_Suburb__c;
                objPayload.delivery_address.postcode=objCase.TTI_Freight_In_Delivery_Postcode__c;
            }
            if(triggerPointButtonName=='MarkAsComplete')
            {
                objPayload.pickup_address.street=objCase.TTI_Freight_Out_PickUp_Address__c;
                objPayload.pickup_address.suburb=objCase.TTI_Freight_Out_Pickup_Suburb__c;
                objPayload.pickup_address.postcode=objCase.TTI_Freight_Out_Pickup_Postcode__c;
                objPayload.delivery_address.street=objCase.TTI_Freight_Out_Delivery_Address__c;
                objPayload.delivery_address.suburb=objCase.TTI_Freight_Out_Delivery_Suburb__c;
                objPayload.delivery_address.postcode=objCase.TTI_Freight_Out_Delivery_Postcode__c;
            }
            objPayload.delivery_address.name=objCase.Service_Agent__r.Name;
            objPayload.delivery_address.phone=objCase.Service_Agent__r.Phone;
            objPayload.delivery_address.email='';//objCase.Service_Agent__r.; Ask Vince
            objPayload.delivery_address.company_name=objCase.Service_Agent__r.Name;
            objPayload.delivery_address.instructions='Case Number:'+objCase.CaseNumber;
            Datetime myDateTime=Datetime.now();
            myDateTime=myDateTime.addDays(1);
            if(myDateTime.format('EEEE') =='Saturday')
            {
                myDateTime=myDateTime.addDays(2);
            }
            if(myDateTime.format('EEEE') =='Sunday')
            {
                myDateTime=myDateTime.addDays(1);
            }
            objPayload.pickup_date_time=String.valueOf(myDateTime.date());
            objPayload.parcel_quantity=1;   
            lstPayload.add(objPayload);
        }
    }
    
    private static string createTNTConsignmentWebServicePayload(Case objCase,TTI_Frieght_Company_API_Details__c objFreightCompanyDetails){
        string consignmentNumber;
        if(triggerPointButtonName=='SubmitClaim')
            consignmentNumber=objFreightCompanyDetails.Prefix__c+'1'+objCase.CaseNumber;
        if(triggerPointButtonName=='MarkAsComplete')
            consignmentNumber=objFreightCompanyDetails.Prefix__c+'2'+objCase.CaseNumber;
        String requestBody='<?xml version="1.0" encoding="UTF-8"?>';
        requestBody=requestBody+'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.datacontract.org/2004/07/ConsignmentService" xmlns:con1="http://schemas.datacontract.org/2004/07/ConsignmentLibrary" xmlns:tem="http://tempuri.org/">';
        requestBody=requestBody+'<soapenv:Header />';
        requestBody=requestBody+'<soapenv:Body>';
        requestBody=requestBody+'<tem:ProcessConsignmentRequest>';
        requestBody=requestBody+'<tem:Request>';
        requestBody=requestBody+'<con:UserName>'+objFreightCompanyDetails.TTI_Username__c+'</con:UserName>';
        requestBody=requestBody+'<con:Password>'+objFreightCompanyDetails.TTI_Password__c+'</con:Password>';
        requestBody=requestBody+'<con:ConsignmentProcessList>';
        requestBody=requestBody+'<con:ConsignmentProcess>';
        requestBody=requestBody+'<con:consignment>';
        requestBody=requestBody+'<con1:consignmentNumber>'+consignmentNumber+'</con1:consignmentNumber>';
        requestBody=requestBody+'<con1:payingAccount>'+objCase.Service_Agent__r.Freight_Company_Account_Number__c+'</con1:payingAccount>';
        requestBody=requestBody+'<con1:collection>';
        
        if(triggerPointButtonName=='SubmitClaim'){
            string NameWith20Char1=objCase.TTI_Customer_Account__r.Name;
            if(NameWith20Char1.length() >20)
                NameWith20Char1=NameWith20Char1.substring(0,20);
            requestBody=requestBody+'<con1:Name>'+NameWith20Char1+'</con1:Name>';	
            requestBody=requestBody+'<con1:Address1>'+objCase.TTI_Freight_In_PickUp_Address__c+'</con1:Address1>';
            requestBody=requestBody+'<con1:Suburb>'+objCase.TTI_Freight_In_Pickup_Suburb__c+'</con1:Suburb>';
            requestBody=requestBody+'<con1:State>'+objCase.TTI_Freight_In_Pickup_State__c+'</con1:State>';
            requestBody=requestBody+'<con1:Postcode>'+objCase.TTI_Freight_In_Pickup_Postcode__c+'</con1:Postcode>';
            requestBody=requestBody+'<con1:ContactName>'+NameWith20Char1+'</con1:ContactName>';
            requestBody=requestBody+'<con1:Phone>'+objCase.TTI_Customer_Account__r.PersonMobilePhone+'</con1:Phone>';
        }
        
        if(triggerPointButtonName=='MarkAsComplete'){
            string NameWith20Char1=objCase.Service_Agent__r.Name;
            if(NameWith20Char1.length() >20)
                NameWith20Char1=NameWith20Char1.substring(0,20);
            requestBody=requestBody+'<con1:Name>'+NameWith20Char1+'</con1:Name>';	
            requestBody=requestBody+'<con1:Address1>'+objCase.TTI_Freight_Out_PickUp_Address__c+'</con1:Address1>';
            requestBody=requestBody+'<con1:Suburb>'+objCase.TTI_Freight_Out_Pickup_Suburb__c+'</con1:Suburb>';
            requestBody=requestBody+'<con1:State>'+objCase.TTI_Freight_Out_Pickup_State__c+'</con1:State>';
            requestBody=requestBody+'<con1:Postcode>'+objCase.TTI_Freight_Out_Pickup_Postcode__c+'</con1:Postcode>';
            requestBody=requestBody+'<con1:ContactName>'+NameWith20Char1+'</con1:ContactName>';
            requestBody=requestBody+'<con1:Phone>'+objCase.Service_Agent__r.Phone+'</con1:Phone>';
        }
        
        requestBody=requestBody+'</con1:collection>';
        requestBody=requestBody+'<con1:delivery>';
        if(triggerPointButtonName=='SubmitClaim')
        {
            string tempName=objCase.Service_Agent__r.Name;
            if(tempName.length() > 20)
            {
                tempName=tempName.substring(0, 20);
            }
            requestBody=requestBody+'<con1:Name>'+tempName+'</con1:Name>';
            requestBody=requestBody+'<con1:Address1>'+objCase.TTI_Freight_In_Delivery_Address__c+'</con1:Address1>';
            requestBody=requestBody+'<con1:Suburb>'+objCase.TTI_Freight_In_Delivery_Suburb__c+'</con1:Suburb>';
            requestBody=requestBody+'<con1:State>'+objCase.TTI_Freight_In_Delivery_State__c+'</con1:State>';
            requestBody=requestBody+'<con1:Postcode>'+objCase.TTI_Freight_In_Delivery_Postcode__c+'</con1:Postcode>';
            requestBody=requestBody+'<con1:ContactName>'+tempName+'</con1:ContactName>';
            requestBody=requestBody+'<con1:Phone>+'+objCase.Service_Agent__r.Phone+'</con1:Phone>';
            
        }
        if(triggerPointButtonName=='MarkAsComplete')
        {
            string NameWith20Char;
            if(objCase.Retailer_Account__c!=null)
                NameWith20Char=objCase.Retailer_Account__r.Name;
            else
                NameWith20Char=objCase.TTI_Customer_Account__r.Name;
            if(NameWith20Char.length() > 20)
            {
                NameWith20Char=NameWith20Char.substring(0, 20);
            }
            system.debug(NameWith20Char);
            requestBody=requestBody+'<con1:Name>'+NameWith20Char+'</con1:Name>';
            requestBody=requestBody+'<con1:Address1>'+objCase.TTI_Freight_Out_Delivery_Address__c+'</con1:Address1>';
            requestBody=requestBody+'<con1:Suburb>'+objCase.TTI_Freight_Out_Delivery_Suburb__c+'</con1:Suburb>';
            requestBody=requestBody+'<con1:State>'+objCase.TTI_Freight_Out_Delivery_State__c+'</con1:State>';
            requestBody=requestBody+'<con1:Postcode>'+objCase.TTI_Freight_Out_Delivery_Postcode__c+'</con1:Postcode>';
            if(objCase.Retailer_Account__c!=null)
            {
                string contactNameWith20Char=objCase.Retailer_Account__r.Name;
                if(contactNameWith20Char.length() >20)
                    contactNameWith20Char=contactNameWith20Char.substring(0,20);
                requestBody=requestBody+'<con1:ContactName>'+contactNameWith20Char+'</con1:ContactName>';
                requestBody=requestBody+'<con1:Phone>'+objCase.Retailer_Account__r.Phone+'</con1:Phone>';
            }
            else
            {
                string contactNameWith20Char=objCase.TTI_Customer_Account__r.Name;
                if(contactNameWith20Char.length() >20)
                    contactNameWith20Char=contactNameWith20Char.substring(0,20);
                requestBody=requestBody+'<con1:ContactName>'+contactNameWith20Char+'</con1:ContactName>';
                requestBody=requestBody+'<con1:Phone>'+objCase.TTI_Customer_Account__r.PersonMobilePhone+'</con1:Phone>';
            }
        }
        Date d=Date.today();
        d=d.addDays(1);
        string dd;
        if(d.day()<10)
        {
            dd='0'+string.valueOf(d.day());
        }
        else{
            dd=string.valueOf(d.day());
        }
        string mm;
        if(d.month()<10)
        {
            mm='0'+string.valueOf(d.month());
        }
        else{
            mm=string.valueOf(d.month());
        }
        string yy=string.valueOf(d.year());
        requestBody=requestBody+'</con1:delivery>';
        requestBody=requestBody+'<con1:consignmentDate>'+dd+mm+yy+'</con1:consignmentDate>';
        requestBody=requestBody+'<con1:serviceCode>76</con1:serviceCode>';
        requestBody=requestBody+'<con1:dangerousGoodsIndicator>N</con1:dangerousGoodsIndicator>';
        requestBody=requestBody+'<con1:payer>S</con1:payer>';
        requestBody=requestBody+'<con1:foodIndicator>N</con1:foodIndicator>';
        requestBody=requestBody+'<con1:cancelIndicator>N</con1:cancelIndicator>';
        requestBody=requestBody+'<con1:customerConsignmentRef>'+objCase.CaseNumber+'</con1:customerConsignmentRef>';
        requestBody=requestBody+'<con1:consignmentFinaliseIndicator>Y</con1:consignmentFinaliseIndicator>';
        requestBody=requestBody+'<con1:consignmentSpecialInstructionList>';
        requestBody=requestBody+'<con1:ConsignmentSpecialInstruction>';
        if(triggerPointButtonName=='SubmitClaim')
            requestBody=requestBody+'<con1:textType>DELIVERY</con1:textType>';
        if(triggerPointButtonName=='MarkAsComplete')
            requestBody=requestBody+'<con1:textType>UNSPECIFIED</con1:textType>';
        requestBody=requestBody+'<con1:textLine>Case Number:'+objCase.CaseNumber+'</con1:textLine>';
        requestBody=requestBody+'</con1:ConsignmentSpecialInstruction>';
        requestBody=requestBody+'</con1:consignmentSpecialInstructionList>';
        requestBody=requestBody+'<con1:packageLineList>';
        requestBody=requestBody+'<con1:PackageLine>';
        requestBody=requestBody+'<con1:lineSequence>1</con1:lineSequence>';
        requestBody=requestBody+'<con1:descriptionOfGoods>'+objCase.Product_Name__r.ProductCode+'</con1:descriptionOfGoods>';
        
        decimal totalWeight=objCase.Product_Name__r.Weight__c;
        decimal height=(objCase.Product_Name__r.Height__c/10.00);
        decimal width=(objCase.Product_Name__r.Width__c/10.00);
        decimal length=(objCase.Product_Name__r.Length__c/10.00);
        height=height.round(System.RoundingMode.HALF_EVEN);
        width=width.round(System.RoundingMode.HALF_EVEN);
        length=length.round(System.RoundingMode.HALF_EVEN);
        
        requestBody=requestBody+'<con1:itemQuantity>1</con1:itemQuantity>';
        requestBody=requestBody+'<con1:lineWeight>'+totalWeight+'</con1:lineWeight>';
        requestBody=requestBody+'<con1:weightMeasureUnit>KG</con1:weightMeasureUnit>';
        requestBody=requestBody+'<con1:itemLength>'+length+'</con1:itemLength>';
        requestBody=requestBody+'<con1:itemWidth>'+width+'</con1:itemWidth>';
        requestBody=requestBody+'<con1:itemHeight>'+height+'</con1:itemHeight>';
        requestBody=requestBody+'<con1:dimensionMeasureUnit>CM</con1:dimensionMeasureUnit>';
        requestBody=requestBody+'<con1:lineVolume>0</con1:lineVolume>';
        requestBody=requestBody+'<con1:volumeMeasureUnit>CC</con1:volumeMeasureUnit>';
        requestBody=requestBody+'</con1:PackageLine>';
        requestBody=requestBody+'</con1:packageLineList>';
        requestBody=requestBody+'</con:consignment>';
        requestBody=requestBody+'<con:consignmentActionList>';
        requestBody=requestBody+'<con1:ConsignmentActionType>SUBMIT</con1:ConsignmentActionType>';
        requestBody=requestBody+'</con:consignmentActionList>';
        requestBody=requestBody+'<con:senderCode>'+objFreightCompanyDetails.Sender_Code__c+'</con:senderCode>';
        requestBody=requestBody+'<con:labelType>UNSPECIFIED</con:labelType>';
        requestBody=requestBody+'</con:ConsignmentProcess>';
        requestBody=requestBody+'</con:ConsignmentProcessList>';
        requestBody=requestBody+'</tem:Request>';
        requestBody=requestBody+'</tem:ProcessConsignmentRequest>';
        requestBody=requestBody+'</soapenv:Body>';
        requestBody=requestBody+'</soapenv:Envelope>';
        
        return requestBody;
    }
    private static string createTNTBookingWebServicePayload(Case objCase,TTI_Frieght_Company_API_Details__c objFreightCompanyDetails)
    {
        string consignmentNumber;
        if(triggerPointButtonName=='SubmitClaim')
            consignmentNumber=objFreightCompanyDetails.Prefix__c+'1'+objCase.CaseNumber;
        if(triggerPointButtonName=='MarkAsComplete')
            consignmentNumber=objFreightCompanyDetails.Prefix__c+'2'+objCase.CaseNumber;
        
        Freight_Account_Details__c objFreightAccDetails = Freight_Account_Details__c.getValues(objCase.Service_Agent__r.Freight_Company_Account_Number__c);
        String requestBody = '<?xml version=\"1.0\" encoding=\"utf-8\"?>';
        requestBody  +='<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">';
        requestBody   +='<soap:Body> <SubmitBookingRequest xmlns=\"http://tempuri.org/\">';
        requestBody   +='<userName>'+objFreightCompanyDetails.TTI_Username__c+'</userName>';
        requestBody +='<password>'+objFreightCompanyDetails.TTI_Password__c+'</password>';
        requestBody +='<booking>';
        
        requestBody +='<SenderAccount xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">';
        requestBody += objFreightAccDetails.Name+'</SenderAccount>';
        
        requestBody +='<SenderDetails xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">';
        requestBody +='<CompanyName>'+objFreightAccDetails.Company_Name__c+'</CompanyName>';
        requestBody +='<ContactName>'+objFreightAccDetails.Contact_Name__c +'</ContactName>';
        requestBody +='<ContactPhoneAreaCode>03</ContactPhoneAreaCode>';
        requestBody +='<ContactPhoneNumber>'+objFreightAccDetails.Contact_Phone__c+'</ContactPhoneNumber>';
        requestBody +='<AddressLine1>'+objFreightAccDetails.Street_Address__c+'</AddressLine1>';
        requestBody +=' <AddressLine2 xsi:nil="true" />';
        requestBody +='<Suburb>'+objFreightAccDetails.City__c+'</Suburb>';
        requestBody +='<State>'+objFreightAccDetails.Province__c+'</State>';
        requestBody +='<Postcode>'+objFreightAccDetails.Postcode__c+'</Postcode>';
        requestBody +='</SenderDetails>';
        
        requestBody +=' <CollectionDetails xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">';
        requestBody +='<CompanyName>'+objFreightAccDetails.Company_Name__c+'</CompanyName>';
        requestBody +='<ContactName>'+objCase.TTI_Customer_Account__r.Name+'</ContactName>';
        requestBody +='<ContactPhoneAreaCode>03</ContactPhoneAreaCode>';
        requestBody +='<ContactPhoneNumber>'+objCase.TTI_Customer_Account__r.PersonMobilePhone+'</ContactPhoneNumber>';
        if(triggerPointButtonName=='SubmitClaim'){
            requestBody +='<AddressLine1>'+objCase.TTI_Freight_In_PickUp_Address__c+'</AddressLine1>';
            requestBody +=' <AddressLine2 xsi:nil="true" />';
            requestBody +='<Suburb>'+objCase.TTI_Freight_In_Pickup_Suburb__c+'</Suburb>';
            requestBody +='<State>'+objCase.TTI_Freight_In_Pickup_State__c+'</State>';
            requestBody +='<Postcode>'+objCase.TTI_Freight_In_Pickup_Postcode__c+'</Postcode>';
        }
        else
        {
            requestBody +='<AddressLine1>'+objCase.TTI_Freight_Out_PickUp_Address__c+'</AddressLine1>';
            requestBody +=' <AddressLine2 xsi:nil="true" />';
            requestBody +='<Suburb>'+objCase.TTI_Freight_Out_Pickup_Suburb__c+'</Suburb>';
            requestBody +='<State>'+objCase.TTI_Freight_Out_Pickup_State__c+'</State>';
            requestBody +='<Postcode>'+objCase.TTI_Freight_Out_Pickup_Postcode__c+'</Postcode>';
        }
        requestBody +='</CollectionDetails>';
        
        requestBody +=' <ReceiverDetails xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">';
        if(triggerPointButtonName=='SubmitClaim'){
            requestBody +='<CompanyName>'+objCase.Service_Agent__r.Name+'</CompanyName>';
        }
        if(triggerPointButtonName=='MarkAsComplete'){
            requestBody +='<CompanyName>'+objFreightAccDetails.Company_Name__c+'</CompanyName>';
        }
        requestBody +='<ContactName>'+objCase.Service_Agent__r.Name+'</ContactName>';
        requestBody +='<ContactPhoneAreaCode>03</ContactPhoneAreaCode>';
        requestBody +='<ContactPhoneNumber>'+objCase.Service_Agent__r.Phone+'</ContactPhoneNumber>';
        if(triggerPointButtonName=='SubmitClaim')
        {
            requestBody +='<AddressLine1>'+objCase.TTI_Freight_In_Delivery_Address__c+'</AddressLine1>';
            requestBody +=' <AddressLine2 xsi:nil="true" />';
            requestBody +='<Suburb>'+objCase.TTI_Freight_In_Delivery_Suburb__c+'</Suburb>';
            requestBody +='<State>'+objCase.TTI_Freight_In_Delivery_State__c+'</State>';
            requestBody +='<Postcode>'+objCase.TTI_Freight_In_Delivery_Postcode__c+'</Postcode>';
        }
        if(triggerPointButtonName=='MarkAsComplete'){
            requestBody +='<AddressLine1>'+objCase.TTI_Freight_Out_Delivery_Address__c +'</AddressLine1>';
            requestBody +=' <AddressLine2 xsi:nil="true" />';
            requestBody +='<Suburb>'+objCase.TTI_Freight_Out_Delivery_Suburb__c +'</Suburb>';
            requestBody +='<State>'+objCase.TTI_Freight_Out_Delivery_State__c +'</State>';
            requestBody +='<Postcode>'+objCase.TTI_Freight_Out_Delivery_Postcode__c +'</Postcode>';
        }
        
        requestBody +='</ReceiverDetails>';
        decimal totalWeight=objCase.Product_Name__r.Weight__c;
        decimal height=(objCase.Product_Name__r.Height__c/10.00);
        decimal width=(objCase.Product_Name__r.Width__c/10.00);
        decimal length=(objCase.Product_Name__r.Length__c/10.00);
        height=height.round(System.RoundingMode.HALF_EVEN);
        width=width.round(System.RoundingMode.HALF_EVEN);
        length=length.round(System.RoundingMode.HALF_EVEN);
        requestBody +='<ItemCount xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">1</ItemCount>';
        requestBody +='<TotalWeight xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">'+totalWeight+'</TotalWeight>';
        requestBody +='<MaxLength xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">'+length+'</MaxLength>';
        requestBody +='<MaxWidth xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">'+width+'</MaxWidth>';
        requestBody +='<MaxHeight xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">'+height+'</MaxHeight>';
        requestBody +='<PackagingCode xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">BX</PackagingCode>';
        Datetime d=Datetime.now();
        d=d.addDays(1);
        if(d.format('EEEE') =='Saturday')
        {
            d=d.addDays(2);
        }
        if(d.format('EEEE') =='Sunday')
        {
            d=d.addDays(1);
        }
        requestBody +='<CollectionDateTime xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">'+String.valueOf(d.date())+'</CollectionDateTime>';
        requestBody +='<CollectionCloseTime xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">1600</CollectionCloseTime>';
        requestBody +='<ServiceCode xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">76</ServiceCode>';
        requestBody +=' <IsDangerousGoods xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">false</IsDangerousGoods>';
        requestBody +='<Payer xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">Sender</Payer>';
        requestBody +='<ReceiverAccount xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\"></ReceiverAccount>';
        requestBody +='<Specialinstructions xsi:nil="true" xmlns="http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking" />';
        requestBody +='<CustomerReference xmlns=\"http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking\">Case No:'+objCase.CaseNumber+'</CustomerReference>';
        requestBody +='<DangerousGoodsUN xsi:nil="true" xmlns="http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking" />';
        requestBody +='<DangerousGoodsPackingGroup xsi:nil="true" xmlns="http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking" />';
        requestBody +=' <ConsignmentNoteNumber xmlns="http://schemas.datacontract.org/2004/07/TNT.DataContracts.Booking">'+consignmentNumber+'</ConsignmentNoteNumber>';
        requestBody +='</booking>';
        requestBody +='</SubmitBookingRequest>';
        requestBody +=' </soap:Body> </soap:Envelope>';
        return requestBody;
    }
    
}