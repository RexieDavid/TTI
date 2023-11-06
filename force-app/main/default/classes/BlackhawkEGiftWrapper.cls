public class BlackhawkEGiftWrapper {

	public Integer clientProgramNumber {get;set;} 
	public String orderNumber {get;set;} 
	public Integer quantity {get;set;} 
    public String orderStatus {get;set;} 
	public List<EGifts> eGifts {get;set;} 

	public BlackhawkEGiftWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'clientProgramNumber') {
						clientProgramNumber = parser.getIntegerValue();
					} else if (text == 'orderNumber') {
						orderNumber = parser.getText();
					} else if (text == 'quantity') {
						quantity = parser.getIntegerValue();
					}
                    else if (text == 'orderStatus') {
						orderStatus = parser.getText();
					}
                    else if (text == 'eGifts') {
						eGifts = arrayOfEGifts(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'BlackhawkEGiftWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class EGifts {

		public String url {get;set;} 
		public String contentProviderCode {get;set;} 
		public Double amount {get;set;} 

		public EGifts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'url') {
							url = parser.getText();
						} else if (text == 'contentProviderCode') {
							contentProviderCode = parser.getText();
						} else if (text == 'amount') {
							amount = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'EGifts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static BlackhawkEGiftWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new BlackhawkEGiftWrapper(parser);
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

    private static List<EGifts> arrayOfEGifts(System.JSONParser p) {
        List<EGifts> res = new List<EGifts>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new EGifts(p));
        }
        return res;
    }

}