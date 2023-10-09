public class DirectMarketingController {

  /*

    //Declare Valriables
    public string PBookId = '01s90000000DTDhAAO';//Industrial Pricebook
    
    public string inputkey1 {get;set;} //Product Description
    public string inputkey2 {get;set;} //Promo Product Code search
    
    public date DateStart {get;set;} //Start Date field for Search Query
    public date DateEnd {get;set;} //End Date field for Search Query
    
    //***** New Variables for Specific search******
    public list <Product2> ProdSAP {get;set;}
    
    //**************************************
    
    public list <Product2> SelProd {get;set;} //Select 10 products based on search
    public list <Product2> SelProdAll {get;set;}//Select all products based on search
    public list <PricebookEntry> SelPromo {get;set;}//Select Promo Product based on search
    public list <PricebookEntry> PromoList {get;set;}//Promo Product list based on selected products
    public list <pProduct> selectedProducts {get;set;}//Filtered Promo Product list with Promo Quantity    
    public integer ProdAllCount{get;set;} //Count of all products via query
    public integer PromoCount{get;set;} //Count of promo products via query
    
    public list <AggregateResult> SelAccList {get;set;} //
    public list <pAccount> AccList = new list <pAccount>(); //Our collection of the class/wrapper object pAccount
  	public list <pAccount> selectedAccounts = new List<pAccount>();//Filtered list of Selected Accoounts
  	public string SelectAll {get;set;} //Variable to determine select all accounts
    
    public string OppName {get;set;}//Collect OppName for DM Opportunities
    
    public boolean Section1 {get;set;}  //Render section1 variable
    public boolean Section2 {get;set;}  //Render section2 variable
    public boolean Section3 {get;set;}  //Render section3 variable
    public boolean Section4 {get;set;}  //Render section4 variable
    
    //Declare Variables for Record Creation
    public list <Opportunity> createOpps = new list <Opportunity>(); //Opportunity Container
    public list <OpportunityLineItem> createOppLine = new list <OpportunityLineItem>(); //Opportunity Products Container
    public list <Task> createTasks = new list <Task>(); //Task Container
    public list <TTI_Form__c> createForms = new list <TTI_Form__c>(); //TTI Form Container
    public list <TTI_Form_Product__c> createFormProds = new list <TTI_Form_Product__c>(); //TTI Form Products Container

//PAGE ON LOAD **************************************
    public DirectMarketingController() {
      Section1 = true;//True on load
      Section2 = false;//false on load
      Section3 = false;//false on load
      Section4 = false;//false on load
      DateStart = Date.today().addYears(-1);
      DateEnd = Date.today();
      SelectAll = 'Select All';
    }

//STEP 1 - PRODUCT SEARCH & ACCOUNT SELECT **************************************
	//Add SAP# to list
	public void AddSAP()
	{
		if (ProdSAP == null){
			ProdSAP = new list<Product2>();
		}
		if (inputkey1 != ''){
			list<Product2> p = [SELECT Id, ProductCode, Description FROM Product2 WHERE ProductCode = :inputkey1 LIMIT 1];
			if (p.size() == 1){
				set <Product2> pSet = new set<Product2>(ProdSAP);
				if (pSet.contains(p[0])){
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Product already in search list.');
					ApexPages.addMessage(myMsg);
				} else {
					ProdSAP.add(p[0]);
				}
			} else {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'Product not found!');
				ApexPages.addMessage(myMsg);
			}
		}
	}
	//Clear SAP# List
	public void ClearSAP()
	{
		if (ProdSAP != null){
			ProdSAP.clear();
		}
	}
	//Command button for Product Search
	public void SearchSAP()
	{
		if (ProdSAP != null){
			//Declare Account Search Query
			string OppId = '01290000000GI4PAAW';
			string SelectA='SELECT Opportunity.AccountId AccId,Opportunity.Account.Name AccName, Opportunity.Account.OwnerId OwnerId, Opportunity.Account.Owner.Name OwnerName, Opportunity.Account.Direct_Marketing_Contact__c ContactDMID, Opportunity.Account.Direct_Marketing_Contact__r.Name ContactDM, Sum(Quantity) QTY, Sum(TotalPrice) Total ';
			string FromA='FROM OpportunityLineItem ';
			string WhereA='WHERE Opportunity.IsWon = True AND Opportunity.CloseDate >= :DateStart AND Opportunity.CloseDate <= :DateEnd AND Opportunity.RecordTypeId =: OppId  AND PricebookEntry.Product2Id IN :ProdSAP ';
			string GroupA='GROUP BY Opportunity.AccountId,Opportunity.Account.Name,Opportunity.Account.OwnerId,Opportunity.Account.Owner.Name,Opportunity.Account.Direct_Marketing_Contact__c,Opportunity.Account.Direct_Marketing_Contact__r.Name ';
			string LimitA='ORDER BY Sum(Quantity) Desc';
			string queryA= SelectA+FromA+WhereA+GroupA+LimitA;
			//Run Account Query
			SelAccList = Database.query(queryA);
			AccList.clear();
			SelectAll = 'Select All';
			if (SelAccList != null){
				//Loop Through Aggregated Results
				for(AggregateResult a:SelAccList){
					AccList.add(new pAccount(String.valueOf(a.get('AccId')),String.valueOf(a.get('AccName')),String.valueOf(a.get('OwnerId')),String.valueOf(a.get('ContactDMID')),String.valueOf(a.get('ContactDM')),Integer.valueOf(a.get('QTY')),Double.valueOf(a.get('Total')),false,String.valueOf(a.get('OwnerName'))));
				}
			}
		}
	}
	//Command Button for Fuzzy Search
	public void SearchFuzzy()
	{
	    if (inputkey1 == ''){
	        if(SelProd != null){
	            SelProd.clear();
	            SelProdAll.clear();
	            ProdAllCount = SelProdAll.size();
	            SelAccList.clear();
	            SelectAll = 'Select All';
	            }
	        //
	    } else {
	        //Declare Product Search Query
	        string SelectP='SELECT prod.Id, prod.ProductCode, prod.Description ';
	        string FromP='FROM Product2 prod ';
	        string WhereP='WHERE prod.ProductCode = :inputkey1 ';
	        string AndOrP='OR prod.Description like \'%'+inputkey1+'%\' ';
	        string LimitP='Limit 10';
	        string queryP= SelectP+FromP+WhereP+AndOrP+LimitP;
	        string queryPAll= SelectP+FromP+WhereP+AndOrP;
	        //Run Product Query
	        SelProd = Database.query(queryP);
	        SelProdAll = Database.query(queryPAll);
	        ProdAllCount = SelProdAll.size();
	        
	        //Declare Account Search Query
	        string OppId = '01290000000GI4PAAW';
	        string SelectA='SELECT Opportunity.AccountId AccId,Opportunity.Account.Name AccName, Opportunity.Account.OwnerId OwnerId, Opportunity.Account.Owner.Name OwnerName, Opportunity.Account.Direct_Marketing_Contact__c ContactDMID, Opportunity.Account.Direct_Marketing_Contact__r.Name ContactDM, Sum(Quantity) QTY, Sum(TotalPrice) Total ';
	        string FromA='FROM OpportunityLineItem ';
	        string WhereA='WHERE Opportunity.IsWon = True AND Opportunity.CloseDate >= :DateStart AND Opportunity.CloseDate <= :DateEnd AND Opportunity.RecordTypeId =: OppId  AND PricebookEntry.Product2Id IN :SelProdAll ';
	        string GroupA='GROUP BY Opportunity.AccountId,Opportunity.Account.Name,Opportunity.Account.OwnerId,Opportunity.Account.Owner.Name,Opportunity.Account.Direct_Marketing_Contact__c,Opportunity.Account.Direct_Marketing_Contact__r.Name ';
	        string LimitA='ORDER BY Sum(Quantity) Desc';
	        string queryA= SelectA+FromA+WhereA+GroupA+LimitA;
	        //Run Account Query
	  SelAccList = Database.query(queryA);
	  AccList.clear();
	  SelectAll = 'Select All';
		  if (SelAccList != null){
		  //Loop Through Aggregated Results
		    for(AggregateResult a:SelAccList){
		      AccList.add(new pAccount(String.valueOf(a.get('AccId')),String.valueOf(a.get('AccName')),String.valueOf(a.get('OwnerId')),String.valueOf(a.get('ContactDMID')),String.valueOf(a.get('ContactDM')),Integer.valueOf(a.get('QTY')),Double.valueOf(a.get('Total')),false,String.valueOf(a.get('OwnerName'))));
		    }
		  }
	  }
	}
    
  //Account select section populate with AccList
  public List<pAccount> getSelAcc(){
    return AccList;
  }
  
  //Select all accounts in AccList
  public void runSelectAll(){
  	if (AccList != null){
  		
		if (SelectAll == 'Select All'){
			SelectAll = 'De-Select All';
			//Run Select All Query
			for (integer i=0; i<AccList.size();i++){
				AccList[i].Selected = true;
			}
			
		} else if (SelectAll == 'De-Select All'){
			SelectAll = 'Select All';
			//Run De-Select All Query
			for (integer i=0; i<AccList.size();i++){
				AccList[i].Selected = false;
			}
		}
	}
  }

//STEP 2 - PROMO PRODUCT **************************************
  //Command Button for Promo Product Search
    public void SearchPromo(){
    if (inputkey2 == ''){
      if(SelPromo != null){
        SelPromo.clear();
        PromoCount = 0;
      }
    } else {
      //Declare Promo Product Search Query
      string SelectPP='SELECT prod.Id, prod.Product2Id, prod.ProductCode, prod.Name ';
      string FromPP='FROM PricebookEntry prod ';
      string WherePP='WHERE prod.ProductCode = :inputkey2 AND prod.Pricebook2Id = :PBookId'; 
      string queryPP= SelectPP+FromPP+WherePP;
        //Run Promo Product Query
        SelPromo = Database.query(queryPP);
        PromoCount = SelPromo.size();
    }
    }
 
  //Command Button for Promo Product Add
    public void AddPromo(){
    if (PromoList == null){
      PromoList = new list<PricebookEntry>();
      selectedProducts = new list<pProduct>();
    }
    
    if (SelPromo != null){
      if (SelPromo.size() == 1){
        set <PricebookEntry> ppSet = new Set<PricebookEntry>(PromoList);
        if (ppSet.contains(SelPromo[0])){
          
        } else {
          for(PricebookEntry pp:SelPromo){
            PromoList.add(pp);
            selectedProducts.add(new pProduct(pp.Id,pp.Product2Id,pp.ProductCode,pp.Name,1));
          }
        }
      }
    }
  }
  //Command Button to clear Promo Product list
  public void ClearPromo()
  {
    if (PromoList != null){
      PromoList.clear();
      selectedProducts.clear();

    }
  }

//STEP 3 - RUN DIRECT MARKETING & RECORD CREATION **************************************
  //Selected Accounts from AccList
    public list<pAccount> getSAccounts(){
    selectedAccounts.clear();
    for(pAccount aAcc: AccList) {
          if(aAcc.selected == true) {
              selectedAccounts.add(aAcc);
          }
      }return selectedAccounts;
    }
  
  //Load Promo Product QTY 
  public list<pProduct> getSProducts(){
    return selectedProducts;
  }
  
//STEP 4 - LET THE MAGIC HAPPEN **************************************
public void runMagic(){
  
  if (OppName == '') {
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a Direct Marketing Opportunity Name');
    ApexPages.addMessage(myMsg);
  } else if (selectedAccounts.size() == 0){
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select accounts to run a Direct Marketing on');
    ApexPages.addMessage(myMsg);
  } else if (selectedProducts == null){
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Promo Products to give via Direct Marketing');
    ApexPages.addMessage(myMsg);
  }
  //Check for selected accounts and promo products
  if (selectedAccounts.size() != 0){
    if (selectedProducts != null){
      if (OppName != null){
        //Finish Process
        if(Section3 == true){
            Section3 = false;
            Section4 = true;
          }
        // 1 - Create Opportunities on Account
        if(selectedAccounts != null){
          //Get RecordType ID for Opps 2bCreated
          //String INDExpInt = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('IND Expression of Interest').getRecordTypeId();
          //RecordType OppRecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'IND_Expression_of_Interest'];//Get RecordType ID
          for (pAccount a:selectedAccounts){
            Opportunity o = new Opportunity();
            o.Name = OppName;
            o.AccountId = a.AccId;
            o.OwnerId = a.OwnerId;
            o.Account_Contact__c = a.ContactDMID;
            o.CloseDate = Date.today().addDays(60);
            o.StageName = 'Demo/Loan Tools';
            o.RecordTypeId = '01290000000GI4PAAW';
            o.Pricebook2Id = PBookId;
            createOpps.add(o);
          }
        }insert createOpps; //Create opps on Account
        
        //2 - Create Products on Opportunities
        if(selectedProducts != null){
          if(createOpps != null){
            for (Opportunity o:createOpps){
              for (pProduct p:selectedProducts){
                OpportunityLineItem ol = new OpportunityLineItem();
                ol.OpportunityId = o.Id;
                ol.PricebookEntryId = p.PId;
                ol.Quantity = p.PromoQty;
                ol.UnitPrice = 0;
                createOppLine.add(ol);
              }
            }
          }    
        }insert createOppLine; //Create oppProducts on Account
      
        //3 - Create Activities on Accounts
        if(selectedAccounts != null){
          for (pAccount a:selectedAccounts){
            Task t = new Task();
            t.Status = 'In Progress';
            t.Subject = 'Follow up: '+ OppName;
            t.ActivityDate = Date.today().addDays(28);
            t.IsReminderSet = true;
            t.ReminderDateTime = Date.today().addDays(21);
            t.OwnerId = a.OwnerId;
            t.WhatId = a.AccId;
            t.Type = 'Other Event';
            t.Activity_SubType__c = 'Other (please specify)';
            t.Activity_SubType_Other__c = 'Direct Marketing';
            createTasks.add(t);
          }
      
        }   
        Database.DMLOptions notifyOption = new Database.DMLOptions();
        notifyOption.EmailHeader.triggerUserEmail = true;
        Database.insert(createTasks, notifyOption);
        
        //4 - Create TTI Forms on Accounts
        if(createOpps != null){
          //Get recordtype Id for TTI Forms 2b Created 
          String ZJSS = Schema.Sobjecttype.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Internal Order').getRecordTypeId();
          
          for (Opportunity o:createOpps){
            TTI_Form__c frm = new TTI_Form__c();
            frm.Form_Opportunity__c = o.Id;
            frm.Customer_Name__c = o.AccountId;
            frm.Urgent_Indicator__c = 'Yes';
            frm.Purpose_of_order__c = 'Direct Marketing';
            frm.Required_by_date__c = Date.today().addDays(1);
            frm.Approve_by__c = '00590000000qf8u';
            frm.OwnerId = o.OwnerId;
            frm.RecordTypeId = ZJSS;
            createForms.add(frm);
          }
        }insert createForms;
        
        //5 - Create TTI Form Products on TTI Forms
        if(selectedProducts != null){
          if (createOpps != null){
            for (TTI_Form__c f:createForms){
              for (pProduct p:selectedProducts){
                TTI_Form_Product__c frmP = new TTI_Form_Product__c();
                frmP.Form_Number__c = f.Id;
                frmP.SAP_Material_Number__c = p.ProdId;
                frmP.Quantity__c = p.PromoQty;
                createFormProds.add(frmP);
              }
            }
          }
        }insert createFormProds; //Create oppProducts on Account
        
        //6 - Auto submit created TTI Form for Approval
        if (createForms != null){
          list <Approval.Processsubmitrequest> requests = new list <Approval.Processsubmitrequest>();
          for (TTI_Form__c f:createForms){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Direct Marketing - Submitting request for approval');
            req1.setObjectId(f.Id);
            requests.add(req1);
          }
          Approval.ProcessResult[] processResults = null;
          try {
            processResults = Approval.process(requests, true);
          } catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
          }
        }
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Direct Marketing process has been run');
        ApexPages.addMessage(myMsg);
      }//End OppName
    }//End Promo prods
  }//End Selected Accounts
}

//NAVIGATION PANEL **************************************    
  //Next button logic
  public void NextStep()
  {
    if(Section1 == true){
      Section1 = false;
      Section2 = true;
    }
    else if(Section2 == true){
      Section2 = false;
      Section3 = true;
    }
  }
  //Back button logic
  public void BackStep()
  {
    if(Section2 == true){
      Section2 = false;
      Section1 = true;
    }
    if(Section3 == true){
      Section3 = false;
      Section2 = true;
    }
  }

//WRAPPER CLASS **************************************
    //Wrapper class to collect Accounts
  public class pAccount {
    public Id AccId {get; set;}
    public String AccName {get; set;}
    public Id OwnerId {get; set;}
    public Id ContactDMID {get; set;}
    public String ContactDM {get; set;}
    public Integer QTY {get; set;}
    public Double Total {get; set;}
    public Boolean Selected {get; set;}
    public String OwnerName {get; set;}
    public pAccount(Id a, string b, Id c, Id d, string e,integer f, double g, boolean h, string i){
      this.AccId=a;
      this.AccName=b;
      this.OwnerId=c;
      this.ContactDMID=d;
      this.ContactDM=e;
      this.QTY=f;
      this.Total=g;
      this.Selected=h;
      this.OwnerName=i;
    }
  }
    //Wrapper class to collect Promo Products & Quantity
  public class pProduct {
    public Id PId {get; set;}
    public Id ProdId {get; set;}
    public String ProdCode {get; set;}
    public String ProdName {get; set;}
    public Integer PromoQty {get; set;}
    public pProduct(Id a, Id b, string c, string d, integer e){
      this.PId=a;
      this.ProdId=b;
      this.ProdCode=c;
      this.ProdName=d;
      this.PromoQty=e;
    }
  }
  */

}