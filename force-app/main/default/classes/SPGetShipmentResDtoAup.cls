/**
* @author Francis Nasalita
* @date 2019-07-18
*
* @group Service Portal
* @group-content ../../ApexDocContent/service-portal.html
*
* @description Class that represents the response payload structure of Australia Post's "Get Shipment" web service
*/
public class SPGetShipmentResDtoAup {

    public class Context {
        public String product_id {get;set;} 
        public String shipment_internal_ref {get;set;} 
        public String weight {get;set;} 
        public String location_id {get;set;} 
        public String shipment_id {get;set;} 

        public Context(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'product_id') {
                            product_id = parser.getText();
                        } else if (text == 'shipment_internal_ref') {
                            shipment_internal_ref = parser.getText();
                        } else if (text == 'weight') {
                            weight = parser.getText();
                        } else if (text == 'location_id') {
                            location_id = parser.getText();
                        } else if (text == 'shipment_id') {
                            shipment_id = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Item_summary {
        public String status {get;set;} 

        public Item_summary(JSONParser parser) {
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
    
    public class From_Z {
        public String type_Z {get;set;} // in json: type
        public List<String> lines {get;set;} 
        public String suburb {get;set;} 
        public String postcode {get;set;} 
        public String state {get;set;} 
        public String name {get;set;} 
        public String country {get;set;} 
        public String email {get;set;} 
        public String phone {get;set;} 

        public From_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'lines') {
                            lines = arrayOfString(parser);
                        } else if (text == 'suburb') {
                            suburb = parser.getText();
                        } else if (text == 'postcode') {
                            postcode = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
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
    
    public class Label {
        public String label_url {get;set;} 
        public String status {get;set;} 
        public List<Item_contents> errors {get;set;} 
        public String label_creation_date {get;set;} 

        public Label(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'label_url') {
                            label_url = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'errors') {
                            errors = arrayOfItem_contents(parser);
                        } else if (text == 'label_creation_date') {
                            label_creation_date = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Tracking_details {
        public String article_id {get;set;} 
        public String consignment_id {get;set;} 
        public String barcode_id {get;set;} 

        public Tracking_details(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'article_id') {
                            article_id = parser.getText();
                        } else if (text == 'consignment_id') {
                            consignment_id = parser.getText();
                        } else if (text == 'barcode_id') {
                            barcode_id = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Postage_details {
        public Price price {get;set;} 

        public Postage_details(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'price') {
                            price = new Price(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Pagination {
        public Integer total_number_of_records {get;set;} 
        public Integer number_of_records_per_page {get;set;} 
        public Integer current_page_number {get;set;} 

        public Pagination(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'total_number_of_records') {
                            total_number_of_records = parser.getIntegerValue();
                        } else if (text == 'number_of_records_per_page') {
                            number_of_records_per_page = parser.getIntegerValue();
                        } else if (text == 'current_page_number') {
                            current_page_number = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Price {
        public Double calculated_price {get;set;} 
        public Double calculated_price_ex_gst {get;set;} 
        public Double calculated_gst {get;set;} 

        public Price(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'calculated_price') {
                            calculated_price = parser.getDoubleValue();
                        } else if (text == 'calculated_price_ex_gst') {
                            calculated_price_ex_gst = parser.getDoubleValue();
                        } else if (text == 'calculated_gst') {
                            calculated_gst = parser.getDoubleValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Item_contents {

        public Item_contents(JSONParser parser) {
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
    
    public class Items {
        public Double weight {get;set;} 
        public Double height {get;set;} 
        public Double length {get;set;} 
        public Double width {get;set;} 
        public Boolean contains_dangerous_goods {get;set;} 
        public Boolean authority_to_leave {get;set;} 
        public Boolean allow_partial_delivery {get;set;} 
        public String item_id {get;set;} 
        public String item_reference {get;set;} 
        public Tracking_details tracking_details {get;set;} 
        public String product_id {get;set;} 
        public Item_summary item_summary {get;set;} 
        public List<Item_contents> item_contents {get;set;} 
        public Label label {get;set;} 
        public String packaging_type {get;set;} 
        public Postage_details postage_details {get;set;} 

        public Items(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'weight') {
                            weight = parser.getDoubleValue();
                        } else if (text == 'height') {
                            height = parser.getDoubleValue();
                        } else if (text == 'length') {
                            length = parser.getDoubleValue();
                        } else if (text == 'width') {
                            width = parser.getDoubleValue();
                        } else if (text == 'contains_dangerous_goods') {
                            contains_dangerous_goods = parser.getBooleanValue();
                        } else if (text == 'authority_to_leave') {
                            authority_to_leave = parser.getBooleanValue();
                        } else if (text == 'allow_partial_delivery') {
                            allow_partial_delivery = parser.getBooleanValue();
                        } else if (text == 'item_id') {
                            item_id = parser.getText();
                        } else if (text == 'item_reference') {
                            item_reference = parser.getText();
                        } else if (text == 'tracking_details') {
                            tracking_details = new Tracking_details(parser);
                        } else if (text == 'product_id') {
                            product_id = parser.getText();
                        } else if (text == 'item_summary') {
                            item_summary = new Item_summary(parser);
                        } else if (text == 'item_contents') {
                            item_contents = arrayOfItem_contents(parser);
                        } else if (text == 'label') {
                            label = new Label(parser);
                        } else if (text == 'packaging_type') {
                            packaging_type = parser.getText();
                        } else if (text == 'postage_details') {
                            postage_details = new Postage_details(parser);
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class To {
        public String type_Z {get;set;} // in json: type
        public List<String> lines {get;set;} 
        public String suburb {get;set;} 
        public String postcode {get;set;} 
        public String state {get;set;} 
        public String name {get;set;} 
        public String business_name {get;set;} 
        public String country {get;set;} 
        public String email {get;set;} 

        public To(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'lines') {
                            lines = arrayOfString(parser);
                        } else if (text == 'suburb') {
                            suburb = parser.getText();
                        } else if (text == 'postcode') {
                            postcode = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'business_name') {
                            business_name = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Tracking_summary {
        public Integer Created {get;set;} 

        public Tracking_summary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Created') {
                            Created = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Shipment_summary {
        public String status {get;set;} 
        public Tracking_summary tracking_summary {get;set;} 
        public Integer number_of_items {get;set;} 

        public Shipment_summary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'tracking_summary') {
                            tracking_summary = new Tracking_summary(parser);
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
    
    public class Warnings {
        public String code {get;set;} 
        public String name {get;set;} 
        public String message {get;set;} 
        public String field {get;set;} 
        public Context context {get;set;} 

        public Warnings(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'code') {
                            code = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'field') {
                            field = parser.getText();
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
    
    public List<Warnings> warnings {get;set;} 
    public List<Shipments> shipments {get;set;} 
    public Pagination pagination {get;set;} 

    public SPGetShipmentResDtoAup(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'warnings') {
                        warnings = arrayOfWarnings(parser);
                    } else if (text == 'shipments') {
                        shipments = arrayOfShipments(parser);
                    } else if (text == 'pagination') {
                        pagination = new Pagination(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Shipments {
        public String shipment_id {get;set;} 
        public String shipment_reference {get;set;} 
        public String shipment_creation_date {get;set;} 
        public String customer_reference_1 {get;set;} 
        public String customer_reference_2 {get;set;} 
        public List<String> sender_references {get;set;} 
        public Boolean email_tracking_enabled {get;set;} 
        public From_Z from_Z {get;set;} // in json: from
        public To to {get;set;} 
        public List<Items> items {get;set;} 
        public Item_contents options {get;set;} 
        public Shipment_summary shipment_summary {get;set;} 
        public String movement_type {get;set;} 
        public Boolean consolidate {get;set;} 
        public String charge_to_account {get;set;} 

        public Shipments(JSONParser parser) {
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
                        } else if (text == 'customer_reference_1') {
                            customer_reference_1 = parser.getText();
                        } else if (text == 'customer_reference_2') {
                            customer_reference_2 = parser.getText();
                        } else if (text == 'sender_references') {
                            sender_references = arrayOfString(parser);
                        } else if (text == 'email_tracking_enabled') {
                            email_tracking_enabled = parser.getBooleanValue();
                        } else if (text == 'from') {
                            from_Z = new From_Z(parser);
                        } else if (text == 'to') {
                            to = new To(parser);
                        } else if (text == 'items') {
                            items = arrayOfItems(parser);
                        } else if (text == 'options') {
                            options = new Item_contents(parser);
                        } else if (text == 'shipment_summary') {
                            shipment_summary = new Shipment_summary(parser);
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
    
    public static SPGetShipmentResDtoAup parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SPGetShipmentResDtoAup(parser);
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
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Items(p));
        }
        return res;
    }

    private static List<Warnings> arrayOfWarnings(System.JSONParser p) {
        List<Warnings> res = new List<Warnings>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Warnings(p));
        }
        return res;
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

    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    private static List<Item_contents> arrayOfItem_contents(System.JSONParser p) {
        List<Item_contents> res = new List<Item_contents>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Item_contents(p));
        }
        return res;
    }
}