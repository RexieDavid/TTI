/**
* @author: Rexie Aaron David
* @date: October 2023
* @description: This class handles LogException 
* @reference: https://salesforceable.medium.com/a-handy-error-logger-in-salesforce-to-write-the-exceptions-to-a-custom-object-2b6f79e4c0ef
*/ 
public class LogException extends Exception {

    public String ModuleName {get; set;}
    public String StackTrace {get; set;}
    public String ClassName {get; set;}
    public String MethodName {get; set;}
    public String ExceptionCause {get; set;}
    public String SourceObject {get; set;}
    public String SourceRecord {get; set;}
        
    public void log(Exception ex){
        try{
            extractExceptionData(ex); 
            writeToObject(ex);
        }
        catch(Exception e){
            new LogException().Module('LogException').log(e);            
        }                 
    }
    
    public LogException Module(String Name){
        ModuleName = name;
        return this;
    }
    
    public LogException ExceptionCause(String cause){
        ExceptionCause = cause;
        return this;
    }

    public LogException SourceObject(String sourceObj){
        SourceObject = sourceObj;
        return this;
    }

    public LogException SourceRecord(String recordId){
        SourceRecord = recordId;
        return this;
    }


    
    public void extractExceptionData(Exception ex){
        try{
            stackTrace = ex.getStackTraceString()
                         .substringBefore('\n');
            
            className = stackTrace.substringAfter('.')
                        .substringBefore('.'); 
            
            methodName = stackTrace.substringBefore(':')
                         .substringAfter(className)
                         .substringAfter('.');    
        }
        catch(Exception e){
            new LogException().Module('LogException').log(e); 
        }                      
    }
    
    public void writeToObject(Exception ex){
        try{
            TTI_Error_Log__c logger = new TTI_Error_Log__c();
            logger.Module_Name__c = ModuleName;
            logger.TTI_Stack_Trace_String__c = ex.getStackTraceString();
            logger.Class_Name__c = className;
            logger.Method_Name__c = methodName;
            logger.TTI_Line_Number__c = ex.getLineNumber();
            logger.TTI_Type_Name__c = ex.getTypeName();
            logger.Exception_Cause_Override__c = ExceptionCause; 
            logger.TTI_Cause__c = String.valueOf(ex.getCause());
            logger.TTI_Message__c = ex.getMessage();
            logger.Source_Object__c = SourceObject;
            logger.Source_Record_ID__c = SourceRecord;
            insert logger;    
        }
        catch(Exception e){
            new LogException().Module('LogException').log(e);     
        }
        
    }
    
}