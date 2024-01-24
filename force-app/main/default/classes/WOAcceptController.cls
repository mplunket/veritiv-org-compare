public class WOAcceptController {
    
    
    public WorkOrder currentWO; 
    public WOAcceptController(ApexPages.StandardController controller) {
        //currentCase = (Case)controller.getRecord();
    }


    /*
    public CaseAcceptController() {
        
    }
    */
    public PageReference init(){
        currentWO = [SELECT Id, Status,ownerid FROM workorder WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        system.debug(currentWO );
        id currentUserId = UserInfo.getUserId();
        currentWO.ownerid = currentUserId ;
        currentWO.Status = 'In Progress';
        update currentWO ;
        
        PageReference pg = new PageReference('/'+currentWO .Id);
        pg.setRedirect(true);
        return pg;  
    }


}