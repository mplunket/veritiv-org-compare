public class RenderPAPDFQueueable implements Queueable, Database.AllowsCallouts {
    
    private Id paId;
    
    public RenderPAPDFQueueable(Id paId) {
        this.paId = paId;
        system.debug('Queue run ' + paId);
    }
    
    public void execute(QueueableContext context) {
        // Retrieve the Product Analysis record
        Product_Analysis__c pa = [SELECT Id, Name, CreatedDate FROM Product_Analysis__c WHERE Id = :paId];
        
        system.debug('Queue pa ' + pa);
        // Render the Visualforce page as a PDF
        PageReference pdfPage = Page.PAPDF;
        pdfPage.getParameters().put('id', pa.id);
        Blob pdfBlob;
        //Rodney update: added check for test class as getcontent isn't supported in test classes
        if(!Test.isRunningTest()){
            pdfBlob = pdfPage.getContentAsPDF();
        }else{
            pdfBlob = Blob.valueOf('Test PDF content');
        }
        //Create a new file and attach it to the account record
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'Product_Analysis' + pa.Name + '.pdf';
        cv.Title = 'Secure Wrap Analysis ' + pa.Name + ' PDF';
        cv.VersionData = pdfBlob;
        cv.FirstPublishLocationId = pa.Id;
        insert cv;
    }

}