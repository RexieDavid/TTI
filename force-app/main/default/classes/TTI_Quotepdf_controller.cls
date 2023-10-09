public class TTI_Quotepdf_controller {
public Case objCase{get;set;}
public String email{get;set;}
public List<Case> lstCase{get;set;}
public List<Service_Request_Line_Item__c> lstSRL{get;set;}
public String StrCaseId{get;set;}
public Decimal totalcost{get;set;}
public Decimal totalcostwithgst{get;set;}
    public TTI_Quotepdf_controller(){
        lstCase = new List<Case>();
        StrCaseId= ApexPages.currentPage().getparameters().get('caseId');
        
        lstCase =[SELECT id ,SuppliedEmail,Brand__c,CaseNumber,Asset.Name,Diagnosed_Date__c,Service_Agent__r.Name,Service_Agent__r.Delivery_Street__c, Service_Agent__r.Delivery_Suburb__c,Service_Agent__r.Delivery_Postcode__c,Service_Agent__r.Phone,Retailer_Account__r.Name,
                    TTI_Quote_to_Retailer__c ,Parts_Discount_Value__c,Parts_Percentage_Discount__c,Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c,Retailer_Account__r.Delivery_Postcode__c,Labour_Percentage_Discount__c,TTI_Total_Service_line_item_value_inc_GS__c,Labour_Discount_Value__c , TTI_Quote_to_Customer__c,TTI_Brand_Logo_URL__c,TTI_Service_Agent_Comments__c,TTI_Customer_Account__r.PersonMobilePhone,TTI_Customer_Account__r.Name,TTI_GST_for_SRLI__c FROM Case WHERE Id =:StrCaseId];
        
        if(lstCase != null && !lstCase.isEmpty()){
            objCase = lstCase[0];
        }
        
        lstSRL =[SELECT Quantity__c, Line_Item_Description__c, Unit_List_Price__c, Total_List_Price__c ,Service_Request_Number__c FROM Service_Request_Line_Item__c 
                    WHERE Service_Request_Number__c =:objCase.id];
                    
        
        totalcost = 0;
        totalcostwithgst = 0;
        for(Service_Request_Line_Item__c srl:lstSRL ){
            
            if(srl.Total_List_Price__c !=null){
                totalcost =totalcost +  srl.Total_List_Price__c ;
            }
            
        }
        totalcostwithgst = totalcost + (objCase.TTI_GST_for_SRLI__c*totalcostwithgst)/100 ;
        User u = [select Id, username ,  Account.Name from User where Id = :UserInfo.getUserId()];
        //email = '';
        
        if((u.Account.Name == 'SERVICE CENTRE - NSW') || (Test.isRunningTest())){
            if(objCase.Brand__c == 'AEG'){
            email = 'nswservice@aegpowertools.com.au';
            }else if(objCase.Brand__c == 'Milwaukee'){
            email = 'nswservice@milwaukeetools.com.au';
            }else{
            email = 'nswservice@ttibrands.com.au';
            }
        }
        if((u.Account.Name == 'SERVICE CENTRE - MEL') || (Test.isRunningTest())){
            if(objCase.Brand__c == 'AEG'){
            email = 'vicservice@aegpowertools.com.au';
            }else if(objCase.Brand__c == 'Milwaukee'){
            email = 'vicservice@milwaukeetools.com.au';
            }else{
            email = 'vicservice@ttibrands.com.au';
            }
        }
        
        
    }
    
}