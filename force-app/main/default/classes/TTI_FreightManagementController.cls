/**
 * @File Name          : TTI_FreightManagementController.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 27/08/2019, 6:33:52 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author             Modification
 *==============================================================================
 * 1.0    18/07/2019, 12:54:59 pm   Francis Nasalita     Initial Version
**/
public without sharing class TTI_FreightManagementController {

    private static Map<String, Service_Portal_Freight_Configuration__mdt> configFreightMap;
    private static final String INVALID_USER_ERROR_MESSAGE = 'Invalid user.';
    public static final AuraWrapperClass GENERIC_ERROR = new AuraWrapperClass('Error!', 'An unknown error has occured. Please contact your administrator.');
    private static final AuraWrapperClass GENERIC_CASE_ERROR = new AuraWrapperClass('Error!', 'An unknown error has occured while updating the case. Please contact your administrator.');

    public class TTI_FreightManagementControllerException extends Exception {}

    static {
        Boolean inProduction = ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        configFreightMap = new Map<String, Service_Portal_Freight_Configuration__mdt>();
        for (Service_Portal_Freight_Configuration__mdt c : [SELECT DeveloperName,
                                                                    Account_Number__c,
                                                                    Brand__c,
                                                                    Carrier__c,
                                                                    Country__c,
                                                                    Product_Default_Height__c,
                                                                    Product_Default_Length__c,
                                                                    Product_Default_Weight__c,
                                                                    Product_Default_Width__c,
                                                                    Product_Minimum_Weight__c
                                                            FROM Service_Portal_Freight_Configuration__mdt]) {

            if (c.DeveloperName == 'AU_StarTrack') {
                configFreightMap.put('AU_StarTrack', c);
            } else {
                String country = '';

                if (c.Country__c == 'Australia') {
                    country = 'AU';
                } else if (c.Country__c == 'New Zealand') {
                    country = 'NZ';
                }

                configFreightMap.put(country + '_' + c.Carrier__c + '_' + c.Brand__c, c);
            }
        }

        if (configFreightMap.isEmpty()) {
            throw new TTI_FreightManagementControllerException('There is a problem with your integration configuration. Kindly contact your administrator for assistance.');
        }
    }

    public static AuraHandledException getAuraException(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        return ex;
    }

    @AuraEnabled
    public static string getClaims(String lastNDays, Boolean isViewArchived) {
        List<Case> lstcase = new List<Case>();
        string result = null;
        
        List<User> lstUser = [SELECT Id, AccountId, Profile.Name, UserRole.Name FROM User where Id = :UserInfo.getUserId()];
        String userId = lstUser[0].Id;
        String accId = lstUser[0].AccountId;
        String profileName = lstUser[0].Profile.Name;
        String userRole = lstUser[0].UserRole.Name;
        String fields = 'Id, CaseNumber, Contact.Name, TTI_Customer_Contact__r.Name, Status, shipment_id__c, OrderId__c, TTI_Freight_Out_Courier__c, TTI_Closed_Datetime__c';
        // create shipment fields
        fields += ', Service_Agent__c, FreightOutDeliverTo__c, TTI_Freight_Out_PickUp_Address__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_Pickup_Country__c, TTI_Freight_Out_Pickup_State__c';
        fields += ', TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Country__c, TTI_Freight_Out_Delivery_State__c';
        fields += ', TTI_Freight_Out_Delivery_Postcode__c, SuppliedEmail, Brand__c, Service_Agent__r.Name, Service_Agent__r.Internal_Service_Agent__c, TTI_Service_Agent_Job_Number__c ';
        fields += ', Contact.Email, Contact.Phone, TTI_Customer_Account__r.Name, TTI_Customer_Account__r.Phone, Service_Agent__r.Company_Code__c';
        fields += ', Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Weight__c';
        fields += ', Product_Name__r.Width__c, Product_Name__r.Dangerous_Goods_Text__c, Service_Agent__r.Freight_Company__c, Label_Url__c, Label_Request_Id__c';
        fields += ', Service_Request_Milestone__c, TTI_Freight_Out_Required__c, Freight_out_consignment_number__c';
        fields += ', Retailer_Account__c, Retailer_Account__r.Name, Freight_Out_Delivery_Address_Modified__c, TTI_Customer_Delivery_Method__c, SuppliedPhone, ContactPhone';
        fields += ', Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c, Retailer_Account__r.Delivery_State__c, Retailer_Account__r.Delivery_Postcode__c, Retailer_Account__r.Delivery_Country__c';

        String whereQuery = '';

        if (profileName == 'System Administrator' || profileName == '~ Customer Service' || profileName == 'Customer Service') {

        } else {
            if (userRole != null && userRole.contains('Customer Manager')) {
                whereQuery = 'Service_Agent__c = :accId';
            } else {
                whereQuery = 'Diagnosed_User__c = :userId AND Service_Agent__c = :accId';
            }
        }
        
        String strQuery = 'SELECT ' + fields + ' FROM Case WHERE ' + whereQuery;
        strQuery += ' AND TTI_Closed_Datetime__c = LAST_N_DAYS:' + lastNDays;
        strQuery += ' AND TTI_Freight_Out_Courier__c != NULL';
        strQuery += ' AND (Service_Request_Milestone__c = \'Completed\' OR Service_Request_Milestone__c = \'Closed\')';
        strQuery += ' AND TTI_Freight_Out_Required__c = TRUE';
        strQuery += isViewArchived ? ' AND OrderId__c != NULL' : ' AND OrderId__c = NULL';
        strQuery += ' ORDER BY TTI_Closed_Datetime__c DESC';
        lstcase = Database.query(strQuery);

        if (!lstcase.isEmpty()) {
            result = JSON.serialize(lstcase);
        }

        return result;
    }

    @AuraEnabled
    public static User getCurrentUser() {
        try {
            User userObj = [SELECT Id, 
                                   AccountId, 
                                   Account.Allow_Delivery_to_Customers__c, 
                                   Account.TTI_SAP_Cust_No__c, 
                                   Account.Internal_Service_Agent__c, 
                                   ContactId, 
                                   Contact.Last_Manifested_Date__c
                             FROM User 
                            WHERE id = :UserInfo.getUserId()];

            if (userObj != null) {
                return userObj;
            } else {
                throw getAuraException(JSON.serialize(INVALID_USER_ERROR_MESSAGE));
            }
        } catch(Exception e) {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }

    @AuraEnabled
    public static String updateCaseFreight(String caseJson) {
        if (String.isNotBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);

            try {
                update caseRec;
                return JSON.serialize(caseRec);
            }  catch(DmlException e) {
                // insert error to error object
                throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }
    
    /**********************************************************************
    * @description Updates the freight controller's Last Manifested Date
    *              and returns serialized Contact record 
    * @param contactId the contact id of current user performing manifest
    * @example
    * TTI_FreightManagementController.updateFreightContact(caseRec.ContactId);
    */
    @AuraEnabled
    public static String updateFreightContact(String contactId) {
        if (String.isNotBlank(contactId)) {
            try {
                Contact freightContact = [SELECT Id, Last_Manifested_Date__c 
                                          FROM Contact
                                          WHERE Id = :contactId];
                if (freightContact != null) {
                    freightContact.Last_Manifested_Date__c = System.today();
                    update freightContact;
                    return JSON.serialize(freightContact);
                } else {
                    throw getAuraException(JSON.serialize(GENERIC_ERROR));
                }
            } catch(Exception e) {
                throw getAuraException(JSON.serialize(GENERIC_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }


    @AuraEnabled
    public static String getOrder(String orderId) {
        String response;

        Service_Portal_Freight_Configuration__mdt config = getConfig('AU_StarTrack');

        if (String.isNotBlank(orderId) && orderId != null && config != null) {
            try {
                response = JSON.serialize(SpShippingAndTrackingAup.getOrder(config.Account_Number__c, orderId));
            }  catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }
    
    @AuraEnabled
    public static String getShipment(String shipmentId) {
        String response;

        Service_Portal_Freight_Configuration__mdt config = getConfig('AU_StarTrack');

        if (String.isNotBlank(shipmentId) && shipmentId != null &&config != null) {
            try {
                response = SpShippingAndTrackingAup.getShipment(config.Account_Number__c, shipmentId);
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }

    @AuraEnabled
    public static String createOrder(String jsonShipmentIds, String jsonCaseNumbers, String customerNo) {
        String response = '';
        if (String.isNotBlank(jsonShipmentIds) && String.isNotBlank(jsonCaseNumbers) && String.isNotBlank(customerNo)) {
            List<String> shipmentIds = (List<String>) JSON.deserialize(jsonShipmentIds, List<String>.class);
            List<String> caseNumbers = (List<String>) JSON.deserialize(jsonCaseNumbers, List<String>.class);

            String orderRef = 'TTI-' + customerNo + '-' + getDateTimeNow();
            SPCreateOrderReqDtoAup reqDto = createManifestReqDto(shipmentIds, orderRef);
            Service_Portal_Freight_Configuration__mdt config = getConfig('AU_StarTrack');

            if (config != null) {
                try {
                    response = SpShippingAndTrackingAup.createOrder(config.Account_Number__c, reqDto);
                } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                    throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
                } catch(DmlException e) {
                    throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
                }
            } else {
                throw getAuraException(JSON.serialize(GENERIC_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }

    @AuraEnabled
    public static String createAdhocPickup(String jsonShipmentIds, String jsonCaseNumbers, String jsonAdhocDets) {
        String response = '';
        User currentUser = getCurrentUser();

        if (String.isNotBlank(jsonShipmentIds) && String.isNotBlank(jsonCaseNumbers) && String.isNotBlank(jsonAdhocDets)) {
            Service_Portal_Freight_Configuration__mdt config = getConfig('AU_StarTrack');
            if (config != null) {
                try {
                    String shipments;
                    if (!Test.isRunningTest()) {
                        shipments = getShipment(jsonShipmentIds.replaceAll('[\\[|\\]|\"]', ''));
                    } else {
                        shipments = SpTestDataFactory.generateExpectedGetShipmentResponse();
                    }
                    
                    SPGetShipmentResDtoAup resShipments = (SPGetShipmentResDtoAup) SPGetShipmentResDtoAup.parse(shipments);
                    Map<String,Object> adhocDetails = (Map<String,Object>) JSON.deserializeUntyped(jsonAdhocDets);
                    List<String> caseNumbers = (List<String>) JSON.deserialize(jsonCaseNumbers, List<String>.class);

                    List<Case> caseRecs = [SELECT Id, 
                                                  Freight_Out_Booking_ID__c, 
                                                  Freight_Out_Manifest_Req_Win_Start__c, 
                                                  Freight_Out_Manifest_Req_Win_End__c, 
                                                  Freight_Out_Manifest_Requested_Date__c, 
                                                  Freight_Out_Manifest_Pickup_Instructions__c, 
                                                  TTI_Freight_Out_Pickup_Postcode__c, 
                                                  TTI_Freight_Out_Pickup_State__c, 
                                                  TTI_Freight_Out_Pickup_Suburb__c, 
                                                  TTI_Freight_Out_PickUp_Address__c, 
                                                  TTI_Freight_Out_Delivery_Country__c, 
                                                  Service_Agent__r.Name, 
                                                  Service_Agent__r.Internal_Service_Agent__c, 
                                                  Account.Name, 
                                                  Account.Phone, 
                                                  Contact.Name, 
                                                  Contact.Email, 
                                                  Contact.Account.TTI_SAP_Cust_No__c, 
                                                  OrderId__c, 
                                                  Freight_Out_Manifest_Order_Number__c
                                             FROM Case 
                                            WHERE CaseNumber IN :caseNumbers];

                    SpCreateAdhocPickupReqDtoAup reqDto = new SpCreateAdhocPickupReqDtoAup();
                    reqDto = SpShippingAndTrackingAup.createAdhocPickupReqDto(resShipments, caseRecs, config, adhocDetails);

                    response = SpShippingAndTrackingAup.createAdhocPickup(config.Account_Number__c, reqDto);

                    SpCreateAdhocPickupResDtoAup spRes = (SpCreateAdhocPickupResDtoAup) JSON.deserialize(response, SpCreateAdhocPickupResDtoAup.class);

                    String pickupDate = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Requested_Date__c'));
                    String pickupStartTime = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Req_Win_Start__c'));
                    String pickupEndTime = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Req_Win_End__c'));
                    String pickupInstructions = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Pickup_Instructions__c'));
                    String orderId = String.valueOf(adhocDetails.get('Freight_Out_Manifest_Order_Number__c'));

                    for (Case caseRec :caseRecs) {
                        caseRec.Freight_Out_Manifest_Requested_Date__c = Date.valueOf(pickupDate);
                        caseRec.Freight_Out_Manifest_Req_Win_Start__c = Time.newInstance (
                                                                            Integer.valueOf(pickupStartTime.substring(0,2)), 
                                                                            Integer.valueOf(pickupStartTime.substring(3,5)), 
                                                                            Integer.valueOf(pickupStartTime.substring(6,8)), 
                                                                            0
                                                                        );
                        caseRec.Freight_Out_Manifest_Req_Win_End__c = Time.newInstance (
                                                                            Integer.valueOf(pickupEndTime.substring(0,2)), 
                                                                            Integer.valueOf(pickupEndTime.substring(3,5)), 
                                                                            Integer.valueOf(pickupEndTime.substring(6,8)), 
                                                                            0
                                                                        );
                        caseRec.Freight_Out_Manifest_Pickup_Instructions__c = pickupInstructions;
                        caseRec.Freight_Out_Booking_ID__c = spRes.adhoc_pickups[0].booking_id;
                        caseRec.OrderId__c = orderId;
                        caseRec.Freight_Out_Manifest_Order_Number__c = orderId;
                    }

                    update caseRecs;
                } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                    throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
                } catch(DmlException e) {
                    throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
                }
            } else {
                throw getAuraException(JSON.serialize(GENERIC_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }

    @AuraEnabled
    public static String deleteShipment(String caseId, String shipmentId) {
        String response;

        Service_Portal_Freight_Configuration__mdt config = getConfig('AU_StarTrack');
        
        if (String.isNotBlank(shipmentId) && String.isNotBlank(caseId) && config != null) {
            try {
                response = SpShippingAndTrackingAup.deleteShipment(config.Account_Number__c, shipmentId);

                Case claim = new Case(
                    Id = caseId, 
                    Shipment_Id__c = null,
                    Label_Status__c = null,
                    Label_Request_Id__c = null,
                    Label_Url__c = null,
                    Freight_Out_Delivery_Address_Modified__c = false,
                    Freight_out_consignment_number__c = null
                );
                update claim;
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            } catch(DmlException e) {
                throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }

    @AuraEnabled
    public static String createShipment(String caseJson) {

        String shipmentId;
        if (String.isNotBlank(caseJson)) {
            try {
                Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);
                String freightConfigLabel = getFreightConfigLabel(caseRec);
                Service_Portal_Freight_Configuration__mdt config = getConfig(freightConfigLabel);
                SpCreateShipmentReqDtoAup shipmentReqDto = SpShippingAndTrackingAup.createShipmentReqDto(caseRec, config);

                List<SpShipment> shipmentList = SpShippingAndTrackingAup.createShipments(config.Account_Number__c, shipmentReqDto);

                if (!shipmentList.isEmpty()) {
                    SpCreateShipmentResDtoAup.Shipment shipment = (SpCreateShipmentResDtoAup.Shipment) shipmentList[0];
                    updateCaseWithShipment(caseRec.Id, shipment.shipment_id, shipment.items[0].tracking_details.consignment_id);

                    shipmentId = shipment.shipment_id;
                } else {
                    throw getAuraException(JSON.serialize(GENERIC_ERROR));
                }
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            } catch(DmlException e) {
                throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
            } catch(Exception e) {
                throw getAuraException(JSON.serialize(GENERIC_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
            
        return shipmentId;
    }

    @AuraEnabled
    public static void updateShipment(String caseJson, String shipmentId) {
        if (String.isNotBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);

            String freightConfigLabel = getFreightConfigLabel(caseRec);
            Service_Portal_Freight_Configuration__mdt config = getConfig(freightConfigLabel);

            SpUpdateShipmentReqDtoAup shipmentReqDto = updateShipmentReqDto(caseRec, config);

            try {
                if (config != null) {
                    SpCreateShipmentResDtoAup.Shipment shipment = (SpCreateShipmentResDtoAup.Shipment) SpShippingAndTrackingAup.updateShipment(config.Account_Number__c, shipmentId, shipmentReqDto);
                    updateCaseWithShipment(caseRec.Id, shipment.shipment_id, shipment.items[0].tracking_details.consignment_id);
                }
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }

    @AuraEnabled
    public static String createLabel(String caseJson, String shipmentId, String format) {
        String response;

        if (String.isNotBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);
            SpCreateLabelReqDtoAup label = SpShippingAndTrackingAup.createLabelReqDto(shipmentId, format);
            Service_Portal_Freight_Configuration__mdt config = configFreightMap.get(getFreightConfigLabel(caseRec));

            try {
                List<SpLabel> labelsList = SpShippingAndTrackingAup.createLabels(config.Account_Number__c, label);

                if (!labelsList.isEmpty()) {
                    updateCaseWithLabelReqId(caseRec.Id, ((SpCreateLabelResDtoAup.Label) labelsList[0]).request_id);
                    response = JSON.serialize(labelsList);
                }
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            } catch(DmlException e) {
                throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }

        return response;
    }

    @AuraEnabled
    public static String getLabel(String caseJson, String requestId) {
        String response;

        if (String.isNotBlank(caseJson) && String.isNotBlank(requestId)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);
            Service_Portal_Freight_Configuration__mdt config = getConfig(getFreightConfigLabel(caseRec));

            try {
                SpLabel labelObj = SpShippingAndTrackingAup.getLabel(config.Account_Number__c, requestId);

                SpGetLabelResDtoAup.Label labelDto = (SpGetLabelResDtoAup.Label) labelObj;

                if (labelDto.status == 'AVAILABLE' || (labelDto.status == 'PENDING' && caseRec.Label_Status__c != 'PENDING')) {
                    updateCaseWithLabelUrl(caseRec.Id, labelDto.url, labelDto.status);
                }

                response = JSON.serialize(labelObj);
            } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
            } catch(DmlException e) {
                throw getAuraException(JSON.serialize(GENERIC_CASE_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
        return response;
    }

    @AuraEnabled
    public static String getDangerousGoodsForm(String caseJson, String shipmentId) {
        String response = '';
        if (!String.isBlank(caseJson)) {
            Case caseRec = (Case) JSON.deserialize(caseJson, Case.class);

            if (String.isNotBlank(shipmentId)) {
                try {
                    Service_Portal_Freight_Configuration__mdt config = getConfig(getFreightConfigLabel(caseRec));

                    response = JSON.serialize(SpShippingAndTrackingAup.getDangerousGoodsForm(config.Account_Number__c, shipmentId));
                } catch(SpShippingAndTrackingAup.SpShippingAndTrackingAupException e) {
                    throw getAuraException(JSON.serialize(new AuraWrapperClass(e.errors, e.statusCode, '')));
                }
            } else {
                throw getAuraException(JSON.serialize(GENERIC_ERROR));
            }
        } else {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
        return response;
    }

    private static Service_Portal_Freight_Configuration__mdt getConfig(String value) {
        Service_Portal_Freight_Configuration__mdt config = Test.isRunningTest() ? 
            configFreightMap.values()[0] : 
            configFreightMap.get(value);

        return config;
    }

    private static SPCreateOrderReqDtoAup createManifestReqDto(List<String> shipmentIds, String orderRef) {
        SPCreateOrderReqDtoAup manifest = new SPCreateOrderReqDtoAup();
        List<SPCreateOrderReqDtoAup.Shipments> shipments = new List<SPCreateOrderReqDtoAup.Shipments>();

        for(String shipmentId :shipmentIds) {
            SPCreateOrderReqDtoAup.Shipments shipment = new SPCreateOrderReqDtoAup.Shipments();
            shipment.shipment_id = shipmentId;
            shipments.add(shipment);
        }

        manifest.shipments = shipments;
        manifest.order_reference = orderRef;
        manifest.payment_method = 'CHARGE_TO_ACCOUNT';

        return manifest;
    }

    private static String getDateTimeNow() {
        DateTime now = System.Now();
        String year = String.valueOf(now.year());
        String month = String.valueOf(now.month());
        String day = String.valueOf(now.day());
        String hour = String.valueOf(now.hour());
        String minute = String.valueOf(now.minute());
        return year + month + day + hour + minute;
    }

    private static String getFreightConfigLabel(Case caseRec) {
        if (caseRec != null) {
            String freightConfigLabel = '';

            if (caseRec.Service_Agent__r.Company_Code__c == 'BP01') {
                freightConfigLabel += 'AU_';
            } else if (caseRec.Service_Agent__r.Company_Code__c == 'NZ01') {
                freightConfigLabel += 'NZ_';
            } else {
                return null;
            }

            if (caseRec.Service_Agent__r.Freight_Company__c != null) {
                freightConfigLabel += caseRec.Service_Agent__r.Freight_Company__c + '_';
            } else {
                return null;
            }

            if (caseRec.Brand__c != null) {
                freightConfigLabel += caseRec.Brand__c;
            } else {
                return null;
            }

            return freightConfigLabel;
        } else {
            return null;
        }
    }

    private static void updateCaseWithLabelReqId(Id caseId, String requestId) {
        Case caseRec = new Case();
        caseRec.Id = caseId;
        caseRec.Label_Request_Id__c = requestId;

        try {
            update caseRec;
        } catch (Exception e) {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }

    private static void updateCaseWithLabelUrl(Id caseId, String url, String status) {
        Case caseRec = new Case();
        caseRec.Id = caseId;
        caseRec.Label_Url__c = url;
        caseRec.Label_Status__c = status;

        try {
            update caseRec;
        } catch (Exception e) {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }

    private static void updateCaseWithShipment(Id caseId, String shipmentId, String consignmentId) {
        Case caseRec = new Case();
        caseRec.Id = caseId;
        caseRec.Shipment_Id__c = shipmentId;
        caseRec.Freight_out_consignment_number__c = consignmentId;

        try {
            update caseRec;
        } catch (Exception e) {
            throw getAuraException(JSON.serialize(GENERIC_ERROR));
        }
    }

    public static SpUpdateShipmentReqDtoAup updateShipmentReqDto(Case caseRec, Service_Portal_Freight_Configuration__mdt config) {
        String agentPhone = String.isNotBlank(caseRec.Contact.Phone) ? caseRec.Contact.Phone : '';
        if (String.isNotBlank(agentPhone) && Pattern.matches(Label.UTIL_REGEX_ANZ_Phone_Format, agentPhone)) {
            agentPhone = agentPhone.replaceFirst('\\+(61|64)', '0');
        }

        String customerPhone = String.isNotBlank(caseRec.SuppliedPhone) ? caseRec.SuppliedPhone : '';
        if (String.isNotBlank(customerPhone) && Pattern.matches(Label.UTIL_REGEX_ANZ_Phone_Format, customerPhone)) {
            customerPhone = customerPhone.replaceFirst('\\+(61|64)', '0');
        }

        String height = caseRec.Product_Name__r.Height__c == null ? config.Product_Default_Height__c : String.valueOf(Math.round(Integer.valueOf(caseRec.Product_Name__r.Height__c)));
        String length = caseRec.Product_Name__r.Length__c == null ? config.Product_Default_Length__c : String.valueOf(Math.round(Integer.valueOf(caseRec.Product_Name__r.Length__c)));
        String width = caseRec.Product_Name__r.Width__c == null ? config.Product_Default_Width__c : String.valueOf(Math.round(Integer.valueOf(caseRec.Product_Name__r.Width__c)));
        String weight;
        if (caseRec.Product_Name__r.Weight__c == null) {
            weight = config.Product_Default_Weight__c;
        } else if (Double.valueOf(caseRec.Product_Name__r.Weight__c) < 1) {
            weight = config.Product_Minimum_Weight__c;
        } else {
            weight = String.valueOf(Math.round(Integer.valueOf(caseRec.Product_Name__r.Weight__c)));
        }

        SpUpdateShipmentReqDtoAup reqDto = new SpUpdateShipmentReqDtoAup();
        
        reqDto.movement_type = 'TRANSFER';
        reqDto.consolidate = false;
        reqDto.customer_reference_1 = caseRec.CaseNumber;
        reqDto.customer_reference_2 = caseRec.TTI_Service_Agent_Job_Number__c;
        reqDto.email_tracking_enabled = String.IsNotBlank(caseRec.SuppliedEmail);
        reqDto.shipment_reference = 'TTI_CASE_' + caseRec.CaseNumber;

        SpUpdateShipmentReqDtoAup.Source source = new SpUpdateShipmentReqDtoAup.Source();

        if (String.isNotBlank(caseRec.Contact.Email)) {
            source.email = caseRec.Contact.Email;
        }
        if (String.isNotBlank(agentPhone)) {
            source.phone = agentPhone;
        }        
        
        source.name = caseRec.Service_Agent__r.Name;
        source.postcode = caseRec.TTI_Freight_Out_Pickup_Postcode__c;
        source.state = caseRec.TTI_Freight_Out_Pickup_State__c;
        source.suburb = caseRec.TTI_Freight_Out_Pickup_Suburb__c;
        source.lines = new List<String>{ caseRec.TTI_Freight_Out_PickUp_Address__c };
        reqDto.source = source;

        SpUpdateShipmentReqDtoAup.Destination destination = new SpUpdateShipmentReqDtoAup.Destination();

        if (String.isNotBlank(caseRec.SuppliedEmail)) {
            destination.email = caseRec.SuppliedEmail;
        }
        if (String.isNotBlank(customerPhone)) {
            destination.phone = customerPhone;
        }
        
        destination.name = caseRec.FreightOutDeliverTo__c;
        destination.postcode = caseRec.TTI_Freight_Out_Delivery_Postcode__c;
        destination.state = caseRec.TTI_Freight_Out_Delivery_State__c;
        destination.suburb = caseRec.TTI_Freight_Out_Delivery_Suburb__c;
        destination.lines = new List<String>{ caseRec.TTI_Freight_Out_Delivery_Address__c };
        reqDto.destination = destination;

        SpUpdateShipmentReqDtoAup.Items item = new SpUpdateShipmentReqDtoAup.Items();
        item.allow_partial_delivery = false;
        item.authority_to_leave = false;
        item.height = height;
        item.item_reference = caseRec.Product_Name__r.SAP_MaterialNumber__c;
        item.length = length;
        item.packaging_type = 'ITM';
        item.product_id = 'EXP';
        item.weight = weight;
        item.width = width;

        SpUpdateShipmentReqDtoAup.Dangerous_goods dangerousGoods = new SpUpdateShipmentReqDtoAup.Dangerous_goods();
        if (String.isNotBlank(caseRec.Product_Name__r.Dangerous_Goods_Text__c)) {
            item.contains_dangerous_goods = true;
            item.product_id = 'EXP';

            dangerousGoods.un_number = Label.SP_Dangerous_Goods_Code;
            dangerousGoods.technical_name = 'Lithium Metal Batteries';
            dangerousGoods.net_weight = weight;
            dangerousGoods.class_division = '9';
            dangerousGoods.outer_packaging_type = 'BOX';
            dangerousGoods.outer_packaging_quantity = '1';

            reqDto.dangerous_goods = dangerousGoods;
        }

        reqDto.items = new List<SpUpdateShipmentReqDtoAup.Items>{ item };

        return reqDto;
    }

    public class AuraWrapperClass {
        public Integer statusCode { get; set; }
        public List<ErrorObj> errors { get; set; }
        public String response { get; set; }
        
        public AuraWrapperClass(List<SpErrorResDtoAup.Errors> listError, Integer statCode, String res) {
            this.errors = new List<ErrorObj>();
            this.statusCode = statCode;
            this.response = res;
            
            if (!listError.isEmpty()) {
                for (SpErrorResDtoAup.Errors error :listError) {
                    errors.add(new ErrorObj(error));
                }
            }
        }

        public AuraWrapperClass(String title, String message, String res) {
            this.errors = new List<ErrorObj>{ new ErrorObj(title, message) };
            this.statusCode = null;
            this.response = res;
        }

        public AuraWrapperClass(String title, String message) {
            this.errors = new List<ErrorObj>{ new ErrorObj(title, message) };
            this.statusCode = null;
            this.response = null;
        }
    }
    
    public class ErrorObj {
        public String title;
        public String message;
        public String field;
        public String code;
        
        public ErrorObj(String strTitle, String strMessage) {
            this.title = strTitle;
            this.message = strMessage;
            this.field = null;
            this.code = null;
        }
        
        public ErrorObj(SpErrorResDtoAup.Errors error) {
            this.title = error.name;
            this.message = error.message;
            this.field = error.field;
            this.code = error.code;
        }
    }
}