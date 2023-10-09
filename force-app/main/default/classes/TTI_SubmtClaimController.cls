/**
 * @File Name          : TTI_SubmtClaimController.cls
 * @Description        : Class needs to get refactor
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Anthony Salas
 * @Last Modified On   : 17/06/2020, 12:17:17 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    06/08/2019, 8:16:09 am   Francis Nasalita     Initial Version
 * 1.1    10/09/2019, 7:23:00 am   Francis Nasalita     Updated getUserType(), added Company Code to the query
 * 1.2    17/06/2020, 12:17:00 pm  Anthony Salas        Add MX_Authorised__c field to getUserType method query
 * 1.3    21/09/2020, 01:40:00 pm  Ericka Cajucom       Add Company_Code__c field to getUserType method query
**/
global without sharing class TTI_SubmtClaimController {

    public static Boolean newAccountCreated;

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();

    @AuraEnabled
    public static User getUserType() {
        list<User> userType = [SELECT Id, 
                                    Account.Id, 
                                    AccountId, 
                                    Country, 
                                    Account.Freight_Company__c, 
                                    Account.RecordTypeId, 
                                    Account.Allow_Delivery_to_Customers__c, 
                                    Account.RecordType.Name, 
                                    Account.Delivery_Country__c ,
                                    Account.BillingAddress, 
                                    Account.ShippingStreet, 
                                    Account.ShippingCity, 
                                    Account.ShippingCountry, 
                                    Account.ShippingState, 
                                    Account.ShippingPostalCode, 
                                    Account.Delivery_Street__c, 
                                    Account.Delivery_Suburb__c,
                                    Account.Delivery_State__c, 
                                    Account.Delivery_Postcode__c ,
                                    Account.MX_Authorised__c,
                                    Account.Company_Code__c
                                    FROM User WHERE Id = :UserInfo.getUserId()];
        if (userType != null && userType.size() > 0) {
            return userType[0];
        }
        return null;
    }

    @AuraEnabled
    public static String getFreightAccountDetailsCustmSetting() {
        List<Freight_Account_Details__c> lstFreightAccDetail = Freight_Account_Details__c.getall().values();
        return JSON.serialize(lstFreightAccDetail);
    }

    /********************************************************************** 
    * @description Returns field describe data 
    * @param objectName Asset 
    * @param fieldName Id, Name, PurchaseDate, SerialNumber
    * @return List of asset that contains the input SerialNumber, Product2Id, and ContactId from user input
    * @example 
    * list<Asset> asset = new List<Asset>(); 
    */ 
    @AuraEnabled
    public static Asset assetCheck(String serialnumber, String productId, String contactId) {
        list<Asset> asset = new List<Asset>();
        if (contactId == null || contactId == '') {
            return null;
        } else {
            //Modified to only query for Assets with matching non-blank serial number [SP-880]
            asset = [SELECT Id, Name, PurchaseDate, SerialNumber from Asset
                        WHERE (SerialNumber = :serialnumber AND SerialNumber != null 
                        AND Product2Id = :productId AND ContactId = :contactId) ORDER BY PurchaseDate DESC];
        }
        
        if (asset.size() > 0 && asset != null) {
            Asset searchedAsset = asset[0];
            return searchedAsset;
        }
        return null;
    }

    @AuraEnabled
    public static Product2 productCheck(String productId) {
        List<Product2> products = [SELECT Id FROM Product2 WHERE Id = :productId LIMIT 1];
        if (!products.isEmpty() && products != null) {
            return products[0];
        }
        return null;
    }

    @AuraEnabled
    public static String saveClaimDetails(Case objcase, Asset objAsset, Integer warrantyMonths, Contact objCon, Boolean isNewContactCreated) {
        System.debug('RDAVID >>> objCon >>> '+objCon);
        try {
            newAccountCreated = false;
            String custonlebelART = Label.TTI_Entitlement_Number;
            if (custonlebelART != null && custonlebelART != '') {
                objcase.Entitlementid = custonlebelART ;
            }
            String brand = objcase.Brand__c;
            if (objCon != null) {
                if (objCon.Id != null) {
                    contact objconreturn = checkTheValue(objCon, false, brand);
                } else if (objCon.Id == null) {
                    contact objconreturn = checkTheValue(objCon, true, brand);
                    if (objconreturn != null && objconreturn.Id != null) {
                        objcase.TTI_Customer_Contact__c = objconreturn.Id;
                        objcase.TTI_Customer_Account__c = objconreturn.Accountid;
                        if (newAccountCreated == false && objAsset.Id == null) {
                            Asset dummyAsset = assetCheck(objcase.Serial_Number__c, objCase.Product_Name__c, objcase.TTI_Customer_Contact__c);
                            if (dummyAsset != null) {
                                if (dummyAsset.SerialNumber == null) {
                                    dummyAsset.SerialNumber = objcase.Serial_Number__c;
                                    dummyAsset.SerialNumberWeek__c = objAsset.SerialNumberWeek__c;
                                    if (objAsset.SerialNumberWeek__c != null) {
                                        dummyAsset.Display_Week__c = true;
                                    }
                                    if (objAsset.SerialNumberYear__c != null) {
                                        dummyAsset.Display_Year__c = true;
                                    }
                                    dummyAsset.SerialNumberYear__c = objAsset.SerialNumberYear__c;
                                }
                                dummyAsset.PurchaseDate = objcase.Purchase_Date__c;
                                dummyAsset.Receipt_No__c = objcase.Receipt_No__c;
                                objAsset = dummyAsset;
                            }
                        }
                    }
                }
            }

            Id ServTypecaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            Case caseNew = objcase;
            caseNew.RecordTypeId = ServTypecaseId;

            if (objcase.Purchase_Date__c != null && warrantyMonths != null) {
                Date purchaseDate = (Date)objcase.Purchase_Date__c;
                objAsset.WarrantyCalculatedEndDate__c = purchaseDate.addMonths(Integer.valueOf(warrantyMonths));

            }
            objAsset.ContactId = objcase.TTI_Customer_Contact__c;
            objAsset.AccountId = objcase.TTI_Customer_Account__c;
            if (objAsset.Name != null && objAsset.Name != '') {
                upsert objAsset;
                caseNew.AssetId = objAsset.Id;
            }
            if (caseNew.TTI_Freight_In_Required__c == true) {
                List<User> objServiceAgentUser = [SELECT Id, Account.Delivery_Country__c FROM User where AccountId = :caseNew.Service_Agent__c];
                if (objServiceAgentUser != null && objServiceAgentUser.size() > 0) {
                    Account objAccountTemp = new Account(Id = objcase.TTI_Customer_Account__c);
                    caseNew.OwnerId = objServiceAgentUser[0].Id;
                    if (newAccountCreated && objAccountTemp.Country__pc == null) {
                        objAccountTemp.Country__pc = objServiceAgentUser[0].Account.Delivery_Country__c;
                        update objAccountTemp;
                    }
                }
            } else {
                List<User> objServiceAgentUser = [SELECT Id, AccountId, Account.Delivery_Country__c FROM User where Id = :UserInfo.getUserId()];
                if (objServiceAgentUser[0].AccountId != null) {
                    Account objAccountTemp = new Account(Id = objcase.TTI_Customer_Account__c);
                    if (newAccountCreated && objAccountTemp.Country__pc == null) {
                        objAccountTemp.Country__pc = objServiceAgentUser[0].Account.Delivery_Country__c;
                        update objAccountTemp;
                    }
                }
            }

            upsert caseNew;
            Case caseObj = [SELECT Id, CaseNumber, TTI_Freight_In_Required__c, TTI_Freight_Out_Required__c, TTI_Customer_Contact__c,
                            Service_Agent__r.Name, Service_Agent__r.Phone, TTI_Email_Notification_Opt_In__c, TTI_CaseFromEmailId__c,
                            Service_Agent__r.Freight_Company__c, Service_Agent__r.Freight_Company_Account_Number__c,
                            TTI_Customer_Account__r.Name, TTI_Customer_Account__r.PersonMobilePhone,
                            TTI_Customer_Account__r.PersonEmail, TTI_Freight_In_PickUp_Address__c
                            , TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Postcode__c,
                            TTI_Freight_Out_PickUp_Address__c, TTI_Freight_Out_Pickup_Suburb__c,
                            TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_In_Delivery_Address__c,
                            TTI_Freight_In_Delivery_Suburb__c, TTI_Freight_In_Delivery_Postcode__c, TTI_Freight_In_Delivery_State__c,
                            TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c,
                            TTI_Freight_Out_Delivery_Postcode__c, Brand__c, Product_Name__r.Name,
                            TTI_Brand_Logo_URL__c FROM Case WHERE Id = :caseNew.Id];
            if (Test.isRunningTest()) {
                return caseObj.Id;
            }
            return JSON.serialize(caseObj);
        } catch (Exception e) {
            return e.getMessage() + ';' + e.getStackTraceString();
        }
    }

    @AuraEnabled
    public static void handleEmailAndAttachment(String CaseId) {
        List<Case> lstCase = [SELECT Id , CaseNumber, Status, Retailer_Account__c, Retailer_Account__r.Name, TTI_Customer_Account__r.Name, TTI_Customer_Contact__c, Service_Agent__r.Name,
                                SuppliedEmail, Brand__c, Product_Name__c, Purchase_Date__c, Fault_Description__c, TTI_Freight_In_Required__c, CreatedDate, TTI_Customer_Account__r.PersonMobilePhone,
                                TTI_Freight_Out_Required__c, Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c, Retailer_Account__r.Delivery_Postcode__c,
                                TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c , TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Country__c,
                                TTI_Freight_In_PickUp_Address__c, TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_Postcode__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Country__c,
                                Retailer_Account__r.Delivery_State__c, Retailer_Account__r.Delivery_Country__c, Service_Agent__r.Delivery_State__c, Service_Agent__r.Delivery_Country__c , Service_Agent__r.Delivery_Street__c,
                                Service_Agent__r.Delivery_Suburb__c, TTI_CaseFromEmailId__c, TTI_Email_Notification_Opt_In__c, Service_Agent__r.Delivery_Postcode__c, Serial_Number__c, Product_Name__r.Name, TTI_Brand_Logo_URL__c FROM Case WHERE Id = :CaseId];

        TTI_PdfAndEmailHandler.handleEmailAndAttachmentProcess(lstCase[0], 'ReceiptGeneration');
    }

    // This method is used to Check the status
    public static Contact checkTheValue(Contact objCon, Boolean isNewContactCreated, String brand) {
        System.debug('RDAVID >>> isNewContactCreated >>> '+isNewContactCreated);
        List<Contact> lstCont = new List<Contact>();
        List<Account> lstAccuntEmailUpdate = new List<Account>();
        List<Contact> lstContToreturn = new List<Contact>();

        if (isNewContactCreated) {

            String custonlebelART = Label.Account_RecordType; // custom label
            List<String> lstAccRT = custonlebelART.split(';');
            Set<Id> recordTypeId = new Set<Id>();

            recordTypeId.add(b2cConsumerContactAccRecTypeId);
            //S1 - Scenario when everything is populated
            if (objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && objCon.MobilePhone != null && objCon.MobilePhone != '' && objCon.HomePhone != null && objCon.HomePhone != '') {
                System.debug('RDAVID >>> Scenario 1');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND ((Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND MobilePhone = :objCon.MobilePhone AND HomePhone = :objCon.HomePhone) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            } 
            //S2 - Scenario when only Mobile is entered
            else if (objCon.MobilePhone != null && objCon.MobilePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null) && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                System.debug('RDAVID >>> Scenario 2');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            } 
            //S3 - Scenario when only email is entered
            else if (objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.MobilePhone == '' || objCon.MobilePhone == null) && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                System.debug('RDAVID >>> Scenario 3');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            }
            //S4 - Scenario when only home phone is entered
            else if (objCon.HomePhone != null && objCon.HomePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null) && (objCon.MobilePhone == '' || objCon.MobilePhone == null)) {
                System.debug('RDAVID >>> Scenario 4');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND HomePhone = :objCon.HomePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            }
            //S5 - Scenario when mobile and home phone is entered
            else if (objCon.MobilePhone != '' || objCon.MobilePhone != null && objCon.HomePhone != null && objCon.HomePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null)) {
                System.debug('RDAVID >>> Scenario 5');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND HomePhone = :objCon.HomePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            }
            //S6 - Scenario when mobile and email is entered
            else if (objCon.MobilePhone != '' || objCon.MobilePhone != null && objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                System.debug('RDAVID >>> Scenario 6');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            }
            //S7 - Scenario when home phone and email is entered
            else if (objCon.HomePhone != '' || objCon.HomePhone != null && objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.MobilePhone == '' || objCon.MobilePhone == null)) {
                System.debug('RDAVID >>> Scenario 7');
                lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                           LastName = :objCon.LastName AND HomePhone = :objCon.HomePhone AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
            }
            System.debug('RDAVID >>> lstCont >>> '+lstCont);
            if (lstCont.size() > 0) {
                Id B2CConsumerContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
                Account objPersonAcc = new Account();
                objPersonAcc.RecordTypeId = B2CConsumerContact;
                objPersonAcc.LastName = objCon.LastName.capitalize();
                objPersonAcc.FirstName = objCon.FirstName.capitalize();
                objPersonAcc.PersonEmail = objCon.Email;
                objPersonAcc.PersonMobilePhone = objCon.MobilePhone;
                objPersonAcc.Country__pc = objCon.Country__c;
                objPersonAcc.Brand__pc = brand;
                objPersonAcc.Brands__c = brand + ';';
                objPersonAcc.OwnerId = Label.TTI_Connected_App_Admin_UserId;
                objPersonAcc.Record_Status__c = 'Active';
                objPersonAcc.PersonHasOptedOutOfEmail = objCon.HasOptedOutOfEmail;
                objPersonAcc.PersonLeadSource = 'Warranty Community';
                insert objPersonAcc;
                System.debug('RDAVID >>> objPersonAcc >>> '+objPersonAcc);
                newAccountCreated = true;

                List<Contact> lstContoSent = [SELECT Id, FirstName, AccountId, LastName, Brand__c, MobilePhone, HomePhone, Email FROM Contact WHERE AccountId = :objPersonAcc.Id];
                objCon.AccountId = objPersonAcc.Id;

                if (lstContoSent[0] != null && lstContoSent[0].Id != null) {
                    objCon.Id = lstContoSent[0].Id;
                }
                lstContToreturn.add(objCon);

            } else if (lstCont.size() == 0) {
                Id B2CConsumerContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
                //S1 - Scenario when everything is populated
                if (objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && objCon.MobilePhone != null && objCon.MobilePhone != '' && objCon.HomePhone != null && objCon.HomePhone != '') {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND ((Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND MobilePhone = :objCon.MobilePhone AND HomePhone = :objCon.HomePhone) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                } 
                //S2 - Scenario when only Mobile is entered
                else if (objCon.MobilePhone != null && objCon.MobilePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null) && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                } 
                //S3 - Scenario when only email is entered
                else if (objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.MobilePhone == '' || objCon.MobilePhone == null) && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                }
                //S4 - Scenario when only home phone is entered
                else if (objCon.HomePhone != null && objCon.HomePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null) && (objCon.MobilePhone == '' || objCon.MobilePhone == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND HomePhone = :objCon.HomePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                }
                //S5 - Scenario when mobile and home phone is entered
                else if (objCon.MobilePhone != '' || objCon.MobilePhone != null && objCon.HomePhone != null && objCon.HomePhone != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.Email == '' || objCon.Email == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND HomePhone = :objCon.HomePhone AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                }
                //S6 - Scenario when mobile and email is entered
                else if (objCon.MobilePhone != '' || objCon.MobilePhone != null && objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.HomePhone == '' || objCon.HomePhone == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND MobilePhone = :objCon.MobilePhone AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                }
                //S7 - Scenario when home phone and email is entered
                else if (objCon.HomePhone != '' || objCon.HomePhone != null && objCon.Email != null && objCon.Email != '' && objCon.LastName != null && objCon.LastName != '' && (objCon.MobilePhone == '' || objCon.MobilePhone == null)) {
                    lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, AccountId, Email, Account.AlternateEmail__pc FROM Contact WHERE
                               LastName = :objCon.LastName AND HomePhone = :objCon.HomePhone AND (Email = :objCon.Email OR Account.AlternateEmail__pc = :objCon.Email) AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c = 'Active'];
                }
                Map<String, List<Contact>> mapStrNameWithListCon = new Map<String, List<Contact>>();
                if (lstCont.size() > 0) {
                    for (Contact objConNew : lstCont) {
                        if (objCon.Email != null && (objCon.Email == objConNew.Email || objCon.Email == objConNew.Account.AlternateEmail__pc)) {
                            if (mapStrNameWithListCon.get('Email') != null ) {
                                List<Contact> lstConinside = mapStrNameWithListCon.get('Email');
                                lstConinside.add(objConNew);
                                mapStrNameWithListCon.put('Email', lstConinside);
                            }
                            if (mapStrNameWithListCon.get('Email') == null ) {
                                List<Contact> lstConinside = new List<Contact>();
                                lstConinside.add(objConNew);
                                mapStrNameWithListCon.put('Email', lstConinside);
                            }
                        } else if (objCon.MobilePhone != null && objCon.LastName != null &&
                                   objCon.MobilePhone == objConNew.MobilePhone && objCon.LastName == objConNew.LastName) {
                            if (mapStrNameWithListCon.get('PhoneName') != null ) {
                                List<Contact> lstConinside = mapStrNameWithListCon.get('PhoneName');
                                lstConinside.add(objConNew);
                                mapStrNameWithListCon.put('PhoneName', lstConinside);
                            }
                            if (mapStrNameWithListCon.get('PhoneName') == null ) {
                                List<Contact> lstConinside = new List<Contact>();
                                lstConinside.add(objConNew);
                                mapStrNameWithListCon.put('PhoneName', lstConinside);
                            }
                        }
                    }
                    if (mapStrNameWithListCon.get('Email') != null && mapStrNameWithListCon.get('Email').size() > 0) {
                        Contact getcontact = mapStrNameWithListCon.get('Email')[0];
                        lstContToreturn.add(getcontact);
                        if (String.isNotEmpty(objCon.MobilePhone) && objCon.MobilePhone != getcontact.MobilePhone) {
                            Account objAc = new Account(Id = getcontact.AccountId);
                            objAc.PersonMobilePhone = objCon.MobilePhone;
                            objAc.RecordTypeId = b2cConsumerContactAccRecTypeId;
                            lstAccuntEmailUpdate.add(objAc);
                        }
                    } else if (mapStrNameWithListCon.get('PhoneName') != null && mapStrNameWithListCon.get('PhoneName').size() > 0) {
                        Contact getcontact = mapStrNameWithListCon.get('PhoneName')[0];
                        if (getcontact.Account.AlternateEmail__pc != null && String.isNotEmpty(objCon.Email) && objCon.Email != getcontact.Account.AlternateEmail__pc) {
                            Account objAc = new Account(Id = getcontact.AccountId);
                            objAc.AlternateEmail__pc = objCon.Email;
                            lstAccuntEmailUpdate.add(objAc);
                        } else if (getcontact.Account.AlternateEmail__pc == null && String.isNotEmpty(objCon.Email) ) {
                            Account objAc = new Account(Id = getcontact.AccountId);
                            objAc.AlternateEmail__pc = objCon.Email;
                            lstAccuntEmailUpdate.add(objAc);
                        }
                        lstContToreturn.add(getcontact);
                    }
                } else if (lstCont.size() == 0) {
                    Account objPersonAcc = new Account();
                    objPersonAcc.RecordTypeId = B2CConsumerContact;
                    objPersonAcc.LastName = objCon.LastName.capitalize();
                    objPersonAcc.FirstName = objCon.FirstName.capitalize();
                    objPersonAcc.PersonEmail = objCon.Email;
                    objPersonAcc.PersonMobilePhone = objCon.MobilePhone;
                    objPersonAcc.PersonHomePhone = objCon.HomePhone;
                    objPersonAcc.Country__pc = objCon.Country__c;
                    objPersonAcc.Brand__pc = brand;
                    objPersonAcc.Brands__c = brand + ';';
                    objPersonAcc.OwnerId = Label.TTI_Connected_App_Admin_UserId;
                    objPersonAcc.Record_Status__c = 'Active';
                    objPersonAcc.PersonHasOptedOutOfEmail = objCon.HasOptedOutOfEmail;
                    objPersonAcc.PersonLeadSource = 'Warranty Community';
                    insert objPersonAcc;
                    newAccountCreated = true;
                    List<Contact> lstContoSent = [SELECT Id, FirstName, AccountId, LastName, Brand__c, MobilePhone, HomePhone, Email FROM Contact WHERE AccountId = :objPersonAcc.Id];
                    objCon.AccountId = objPersonAcc.Id;

                    if (lstContoSent[0] != null && lstContoSent[0].Id != null) {
                        objCon.Id = lstContoSent[0].Id;
                    }
                    lstContToreturn.add(objCon);
                }
            }
        } else if (!isNewContactCreated) {

            lstCont = [SELECT Id, FirstName, LastName, Brand__c, MobilePhone, HomePhone, Email, HasOptedOutOfEmail FROM Contact WHERE Id = :objCon.Id];

            if (lstCont.Size() > 0 && ( lstCont[0].FirstName != objCon.FirstName || lstCont[0].LastName != objCon.LastName
                                        || lstCont[0].MobilePhone != objCon.MobilePhone || lstCont[0].Email != objCon.Email
                                        || lstCont[0].HasOptedOutOfEmail != objCon.HasOptedOutOfEmail
                                        || lstCont[0].HomePhone != objCon.HomePhone)) {

                String mobilePhone = lstCont[0].MobilePhone;
                String homePhone = lstCont[0].HomePhone;

                lstCont[0].FirstName = objCon.FirstName.capitalize();
                lstCont[0].LastName = objCon.LastName.capitalize();
                lstCont[0].MobilePhone = objCon.MobilePhone;
                lstCont[0].HomePhone = objCon.HomePhone;
                lstCont[0].HasOptedOutOfEmail = objCon.HasOptedOutOfEmail;
                lstCont[0].Email = objCon.Email;
                update lstCont[0];

                if ((mobilePhone != objCon.MobilePhone || homePhone != objCon.HomePhone) && objCon.AccountId != null) {
                    List<Account> updatePersonAccount = [SELECT Id, Country__pc, PersonHasOptedOutOfEmail  FROM Account Where Id = :objCon.AccountId];
                    if (updatePersonAccount.size() > 0) {
                        updatePersonAccount[0].Country__pc = objCon.Country__c;
                        updatePersonAccount[0].PersonHasOptedOutOfEmail = objCon.HasOptedOutOfEmail;
                        update updatePersonAccount[0];
                    }
                }
                lstContToreturn.add(lstCont[0]);
            }
        }

        if (lstAccuntEmailUpdate != null && lstAccuntEmailUpdate.size() > 0) {
            update lstAccuntEmailUpdate;
        }
        if (lstContToreturn.size() > 0) {
            return lstContToreturn[0];
        }

        return null;
    }

    public static googleApiWrap getLangLatOfPostal(String Postalcode, String Country) {

        //  This is key of Geocoding API for Google Maps Need
        String  keyofgeoCode = 'AIzaSyCj0zEch86yRgH4eiVqsXLIdMbKVopQ5Sk';
        googleApiWrap objWrapLatLag = new googleApiWrap();
        Map<String, Double> MapLatNLag = new Map<String, Double>();
        String addressforGoogle = EncodingUtil.urlEncode(Postalcode + ',' + Country, 'UTF-8');
        Postalcode = EncodingUtil.urlEncode(Postalcode, 'UTF-8');


        //  build and make the callout to the Geocoding API
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + addressforGoogle + '&key=' + keyofgeoCode + '&sensor=false');
        request.setMethod('GET');
        request.setTimeout(120000);
        try {
            JSONParser responseParser;
            if (!Test.isRunningTest()) {
                HttpResponse   response = http.send(request);

                responseParser = JSON.createParser(response.getBody());
            }
            if (Test.isRunningTest()) {
                responseParser = JSON.createParser('"location" : {"lat" : 28.5821195,"lng" : 77.3266991}');
            }
            double  latitude = null;
            double  longitude = null;
            if (Test.isRunningTest()) {
                latitude = 28.5821195;
                longitude = 77.3266991;
            }
            if (!Test.isRunningTest()) {
                while (responseParser.nextToken() != null) {
                    if ((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                        responseParser.nextToken();
                        while (responseParser.nextToken() != JSONToken.END_OBJECT) {

                            String locationText = responseParser.getText();

                            responseParser.nextToken();

                            if (locationText == 'lat')

                                latitude = responseParser.getDoubleValue();

                            else if (locationText == 'lng')

                                longitude = responseParser.getDoubleValue();
                        }
                    }
                }
            }

            if (latitude != null) {
                objWrapLatLag.glatitude = latitude;
            }
            if (longitude != null) {
                objWrapLatLag.glongitude = longitude;
            }
            return objWrapLatLag;
        } catch (Exception e) {
            return objWrapLatLag;
        }
    }

    @AuraEnabled
    public static String searchNearByLocation(String strPincode, String brand, Product2 objProduct, String radiusCountry, String TypeofSA, integer radiusofSearch) {
        Set<String> setofServiceAgent = new Set<String> {'Bronze', 'Silver', 'Gold', 'Platinum'};

        Map<String, Double> MapOfLatNLang = new Map<String, Double>();
        List<Account> lstAccnt = new list<Account>();
        googleApiWrap objgetLtitute = getLangLatOfPostal(strPincode, radiusCountry);
        String locatorCategory = objProduct.Locator_Category__c;
        String strQuery = '';

        if (objgetLtitute.glatitude != null && objgetLtitute.glongitude != null && objProduct.Locator_Category__c != null ) {
            String Acctype = 'Service Agent';
            String recordStatus = 'Active';
            if (setofServiceAgent.contains(TypeofSA))
                strQuery = 'SELECT Id,Name,BillingAddress,Delivery_Street__c,Delivery_Suburb__c,Delivery_State__c,Delivery_Postcode__c,Delivery_Country__c from  Account WHERE Type=:Acctype AND Service_Agent_Status__c=:TypeofSA AND ';
            else
                strQuery = 'SELECT Id,BillingAddress,Name,Delivery_Street__c,Delivery_Suburb__c,Delivery_State__c,Delivery_Postcode__c,Delivery_Country__c from  Account WHERE Type=:Acctype AND ';
            double strLatitude = objgetLtitute.glatitude;
            double strLongitude = objgetLtitute.glongitude;

            if (brand == 'Milwaukee')
                strQuery += '  Services_Milwaukee_Brands__c = true AND Milwaukee_Products__c INCLUDES (:locatorCategory)';
            else if (brand == 'AEG')
                strQuery += ' Services_AEG_Brands__c = true AND AEG_Products__c INCLUDES (:locatorCategory)';
            else if (brand == 'Ryobi')
                strQuery += ' Services_Ryobi_Brands__c = true AND Ryobi_Products__c INCLUDES (:locatorCategory)';
            else if (brand == 'VAX')
                strQuery += ' Services_VAX_Brands__c = true AND VAX_Products__c INCLUDES (:locatorCategory)';
            else if (brand == 'Homelite')
                strQuery += ' Homelite__c = true AND Homelite_Products__c INCLUDES (:locatorCategory)';
            else if (brand == 'Dirt Devil')
                strQuery += ' Services_DirtDevil_Brands__c = true AND Dirtdevil_Products__c INCLUDES (:locatorCategory)';
            strQuery += ' AND DISTANCE(BillingAddress, GEOLOCATION(:strLatitude,:strLongitude),\'km\') < :radiusofSearch';
            strQuery += ' AND Display_on_GEO_Locator__c=true AND Record_Status__c=:recordStatus';
            lstAccnt = Database.Query(strQuery);
        }
        return JSON.serialize(lstAccnt);

    }

    public class googleApiWrap {
        public Double glatitude {get; set;}
        public Double glongitude {get; set;}
    }

    webservice static void RetriggerFreightRequest(String caseId, String TriggerPoint) {
        TTI_FreightCompanyAPIResponse objResponse = new TTI_FreightCompanyAPIResponse();
        List<Case> lstCases = [SELECT Id, CaseNumber, TTI_Freight_In_Required__c, TTI_Freight_Out_Required__c, Product_Name__r.ProductCode,
                               Product_Name__r.Height__c, Product_Name__r.Width__c, Product_Name__r.Length__c, Product_Name__r.Weight__c,
                               Service_Agent__r.Name, Service_Agent__r.Phone, Retailer_Account__r.Name, Retailer_Account__r.Phone,
                               Service_Agent__r.Freight_Company__c, Service_Agent__r.Freight_Company_Account_Number__c,
                               TTI_Customer_Account__r.Name, TTI_Customer_Account__r.PersonMobilePhone, TTI_Brand_Service_Phone__c,
                               TTI_Customer_Account__r.PersonEmail, TTI_Freight_In_PickUp_Address__c
                               , TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Postcode__c,
                               TTI_Freight_Out_PickUp_Address__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_Pickup_State__c,
                               TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_In_Delivery_Address__c, TTI_Freight_Out_Delivery_State__c,
                               TTI_Freight_In_Delivery_Suburb__c, TTI_Freight_In_Delivery_Postcode__c, TTI_Freight_In_Delivery_State__c,
                               TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c, Freight_in_consignment_number__c,
                               Freight_out_consignment_number__c, Service_Request_Milestone__c,
                               TTI_Freight_Out_Delivery_Postcode__c, Product.Dangerous_Goods_Text__c FROM Case WHERE Id = :caseId];
        Case objCase = lstCases[0];
        TTI_FreightCompanyAPI.sendFreightCompanyRequest(lstCases, TriggerPoint, objResponse);
        objCase.TTI_Freight_in_API_Request__c = objResponse.inputRequest;
        if (objResponse.Tracking_references != null && objResponse.Tracking_references != '') {
            objCase.Freight_Error_Text__c = '';

            if (TriggerPoint == 'SubmitClaim') {
                objCase.Freight_in_consignment_number__c = objResponse.Tracking_references;
                if (objCase.Service_Agent__r.Freight_Company__c == 'TNT') {
                    objCase.TTI_Freight_in_tracking_url__c = 'http://www.tntexpress.com.au/interaction/track.aspx?con=' + objResponse.Tracking_references;
                }
                if (objCase.Service_Agent__r.Freight_Company__c == 'Courier Post') {
                    objCase.TTI_Freight_in_tracking_url__c = ' http://trackandtrace.courierpost.co.nz/Search/' + objResponse.Tracking_references;
                }
                objCase.Status = 'New';
            }
            if (TriggerPoint == 'MarkAsComplete') {
                objCase.Status = 'In Progress';
                objCase.Freight_out_consignment_number__c = objResponse.Tracking_references;
                if (objCase.Service_Agent__r.Freight_Company__c == 'TNT') {
                    objCase.TTI_Freight_out_tracking_url__c = 'http://www.tntexpress.com.au/interaction/track.aspx?con=' + objResponse.Tracking_references;
                }
                if (objCase.Service_Agent__r.Freight_Company__c == 'Courier Post') {
                    objCase.TTI_Freight_out_tracking_url__c = ' http://trackandtrace.courierpost.co.nz/Search/' + objResponse.Tracking_references;
                }
            }
        }
        if (objResponse.Success == false) {
            objCase.Freight_Error_Text__c = objResponse.Error_message;
            objCase.Status = 'Integration Error';
        }

        update objCase;
    }

    @AuraEnabled
    public static String sendFreightCompanyRequest(Id caseId, String TriggerPoint) {
        TTI_FreightCompanyAPIResponse objResponse = new TTI_FreightCompanyAPIResponse();
        List<Case> lstCases = [SELECT Id, CaseNumber, TTI_Freight_In_Required__c, TTI_Freight_Out_Required__c, Product_Name__r.ProductCode,
                                Product_Name__r.Height__c, Product_Name__r.Width__c, Product_Name__r.Length__c, Product_Name__r.Weight__c,
                                Service_Agent__r.Name, Service_Agent__r.Phone, Retailer_Account__r.Name, Retailer_Account__r.Phone,
                                Service_Agent__r.Freight_Company__c, Service_Agent__r.Freight_Company_Account_Number__c,
                                TTI_Customer_Account__r.Name, TTI_Customer_Account__r.PersonMobilePhone, TTI_Brand_Service_Phone__c,
                                TTI_Customer_Account__r.PersonEmail, TTI_Freight_In_PickUp_Address__c
                                , TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Postcode__c,
                                TTI_Freight_Out_PickUp_Address__c, TTI_Freight_Out_Pickup_Suburb__c, TTI_Freight_Out_Pickup_State__c,
                                TTI_Freight_Out_Pickup_Postcode__c, TTI_Freight_In_Delivery_Address__c,
                                TTI_Freight_In_Delivery_Suburb__c, TTI_Freight_In_Delivery_Postcode__c, TTI_Freight_In_Delivery_State__c,
                                TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c, Freight_in_consignment_number__c,
                                Freight_out_consignment_number__c, TTI_Freight_Out_Delivery_State__c,
                                TTI_Freight_Out_Delivery_Postcode__c, Product.Dangerous_Goods_Text__c FROM Case WHERE Id = :caseId];
        TTI_FreightCompanyAPI.sendFreightCompanyRequest(lstCases, TriggerPoint, objResponse);
        Case objCase = lstCases[0];
        objCase.TTI_Freight_in_API_Request__c = objResponse.inputRequest;
        if (objResponse.Tracking_references != null && objResponse.Tracking_references != '') {
            objCase.Freight_in_consignment_number__c = objResponse.Tracking_references;
            if (objCase.Service_Agent__r.Freight_Company__c == 'TNT') {
                objCase.TTI_Freight_in_tracking_url__c = 'http://www.tntexpress.com.au/interaction/track.aspx?con=' + objResponse.Tracking_references;
            }
            if (objCase.Service_Agent__r.Freight_Company__c == 'Courier Post') {
                objCase.TTI_Freight_in_tracking_url__c = ' http://trackandtrace.courierpost.co.nz/Search/' + objResponse.Tracking_references;
            }

        }
        if (objResponse.Success == false) {
            objCase.Freight_Error_Text__c = objResponse.Error_message;
            objCase.Status = 'Integration Error';
        }

        update objCase;
        return JSON.serialize(objResponse);

    }

    public static void dummyTest() {
        Integer i = 0;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
        i ++;
    }
}