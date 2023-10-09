public class TTI_CreateAPIPayload {
    
    public String carrier;	//COURIERPOST
    public String caller;	//Techtronic Industries Group
    public String name;	//Phillip Crotty
    public String email;	//phillip.crotty@ttibrands.com.au
    public String phone;	//+61 3 9730 7754
    public String customer_reference;	//21946011
	public boolean is_label_required;
	public List<string> tracking_references;
    public String service_code;	//ON
    public cls_pickup_address pickup_address;
    public cls_delivery_address delivery_address;
    public String pickup_date_time;	//2018-01-23T10:08:28.778Z
    public Integer parcel_quantity;	//1
	public boolean is_delivery_confirm_required;
	public boolean is_booking_confirm_required;
    
    public class cls_pickup_address {
        public String name;	//Mayank Agarwal
        public String phone;	//029540810845
        public String email;	//aggrwll.95@gmail.com
        public String street;	//15 NEW STREET
        public String suburb;	//NELSON
        public String postcode;	//7010
    }
    public class cls_delivery_address {
        public String street;	//49a BARRYS POINT ROAD
        public String suburb;	//TAKAPUNA NORTHSHORE
        public String postcode;	//0622
        public String name;	//ELECTRICAL SERVICE CENTRE
        public String phone;	//+6435483144
        public String email;	//aggrwll.95@gmail.com
        public String company_name;	//ELECTRICAL SERVICE CENTRE
		public string instructions;
    }
    
    public TTI_CreateAPIPayload(){
        pickup_address =  new cls_pickup_address();
        delivery_address = new cls_delivery_address();
		tracking_references=new List<string>();
    }
    
    
}