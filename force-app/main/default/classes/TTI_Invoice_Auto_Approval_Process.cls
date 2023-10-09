/**
* @author: Jubesh Nagpal
* @date: November 2017
* @description: This class handles Auto Approval Process for Invoice .
*/
public Class TTI_Invoice_Auto_Approval_Process{
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method runs after manual approval or rejection for warranty claims by process builder .
    */
    @InvocableMethod
    public static void restartapprovalprocess(List<Id> CaseId) {
        autoapprove(CaseId);
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method evaluate if Invoice should be auto-approved
        And Set field values  Or Initiate Manual Approval Process .
    */ 
        @AuraEnabled
    public static void autoapprove(List<Id> listCaseId) {
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.addall(listCaseId);
        if (listCaseId != null) {
            List<Service_Request_Line_Item__c> slirecordlist = [SELECT Id, 
                Name, 
                Order_Line_Type__c, 
                Part_Number__r.id,
                Part_Number__r.AU_Landed_Cost__c,
                Part_Number__r.NZ_Landed_Cost__c, 
                Order_Line_Category__c, 
                Total_Value__c,
                Part_Number__r.SOH_BP01__c,
                Part_Number__r.SAP_Material_Group__c,
                Quantity__c,
                Service_Request_Number__c 
                FROM Service_Request_Line_Item__c 
                WHERE Service_Request_Number__c IN :listCaseId];
            Map<Id, List<Service_Request_Line_Item__c>> slimap = new Map<Id, List<Service_Request_Line_Item__c>>();
            for (Service_Request_Line_Item__c slirecord: slirecordlist) {
                for (Id caseid : listCaseId) {
                    if (slirecord.Service_Request_Number__c == caseid) {
                        if (slimap.containskey(caseid)) {
                            slimap.get(caseid).add(slirecord);
                        } else {
                            List<Service_Request_Line_Item__c> slilist = new List<Service_Request_Line_Item__c>();
                            slilist.add(slirecord);
                            slimap.put(caseid , slilist);
                        }
                    }
                }
            }
            for (Case caserecord : [SELECT Id,
                    Total_Sundry_Expenses__c,
                    Claim_Type__c,
                    Invoice_Manually_Approved__c,
                    Product_Size_Category__c,
                    Invoice_Auto_Approved__c,
                    Invoice_Approved_Date__c,
                    Product_Payment_Category__c,
                    Number_of_Interactions__c,
                    Manual_Invoice_Approval_Reason__c,
                    Service_Request_Milestone__c,
                    Service_Agent__r.Max_Claimable_Sundry_Expenses__c,
                    Product_Name__r.SAP_Material_Group__c,
                    Repair_Type__c, 
                    Service_Agent__r.Service_Agent_Status__c 
                    FROM Case 
                    WHERE id in :listCaseId]) {
                if (caserecord.Claim_Type__c == 'Non-Warranty') {
                    caserecord.Invoice_Auto_Approved__c = true;
                    caserecord.Invoice_Approved_Date__c = datetime.now();
                    if (caserecord.Total_Sundry_Expenses__c > 0 && !caserecord.Invoice_Manually_Approved__c) {
                        caserecord.Invoice_Approved_with_sundries__c = true;
                        caserecord.Invoice_Approved_without_sundries__c = false;
                    }
                    caserecord.Invoiced_Approved__c = true;
                    caserecord.Number_of_Interactions__c =  caserecord.Number_of_Interactions__c + 1;
                    caserecord.Manual_Invoice_Approval_Reason__c = '';
                    caserecord.Service_Request_Milestone__c = 'Closed';
                    caserecord.Status = 'Closed';
                    caserecord.Closed_Reason__c = 'Service Request Completed';
                    try {
                        update caserecord;
                        
                    } catch (Exception e) {
                        
                    }
                }
                else {   
                    List<String> Manualinvoiceapprovalreasonlist = new List<String> ();
                    Boolean Criteria1 = true;
                    if (!caserecord.Invoice_Manually_Approved__c) {
                        Criteria1 = sundryexpensesexceedsmaximumthreshold(caserecord); 
                        if (!Criteria1) {
                        Manualinvoiceapprovalreasonlist.add('Maximum Sundry Amount exceeded');
                        }
                    }
                    
                    Boolean Criteria2 = bonuspayable(caserecord);
                    
                    if (!(Criteria2)) {
                        Manualinvoiceapprovalreasonlist.add('Cannot determine bonus');
                    }
                    
                    Boolean Criteria3 = basepricepayable(caserecord);
                    if (!Criteria3) {
                        Manualinvoiceapprovalreasonlist.add('Cannot determine base price');
                    }
                    
                    Boolean Criteria4 = incorrectrepairtype(caserecord , slimap.get(caserecord.id));
                    if (!Criteria4) {
                        Manualinvoiceapprovalreasonlist.add('Incorrect Repair Type');
                    }
                    
                    Boolean Criteria5 = true;
                    if (!caserecord.Invoice_Manually_Approved__c) {
                    Criteria5 = Generatorcombinedrepair(caserecord);
                        if (!Criteria5) {
                            Manualinvoiceapprovalreasonlist.add('Generator & Combined Repair');
                        }
                    }
                    
                    Boolean Criteria6 = missingcategory(caserecord);
                    if (!Criteria6) {
                        Manualinvoiceapprovalreasonlist.add('Product Categories on the case are blank');
                    }
                    
                    String Manualinvoiceapprovalreason = String.join(Manualinvoiceapprovalreasonlist, ';');
                    
                    if (caserecord.Number_of_Interactions__c == null) {
                        caserecord.Number_of_Interactions__c = 0 ;
                    }
                    
                    if (Criteria1  /*&&Criteria2*/ && Criteria3 && Criteria4 && Criteria5 && Criteria6) {
                        caserecord.Invoice_Auto_Approved__c = true;
                        caserecord.Invoice_Approved_Date__c = datetime.now();
                        if (caserecord.Total_Sundry_Expenses__c > 0 &&  !caserecord.Invoice_Manually_Approved__c) {
                            caserecord.Invoice_Approved_with_sundries__c = true;
                            caserecord.Invoice_Approved_without_sundries__c = false;
                        }
                        caserecord.Invoiced_Approved__c = true;
                        caserecord.Number_of_Interactions__c =  caserecord.Number_of_Interactions__c + 1;
                        caserecord.Manual_Invoice_Approval_Reason__c = Manualinvoiceapprovalreason;
                        caserecord.Service_Request_Milestone__c = 'Closed';
                        caserecord.Status = 'Closed';
                        caserecord.Closed_Reason__c = 'Service Request Completed';
                        try {
                            update caserecord;
                            
                        } catch (Exception e) {
                            
                        }
                    } else {
                        caserecord.Invoice_Auto_Approved__c = false;
                        caserecord.Number_of_Interactions__c =  caserecord.Number_of_Interactions__c + 1;
                        caserecord.Invoiced_Approved__c = false;
                        caserecord.Invoice_Approved_Date__c = null;
                        caserecord.Manual_Invoice_Approval_Reason__c = Manualinvoiceapprovalreason;
                        try {
                            update caserecord;
                            
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setObjectId(caserecord.id);
                            req1.setSubmitterId(UserInfo.getUserId());
                            req1.setProcessDefinitionNameOrId('Warranty_Invoice_Approval');
                            Approval.ProcessResult result = Approval.process(req1);
                        } catch(Exception e) {
                            
                        }
                    }
                }
            }  
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Sundry Expenses exceeds maximum threshold.
    */
    @AuraEnabled
    public static Boolean sundryexpensesexceedsmaximumthreshold(Case caserecord) {
        //Updated by Upendra Kumar
        //Calculating Total Sandry Cost of current month claims
        //And comparing with Allowed Sandry Cost
        //It will return true if within limit else false
        decimal totalSum = 0;
        User objCurrentUser = [SELECT Id, ContactId, 
                               Contact.AccountId, 
                               Contact.Account.Max_Claimable_Sundry_Expenses__c
                               FROM User WHERE Id =: UserInfo.getUserId()];
        if (objCurrentUser.ContactId != null && objCurrentUser.Contact.AccountId != null) {
            date monthFirstDate = Date.newInstance(System.today().Year(), System.today().month(), 1);           
            date monthLastDate = Date.newInstance(System.today().Year(), System.today().month() + 1, 1);
            
            // Updated by Francis Nasalita
            // If total sundry expense is null or zero then checking of total 
            // Sundry cost of current month will not procedd
            if (caserecord.Total_Sundry_Expenses__c == null || caserecord.Total_Sundry_Expenses__c == 0) 
                return true;
            else 
                totalSum += caserecord.Total_Sundry_Expenses__c;
            
            for (Case objCurrMonthClaims : [SELECT Id, Total_Sundry_Expenses__c FROM Case WHERE 
                                           Service_Agent__c =: objCurrentUser.Contact.AccountId
                                           AND Invoiced_Approved__c = true
                                           AND Completion_Date__c >=: monthFirstDate 
                                           AND Completion_Date__c <: monthLastDate
                                           AND RecordType.Name = 'Service Request'
                                           AND Id !=: caserecord.Id]) {

                if (objCurrMonthClaims.Total_Sundry_Expenses__c != null) totalSum += objCurrMonthClaims.Total_Sundry_Expenses__c;
            }

            if (objCurrentUser.Contact.Account.Max_Claimable_Sundry_Expenses__c == null) {
                return true;
            }

            if (objCurrentUser.Contact.Account.Max_Claimable_Sundry_Expenses__c != null && 
               totalSum <= objCurrentUser.Contact.Account.Max_Claimable_Sundry_Expenses__c) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
        //Changes done
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Bonus payable to the Service Agent.
    */
    @AuraEnabled
    public static Boolean bonuspayable(Case caserecord) {
        Map<String,ServiceAgentBonus__c> ServiceAgentBonuslist = ServiceAgentBonus__c.getAll();
        Integer count = 0;
        for (ServiceAgentBonus__c sa : ServiceAgentBonuslist.values()) {
            if (sa.RepairType__c == caserecord.Repair_Type__c && sa.PaymentCategory__c == caserecord.Product_Payment_Category__c) {
                count++;
                break;
            }
        }
        if (count == 0) {
            return false;
        } else {
            return true;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Base price payable to the Service Agent.
    */
    @AuraEnabled
    public static Boolean basepricepayable(Case caserecord) {
        Map<String,PricingStructure__c> PricingStructurelist = PricingStructure__c.getAll();
        Integer count = 0;
        for (PricingStructure__c ps : PricingStructurelist.values()) {
            if (ps.Pricing_Type__c == caserecord.Repair_Type__c 
                    && ps.Product_Category__c == caserecord.Product_Payment_Category__c 
                    && ps.Size__c == caserecord.Product_Size_Category__c 
                    && ps.Service_Agent_Status__c == caserecord.Service_Agent__r.Service_Agent_Status__c ) {
                count++;
                break;
            }
        }
        if (count == 0) {
            return false;
        } else {
            return true;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: January 2018
    * @description: This Method Checks Criteria  - If Generator and combined is selected.
    */
    @AuraEnabled
    public static Boolean Generatorcombinedrepair(Case caserecord) {
        if (caserecord.Product_Payment_Category__c == 'Generators' && caserecord.Repair_Type__c == 'Combined Engine & Electrical Repair') {
            return false;
        } else {
            return true;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Incorrect repair Type Selected.
    */
    @AuraEnabled
    public static Boolean incorrectrepairtype(Case caserecord, List<Service_Request_Line_Item__c> slirecordlist ) {
         
        String Repairtype = caserecord.Repair_Type__c;
        
            String MaterialGroup;
            Integer count = 0;
            if (slirecordlist != null) {
                for (Service_Request_Line_Item__c sli : slirecordlist) {
                    if (sli.Order_Line_Type__c == 'Part') {
                        MaterialGroup = sli.Part_Number__r.SAP_Material_Group__c;
                        if (Repairtype == 'Repair' || Repairtype == 'Repair - Large tool'|| Repairtype == 'Repair - Large tool') {
                            if (MaterialGroup != null && (Materialgroup.right(2) == 'TL' || Materialgroup.right(2) == 'MA')) {
                                count++;
                            }
                            
                        }
                        if (Repairtype == 'Repair' ||Repairtype == 'Repair - Large tool'||Repairtype == 'Repair - Large tool'||Repairtype == 'Replacement') {
                            if (Materialgroup.right(3) == 'CHA' ||Materialgroup.right(3) == 'BAT') {
                                count++;
                            }
                        }   
                    }
                }
            
            }
            if (count > 0) {
                return false;
            } else {
                return true;
            }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If product  size category or payment category missing.
    */
    @AuraEnabled
    public static Boolean missingcategory(Case caserecord) {
        if (caserecord.Product_Payment_Category__c == null || caserecord.Product_Size_Category__c == null) {
            return false;
        } else {
            return true;
        }
    }
    
    
}