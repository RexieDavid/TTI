/**
 * @File Name          : SpShippingAndTrackingAup.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 29/08/2019, 9:25:57 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author           Modification
 *==============================================================================
 * 1.0    18/07/2019, 7:21:34 am   Francis Nasalita     Initial Version
**/
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public class SpShippingAndTrackingAup implements SpShippingAndTrackingInterface {

    private static String removeNonAlphanumeric(String text) {
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(text);
        return matcher.replaceAll('');
    }

    private static Map<String, Service_Portal_Integration_Configuration__mdt> configActionMap;

    static {
        Boolean inProduction = ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        configActionMap = new Map<String, Service_Portal_Integration_Configuration__mdt>();
        for (Service_Portal_Integration_Configuration__mdt c : [SELECT Action__c,
                                                                        Username__c,
                                                                        Secret__c,
                                                                        Endpoint_Full_URL__c
                                                                    FROM Service_Portal_Integration_Configuration__mdt
                                                                    WHERE Is_Production__c = :inProduction
                                                                    AND Freight_Forwarder__c = 'Australia_Post']) {
            configActionMap.put(c.Action__c, c);
        }

        // uncomment after the deployment
        // if (configActionMap.isEmpty()) {
        //     throw new SpShippingAndTrackingAupException('There is a problem with your integration configuration. Kindly contact your administrator for assistance.');
        // }
    }

    public static Blob getOrder(String accountNumber, String orderId) {
        return execGetOrder(accountNumber, orderId);
    }

    public static Blob getDangerousGoodsForm(String accountNumber, String shipmentId) {
        return execgetDGForm(accountNumber, shipmentId);
    }
    
    public static SpShipment updateShipment(String accountNumber, String shipmentId, String jsonRequest) {
        return execUpdateShipmentCall(accountNumber, shipmentId, jsonRequest);
    }

    public static SpShipment updateShipment(String accountNumber, String shipmentId, SpUpdateShipmentReqDtoAup reqDto) {
        Map<String, Object> tmp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqDto));
        SpShippingAndTrackingAup.fixShipmentCreationReqJsonKeys(tmp);
        return execUpdateShipmentCall(accountNumber, shipmentId, JSON.serialize(tmp));
    }

    public static String deleteShipment(String accountNumber, String shipmentId) {
        return execDeleteShipmentCall(accountNumber, shipmentId);   
    }

    public static String getShipment(String accountNumber, String shipmentId) {
        return execGetShipmentCall(accountNumber, shipmentId);
    }
    
    public static String createOrder(String accountNumber, SpCreateOrderReqDtoAup reqDto) {
        Map<String, Object> tmp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqDto));
        return execCreateOrderCall(accountNumber, JSON.serialize(tmp));
    }
    
    public static List<SpShipment> createShipments(String accountNumber, String jsonRequest) {
        return execCreateShipmentsCall(accountNumber, jsonRequest);
    }

    public static List<SpShipment> createShipments(String accountNumber, SpCreateShipmentReqDtoAup reqDto) {
        Map<String, Object> tmp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqDto));
        SpShippingAndTrackingAup.fixShipmentCreationReqJsonKeys(tmp);

        return execCreateShipmentsCall(accountNumber, JSON.serialize(tmp));
    }

    public static List<SpLabel> createLabels(String accountNumber, String jsonRequest) {
        return execCreateLabelsCall(accountNumber, jsonRequest);
    }

    public static List<SpLabel> createLabels(String accountNumber, SpCreateLabelReqDtoAup reqDto) {
        Map<String, Object> tmp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(reqDto));
        SpShippingAndTrackingAup.fixLabelCreationReqJsonKeys(tmp);
        
        return execCreateLabelsCall(accountNumber, JSON.serialize(tmp));
    }

    public static String createAdhocPickup(String accountNumber, SpCreateAdhocPickupReqDto reqDto) {
        Map<String, Object> tmp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqDto));
        SpShippingAndTrackingAup.fixAdhocPickupCreationReqJsonKeys(tmp);

        return execCreateAdhocPickupCall(accountNumber, JSON.serialize(tmp));
    }

    public static SpLabel getLabel(String accountNumber, String requestId) {
        return execGetLabelCall(accountNumber, requestId);
    }

    public static void fixShipmentCreationReqJsonKeys(Map<String, Object> req) {
        if (req.containsKey('shipments')) {
            for (Object o : (List<Object>)req.get('shipments')) {
                Map<String, Object> obj = (Map<String, Object>)o;
                if (obj.containsKey('source')) {
                    obj.put('from', obj.get('source'));
                    obj.remove('source');
                }
                if (obj.containsKey('destination')) {
                    obj.put('to', obj.get('destination'));
                    obj.remove('destination');
                }
            } 
        } else {
            Map<String, Object> obj = (Map<String, Object>) req;
            if (obj.containsKey('source')) {
                obj.put('from', obj.get('source'));
                obj.remove('source');
            }
            if (obj.containsKey('destination')) {
                obj.put('to', obj.get('destination'));
                obj.remove('destination');
            }
        }
    }

    public static void fixLabelCreationReqJsonKeys(Map<String, Object> req) {
        for (Object o : (List<Object>)req.get('preferences')) {
            Map<String, Object> obj = (Map<String, Object>)o;
            if (obj.containsKey('preference_type')) {
                obj.put('type', obj.get('preference_type'));
                obj.remove('preference_type');
            }

            for (Object g : (List<Object>)obj.get('groups')) {
                Map<String, Object> innerObj = (Map<String, Object>)g;
                if (innerObj.containsKey('group_name')) {
                    innerObj.put('group', innerObj.get('group_name'));
                    innerObj.remove('group_name');
                }
            }
        }
    }

    public static void fixAdhocPickupCreationReqJsonKeys(Map<String, Object> req) {
        if (req.containsKey('adhoc_pickup')) {
            Map<String, Object> obj = (Map<String, Object>) req.get('adhoc_pickup');
            if (obj.containsKey('source')) {
                obj.put('from', obj.get('source'));
                obj.remove('source');
            }
        }
    }

    @TestVisible
    private static Blob execGetOrder(String accountNumber, String orderId) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('GET_ORDER');
        String endpoint = config.Endpoint_Full_URL__c.replace('<account_number>', accountNumber).replace('<order_id>', orderId);

        HttpResponse response = execCallout(accountNumber, '', config.Username__c, config.Secret__c, endpoint, 'GET');        
        Integer statusCode = response.getStatusCode();

        Blob pdf;
        if (statusCode == 200) {
            pdf = response.getBodyAsBlob();
        } else {
            handleErrorResponse(response, statusCode);
        }

        return pdf;
    }

    @TestVisible
    private static Blob execgetDGForm(String accountNumber, String shipmentId) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('GET_DG_FORM');
        String endpoint = config.Endpoint_Full_URL__c.replace('<shipment_id>', shipmentId);

        HttpResponse response = execCallout(accountNumber, '', config.Username__c, config.Secret__c, endpoint, 'GET');
        Integer statusCode = response.getStatusCode();

        Blob pdf;
        if (statusCode == 200) {
            pdf = response.getBodyAsBlob();
        } else {
            handleErrorResponse(response, statusCode);
        }

        return pdf;
    }

    @TestVisible
    private static SpLabel execGetLabelCall(String accountNumber, String requestId) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('GET_LABEL');
        String endpoint = config.Endpoint_Full_URL__c + (config.Endpoint_Full_URL__c.right(1).equals('/') ? '' : '/') + requestId;

        HttpResponse response = execCallout(accountNumber, '', config.Username__c, config.Secret__c, endpoint, 'GET');
        Integer statusCode = response.getStatusCode();

        SpLabel label;
        if (statusCode == 200) {
            SpGetLabelResDtoAup spGlblRes = SpGetLabelResDtoAup.parse(response.getBody());
            label = spGlblRes.labels.get(0);
        } else {
            handleErrorResponse(response, statusCode);
        }

        return label;
    }

    @TestVisible
    private static List<SpLabel> execCreateLabelsCall(String accountNumber, String jsonRequest) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('CREATE_LABEL');
        
        HttpResponse response = execCallout(accountNumber, jsonRequest, config.Username__c, config.Secret__c, config.Endpoint_Full_URL__c, 'POST');
        Integer statusCode = response.getStatusCode();

        List<SpLabel> labels;
        if (statusCode == 200) {
            SpCreateLabelResDtoAup spClblRes = SpCreateLabelResDtoAup.parse(response.getBody());
            labels = spClblRes.labels;
        } else {
            handleErrorResponse(response, statusCode);
        }

        return labels;
    }

    @TestVisible
    private static List<SpShipment> execCreateShipmentsCall(String accountNumber, String jsonRequest) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('CREATE_SHIPMENT');
        
        HttpResponse response = execCallout(accountNumber, jsonRequest, config.Username__c, config.Secret__c, config.Endpoint_Full_URL__c, 'POST');
        Integer statusCode = response.getStatusCode();

        List<SpShipment> shipments;
        if (statusCode == 201) {
            SpCreateShipmentResDtoAup spRes = SpCreateShipmentResDtoAup.parse(response.getBody());

            shipments = (List<SpShipment>) spRes.shipments;
        } else {
            handleErrorResponse(response, statusCode);
        }
        
        return shipments;
    }

    @TestVisible
    private static String execCreateOrderCall(String accountNumber, String jsonRequest) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('CREATE_ORDER');
        
        HttpResponse response = execCallout(accountNumber, jsonRequest, config.Username__c, config.Secret__c, config.Endpoint_Full_URL__c, 'PUT');
        Integer statusCode = response.getStatusCode();

        String jsonOrder;
        if (statusCode == 201) {
            SpCreateOrderResDtoAup spRes = SpCreateOrderResDtoAup.parse(response.getBody());
            jsonOrder = JSON.serialize(spRes);
        } else {
            handleErrorResponse(response, statusCode);
        }

        return jsonOrder;
    }

    @TestVisible
    private static String execCreateAdhocPickupCall(String accountNumber, String jsonRequest) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('CREATE_ADHOC_PICKUP');
        
        HttpResponse response = execCallout(accountNumber, jsonRequest, config.Username__c, config.Secret__c, config.Endpoint_Full_URL__c, 'POST');
        Integer statusCode = response.getStatusCode();

        String jsonAdhocPickup;
        if (statusCode == 201) {
            SpCreateAdhocPickupResDtoAup spRes = SpCreateAdhocPickupResDtoAup.parse(response.getBody());
            jsonAdhocPickup = JSON.serialize(spRes);
        } else {
            handleErrorResponse(response, statusCode);
        }

        return jsonAdhocPickup;
    }

    @TestVisible
    private static String execGetShipmentCall(String accountNumber, String shipmentId) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('GET_SHIPMENT');
        String endpoint = config.Endpoint_Full_URL__c.replace('<shipment_id>', shipmentId);
        
        HttpResponse response = execCallout(accountNumber, '', config.Username__c, config.Secret__c, endpoint, 'GET');
        Integer statusCode = response.getStatusCode();

        String jsonShipment;
        if (statusCode == 200) {
            SPGetShipmentResDtoAup spRes = SPGetShipmentResDtoAup.parse(response.getBody());
            jsonShipment = JSON.serialize(spRes);
        } else {
            handleErrorResponse(response, statusCode);
        }

        return jsonShipment;
    }

    @TestVisible
    private static String execDeleteShipmentCall(String accountNumber, String shipmentId) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('DELETE_SHIPMENT');
        String endpoint = config.Endpoint_Full_URL__c.replace('<shipment_id>', shipmentId);

        HttpResponse response = execCallout(accountNumber, '', config.Username__c, config.Secret__c, endpoint, 'DELETE');
        Integer statusCode = response.getStatusCode();

        if (statusCode != 200) {
            handleErrorResponse(response, statusCode);
        }

        return shipmentId;
    }

    @TestVisible
    private static SpShipment execUpdateShipmentCall(String accountNumber, String shipmentId, String jsonRequest) {
        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('UPDATE_SHIPMENT');
        String endpoint = config.Endpoint_Full_URL__c.replace('<shipment_id>', shipmentId);

        HttpResponse response = execCallout(accountNumber, jsonRequest, config.Username__c, config.Secret__c, endpoint, 'PUT');
        Integer statusCode = response.getStatusCode();

        SpShipment shipment;
        if (statusCode == 201) {
            SpCreateShipmentResDtoAup.Shipment spRes = SpCreateShipmentResDtoAup.parseShipment(response.getBody());
            shipment = (SpShipment) spRes;
        } else {
            handleErrorResponse(response, statusCode);
        }

        return shipment;
    }

    @TestVisible
    private static HttpResponse execCallout(String accountNumber, String jsonRequest, String username, String secret, String endpoint, String webMethod) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(webMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Account-Number', accountNumber);
        request.setHeader('Authorization', 'Basic ' + generateEncodedAuthKey(username, secret));
        request.setTimeout(20000);

        if (String.isNotBlank(jsonRequest)) {
            request.setBody(jsonRequest);
        }        
        HttpResponse response = http.send(request);


        return response;
    }

    @TestVisible
    private static String generateEncodedAuthKey(String username, String secret) {
        return EncodingUtil.base64Encode(Blob.valueOf(username + ':' + secret));
    }

    public class SpShippingAndTrackingAupException extends Exception {
        
        public List<SpErrorResDtoAup.Errors> errors;
        public Integer statusCode;
        
        public SpShippingAndTrackingAupException(String errMsg, Integer code, List<SpErrorResDtoAup.Errors> listError) {
            this.setMessage(errMsg);
            this.statusCode = code;
            
            if (!listError.isEmpty()) {
                this.errors = listError;
                
                for (SpErrorResDtoAup.Errors err :this.errors) {
                    err.name = generateTitle(err.name);
                    err.message = err.message.removeStart('(').removeEnd(')');
                }
            }
        }
    }

    private static String generateTitle(String title) {
        String newTitle = '';
        Boolean flag = true;

        for (String text :title.split('_')) {
            if (flag) {
                newTitle += text.toLowerCase().capitalize();
                flag = false;
            } else {
                newTitle += ' ' + text.toLowerCase().capitalize();
            }            
        }

        return newTitle;
    }

    private static String getValidPhoneNumber(String phone) {
        if (String.isNotBlank(phone) && Pattern.matches(Label.UTIL_REGEX_ANZ_Phone_Format, phone)) {
            return phone.replaceFirst('\\+(61|64)', '0');
        } else if (String.isNotBlank(phone) && Pattern.matches(Label.SP_REGEX_ANZ_RetailerPhone_Format, phone)) {
            return phone.replaceFirst('\\+(61|64)', '0');
        }
        return '';
    }

    private static String getValidProductDimension(Decimal actualDimension, String altDimension) {
        if(actualDimension != null) {
            return String.valueOf(Math.round(Integer.valueOf(actualDimension) / 10));
        } else {
            return altDimension != null ? String.valueOf(Math.round(Integer.valueOf(altDimension) / 10)) : altDimension;
        }
    }

    private static String getValidProductDimension(Decimal actualWeight, String altWeight, String minWeight) {
        if (String.isBlank(String.valueOf(actualWeight))) {
            return altWeight;
        } else if (Double.valueOf(actualWeight) < 1) {
            return minWeight;
        } else {
            return String.valueOf(Math.round(Integer.valueOf(actualWeight)));
        }
    }

    public static SpCreateShipmentReqDtoAup createShipmentReqDto(Case caseRec, Service_Portal_Freight_Configuration__mdt config) {
        String height = getValidProductDimension(caseRec.Product_Name__r.Height__c, config.Product_Default_Height__c);
        String length = getValidProductDimension(caseRec.Product_Name__r.Length__c, config.Product_Default_Length__c);
        String width = getValidProductDimension(caseRec.Product_Name__r.Width__c, config.Product_Default_Width__c);
        String weight = getValidProductDimension(caseRec.Product_Name__r.Weight__c, config.Product_Default_Weight__c, config.Product_Minimum_Weight__c);

        SpCreateShipmentReqDtoAup reqDto = new SpCreateShipmentReqDtoAup();

        SpCreateShipmentReqDtoAup.Shipments shipment = new SpCreateShipmentReqDtoAup.Shipments();
        shipment.consolidate = false;
        shipment.movement_type = 'TRANSFER';
        shipment.customer_reference_1 = caseRec.CaseNumber;
        shipment.customer_reference_2 = caseRec.TTI_Service_Agent_Job_Number__c;
        shipment.email_tracking_enabled = String.IsNotBlank(caseRec.SuppliedEmail);
        shipment.shipment_reference = 'TTI_CASE_' + caseRec.CaseNumber;

        SpCreateShipmentReqDtoAup.Source source = new SpCreateShipmentReqDtoAup.Source();

        if (String.isNotBlank(caseRec.Contact.Email)) {
            source.email = caseRec.Contact.Email;
        }
        
        String phone = caseRec.Service_Agent__r.Internal_Service_Agent__c && caseRec.TTI_Freight_Out_Delivery_Country__c == 'Australia' ?
            Label.SP_TTI_General_Customer_Service_Line : getValidPhoneNumber(caseRec.Contact.Phone);
            
        source.phone = phone;
        source.name = caseRec.Service_Agent__r.Name;
        source.postcode = caseRec.TTI_Freight_Out_Pickup_Postcode__c;
        source.state = caseRec.TTI_Freight_Out_Pickup_State__c;
        source.suburb = caseRec.TTI_Freight_Out_Pickup_Suburb__c;
        source.lines = new List<String>{ caseRec.TTI_Freight_Out_PickUp_Address__c };
        shipment.source = source;

        SpCreateShipmentReqDtoAup.Destination destination = new SpCreateShipmentReqDtoAup.Destination();

        if (String.isNotBlank(caseRec.SuppliedEmail)) {
            destination.email = caseRec.SuppliedEmail;
        }

        destination.phone = getValidPhoneNumber(caseRec.SuppliedPhone);
        destination.name = caseRec.FreightOutDeliverTo__c;
        destination.postcode = caseRec.TTI_Freight_Out_Delivery_Postcode__c;
        destination.state = caseRec.TTI_Freight_Out_Delivery_State__c;
        destination.suburb = caseRec.TTI_Freight_Out_Delivery_Suburb__c;
        destination.lines = new List<String>{ caseRec.TTI_Freight_Out_Delivery_Address__c };
        shipment.destination = destination;

        SpCreateShipmentReqDtoAup.Items item = new SpCreateShipmentReqDtoAup.Items();
        item.allow_partial_delivery = false;
        item.authority_to_leave = false;
        item.height = height;
        item.item_reference = caseRec.Product_Name__r.SAP_MaterialNumber__c;
        item.length = length;
        item.packaging_type = 'ITM';
        item.product_id = 'EXP';
        item.weight = weight;
        item.width = width;

        if (String.isNotBlank(caseRec.Product_Name__r.Dangerous_Goods_Text__c)) {
            SpCreateShipmentReqDtoAup.Dangerous_goods dangerousGoods = new SpCreateShipmentReqDtoAup.Dangerous_goods();
            item.contains_dangerous_goods = true;
            item.product_id = 'EXP';

            dangerousGoods.un_number = Label.SP_Dangerous_Goods_Code;
            dangerousGoods.technical_name = 'Lithium Metal Batteries';
            dangerousGoods.net_weight = weight;
            dangerousGoods.class_division = '9';
            dangerousGoods.outer_packaging_type = 'BOX';
            dangerousGoods.outer_packaging_quantity = '1';

            shipment.dangerous_goods = dangerousGoods;
        }

        shipment.items = new List<SpCreateShipmentReqDtoAup.Items>{ item };

        reqDto.shipments = new List<SpCreateShipmentReqDtoAup.Shipments>{ shipment };

        return reqDto;
    }

    public static SpCreateLabelReqDtoAup createLabelReqDto(String shipmentId, String format) {

        SpCreateLabelReqDtoAup label = new SpCreateLabelReqDtoAup();
        label.preferences = new List<SpCreateLabelReqDtoAup.Preference>{
            new SpCreateLabelReqDtoAup.Preference('PRINT', format,
                new List<SpCreateLabelReqDtoAup.LabelGroup>{
                    new SpCreateLabelReqDtoAup.LabelGroup('Startrack', 'A6-1pp', true, 0, 0)
                }
            )
        };

        label.shipments = new List<SpCreateLabelReqDtoAup.Shipment>();
        label.shipments.add(new SpCreateLabelReqDtoAup.Shipment(shipmentId));

        return label;
    }

    public static SpCreateAdhocPickupReqDtoAup createAdhocPickupReqDto(SPGetShipmentResDtoAup resShipments, List<Case> caseRecs, 
            Service_Portal_Freight_Configuration__mdt config, Map<String,Object> adhocDetails) {

        SpCreateAdhocPickupReqDtoAup reqDto = new SpCreateAdhocPickupReqDtoAup();
        SpCreateAdhocPickupReqDtoAup.Adhoc_pickup adhoc_pickup = new SpCreateAdhocPickupReqDtoAup.Adhoc_pickup();
        String pickupDate = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Requested_Date__c'));
        String pickupStartTime = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Req_Win_Start__c')).removeEnd('.000');
        String pickupEndTime = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Req_Win_End__c')).removeEnd('.000');
        String pickupInstructions = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Pickup_Instructions__c'));
        String customerNo = caseRecs[0].Contact.Account.TTI_SAP_Cust_No__c;
        String pickupRef = customerNo + String.valueOf(Date.today()).remove('-') + pickupStartTime.replaceAll(':','');

        adhoc_pickup.product_id = 'EXP';
        adhoc_pickup.pickup_reference = pickupRef.left(20); 
        adhoc_pickup.pickup_date = pickupDate;
        adhoc_pickup.pickup_starttime = pickupStartTime;
        adhoc_pickup.pickup_endtime = pickupEndTime;
        adhoc_pickup.pickup_instructions = pickupInstructions;
        adhoc_pickup.contains_dangerous_goods = false;
        adhoc_pickup.consignment_id = '';

        SpCreateAdhocPickupReqDtoAup.Source source = new SpCreateAdhocPickupReqDtoAup.Source();
        
        if (String.isNotBlank(caseRecs[0].Contact.Email)) {
            source.email = caseRecs[0].Contact.Email;
        }

        String phone = caseRecs[0].Service_Agent__r.Internal_Service_Agent__c && caseRecs[0].TTI_Freight_Out_Delivery_Country__c == 'Australia' ? 
            Label.SP_TTI_General_Customer_Service_Line : getValidPhoneNumber(caseRecs[0].Account.Phone);

        source.business_name = caseRecs[0].Service_Agent__r.Name.abbreviate(40);
        source.booking_name = caseRecs[0].Contact.Name.left(40);
        source.pickup_name = caseRecs[0].Account.Name.left(50);
        source.pickup_area = pickupInstructions.abbreviate(50);
        source.private_address = false;
        source.phone = phone.replaceAll('[^0-9]+','');
        source.postcode = caseRecs[0].TTI_Freight_Out_Pickup_Postcode__c;
        source.state = caseRecs[0].TTI_Freight_Out_Pickup_State__c;
        source.suburb = caseRecs[0].TTI_Freight_Out_Pickup_Suburb__c;
        source.lines = new List<String>{ caseRecs[0].TTI_Freight_Out_PickUp_Address__c };
        adhoc_pickup.source = source;

        Map<String,SpCreateAdhocPickupReqDtoAup.Parcel_details> parcelMap = new Map<String,SpCreateAdhocPickupReqDtoAup.Parcel_details>();
        SpCreateAdhocPickupReqDtoAup.Parcel_details parcel_detail;
        
        for (SPGetShipmentResDtoAup.Shipments shipment :resShipments.shipments) {
            for (SPGetShipmentResDtoAup.Items item :shipment.items) {
                adhoc_pickup.contains_dangerous_goods = adhoc_pickup.contains_dangerous_goods || item.contains_dangerous_goods;

                 if (!parcelMap.containsKey(item.packaging_type) ) {
                    parcel_detail = new SpCreateAdhocPickupReqDtoAup.Parcel_details();
                    parcel_detail.packaging_type = item.packaging_type;
                    parcel_detail.length = item.length;
                    parcel_detail.height = item.height;
                    parcel_detail.width = item.width;
                    parcel_detail.weight = item.weight;
                    parcel_detail.heaviest_item = item.weight;
                    parcel_detail.count = 1;
                    parcelMap.put(item.packaging_type, parcel_detail);
                } else {
                    parcel_detail = parcelMap.get(item.packaging_type);
                    parcel_detail.length = math.max(parcel_detail.length, item.length);
                    parcel_detail.height = math.max(parcel_detail.height, item.height);
                    parcel_detail.width = math.max(parcel_detail.width, item.width);
                    parcel_detail.weight = parcel_detail.weight + item.weight;
                    parcel_detail.heaviest_item = math.max(parcel_detail.heaviest_item, item.weight);
                    parcel_detail.count++;
                }
            }
        }

        List<SpCreateAdhocPickupReqDtoAup.Parcel_details> parcels = new List<SpCreateAdhocPickupReqDtoAup.Parcel_details>();
        for (String key : parcelMap.keySet()) {
            parcels.add(parcelMap.get(key));
        }

        adhoc_pickup.parcel_details = parcels;
        reqDto.adhoc_pickup = adhoc_pickup;

        return reqDto;
    }
    
    private static void handleErrorResponse(HttpResponse response, Integer statusCode) {
        SpErrorResDtoAup spErrorRes;
        spErrorRes = SpErrorResDtoAup.parse(response.getBody());
        
        throw new SpShippingAndTrackingAupException('The status code returned was not expected: ' + statusCode + ' ' + response.getStatus(), 
                                                    statusCode, 
                                                    spErrorRes.errors);
    }
}