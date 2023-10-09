public class SpCreateLabelResDtoAup extends SpCreateLabelResDto {

    public class Option {

        public Option(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        //{
                        consumeObject(parser);
                        //}
                    }
                }
            }
        }
    }
    
    public class Label extends SpLabel {
        public String request_id { get; set; } 
        public String status { get; set; } 
        public String request_date { get; set; } 
        public List<Shipment> shipments { get; set; } 
        public List<String> shipment_ids { get; set; } 

        public Label(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'request_id') {
                            request_id = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'request_date') {
                            request_date = parser.getText();
                        } else if (text == 'shipments') {
                            shipments = arrayOfShipments(parser);
                        } else if (text == 'shipment_ids') {
                            shipment_ids = arrayOfString(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public String message { get; set; } 
    public String code { get; set; } 
    public List<Label> labels { get; set; } 

    public SpCreateLabelResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'message') {
                        message = parser.getText();
                    } else if (text == 'code') {
                        code = parser.getText();
                    } else if (text == 'labels') {
                        labels = arrayOfLabels(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Shipment {
        public String shipment_id { get; set; } 
        public Option option { get; set; } 

        public Shipment(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else if (text == 'options') {
                            option = new Option(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static SpCreateLabelResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateLabelResDtoAup(parser);
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
    
    private static List<Shipment> arrayOfShipments(System.JSONParser p) {
        List<Shipment> res = new List<Shipment>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Shipment(p));
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

    private static List<Label> arrayOfLabels(System.JSONParser p) {
        List<Label> res = new List<Label>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Label(p));
        }
        return res;
    }
}