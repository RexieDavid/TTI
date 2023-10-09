public class SpCreateAdhocPickupResDtoAup extends SpCreateAdhocPickupResDto {

    public List<Adhoc_pickups> adhoc_pickups {get;set;} 

    public SpCreateAdhocPickupResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'adhoc_pickups') {
                        adhoc_pickups = arrayOfAdhoc_pickups(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'SpCreateAdhocPickupResDtoAup consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Adhoc_pickups {
        public String booking_id {get;set;} 

        public Adhoc_pickups(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'booking_id') {
                            booking_id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Adhoc_pickups consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static SpCreateAdhocPickupResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpCreateAdhocPickupResDtoAup(parser);
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
    
    private static List<Adhoc_pickups> arrayOfAdhoc_pickups(System.JSONParser p) {
        List<Adhoc_pickups> res = new List<Adhoc_pickups>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Adhoc_pickups(p));
        }
        return res;
    }
}