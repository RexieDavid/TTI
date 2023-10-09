public with sharing class ProductTriggerHelper {
	
	private static boolean resetIndicator = true;
	
	public static boolean getResetIndicator(){
		return resetIndicator;
	}
	
	public static void setResetIndicator(boolean indicator){
		resetIndicator = indicator;		
	}
	

}