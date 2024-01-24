/*Name: CloseCase
Created By : Sujitha
Created Date: 9/18
*/

public class CloseCase{
    public Case changeOwnerCase {get; set;}
    public ID caseIdVar{get;set;}
    private ApexPages.StandardController stdController {get; set;}
    
    public CloseCase( ApexPages.StandardController stdController ){
        
        this.stdController = stdController;
        changeOwnerCase = (Case)stdController.getRecord();
        
    }
    
    public pagereference CloseCaseMethod(){
        caseIdVar =  ApexPages.currentPage().getParameters().get('caseId');
        system.debug(caseIdVar );
        if(caseIdVar != null){
            case c = [select id, status from case where id =: caseIdVar ];
            c.status = 'Closed';
            try{
                update c;
                System.debug('updated status'+ c.Status);
                PageReference nextPage = new PageReference('/' + c.Id);
                
                return nextPage;
            }
            catch(exception e){
                system.debug(e);
                ApexPages.addMessages(e); 
            }
            
        }
        return null;
    }
    
    public pageReference goBack(){
        PageReference nextPage = new PageReference('/' +caseIdVar);
        return nextPage;
    }
}