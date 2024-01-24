@IsTest
private class RoutingRecordCleanupBatchTest {
    @IsTest
    static void testInactiveDateStamp() {
        Contact testContact = (Contact) new SObjectBuilder(Contact.SObjectType)
                .create().getRecord();
        ANI_TFN_Mapping__c testMapping = (ANI_TFN_Mapping__c) new SObjectBuilder(ANI_TFN_Mapping__c.SObjectType)
            	.put(ANI_TFN_Mapping__c.name, '123-456-7890')
                .create().getRecord();
        ANI_Routing_Record__c testRecord = (ANI_Routing_Record__c) new SObjectBuilder(ANI_Routing_Record__c.SObjectType)
                .put(ANI_Routing_Record__c.ANI_Contact__c, testContact.Id)
                .put(ANI_Routing_Record__c.ANI_Toll_Free_Map_Number__c, testMapping.Id)
                .create().getRecord();

        testRecord.put(ANI_Routing_Record__c.Inactive__c, true);

        Test.startTest();
            update testRecord;
        Test.stopTest();

        Date today = Date.today();
        Date dateInSystem = [SELECT Inactive_Date__c FROM ANI_Routing_Record__c].Inactive_Date__c;
        System.assertEquals(today, dateInSystem, 'We expect the Inactive date to be stamped with the current date.');
    }
    @isTest
    static void testDelete60DayOldRecord() {
        Contact testContact = (Contact) new SObjectBuilder(Contact.SObjectType)
                .create().getRecord();
        ANI_TFN_Mapping__c testMapping = (ANI_TFN_Mapping__c) new SObjectBuilder(ANI_TFN_Mapping__c.SObjectType)
            	.put(ANI_TFN_Mapping__c.name, '123-456-7890')
                .create().getRecord();
        ANI_Routing_Record__c testRecord = (ANI_Routing_Record__c) new SObjectBuilder(ANI_Routing_Record__c.SObjectType)
                .put(ANI_Routing_Record__c.ANI_Contact__c, testContact.Id)
                .put(ANI_Routing_Record__c.ANI_Toll_Free_Map_Number__c, testMapping.Id)
                .put(ANI_Routing_Record__c.Inactive__c, true)
                .create().getRecord();

        testRecord.put(ANI_Routing_Record__c.Inactive_Date__c, Date.today().addDays(-61));
        update testRecord;

        RoutingRecordCleanupBatch cleanupBatch = new RoutingRecordCleanupBatch();

        Test.startTest();
            Database.executeBatch(cleanupBatch);
        Test.stopTest();

        ANI_Routing_Record__c deletedRecord = [SELECT IsDeleted FROM ANI_Routing_Record__c ALL ROWS];
        System.assertEquals(true, deletedRecord.IsDeleted,
                'We expect a routing record that has been Inactive for 60 days or more to be deleted.');
    }
    @isTest
    static void testDontDeleteUnder60DayOldRecord() {
        Contact testContact = (Contact) new SObjectBuilder(Contact.SObjectType)
                .create().getRecord();
        ANI_TFN_Mapping__c testMapping = (ANI_TFN_Mapping__c) new SObjectBuilder(ANI_TFN_Mapping__c.SObjectType)
            	.put(ANI_TFN_Mapping__c.name, '123-456-7890')
                .create().getRecord();
        ANI_Routing_Record__c testRecord = (ANI_Routing_Record__c) new SObjectBuilder(ANI_Routing_Record__c.SObjectType)
                .put(ANI_Routing_Record__c.ANI_Contact__c, testContact.Id)
                .put(ANI_Routing_Record__c.ANI_Toll_Free_Map_Number__c, testMapping.Id)
                .put(ANI_Routing_Record__c.Inactive__c, true)
                .create().getRecord();

        RoutingRecordCleanupBatch cleanupBatch = new RoutingRecordCleanupBatch();

        Test.startTest();
            Database.executeBatch(cleanupBatch);
        Test.stopTest();

        ANI_Routing_Record__c notDeletedRecord = [SELECT IsDeleted FROM ANI_Routing_Record__c];
        System.assertEquals(false, notDeletedRecord.IsDeleted,
                'We expect a routing record that has been Inactive for less than 60 days to not be deleted.');
    }
}