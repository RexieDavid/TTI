/**
* @author: Rexie Aaron David
* @date: November 2023
* @description: Wrapper Class for Request of BlackhawkNZ Order Resource
*/ 
public class BlackhawkNZOrderRequestWrapper {

    public String OrderReferenceNumber {get;set;} 
	public Recipient Recipient {get;set;} 
	public DigitalStoreCardOrder DigitalStoreCardOrder {get;set;} 

	public class PersonalisationInfo {
		public String To {get;set;} 
		public String Message {get;set;} 
		public String From_Z {get;set;} // in json: From

		// public PersonalisationInfo(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'To') {
		// 					To = parser.getText();
		// 				} else if (text == 'Message') {
		// 					Message = parser.getText();
		// 				} else if (text == 'From') {
		// 					From_Z = parser.getText();
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'PersonalisationInfo consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}

	// public BlackhawkNZOrderRequestWrapper(JSONParser parser) {
	// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 			String text = parser.getText();
	// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 				if (text == 'OrderReferenceNumber') {
	// 					OrderReferenceNumber = parser.getText();
	// 				} else if (text == 'Recipient') {
	// 					Recipient = new Recipient(parser);
	// 				} else if (text == 'DigitalStoreCardOrder') {
	// 					DigitalStoreCardOrder = new DigitalStoreCardOrder(parser);
	// 				} else {
	// 					System.debug(LoggingLevel.WARN, 'BlackhawkNZOrderRequestWrapper consuming unrecognized property: '+text);
	// 					consumeObject(parser);
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class DigitalStoreCardOrder {
		public PersonalisationInfo PersonalisationInfo {get;set;} 
		public List<OrderItems> OrderItems {get;set;} 

		// public DigitalStoreCardOrder(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'PersonalisationInfo') {
		// 					PersonalisationInfo = new PersonalisationInfo(parser);
		// 				} else if (text == 'OrderItems') {
		// 					OrderItems = arrayOfOrderItems(parser);
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'DigitalStoreCardOrder consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
	
	public class OrderItems {
		public Integer Quantity {get;set;} 
		public Integer Amount {get;set;} 
		public String SKU {get;set;} 
		public String ReferenceNumber {get;set;} 

		// public OrderItems(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'Quantity') {
		// 					Quantity = parser.getIntegerValue();
		// 				} else if (text == 'Amount') {
		// 					Amount = parser.getIntegerValue();
		// 				} else if (text == 'SKU') {
		// 					SKU = parser.getText();
		// 				} else if (text == 'ReferenceNumber') {
		// 					ReferenceNumber = parser.getText();
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'OrderItems consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
	
	public class Recipient {
		public String Email {get;set;} 
		public String FirstName {get;set;} 
		public String LastName {get;set;} 
		public String MobileNumber {get;set;} 
		public String PhoneNumber {get;set;} 

		// public Recipient(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'Email') {
		// 					Email = parser.getText();
		// 				} else if (text == 'FirstName') {
		// 					FirstName = parser.getText();
		// 				} else if (text == 'LastName') {
		// 					LastName = parser.getText();
		// 				} else if (text == 'MobileNumber') {
		// 					MobileNumber = parser.getText();
		// 				} else if (text == 'PhoneNumber') {
		// 					PhoneNumber = parser.getText();
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'Recipient consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
	
	// public static BlackhawkNZOrderRequestWrapper parse(String json) {
	// 	System.JSONParser parser = System.JSON.createParser(json);
	// 	return new BlackhawkNZOrderRequestWrapper(parser);
	// }
	
	// public static void consumeObject(System.JSONParser parser) {
	// 	Integer depth = 0;
	// 	do {
	// 		System.JSONToken curr = parser.getCurrentToken();
	// 		if (curr == System.JSONToken.START_OBJECT || 
	// 			curr == System.JSONToken.START_ARRAY) {
	// 			depth++;
	// 		} else if (curr == System.JSONToken.END_OBJECT ||
	// 			curr == System.JSONToken.END_ARRAY) {
	// 			depth--;
	// 		}
	// 	} while (depth > 0 && parser.nextToken() != null);
	// }
	
    // private static List<OrderItems> arrayOfOrderItems(System.JSONParser p) {
    //     List<OrderItems> res = new List<OrderItems>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new OrderItems(p));
    //     }
    //     return res;
    // }

}