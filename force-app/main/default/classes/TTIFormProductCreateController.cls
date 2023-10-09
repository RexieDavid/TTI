/**
* @author: Jerome Liwanag
* @date: Feb 2017
* @description: This class is the controller for the (Name)VF page. It handles the logic
* required to display the page. Takes care of the insert operation of a TTI Form Product
* record using a search method AND a wrapper class
* @history:
* <Date>            <Author>                    <Description>
* 05-May-2017       Stephen James Laylo         Added pagination functionality
* 17-July-2023      John Lawrence Catan         Added validation for INC0037342/SD-2301
*/ 
public class TTIFormProductCreateController {
    
    // Class variables
    public List<Product2> prods = new List<Product2>();
    public List<ProductWrapper> prodWrap { get; set; }
    public List<ProductWrapper> prodWrapCon { get; set; }
    public List<Product2> selectedProduct { get; set; } 
    public TTI_Form_Product__c ttiFormProduct { get; set; } 
    public TTI_Form__c ttiForm { get; set; } 
    public Product2 product { get; set; } 
    public String searchString { get; set; } 
    public Id formId { get; set; } 
    public Map<Product2, Integer> mapTTIForm { get; set; }

    public Integer page { get; set; }
    public Integer pageSize { get; set; }
    public Integer totalSize  { get; set; }
    public Integer totalPages { get; set; }
    public Set<Id> selectedIds = new Set<Id>();
    public String nzNote { get; set; }
    
    // TTI Form's Record Types
    private Id demoSamppleRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Demo Sample Request').getRecordTypeId();
    private Id promoStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
    private Id showroomStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId();
    private Id zjssInternalRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('ZJSS Internal Order').getRecordTypeId();

    // Brand Defaults
    private List<Brand_Defaults__c> brandDefaults;
    
    // Constructor
    public TTIFormProductCreateController() {
        this.nzNote = '';
        this.ttiFormProduct = new TTI_Form_Product__c();
        this.mapTTIForm = new Map<Product2,Integer>();
        this.ttiFormProduct.Form_Number__c = ApexPages.currentPage().getParameters().get('Id');
        this.formId = System.currentPageReference().getParameters().get('Id');
        this.selectedProduct = new List<Product2>();
        this.prodWrap = new List<ProductWrapper>();
        this.prodWrapCon = new List<ProductWrapper>();
        this.page = 0;
        this.pageSize = 20;
        this.totalSize = 0;
        this.totalPages = 0;

        // Get Brand Defaults
        this.brandDefaults = Brand_Defaults__c.getall().Values();

        // Query the products that is record type dependent on first load
        runSearch(true);
        // Adding the list of products to a wrapper
        //ProductWrapperObject();

        first();
    }
    
