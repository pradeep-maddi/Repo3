/*********************************************************************************
Class Name      : Batch_Mask_Data_Utility
Description     : Utility class for masking PII data functionality.
*/
public with sharing class Batch_Mask_Data_Utility 
{  
    private static Database.BatchableContext batchContext;
    public static Integer noOfFailedRecords = 0; //Used to store failure records count while data masking.
    private static set<Id> setFailedRecordIds = new set<Id>();
    public static string strExceptionMessage = '';
    private static Integer batchJobCount;
  
    /*********************************************************************************
    Method Name    : maskObjectData
    Description    : Used to fetch child objects and it's fields Information from MaskObjectData__c custom setting to perform masking.
    Return Type    : String               
    *********************************************************************************/
    public static void maskObjectData(Database.BatchableContext BC,List<sObject> scope,String strParentObjName,Integer batchJobNo) 
    {
        batchJobCount = batchJobNo;
        batchContext = BC;
        Set<Id> parentsObjectIds = new set<Id>(); // Used to hold parent sObject Id's on which masking is performed.
        String strQuery;               // Used to store query string for child objects.
        Map<string,string> mapObjAPINameVsRelationFieldName = new Map<string,string>(); // Used to store object name and it's relationship field name with parent object.
        Map<string, List<String>> mapObjAPINameVsFieldAPINames = new Map<string, list<string>>(); // Used to store object name and list of fields to be masked.
        Map<String, List<sobject>> mapSobject = new Map <string,List<sobject>>(); // Used to store object name with list of queried records for masking.
        List<sobject> lstObj = new List<sobject>();
        
        try 
        {
            //Collecting parent sObject record Id's to query it's related child records for masking. 
            for(sObject pObj: scope) 
            { 
                parentsObjectIds.add(pObj.Id);
            }
        
            //Fetching objects and it's fields Information for which masking needs to be performed.
            for (MaskObjectData__c  objInfo : [Select Relationship_Field_To_Parent__c,Field_Api_Name__c,Object_Api_Name__c,Parent_Object_Api_Name__c
                                   from MaskObjectData__c where Parent_Object_Api_Name__c =:strParentObjName ])
            {
                //Collecting object name and list of it's fields into map for masking.
                if(mapObjAPINameVsFieldAPINames.containskey(objInfo.Object_Api_Name__c) && objInfo.Field_Api_Name__c != null) 
                {
                   mapObjAPINameVsFieldAPINames.get(objInfo.Object_Api_Name__c).add(objInfo.Field_Api_Name__c);
                } 
                else if(objInfo.Field_Api_Name__c != null)
                {
                   mapObjAPINameVsFieldAPINames.put(objInfo.Object_Api_Name__c, new List<String>{objInfo.Field_Api_Name__c});                
                }
                        
                //Collecting object name and it's relationship field to parent object. Useful while querying child records of parent object.
                if(objInfo.Object_Api_Name__c != null && objInfo.Relationship_Field_To_Parent__c != null && !mapObjAPINameVsRelationFieldName.containsKey(objInfo.Object_Api_Name__c)) 
                    mapObjAPINameVsRelationFieldName.put(objInfo.Object_Api_Name__c, objInfo.Relationship_Field_To_Parent__c);
            }      
              
            //Constructing query for child objects.
            if(mapObjAPINameVsFieldAPINames != null && !mapObjAPINameVsFieldAPINames.keyset().isEmpty())
            {
               // Iterating through list of child objects and it's list of fields to query child objects records for masking. 
                for (String strAPINAme: mapObjAPINameVsFieldAPINames.keyset()) 
                {
                    strQuery = 'Select Id,' + ((mapObjAPINameVsRelationFieldName.containsKey(strAPINAme) &&  mapObjAPINameVsRelationFieldName.get(strAPINAme) != 'Id') ? (mapObjAPINameVsRelationFieldName.get(strAPINAme) + ',') : '');
            
                    strQuery+= String.join(mapObjAPINameVsFieldAPINames.get(strAPINAme),',') + ' from ' + strAPINAme;
        
                    if (mapObjAPINameVsRelationFieldName.containsKey(strAPINAme))
                        strQuery += ' WHERE ' + mapObjAPINameVsRelationFieldName.get(strAPINAme) + ' IN :parentsObjectIds';
                    
                    //Querying child objects for parent.. Query would execute only for number of child objects in custom setting, written in for loop as it won't be hitting any governor limits.
                    lstObj = database.query(strQuery);
                    
                    if(!lstObj.isEmpty())
                       mapSobject.put(strAPINAme, lstObj);
                }
            }
            
            //If there are any child object records queried, Masking those queried records.
            if(!mapSobject.keyset().isEmpty()) 
                maskQueriedsObjects(mapSobject,mapObjAPINameVsFieldAPINames,mapObjAPINameVsRelationFieldName);
        }    
        catch(Exception ex)
        {
           // Do required processing as per business requirement to create custom error log records or send email to user etc..
           Exception_Handler.handleException(ex,'Error occured in \'maskObjectData\' method of \'Batch_Mask_Data_Utility\' class while forming dynamic query for objects to fetch objects data for masking.');
           strExceptionMessage = ex.getMessage();
        }
    } 
    
    /*********************************************************************************
    Method Name    : maskQueriedsObjects
    Description    : 
    Return Type    : void               
    *********************************************************************************/
    private static void maskQueriedsObjects(Map<String, List<sobject>> mapSobject,Map<string, List<String>> mapObjAPINameVsFieldAPINames,Map<string,string> mapObjAPINameVsRelationFieldName)
    {
        Schema.SObjectType sobjectType;    
        Schema.DescribeFieldResult field;  //Used for field describe to know it's field type for masking.
        String maskTextFormat;             //Used to store mask format for different field types.
        Map<String,Map<Id,Sobject>> mapObjectWiseMaskedResults = new Map < String, Map < Id, Sobject >> ();
        
        Map<Id,Sobject> mapMaskedsObjectList1 = new Map<Id,Sobject> ();
        Map<Id,Sobject> mapMaskedsObjectList2 = new Map<Id,Sobject> ();
        
        Map<Id,Sobject> mapUpdatedsObjects = new Map<Id,Sobject>(); //Map used to store updated mask records.
       
        try
        {
          //Iterating through the list of objects which needs to be masked.
          for(String strObjAPIName : mapSobject.keySet())
          { 
            sobjectType = Schema.getGlobalDescribe().get(strObjAPIName);
            mapUpdatedsObjects = new Map<Id,Sobject>();
            //Getting queried records of object.
            for(sObject objsObject : mapSobject.get(strObjAPIName))
            {
              //Getting list of fields to be masked.
              for(String objFieldAPIName : mapObjAPINameVsFieldAPINames.get(strObjAPIName))
              {
                if(sobjectType.getDescribe().fields.getMap().containsKey(objFieldAPIName))
                {
                    field = sobjectType.getDescribe().fields.getMap().get(objFieldAPIName).getDescribe();
                
                    //Checking If field to be masked has some value and FieldMaskingType__c custom setting has some masking text for field type.
                    if(!field.isUnique() && objsObject.get(field.getLocalName()) != null && FieldMaskingType__c.getInstance(String.valueOf(field.getType())) != null)
                    {
                       Object objDynamicValueType;
                       
                       FieldMaskingType__c objmaskFieldType = FieldMaskingType__c.getInstance(String.valueOf(field.getType()));
                       maskTextFormat = getMaskFormatBasedOnJobCount(objmaskFieldType);
                       
                       if(!String.isEmpty(maskTextFormat))
                       { 
                         //Typecasting Masktext to field type.
                          if (field.getType() == Schema.DisplayType.Date)
                            objDynamicValueType = Date.parse(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.DateTime)
                            objDynamicValueType = DateTime.parse(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.Percent || field.getType() == Schema.DisplayType.Currency)
                            objDynamicValueType = Decimal.valueOf(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.Double)
                            objDynamicValueType = Double.valueOf(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.Integer)
                             objDynamicValueType = Integer.valueof(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.Boolean)    
                            objDynamicValueType =  Boolean.valueOf(maskTextFormat);
                          else if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist || field.getType() == Schema.DisplayType.MultiPicklist || field.getType() == Schema.DisplayType.TextArea || field.getType() == Schema.DisplayType.Email || field.getType() == Schema.DisplayType.Phone)        
                          {         
                            objDynamicValueType = maskTextFormat;
                          }     
                                     
                          if(objDynamicValueType != null)    
                          {
                             //Masking object field.
                             objsObject.put(field.getLocalName(), objDynamicValueType);
                             mapUpdatedsObjects.put(objsObject.Id, objsObject);
                          }  
                      }
                      
                    }
                    else if(field.isUnique())
                    {
                        objsObject.put(field.getLocalName(),'xx'+Math.random() + String.valueof(DateTime.now().getTime()));
                        mapUpdatedsObjects.put(objsObject.Id, objsObject);
                    }
                }
              }
            }
            mapObjectWiseMaskedResults.put(strObjAPIName,mapUpdatedsObjects);
          } 
        
        //Splitting into two maps to avoid 'Cannot have more than 10 chunks in a single operation' error when there are more child records for patient to be masked..
        if(!mapObjectWiseMaskedResults.values().isEmpty()) 
        {
            Integer counter = 0;
            
            for (String idObj: mapObjectWiseMaskedResults.keyset()) 
            {
                if (counter < 1) 
                {
                    mapMaskedsObjectList1.putAll(mapObjectWiseMaskedResults.get(idObj));
                    counter++; 
                } 
                else if (counter >= 1 && counter < mapObjectWiseMaskedResults.keyset().size()) 
                {
                    mapMaskedsObjectList2.putAll(mapObjectWiseMaskedResults.get(idObj));
                    counter++;
                }
            } 
         }
         
         if(!mapMaskedsObjectList1.values().isEmpty())
         {
            // Updating masked records.
            Database.SaveResult[] srList = Database.update(mapMaskedsObjectList1.values(), false);
            handleMaskDMLOperations(mapMaskedsObjectList1.values(), srList,mapObjAPINameVsRelationFieldName);
         }
         
         if(!mapMaskedsObjectList2.values().isEmpty())
         {
            // Updating masked records.
            Database.SaveResult[] srList = Database.update(mapMaskedsObjectList2.values(), false);
            handleMaskDMLOperations(mapMaskedsObjectList2.values(), srList,mapObjAPINameVsRelationFieldName);
         }
        }
        catch(Exception ex)
        {
          // Do required processing as per business requirement to create custom error log records or send email to user etc..
          Exception_Handler.handleException(ex,'Error occured in \'maskQueriedsObjects\' method of \'Batch_Mask_Data_Utility\' class while masking queried objects information.');
          noOfFailedRecords = null;
          strExceptionMessage = ex.getMessage();
        }
  }

    
  private Static String getMaskFormatBasedOnJobCount(FieldMaskingType__c objmaskFieldType)
  {
     String strMaskFormat = '';
     
     if(batchJobCount == 1)
        strMaskFormat = objmaskFieldType.Masking_Format_1__c;
     else if(batchJobCount == 2)
        strMaskFormat = objmaskFieldType.Masking_Format_2__c;
     else if(batchJobCount == 3)
        strMaskFormat = objmaskFieldType.Masking_Format_3__c;
     else if(batchJobCount == 4)
        strMaskFormat = objmaskFieldType.Masking_Format_4__c;
     else if(batchJobCount == 5)
        strMaskFormat = objmaskFieldType.Masking_Format_5__c;
     else if(batchJobCount == 6)
        strMaskFormat = objmaskFieldType.Masking_Format_6__c;
     else if(batchJobCount == 7)
        strMaskFormat = objmaskFieldType.Masking_Format_7__c;
     else if(batchJobCount == 8)
        strMaskFormat = objmaskFieldType.Masking_Format_8__c;
     else if(batchJobCount == 9)
        strMaskFormat = objmaskFieldType.Masking_Format_9__c;
     else if(batchJobCount == 10)
        strMaskFormat = objmaskFieldType.Masking_Format_10__c;          
  
     return strMaskFormat;
  
  }
    
  public static void handleMaskDMLOperations(List<sObject> lstUpdatedsObjects,Database.saveResult[] saveResults,Map<string,string> mapObjAPINameVsRelationFieldName)
  {
    try
    {
        List<Error_Log__c> lstErrorLogsToInsertForFailedRecords = new List<Error_Log__c>();
        
        String strObjectName;
        String strErrorRecordsInfo='';
          
          // Fetching failed records information.
          for(Integer index = 0; index <lstUpdatedsObjects.size(); index++) 
          {
              Database.SaveResult saveRes = saveResults[index];
              sObject sObjRec = lstUpdatedsObjects[index];
              
              // If record updation is failed
              if(!saveRes.isSuccess()) 
              {
                  noOfFailedRecords++;
                  strObjectName = sObjRec.Id.getSObjectType().getDescribe().getName();
                  
                  if(mapObjAPINameVsRelationFieldName.containsKey(strObjectName))
                    setFailedRecordIds.add((Id)sObjRec.get(mapObjAPINameVsRelationFieldName.get(strObjectName)));
                  
                  strErrorRecordsInfo += 'Record Id: ' + sObjRec.Id + '\n\n' + 'Errors: ';
              
                  List<Database.Error> lstErrors = saveRes.getErrors();
                  
                  //Getting errors Information of failure records.  
                  for(Integer index1 = 0 ; index1 < lstErrors.size() ; index1++) 
                  {
                    strErrorRecordsInfo +=  '\n' + (index1 + 1) + ') ' + lstErrors[index1].getMessage();
                  }
                  
                  lstErrorLogsToInsertForFailedRecords.add(new Error_Log__c( Error_Datetime__c= DateTime.Now(),Error_Message__c = strErrorRecordsInfo,Running_User__c = UserInfo.getUserId()));
              } 
          }
          
          if(!lstErrorLogsToInsertForFailedRecords.isEmpty())
            Database.insert(lstErrorLogsToInsertForFailedRecords,false);
    }
    
     catch(Exception ex)
     {
          // Do required processing as per business requirement to create custom error log records or send email to user etc..
          Exception_Handler.handleException(ex,'Error occured in \'handleMaskDMLOperations\' method of \'Batch_Mask_Data_Utility\' class while creating error log information for failed records.');
     }
  }
  
  /*********************************************************************************
    Method Name    : updateIsMaskedFlag
    Description    : Used to fetch child objects and it's fields Information from MaskObjectData__c custom setting to perform masking.
    Return Type    : void               
    *********************************************************************************/
    public static void updateIsMaskedFlag(List<sObject> scope,String strFieldToUpdate)
    {
        try
        {
             for(sObject objsObject : scope) 
             {
                  if((setFailedRecordIds != null && !setFailedRecordIds.contains(objsObject.Id)) || (setFailedRecordIds == null && String.isEmpty(strExceptionMessage))) 
                      objsObject.put(strFieldToUpdate,true);
             }
             Database.update(scope, false);
        }
        catch(Exception ex)
        {
          // Do required processing as per business requirement to create custom error log records or send email to user etc..
          Exception_Handler.handleException(ex,'Error occured in \'updateIsMaskedFlag\' method of \'Batch_Mask_Data_Utility\' class while updating isMasked flag to true after record information is successfully masked.');
        }
    }
}