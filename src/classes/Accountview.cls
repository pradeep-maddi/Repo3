public class Accountview
{
   
   public Accountview(ApexPages.StandardController controller)
   {
   }
   
   public pagereference actionRedirect()
   {       
       if(Apexpages.currentpage().getparameters().get('searchId') ==  'login')
           return new pagereference('/apex/SiteLogin');
       
       else
           return new pagereference('/apex/SLDS');    
       
   }
   
}