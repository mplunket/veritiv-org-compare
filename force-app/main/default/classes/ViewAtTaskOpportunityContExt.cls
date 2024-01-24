/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Controller to drive ViewAtTask page
*/
public with sharing class ViewAtTaskOpportunityContExt {

	public final OpportunityModel oppModel { get; private set; }
	
    public ViewAtTaskOpportunityContExt(ApexPages.StandardController controller) {		
		this.oppModel = new OpportunityModel(controller.getId());			
    }

}