/**
* Created by Haider Raza on 11/01/2017.
*/

public class M12Stocktake {
    
    public M12Stocktake(ApexPages.StandardController controller) {
        
    }   
    
    private String cTime = ApexPages.currentPage().getParameters().get('uniqueId');
    private List<cProducts> m12Products { get; set; }
    
    public Boolean isEditable{
        get{
            if (isEditable == null) {
                isEditable = false;
            }
            return isEditable;
        }
        set;
    }
    
    public String currentAccountId{
        get{
            if (currentAccountId == null) {
                currentAccountId = ApexPages.currentPage().getParameters().get('id');
            }
            return currentAccountId;
        }
        set;
    }
    
    private String qry;
    
    public class cProducts{
        public Boolean isSelected { get; set; }
        public M12_Inventory__c m12Product { get; set; }
        public Decimal Variance { get; set; }
        public Decimal Quantity { get; set; }
        public Boolean Displayed { get; set; }
        public Double TotalPrice { get; set; }
        public Boolean IsMandatoryDisplay { get; set; }
        public String M12ProductCategory { get; set; }
        public Integer M12ProductCategorySort { get; set; }
        public String ProductId { get; set; }
        private M12_Inventory__c prod;
        private Decimal SuggestedOrderQty;
        
        public cProducts(M12_Inventory__c prod) {
            this.prod = prod;
            this.Displayed = false;
            this.isSelected = false;
            this.m12Product = this.prod;
            this.Quantity = 0;
            this.IsMandatoryDisplay = this.prod.Is_Mandatory_Display__c;
            this.M12ProductCategory = this.prod.M12_Product_Category__c;
            this.M12ProductCategorySort = Integer.valueOf(this.prod.M12_Product_Category_Sort__c);
            this.ProductId = this.prod.Product__c;
            refresh();
        }
        
        public void refresh() {
            this.Variance = this.prod.Required_Quantity__c == null ? 0 : this.Quantity - Integer.valueOf(this.prod.Required_Quantity__c);
            this.SuggestedOrderQty = this.Variance * -1;
            this.SuggestedOrderQty = (this.SuggestedOrderQty < 0) ? 0 : this.SuggestedOrderQty;
            
            this.TotalPrice =  (this.SuggestedOrderQty) * (this.prod.M12_Hub_Price_per_unit__c == null ? 0 : this.prod.M12_Hub_Price_per_unit__c) ;
        }
    }
    
