public class SpErrorResDtoAup extends SpErrorResDto {

    public SpErrorResDtoAup() {
        //
    }

    public class Context {
        public String request_id {get;set;} 
        public String shipment_id {get;set;} 
        public String contract_id {get;set;} 
        public String order_id {get;set;} 
        public String location_id {get;set;} 

        public Context(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'request_id') {
                            request_id = parser.getText();
                        } else if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else if (text == 'contract_id') {
                            contract_id = parser.getText();
                        } else if (text == 'order_id') {
                            order_id = parser.getText();
                        } else if (text == 'location_id') {
                            location_id = parser.getText();
                        }  else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Errors {
        public String code {get;set;} 
        public String name {get;set;} 
        public String field {get;set;} 
        public String message {get;set;} 
        public Context context {get;set;} 

        public Errors(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'code') {
                            code = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'field') {
                            field = parser.getText();
                        } else if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'context') {
                            context = new Context(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Errors> errors {get;set;} 

    public SpErrorResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'errors') {
                        errors = arrayOfErrors(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static SpErrorResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpErrorResDtoAup(parser);
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

    private static List<Errors> arrayOfErrors(System.JSONParser p) {
        List<Errors> res = new List<Errors>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Errors(p));
        }
        return res;
    }
}