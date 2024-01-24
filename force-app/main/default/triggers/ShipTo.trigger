trigger ShipTo on Ship_To__c (after delete, after insert, after update) {

    if( trigger.isDelete )
    {
        ShipToServices.updateIRepInfoForAccounts( trigger.oldMap );
    }
    else if( trigger.isInsert )
    {
        ShipToServices.updateIRepInfoForAccounts( trigger.newMap );
    }
    else if( trigger.isUpdate )
    {
        ShipToServices.updateIRepInfoForAccounts( trigger.newMap );
    }

}