/**
 * Created by Haider Raza on 15/01/2017.
 */

public class M12StocktakeModify {
    public M12StocktakeModify(ApexPages.StandardController controller) {}
    public String siIdToUpdate{get; set;}

    String currentId {
        get {
            if (currentId == null) {
                currentId = ApexPages.currentPage().getParameters().get('Id');
            }
            return currentId;
        }
        set;
    }
    
    String accId {
        get {
            if (accId == null) {
                if (ApexPages.currentPage().getParameters().get('retURL') != null) {
                    accId = ApexPages.currentPage().getParameters().get('retURL');
                } else {
                    accId = [SELECT Account__c FROM M12_Stocktake__c WHERE Id=: currentId].Account__c;
                }
            }
            return accId;
        }
        set;
    }
    
    String qry = 'SELECT Id, (SELECT Id, Display__c, Inverse_Variation__c, M12_Inventory__c, M12_Inventory__r.Product__r.Name, M12_Inventory__r.Is_Mandatory_Display__c, '+
                    'M12_Stocktake__c, Stocktake_Quantity__c, Variation__c, M12_Inventory__r.Product__r.SAP_MaterialNumber__c, M12_Inventory__r.M12_Hub_Price_per_unit__c, '+
                    'M12_Inventory__r.Product__r.ProductCode, M12_Inventory__r.Product__r.SAP_Product_Heirarchy__c, M12_Inventory__r.Required_Quantity__c, Total_Price__c  '+
                    'FROM M12_Stocktake_Inventory__r) '+
                    'FROM M12_Stocktake__c '+
                    'WHERE Id=\''+currentId+'\'';

    public List<M12_Stocktake__c> m12Stocktakes{
        get {
            if (m12Stocktakes == null) {
                m12Stocktakes = (List<M12_Stocktake__c>)con.getRecords();
            }
            return m12Stocktakes;
        }
        set;
    }

    public PageReference backToAccount() {
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference accPage = new PageReference(baseURL+'/'+accId);
        accPage.setRedirect(TRUE);

        return accPage;
    }

    public PageReference shareM12Stock() {
        PageReference shareM12 = Page.ShareM12Stocktake;
        shareM12.getParameters().put('Id', currentId);
        shareM12.getParameters().put('accId', accId);
        shareM12.setRedirect(true);

        return shareM12;
    }

    public void updateM12Quantity() {
        List<M12_Stocktake_Inventory__c> siToUpdate = new List<M12_Stocktake_Inventory__c>();
        for (M12_Stocktake__c p : m12Stocktakes) {
            for (M12_Stocktake_Inventory__c si : p.M12_Stocktake_Inventory__r) {
                if (siIdToUpdate == si.Id) {
                    si.Stocktake_Quantity__c = si.Stocktake_Quantity__c != null ? si.Stocktake_Quantity__c : 0;
                    si.Variation__c = si.Stocktake_Quantity__c - si.M12_Inventory__r.Required_Quantity__c;
                    if (si.Variation__c >0 ) {
                        si.Total_Price__c = 0;
                    } else {
                        si.Total_Price__c = (si.M12_Inventory__r.Required_Quantity__c - si.Stocktake_Quantity__c) *  si.M12_Inventory__r.M12_Hub_Price_per_unit__c;
                    }
                    siToUpdate.add(si);
                    break;
                }
            }
        }
        if (siToUpdate.size() > 0) {
            upsert siToUpdate;
        }
    }

    public ApexPages.StandardSetController con{
        get{
            if (con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator(qry));
                con.setPageSize(200);
            }
            return con;
        }
        set;
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
            return 'Page ' +con.getPageNumber() + ' of ' + Math.ceil(con.getResultSize()/500.0);
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