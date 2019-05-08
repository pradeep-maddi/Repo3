/*********************************************************************************
Class Name      : Exception_Handler 
Description     : Utility class for handling exceptions.
*/

public with sharing class Exception_Handler 
{
    /*********************************************************************************
    Method Name     : handleException
    Description     : utility method to handle all the caught exceptions in catch block.
    Return Type     : Void
    Parameters      : exception object, Additional information on exception..
    *********************************************************************************/
    public static void handleException(Exception e, String Message) {        
        Error_Log__c errLog = new Error_Log__c( Error_Datetime__c= DateTime.Now(),
                                                Error_Message__c= e.getMessage(),
                                                Running_User__c = UserInfo.getUserId() ,
                                                Stack_Trace__c = e.getStackTraceString(),
                                                Additional_Information__c = Message                                                               
                                              );                       
        insert errLog ;
    }
}