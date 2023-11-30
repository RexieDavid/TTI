/**
* @author: Rexie Aaron David
* @date: November 2023
* @description: Wrapper Class for Response BlackhawkNZ Order Resource
*/ 
public class BlackhawkNZOrderWrapper {

	public class Response {
		public String OrderReferenceNumber {get;set;} 
		public String StatusCode {get;set;} 
		public String RecievedOn {get;set;} 
		public DigitalStoreCardOrder DigitalStoreCardOrder {get;set;} 

		public Response(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'OrderReferenceNumber') {
							OrderReferenceNumber = parser.getText();
						} else if (text == 'StatusCode') {
							StatusCode = parser.getText();
						} else if (text == 'RecievedOn') {
							RecievedOn = parser.getText();
						} else if (text == 'DigitalStoreCardOrder') {
							DigitalStoreCardOrder = new DigitalStoreCardOrder(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Response consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DigitalStoreCardOrder {
		public List<OrderItems> OrderItems {get;set;} 

		public DigitalStoreCardOrder(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'OrderItems') {
							OrderItems = arrayOfOrderItems(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DigitalStoreCardOrder consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Integer Result {get;set;} 
	public Response Response {get;set;} 
	public List<String> Errors {get;set;} 

	public BlackhawkNZOrderWrapper(JSONParser parser) {
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
						System.debug(LoggingLevel.WARN, 'BlackhawkNZOrderWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class OrderItems {
		public Integer Quantity {get;set;} 
		public List<String> StoreCardUrls {get;set;} 
		public String StatusCode {get;set;} 
		public List<Metadata> Metadata {get;set;} 
		public String SKU {get;set;} 
		public String ReferenceNumber {get;set;} 
		public String StatusMessage {get;set;} 
		public String ReceiptNumber {get;set;} 
		public Double Amount {get;set;} 
		public Double CostPerUnit {get;set;} 
		public Double RRPPerUnit {get;set;} 
		public Boolean IncludesGst {get;set;} 

		public OrderItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Quantity') {
							Quantity = parser.getIntegerValue();
						} else if (text == 'StoreCardUrls') {
							StoreCardUrls = arrayOfString(parser);
						} else if (text == 'StatusCode') {
							StatusCode = parser.getText();
						} else if (text == 'Metadata') {
							Metadata = arrayOfMetadata(parser);
						} else if (text == 'SKU') {
							SKU = parser.getText();
						} else if (text == 'ReferenceNumber') {
							ReferenceNumber = parser.getText();
						} else if (text == 'StatusMessage') {
							StatusMessage = parser.getText();
						} else if (text == 'ReceiptNumber') {
							ReceiptNumber = parser.getText();
						} else if (text == 'Amount') {
							Amount = parser.getDoubleValue();
						} else if (text == 'CostPerUnit') {
							CostPerUnit = parser.getDoubleValue();
						} else if (text == 'RRPPerUnit') {
							RRPPerUnit = parser.getDoubleValue();
						} else if (text == 'IncludesGst') {
							IncludesGst = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'OrderItems consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Metadata {
		public String Barcode {get;set;} 
		public String Pin {get;set;} 
		public String ExpiryDate {get;set;} 
		public String BarcodeType {get;set;} 
		public Double Balance {get;set;} 
		public String LastBalanceCheckedDate {get;set;} 
		public String Status {get;set;} 
		public Object LastStatusChangedDate {get;set;} 
		public Boolean IsBonusCard {get;set;} 
		public Double CardValue {get;set;} 
		public String CardUrl {get;set;} 
		public Boolean SupportsBalanceCheck {get;set;} 
		public String BalanceCheckUrl {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Barcode') {
							Barcode = parser.getText();
						} else if (text == 'Pin') {
							Pin = parser.getText();
						} else if (text == 'ExpiryDate') {
							ExpiryDate = parser.getText();
						} else if (text == 'BarcodeType') {
							BarcodeType = parser.getText();
						} else if (text == 'Balance') {
							Balance = parser.getDoubleValue();
						} else if (text == 'LastBalanceCheckedDate') {
							LastBalanceCheckedDate = parser.getText();
						} else if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'LastStatusChangedDate') {
							LastStatusChangedDate = parser.readValueAs(Object.class);
						} else if (text == 'IsBonusCard') {
							IsBonusCard = parser.getBooleanValue();
						} else if (text == 'CardValue') {
							CardValue = parser.getDoubleValue();
						} else if (text == 'CardUrl') {
							CardUrl = parser.getText();
						} else if (text == 'SupportsBalanceCheck') {
							SupportsBalanceCheck = parser.getBooleanValue();
						} else if (text == 'BalanceCheckUrl') {
							BalanceCheckUrl = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static BlackhawkNZOrderWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new BlackhawkNZOrderWrapper(parser);
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
	
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    private static List<Metadata> arrayOfMetadata(System.JSONParser p) {
        List<Metadata> res = new List<Metadata>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Metadata(p));
        }
        return res;
    }

    private static List<OrderItems> arrayOfOrderItems(System.JSONParser p) {
        List<OrderItems> res = new List<OrderItems>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new OrderItems(p));
        }
        return res;
    }

}