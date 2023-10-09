public class SpCreateAdhocPickupReqDtoAup extends SpCreateAdhocPickupReqDto {

    public SpCreateAdhocPickupReqDtoAup() {
        //
    }

    public Adhoc_pickup adhoc_pickup { get; set; }

    public SPCreateAdhocPickupReqDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'adhoc_pickup') {
                        adhoc_pickup = new Adhoc_pickup(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'SPCreateAdhocPickupReqDtoAup consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Source {
        public List <String> lines { get; set; }
        public String suburb { get; set; }
        public String postcode { get; set; }
        public String state { get; set; }
        public String business_name { get; set; }
        public String booking_name { get; set; }
        public String pickup_name { get; set; }
        public String pickup_area { get; set; }
        public Boolean private_address { get; set; }
        public String email { get; set; }
        public String phone { get; set; }

        public Source() {
            //
        }
        
        public Source(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'lines') {
                            lines = arrayOfString(parser);
                        } else if (text == 'suburb') {
                            suburb = parser.getText();
                        } else if (text == 'postcode') {
                            postcode = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'business_name') {
                            business_name = parser.getText();
                        } else if (text == 'booking_name') {
                            booking_name = parser.getText();
                        } else if (text == 'pickup_name') {
                            pickup_name = parser.getText();
                        } else if (text == 'pickup_area') {
                            pickup_area = parser.getText();
                        } else if (text == 'private_address') {
                            private_address = parser.getBooleanValue();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Parcel_details {
        public String packaging_type { get; set; }
        public String comments { get; set; }
        public Decimal length { get; set; }
        public Decimal height { get; set; }
        public Decimal width { get; set; }
        public Integer count { get; set; }
        public Decimal weight { get; set; }
        public Decimal heaviest_item { get; set; }

        public Parcel_details() {
            //
        }
        
        public Parcel_details(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'packaging_type') {
                            packaging_type = parser.getText();
                        } else if (text == 'comments') {
                            comments = parser.getText();
                        } else if (text == 'length') {
                            length = parser.getDoubleValue();
                        } else if (text == 'height') {
                            height = parser.getDoubleValue();
                        } else if (text == 'width') {
                            width = parser.getDoubleValue();
                        } else if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else if (text == 'weight') {
                            weight = parser.getDoubleValue();
                        } else if (text == 'heaviest_item') {
                            heaviest_item = parser.getDoubleValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Parcel_details consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Adhoc_pickup {
        public String product_id { get; set; }
        public String pickup_reference { get; set; }
        public String pickup_date { get; set; }
        public String pickup_starttime { get; set; }
        public String pickup_endtime { get; set; }
        public String pickup_instructions { get; set; }
        public Source source { get; set; } // in json: from
        public Boolean contains_dangerous_goods { get; set; }
        public String consignment_id { get; set; }
        public List < Parcel_details > parcel_details { get; set; }

        public Adhoc_pickup() {
            //
        }
        
        public Adhoc_pickup(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'product_id') {
                            product_id = parser.getText();
                        } else if (text == 'pickup_reference') {
                            pickup_reference = parser.getText();
                        } else if (text == 'pickup_date') {
                            pickup_date = parser.getText();
                        } else if (text == 'pickup_starttime') {
                            pickup_starttime = parser.getText();
                        } else if (text == 'pickup_endtime') {
                            pickup_endtime = parser.getText();
                        } else if (text == 'pickup_instructions') {
                            pickup_instructions = parser.getText();
                        } else if (text == 'from') {
                            source = new Source(parser);
                        } else if (text == 'contains_dangerous_goods') {
                            contains_dangerous_goods = parser.getBooleanValue();
                        } else if (text == 'consignment_id') {
                            consignment_id = parser.getText();
                        } else if (text == 'parcel_details') {
                            parcel_details = arrayOfParcel_details(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Adhoc_pickup consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static SpCreateAdhocPickupReqDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateAdhocPickupReqDtoAup(parser);
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
    
    private static List < Parcel_details > arrayOfParcel_details(System.JSONParser p) {
        List < Parcel_details > res = new List < Parcel_details > ();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Parcel_details(p));
        }
        return res;
    }
    
    private static List < String > arrayOfString(System.JSONParser p) {
        List < String > res = new List < String > ();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
}