/**
 * Created by Haider Raza on 11/01/2017.
 */

public with sharing class checkRecursive {
    private static boolean run = true;

    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}