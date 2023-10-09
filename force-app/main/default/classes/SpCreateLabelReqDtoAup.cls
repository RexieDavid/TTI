public class SpCreateLabelReqDtoAup extends SpCreateLabelReqDto {
    
    public SpCreateLabelReqDtoAup() {
        //
    }

    public class LabelGroup {
        public String group_name { get; set; } // in json: group
        public String layout { get; set; } 
        public Boolean branded { get; set; } 
        public Integer left_offset { get; set; } 
        public Integer top_offset { get; set; } 

        public LabelGroup() {
            //
        }

        public LabelGroup(String group_name, String layout, Boolean branded, Integer left_offset, Integer top_offset ) {
            this.group_name = group_name;
            this.layout = layout;
            this.branded = branded;
            this.left_offset = left_offset;
            this.top_offset = top_offset;
        }

        public LabelGroup(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'group') {
                            group_name = parser.getText();
                        } else if (text == 'layout') {
                            layout = parser.getText();
                        } else if (text == 'branded') {
                            branded = parser.getBooleanValue();
                        } else if (text == 'left_offset') {
                            left_offset = parser.getIntegerValue();
                        } else if (text == 'top_offset') {
                            top_offset = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Preference {
        public String preference_type { get; set; } // in json: type
        public String format { get; set; } 
        public List<LabelGroup> groups { get; set; } 

        public Preference() {
            //
        }

        public Preference(String preference_type, String format, List<LabelGroup> groups) {
            this.preference_type = preference_type;
            this.format = format;
            this.groups = groups;
        }

        public Preference(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            preference_type = parser.getText();
                        } else if (text == 'format') {
                            format = parser.getText();
                        } else if (text == 'groups') {
                            groups = arrayOfGroups(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Preference> preferences { get; set; } 
    public List<Shipment> shipments { get; set; } 

    public SpCreateLabelReqDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'preferences') {
                        preferences = arrayOfPreferences(parser);
                    } else if (text == 'shipments') {
                        shipments = arrayOfShipments(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Shipment {
        public String shipment_id { get; set; } 

        public Shipment() {
            //
        }

        public Shipment(String shipment_id) {
            this.shipment_id = shipment_id;
        }

        public Shipment(JSONParser parser) {
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
    
    
    public static SpCreateLabelReqDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateLabelReqDtoAup(parser);
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

    private static List<LabelGroup> arrayOfGroups(System.JSONParser p) {
        List<LabelGroup> res = new List<LabelGroup>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LabelGroup(p));
        }
        return res;
    }

    private static List<Preference> arrayOfPreferences(System.JSONParser p) {
        List<Preference> res = new List<Preference>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Preference(p));
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
}