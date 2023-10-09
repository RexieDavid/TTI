/**
* @author: Christopher Camilon
* @date: November 2018
* @description: This class handles logic for making sure trigger runs only once
*/
public class TriggerHelperClass {   

    private static boolean flagValue = false;
    //private static integer totalRun = 0;

    public static boolean hasAlreadyfired() {
        return flagValue;
    }
    
    public static void setAlreadyfired() {
        //totalRun += 1;
        //if(totalRun == 3){
            flagValue = true;
       // }
    }


}