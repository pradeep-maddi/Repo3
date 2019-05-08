public class LanguageCheck
{
    
    public string strLanguageCheck {get;set;}
    
    public LanguageCheck()
    {
        if(ApexPages.currentPage().getParameters().containsKey('lang'))
            strLanguageCheck = ApexPages.currentPage().getParameters().get('lang');
    }
}