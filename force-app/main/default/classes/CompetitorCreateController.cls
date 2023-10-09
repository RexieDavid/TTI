/**
* @author: Stephen James Laylo
* @date: June 2017
* @description: This class is the controller for the CompetitorCreate VF page. It handles the logic
* required to display the page. Takes care of the insert operation of a Competitor record
*/ 
public class CompetitorCreateController {
	public List<Competitor__c> competitors { get; set; }
	public List<Competitor__c> deletedCompetitors { get; set; }
	public String selectedRowIndex { get; set; }
	public Competitor__c competitor { get; set; }
	public Sales_Pitch__c spProductCat { get; set; }
	public Boolean isSaveButtonClicked { get; set; }
	
	public Integer count = 1;
	private String retUrl;
	private String salesPitchId;
	private List<Competitor_Brand__c> competitorBrands;
	
	// Constructor
	public CompetitorCreateController() {
	    initialize();
	}
	
	public CompetitorCreateController(ApexPages.StandardController stdController) {
	    initialize();
	}
	
	public void initialize() {
	    competitors = new List<Competitor__c>();
	    deletedCompetitors = new List<Competitor__c>();
	    competitor = new Competitor__c();
	    spProductCat = new Sales_Pitch__c();
	    competitorBrands = new List<Competitor_Brand__c>([SELECT Id, Name FROM Competitor_Brand__c WHERE Parent_Brand__c != null ORDER BY Name ASC]);

	    isSaveButtonClicked = false;
	    
	    retUrl = ApexPages.currentPage().getParameters().get('retUrl');
	    salesPitchId = ApexPages.currentPage().getParameters().get('salesPitchId');
	    
	    competitor.Sales_Pitch__c = salesPitchId;
	    spProductCat = [SELECT Opportunity_Product_Category__r.Name, (SELECT Id, Sub_Brand__c, SKU_Count__c, Estimated_Value__c, Primary_Supplier__c, Comment__c FROM Competitors__r) FROM Sales_Pitch__c WHERE Id = :salesPitchId LIMIT 1];
	    if (!spProductCat.Competitors__r.isEmpty()) {
	        competitors = spProductCat.Competitors__r;
	    } else {
	        addMore();
	    }
        
        selectedRowIndex = '0';
        
        if (retUrl == null) {
            retUrl = '/' + Competitor__c.sObjectType.getDescribe().getKeyPrefix();
        }
	}

	public List<SelectOption> getBrandsOptions() {
		List<SelectOption> options = new List<SelectOption>(); 
		options.add(new SelectOption('', '- None -')); 

		for (Competitor_Brand__c brand : competitorBrands) { 
			options.add(new SelectOption(brand.Id, brand.Name)); 
		}

		return options;
	}

	public PageReference save() {
	    List<Competitor__c> compList = new List<Competitor__c>();
	    for (Competitor__c competitor : competitors) {
	        if (competitor.Id == null) {
	            competitor.Sales_Pitch__c = salesPitchId;
	        }
	        if (competitor.Sub_Brand__c == null){
	            compList.add(competitor);
	        }
	    }
	    
	    if (!compList.isEmpty()) {
	        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please put a Competitor to each row added');
            ApexPages.addMessage(myMsg);
            PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
            
            return pr;
	    }
	    
		upsert competitors;
		
		if (!deletedCompetitors.isEmpty()) {
		    delete deletedCompetitors;
		}
		
		PageReference reRend = new PageReference(retUrl);
        reRend.setRedirect(true);
        return reRend;
	}
	
	public PageReference cancel() {
		PageReference reRend = new PageReference(retUrl);
        reRend.setRedirect(true);
        return reRend;
	}
	
	public void add() {	
		count = count + 1;
		addMore();		
	}
	
	public void addMore() {
		Competitor__c cmp = new Competitor__c();
		competitors.add(cmp);
    }
	
	public void del() {
	    if (competitors.get(Integer.valueOf(selectedRowIndex) - 1).Id != null) {
	        deletedCompetitors.add(competitors.get(Integer.valueOf(selectedRowIndex) - 1));
	    }
		competitors.remove(Integer.valueOf(selectedRowIndex) - 1);
		count = count - 1;
	}
}