public class SpCreateOrderReqDtoAup extends SpCreateOrderReqDto {

    public SpCreateOrderReqDtoAup() {
        //
    }

    public String order_reference {get;set;} 
    public String payment_method {get;set;} 
    public List<Shipments> shipments {get;set;} 

    public SpCreateOrderReqDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'order_reference') {
                        order_reference = parser.getText();
                    } else if (text == 'payment_method') {
                        payment_method = parser.getText();
                    } else if (text == 'shipments') {
                        shipments = arrayOfShipments(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Shipments {
        public String shipment_id {get;set;} 

        public Shipments() {
            // 
        }

        public Shipments(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static SpCreateOrderReqDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateOrderReqDtoAup(parser);
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

    private static List<Shipments> arrayOfShipments(System.JSONParser p) {
        List<Shipments> res = new List<Shipments>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Shipments(p));
        }
        return res;
    }
}