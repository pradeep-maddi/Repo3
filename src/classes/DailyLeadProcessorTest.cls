@isTest
public class DailyLeadProcessorTest
{
    static testMethod void testAccs()
    {
        String strCronExp  = '0 0 0 15 3 ? 2022';
        
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
            String jobId = System.schedule('ScheduledApexTest', strCronExp  ,new DailyLeadProcessor());          
        test.stoptest();
    }
}