    public void updateM12Quantity() {
        try {
            for (cProducts p : m12Products) {
                p.Variance = (p.Quantity == null ? 0 : p.Quantity) - (p.m12Product.Required_Quantity__c == null ? 0 : Integer.valueOf(p.m12Product.Required_Quantity__c));
                if (p.Variance <= 0) {
                    p.TotalPrice = ((p.m12Product.Required_Quantity__c == null ? 0 : p.m12Product.Required_Quantity__c) - p.Quantity) * (p.m12Product.M12_Hub_Price_per_unit__c == null ? 0 : p.m12Product.M12_Hub_Price_per_unit__c);
                } else {
                    p.TotalPrice = 0;
                }
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid input. ' + ex.getMessage()));
        }
    }
    

    public String m12StocktakeId { get; set; }
    
    public void processM12Stocktake() {
        updateM12Quantity();
        
    	List<M12_Stocktake_Inventory__c> m12Stocktake = new List<M12_Stocktake_Inventory__c>();
        
        if (m12StocktakeId == null) {
            m12StocktakeId = this.createM12Stocktake();
        }

        for (cProducts p : m12Products) {
            String key = cTime + '' + p.m12Product.Id + m12StocktakeId + p.M12ProductCategory + p.ProductId;
            m12Stocktake.add(new M12_Stocktake_Inventory__c(Display__c = p.Displayed, 
                                                            M12_Inventory__c = p.m12Product.Id,
                                                            M12_Stocktake__c = m12StocktakeId,
                                                            Stocktake_Quantity__c = p.Quantity, 
                                                            Unique_Key__c = key,
                                                            Variation__c = p.Variance, 
                                                            Total_Price__c = p.TotalPrice));
        }
        
        if (m12Stocktake.size()>0) {
            try {                
                Schema.SObjectField keyField = M12_Stocktake_Inventory__c.Fields.Unique_Key__c;
                Database.upsert(m12Stocktake, keyField, true);
                
                isEditable = true;
                //isShareable = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved Successfully.'));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to save. '+ex.getMessage()));
            }
        }
    }
    
    public PageReference submitM12Stocktake() {
        try {
            processM12Stocktake();
            M12_Stocktake__c stockSubmitted = new M12_Stocktake__c(Id = m12StocktakeId, Submitted__c = true, Submitted_Date__c = System.now());
            upsert stockSubmitted;
            
            PageReference shareM12 = Page.ShareM12Stocktake;
            shareM12.getParameters().put('Id', m12StocktakeId);
            shareM12.getParameters().put('accId', currentAccountId);
            shareM12.setRedirect(true);
            
            return shareM12;
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to save. '+ex.getMessage()));
            return null;
        }
    }
    
    public String createM12Stocktake() {
        Schema.SObjectField keyField = M12_Stocktake__c.Fields.Unique_Key__c;
        String key = cTime + '' + currentAccountId;
                
        M12_Stocktake__c m12Stock = new M12_Stocktake__c(Account__c = currentAccountId, Unique_Key__c = key);
        Database.upsert(m12Stock, keyField, true);
        
        return m12Stock.Id;
    }
    
    public List<cProducts> getProducts() {
        if (m12Products == null) {
            m12Products = new List<cProducts>();
            String key = cTime + '' + currentAccountId;
            Map<Id, M12_Stocktake_Inventory__c> m12StocktakeInvMap = new Map<Id, M12_Stocktake_Inventory__c>();
            
            for (M12_Stocktake_Inventory__c m12StocktakeInv : [SELECT M12_Stocktake__c, M12_Inventory__c, M12_Inventory__r.M12_Product_Category__c, M12_Inventory__r.Product__c, Stocktake_Quantity__c, Unique_Key__c FROM M12_Stocktake_Inventory__c WHERE M12_Stocktake__r.Unique_Key__c = :key]) {
                if (m12StocktakeInv.Unique_Key__c == (cTime + m12StocktakeInv.M12_Inventory__c + m12StocktakeInv.M12_Stocktake__c + m12StocktakeInv.M12_Inventory__r.M12_Product_Category__c + m12StocktakeInv.M12_Inventory__r.Product__c)) {
                    m12StocktakeInvMap.put(m12StocktakeInv.M12_Inventory__c, m12StocktakeInv);
                }
            }

            for (M12_Inventory__c p : (List<M12_Inventory__c>) con.getRecords()) {
                cProducts cProd = new cProducts(p);
                if (m12StocktakeInvMap.containsKey(p.Id)) {
                    cProd.Quantity = m12StocktakeInvMap.get(p.Id).Stocktake_Quantity__c;
                    cProd.refresh();
                }
                
                m12Products.add(cProd);
            }
        }
        return m12Products;
    }
    
    public ApexPages.StandardSetController con{
        get{
            if (con == null) {
                if (qry == null) qry = prepareQryString();
                con = new ApexPages.StandardSetController(Database.getQueryLocator(qry));
                con.setPageSize(200);
            }
            return con;
        }
        set;
    }
    
    public String prepareQryString() {
        return 'SELECT Id, Is_Active__c, M12_Hub_Price_per_unit__c, Product__c, Required_Quantity__c, Name, Is_Mandatory_Display__c, ' +
                'Product__r.Name, Product__r.SAP_MaterialNumber__c, Product__r.ProductCode, Product__r.SAP_Product_Heirarchy__c, ' +
                'M12_Product_Category__c, M12_Product_Category_Sort__c ' +
                'FROM M12_Inventory__c ' +
                'WHERE Is_Active__c = true ' +
                'ORDER BY M12_Product_Category_Sort__c, Product__r.ProductCode ';
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    public String pageDetail{
        get{
            return 'Page ' + con.getPageNumber() + ' of ' + Math.ceil(con.getResultSize() / 500.0);
        }
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns the first page of records
    public void first() {
        con.first();
    }
    
    // returns the last page of records
    public void last() {
        con.last();
    }
    
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
    
    // returns the next page of records
    public void next() {
        con.next();
    }
    
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
}