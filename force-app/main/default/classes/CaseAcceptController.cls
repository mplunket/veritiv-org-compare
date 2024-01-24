public class CaseAcceptController {
    
    
    public Case currentCase; 
    public CaseAcceptController(ApexPages.StandardController controller) {
        //currentCase = (Case)controller.getRecord();
    }


    /*
    public CaseAcceptController() {
        
    }
    */
    public PageReference init(){
        currentCase = [SELECT Id, Status,ownerid FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        system.debug(currentcase);
        id currentUserId = UserInfo.getUserId();
        currentCase.ownerid = currentUserId ;
        currentCase.Status = 'In Process';
        update currentCase;
        
        PageReference pg = new PageReference('/'+currentCase.Id);
        pg.setRedirect(true);
        return pg;  
    }


}