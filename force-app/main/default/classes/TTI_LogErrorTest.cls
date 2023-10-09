@isTest
public class TTI_LogErrorTest {
    public static testmethod void validate(){
        try{
            integer i;
            i++;
        }
        catch(Exception exp){
            TTI_LogError.createExceptionLog(exp, '');
        }
    }
}