/**
* @author: Jerome Liwanag
* @date: June 2017
* @description: This class is the controller for the (Name)VF page. It handles the logic
* required to display the page. Takes care of the insert operation of a Catalogue Product
* record using a search method and a wrapper class
*/ 
public class CatalogueProductCreateController
{
	public List<Catalogue_Product__c> lstCatalogueProd  = new List<Catalogue_Product__c>(); //will hold the account records to be saved
	public List<CatalogueWrapper> catWrap {get;set;} //list of the inner class
	public String selectedRowIndex {get;set;} //will indicate the row to be deleted	
	public Catalogue_Product__c catSub {get; set;}
	public Integer count = 1; //no. of rows added/records in the inner class list
	// Constructor
	public CatalogueProductCreateController()
	{   
	    catSub = new Catalogue_Product__c();
	    catSub.Catalogue__c = ApexPages.currentPage().getParameters().get('Id');
        catWrap = new List<CatalogueWrapper>();
        addMore();
        selectedRowIndex = '0';
        
	}
	
	public PageReference save()
	{
	    lstCatalogueProd.clear();
	    Integer errors = 0;
		for(Integer j = 0;j<catWrap.size();j++)
		{   
		    
		    //if(catWrap[j].catalogueProd.Product__c != null && catWrap[j].catalogueProd.Dealer_Pricing__c == null){
		       // errors++;
		        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Add a Dealer Price for each Product added');
                //ApexPages.addMessage(myMsg);
		    //}
		    //else 
                if(catWrap[j].catalogueProd.Product__c != null){
    		    catWrap[j].catalogueProd.Catalogue__c = catSub.Catalogue__c;
    			lstCatalogueProd.add(catWrap[j].catalogueProd);
		    }
		}
		
		if(!lstCatalogueProd.isEmpty() && errors == 0){
		    insert lstCatalogueProd;
		}
		else{
		    
		    if(errors > 0){
		        return null;
		    }
		    else{
    		    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Insert at least 1 product');
                ApexPages.addMessage(myMsg);
                return null;
		    }
		}
		PageReference reRend = new ApexPages.StandardController(catSub).view();
        reRend.setRedirect(true);
        return reRend;
	    
	}
	
	public PageReference cancel()
	{
		PageReference reRend = new ApexPages.StandardController(catSub).view();
        reRend.setRedirect(true);
        return reRend;
	}
	
	public void add()
	{	
		count = count+1;
		addMore();		
	}
	
	public void addMore()
	{
		CatalogueWrapper cw = new CatalogueWrapper(count); //call to the iner class constructor
		catWrap.add(cw); //add the record to the inner class list 
    }
	
	public void del()
	{
		catWrap.remove(Integer.valueOf(selectedRowIndex)-1);
		count = count - 1;
	}
	
	public class CatalogueWrapper
	{
		public String recCount {get;set;} // recCount acts as a index for a row. This will be helpful to identify the row to be deleted
		public Catalogue_Product__c catalogueProd {get;set;}
		
		public CatalogueWrapper(Integer intCount)
		{
			recCount = String.valueOf(intCount);	
			catalogueProd = new Catalogue_Product__c();
			
		}	
	}
}