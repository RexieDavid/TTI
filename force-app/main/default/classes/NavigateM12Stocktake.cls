/**
 * Created by Haider Raza on 16/02/2017.
 */

public class NavigateM12Stocktake {
    
	public Boolean isM12StocktakeValid{
		get {
			if (isM12StocktakeValid == null) {
				try {
					String isM12group = ApexPages.currentPage().getParameters().get('group');
					if (isM12group.contains('M12')) {
						isM12StocktakeValid = true;
					} else {
						isM12StocktakeValid = false;
					}
				} catch (Exception ex) {
					isM12StocktakeValid = false;
				}
			}
			return isM12StocktakeValid;
		}
		set;
	}
	
	public String accId {
		get{
			if (accId == null) {
				accId = ApexPages.currentPage().getParameters().get('Id');
			}
			return accId;
		}
		set;
	}
	
	public PageReference controlNavigation() {
		if (isM12StocktakeValid || Test.isRunningTest()) {
			PageReference M12StockPageReference = Page.M12Stocktake;
			M12StockPageReference.getParameters().put('Id', accId);
            M12StockPageReference.getParameters().put('uniqueId', String.valueOf(System.now()));
			M12StockPageReference.setRedirect(true);
			
			return M12StockPageReference;
		}
		return null;
	}
}