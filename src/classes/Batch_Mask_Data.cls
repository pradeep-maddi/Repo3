/*********************************************************************************
Class Name      : Batch_Mask_Data
Description     : Batch class to mask PII or PHI data.
*/

global with sharing class Batch_Mask_Data implements Database.Batchable<sObject>,Database.Stateful
{
    private String strQuery;                                // Holds batch query string.
    private String strParentObjectName;                     // Holds the object API name on which required processing(Masking) is being performed. 
    private String strIsMaskedCheckField;                   // Holds isMasked flag field API name.
    private Integer failedRecsCount = 0;                    // Holds count of failed records while data masking..
    private String strExceptionMessage = '';                // Holds count of failed records while data masking..
    private Integer batchJobCount = 0; 
     
    //Constructor
    /*********************************************************************************
    Method Name    : Batch_Mask_Data(constructor)
    Description    : Accepts required parameters for batch class.
    Return Type    : none
    *********************************************************************************/
     global Batch_Mask_Data(String objName,String query,String strIsMaskedField){       
        strQuery = query;
        strParentObjectName = objName;
        strIsMaskedCheckField = strIsMaskedField;
    }
    
    /*********************************************************************************
    Method Name    : start
    Description    : Collect the records or objects to pass to the interface method execute.
    Return Type    : QueryLocator
    Parameter      : BatchableContext instance           
    *********************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    /*********************************************************************************
    Method Name    : execute
    Description    : Used to do the required processing for each chunk of data. This method is called for each batch of records that you pass to it.
    Return Type    : void
    Parameter      : 1. BatchableContext 2. List<SObject>           
    *********************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        if(batchJobCount >= 10)
            batchJobCount = 0;
        
        batchJobCount += 1;
        
        //Calling utility class method to mask PII data.
        Batch_Mask_Data_Utility.maskObjectData(BC,scope,strParentObjectName,batchJobCount);
        
        failedRecsCount+= (Batch_Mask_Data_Utility.noOfFailedRecords != null ? Batch_Mask_Data_Utility.noOfFailedRecords : 0);
        
        strExceptionMessage = Batch_Mask_Data_Utility.strExceptionMessage;
        
        //Calling utility class method to update isMasked flag(If exists) to true once masking has been completed to avoid repetitive processing on already masked records.
        if(!String.isEmpty(strIsMaskedCheckField))
          Batch_Mask_Data_Utility.updateIsMaskedFlag(scope,strIsMaskedCheckField);
    } 
    
    /*********************************************************************************
    Method Name    : finish
    Description    : Method called after all batches are processed. Used to execute post-processing operations.
    Return Type    : void
    Parameter      : Database.BatchableContext        
    *********************************************************************************/
    global void finish(Database.BatchableContext BC) 
    {
        String strEmailBodyMessage;
        
        // IF there is an exception while processing batch results
        if(!String.isEmpty(strExceptionMessage))
            strEmailBodyMessage = 'Exception: ' + strExceptionMessage + ' occurred while processing batch results.' + '\n\n' + 'Please check error log record created for detailed information of occurred exception.';
        else if(failedRecsCount > 0)
            strEmailBodyMessage = 'Batch Mask Data completed with failure of ' +  failedRecsCount + ' records.' + '\n\n' + 'Please check error log records created for detailed information of failure records.';
        else
            strEmailBodyMessage = 'Batch Mask Data completed with 0 failures.';
            
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
                          
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Mask Data: ' + a.Status);
        mail.setPlainTextBody(strEmailBodyMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
}