    public void ProductWrapperObject() {
        for (Product2 prodLoop : prods) {
            ProductWrapper pWrap = new ProductWrapper(prodLoop);
            prodWrap.add(pWrap);
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Gets the selected product through a checkbox
    * AND put it in a wrapper together with the quantity
    */ 
    public void getSelected() {
        this.mapTTIForm.clear();
        this.selectedProduct.clear();

        for (ProductWrapper pwrap : prodWrap) {
            if (pwrap.selected == true) {
                this.selectedProduct.add(pwrap.prod);
                this.mapTTIForm.put(pwrap.prod, pwrap.quantity);
                selectedIds.add(pwrap.prod.Id);
            }
        }
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Initiates the 'Save' button to insert
    * the TTI Form Product(s) depending on the product(s) selected
    * @history:
    * <Date>            <Author>                    <Description>
    * 18-Apr-2017       Stephen James Laylo         Modified the logic to handle selected products with zero quantities
    */ 
    public PageReference save() {
        
        getSelected();
        List<TTI_Form_Product__c> ttiFormProdList = new List<TTI_Form_Product__c>();
        Boolean validationFlag = false;
        Boolean existingMQTL = false;
        
        //Query current user to check for Rounding Profile
        TTI_Form__c currentTTIForm = [SELECT Id,Name, ownerId, RecordTypeId, Delivery_Country__c FROM TTI_Form__c WHERE Id = :formid];
        User currentUser = [SELECT Id, Name, Country FROM user WHERE Id = :currentTTIForm.ownerId];
        
        
        //Query existing Form Products to check for any MQ-TL products
		List<TTI_Form_Product__c> ttiFormProdExisting = [SELECT Id, Name, Form_Number__c FROM TTI_Form_Product__c 
                                                         WHERE Form_Number__c =: formid AND SAP_Material_Number__r.SAP_Material_Group__c = 'MQ-TL'];
        
        /*Added validation for MQ-TL products for INC0037342/SD-2301
         * MQ-TL Products cannot be added with other SAP Material groups
        */
        if(!ttiFormProdExisting.isEmpty()){
            existingMQTL = true;
        }
        
        if (!this.selectedProduct.isEmpty()) {
            for (Product2 prodLoop : this.selectedProduct){
                if(prodLoop.SAP_Material_Group__c == 'MQ-TL'){
                    validationFlag = true;
                }
            }
        }
        
        if (!this.selectedProduct.isEmpty()) {
            for (Product2 prodLoop : this.selectedProduct) {
                
                /*Added validation for MQ-TL products for INC0037342/SD-2301 by John Lawrence Catan
                * MQ-TL Products cannot be added with other SAP Material groups
                */
                if(existingMQTL && currentTTIForm.RecordTypeId == promoStockRecId){
                    // Error Handling
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'There is an existing MQ-TL (MX Product) SAP material group product. You cannot order MQ-TL (MX Product) SAP material group product with the other material groups.');
                    ApexPages.addMessage(myMsg);
                    ApexPages.currentPage().getParameters().put('Id', formid);
                    PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                    return pr;
                }
                
                /*Added validation for MQ-TL products for INC0037342/SD-2301 by John Lawrence Catan
                * MQ-TL Products cannot be added with other SAP Material groups
                */
                if(validationFlag && prodLoop.SAP_Material_Group__c != 'MQ-TL' && currentTTIForm.RecordTypeId == promoStockRecId){
                    // Error Handling
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot order MQ-TL (MX Product) SAP material group product with the other material groups.');
                    ApexPages.addMessage(myMsg);
                    ApexPages.currentPage().getParameters().put('Id', formid);
                    PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                    return pr;
                }
                
                if (this.mapTTIForm.containsKey(prodLoop)) {
                    if (this.mapTTIForm.get(prodLoop) > 0) {
                        ttiFormProdList.add(new TTI_Form_Product__c(SAP_Material_Number__c = prodLoop.Id, Quantity__c = this.mapTTIForm.get(prodLoop), Form_Number__c = ApexPages.currentPage().getParameters().get('Id')));
                    } else {
                        // Error Handling
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please put a quantity to each selected product.');
                        ApexPages.addMessage(myMsg);
                        ApexPages.currentPage().getParameters().put('Id', formid);
                        PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                        return pr;
                    }
                }
                
                /*Added validation for INC0024762/SD-2321
                 * 07-17-2023 John Lawrence Catan 
                 *YG01 - Rounding Profile for PAC, YG02 - Rounding Profile for CAR 
				*/
                
                System.debug('currentUser.Country = ' + currentUser.Country);
                System.debug('currentUser.Name = ' + currentUser.Name);
                System.debug('currentUser.Name = ' + currentUser.Id);
				System.debug('Rounding_Profile_AU__c = ' + prodLoop.Rounding_Profile_AU__c);
                System.debug('Rounding_Profile_NZ__c = ' + prodLoop.Rounding_Profile_NZ__c);
				System.debug('prodLoop.PAC__c = ' + prodLoop.PAC__c);
				System.debug('prodLoop.CAR__c = ' + prodLoop.CAR__c); 
				System.debug('quantity = ' + this.mapTTIForm.get(prodLoop));     
				//System.debug('mod = ' + math.mod(this.mapTTIForm.get(prodLoop), Integer.valueof(prodLoop.PAC__c)));
                //System.debug('divide = ' + this.mapTTIForm.get(prodLoop)/prodLoop.PAC__c); 
                
                Decimal D1;
				Decimal D2;
                
                if(prodLoop.PAC__c != NULL)
                D1 = this.mapTTIForm.get(prodLoop)/prodLoop.PAC__c;
                
                if(prodLoop.CAR__c != NULL)
                D2 = this.mapTTIForm.get(prodLoop)/prodLoop.CAR__c;
                
                //AU only and YG01 with PAC
                if((currentUser.Country != NULL && (currentUser.Country.equalsignorecase('AU') || currentUser.Country.equalsignorecase('Australia'))) 
                    && prodLoop.Rounding_Profile_AU__c != NULL && prodLoop.Rounding_Profile_AU__c == 'YG01' &&
                   prodLoop.PAC__c != NULL && Math.abs(D1 - D1.intValue()) != 0){//D1.precision()>=1){
                    // Error Handling
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'The quantity of ' + prodLoop.Name + ' should be equal to multiples of ' + prodLoop.PAC__c +'.');
                    ApexPages.addMessage(myMsg);
                    ApexPages.currentPage().getParameters().put('Id', formid);
                    PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                    return pr;
                }
                
                //AU only and YG02 with CAR
                if((currentUser.Country != NULL && (currentUser.Country.equalsignorecase('AU') || currentUser.Country.equalsignorecase('Australia')))
                    && prodLoop.Rounding_Profile_AU__c != NULL && prodLoop.Rounding_Profile_AU__c == 'YG02' &&
                   prodLoop.CAR__c != NULL && Math.abs(D2 - D2.intValue()) != 0){//D2.precision()>=1){
                    // Error Handling
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'The quantity of ' + prodLoop.Name + ' should be equal to multiples of ' + prodLoop.CAR__c +'.');
                    ApexPages.addMessage(myMsg);
                    ApexPages.currentPage().getParameters().put('Id', formid);
                    PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                    return pr;
                }

                //NZ YG01 with PAC
                if((currentUser.Country != NULL && (currentUser.Country.equalsignorecase('NZ') || currentUser.Country.equalsignorecase('New Zealand'))) 
                    && prodLoop.Rounding_Profile_NZ__c != NULL && prodLoop.Rounding_Profile_NZ__c == 'YG01' &&
                    prodLoop.PAC__c != NULL && Math.abs(D1 - D1.intValue()) != 0){//D1.precision()>=1){
                        // Error Handling
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'The quantity of ' + prodLoop.Name + ' should be equal to multiples of ' + prodLoop.PAC__c +'.');
                        ApexPages.addMessage(myMsg);
                        ApexPages.currentPage().getParameters().put('Id', formid);
                        PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                        return pr;
                    }
                
                //NZ and YG02 with CAR
                if((currentUser.Country != NULL && (currentUser.Country.equalsignorecase('NZ') || currentUser.Country.equalsignorecase('New Zealand')))
                    && prodLoop.Rounding_Profile_NZ__c != NULL && prodLoop.Rounding_Profile_NZ__c == 'YG02' &&
                   prodLoop.CAR__c != NULL && Math.abs(D2 - D2.intValue()) != 0){//D2.precision()>=1){
                    // Error Handling
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'The minimum quantity of ' + prodLoop.Name + ' should be equal to multiples of ' + prodLoop.CAR__c +'.');
                    ApexPages.addMessage(myMsg);
                    ApexPages.currentPage().getParameters().put('Id', formid);
                    PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
                    return pr;
                }

            } 
            
