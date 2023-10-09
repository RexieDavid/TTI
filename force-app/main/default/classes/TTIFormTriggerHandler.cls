/**
* @author: Jerome Liwanag
* @date: Apr 2017
* @description: This class handles all CRUD operations for the
* TTIForm Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class TTIFormTriggerHandler {
    
    public static Id promoStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_PROMO_STOCK_REQUEST).getRecordTypeId();
    public static Id demoSampleRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_DEMO_SAMPLE_REQUEST).getRecordTypeId();
    public static Id zjssInternalRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_ZJSS_INTERNAL_ORDER).getRecordTypeId();
    public static Id showroomRequestRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_REQUEST).getRecordTypeId();
    public static Id showroomReturnRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_RETURN).getRecordTypeId();
    public static Id zjssRebateRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_ZJSS_REBATE).getRecordTypeId();
    public static Id sponsorshipsId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SPONSORSHIPS).getRecordTypeId();
    public static Id personAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    public static final String pickupFromWharehouse = 'PICKUP FROM WHAREHOUSE';
    public static final String deliveryPostal = '9999';
    public static Boolean runAssignDeliveryAddressOnce = false;
    public static Boolean assignApproverAndAccountsOnce = false;
    
    public static String ZJSS_ApproveById;
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on Before Insert
    * functionalities of the TTIForm
    */ 
    public static void onBeforeInsert(List<TTI_Form__c> ttiFormList) {
        if(!runAssignDeliveryAddressOnce){
            runAssignDeliveryAddressOnce = true;
            assignDeliveryAddress(ttiFormList);
        }
        if(!assignApproverAndAccountsOnce){
            assignApproverAndAccountsOnce = true;
            assignApproverAndAccounts(ttiFormList);
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on Before Update
    * functionalities of the TTIForm
    */ 
    public static void onBeforeUpdate(List<TTI_Form__c> ttiFormList, Map<Id,TTI_Form__c> ttiFormOldMap) {
        if(!runAssignDeliveryAddressOnce){
            runAssignDeliveryAddressOnce = true;
            assignDeliveryAddress(ttiFormList);
        }
        if(!assignApproverAndAccountsOnce){
            assignApproverAndAccountsOnce = true;
            assignApproverAndAccounts(ttiFormList);
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on After Insert
    * functionalities of the TTIForm
    */ 
    public static void onAfterInsert(List<TTI_Form__c> ttiFormList) {
        updateContracts(ttiFormList);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on After Update
    * functionalities of the TTIForm
    */ 
    public static void onAfterUpdate(List<TTI_Form__c> ttiFormList, Map<Id,TTI_Form__c> ttiFormOldMap) {
        updateContracts(ttiFormList);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles all on After Delete
    * functionalities of the TTIForm
    */ 
    public static void onAfterDelete(List<TTI_Form__c> ttiFormOldList) {
        updateContracts(ttiFormOldList);
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method handles the assiignment of Delivery
    * Address if the pick up from wharehouse field is checked
    */ 
    public static void assignDeliveryAddress(List<TTI_Form__c> ttiFormList){
        
        Set<Id> ttiFormIds = new Set<Id>();
        
        for (TTI_Form__c ttiFormLoop : ttiFormList) {
            ttiFormIds.add(ttiFormLoop.OwnerId);
        }
        
        Map<Id,User> userMap = new Map<Id,User>([Select Id, TTI_SAP_Cust_No__c, ManagerId, Cost_Centre__c, Default_Plant__c FROM User WHERE Id IN :ttiFormIds]);
        
        for (TTI_Form__c ttiFormLoop : ttiFormList) {
            if (userMap.containsKey(ttiFormLoop.OwnerId)){
                // Delivery Assignment only works if Pickup From Wharehouse field is checked 
                if (ttiFormLoop.Pickup_from_Wharehouse__c) {
                ttiFormLoop.Delivery_Street__c = pickupFromWharehouse;
                ttiFormLoop.Delivery_Postcode__c = deliveryPostal;
    
                    if (userMap.get(ttiFormLoop.OwnerId).Default_Plant__c != Null) {
                        if (userMap.get(ttiFormLoop.OwnerId).Default_Plant__c == GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_BP01) {
                            ttiFormLoop.Delivery_Suburb__c  = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_Suburb__c'));
                            ttiFormLoop.Delivery_State__c   = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_State__c'));
                            ttiFormLoop.Delivery_Country__c = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_Country__c'));
                        } else if (userMap.get(ttiFormLoop.OwnerId).Default_Plant__c == GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_BP02) {
                            ttiFormLoop.Delivery_Suburb__c  = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP02_Suburb__c'));
                            ttiFormLoop.Delivery_State__c   = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP02_State__c'));
                            ttiFormLoop.Delivery_Country__c = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP02_Country__c'));
                        } else if (userMap.get(ttiFormLoop.OwnerId).Default_Plant__c == GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_NZ01) {
                            ttiFormLoop.Delivery_Suburb__c  = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('NZ01_Suburb__c'));
                            ttiFormLoop.Delivery_State__c   = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('NZ01_State__c'));
                            ttiFormLoop.Delivery_Country__c = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('NZ01_Country__c'));
                        }
                    } 
                    else {
                        ttiFormLoop.Delivery_Suburb__c  = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_Suburb__c'));
                        ttiFormLoop.Delivery_State__c   = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_State__c'));
                        ttiFormLoop.Delivery_Country__c = String.valueOf(TTI_Form_Delivery_Address__c.getOrgDefaults().get('BP01_Country__c'));
                    }
    
                }
            }
        }
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method assigns designated approvers
    * and the associated account related to the record
    *
    */ 
    public static void assignApproverAndAccounts(List<TTI_Form__c> ttiFormList){
        
        Set<Id> ttiFormIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,List<Account>> accountUserListMap = new Map<Id,List<Account>>();
        Map<String, String> formIdContractIdMap = new Map<String, String>();
        for (TTI_Form__c ttiFormLoop : ttiFormList) {
            ttiFormIds.add(ttiFormLoop.OwnerId);
            if (ttiFormLoop.Form_Opportunity__c != null) {
                oppIds.add(ttiFormLoop.Form_Opportunity__c);
            }
            if (ttiFormLoop.RecordTypeId == zjssRebateRecId && ttiFormLoop.Contract__c!=null) {
                formIdContractIdMap.put(ttiFormLoop.Id, ttiFormLoop.Contract__c);
            }
        }
        
        Map<String, Contract> contractIdContractMap;
        if (!formIdContractIdMap.isEmpty()) {
            contractIdContractMap = new Map<String, Contract>([SELECT Id, AccountId FROM Contract WHERE Id IN: FormIdContractIdMap.values()]);
        }
        Set<String> ttiCustNoSet = new Set<String>();
        Map<Id,User> userMap = new Map<Id,User>();
        for(User userLoop: [Select Id, TTI_SAP_Cust_No__c, ManagerId, Cost_Centre__c, Default_Plant__c FROM User WHERE Id IN :ttiFormIds]){
            userMap.put(userLoop.Id, userLoop);
            ttiCustNoSet.add(userLoop.TTI_SAP_Cust_No__c);
        }
        
        
        TTIForm_Defaults__c defaultValues = TTIForm_Defaults__c.getOrgDefaults();
        TTIForm_Defaults_NZ__c defaultValuesNZ = TTIForm_Defaults_NZ__c.getOrgDefaults();
        
        Account promoAccNz = [SELECT Id FROM Account WHERE Account.TTI_SAP_Cust_No__c=:defaultValuesNZ.Default_Promo_Account_Number__c LIMIT 1];
        Account promoAcc = [SELECT Id FROM Account WHERE Account.TTI_SAP_Cust_No__c=:defaultValues.Default_Promo_Account_Number__c LIMIT 1];
        User promoUserNz = [SELECT Id FROM User WHERE Username=:defaultValuesNZ.Default_Promo_Approver__c];
        User promoUser = [SELECT Id FROM User WHERE Username=:defaultValues.Default_Promo_Approver__c];
        User jssUser = [SELECT Id FROM User WHERE Username =: TTIForm_Defaults__c.getOrgDefaults().Default_JSS_Approver__c];
        
        
        for(Account accLoop : [SELECT Id,TTI_SAP_Cust_No__c FROM Account WHERE TTI_SAP_Cust_No__c != null AND TTI_SAP_Cust_No__c IN :ttiCustNoSet]){
            for(User userLoop : userMap.values()){
                if(accLoop.TTI_SAP_Cust_No__c == userLoop.TTI_SAP_Cust_No__c){
                    if(!accountUserListMap.containsKey(userLoop.Id)){
                        accountUserListMap.put(userLoop.Id, new List<Account> {accLoop});
                    }else{
                        accountUserListMap.get(userLoop.Id).add(accLoop);
                    }
                }
            }
        }
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Account_Contact__c FROM Opportunity WHERE Id IN :oppIds]);
        
        for (TTI_Form__c ttiFormLoop : ttiFormList) {
            
            ttiFormLoop.FormID__c = ttiFormLoop.Name;
            // If TTI Form record type is "PROMO STOCK REQUEST" set default Account and default Approver
            if (ttiFormLoop.RecordTypeId == promoStockRecId) {
                assignApproverAndAccountsOnce = false;
                if(ttiFormLoop.Delivery_Country__c == 'NZ' || ttiFormLoop.Delivery_Country__c == 'New Zealand'){
                    ttiFormLoop.Approve_by__c = promoUserNz.Id;
                    ttiFormLoop.Account__c = promoAccNz.Id;
                
                }else if(ttiFormLoop.Delivery_Country__c == 'AU' || ttiFormLoop.Delivery_Country__c == 'Australia'){
                    ttiFormLoop.Approve_by__c = promoUser.Id;
                    ttiFormLoop.Account__c = promoAcc.Id;
                
                }
                
            }
            
            // If TTI Form record type is "SPONSORSHIPS" set default Account and default Approver
            if (ttiFormLoop.RecordTypeId == sponsorshipsId) {
                assignApproverAndAccountsOnce = false;
                if(ttiFormLoop.Delivery_Country__c == 'NZ' || ttiFormLoop.Delivery_Country__c == 'New Zealand'){
                    ttiFormLoop.Approve_by__c = Label.Sponsorship_Approver;
                    ttiFormLoop.Account__c = promoAccNz.Id;
                
                }else if(ttiFormLoop.Delivery_Country__c == 'AU' || ttiFormLoop.Delivery_Country__c == 'Australia'){
                    ttiFormLoop.Approve_by__c = Label.Sponsorship_Approver;
                    ttiFormLoop.Account__c = promoAcc.Id;
                
                }
                
            }    
    
            //HR - 22/05/2016 - If recordtype is ZJSS Rebate, set the owner to James
            if (ttiFormLoop.RecordTypeId == zjssRebateRecId) {
                if (ZJSS_ApproveById==null) {
                    if (Test.isRunningTest())
                        ZJSS_ApproveById = [SELECT Id FROM User WHERE IsActive=TRUE AND TTI_SAP_Cust_No__c!=null LIMIT 1].Id;
                    else
                        ZJSS_ApproveById = jssUser.Id;
                }
                ttiFormLoop.Approve_by__c = ZJSS_ApproveById;
            }
            
            //If TTI Form record type is "Showroom Stock Request" or "Demo Sample Request" set Approver as User Manager and Account as User's SAP Account and Customer as User's Account
            if (ttiFormLoop.RecordTypeId == showroomRequestRecId || ttiFormLoop.RecordTypeId == demoSampleRecId) {
                if (userMap.get(ttiFormLoop.OwnerId).ManagerId != Null) {
                    ttiFormLoop.Approve_by__c = userMap.get(ttiFormLoop.OwnerId).ManagerId;
                } else {
                    ttiFormLoop.Approve_by__c = jssUser.Id;
                }
                
                if (userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c != Null) {
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size()==1) {
                        ttiFormLoop.Account__c = accountUserListMap.get(ttiFormLoop.OwnerId)[0].Id;
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() > 1) {
                        ttiFormLoop.addError('Multiple accounts found with "TTI SAP Customer No: ' + userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c +'"');
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() == 0) {
                        ttiFormLoop.addError('The form owner does not have a valid SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                    }
                } 
                else {
                    ttiFormLoop.addError('The form owner does not have a SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                    }

                ttiFormLoop.Customer_Name__c = ttiFormLoop.Account__c;
            }
            
            //If TTI Form record type is "Showroom Stock Return" set Approver as User Manager and Account as User's SAP Account
            if (ttiFormLoop.RecordTypeId == showroomReturnRecId) {
                if (userMap.get(ttiFormLoop.OwnerId).ManagerId != Null) {
                    ttiFormLoop.Approve_by__c = userMap.get(ttiFormLoop.OwnerId).ManagerId;
                } else {
                    ttiFormLoop.Approve_by__c = jssUser.Id;
                }
            
                if (userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c != Null) {
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size()==1) {
                        ttiFormLoop.Account__c = accountUserListMap.get(ttiFormLoop.OwnerId)[0].Id;
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() > 1) {
                        ttiFormLoop.addError('Multiple accounts found with "TTI SAP Customer No: ' + userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c +'"');
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() == 0) {
                        ttiFormLoop.addError('The form owner does not have a valid SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                    }
                } 
                else {
                    ttiFormLoop.addError('The form owner does not have a SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                }
                
            }

            //If the TTI Form record type is "ZJSS Internal Order" set Opportunity Contact
            if (ttiFormLoop.RecordTypeId == zjssInternalRecId || ttiFormLoop.RecordTypeId == zjssRebateRecId) {
                
                //Exception handling for No contact on Opportunity
                if (ttiFormLoop.Form_Opportunity__c != Null) {
                    Opportunity opp = oppMap.get(ttiFormLoop.Form_Opportunity__c);
                    id ConID = opp.Account_Contact__c;
                    ttiFormLoop.Form_Opportunity_Contact__c = ConID;
                }
    
                //Link Account to User's SAP Account
                if (userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c != Null) {
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size()==1) {
                        ttiFormLoop.Account__c = accountUserListMap.get(ttiFormLoop.OwnerId)[0].Id;
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() > 1) {
                        ttiFormLoop.addError('Multiple accounts found with "TTI SAP Customer No: ' + userMap.get(ttiFormLoop.OwnerId).TTI_SAP_Cust_No__c +'"');
                    }
                    if (accountUserListMap.get(ttiFormLoop.OwnerId).size() == 0 && !Test.isRunningTest()) {
                        ttiFormLoop.addError('The form owner does not have a valid SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                    }
                } else {
                    ttiFormLoop.addError('The form owner does not have a SAP Account Number on their User Record. Please contact your Salesforce Administrator for further help.');
                }
              
                if (ttiFormLoop.RecordTypeId == zjssRebateRecId && ContractIdContractMap!=null && ContractIdContractMap.containsKey(ttiFormLoop.Contract__c)) {
                    ttiFormLoop.Customer_Name__c = ContractIdContractMap.get(ttiFormLoop.Contract__c).AccountId;
                }
            }
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Apr 2017
    * @description: This method updates the sum of contracts associated
    * to a zjsss rebate type of account 
    *
    */ 
    public static void updateContracts(List<TTI_Form__c> ttiFormList){
        
        Map<String, Double> sumFormsListPrice = new Map<String, Double>();
        for(TTI_Form__c ttiFormLoop : ttiFormList){
            if(ttiFormLoop.RecordTypeId == zjssRebateRecId){
                sumFormsListPrice.put(ttiFormLoop.Contract__c, null);
            }
        }
        
         if (sumFormsListPrice.isEmpty()){
            return;
         }
         
        for (AggregateResult t : [SELECT Contract__c, SUM(Total_Form_List_Price_Value__c)
                                  FROM TTI_Form__c
                                  WHERE Contract__c IN :sumFormsListPrice.keySet()
                                  AND RecordTypeId = :zjssRebateRecId
                                  AND Form_Status__c = 'Approved'
                                  GROUP BY Contract__c]) {
                                
            if (t.get('expr0')!=null) {
                sumFormsListPrice.put(String.valueOf(t.get('Contract__c')), Double.valueOf(t.get('expr0')));
            }
            else {
                sumFormsListPrice.put(String.valueOf(t.get('Contract__c')), 0);
            }
        }
        
        List<Contract> contractsToUpdate = new List<Contract>();

        for (String s : sumFormsListPrice.keySet()) {
            if (sumFormsListPrice.get(s)!=null) {
                contractsToUpdate.add(new Contract(Id = s, Sum_of_Redeemed__c = sumFormsListPrice.get(s)));
            } else if (sumFormsListPrice.get(s)==null) {
                contractsToUpdate.add(new Contract(Id = s, Sum_of_Redeemed__c = 0));
            }
        }
    
        if (!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
        }
                            
    }
}