public class AccountProcessor{
 
    @future 
    public static void countContacts(List<Id> lstAccIds)
    {
        System.debug('11111'); 
         System.debug('222222'); 
        List<Account> lstAccountsToUpdate = new List<Account>();
        set<Id> setAcctIds = new set<Id>(lstAccIds);
        System.debug('222'); 
        for(AggregateResult groupedResults : [SELECT count(Id),AccountId FROM Contact
                                              Where AccountId IN: lstAccIds
                                              Group by AccountId ])
        {
            lstAccountsToUpdate.add(new Account(Id = (Id)groupedResults.get('AccountId'),Number_of_Contacts__c = (Integer)groupedResults.get('expr0')));      
            setAcctIds.remove((Id)groupedResults.get('AccountId'));               
        }
                  
        for(Id acctId : setAcctIds){
            lstAccountsToUpdate.add(new Account(Id = acctId,Number_of_Contacts__c = 0));
        }       
        
        update lstAccountsToUpdate;
    }
}
