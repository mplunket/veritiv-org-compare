trigger AccountPlan on Account_Plan__c (after insert, after update)
{
	if( trigger.isInsert )
	{
		AccessLevelServices.grantAccountPlanAccessToATMs( trigger.newMap );
	}

	else if( trigger.isUpdate )
	{
		AccessLevelServices.grantAccessForMigratedAccountPlans( trigger.newMap, trigger.oldMap );
	}
}