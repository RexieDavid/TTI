public class SpCreateOrderResDtoAup extends SpCreateOrderResDto {

    public SpCreateOrderResDtoAup() {
        // 
    }

    public class Order {
        public String order_id {get;set;} 
        public String order_reference {get;set;} 
        public String order_creation_date {get;set;} 
        public Order_summary order_summary {get;set;} 
        public List<Shipments> shipments {get;set;} 
        public String payment_method {get;set;} 

        public Order(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'order_id') {
                            order_id = parser.getText();
                        } else if (text == 'order_reference') {
                            order_reference = parser.getText();
                        } else if (text == 'order_creation_date') {
                            order_creation_date = parser.getText();
                        } else if (text == 'order_summary') {
                            order_summary = new Order_summary(parser);
                        } else if (text == 'shipments') {
                            shipments = arrayOfShipments(parser);
                        } else if (text == 'payment_method') {
                            payment_method = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Tracking_summary_Z {
        public Integer sealed {get;set;} 

        public Tracking_summary_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Sealed') {
                            sealed = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Order order {get;set;} 

    public SpCreateOrderResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'order') {
                        order = new Order(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Tracking_summary {
        public Integer initiated {get;set;} 

        public Tracking_summary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Initiated') {
                            initiated = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Order_summary {
        public Double total_cost {get;set;} 
        public Double total_cost_ex_gst {get;set;} 
        public Double total_gst {get;set;} 
        public String status {get;set;} 
        public Tracking_summary tracking_summary {get;set;} 
        public Integer number_of_shipments {get;set;} 

        public Order_summary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'total_cost') {
                            total_cost = parser.getDoubleValue();
                        } else if (text == 'total_cost_ex_gst') {
                            total_cost_ex_gst = parser.getDoubleValue();
                        } else if (text == 'total_gst') {
                            total_gst = parser.getDoubleValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'tracking_summary') {
                            tracking_summary = new Tracking_summary(parser);
                        } else if (text == 'number_of_shipments') {
                            number_of_shipments = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Shipment_summary {
        public Double total_cost {get;set;} 
        public Double total_cost_ex_gst {get;set;} 
        public Double fuel_surcharge {get;set;} 
        public Double total_gst {get;set;} 
        public String status {get;set;} 
        public Tracking_summary_Z tracking_summary {get;set;} 
        public Integer number_of_items {get;set;} 

        public Shipment_summary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'total_cost') {
                            total_cost = parser.getDoubleValue();
                        } else if (text == 'total_cost_ex_gst') {
                            total_cost_ex_gst = parser.getDoubleValue();
                        } else if (text == 'fuel_surcharge') {
                            fuel_surcharge = parser.getDoubleValue();
                        } else if (text == 'total_gst') {
                            total_gst = parser.getDoubleValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'tracking_summary') {
                            tracking_summary = new Tracking_summary_Z(parser);
                        } else if (text == 'number_of_items') {
                            number_of_items = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Shipments {
        public String shipment_id {get;set;} 
        public Boolean email_tracking_enabled {get;set;} 
        public Shipment_summary shipment_summary {get;set;} 

        public Shipments(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else if (text == 'email_tracking_enabled') {
                            email_tracking_enabled = parser.getBooleanValue();
                        } else if (text == 'shipment_summary') {
                            shipment_summary = new Shipment_summary(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }	
    
    public static SpCreateOrderResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateOrderResDtoAup(parser);
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