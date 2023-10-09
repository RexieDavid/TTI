public class TTI_LogError {
    public static void createExceptionLog(Exception exceptionCaught, String inputParamJason){
        TTI_Error_Log__c objException = new TTI_Error_Log__c();
        objException.TTI_Cause__c = String.valueOf(exceptionCaught.getCause());
        objException.TTI_Line_Number__c = exceptionCaught.getLineNumber();
        objException.TTI_Message__c = exceptionCaught.getMessage();
        objException.TTI_Stack_Trace_String__c = exceptionCaught.getStackTraceString();
        objException.TTI_Type_Name__c = exceptionCaught.getTypeName();
        objException.TTI_Input_Parameters__c = inputParamJason;
        insert objException;
    }
}