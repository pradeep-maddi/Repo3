/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class Test_Batch_Mask_Data 
{
    // Testing data setup for all methods in this class.
    @testSetup
    static void dataSetUp() 
    {
        //Creating accounts
        List<Account> accounts = new List<Account>{
                                                     new Account(Name = 'Unit Test Corp',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Hot',NumberOfEmployees = 2500),
                                                     new Account(Name = 'Unit Test LLC',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Warm',NumberOfEmployees = 3000),
                                                     new Account(Name = 'Parent Company Inc1',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 3500),
                                                     new Account(Name = 'Parent Company Inc2',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 4000),
                                                     new Account(Name = 'Parent Company Inc3',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 4500),
                                                     new Account(Name = 'Parent Company Inc4',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 5000),
                                                     new Account(Name = 'Parent Company Inc5',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 5500),
                                                     new Account(Name = 'Parent Company Inc6',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 6000),
                                                     new Account(Name = 'Parent Company Inc7',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 6500),
                                                     new Account(Name = 'Parent Company Inc8',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 7000),
                                                     new Account(Name = 'Parent Company Inc9',Fax='11232323',Type = 'Customer - Direct',Phone = '121313123',Rating = 'Cold',NumberOfEmployees = 7500)
                                                  };
        insert accounts;
        
        //Creating contacts for Accounts
        List<Contact> contacts = new List<Contact>{
                                                    new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Unit Test Corp - 1',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1980, 2, 17),Email = 'test@test.com',LeadSource = 'Web'),
                                                    new Contact(AccountId = accounts[1].Id, FirstName = 'Test', LastName = 'Unit Test Corp - 2',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1981, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[2].Id, FirstName = 'Test', LastName = 'Unit Test LLC - 1',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1982, 2, 17),Email = 'test@test.com',LeadSource = 'Web'),
                                                    new Contact(AccountId = accounts[3].Id, FirstName = 'Test', LastName = 'Unit Test LLC - 2',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1983, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[4].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 1',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1984, 2, 17),Email = 'test@test.com',LeadSource = 'Web'),
                                                    new Contact(AccountId = accounts[5].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 2',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[6].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 3',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[7].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 4',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[8].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 5',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[9].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 6',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[10].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 7',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[10].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 8',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry'),
                                                    new Contact(AccountId = accounts[10].Id, FirstName = 'Test', LastName = 'Parent Company Inc - 9',Phone = '1212121',Title ='Test',Birthdate = date.newinstance(1985, 2, 17),Email = 'test@test.com',LeadSource = 'Phone Inquiry')
                                                  };
        insert contacts;
        
        //Creating Opportunities for Accounts
        List<Opportunity> opportunities = new List<Opportunity>{
                                                                  new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opp Unit Test Corp - 1', CloseDate = Date.Today().addMonths(1), StageName = 'Prospecting',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'New Customer'),
                                                                  new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opp Unit Test Corp - 1', CloseDate = Date.Today().addMonths(1), StageName = 'Needs Analysis',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'Existing Customer - Upgrade'),
                                                                  new Opportunity(AccountId = accounts[2].Id, Name = 'Test Opp Unit Test LLC - 1', CloseDate = Date.Today().addMonths(1), StageName = 'Prospecting',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'New Customer'),
                                                                  new Opportunity(AccountId = accounts[3].Id, Name = 'Test Opp Unit Test LLC - 2', CloseDate = Date.Today().addMonths(1), StageName = 'Needs Analysis',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'Existing Customer - Upgrade'),
                                                                  new Opportunity(AccountId = accounts[4].Id, Name = 'Test Opp Parent Company Inc - 1', CloseDate = Date.Today().addMonths(1), StageName = 'Prospecting',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'New Customer'),
                                                                  new Opportunity(AccountId = accounts[5].Id, Name = 'Test Opp Parent Company Inc - 2', CloseDate = Date.Today().addMonths(1), StageName = 'Needs Analysis',Amount = 121212,Description = 'Test Description',Probability = 10,Type = 'Existing Customer - Upgrade')
                                                               };
        insert opportunities;
        
        // Inserting Masking_Object__c record to perform masking on Account and it's child objects.
        Masking_Object__c objMaskingObject = new Masking_Object__c(Name = 'Account',SOQL_Query__c = 'Select Id From Account where Type = \'Customer - Direct\' AND Is_Masked__c = false',Batch_Size__c = 15,Is_Masked_Field__c = 'Is_Masked__c',IsMaskRun__c = true);
        insert objMaskingObject;
        
        List<MaskObjectData__c> lstMaskingObjectData = new List<MaskObjectData__c>{
                                                                                     new MaskObjectData__c(Name = '1', Object_Api_Name__c = 'Account',Field_Api_Name__c = 'Fax',Relationship_Field_To_Parent__c = 'Id',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '2', Object_Api_Name__c = 'Account',Field_Api_Name__c = 'Type',Relationship_Field_To_Parent__c = 'Id',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '3', Object_Api_Name__c = 'Account',Field_Api_Name__c = 'Phone',Relationship_Field_To_Parent__c = 'Id',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '4', Object_Api_Name__c = 'Account',Field_Api_Name__c = 'Rating',Relationship_Field_To_Parent__c = 'Id',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '5', Object_Api_Name__c = 'Account',Field_Api_Name__c = 'NumberOfEmployees',Relationship_Field_To_Parent__c = 'Id',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '6', Object_Api_Name__c = 'Contact',Field_Api_Name__c = 'Phone',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '7', Object_Api_Name__c = 'Contact',Field_Api_Name__c = 'Title',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '8', Object_Api_Name__c = 'Contact',Field_Api_Name__c = 'Birthdate',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '9', Object_Api_Name__c = 'Contact',Field_Api_Name__c = 'Email',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '10', Object_Api_Name__c = 'Contact',Field_Api_Name__c = 'LeadSource',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '11', Object_Api_Name__c = 'Opportunity',Field_Api_Name__c = 'Amount',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '12', Object_Api_Name__c = 'Opportunity',Field_Api_Name__c = 'Description',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '13', Object_Api_Name__c = 'Opportunity',Field_Api_Name__c = 'Probability',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '14', Object_Api_Name__c = 'Opportunity',Field_Api_Name__c = 'StageName',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account'),
                                                                                     new MaskObjectData__c(Name = '15', Object_Api_Name__c = 'Opportunity',Field_Api_Name__c = 'Type',Relationship_Field_To_Parent__c = 'AccountId',Parent_Object_Api_Name__c = 'Account')
                                                                                  };
        insert lstMaskingObjectData;
        
        List<FieldMaskingType__c> lstFieldMaskingTypes = new List<FieldMaskingType__c>{
                                                                                         new FieldMaskingType__c(Name = 'CURRENCY', Masking_Format_1__c = '123'),
                                                                                         new FieldMaskingType__c(Name = 'DATE', Masking_Format_1__c = '1/29/2015'),
                                                                                         new FieldMaskingType__c(Name = 'DOUBLE', Masking_Format_1__c = ' 123.45'),
                                                                                         new FieldMaskingType__c(Name = 'EMAIL', Masking_Format_1__c = 'xxx@xx.xx'),
                                                                                         new FieldMaskingType__c(Name = 'INTEGER', Masking_Format_1__c = '12345'),
                                                                                         new FieldMaskingType__c(Name = 'MULTIPICKLIST', Masking_Format_1__c = 'xxxxxx'),
                                                                                         new FieldMaskingType__c(Name = 'PHONE', Masking_Format_1__c = '123456789'),
                                                                                         new FieldMaskingType__c(Name = 'PICKLIST', Masking_Format_1__c = 'xxxxxx'),
                                                                                         new FieldMaskingType__c(Name = 'STRING', Masking_Format_1__c = 'xxxxxx'),
                                                                                         new FieldMaskingType__c(Name = 'TEXTAREA', Masking_Format_1__c = 'xxxxxx')
                                                                                      };
       insert lstFieldMaskingTypes;                                                                                       
    }
    
    static testMethod void myUnitTest() 
    {
        // Fetching test data which was created as a part of 
        List<Account> lstAccounts      =  [Select Id,Name,Fax,Type,Phone,Rating,NumberOfEmployees from Account];
        List<Contact> lstContacts      =  [Select Id,AccountId,FirstName,LastName,Phone,Title,Birthdate,Email,LeadSource from Contact];
        List<Opportunity> lstOpportunities = [Select Id,AccountId,Name,CloseDate,StageName,Amount,Description,Probability,Type from Opportunity];
        List<Masking_Object__c> lstMaskingobjectInfo = [Select Name,SOQL_Query__c,Batch_Size__c,Is_Masked_Field__c from Masking_Object__c];
        List<MaskObjectData__c> lstMaskingObjectData = [Select Name,Object_Api_Name__c,Field_Api_Name__c,Relationship_Field_To_Parent__c,Parent_Object_Api_Name__c from MaskObjectData__c];
        List<FieldMaskingType__c> lstFieldMaskingTypes = [Select Name,Masking_Format_1__c from FieldMaskingType__c];
        
        //TO DO: implement unit test
        SchedulableContext sc;
        test.starttest();
          Batch_Mask_Data_Schedular objSchedular = new Batch_Mask_Data_Schedular();
          objSchedular.execute(sc);
        test.stoptest();
        
        //Verifying expected Results for Accounts
        system.assert([Select Id from Account where Type = 'xxxxxx'].size() > 0);
        system.assert([Select Id from Account where Phone = '123456789'].size() > 0);
        system.assert([Select Id from Account where Rating = 'xxxxxx'].size() > 0);
        system.assert([Select Id from Account where Fax = '123456789'].size() > 0);
        system.assert([Select Id from Account where NumberOfEmployees = 12345].size() > 0);
        
        //Verifying expected Results for Contacts
        system.assert([Select Id from Contact where Phone = '123456789'].size() > 0);
        system.assert([Select Id from Contact where Email = 'xxx@xx.xx'].size() > 0);
       
        //Verifying expected Results for Opportunities
        system.assert([Select Id from Opportunity where Amount= 123].size() > 0);
        system.assert([Select Id from Opportunity where StageName = 'xxxxxx'].size() > 0);
        system.assert([Select Id from Opportunity where Type = 'xxxxxx'].size() > 0);
    } 
    
    static testMethod void testExceptionHandler() 
    {
        // Fetching test data which was created as a part of 
        List<Account> lstAccounts      =  [Select Id,Name,Fax,Type,Phone,Rating,NumberOfEmployees from Account];
        List<Contact> lstContacts      =  [Select Id,AccountId,FirstName,LastName,Phone,Title,Birthdate,Email,LeadSource from Contact];
        List<Opportunity> lstOpportunities = [Select Id,AccountId,Name,CloseDate,StageName,Amount,Description,Probability,Type from Opportunity];
        List<Masking_Object__c> lstMaskingobjectInfo = [Select Name,SOQL_Query__c,Batch_Size__c,Is_Masked_Field__c from Masking_Object__c];
        List<MaskObjectData__c> lstMaskingObjectData = [Select Name,Object_Api_Name__c,Field_Api_Name__c,Relationship_Field_To_Parent__c,Parent_Object_Api_Name__c from MaskObjectData__c];
        List<FieldMaskingType__c> lstFieldMaskingTypes = [Select Name,Masking_Format_1__c from FieldMaskingType__c];
        
        List<FieldMaskingType__c> lstExistingFieldTypes = [Select Name,Masking_Format_1__c from FieldMaskingType__c
                                                          where Name='CURRENCY'];
        if(!lstExistingFieldTypes.isEmpty())
        {
            lstExistingFieldTypes[0].Masking_Format_1__c = 'abc';
            update lstExistingFieldTypes[0];
        }
        
        
        //TO DO: implement unit test
        SchedulableContext sc;
        test.starttest();
          Batch_Mask_Data_Schedular objSchedular = new Batch_Mask_Data_Schedular();
          objSchedular.execute(sc);
        test.stoptest();
        
        //Verifying expected results.
        system.assert([Select Id from Error_Log__c ].size() > 0); 
    }   
}