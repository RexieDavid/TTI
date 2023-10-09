public class SpUpdateShipmentReqDtoAup extends SpUpdateShipmentReqDto {
    
    public SpUpdateShipmentReqDtoAup() {
        //
    }

    public class Dangerous_goods {
        public String class_division {get;set;} 
        public String net_weight {get;set;} 
        public String outer_packaging_quantity {get;set;} 
        public String outer_packaging_type {get;set;} 
        public String technical_name {get;set;} 
        public String un_number {get;set;} 

        public Dangerous_goods() {
            //
        }

        public Dangerous_goods(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'class_division') {
                            class_division = parser.getText();
                        } else if (text == 'net_weight') {
                            net_weight = parser.getText();
                        } else if (text == 'outer_packaging_quantity') {
                            outer_packaging_quantity = parser.getText();
                        } else if (text == 'outer_packaging_type') {
                            outer_packaging_type = parser.getText();
                        } else if (text == 'technical_name') {
                            technical_name = parser.getText();
                        } else if (text == 'un_number') {
                            un_number = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Destination destination {get;set;} 
    public Source source {get;set;} // in json: from
    public Boolean consolidate {get;set;} 
    public String customer_reference_1 {get;set;} 
    public Object customer_reference_2 {get;set;} 
    public Dangerous_goods dangerous_goods {get;set;} 
    public Boolean email_tracking_enabled {get;set;} 
    public List<Items> items {get;set;} 
    public String shipment_reference {get;set;} 
    public String movement_type {get;set;}

    public SpUpdateShipmentReqDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'destination') {
                        destination = new Destination(parser);
                    } else if (text == 'source') {
                        source = new Source(parser);
                    } else if (text == 'consolidate') {
                        consolidate = parser.getBooleanValue();
                    } else if (text == 'customer_reference_1') {
                        customer_reference_1 = parser.getText();
                    } else if (text == 'customer_reference_2') {
                        customer_reference_2 = parser.getText();
                        //customer_reference_2 = parser.readValueAs(Object.class);
                    } else if (text == 'dangerous_goods') {
                        dangerous_goods = new Dangerous_goods(parser);
                    } else if (text == 'email_tracking_enabled') {
                        email_tracking_enabled = parser.getBooleanValue();
                    } else if (text == 'items') {
                        items = arrayOfItems(parser);
                    } else if (text == 'shipment_reference') {
                        shipment_reference = parser.getText();
                    } else if (text == 'movement_type') {
                        movement_type = parser.getText();
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Source {
        public String email {get;set;} 
        public List<String> lines {get;set;} 
        public String name {get;set;} 
        public String phone {get;set;} 
        public String postcode {get;set;} 
        public String state {get;set;} 
        public String suburb {get;set;} 

        public Source() {
            //
        }

        public Source(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'lines') {
                            lines = arrayOfString(parser);
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'postcode') {
                            postcode = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'suburb') {
                            suburb = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Items {
        public Boolean allow_partial_delivery {get;set;} 
        public Boolean authority_to_leave {get;set;} 
        public Boolean contains_dangerous_goods {get;set;} 
        public String height {get;set;} 
        public String item_reference {get;set;} 
        public String length {get;set;} 
        public String packaging_type {get;set;} 
        public String product_id {get;set;} 
        public String weight {get;set;} 
        public String width {get;set;} 

        public Items() {
            //
        }

        public Items(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'allow_partial_delivery') {
                            allow_partial_delivery = parser.getBooleanValue();
                        } else if (text == 'authority_to_leave') {
                            authority_to_leave = parser.getBooleanValue();
                        } else if (text == 'contains_dangerous_goods') {
                            contains_dangerous_goods = parser.getBooleanValue();
                        } else if (text == 'height') {
                            height = parser.getText();
                        } else if (text == 'item_reference') {
                            item_reference = parser.getText();
                        } else if (text == 'length') {
                            length = parser.getText();
                        } else if (text == 'packaging_type') {
                            packaging_type = parser.getText();
                        } else if (text == 'product_id') {
                            product_id = parser.getText();
                        } else if (text == 'weight') {
                            weight = parser.getText();
                        } else if (text == 'width') {
                            width = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Destination {
        public String business_name {get;set;} 
        public String email {get;set;} 
        public List<String> lines {get;set;} 
        public String name {get;set;} 
        public Object phone {get;set;} 
        public String postcode {get;set;} 
        public String state {get;set;} 
        public String suburb {get;set;} 

        public Destination() {
            //
        }

        public Destination(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'business_name') {
                            business_name = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'lines') {
                            lines = arrayOfString(parser);
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                            // phone = parser.readValueAs(Object.class);
                        } else if (text == 'postcode') {
                            postcode = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'suburb') {
                            suburb = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }	
    
    public static SpUpdateShipmentReqDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpUpdateShipmentReqDtoAup(parser);
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

    private static List<Items> arrayOfItems(System.JSONParser p) {
        List<Items> res = new List<Items>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Items(p));
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