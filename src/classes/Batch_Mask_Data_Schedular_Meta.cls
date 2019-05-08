global class Batch_Mask_Data_Schedular_Meta implements Schedulable 
{
    /*********************************************************************************
    Method Name    : execute
    Return Type    : void
    Parameter      : SchedulableContext          
    *********************************************************************************/
    global void execute(SchedulableContext sc) 
    {
      // Querying Information from custom object Masking_Object__c where batch query details and batch size are stored.
      List<Masking_Object__c> lstObjectToMask = [Select Name,Batch_Size__c,SOQL_Query__c,Is_Masked_Field__c from Masking_Object__c where IsMaskRun__c = true order by LastModifiedDate DESC limit 1 ];
      
      // Checking If query returns record and SOQL_Query__c(batch query) field populated.
      if(!lstObjectToMask.isEmpty() && lstObjectToMask[0].SOQL_Query__c != null)
      {
        // Instantiating batch class.
        Database.Batchable<Sobject> batchClass = new Batch_Mask_Data_Meta(lstObjectToMask[0].Name,lstObjectToMask[0].SOQL_Query__c,lstObjectToMask[0].Is_Masked_Field__c);
        
        // Checking If batch size is specified in Masking_Object__c record, If not giving batch size as 200.
        Integer batchSize = lstObjectToMask[0].Batch_Size__c != null ? Integer.valueOf(lstObjectToMask[0].Batch_Size__c) : 200;
        
        // Executing batch class.
        database.executeBatch(batchClass,batchSize); 
      }
    } 
}