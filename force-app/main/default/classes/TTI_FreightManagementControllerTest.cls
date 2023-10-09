/**
 * @File Name          : TTI_FreightManagementControllerTest.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 27/08/2019, 6:33:38 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author           Modification
 *==============================================================================
 * 1.0    26/08/2019, 2:05:48 PM   Francis Nasalita     Initial Version
**/
@IsTest
public with sharing class TTI_FreightManagementControllerTest {

    private static final String GET_ORDER_EXPECTED_ERROR_MESSAGE = 'An order with order id AP0000002422 cannot be found. Please check that the identifier is correct and submit the request again.';
    private static final String GET_SHIPMENT_EXPECTED_ERROR_MESSAGE = 'An order with shipment id 9lesEAOvOm4AAAFI3swaDRYB cannot be found. Please check that the identifier is correct and submit the request again.';
    public static final String GENERIC_ERROR = 'An unknown error has occured. Please contact your administrator.';
    private static final String GENERIC_CASE_ERROR = 'An unknown error has occured while updating the case. Please contact your administrator.';
    private static final String GET_ADHOCPICKUP_EXPECTED_ERROR_MESSAGE = 'The product ID ABC is not available';

    /**********************************************************************
    * @description             Initialize data
    */
    @TestSetup
    static void initTestData() {
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

        Product2 prod;
        Account serviceAgentAcc;
        Contact serviceAgentContact;
        User serviceAgentUser;
        System.runAs(newUser) {
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
            serviceAgentContact.Phone = '+61412345678';
            serviceAgentContact.Email = 'Demo.Account@yopmail.com';
            insert serviceAgentContact;

            serviceAgentUser = TTI_CommonUtilityClass.createUser();
            serviceAgentUser.ContactId = serviceAgentContact.Id;
            insert serviceAgentUser;

            // Create B2C Consumer Contact
            Account customerAccount = TTI_CommonUtilityClass.createB2CAccount('Jack', 'Codling', 'Milwaukee', 'Australia');
            customerAccount.PersonMobilePhone = '+61498765432';
            insert customerAccount;
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
            caseObj.SuppliedPhone = '+61432165497';
            caseObj.TTI_Freight_Out_Delivery_Postcode__c = '4500';
            caseObj.TTI_Freight_Out_Delivery_State__c = 'QLD';
            caseObj.TTI_Freight_Out_Delivery_Suburb__c = 'BRENDALE';
            caseObj.TTI_Freight_Out_Delivery_Address__c = '1 22-24 STRATHWYN ST';
            caseObj.TTI_Freight_Out_Delivery_Country__c = 'Australia';
            
            insert caseObj;
        }
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method checks if Case is updated successfully 
    *               after creating/updating a shipment from Freight Mgmt
    */
    @IsTest
    static void testUpdateCaseFreight() {

        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        Account serviceAgentAcc = [SELECT Id FROM Account WHERE Name = 'Demo Account'][0];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200'][0];
        Account customerAccount = [SELECT Id FROM Account WHERE Name = 'Jack Codling'][0];
                
        String jsonUpdatedCase;
        System.runAs(serviceAgentUser) {
            List<Case> listServiceReqCases = new List<Case>();
            for (Integer i = 0; i < 5; i++) {
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
                caseObj.TTI_Freight_Out_Delivery_Postcode__c = '4500';
                caseObj.TTI_Freight_Out_Delivery_State__c = 'QLD';
                caseObj.TTI_Freight_Out_Delivery_Suburb__c = 'BRENDALE';
                caseObj.TTI_Freight_Out_Delivery_Address__c = '1 22-24 STRATHWYN ST';
                caseObj.TTI_Freight_Out_Delivery_Country__c = 'Australia';
                caseObj.TTI_Freight_Out_Courier__c = 'test';
                caseObj.OrderId__c = '111Z50194414';
                caseObj.TTI_Freight_Out_Required__c = true;
                caseObj.Service_Request_Milestone__c = 'Closed';
                listServiceReqCases.add(caseObj);
            }

            insert listServiceReqCases;
            
            List<Case> listCases = (List<Case>) JSON.deserialize(TTI_FreightManagementController.getClaims('30', true), List<Case>.class);
            User currentUser = TTI_FreightManagementController.getCurrentUser();
            
            Case caseObj = listCases[0];
            caseObj.Brand__c = 'Milwaukee';

            Test.startTest();
            jsonUpdatedCase = TTI_FreightManagementController.updateCaseFreight(json.serialize(caseObj));
            Test.stopTest();
        }

        Case updatedCaseObj = (Case) json.deserialize(jsonUpdatedCase, Case.class);
        System.assertEquals('Milwaukee', updatedCaseObj.Brand__c, 'Brand should be Milwaukee.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on creating shipment,
    *               Checks if shipment Id is returned successfully.
    */
    @IsTest
    static void testCreateShipment() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        String shipmentId;
        System.runAs(serviceAgentUser) {
            Case claim = [SELECT Id, CaseNumber, SuppliedEmail, Contact.Phone, Contact.Email, TTI_Customer_Account__r.PersonMobilePhone, TTI_Service_Agent_Job_Number__c,
                                        Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Width__c, Product_Name__r.Weight__c,
                                        Service_Agent__r.Name, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c,
                                        TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Pickup_State__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_PickUp_Address__c,
                                        TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Address__c,
                                        FreightOutDeliverTo__c, Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Dangerous_Goods_Text__c
                                   FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedCreateShipmentsResponse(),
                                                                                responseHeaders));

            Test.startTest();
            shipmentId = TTI_FreightManagementController.createShipment(json.serialize(claim));
            Test.stopTest();
        }
        
        System.assert(String.isNotBlank(shipmentId), 'Should return shipment id.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on updating shipment,
    *               Checks if shipment Id is returned successfully.
    */
    @IsTest
    static void testUpdateShipment() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber, SuppliedEmail, Contact.Phone, Contact.Email, TTI_Customer_Account__r.PersonMobilePhone, TTI_Service_Agent_Job_Number__c,
                                        Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Width__c, Product_Name__r.Weight__c,
                                        Service_Agent__r.Name, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c,
                                        TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Pickup_State__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_PickUp_Address__c,
                                        TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Address__c,
                                        FreightOutDeliverTo__c, Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Dangerous_Goods_Text__c
                                   FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                                'OK',
                                                                                SpTestDataFactory.generateUpdateShipmentResponse(),
                                                                                responseHeaders));
            
            Test.startTest();
            TTI_FreightManagementController.updateShipment(json.serialize(claim), 't4AK0EhQTu4AAAFeVsxGqhLO');
            Test.stopTest();

            claim = [SELECT Shipment_Id__c, Freight_out_consignment_number__c FROM Case WHERE Id = :claim.Id];
        }
        
        System.assertEquals('t4AK0EhQTu4AAAFeVsxGqhLO', claim.Shipment_Id__c, 'Invalid shipment Id.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on deleting shipment.
    */
    @IsTest
    static void testDeleteShipment() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                '',
                                                                                responseHeaders));

            String delShipmentRes;
            Test.startTest();
            
            delShipmentRes = TTI_FreightManagementController.deleteShipment(claim.Id, 't4AK0EhQTu4AAAFeVsxGqhLO');
            Test.stopTest();

            System.assert(String.isNotBlank(delShipmentRes), 'Should return shipment Id.');
        }

        Case updatedClaim = [SELECT Shipment_Id__c, Label_Status__c, Label_Request_Id__c, Label_Url__c FROM Case WHERE Id = :claim.Id];
        System.assertEquals(null, updatedClaim.Shipment_Id__c, 'Shipment Id is not cleared.');
        System.assertEquals(null, updatedClaim.Label_Status__c, 'Label status is not cleared.');
        System.assertEquals(null, updatedClaim.Label_Request_Id__c, 'Label request id is not cleared.');
        System.assertEquals(null, updatedClaim.Label_Url__c, 'Label url is not cleared.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on generating a PDF Label,
    *               Case Label_Request_Id__c and Label_URL__c should be updated
    */
    @IsTest
    static void testCreateLabel() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedGetLabelResponse(),
                                                                                responseHeaders));

            Test.startTest();
            String createlabel = TTI_FreightManagementController.createLabel(json.serialize(claim), 't4AK0EhQTu4AAAFeVsxGqhLO', 'PDF');
            Test.stopTest();
        }

        Case updatedClaim = [SELECT Label_Request_Id__c FROM Case WHERE Id = :claim.Id];
        System.assertEquals('d9d1445d-cd1b-452d-9d68-29dbb3967acf', updatedClaim.Label_Request_Id__c, 'Invalid Label Request.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on retreiving Label from Case.Label_URL__c
    */
    @IsTest
    static void testGetLabel() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedGetLabelResponse(),
                                                                                responseHeaders));

            
            Test.startTest();
            String getLabel = TTI_FreightManagementController.getLabel(json.serialize(claim), 'd9d1445d-cd1b-452d-9d68-29dbb3967acf');
            Test.stopTest();
        }

        Case updatedClaim = [SELECT Label_Url__c, Label_Status__c FROM Case WHERE Id = :claim.Id];
        System.assertEquals('PENDING', updatedClaim.Label_Status__c, 'Label status is not PENDING.');
        System.assertEquals(null, updatedClaim.Label_Url__c, 'Label url have value.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on retreiving shipment
    */
    @IsTest
    static void testGetShipment() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        String shipmentObj;
        System.runAs(serviceAgentUser) {
            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedGetShipmentResponse(),
                                                                                responseHeaders));

            
            Test.startTest();
            shipmentObj = TTI_FreightManagementController.getShipment('9lesEAOvOm4AAAFI3swaDRYB');
            Test.stopTest();
        }
        System.assert(String.isNotEmpty(shipmentObj), 'Shipment object is empty.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on creating Order and updates Case Order_Id__c and Freight_Out_Manifest_Order_Number__c
    */
    @IsTest
    static void testCreateOrder() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];

        Case claim;
        String orderObj;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedCreateOrderResponse(),
                                                                                responseHeaders));

            
            Test.startTest();
            orderObj = TTI_FreightManagementController.createOrder(
                JSON.serialize(new List<String>{'gskK1UrUQPMAAAFSUuRKdt9Y'}),
                JSON.serialize(new List<String>{claim.CaseNumber}), 
                '00673416'
            );
            Test.stopTest();
        }
        System.assert(String.isNotEmpty(orderObj), 'Order object is empty.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks successful call on retreiving order
    */
    @IsTest
    static void testGetOrder() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        String getOrder;
        System.runAs(serviceAgentUser) {
            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedGetOrderResponse(),
                                                                                responseHeaders));
            
            Test.startTest();
            getOrder = TTI_FreightManagementController.getOrder('AP0000002422');
            Test.stopTest();
        }
        System.assert(String.isNotEmpty(getOrder), 'No order summary retrieved.');
    }

    /**
    * @author: Francis Nasalita
    * @date: 
    * @description: This test method mocks failure scenario on retreiving order
    */
    @IsTest
    static void testGetOrderNegative() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        
        System.runAs(serviceAgentUser) {
            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(400,
                                                                                'Bad Request',
                                                                                SpTestDataFactory.generateOrderErrorResponse(),
                                                                                responseHeaders));
                                                                                
            try {
                Test.startTest();
                String getOrder = TTI_FreightManagementController.getOrder('AP0000002422');
                Test.stopTest();
            } catch (AuraHandledException e) {
                TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
                System.assertEquals(GET_ORDER_EXPECTED_ERROR_MESSAGE, errorOb.errors[0].message, 'Get order successfully processed.');
            }
        }
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This test method checks if Dangerous goods form pdf is returned upon 
                    clicking the button in Freight Mgmt Screen
    */
    @IsTest
    static void testgetDGForm() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Case selectedCase = [SELECT Id, CaseNumber, Brand__c, Service_Agent__c, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c FROM Case LIMIT 1];
        selectedCase.Shipment_Id__c = 'FW0K0EQjTTEAAAFzdkcdb7gP';
        update selectedCase;
        
        String caseJson = Json.serialize(selectedCase);
        
        String blobResponse = 'JVBERi0xLjUKJeLjz9MKNCAwIG9iago8PC9Db2xvclNwYWNlL0RldmljZVJHQi9TdWJ0eXBlL0ltYWdlL0hlaWdodCA3M==';
        
        String getDGForm;
        String noShippingIdError;
        String noCaseError;
        String genericError;
        System.runAs(serviceAgentUser) {
            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(200,
                                                                                'OK',
                                                                                blobResponse,
                                                                                responseHeaders));
            
            Test.startTest();
            getDGForm = TTI_FreightManagementController.getDangerousGoodsForm(caseJson, selectedCase.Shipment_Id__c);            
            
            Test.stopTest();
        }
        System.assert(String.isNotEmpty(getDGForm), 'No Dangerous Goods form retrieved.');
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This test method checks if Dangerous goods form pdf is returned upon 
                    clicking the button in Freight Mgmt Screen
    */
    @IsTest
    static void testinvalidIpdateCaseFreightNoCase() {
        Test.startTest();
        try {
            TTI_FreightManagementController.updateCaseFreight('');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to update empty case
    */
    @IsTest
    static void testinvalidpdateCaseFreightFailedUpdate() {
        Test.startTest();
        try {
            TTI_FreightManagementController.updateCaseFreight(JSON.serialize(new Case()));
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_CASE_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();        
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to retrive an order without the order Id
    */
    @IsTest
    static void testinvalidGetOrder() {
        Test.startTest();
        try {
            TTI_FreightManagementController.getOrder('');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to retrive a shipment without the shipment Id
    */
    @IsTest
    static void testinvalidGetShipment() {
        Test.startTest();
        try {
            TTI_FreightManagementController.getShipment('');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to retrive a shipment due to a bad request
    */
    @IsTest
    static void testGetShipmentNegative() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        String shipmentObj;
        System.runAs(serviceAgentUser) {
            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(400,
                                                                                'Bad Request',
                                                                                SpTestDataFactory.generateShipmentErrorResponse(),
                                                                                responseHeaders));

            
            Test.startTest();
            try {
                shipmentObj = TTI_FreightManagementController.getShipment('9lesEAOvOm4AAAFI3swaDRYB');
            } catch (Exception e) {
                TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
                System.assertEquals(GET_SHIPMENT_EXPECTED_ERROR_MESSAGE, errorOb.errors[0].message, 'Get shipment successfully processed.');
            }
            Test.stopTest();
        }
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to create an order due to a bad request
    */
    @IsTest
    static void testCreateOrderNegative() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];

        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber FROM Case LIMIT 1];

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(400,
                                                                                'Bad Request',
                                                                                SpTestDataFactory.generateOrderErrorResponse(),
                                                                                responseHeaders));

            
            Test.startTest();
            
            try {
                String orderObj = TTI_FreightManagementController.createOrder(
                    JSON.serialize(new List<String>{'gskK1UrUQPMAAAFSUuRKdt9Y'}),
                    JSON.serialize(new List<String>{claim.CaseNumber}), 
                    '00673416'
                );
            } catch (Exception e) {
                TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
                System.assertEquals(GET_ORDER_EXPECTED_ERROR_MESSAGE, errorOb.errors[0].message, 'Create order successfully processed.');
            }
            
            Test.stopTest();
        }
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to create an order without shipment id, case# and customer#
    */
    @IsTest
    static void testinvalidCreateOrder() {
        Test.startTest();
        try {
            TTI_FreightManagementController.createOrder('', '', '');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to delete a shipment without case id and shipment id
    */
    @IsTest
    static void testinvalidDeleteShipment() {
        Test.startTest();
        try {
            TTI_FreightManagementController.deleteShipment('', '');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Case was updated successfully');
        }
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 25/08/2020
    * @description: This negative scenario throws an AuraException for trying to delete the shipment due to a bad request
    */
    @IsTest
    static void testNegativeDeleteShipment() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];

        Case claim;
        System.runAs(serviceAgentUser) {
            claim = [SELECT Id, CaseNumber FROM Case LIMIT 1];

            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };
            
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(400,
                                                                                'Bad Request',
                                                                                SpTestDataFactory.generateShipmentErrorResponse(),
                                                                                responseHeaders));

            Test.startTest();
            
            try {
                TTI_FreightManagementController.deleteShipment(claim.Id, 't4AK0EhQTu4AAAFeVsxGqhLO');
            } catch (AuraHandledException e) {
                TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
                System.assertEquals(GET_SHIPMENT_EXPECTED_ERROR_MESSAGE, errorOb.errors[0].message, 'Delete Shipment successfully processed.');
            }
            Test.stopTest();
        }
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 26/08/2020
    * @description: This test method checks if Contact record is updated upon creating a manifest
    */
    @IsTest
    static void testUpdateFreightContact() {
        Contact serviceAgentContact = [SELECT Id, Last_Manifested_Date__c FROM Contact LIMIT 1];
        
        Test.startTest();
        TTI_FreightManagementController.updateFreightContact(serviceAgentContact.Id);
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, Last_Manifested_Date__c FROM Contact WHERE Id = :serviceAgentContact.Id];
        System.assert(updatedContact.Last_Manifested_Date__c == System.today(), 'Last Manifested Date not updated.');
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 26/08/2020
    * @description: This test method checks if an AuraException is thrown when trying to update wrong record
    */
    @IsTest
    static void testUpdateFreightContactNegative() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];
        
        Test.startTest();
        try {
            TTI_FreightManagementController.updateFreightContact(serviceAgentUser.Id);
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Update Freight Contact successfully processed.');
        }
        
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 26/08/2020
    * @description: This test method checks if an AuraException is thrown when trying to update empty record
    */
    @IsTest
    static void testUpdateFreightContactNoContact() {
        Test.startTest();
        try {
            TTI_FreightManagementController.updateFreightContact('');
        } catch(Exception e) {
            TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
            System.assertEquals(GENERIC_ERROR, errorOb.errors[0].message, 'Update Freight Contact successfully processed.');
        }
        
        Test.stopTest();
    }

    /**
    * @author: Khrisna Elumba
    * @date: 29/01/2021
    * @description: This test method mocks successful call on creating adhoc pickup and updates the related fields in the Case
    */
    @IsTest
    static void testCreateAdhocPickup() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];

        List<String> caseNumbers = new List<String>();
        System.runAs(serviceAgentUser) {
            for (Case claim :[SELECT Id, CaseNumber FROM Case]) {
                caseNumbers.add(claim.CaseNumber);
            }

            String jsonAdhocDets = '' +
                '{' +
                '   "Freight_Out_Manifest_Requested_Date__c": "2021-01-01",' +
                '   "Freight_Out_Manifest_Req_Win_Start__c": "06:30:00.000",' +
                '   "Freight_Out_Manifest_Req_Win_End__c": "23:30:00.000",' +
                '   "Freight_Out_Manifest_Pickup_Instructions__c": "heavy items",' +
                '   "Freight_Out_Manifest_Order_Number__c": "TB00106718"' +
                '}';

            // Prepare the mocking class
            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };

            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(201,
                                                                                'OK',
                                                                                SpTestDataFactory.generateExpectedCreateAdhocPickupResponse(),
                                                                                responseHeaders));

            Test.startTest();
            String adhockPickups = TTI_FreightManagementController.createAdhocPickup(
                JSON.serialize(new List<String>{'gskK1UrUQPMAAAFSUuRKdt9Y'}),
                JSON.serialize(caseNumbers), 
                jsonAdhocDets
            );
            Test.stopTest();
        }

        for (Case claim :[SELECT CaseNumber, 
                                 Freight_Out_Booking_ID__c, 
                                 Freight_Out_Manifest_Req_Win_Start__c, 
                                 Freight_Out_Manifest_Req_Win_End__c, 
                                 Freight_Out_Manifest_Requested_Date__c, 
                                 Freight_Out_Manifest_Pickup_Instructions__c, 
                                 OrderId__c, 
                                 Freight_Out_Manifest_Order_Number__c
                            FROM Case 
                           WHERE CaseNumber IN :caseNumbers]) {

            String pickupDate = String.valueOf(claim.Freight_Out_Manifest_Requested_Date__c);
            String pickupStartTime = String.valueOf(claim.Freight_Out_Manifest_Req_Win_Start__c);
            String pickupEndTime = String.valueOf(claim.Freight_Out_Manifest_Req_Win_End__c);
            String pickupInstructions = String.valueOf(claim.Freight_Out_Manifest_Pickup_Instructions__c);
            String orderId = String.valueOf(claim.Freight_Out_Manifest_Order_Number__c);

            System.assertEquals('2021-01-01', pickupDate, 'Incorrect Date');
            System.assertEquals('heavy items', pickupInstructions, 'Incorrect Instructions');
            System.assertEquals('06:30:00.000Z', pickupStartTime, 'Incorrect Start Time');
            System.assertEquals('23:30:00.000Z', pickupEndTime, 'Incorrect End Time');
            System.assertEquals('1234567', claim.Freight_Out_Booking_ID__c, 'Incorrect Booking Id.');
            System.assertEquals('TB00106718', claim.OrderId__c, 'Incorrect Order Id');
            System.assertEquals('TB00106718', claim.Freight_Out_Manifest_Order_Number__c, 'Incorrect Order Number');
        }
    }

    /**
    * @author: Khrisna Elumba
    * @date: 29/01/2021
    * @description: This negative scenario throws an AuraException for an adhoc pickup of a product with an invalid product id
    */
    @IsTest
    static void testCreateAdhocPickupNegative() {
        User serviceAgentUser = [SELECT Id FROM User WHERE Username = 'teststandard@testing.com'][0];

        List<String> caseNumbers = new List<String>();
        System.runAs(serviceAgentUser) {
            for (Case claim :[SELECT Id, CaseNumber FROM Case]) {
                caseNumbers.add(claim.CaseNumber);
            }

            String jsonAdhocDets = '' +
                '{' +
                '   "Freight_Out_Manifest_Requested_Date__c": "2021-01-01",' +
                '   "Freight_Out_Manifest_Req_Win_Start__c": "06:30:00.000",' +
                '   "Freight_Out_Manifest_Req_Win_End__c": "23:30:00.000",' +
                '   "Freight_Out_Manifest_Pickup_Instructions__c": "heavy items"' +
                '}';

            Map<String, String> responseHeaders = new Map<String, String> {
                'Content-Type' => 'application/json'
            };

            Test.setMock(HttpCalloutMock.class, new SpShippingAndTrackingAupMock(400,
                                                                                'Bad Request',
                                                                                SpTestDataFactory.generateAdhocPickupErrorResponse(),
                                                                                responseHeaders));

            Test.startTest();
            try {
                String adhockPickups = TTI_FreightManagementController.createAdhocPickup(
                    JSON.serialize(new List<String>{'gskK1UrUQPMAAAFSUuRKdt9Y'}),
                    JSON.serialize(caseNumbers), 
                    jsonAdhocDets
                );
            } catch (Exception e) {
                TTI_FreightManagementController.AuraWrapperClass errorOb = (TTI_FreightManagementController.AuraWrapperClass) JSON.deserialize(e.getMessage(), TTI_FreightManagementController.AuraWrapperClass.class);
                System.assertEquals(GET_ADHOCPICKUP_EXPECTED_ERROR_MESSAGE, errorOb.errors[0].message, 'Adhoc pickup created successfully.');
            }
            Test.stopTest();
        }
    }
}