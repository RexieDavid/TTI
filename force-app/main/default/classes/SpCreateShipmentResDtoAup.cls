public class SpCreateShipmentResDtoAup extends SpCreateShipmentResDto {

    public class ItemSummary {
        public String status { get; set; } 

        public ItemSummary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'status') {
                            status = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ItemContent {

        public ItemContent(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Warning> warnings { get; set; } 
    public List<Shipment> shipments { get; set; } 

    public SpCreateShipmentResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'warnings') {
                        warnings = arrayOfWarnings(parser);
                    } else if (text == 'shipments') {
                        shipments = arrayOfShipments(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Item {
        public Integer weight { get; set; } 
        public Boolean authority_to_leave { get; set; } 
        public Boolean allow_partial_delivery { get; set; } 
        public String item_id { get; set; } 
        public String item_reference { get; set; } 
        public TrackingDetail tracking_details { get; set; } 
        public String product_id { get; set; } 
        public ItemSummary item_summary { get; set; } 
        public List<ItemContent> item_contents { get; set; } 
        public String packaging_type { get; set; } 

        public Item(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'weight') {
                            weight = parser.getIntegerValue();
                        } else if (text == 'authority_to_leave') {
                            authority_to_leave = parser.getBooleanValue();
                        } else if (text == 'allow_partial_delivery') {
                            allow_partial_delivery = parser.getBooleanValue();
                        } else if (text == 'item_id') {
                            item_id = parser.getText();
                        } else if (text == 'item_reference') {
                            item_reference = parser.getText();
                        } else if (text == 'tracking_details') {
                            tracking_details = new TrackingDetail(parser);
                        } else if (text == 'product_id') {
                            product_id = parser.getText();
                        } else if (text == 'item_summary') {
                            item_summary = new ItemSummary(parser);
                        } else if (text == 'item_contents') {
                            item_contents = arrayOfItemContents(parser);
                        } else if (text == 'packaging_type') {
                            packaging_type = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TrackingSummary {
        public Integer created { get; set; } 

        public TrackingSummary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Created') {
                            created = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ShipmentSummary {
        public Double total_cost { get; set; } 
        public Double total_cost_ex_gst { get; set; } 
        public Double total_gst { get; set; } 
        public Double freight_charge { get; set; } 
        public String status { get; set; } 
        public TrackingSummary tracking_summary { get; set; } 
        public Integer number_of_items { get; set; } 

        public ShipmentSummary(JSONParser parser) {
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
                        } else if (text == 'freight_charge') {
                            freight_charge = parser.getDoubleValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'tracking_summary') {
                            tracking_summary = new TrackingSummary(parser);
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
    
    public class Warning {
        public String message { get; set; } 
        public String field { get; set; } 

        public Warning(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'field') {
                            field = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TrackingDetail {
        public String article_id { get; set; } 
        public String consignment_id { get; set; } 

        public TrackingDetail(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'article_id') {
                            article_id = parser.getText();
                        } else if (text == 'consignment_id') {
                            consignment_id = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Shipment extends SpShipment {
        public String shipment_id { get; set; } 
        public String shipment_reference { get; set; } 
        public String shipment_creation_date { get; set; } 
        public Boolean email_tracking_enabled { get; set; } 
        public List<Item> items { get; set; } 
        public ItemContent options { get; set; } 
        public ShipmentSummary shipment_summary { get; set; } 
        public String movement_type { get; set; } 
        public Boolean consolidate { get; set; } 
        public String charge_to_account { get; set; } 

        public Shipment(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else if (text == 'shipment_reference') {
                            shipment_reference = parser.getText();
                        } else if (text == 'shipment_creation_date') {
                            shipment_creation_date = parser.getText();
                        } else if (text == 'email_tracking_enabled') {
                            email_tracking_enabled = parser.getBooleanValue();
                        } else if (text == 'items') {
                            items = arrayOfItems(parser);
                        } else if (text == 'options') {
                            options = new ItemContent(parser);
                        } else if (text == 'shipment_summary') {
                            shipment_summary = new ShipmentSummary(parser);
                        } else if (text == 'movement_type') {
                            movement_type = parser.getText();
                        } else if (text == 'consolidate') {
                            consolidate = parser.getBooleanValue();
                        } else if (text == 'charge_to_account') {
                            charge_to_account = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static Shipment parseShipment(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new Shipment(parser);
    }
    
    public static SpCreateShipmentResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateShipmentResDtoAup(parser);
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
    
    private static List<Item> arrayOfItems(System.JSONParser p) {
        List<Item> res = new List<Item>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Item(p));
        }
        return res;
    }

    private static List<Shipment> arrayOfShipments(System.JSONParser p) {
        List<Shipment> res = new List<Shipment>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Shipment(p));
        }
        return res;
    }

    private static List<ItemContent> arrayOfItemContents(System.JSONParser p) {
        List<ItemContent> res = new List<ItemContent>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ItemContent(p));
        }
        return res;
    }

    private static List<Warning> arrayOfWarnings(System.JSONParser p) {
        List<Warning> res = new List<Warning>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Warning(p));
        }
        return res;
    }
}