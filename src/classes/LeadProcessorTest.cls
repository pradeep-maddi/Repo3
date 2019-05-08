@isTest
public class LeadProcessorTest
{
    static testMethod void testAccs()
    {
        List<Account> lstAccounts = new List<Account>{new Account(Name = 'Account-01'),
                                                       new Account(Name = 'Account-02')};
        insert lstAccounts;
        
        List<Lead> lstLeadsToInsert = new List<Lead>();
        for(Integer index=0; index < 199; index++ )        
        {
            lstLeadsToInsert.add(new Lead(LastName = 'Lead - ' + index, Status='Open - Not Contacted',Company= lstAccounts[0].Id));
        }
        insert lstLeadsToInsert;
        
        test.starttest();
            Database.executebatch(new LeadProcessor());
        test.stoptest();
    }
}