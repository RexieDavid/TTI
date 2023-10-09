/**
* @author: Jubesh Nagpal
* @date: November 2017
* @description: This class handles Auto Approval Process for service request .
*/
Public Class TTI_ServiceRequest_Auto_Approval_Process{
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method evaluate if Service request should be auto-approves
        And Set field values  And Initiate Manual Approval Process .
    */ 
    @AuraEnabled
    Public static   void autoapprove(Id CaseId){
        if(CaseId!=null){
            Case caserecord = [Select id,Product_Name__r.SAP_MaterialNumber__c,Fault_Codes__c,Goodwill__c,Goodwill_parts_only__c,Asset.WarrantyCalculatedEndDate__c,Claim_Type__c,Purchase_Date__c,Manual_Approval_Reason__c,Service_Request_Milestone__c,Approved_Flag__c,Auto_Approved__c,Sent_to_SAP__c,status,Number_of_Interactions__c,Product_Name__r.Maximum_Number_of_Parts__c,Product_Name__r.Locator_Category__c,Product_Name__r.Payment_Category__c,Product_Name__r.Size_Category__c,Service_Agent__r.Manual_Investigation__c,Service_Agent__r.Delivery_Country__c,Product_Name__r.AU_ListPrice__c,Product_Name__r.NZ_ListPrice__c,Product_Name__r.Standard_Warranty_Months__c,Product_Name__r.id  from Case where id=:CaseId ];
            List<Service_Request_Line_Item__c> slirecordlist = [Select id,name,Part_Number__r.SAP_MaterialNumber__c,Order_Line_Type__c,Part_Number__r.id,Part_Number__r.AU_Landed_Cost__c,Part_Number__r.NZ_Landed_Cost__c,Order_Line_Category__c,Total_Value__c,Part_Number__r.SOH_BP01__c,Part_Number__r.SAP_Material_Group__c,Quantity__c from Service_Request_Line_Item__c where Service_Request_Number__c=:caserecord.id];
            
            List<String> Manualapprovalreasonlist = new List<String> ();
            
                    Boolean Criteria1 = Manualpartsordered(caserecord,slirecordlist); 
                    if(!(Criteria1)){
                        Manualapprovalreasonlist.add('Manual Parts ordered');
                    }
                    Boolean Criteria2 = Numberofparts(caserecord,slirecordlist);
                    Boolean Criteria3 = MissingSKUmaxnumberofparts(caserecord);
                    if(!(Criteria3)){
                        Manualapprovalreasonlist.add('Maximum number of parts for SKU not defined');
                    }else{
                        if(!(Criteria2)){
                        Manualapprovalreasonlist.add('Too many parts');
                        }
                    }
                    
                    Boolean Criteria4 = Stockonhand(caserecord,slirecordlist);
                    if(!(Criteria4)){
                        Manualapprovalreasonlist.add('Low SOH on one or more parts');
                    }
                    Boolean Criteria5 = Warrantyperiod(caserecord);
                    Boolean Criteria6 = Missingwarrantyperiod(caserecord);
                    if(!(Criteria6)){
                        Manualapprovalreasonlist.add('Warranty Period for SKU not defined');
                    }else{
                        if(!(Criteria5)){
                        Manualapprovalreasonlist.add('Out of Warranty Period');
                        }
                    }
                    
                    Boolean Criteria7 = Accessories(caserecord,slirecordlist);
                    if(!(Criteria7)){
                        Manualapprovalreasonlist.add('Accessories/Consumables Specified');
                    }
                    Boolean Criteria8 = SAManualInvestigator(caserecord);
                    if(!(Criteria8)){
                        Manualapprovalreasonlist.add('Service Agent set for Manual Investigation');
                    }
                    Boolean Criteria9 = Replacementpreferred(caserecord,slirecordlist);
                    Boolean Criteria10 = Missinglistprice(caserecord);
                    if(!(Criteria10)){
                        Manualapprovalreasonlist.add('Part or Product List Price not found');
                    }else{
                            if(!(Criteria9)){
                                Manualapprovalreasonlist.add('Replacement preferred');
                            }
                        }
                    
                    Boolean Criteria11 = Missingproductcategories(caserecord);
                    if(!(Criteria11)){
                        Manualapprovalreasonlist.add('Product Categories not defined');
                    }
                    Boolean Criteria12 = Missingmaterialgroups(caserecord,slirecordlist);
                    if(!(Criteria12)){
                        Manualapprovalreasonlist.add('Parts with missing material groups');
                    }
                    Boolean Criteria13 = Partquantityexceeds(caserecord,slirecordlist);
                    Boolean Criteria14 = MissingProductPartquantity(caserecord,slirecordlist);
                    if(!(Criteria14)){
                        Manualapprovalreasonlist.add('Parts BOM Quantity is missing');
                    }else{
                        if(!(Criteria13)){
                        Manualapprovalreasonlist.add('Part Quantity exceeds BOM quantity');
                        }
                    }
                    
                    Boolean Criteria15 = Goodwill(caserecord);
                    if(!(Criteria15)){
                        Manualapprovalreasonlist.add('Goodwill');
                        }
                    
                    String Manualapprovalreason = String.join(Manualapprovalreasonlist, ';');
                    
                    if(caserecord.Number_of_Interactions__c == null){
                        caserecord.Number_of_Interactions__c = 0 ;
                    }
                    caserecord.Diagnosed_Date__c = System.now();
                    caserecord.Diagnosed_User__c = UserInfo.getUserId();
                    if(caserecord.Claim_Type__c == 'Warranty'){
                    //System.debug('Criteria1 '+Criteria1 +'Criteria2'+Criteria2+'Criteria3'+Criteria3+'Criteria4'+Criteria4+'Criteria5'+Criteria5+'Criteria6'+Criteria6+'Criteria7'+Criteria7);
                    
                        if(Criteria1 && Criteria2 && Criteria3 && Criteria4 && Criteria5 && Criteria6 && Criteria7 && Criteria8 && Criteria9 && Criteria10 && Criteria11 && Criteria12 && Criteria13 && Criteria14 && Criteria15){       //Auto-Approved
                            caserecord.status = 'In Progress';
                            caserecord.Service_Request_Milestone__c = 'In Progress';
                            caserecord.Auto_Approved__c = True; 
                            caserecord.Approved_Flag__c = True;
                            caserecord.Approved_Date__c = datetime.now();
                            caserecord.Number_of_Interactions__c =  caserecord.Number_of_Interactions__c + 1;
                            caserecord.Manual_Approval_Reason__c = Manualapprovalreason;
                            system.debug('Manualapprovalreason'+Manualapprovalreason);
                            try{
                                update caserecord; // DML:Update of Case Record
                            }catch(exception e){
                                system.debug('Error DML' + e);
                            }
                        }else{                                                                                              //Going to Manual-Approval
                            caserecord.Auto_Approved__c = False;
                            caserecord.Sent_to_SAP__c = False;
                            caserecord.Number_of_Interactions__c = caserecord.Number_of_Interactions__c + 1;
                            caserecord.Approved_Flag__c = False;
                            caserecord.Approved_Date__c = null;
                            caserecord.Manual_Approval_Reason__c = Manualapprovalreason;
                            
                            
                            try{
                                update caserecord; // DML:Update of Case Record
                            
                                // sending it for  manual approval process
                                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                req1.setObjectId(caserecord.id);
                                req1.setSubmitterId(UserInfo.getUserId());
                                req1.setProcessDefinitionNameOrId('Warranty_Service_Request_Approval');
                                Approval.ProcessResult result = Approval.process(req1);
                                System.debug('Manual process$$'+result);
                                
                                
                                
                            }catch(exception e){
                                system.debug('Error DML' + e);
                            }
                        }
                    }
        }
            
        
        
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If any Manual Parts Ordered
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Manualpartsordered(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        system.debug(slirecordlist+'slirecordlist');
        integer count = 0;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' && sli.Order_Line_Category__c == 'Manual entry'){
                count++;
            }
        }
        if(count > 0){
            return TTI_ServiceRequest_Auto_Approval_Process.BatteryChargerPart(caserecord, slirecordlist);
        }else{
            Return True;
        }
    }

    /**
    * @author: Francis Nasalita
    * @date: September 2018
    * @description: This Method Checks Additional Criteria For Manualpartsordered - If case fault code is 
    *   Battery or Charger, check the parts ordered. If the part ordered is same as the item Return True 
    *   for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    public static Boolean BatteryChargerPart(Case caserecord, List<Service_Request_Line_Item__c> slirecordlist) {
        if(String.isNotBlank(caserecord.Fault_Codes__c)) {
            if(String.valueOf(caserecord.Fault_Codes__c).contains('; ')) {
                Set<String> faultCodes = new Set<String>();
                faultCodes.addAll(String.valueOf(caserecord.Fault_Codes__c).split('; '));
                if(!faultCodes.isEmpty()) {
                    if(faultCodes.contains('BATTERY') || faultCodes.contains('CHARGER')) {
                        if(slirecordlist.size() == 1 && slirecordlist[0].Quantity__c == 1) {
                            if(caserecord.Product_Name__r.SAP_MaterialNumber__c == slirecordlist[0].Part_Number__r.SAP_MaterialNumber__c) {
                                return true;
                            }
                        }
                    }
                }
            }

            if(caserecord.Fault_Codes__c == 'BATTERY' || caserecord.Fault_Codes__c == 'CHARGER') {
                if(slirecordlist.size() == 1 && slirecordlist[0].Quantity__c == 1) {
                    if(caserecord.Product_Name__r.SAP_MaterialNumber__c == slirecordlist[0].Part_Number__r.SAP_MaterialNumber__c) {
                        return true;
                    }
                }
            } 
        }
        return false;
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Number Of Parts More than Allowed Value
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Numberofparts(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        system.debug('Hello@@@'+caserecord.Product_Name__r.Maximum_Number_of_Parts__c);
        if(caserecord.Product_Name__r.Maximum_Number_of_Parts__c == null){
            Return False; //Failure 1
        }else{
            integer count = 0;
            for(Service_Request_Line_Item__c sli : slirecordlist){
                if(sli.Order_Line_Type__c == 'Part'){
                    count++;
                }
            
            }
            if(count > caserecord.Product_Name__r.Maximum_Number_of_Parts__c){
                Return False; //Failure 2
            }else{
                Return True;
            }
            
        }
           
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Stock On Hand
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Stockonhand(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        AutoApproval_Percentage__c sohpercentage = AutoApproval_Percentage__c.getvalues('SOH_Percentage');
        Integer count = 0;
        Decimal SOHValue = 0;
        Decimal percentage = 0;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            percentage = 0;
            if(sli.Order_Line_Type__c == 'Part' ){
                SOHValue = sli.Part_Number__r.SOH_BP01__c;
                if(SOHValue != null && SOHValue != 0){
                    percentage = (sli.Quantity__c/SOHValue)*100;
                    if(percentage > sohpercentage.AutoApproval_Percentage__c ){
                    count++;
                    break;
                    }
                
                }    
            }
            
        }
        
        if(count>0){
            Return False; // Failure
        }else{
            Return True;
        }
        
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Purchase Date is in Warranty Period
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Warrantyperiod(Case caserecord){
        
        Date Warrantyexpirydate = caserecord.Asset.WarrantyCalculatedEndDate__c;
        
        if(Warrantyexpirydate ==null){
            Return False; //Failure 1
        }else{
            
            system.debug('wed$$'+Warrantyexpirydate);
            if(Warrantyexpirydate < date.today()){
                
                system.debug('Warrantyexpirydate '+Warrantyexpirydate + 'todays date'+date.today()+'false');
                Return False; //Failure 2
                
            }else{
                system.debug('Warrantyexpirydate '+Warrantyexpirydate + 'todays date'+date.today()+'true');
                Return True;
            }
        }
            
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Accessories Are  in Service Line Items
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Accessories(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        Map<String,MaterialGroups__c> materialgroup = MaterialGroups__c.getAll();
        Set<String> Materialgroupcodes = materialgroup.keyset();
        Boolean matched = False;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' ){
                if(Materialgroupcodes.contains(sli.Part_Number__r.SAP_Material_Group__c)){
                    matched = True;
                    system.debug('break has happened@@@$$$$$'+sli.Part_Number__r.SAP_Material_Group__c);
                    break;
                }  
            }
            
        }
        if(matched){
            Return False; //Failure
        }else{
            Return True;
        }
        
        
        
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Service Agent Is Manual Investigator
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean SAManualInvestigator(Case caserecord){
        if(caserecord.Service_Agent__r.Manual_Investigation__c == True){
            Return False; //Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Replacement required
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Replacementpreferred(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        Decimal Totalcost = 0;
        Decimal Listprice = 0; 
        Decimal Percentage = 0;
        System.debug(Totalcost +'ackbkjbc'+Listprice);
        
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' ){
                
                if(sli.Part_Number__r.AU_Landed_Cost__c == null){
                    sli.Part_Number__r.AU_Landed_Cost__c = 0;
                }
                if(sli.Part_Number__r.NZ_Landed_Cost__c == null){
                    sli.Part_Number__r.NZ_Landed_Cost__c = 0;
                }
                if(caserecord.Service_Agent__r.Delivery_Country__c=='Australia' || caserecord.Service_Agent__r.Delivery_Country__c=='AU'){
                    Totalcost = Totalcost + sli.Part_Number__r.AU_Landed_Cost__c;
                }else{
                if(caserecord.Service_Agent__r.Delivery_Country__c=='New Zealand' || caserecord.Service_Agent__r.Delivery_Country__c=='NZ'){
                    Totalcost = Totalcost + sli.Part_Number__r.NZ_Landed_Cost__c;
                }
                else{
                    Totalcost = Totalcost + sli.Part_Number__r.NZ_Landed_Cost__c;
                }
            }   
            }
            
        }
        if(caserecord.Service_Agent__r.Delivery_Country__c=='Australia' || caserecord.Service_Agent__r.Delivery_Country__c=='AU'){
            Listprice = caserecord.Product_Name__r.AU_ListPrice__c;
            System.debug('Country++'+caserecord.Service_Agent__r.Delivery_Country__c);
            
        }else{
            if(caserecord.Service_Agent__r.Delivery_Country__c=='New Zealand' || caserecord.Service_Agent__r.Delivery_Country__c=='NZ'){
                Listprice = caserecord.Product_Name__r.NZ_ListPrice__c;
            }
            else{
                Listprice = caserecord.Product_Name__r.AU_ListPrice__c;
            }
        }
        if(Listprice!=0 && Listprice!=null && Totalcost!=null){
            percentage = (Totalcost/Listprice)*100;
        }
        
        System.debug(Totalcost +'ackbkjbc'+Listprice+'sxjkjbajkcb'+percentage );
        AutoApproval_Percentage__c costpercentsetting = AutoApproval_Percentage__c.getvalues('Cost_Percentage');
        Decimal Tolerance = costpercentsetting.AutoApproval_Percentage__c;
        if(percentage>Tolerance){
            Return False; //Failure
        }else{  
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Missing Warranty Months on Product
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Missingwarrantyperiod(Case caserecord){
        if(caserecord.Product_Name__r.Standard_Warranty_Months__c == null){
            Return False; //Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Missing Categories on Product
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Missingproductcategories(Case caserecord){
        if(caserecord.Product_Name__r.Locator_Category__c == null || caserecord.Product_Name__r.Size_Category__c == null || caserecord.Product_Name__r.Payment_Category__c == null){
            Return False; //Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Missing Material Group on Products of Service Line Item
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Missingmaterialgroups(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        
        integer count = 0;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' ){
                    if(sli.Part_Number__r.SAP_Material_Group__c == null){
                        count++;
                    }
            }
            
        }
        if(count>0){
            Return False; //Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Missing Max Number Of Parts on Products
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean MissingSKUmaxnumberofparts(Case caserecord){
        if(caserecord.Product_Name__r.Maximum_Number_of_Parts__c == null){
            Return False; //Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If Missing List Price on Products
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Missinglistprice(Case caserecord){
        Decimal Listprice = 0;
        if(caserecord.Service_Agent__r.Delivery_Country__c=='Australia' || caserecord.Service_Agent__r.Delivery_Country__c=='AU'){
            Listprice = caserecord.Product_Name__r.AU_ListPrice__c;
            System.debug('Country++'+caserecord.Service_Agent__r.Delivery_Country__c);
            
        }else{
            if(caserecord.Service_Agent__r.Delivery_Country__c=='New Zealand' || caserecord.Service_Agent__r.Delivery_Country__c=='NZ'){
                Listprice = caserecord.Product_Name__r.NZ_ListPrice__c;
            }
            else{
                Listprice = caserecord.Product_Name__r.AU_ListPrice__c;
            }
        }
        
        if(Listprice == null){
            Return False; // Failure
        }else{
            Return True;
        }
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks Criteria  - If SLI Quantity is more on Product Parts
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean Partquantityexceeds(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        Set<Id> productpart = new Set<Id>();
        id producttool = caserecord.Product_Name__r.id;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' ){
                system.debug(sli.Part_Number__r.id+'sli.Part_Number__r.id');
                productpart.add(sli.Part_Number__r.id);    
            }
        }
        Map<Id,Decimal> quantityparts = new Map<Id,Decimal>();
        for(Id ppid : productpart){
            quantityparts.put(ppid,0);
        }
        for(Id ppid : productpart){
            Decimal partscount = 0;
            for(Service_Request_Line_Item__c sli : slirecordlist){
                if(sli.Order_Line_Type__c == 'Part' ){
                    if(sli.Part_Number__r.id == ppid){
                        if(sli.Quantity__c!=null){
                            partscount = sli.Quantity__c + quantityparts.get(ppid);
                            quantityparts.put(ppid,partscount);
                        }
                        
                    }    
                }
            }
        }
        
        system.debug('check flags'+producttool+'List'+productpart);
        List<ProductParts__c> ProductPartList = [Select Id,Quantity__c,ProductTool__c,ProductPart__c,ProductPart__r.id from ProductParts__c where ProductTool__c=:producttool And ProductPart__r.id in :productpart ];
        system.debug('Productpartlist'+ProductPartList);
        List<ProductParts__c> ProductPartsublist  = new List<ProductParts__c>();
        Map<id,List<ProductParts__c>> ProductPartMap  = new Map<id,List<ProductParts__c>>();
        if(ProductPartList.size()>0){
            for(ProductParts__c pp : ProductPartList ){
                if(!ProductPartMap.containsKey(pp.ProductPart__r.id)){
                    List<ProductParts__c> pplist = new List<ProductParts__c>();
                    pplist.add(pp);
                    ProductPartMap.put(pp.ProductPart__r.id,pplist);
                }else{
                    ProductPartMap.get(pp.ProductPart__r.id).add(pp);
                }
            }
        }
        system.debug('ProductPartMap'+ProductPartMap);
        integer count = 0;
        if(productpart!=null){
            for(Id pid : productpart){
                if(ProductPartMap.containsKey(pid)){
                    for(ProductParts__c pps : ProductPartMap.get(pid)){
                            if( quantityparts.get(pid) > pps.Quantity__c){
                                count++;
                                break;
                            }
                    }
                } 
            }
        }
        
                    
                    
                
        
        if(count > 0){
            Return False;
        }else{
            Return True;
        }
            
        
        
        
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks If Any of the Parts have quantity null in productparts
        Return True for auto-approval and False for Failure of criteria.
    */
    @AuraEnabled
    Public static    Boolean MissingProductPartquantity(Case caserecord,List<Service_Request_Line_Item__c> slirecordlist){
        Set<Id> productpart = new Set<Id>();
        id producttool = caserecord.Product_Name__r.id;
        for(Service_Request_Line_Item__c sli : slirecordlist){
            if(sli.Order_Line_Type__c == 'Part' && sli.Order_Line_Category__c == 'Bill of Materials'){
                productpart.add(sli.Part_Number__r.id);    
            }
        }
        
        List<ProductParts__c> ProductPartList = [Select Id,Quantity__c,ProductTool__c,ProductPart__c,ProductPart__r.id from ProductParts__c where ProductTool__c=:producttool And ProductPart__r.id =:productpart ];
        system.debug('Productpartlist'+ProductPartList);
        Map<id,ProductParts__c> ProductPartMap  = new Map<id,ProductParts__c>();
        Integer count = 0 ;
        if(ProductPartList.size()>0){
            for(ProductParts__c pp : ProductPartList ){
                if(pp.Quantity__c == null){
                    count++;
                    break;
                }
            }
        }
        if(count > 0){
            Return False;
        }else{
            Return True;
        }
        
        
    }
    
    /**
    * @author: Jubesh Nagpal
    * @date: November 2017
    * @description: This Method Checks has Goodwill or Goodwill parts checked.
    */
    @AuraEnabled
    Public static    Boolean Goodwill(Case caserecord){
        if(caserecord.Goodwill__c || caserecord.Goodwill_parts_only__c){
            Return False;
        }else{
            Return True;
        }
        
        
    }
}