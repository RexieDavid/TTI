/**
 * @File Name          : TTI_ServiceRequestControllerTest.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 29/08/2019, 8:27:58 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    29/08/2019, 6:42:01 PM   Francis Nasalita     Initial Version
**/
@isTest
public class TTI_ServiceRequestControllerTest {

    public static final String GENERIC_ERROR = 'An unknown error has occured. Please contact your administrator.';
    private static final String GET_ORDER_EXPECTED_ERROR_MESSAGE = 'An order with order id AP0000002422 cannot be found. Please check that the identifier is correct and submit the request again.';
    
    /**
     * Create necessary data for test class
     */
    @testSetup
    static void initData() {
        
        List<SOHRAGStatus__c> newSOHRAGStatusesList = new List<SOHRAGStatus__c>();
        List<AutoApproval_Percentage__c> newAutoApprovalPercList = new List<AutoApproval_Percentage__c>();
        List<TTI_Replenishment_Line_Item__c> newRepLineItemsList = new List<TTI_Replenishment_Line_Item__c>();


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

        TTI_ServiceRequestController.getCurrentUser();

        Group newGroup = new Group(Name='group name', type='Queue');
        insert newGroup;
        QueuesObject newQueue = new QueueSObject(QueueID = newGroup.id, SobjectType = 'Case');
        insert newQueue;

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
            serviceAgentAcc.Delivery_Country__c = 'Australia';
            serviceAgentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();            
            insert serviceAgentAcc;

            serviceAgentContact = TTI_CommonUtilityClass.createContact();
            serviceAgentContact.AccountId = serviceAgentAcc.Id;
            serviceAgentContact.phone = '+614321654987';
            serviceAgentContact.Email = 'Demo.Account@yopmail.com';
            insert serviceAgentContact;

            serviceAgentUser = TTI_CommonUtilityClass.createUser();
            serviceAgentUser.ContactId = serviceAgentContact.Id;
            serviceAgentUser.LastName = 'Account';
            serviceAgentUser.Email = 'Demo.Account@yopmail.com';
            serviceAgentUser.UserName = 'Demo.Account@yopmail.com';
            serviceAgentUser.TTI_SAP_Cust_No__c = '54321';
            insert serviceAgentUser;

            // Create B2C Consumer Contact
            Account customerAccount = TTI_CommonUtilityClass.createB2CAccount('Jack', 'Codling', 'Milwaukee', 'Australia');
            customerAccount.PersonMobilePhone = '+61498765432';
            insert customerAccount;
            
            GST_Rates__c objGst = new GST_Rates__c();
            objGst.Name = 'Australia';
            objGst.GST_Rate__c = 10;
            objGst.Country__c = 'Australia';
            insert objGst;
            
            GST_Rates__c objGstNZ = new GST_Rates__c();
            objGstNZ.Name = 'New Zealand';
            objGstNZ.GST_Rate__c = 10;
            objGstNZ.Country__c = 'New Zealand';
            insert objGstNZ;
        
            TTI_Frieght_Company_API_Details__c objAPIDetial = new TTI_Frieght_Company_API_Details__c();
            objAPIDetial.name = 'TNT';
            objAPIDetial.Label_SOAP_Action_URL__c = '1234567';
            objAPIDetial.Label_End_Point_URL__c = 'qwertyui';
            insert objAPIDetial;
        }

        System.runAs(serviceAgentUser) {
            Case caseObj = TTI_CommonUtilityClass.createCase('Milwaukee');
            caseObj.Service_Agent__c = serviceAgentAcc.Id;
            caseObj.AccountId = serviceAgentAcc.Id;
            caseObj.Product_Name__c  = prod.Id;
            caseObj.TTI_Closed_Datetime__c = system.now() - 5;
            caseObj.Diagnosed_User__c = serviceAgentUser.Id;
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

            insert caseObj;
        }

        User newPortalUser = TTI_CommonUtilityClass.createUser();
        newPortalUser.ContactId = newContact.Id;
        insert newPortalUser;

