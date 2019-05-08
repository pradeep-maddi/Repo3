public class InputFileUsingHtmlJavaScript
{
    public String filename{get;set;}
    public String body{get;set;}
    public void doAttachment()
    { 
       Attachment at=new Attachment();
       at.Name=filename;
       at.Body=Blob.valueOf(body);
       
       system.debug('------Name----------' + filename);
       system.debug('------body----------' + body);
   }
}