            try {
                insert ttiFormProdList;
            } catch (DMLException e) {
                for (TTI_Form_Product__c ttiLoop : ttiFormProdList) {
                    ttiLoop.addError('There was a problem with the creation of TTI Form Product - ' + ttiLoop);
                } 
            } 
            
        } else {
            // Error Handling
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please SELECT a Product to add');
            ApexPages.addMessage(myMsg);
            ApexPages.currentPage().getParameters().put('Id', formid);
            PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
            return pr;
        } 
        
        PageReference reRend = new ApexPages.StandardController(ttiformproduct).view();
        reRend.setRedirect(true);
        return reRend;
    } 
    
    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Initiates the 'Cancel' button to go redirect
    * to previous page
    */ 
    public PageReference cancel() {
        PageReference reRend = new ApexPages.StandardController(ttiformproduct).view();
        reRend.setRedirect(true);
        return reRend;
    } 
    

    /**
    * @author: Jerome Liwanag
    * @date: Feb 2017
    * @description: Initiates the 'Search' button to help
    * narrow down products
    */ 
    public PageReference search() {
        runSearch(false);
        return null;
    } 
    
    private void runSearch(Boolean isPagination) {
        if (!isPagination) {
            this.page = 0;
        }
        if (searchString != null){
        searchString = searchString.trim();
        }
        prods = performSearch(searchString);

        // Clears the wrapper to display the search results properly
        Integer j = 0;
        while (j < prodWrap.size()) {
            if (prodWrap.get(j).selected == false) {
                prodWrap.remove(j);
            } else {
                selectedIds.add(prodWrap.get(j).prod.id);
                j ++;
            } 
        } 
        
        for (Product2 a : prods) {
            if(!selectedIds.contains(a.Id)){
            ProductWrapper aw = new ProductWrapper(a);
            prodWrap.add(aw);
            }
        }
    } 
    
    private List<Product2> performSearch(String searchString) {
        
        TTI_Form__c ttiForm = [SELECT RecordTypeId, Name, Id, ownerId, Account_Sales_Organisation__c FROM TTI_Form__c WHERE Id = :formid];
        if (ttiform.Account_Sales_Organisation__c == GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_NZ01){
            nzNote = 'Please Note: Spare Parts will not be displayed for New Zealand';
        }
        //Updated query for INC0024762/SD-2321 adding Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c, CAR__c
        //07-17-2023 John Lawrence Catan 
        String q1 = 'SELECT Id, Name, SAP_Material_Group__c, SAP_MaterialNumber__c, AU_MRPty__c, NZ_MRPty__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c, CAR__c FROM Product2';
        String soql = q1;
        String soql2 = '';

        User u = [SELECT Division FROM user WHERE Id = :ttiForm.ownerId];
        Integer count = 0;

        String disabledMRPTypes;
        for (Brand_Defaults__c brandDefaultsLoop : Brand_Defaults__c.getall().Values()) {
            if (Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get(brandDefaultsLoop.Record_Type_Name__c).getRecordTypeId() == ttiForm.RecordTypeId
                    && brandDefaultsLoop.Division__c == u.Division && ttiForm.Account_Sales_Organisation__c == brandDefaultsLoop.Sales_Organisation__c) {

                disabledMRPTypes = brandDefaultsLoop.Disabled_MRP_Types__c;
                for (String groupString : brandDefaultsLoop.SAP_Material_Group__c.split(';')) {
                    count ++;
                    if (count == 1) {
                        if (!groupString.contains('%')) {
                            soql = soql + ' WHERE (SAP_Material_Group__c = \'' + groupString + '\'';
                        } else {
                            soql = soql + ' WHERE (SAP_Material_Group__c LIKE \'' + groupString + '\'';
                        } 
                    } 
                    if (count > 1) {
                        if (!groupString.contains('%')) {
                            soql = soql + ' OR SAP_Material_Group__c = \'' + groupString + '\'';
                        } else {
                            soql = soql + ' OR SAP_Material_Group__c LIKE \'' + groupString + '\'';
                        } 
                    } 
                } 
                soql = soql + ')';
            } 
        } 
        
        if (searchString != '' && searchString != null) {
            if (count > 0) {
                soql = soql +  ' AND (Name LIKE \'%' + searchString + '%\' OR SAP_MaterialNumber__c LIKE \'%' + searchString + '%\')' + 
                'AND ((NZ_MRPty__c != \'ZN\' AND NZ_MRPty__c != \'\') OR (AU_MRPty__c != \'ZN\' AND AU_MRPty__c != \'\'))';
            } else {
                soql = soql +  ' WHERE (Name LIKE \'%' + searchString + '%\' OR SAP_MaterialNumber__c LIKE \'%' + searchString + '%\')' + 
                'AND ((NZ_MRPty__c != \'ZN\' AND NZ_MRPty__c != \'\') OR (AU_MRPty__c != \'ZN\' AND AU_MRPty__c != \'\'))';}
        } else {
            if (count > 0) {
                soql = soql +  ' AND ((NZ_MRPty__c != \'ZN\' AND NZ_MRPty__c != \'\') OR (AU_MRPty__c != \'ZN\' AND AU_MRPty__c != \'\'))';
            } else {
                soql = soql +  ' WHERE ((NZ_MRPty__c != \'ZN\' AND NZ_MRPty__c != \'\') OR (AU_MRPty__c != \'ZN\' AND AU_MRPty__c != \'\'))';
            }
        }

        soql2 = soql.replace(q1, 'SELECT COUNT() FROM Product2');
        if (count == 0){
            soql2 = soql2 + ' LIMIT 2000';
        }
        this.totalSize = Database.countQuery(soql2);
        if (this.totalSize > 2000) {
            this.totalSize = 2000;
        }
        this.totalPages = (Integer) Math.ceil(((Double) this.totalSize) / ((Double) this.pageSize));

        soql = soql + ' LIMIT ' + this.pageSize + ' OFFSET ' + this.page;
        
        // Executes the query
        List<Product2> products = Database.query(soql);

        if (String.isNotBlank(disabledMRPTypes)) {
            products = this.excludeDisabledProducts(products, disabledMRPTypes, ttiForm.Account_Sales_Organisation__c);
        }

        return products;

    }

    /**
    * @author: Francis Nasalita
    * @date: 2021/10/13
    * @description: Filters retrieved products and exclude disabled products with MRP Types
    * defined in brands default
    */ 
    private List<Product2> excludeDisabledProducts(List<Product2> products, String disabledMRPTypes, String salesOrganization) {
        List<Product2> filteredProducts = new List<Product2>();

        for (Product2 product : products) {
            Boolean isAUAndDisabledProduct = String.isNotBlank(product.AU_MRPty__c) && salesOrganization == 'BP01' && disabledMRPTypes.contains(product.AU_MRPty__c);
            Boolean isNZAndDisabledProduct = String.isNotBlank(product.NZ_MRPty__c) && salesOrganization == 'NZ01' && disabledMRPTypes.contains(product.NZ_MRPty__c);

            if (isAUAndDisabledProduct || isNZAndDisabledProduct) {
                continue;
            }

            filteredProducts.add(product);
        }

        return filteredProducts;
    }

    public Boolean hasNext {
        get {
            return (this.page + this.pageSize < this.totalSize);
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return (this.page > 0);
        }
        set;
    }
    
    public void next() {
        this.page += this.pageSize;
        runSearch(true);
    }
    
    public void previous() {
        this.page -= this.pageSize;
        runSearch(true);
    }

    public void first() {
        this.page = 0;
        runSearch(true);
    }
    
    public void last() {
        this.page = this.totalSize - Math.mod(this.totalSize, this.pageSize);

        if (Math.mod(this.totalSize, this.pageSize) == 0) {
            previous();
        }

        runSearch(true);
    }
    
    public class ProductWrapper {
        public Product2 prod { get; set; } 
        public Boolean selected { get; set; } 
        public Integer quantity { get; set; } 
        
        public ProductWrapper(Product2 p) {
            this.prod = p;
            this.selected = false;
            this.quantity = 0;
        } 
    }

}