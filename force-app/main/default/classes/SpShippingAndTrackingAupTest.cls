/**
 * @File Name          : SpShippingAndTrackingAupTest.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 29/08/2019, 10:32:34 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author            Modification
 *==============================================================================
 * 1.0    29/08/2019, 8:38:24 PM   Francis Nasalita     Initial Version
**/
@IsTest
public with sharing class SpShippingAndTrackingAupTest {

    @IsTest
    static void testCreateShipmentsByObj() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201, 
                                                                             'Created', 
                                                                             SpTestDataFactory.generateExpectedCreateShipmentsResponse(), 
                                                                             responseHeaders));

        // Prepare the request
        SpCreateShipmentReqDtoAup reqDto = SpTestDataFactory.generateCreateShipmentRequest();

        // This causes a fake response to be sent from the class that implements HttpCalloutMock. 
        List<SpCreateShipmentResDtoAup.Shipment> shipments = (List<SpCreateShipmentResDtoAup.Shipment>) SpShippingAndTrackingAup.createShipments('00673416', reqDto);

        System.assertEquals(1, shipments.size(), 'No shipment has been created.');

        SpCreateShipmentResDtoAup.Shipment shipment = shipments[0];
        System.assertEquals('1g8K0E6mBEsAAAFpAGUg7EZn', shipment.shipment_id, 'Invalid shipment Id.');
        System.assertEquals('M18FID-0', shipment.items.get(0).item_reference, 'Invalid product code.');
        System.assertEquals(44.88, shipment.shipment_summary.total_cost_ex_gst, 'Incorrect total cost.');
        
    }
    
    @IsTest
    static void testCreateShipmentsByJson() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201, 
                                                                             'Created', 
                                                                             SpTestDataFactory.generateExpectedCreateShipmentsResponse(), 
                                                                             responseHeaders));

        // Prepare the request
        String json = '{' +
        '    \"shipments\": [' +
        '        {' +
        '            \"shipment_reference\": \"TTI_CASE_00196151\",' +
        '            \"customer_reference_1\": \"00196151\",' +
        '            \"customer_reference_2\": \"\",' +
        '            \"email_tracking_enabled\": true,' +
        '            \"consolidate\": false,' +
        '            \"from\": {' +
        '                \"name\": \"External Agent\",' +
        '                \"lines\": [' +
        '                    \"21 Kelletts Road\"' +
        '                ],' +
        '                \"suburb\": \"Rowville\",' +
        '                \"state\": \"VIC\",' +
        '                \"postcode\": \"3178\",' +
        '                \"phone\": \"\",' +
        '                \"email\": \"fnasalita@ttibrands.com.au\"' +
        '            },' +
        '            \"to\": {' +
        '                \"name\": \"Jack Codling\",' +
        '                \"lines\": [' +
        '                    \"67 Bayfield Street\"' +
        '                ],' +
        '                \"suburb\": \"CRANBROOK\",' +
        '                \"state\": \"TAS\",' +
        '                \"postcode\": \"7190\",' +
        '                \"phone\": \"\",' +
        '                \"email\": \"jack.codling@yopmail.com\"' +
        '            },' +
        '            \"items\": [' +
        '                {' +
        '                    \"item_reference\": \"M18FDD-0\",' +
        '                    \"product_id\": \"PRM\",' +
        '                    \"length\": \"40\",' +
        '                    \"height\": \"35\",' +
        '                    \"width\": \"14\",' +
        '                    \"weight\": \"5\",' +
        '                    \"allow_partial_delivery\": false,' +
        '                    \"packaging_type\": \"ITM\",' +
        '                    \"authority_to_leave\": false' +
        '                }' +
        '            ]' +
        '        }' +
        '    ]' +
        '}';

        // This causes a fake response to be sent from the class that implements HttpCalloutMock. 
        List<SpCreateShipmentResDtoAup.Shipment> shipments = (List<SpCreateShipmentResDtoAup.Shipment>) SpShippingAndTrackingAup.createShipments('00673416', json);

        System.assertEquals(1, shipments.size(), 'No shipment has been created.');

        SpCreateShipmentResDtoAup.Shipment shipment = shipments[0];
        System.assertEquals('1g8K0E6mBEsAAAFpAGUg7EZn', shipment.shipment_id, 'Invalid shipment Id.');
        System.assertEquals('M18FID-0', shipment.items.get(0).item_reference, 'Invalid product code.');
        System.assertEquals(44.88, shipment.shipment_summary.total_cost_ex_gst, 'Incorrect total cost.');
        
    }

    @IsTest
    static void testExecCallout() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201, 
                                                                             'Created', 
                                                                             SpTestDataFactory.generateExpectedCreateShipmentsResponse(), 
                                                                             responseHeaders));
        
        SpCreateShipmentReqDtoAup reqDto = SpTestDataFactory.generateCreateShipmentRequest();
        Map<String, Object> tmp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(reqDto));
        SpShippingAndTrackingAup.fixShipmentCreationReqJsonKeys(tmp);
        String jsonRequest = JSON.serialize(tmp);

        Boolean inProduction = ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Map<String, Service_Portal_Integration_Configuration__mdt> configActionMap = new Map<String, Service_Portal_Integration_Configuration__mdt>();
        for (Service_Portal_Integration_Configuration__mdt c : [SELECT Action__c,
                                                                       Username__c,
                                                                       Secret__c,
                                                                       Endpoint_Full_URL__c
                                                                  FROM Service_Portal_Integration_Configuration__mdt
                                                                 WHERE Is_Production__c = :inProduction
                                                                   AND Freight_Forwarder__c = 'Australia_Post']) {
            configActionMap.put(c.Action__c, c);
        }

        Service_Portal_Integration_Configuration__mdt config = configActionMap.get('CREATE_SHIPMENT');

        HttpResponse response = SpShippingAndTrackingAup.execCallout('00673416', jsonRequest, config.Username__c, config.Secret__c, config.Endpoint_Full_URL__c, 'POST');

        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assertEquals('application/json', contentType);
        String actualValue = response.getBody();
        System.assertEquals(actualValue, SpTestDataFactory.generateExpectedCreateShipmentsResponse());
        System.assertEquals(201, response.getStatusCode());
        System.assertEquals('Created', response.getStatus());

    }

    @IsTest
    static void testCreateLabelsByObj() {
        
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200, 
                                                                             'OK', 
                                                                             SpTestDataFactory.generateExpectedCreateLabelsResponse(), 
                                                                             responseHeaders));

        // Prepare the request
        SpCreateLabelReqDtoAup reqDto = SpTestDataFactory.generateCreateLabelRequest();

        // This causes a fake response to be sent from the class that implements HttpCalloutMock. 
        List<SpLabel> labelsList = SpShippingAndTrackingAup.createLabels('00673416', reqDto);

        System.assertEquals(1, labelsList.size());

        SpCreateLabelResDtoAup.Label label = (SpCreateLabelResDtoAup.Label) labelsList.get(0);
        System.assertEquals('b3ed5e7a-e5fa-45cb-b482-dca37a5d5716', label.request_id);
        System.assertEquals('PENDING', label.status);
        System.assertEquals('07-03-2019 13:29:17', label.request_date);
        System.assertEquals('1g8K0E6mBEsAAAFpAGUg7EZn', label.shipments.get(0).shipment_id);

    }

    @IsTest
    static void testCreateLabelsByJson() {
        
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200, 
                                                                             'OK', 
                                                                             SpTestDataFactory.generateExpectedCreateLabelsResponse(), 
                                                                             responseHeaders));

        // Prepare the request
        String json = '{' +
        '    \"preferences\": [' +
        '        {' +
        '            \"type\": \"PRINT\",' +
        '            \"format\": \"PDF\",' +
        '            \"groups\": [' +
        '                {' +
        '                    \"group\": \"StarTrack\",' +
        '                    \"layout\": \"A6-1pp\",' +
        '                    \"branded\": true,' +
        '                    \"left_offset\": 0,' +
        '                    \"top_offset\": 0' +
        '                },' +
        '            ]' +
        '        }' +
        '    ],' +
        '    \"shipments\": [' +
        '        {' +
        '            \"shipment_id\": \"DY0K0E6mBdYAAAFojWwg7Ma3\"' +
        '        }' +
        '    ]' +
        '}';

        // This causes a fake response to be sent from the class that implements HttpCalloutMock. 
        List<SpLabel> labelsList = SpShippingAndTrackingAup.createLabels('00673416', json);

        System.assertEquals(1, labelsList.size());

        SpCreateLabelResDtoAup.Label label = (SpCreateLabelResDtoAup.Label) labelsList.get(0);
        System.assertEquals('b3ed5e7a-e5fa-45cb-b482-dca37a5d5716', label.request_id);
        System.assertEquals('PENDING', label.status);
        System.assertEquals('07-03-2019 13:29:17', label.request_date);
        System.assertEquals('1g8K0E6mBEsAAAFpAGUg7EZn', label.shipments.get(0).shipment_id);
    }

    @IsTest
    static void testGetLabelPending() {
        
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                             'OK',
                                                                             SpTestDataFactory.generateExpectedGetLabelResponse(),
                                                                             responseHeaders));
        
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        SpLabel labelDto = SpShippingAndTrackingAup.getLabel('00673416', 'd9d1445d-cd1b-452d-9d68-29dbb3967acf');
        
        System.assert(labelDto != null);
        
        SpGetLabelResDtoAup.Label label = (SpGetLabelResDtoAup.Label) labelDto;
        System.assertEquals('d9d1445d-cd1b-452d-9d68-29dbb3967acf', label.request_id);
        System.assertEquals(null, label.url);
        System.assertEquals('PENDING', label.status);
        System.assertEquals('01-04-2016 05:09:14', label.request_date);
        System.assertEquals(null, label.url_creation_date);
        System.assert(!label.shipments.isEmpty());
        System.assertEquals('t4AK0EhQTu4AAAFeVsxGqhLO', label.shipment_ids[0]);
    }

    @IsTest
    static void testUpdateShipmentbyObj() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                             'OK',
                                                                             SpTestDataFactory.generateUpdateShipmentResponse(),
                                                                             responseHeaders));
        
        
        SpUpdateShipmentReqDtoAup reqDto = SpUpdateShipmentReqDtoAup.parse(SpTestDataFactory.generateUpdateShipmentRequest());
        SpCreateShipmentResDtoAup.Shipment shipment = (SpCreateShipmentResDtoAup.Shipment) SpShippingAndTrackingAup.updateShipment('00673416', 'gskK1UrUQPMAAAFSUuRKdt9Y', reqDto);
        System.assertEquals('t4AK0EhQTu4AAAFeVsxGqhLO', shipment.shipment_id, 'Shipment Id does not match.');
    }
    
    @IsTest
    static void testUpdateShipmentbyJson() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                             'OK',
                                                                             SpTestDataFactory.generateUpdateShipmentResponse(),
                                                                             responseHeaders));
        
        SpCreateShipmentResDtoAup.Shipment shipment = (SpCreateShipmentResDtoAup.Shipment) SpShippingAndTrackingAup.updateShipment('00673416', 'gskK1UrUQPMAAAFSUuRKdt9Y', SpTestDataFactory.generateUpdateShipmentRequest());
        System.assertEquals('t4AK0EhQTu4AAAFeVsxGqhLO', shipment.shipment_id, 'Shipment Id does not match.');
    }

    @IsTest
    static void testGetDangerousGoodsForm(){
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/pdf'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                             'OK',
                                                                             'blob',
                                                                             responseHeaders));
        Blob resDto = SpShippingAndTrackingAup.getDangerousGoodsForm('00673416', 'gskK1UrUQPMAAAFSUuRKdt9Y');
        System.assert(resDto != null, 'Should return dangerous goods form.');
    }

    @IsTest
    static void testDeleteShipment() {
        
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                             'OK',
                                                                             '',
                                                                             responseHeaders));
        String resDto = SpShippingAndTrackingAup.deleteShipment('00673416', 'gskK1UrUQPMAAAFSUuRKdt9Y');
        System.assertEquals('gskK1UrUQPMAAAFSUuRKdt9Y', resDto);
    }

    @IsTest
    static void testGetShipment() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                             'OK',
                                                                             SpTestDataFactory.generateExpectedGetShipmentResponse(),
                                                                             responseHeaders));
        String resDto = SpShippingAndTrackingAup.getShipment('00673416', '9lesEAOvOm4AAAFI3swaDRYB');
        SPGetShipmentResDtoAup response = (SPGetShipmentResDtoAup) SPGetShipmentResDtoAup.parse(resDto);
        System.assertEquals('9lesEAOvOm4AAAFI3swaDRYB', response.shipments[0].shipment_id, 'Shipment Id does not match.');
    }

    @IsTest
    static void testCreateOrder() {
        
        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                             'OK',
                                                                             SpTestDataFactory.generateExpectedCreateOrderResponse(),
                                                                             responseHeaders));

        SpCreateOrderReqDtoAup reqDto = SpCreateOrderReqDtoAup.parse(SpTestDataFactory.generateCreateOrderRequest());
        String resDto = SpShippingAndTrackingAup.createOrder('00673416', reqDto);
        SpCreateOrderResDtoAup response = (SpCreateOrderResDtoAup) SpCreateOrderResDtoAup.parse(resDto);
        System.assertEquals('AP0000002422', response.order.order_id, 'Order Id does not match.');
    }

    @IsTest
    static void testGetOrder() {

        // Prepare the mocking class
        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                             'OK',
                                                                             SpTestDataFactory.generateExpectedGetOrderResponse(),
                                                                             responseHeaders));
        Blob resDto = SpShippingAndTrackingAup.getOrder('00673416', 'AP0000002422');
        System.assert(resDto != null, 'Should return order summary details.');
    }

    @IsTest
    static void testCreateLabelReqDto() {
        SpCreateLabelReqDtoAup label = SpShippingAndTrackingAup.createLabelReqDto('t4AK0EhQTu4AAAFeVsxGqhLO', 'PDF');
        System.assert(label.shipments.size() > 0, 'Label does not contain shipments.');
    }

    @IsTest
    static void testCreateShipmentDto() {
        Boolean inProduction = ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        Map<String, Service_Portal_Freight_Configuration__mdt> configFreightMap = new Map<String, Service_Portal_Freight_Configuration__mdt>();
        for (Service_Portal_Freight_Configuration__mdt c : [SELECT Account_Number__c,
                                                                    Brand__c,
                                                                    Carrier__c,
                                                                    Country__c,
                                                                    Product_Default_Height__c,
                                                                    Product_Default_Length__c,
                                                                    Product_Default_Weight__c,
                                                                    Product_Default_Width__c,
                                                                    Product_Minimum_Weight__c
                                                            FROM Service_Portal_Freight_Configuration__mdt]) {

            String country = '';

            if (c.Country__c == 'Australia') {
                country = 'AU';
            } else if (c.Country__c == 'New Zealand') {
                country = 'NZ';
            }

            configFreightMap.put(country + '_' + c.Carrier__c + '_' + c.Brand__c, c);
        }

        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1];

        User newUser = new User(UserRoleId = portalRole.Id,
                                ProfileId = profId.Id,
                                Username = System.now().millisecond() + 'test23@test.com',
                                Alias = 'batman',
                                Email='bruce.wayne@ttibrands.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        insert newUser;

        Contact newContact = TTI_CommonUtilityClass.createContact();
        User serviceAgentUser;
        Account serviceAgentAcc;
        Contact serviceAgentContact;
        Product2 prod;

        System.runAs(newUser) {
            insert newContact;

            prod = new Product2(Name = 'Laptop X200',
                                SAP_Material_Type__c = 'HAWA',
                                Family = 'Hardware',
                                AU_Landed_Cost__c = null,
                                NZ_Landed_Cost__c = null,
                                Maximum_Number_of_Parts__c = 0,
                                SOH_BP01__c = 1,
                                Standard_Warranty_Months__c = -10.0,
                                Height__c = 10,
                                Length__c = 12,
                                Width__c = 50,
                                Weight__c = 150,
                                Dangerous_Goods_Text__c = 'CLASS9',
                                SAP_MaterialNumber__c = '00123456789'
            );
            insert prod;

            serviceAgentAcc = TTI_CommonUtilityClass.createAccount();
            serviceAgentAcc.Name = 'Demo Account';
            serviceAgentAcc.Company_Code__c = 'BP01';
            serviceAgentAcc.Freight_Company__c = 'StarTrack';
            serviceAgentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();            
            insert serviceAgentAcc;

            serviceAgentContact = TTI_CommonUtilityClass.createContact();
            serviceAgentContact.AccountId = serviceAgentAcc.Id;
            serviceAgentContact.Phone = '+61465432198';
            serviceAgentContact.Email = 'Demo.Account@yopmail.com';
            insert serviceAgentContact;

            serviceAgentUser = TTI_CommonUtilityClass.createUser();
            serviceAgentUser.ContactId = serviceAgentContact.Id;
            serviceAgentUser.LastName = 'Account';
            serviceAgentUser.Email = 'Demo.Account@yopmail.com';
            serviceAgentUser.UserName = 'Demo.Account@yopmail.com';
            serviceAgentUser.TTI_SAP_Cust_No__c = '54321';
            insert serviceAgentUser;
        }

        System.runAs(serviceAgentUser) {
            Case caseObj = TTI_CommonUtilityClass.createCase('Milwaukee');
            caseObj.Service_Agent__c = serviceAgentAcc.Id;
            caseObj.AccountId = serviceAgentAcc.Id;
            caseObj.Product_Name__c  = prod.Id;
            caseObj.TTI_Closed_Datetime__c = system.now() - 5;
            caseObj.Diagnosed_User__c = serviceAgentUser.Id;
            //caseObj.TTI_Customer_Account__c = customerAccount.Id;
            caseObj.TTI_Service_Agent_Job_Number__c = 'JN-088-2011-0001';
            caseObj.TTI_Freight_Out_PickUp_Address__c = '21 Kelletts Road';
            caseObj.TTI_Freight_Out_Pickup_State__c = 'VIC';
            caseObj.TTI_Freight_Out_Pickup_Postcode__c = '3178';
            caseObj.TTI_Freight_Out_Pickup_Suburb__c = 'Rowville';
            caseObj.TTI_Freight_Out_Pickup_Country__c = 'Australia';
            caseObj.SuppliedEmail = 'jack.codling@yopmail.com';
            caseObj.SuppliedPhone = '+61445632197';
            caseObj.TTI_Freight_Out_Delivery_Postcode__c = '4500';
            caseObj.TTI_Freight_Out_Delivery_State__c = 'QLD';
            caseObj.TTI_Freight_Out_Delivery_Suburb__c = 'BRENDALE';
            caseObj.TTI_Freight_Out_Delivery_Address__c = '1 22-24 STRATHWYN ST';
            caseObj.TTI_Freight_Out_Delivery_Country__c = 'Australia';

            insert caseObj;
        }
        
        Case claim = [SELECT Id, CaseNumber, SuppliedEmail, Contact.Phone, Contact.Email, TTI_Customer_Account__r.PersonMobilePhone, TTI_Service_Agent_Job_Number__c,
                                        Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Width__c, Product_Name__r.Weight__c,
                                        Service_Agent__r.Name, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c,
                                        TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Pickup_State__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_PickUp_Address__c,
                                        TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Address__c, Service_Agent__r.Internal_Service_Agent__c, 
                                        FreightOutDeliverTo__c, Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Dangerous_Goods_Text__c, SuppliedPhone
                                   FROM Case 
                                   WHERE Brand__c = 'Milwaukee'][0];
        
        SpCreateShipmentReqDtoAup shipmentReqDto;
        Test.startTest();
            shipmentReqDto = SpShippingAndTrackingAup.createShipmentReqDto(claim, configFreightMap.get(getFreightConfigLabel(claim)));
        Test.stopTest();

        System.assert(shipmentReqDto != null, 'No instance of SpCreateShipmentReqDtoAup is found.');
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

    @IsTest
    static void testCreateAdhocPickup() {

        Map<String, String> responseHeaders = new Map<String, String> {
            'Content-Type' => 'application/json'
        };

        Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201, 
                                                                             'Created', 
                                                                             SpTestDataFactory.generateExpectedCreateAdhocPickupResponse(), 
                                                                             responseHeaders));

        SpCreateAdhocPickupReqDtoAup reqDto = SpTestDataFactory.generateCreateAdhocPickupRequest();

        Test.startTest();
            String resDto = SpShippingAndTrackingAup.createAdhocPickup('00673416', reqDto);
        Test.stopTest();

        SpCreateAdhocPickupResDtoAup response = (SpCreateAdhocPickupResDtoAup) SpCreateAdhocPickupResDtoAup.parse(resDto);
        List<SpCreateAdhocPickupResDtoAup.Adhoc_pickups> adhoc_pickups = response.adhoc_pickups;
        System.assertEquals('1234567', adhoc_pickups[0].booking_id, 'Booking Id does not match.');
    }

    @IsTest
    static void testCreateAdhocPickupReqDto() {

        SPGetShipmentResDtoAup resShipments = 
            (SPGetShipmentResDtoAup) SPGetShipmentResDtoAup.parse(SpTestDataFactory.generateExpectedGetShipmentResponse());

        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1];

        User newUser = new User(UserRoleId = portalRole.Id,
                                ProfileId = profId.Id,
                                Username = System.now().millisecond() + 'test23@test.com',
                                Alias = 'batman',
                                Email='bruce.wayne@ttibrands.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        insert newUser;

        Contact newContact = TTI_CommonUtilityClass.createContact();
        User serviceAgentUser;
        Account serviceAgentAcc;
        Contact serviceAgentContact;

        System.runAs(newUser) {
            insert newContact;

            serviceAgentAcc = TTI_CommonUtilityClass.createAccount();
            serviceAgentAcc.Name = 'Demo Account';
            serviceAgentAcc.Company_Code__c = 'BP01';
            serviceAgentAcc.Freight_Company__c = 'StarTrack';
            serviceAgentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();            
            insert serviceAgentAcc;

            serviceAgentContact = TTI_CommonUtilityClass.createContact();
            serviceAgentContact.AccountId = serviceAgentAcc.Id;
            serviceAgentContact.Phone = '+61465432198';
            serviceAgentContact.Email = 'Demo.Account@yopmail.com';
            insert serviceAgentContact;

            serviceAgentUser = TTI_CommonUtilityClass.createUser();
            serviceAgentUser.ContactId = serviceAgentContact.Id;
            serviceAgentUser.LastName = 'Account';
            serviceAgentUser.Email = 'Demo.Account@yopmail.com';
            serviceAgentUser.UserName = 'Demo.Account@yopmail.com';
            serviceAgentUser.TTI_SAP_Cust_No__c = '54321';
            insert serviceAgentUser;
        }

        System.runAs(serviceAgentUser) {
            Case caseObj = TTI_CommonUtilityClass.createCase('Milwaukee');
            caseObj.Service_Agent__c = serviceAgentAcc.Id;
            caseObj.AccountId = serviceAgentAcc.Id;
            caseObj.Diagnosed_User__c = serviceAgentUser.Id;
            caseObj.TTI_Freight_Out_PickUp_Address__c = '21 Kelletts Road';
            caseObj.TTI_Freight_Out_Pickup_State__c = 'VIC';
            caseObj.TTI_Freight_Out_Pickup_Postcode__c = '3178';
            caseObj.TTI_Freight_Out_Pickup_Suburb__c = 'Rowville';
            caseObj.TTI_Freight_Out_Delivery_Country__c = 'Australia';
            insert caseObj;
        }

        List<Case> caseRecs = [SELECT Id, 
                                      CaseNumber, 
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
                                      Contact.Account.TTI_SAP_Cust_No__c
                                 FROM Case];
        
        Service_Portal_Freight_Configuration__mdt config = [SELECT Account_Number__c,
                                                                    Brand__c,
                                                                    Carrier__c,
                                                                    Country__c,
                                                                    Product_Default_Height__c,
                                                                    Product_Default_Length__c,
                                                                    Product_Default_Weight__c,
                                                                    Product_Default_Width__c,
                                                                    Product_Minimum_Weight__c
                                                            FROM Service_Portal_Freight_Configuration__mdt][0];
        
        String jsonAdhocDets = '' +
            '{' +
            '   "Freight_Out_Manifest_Requested_Date__c": "2021-01-24",' +
            '   "Freight_Out_Manifest_Req_Win_Start__c": "06:00:00.000",' +
            '   "Freight_Out_Manifest_Req_Win_End__c": "22:00:00.000",' +
            '   "Freight_Out_Manifest_Pickup_Instructions__c": "tt"' +
            '}';

        Map<String,Object> adhocDetails = (Map<String,Object>) JSON.deserializeUntyped(jsonAdhocDets);

        SpCreateAdhocPickupReqDtoAup adhocPickupReqDto;
        Test.startTest();
            adhocPickupReqDto = SpShippingAndTrackingAup.createAdhocPickupReqDto(resShipments, caseRecs, config, adhocDetails);
        Test.stopTest();

        System.assert(adhocPickupReqDto != null, 'No instance of SpCreateAdhocPickupReqDtoAup is found.');

    }
}