@isTest
public class AccountProcessorTest
{
    static testMethod void testAccs()
    {
        List<Account> lstAccounts = new List<Account>{new Account(Name = 'Account-01'),
                                                       new Account(Name = 'Account-02')};
        insert lstAccounts;
        
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, LastName = 'Contact-01');
        insert objContact;
        
        test.starttest();
            AccountProcessor.countContacts(new List<Id>{lstAccounts[0].Id,lstAccounts[1].Id});
        test.stoptest();
        
        Account updatedAcc = [select Number_of_Contacts__c 
                              from Account 
                              where Id =: lstAccounts[0].Id
                             ];
        
        system.assertEquals(updatedAcc.Number_of_Contacts__c ,1);
        
    }
}