        System.runAs(newUser) {
            Account newAccount = TTI_CommonUtilityClass.createAccount();
            newAccount.Name = 'Demo Account';
            newAccount.Company_Code__c = 'BP01';
            newAccount.Freight_Company__c = 'StarTrack';
            newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
            insert newAccount;

            TTI_queueid__c newTTIQueueId = new TTI_queueid__c();
            newTTIQueueId.Name = 'Warranty Service Request Approval';
            newTTIQueueId.id__c = newQueue.Id;
            insert newTTIQueueId;

            TTI_CommonUtilityClass.insertTemplates();  

            Product2 prod2 = new Product2(Name = 'Laptop X2000',
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
                                        Dangerous_Goods_Text__c = 'CLASS9'
            );
            insert prod2;

            Case newCase = TTI_CommonUtilityClass.createCase();
            newCase.Service_Agent__c = serviceAgentAcc.Id;
            newCase.AccountId = serviceAgentAcc.Id;
            newCase.Product_Name__c  = prod2.Id;
            newCase.Brand__c = 'Milwaukee';
            insert newCase;

            Attachment newAttachment = new Attachment();
            newAttachment.Name = 'Unit Test Attachment';
            newAttachment.Body= Blob.valueOf('Unit Test attachment body');
            newAttachment.ParentId = newCase.Id;
            insert newAttachment;

            ProductParts__c newProdParts = new ProductParts__c();
            newProdParts.ProductTool__c = prod2.Id;
            newProdParts.Quantity__c = 10;
            newProdParts.External_ID__c = 'QAst-123';
            insert newProdParts;

            Service_Request_Line_Item__c newServReqLineItem = new Service_Request_Line_Item__c();
            newServReqLineItem.Service_Request_Number__c = newCase.Id;
            newServReqLineItem.Part_Number__c = prod2.Id;
            newServReqLineItem.Order_Line_Category__c = 'Manual entry';
            newServReqLineItem.Order_Line_Type__c = 'Part';
            newServReqLineItem.Quantity__c = 1;
            insert newServReqLineItem;

            SOHRAGStatus__c newSOHRAGStatus = new SOHRAGStatus__c();
            newSOHRAGStatus.Name = 'AMBER';
            newSOHRAGStatus.MaxSOHRange__c = 50;
            newSOHRAGStatus.MinSOHRange__c = 11;
            newSOHRAGStatusesList.add(newSOHRAGStatus);
            insert newSOHRAGStatusesList;

            AutoApproval_Percentage__c newAutoApprovalPerc = new AutoApproval_Percentage__c();
            newAutoApprovalPerc.Name = 'Cost_Percentage';
            newAutoApprovalPerc.AutoApproval_Percentage__c = 80;
            newAutoApprovalPercList.add(newAutoApprovalPerc);
            newAutoApprovalPerc = new AutoApproval_Percentage__c();
            newAutoApprovalPerc.Name = 'SOH_Percentage';
            newAutoApprovalPerc.AutoApproval_Percentage__c = 60;
            newAutoApprovalPercList.add(newAutoApprovalPerc);
            insert newAutoApprovalPercList;

            TTI_Replenishment_Header__c newRepHeader = new TTI_Replenishment_Header__c();
            newRepHeader.TTI_Service_Agent__c = serviceAgentAcc.Id;
            newRepHeader.TTI_Status__c = 'Pending';
            insert newRepHeader;

            for(Integer counter = 0; counter < 10; counter++) {
                TTI_Replenishment_Line_Item__c newRepLineItem = new TTI_Replenishment_Line_Item__c();
                newRepLineItem.TTI_Replenishment_Header__c = newRepHeader.Id;
                newRepLineItem.TTI_SKU_Number__c = '0000-' + counter;
                newRepLineItem.TTI_Unit_Cost__c = 10;
                newRepLineItem.TTI_Quantity__c = 12;
                newRepLineItemsList.add(newRepLineItem);
            }
            insert newRepLineItemsList;
        }
    }
    
    /**
     * Fetch claims details
     */
    private static Case getClaim() {
        return [SELECT Id, CaseNumber, SuppliedEmail, Contact.Phone, Contact.Email, TTI_Customer_Account__r.PersonMobilePhone, TTI_Service_Agent_Job_Number__c,
                                        Product_Name__r.Height__c, Product_Name__r.Length__c, Product_Name__r.Width__c, Product_Name__r.Weight__c,
                                        Service_Agent__r.Name, Service_Agent__r.Company_Code__c, Service_Agent__r.Freight_Company__c, Brand__c,
                                        TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_Out_Pickup_State__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_PickUp_Address__c,
                                        TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Suburb__c, TTI_Freight_Out_Delivery_Address__c,
                                        FreightOutDeliverTo__c, Product_Name__r.SAP_MaterialNumber__c, Product_Name__r.Dangerous_Goods_Text__c
                                   FROM Case 
                                   WHERE Brand__c = 'Milwaukee'][0];
    }

    /**
     * Checks if case entered approval process
     */
    @isTest
    static void getApprovalProcessLastStepTest() {
        String approvalHistory;
        Case eCase = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c FROM Case LIMIT 1];
        eCase.Claim_Type__c = 'Warranty';
        eCase.Diagnosed_Date__c = Date.today();
        eCase.Manual_Approval_Reason__c = 'Manual Parts ordered';
        update eCase;

        //Add case to approval
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(eCase.Id);
        Approval.ProcessResult result = Approval.process(app);
        
        Test.startTest();
        approvalHistory = TTI_ServiceRequestController.getApprovalProcessLastStep(eCase.Id);
        Test.stopTest();
        System.assert(String.isNotBlank(approvalHistory), 'Case did not enter approval process');
    }

    /**
     * Checks if case did not enter approval process
     */
    @isTest
    static void getApprovalProcessLastStepNegativeTest() {
        String approvalHistory;
        User eUser = [SELECT Id FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Case eCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        System.runAs(eUser) {
            try{
                //Add case to approval
                Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
                app.setObjectId(eCase.Id);
                Approval.ProcessResult result = Approval.process(app);
                approvalHistory = TTI_ServiceRequestController.getApprovalProcessLastStep(eCase.Id);
            }catch(Exception ex) {}
        }
        Test.stopTest();
        System.assert(String.isBlank(approvalHistory), 'Case entered approval process');
    }

    /**
     * Fetch current user info details
     */
    @isTest
    static void getCurrentUserTest() {
        String userInfo;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Case eCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            userInfo = TTI_ServiceRequestController.getCurrentUser();
        }
        Test.stopTest();
        System.assert(userInfo.contains(eUser.Name), 'User info did not match on the running user');
    }

    /**
     * Fetch incompleted task 
     */
    @isTest
    static void getInCompletedTasksTest() {
        String result;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Case eCase = [SELECT Id FROM Case WHERE Brand__c = 'Milwaukee' LIMIT 1];
        
        Test.startTest();
        Task newTask = TTI_CommonUtilityClass.createTask();
        newTask.WhatId = eCase.Id;
        insert newTask;

        result = TTI_ServiceRequestController.getInCompletedTasks(eCase.Id);
        Test.stopTest();
        System.assert(String.isNotBlank(result), 'No incomplete task exist');
    }

    /** 
     * Fetch current user details
     */
    @isTest
    static void getUserTypeTest() {
        User resultUser;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            resultUser = TTI_ServiceRequestController.getUserType();
        }
        Test.stopTest();
        System.assertEquals(eUser.Id, resultUser.Id, 'User did not exist');
    }

    /**
     * Fetch SOHRAG Status custom setting
     */
    @isTest
    static void getSOHRAGStatusCustomSettingTest() {
        String result;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.getSOHRAGStatusCustomSetting();
        }
        Test.stopTest(); 
        System.assert(String.isNotBlank(result), 'SOHRAGStatuses does not exist');
    }

    /**
     * Submit claim/case for approval
     */
    @isTest
    static void submitForApprovalMethodTest() {
        String approvalHistory;
        Case eCase = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c FROM Case WHERE Brand__c = 'Milwaukee' LIMIT 1];
        eCase.Claim_Type__c = 'Warranty';
        eCase.Diagnosed_Date__c = Date.today();
        eCase.Manual_Approval_Reason__c = 'Manual Parts ordered';
        update eCase;

        Test.startTest();
        //Add case to approval
        TTI_ServiceRequestController.submitForApprovalMethod(eCase.Id);
        approvalHistory = TTI_ServiceRequestController.getApprovalProcessLastStep(eCase.Id);
        Test.stopTest();
        System.assert(String.isNotBlank(approvalHistory), 'Case did not enter approval process');
    }

    /**
     * Submit claim/case for invoice approval
     */
    @isTest
    static void submitInvoiceForApprovalMethodTest() {
        String approvalHistory;
        Case eCase = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c FROM Case LIMIT 1];
        eCase.Claim_Type__c = 'Warranty';
        eCase.Diagnosed_Date__c = Date.today();
        eCase.Manual_Approval_Reason__c = 'Manual Parts ordered';
        update eCase;

        Test.startTest();
        //Add case to approval
        TTI_ServiceRequestController.submitInvoiceForApprovalMethod(eCase.Id);
        approvalHistory = TTI_ServiceRequestController.getApprovalProcessLastStep(eCase.Id);
        Test.stopTest();
        System.assert(String.isNotBlank(approvalHistory), 'Case did not enter approval process');
    }

    /**
     * Save case record with line items
     */
    @isTest
    static void saveCaseButtonSaveTest() {
        String result;
        List<Case> eCase = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c 
                      FROM Case
                      WHERE Brand__c = 'Milwaukee'];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :eCase[1].Service_Agent__c LIMIT 1];
        List<Service_Request_Line_Item__c> eSvcReqLIsList = [SELECT Id, Service_Request_Number__c,
                                                                     Order_Line_Category__c, Order_Line_Type__c,
                                                                     Part_Number__c, Quantity__c
                                                              FROM  Service_Request_Line_Item__c 
                                                              WHERE Service_Request_Number__c = :eCase[1].Id];
        List<Service_Request_Line_Item__c> nSvcReqLIsList;
        nSvcReqLIsList = new List<Service_Request_Line_Item__c>{ eSvcReqLIsList.get(0).clone(false, false, false) };
        eCase[1].Claim_Type__c = 'Warranty';
        eCase[1].Diagnosed_Date__c = Date.today();
        eCase[1].Manual_Approval_Reason__c = 'Manual Parts ordered';
        eCase[1].Service_Request_Milestone__c = 'In Progress';

        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.saveCase(JSON.serialize(eCase[1]),
                                                            null,
                                                            null,
                                                            null,
                                                            JSON.serialize(eSvcReqLIsList),
                                                            JSON.serialize(nSvcReqLIsList),
                                                            'Save');

        }
        Test.stopTest();
        eCase = [SELECT Id, CaseNumber, (SELECT Id FROM Service_Request_Line_Items__r) FROM Case WHERE Id = :eCase[1].Id];
        System.assert(eCase[0] != NULL, 'Did not update case record');
        System.assert(!eCase[0].Service_Request_Line_Items__r.isEmpty(), 'Did not create service request line item');
    }

    /**
     * Save and mark as complete case record with line items
     */
    @isTest
    static void saveCaseMarkAsCompleteTest() {
        String result;
        List<Case> eCase = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c 
                      FROM Case 
                      WHERE Brand__c = 'Milwaukee'];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :eCase[1].Service_Agent__c LIMIT 1];
        List<Service_Request_Line_Item__c> eSvcReqLIsList = [SELECT Id, Service_Request_Number__c,
                                                                     Order_Line_Category__c, Order_Line_Type__c,
                                                                     Part_Number__c, Quantity__c
                                                              FROM  Service_Request_Line_Item__c 
                                                              WHERE Service_Request_Number__c = :eCase[1].Id];
        List<Service_Request_Line_Item__c> nSvcReqLIsList;
        nSvcReqLIsList = new List<Service_Request_Line_Item__c>{ eSvcReqLIsList.get(0).clone(false, false, false) };
        eCase[1].Claim_Type__c = 'Warranty';
        eCase[1].Diagnosed_Date__c = Date.today();
        eCase[1].Manual_Approval_Reason__c = 'Manual Parts ordered';
        eCase[1].Service_Request_Milestone__c = 'In Progress';

        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.saveCase(JSON.serialize(eCase[1]),
                                                            null,
                                                            null,
                                                            null,
                                                            JSON.serialize(eSvcReqLIsList),
                                                            JSON.serialize(nSvcReqLIsList),
                                                            'MarkAsComplete');

        }
        Test.stopTest();
        eCase = [SELECT Id,CaseNumber,(SELECT Id FROM Service_Request_Line_Items__r) FROM Case WHERE Claim_Type__c='Warranty' AND Service_Request_Milestone__c='In Progress'];
        System.assert(eCase[0] != NULL, 'Did not update case record');
        System.assert(!eCase[0].Service_Request_Line_Items__r.isEmpty(), 'Did not create service request line item');
    }

    /**
     * Fetch case field dependency
     */
    @isTest
    static void getFieldDependenciesTest() {
        Map<String, List<String>> fieldDendenciesMap = new Map<String, List<String>>();
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            fieldDendenciesMap = TTI_ServiceRequestController.getFieldDependencies('Case', 'Product_Payment_Category__c', 'Repair_Type__c');
        }
        Test.stopTest();
        System.assert(!fieldDendenciesMap.isEmpty(), 'Did not fetch field dependencies');
    }

    /**
     * Update replenishment header and save new replenishment line items
     */
    @isTest
    static void saveReplishmentHeaderAndSaveLineItemTest() {
        String result;
        List<TTI_Replenishment_Line_Item__c> newRepLineItemsList = new List<TTI_Replenishment_Line_Item__c>();
        TTI_Replenishment_Header__c eRepHeader = [SELECT Id, TTI_Status__c FROM TTI_Replenishment_Header__c LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        eRepHeader.TTI_Status__c = 'Submitted';

        for(Integer counter = 0; counter < 10; counter++) {
            TTI_Replenishment_Line_Item__c newRepLineItem = new TTI_Replenishment_Line_Item__c();
            newRepLineItem.TTI_Replenishment_Header__c = eRepHeader.Id;
            newRepLineItem.TTI_SKU_Number__c = '0000-' + counter;
            newRepLineItem.TTI_Unit_Cost__c = 10;
            newRepLineItem.TTI_Quantity__c = 12;
            newRepLineItemsList.add(newRepLineItem);
        }

        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.saveReplishmentHeaderAndItsLineItem(JSON.serialize(eRepHeader), JSON.serialize(newRepLineItemsList), null);
        }
        Test.stopTest();
        System.assertEquals(eRepHeader.Id,result, 'Did not update replenishment header');
    }

    /**
     * Update replenishment header and delete replenishment line items
     */
    @isTest
    static void saveReplishmentHeaderAndDeleteLineItemTest() {
        String result;
        TTI_Replenishment_Header__c eRepHeader = [SELECT Id, TTI_Status__c, (SELECT Id FROM Replenishment_Line_Items__r) FROM TTI_Replenishment_Header__c LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];

        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.saveReplishmentHeaderAndItsLineItem(JSON.serialize(eRepHeader), null,JSON.serialize(eRepHeader.Replenishment_Line_Items__r));
        }
        Test.stopTest();
        System.assertEquals(eRepHeader.Id,result, 'Did not update replenishment header');
    }

    /**
     * Fetch existing product parts for specific product
     */
    @isTest
    static void fetchBillOfMaterialsTest() {
        List<ProductParts__c> resultProdPartsList = new List<ProductParts__c>();
        Product2 eProd = [SELECT Id FROM Product2 WHERE Name = 'Laptop X2000']; 
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];

        Test.startTest();
        System.runAs(eUser) {
            resultProdPartsList = TTI_ServiceRequestController.fetchBillOfMaterials(eProd.Id);
        }
        Test.stopTest();
        System.assert(!resultProdPartsList.isEmpty(), 'No existing product parts for the listed product');
    }

    /**
     * Fetch replenishment header record
     */
    @isTest
    static void fetchReplenishmentRecordTest() {
        TTI_Replenishment_Header__c resRepHeader;
        TTI_Replenishment_Header__c eRepHeader = [SELECT Id FROM TTI_Replenishment_Header__c LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            resRepHeader = TTI_ServiceRequestController.fetchReplenishmentRecord(eRepHeader.Id);
        }
        Test.stopTest();
        System.assertEquals(eRepHeader.Id,resRepHeader.Id, 'Replenishment header did not exist');
    }

    /**
     * Fetch case record via filter
     */
    @isTest
    static void getCasedeatilsTest() {
        String result;
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.getCasedeatils('AccountId != NULL', 'Id');
        }
        Test.stopTest();
        System.assert(String.isNotBlank(result), 'Did not fetch any case records');
    }

    /**
     * Fetch attachment related to case
     */
    @isTest
    static void openReceiptPdfTest() {
        String result;
        List<Case> eCase = [SELECT Id FROM Case WHERE Brand__c = 'Milwaukee'];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestController.openReceiptPdf(eCase[1].Id);
        }
        Test.stopTest();
        System.assert(String.isNotBlank(result), 'Did not fetch any attachment records');
    }

    /**
     * Fetch HAWA products related to case record
     */
    @isTest
    static void serviceRequestHasHAWAProductsTest() {
        Boolean hasHAWAProduct = false;
        List<Case> eCase = [SELECT Id, CaseNumber FROM Case WHERE Brand__c = 'Milwaukee'];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            hasHAWAProduct = TTI_ServiceRequestController.serviceRequestHasHAWAProducts(eCase[1].CaseNumber);
        }
        Test.stopTest();
        System.assert(hasHAWAProduct, 'Case do not have HAWA Products');
    }
    
    /**
     * Calculate claim GST Rates
     */
    @isTest
    static void testCalculateGST() {
        Case caseObj = [SELECT Id, 
                               Claim_Type__c, 
                               Diagnosed_Date__c, 
                               Manual_Approval_Reason__c, 
                               CaseNumber, 
                               Service_Request_Milestone__c, 
                               Service_Agent__c,
                               Service_Agent__r.Delivery_Country__c
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        caseObj.Total_Sundry_Expenses__c = 100;
        update caseObj;

        String updatedCaseJSON;
        System.runAs(eUser) {
            Test.startTest();
            updatedCaseJSON = TTI_ServiceRequestController.calculateGST(JSON.serialize(caseObj));
            Test.stopTest();
        }

        caseObj = (Case) JSON.deserialize(updatedCaseJSON, Case.class);
        System.assertEquals(10.0, caseObj.Sundry_Expense_GST_Payable__c, 'Sundry expense GST payable is not 100');
    }
    
    /**
     * Checks if case/claim requires an attachment without a sundry expense
     */
    @isTest
    static void testIsAttachmentRequiredNoSundry() {
        List<Case> caseObj = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee'];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj[0].Service_Agent__c LIMIT 1];
        
        caseObj[0].Total_Sundry_Expenses__c = 0;
        update caseObj[0];        
        
        Boolean isAttachmentRequired;
        System.runAs(eUser) {
            Test.startTest();
            isAttachmentRequired = TTI_ServiceRequestController.isAttachmentRequired(JSON.serialize(caseObj[0]));
            Test.stopTest();
        }
        System.assertEquals(false, isAttachmentRequired, 'Attachment is required.');
    }
    
    /**
     * Checks if case/claim contains HAWA Products
     */
    @isTest
    static void testHasHAWAProducts() {
        Case caseObj = [SELECT Service_Agent__c, CaseNumber 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Laptop X2000' LIMIT 1];
        List<Id> productIds = new List<Id>();
        productIds.add(product.Id);
        
        System.runAs(serviceAgentUser) {
            Test.startTest();
                Boolean hasHAWA = TTI_ServiceRequestController.serviceRequestHasHAWAProducts(caseObj.CaseNumber);
            Test.stopTest();
        }
    }

    /**
     * Search a service request
     */
    @isTest
    static void testDoSearchServiceReq() {
        String result;
        Case caseObj = [SELECT CaseNumber, Service_Agent__c 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        System.runAs(serviceAgentUser) {
            Test.startTest();
            result = TTI_ServiceRequestController.doSearchServiceReq(caseObj.CaseNumber);
            Test.stopTest();
        }

        Case claim = ((List<Case>) JSON.deserialize(result, List<sObject>.class))[0];
        System.assertEquals(caseObj.CaseNumber, claim.CaseNumber, 'Case number does not match.');
    }
    
    /**
     * Checks if Job Summary was generated
     */
    @isTest
    static void testHandleEmailPart() {
        
        Case caseObj = [SELECT CaseNumber, Service_Agent__c, Completion_Date__c
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        caseObj.Completion_Date__c = Date.newInstance(System.today().Year(), System.today().month(), 1);
        update caseObj;

        System.runAs(serviceAgentUser) {
            Test.startTest();
            TTI_ServiceRequestController.handleEmailPart(caseObj.Id, 'JobSummaryGeneration');
            Test.stopTest();
        }

        Attachment jobSummary = [SELECT Id, ParentId, Name FROM Attachment WHERE Name = :caseObj.CaseNumber + '_Job_Summary.pdf'];
        System.assert(jobSummary != null, 'Job Summary was not created.');
    }
    
    /**
     * Generates PDF Label
     */
    @isTest
    static void testGenerateLabelPdfForAU() {
        String result;
        Case caseObj = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c, Freight_out_consignment_number__c 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        caseObj.Freight_out_consignment_number__c = '111Z50182202';
        update caseObj;
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        Test.startTest();
        result = TTI_ServiceRequestController.generateLabelPdfForAU(JSON.serialize(caseObj));
        Test.stopTest();
        
         System.assert(result != null, 'Failed to generate PDF Label');
    }
    
    /**
     * Checks if PDF fails to generate for unauthorized user
     */
   @isTest
    static void testGenerateLabelPdfForAUNegative() {
        String result;
        Case caseObj = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c, Freight_out_consignment_number__c 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        caseObj.Freight_out_consignment_number__c = '111Z50182202';
        update caseObj;
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        
        System.runAs(serviceAgentUser) {
            Test.startTest();
            try {
                result = TTI_ServiceRequestController.generateLabelPdfForAU(JSON.serialize(caseObj));
            } catch(Exception e) {
                TTI_Error_Log__c errorLog = [SELECT Id FROM TTI_Error_Log__c LIMIT 1];
                System.assert(errorLog != null, 'PDF Label was created');
            }
            Test.stopTest();
       }
        
    }
    
    /**
     * Submit claim
     */
    @isTest
    static void testSentFreightCompanyRequest() {
        String result;
        Case caseObj = [SELECT Id, Claim_Type__c, Diagnosed_Date__c, Manual_Approval_Reason__c, CaseNumber, Service_Request_Milestone__c, Service_Agent__c, Freight_out_consignment_number__c 
                          FROM Case
                         WHERE Brand__c = 'Milwaukee' LIMIT 1];
        caseObj.Freight_out_consignment_number__c = '111Z50182202';
        update caseObj;
        User serviceAgentUser = [SELECT Id, Name, AccountId FROM User WHERE AccountId = :caseObj.Service_Agent__c LIMIT 1];
        
        
        System.runAs(serviceAgentUser) {
            Test.startTest();
            try {
                result = TTI_ServiceRequestController.sendFreightCompanyRequest(caseObj.Id, 'SubmitClaim');
            } catch(Exception e) {
                TTI_Error_Log__c errorLog = [SELECT Id FROM TTI_Error_Log__c LIMIT 1];
                System.assert(errorLog != null, 'PDF Label was created');
            }
            Test.stopTest();
       }
    }
}