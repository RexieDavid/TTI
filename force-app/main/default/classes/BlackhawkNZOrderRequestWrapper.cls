/**
* @author: Rexie Aaron David
* @date: November 2023
* @description: Wrapper Class for Request of BlackhawkNZ Order Resource
*/ 
public class BlackhawkNZOrderRequestWrapper {

    public String OrderReferenceNumber {get;set;} 
	public Recipient Recipient {get;set;} 
	public DigitalStoreCardOrder DigitalStoreCardOrder {get;set;} 

	public class PersonalisationInfo {
		public String To {get;set;} 
		public String Message {get;set;} 
		public String From_Z {get;set;} // in json: From
	}
	
	public class DigitalStoreCardOrder {
		public PersonalisationInfo PersonalisationInfo {get;set;} 
		public List<OrderItems> OrderItems {get;set;} 
	}
	
	public class OrderItems {
		public Integer Quantity {get;set;} 
		public Double Amount {get;set;} 
		public String SKU {get;set;} 
		public String ReferenceNumber {get;set;} 
	}
	
	public class Recipient {
		public String Email {get;set;} 
		public String FirstName {get;set;} 
		public String LastName {get;set;} 
		public String MobileNumber {get;set;} 
		public String PhoneNumber {get;set;} 
	}

}