public with sharing class OpportunityProductExtension {

	public Opportunity oppty;
	public string Code {get;set;}
	public integer Qty {get;set;}
	public double Price {get;set;}
	public string PDesc {get;set;}
	
	public boolean Saved {get;set;}//trigger used on Submit button to close the VF page
	
	public string PBookId = '01s90000000DTDhAAO';//Industrial Pricebook
 	public list <PricebookEntry> SelProd {get;set;}//Select Promo Product based on search	
 	public list <OpportunityLineItem> createOppLine = new list <OpportunityLineItem>(); //Opportunity Products Container

	//Constructor On-Load
    public OpportunityProductExtension(ApexPages.StandardController stdController) {
        this.oppty = (Opportunity)stdController.getRecord();
        Saved = false;
        Qty = 1;
        Price = 1.1;
    }

	
    public void searchProduct() {
    	if (code == null){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please enter a product code!');
			ApexPages.addMessage(myMsg);
    	} else {
			//Product Search Query
			string SelectP='SELECT p.ProductCode, p.Pricebook2Id, p.Name, p.IsActive, p.Id ';
			string FromP='FROM PricebookEntry p ';
			string WhereP='WHERE  p.ProductCode = :code AND p.Pricebook2Id = :PBookId AND p.IsActive = true'; 
			string queryP= SelectP+FromP+WhereP;
			//Run Product Query
			SelProd = Database.query(queryP);
			system.debug('SelProd:'+SelProd);
			// if no product found
			if (SelProd.size() == 0){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No active product found!');
				ApexPages.addMessage(myMsg);
			} else {
				PDesc = SelProd[0].Name;
			}
    	}
    }
    
    public void addProduct() {
    	createOppLine.clear();
    	
    	if (code == null){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please enter a product code!');
			ApexPages.addMessage(myMsg);
    	} else {
			//Product Search Query
			string SelectP='SELECT p.ProductCode, p.Pricebook2Id, p.Name, p.IsActive, p.Id ';
			string FromP='FROM PricebookEntry p ';
			string WhereP='WHERE  p.ProductCode = :code AND p.Pricebook2Id = :PBookId AND p.IsActive = true'; 
			string queryP= SelectP+FromP+WhereP;
			//Run Product Query
			SelProd = Database.query(queryP);
			system.debug('SelProd:'+SelProd);
			// if no product found
			if (SelProd.size() == 0){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No active product found!');
				ApexPages.addMessage(myMsg);
			} else {
				PDesc = SelProd[0].Name;
			}
    	}
    	//*********************************************
		if (SelProd.size() == 0){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No active product found!');
				ApexPages.addMessage(myMsg);
		} else if (SelProd.size() == 1) {
			//Assign Industrial Pricebook to Opportunity if NULL
			Opportunity opp = [SELECT Name, Pricebook2Id FROM Opportunity WHERE Id =:oppty.Id];
			if (opp.Pricebook2Id == null){
				opp.Pricebook2Id = PBookId;
				try {
					upsert opp;//Assign Industrial Pricebook to Opp
				} catch (DMLException e){
					ApexPages.addMessages(e);
				}
			}
			
			//Set Qty to 1 if null or Zero
			if (Qty == null){
				Qty = 1;
			}else if (Qty == 0) {
				Qty = 1;
			}
			
			//create new opportunity line item
			OpportunityLineItem ol = new OpportunityLineItem();
			ol.OpportunityId = oppty.Id;
			ol.PricebookEntryId = SelProd[0].Id;
			ol.Quantity = Qty;
			ol.UnitPrice = Price;
			createOppLine.add(ol);
			try {
				insert createOppLine;//Create oppProducts on Account
				saved = true;
			} catch (DMLException e){
				ApexPages.addMessages(e);
			}
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Product: '+ PDesc +' has been added to opportunity');
			ApexPages.addMessage(myMsg);
    	}
    }

}