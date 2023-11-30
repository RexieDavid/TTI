/**
* @author: Rexie Aaron David
* @date: November 2023
* @description: Wrapper Class for Response BlackhawkNZ Catalogue Resource
*/ 
public class BlackhawkNZCatalogueWrapper {

    public Integer Result {get;set;} 
	public Response Response {get;set;} 
	public List<String> Errors {get;set;} 

	public class Response {
		public List<DigitalStoreCards> DigitalStoreCards {get;set;} 

		public Response(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'DigitalStoreCards') {
							DigitalStoreCards = arrayOfDigitalStoreCards(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Response consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DigitalStoreCards {
		public Object RedemptionInformation {get;set;} 
		public Integer Identifier {get;set;} 
		public String SKU {get;set;} 
		public String ProductName {get;set;} 
		public String ProductDescription {get;set;} 
		public String SupplierCode {get;set;} 
		public String ProductThumbnailUrl {get;set;} 
		public Boolean IsActive {get;set;} 
		public Boolean IsFixedValue {get;set;} 
		public Double ProductValue {get;set;} 
		public String TermsAndConditions {get;set;} 
		public String ValidityPeriod {get;set;} 
		public Boolean IsPresetExpiry {get;set;} 
		public Double VariableMinValue {get;set;} 
		public Double VariableMaxValue {get;set;} 
		public Object Categories {get;set;} 
		public String Language {get;set;} 
		public String LastUpdated {get;set;} 
		public Double ValueCostPerUnit {get;set;} 
		public Double PercentageCostPerUnit {get;set;} 

		public DigitalStoreCards(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'RedemptionInformation') {
							RedemptionInformation = parser.readValueAs(Object.class);
						} else if (text == 'Identifier') {
							Identifier = parser.getIntegerValue();
						} else if (text == 'SKU') {
							SKU = parser.getText();
						} else if (text == 'ProductName') {
							ProductName = parser.getText();
						} else if (text == 'ProductDescription') {
							ProductDescription = parser.getText();
						} else if (text == 'SupplierCode') {
							SupplierCode = parser.getText();
						} else if (text == 'ProductThumbnailUrl') {
							ProductThumbnailUrl = parser.getText();
						} else if (text == 'IsActive') {
							IsActive = parser.getBooleanValue();
						} else if (text == 'IsFixedValue') {
							IsFixedValue = parser.getBooleanValue();
						} else if (text == 'ProductValue') {
							ProductValue = parser.getDoubleValue();
						} else if (text == 'TermsAndConditions') {
							TermsAndConditions = parser.getText();
						} else if (text == 'ValidityPeriod') {
							ValidityPeriod = parser.getText();
						} else if (text == 'IsPresetExpiry') {
							IsPresetExpiry = parser.getBooleanValue();
						} else if (text == 'VariableMinValue') {
							VariableMinValue = parser.getDoubleValue();
						} else if (text == 'VariableMaxValue') {
							VariableMaxValue = parser.getDoubleValue();
						} else if (text == 'Categories') {
							Categories = parser.readValueAs(Object.class);
						} else if (text == 'Language') {
							Language = parser.getText();
						} else if (text == 'LastUpdated') {
							LastUpdated = parser.getText();
						} else if (text == 'ValueCostPerUnit') {
							ValueCostPerUnit = parser.getDoubleValue();
						} else if (text == 'PercentageCostPerUnit') {
							PercentageCostPerUnit = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'DigitalStoreCards consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public BlackhawkNZCatalogueWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'Result') {
						Result = parser.getIntegerValue();
					} else if (text == 'Response') {
						Response = new Response(parser);
					} else if (text == 'Errors') {
						Errors = arrayOfString(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'BlackhawkNZCatalogueWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static BlackhawkNZCatalogueWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new BlackhawkNZCatalogueWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<DigitalStoreCards> arrayOfDigitalStoreCards(System.JSONParser p) {
        List<DigitalStoreCards> res = new List<DigitalStoreCards>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DigitalStoreCards(p));
        }
        return res;
    }
    
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
}