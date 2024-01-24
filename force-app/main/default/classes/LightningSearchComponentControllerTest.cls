@isTest
private class LightningSearchComponentControllerTest {

    private static LightningSearchComponentController.MetadataWrapper buildMetadata() {
        LightningSearchComponentController.MetadataWrapper metadata = new LightningSearchComponentController.MetadataWrapper();

        Map<String, LightningSearchComponentController.FormatWrapper> displayFormats = new Map<String, LightningSearchComponentController.FormatWrapper>();

        for(SObjectType objectType : LightningSearchComponentController.OBJECTS) {
            String objectName = objectType.getDescribe().getName();
            String headerFieldSetName = objectName + LightningSearchComponentController.headerSetFormat;
            String subHeaderFieldSetName = objectName + LightningSearchComponentController.subHeaderSetFormat;
            String detailFieldSetName = objectName + LightningSearchComponentController.detailSetFormat;
            String searchFieldSetName = objectName + LightningSearchComponentController.searchFieldSetFormat;

            Map<String, Schema.FieldSet> fieldsetMap = objectType.getDescribe().fieldsets.getMap();
            Schema.FieldSet headerFieldSet = fieldsetMap.get(headerFieldSetName);
            Schema.FieldSet subHeaderFieldSet = fieldsetMap.get(subHeaderFieldSetName);
            Schema.FieldSet detailFieldSet = fieldsetMap.get(detailFieldSetName);
            Schema.FieldSet searchFieldSet = fieldsetMap.get(searchFieldSetName);

            LightningSearchComponentController.FormatWrapper format = new LightningSearchComponentController.FormatWrapper();
            format.objectName = new LightningSearchComponentController.FieldWrapper(objectName, objectType.getDescribe().getLabel());
            format.headerFields = LightningSearchComponentController.fieldsetToFields(headerFieldSet);
            format.subHeaderFields = LightningSearchComponentController.fieldsetToFields(subHeaderFieldSet);
            format.detailFields = LightningSearchComponentController.fieldsetToFields(detailFieldSet);
            format.searchFields = LightningSearchComponentController.fieldsetToFields(searchFieldSet);

            displayFormats.put(format.objectName.name, format);
        }
        metadata.displayFormats = displayFormats;

        metadata.statePicklistValues = new List<LightningSearchComponentController.FieldWrapper>();
        List<Schema.PicklistEntry> stateEntries = Lead.State__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : stateEntries) {
            metadata.statePicklistValues.add(new LightningSearchComponentController.FieldWrapper(entry.getValue(), entry.getLabel()));
        }

        metadata.segmentPicklistValues = new List<LightningSearchComponentController.FieldWrapper>();
        List<Schema.PicklistEntry> segmentEntries = Account.Segment_2__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : segmentEntries) {
            String segmentValue = entry.getValue();
            String segmentLabel = segmentValue;
            if(LightningSearchComponentController.segmentMap.containsKey(segmentValue)) {
                segmentLabel = LightningSearchComponentController.segmentMap.get(segmentValue);
            }
            
            metadata.segmentPicklistValues.add(new LightningSearchComponentController.FieldWrapper(segmentValue, segmentLabel));
        }

        return metadata;
    }

    @isTest 
    private static void test_getObjectMetadata() {

        LightningSearchComponentController.MetadataWrapper expectedMetadata = buildMetadata();

        Test.startTest();
            LightningSearchComponentController.MetadataWrapper actualMetadata = LightningSearchComponentController.getObjectMetadata();
        Test.stopTest();

        Map<String, LightningSearchComponentController.FormatWrapper> expectedFormats = expectedMetadata.displayFormats;
        Map<String, LightningSearchComponentController.FormatWrapper> actualFormats = actualMetadata.displayFormats;

        System.assertEquals(expectedFormats.size(), actualFormats.size(), 'We expect the proper amount of format wrappers to return');

        List<String> keys = new List<String>(expectedFormats.keySet());
        for(String key : keys) {
            LightningSearchComponentController.FormatWrapper actual = actualFormats.get(key);
            LightningSearchComponentController.FormatWrapper expected = expectedFormats.get(key);

            assertFieldLists(expected.headerFields, actual.headerFields);
            assertFieldLists(expected.subHeaderFields, actual.subHeaderFields);
            assertFieldLists(expected.detailFields, actual.detailFields);
        }
    }

    private static void assertFieldLists(List<LightningSearchComponentController.FieldWrapper> expectedList, List<LightningSearchComponentController.FieldWrapper> actualList) {
        for(Integer i = 0; i < expectedList.size(); i++) {
            LightningSearchComponentController.FieldWrapper expectedField = expectedList[i];
            LightningSearchComponentController.FieldWrapper actualField = actualList[i];
            System.assertEquals(expectedField.label, actualField.label, 'We expect the field labels to be the same.');
            System.assertEquals(expectedField.name, actualField.name, 'We expect the field names to be the same.');
        }
    }


    @isTest
    private static void test_searchObjects() {
        LightningSearchComponentController.MetadataWrapper metadata = buildMetadata();
        String searchString = 'Test Search';
        List<String> segments = new List<String>();

        for(LightningSearchComponentController.FieldWrapper picklistValue : metadata.segmentPicklistValues) {
            segments.add(picklistValue.name);
        }

        List<String> matchedSegments = new List<String>{segments[0], segments[1]};

        UnitTest.addData( SObjectFactory.build(segments.size() * 2, Account.SObjectType) )
                .tag('All Objects')
                .tag('All Accounts')
                .branch('Matched Accounts | Unmatched Accounts');

        UnitTest.get('Matched Accounts')
                .assign(metadata.displayFormats.get('Account').searchFields[0].name, searchString)
                .property('Segment_2__c')
                .assignFrom(matchedSegments);

        UnitTest.addData( SObjectFactory.build(segments.size() * 2, Lead.SObjectType) )
                .tag('All Objects')
                .tag('All Leads')
                .branch('Matched Leads | Unmatched Leads');

        UnitTest.get('Matched Leads')
                .assign(metadata.displayFormats.get('Lead').searchFields[0].name, searchString)
                .property('Segment__c')
                .assignFrom(matchedSegments);

        insert UnitTest.get('All Objects').getList();

        List<Id> objectIds = new List<Id>(UnitTest.getIds('All Objects'));
        Test.setFixedSearchResults(objectIds);

        Map<String, Map<String, List<String>>> filters = new Map<String, Map<String, List<String>>>{
            'Account' => new Map<String, List<String>>{'Segment_2__c' => matchedSegments},
            'Lead' => new Map<String, List<String>>{'Segment__c' => matchedSegments}
        };
            
        Map<String, Map<String, String>> filterOperators = new Map<String, Map<String, String>>{
            'Account' => new Map<String, String>{'Segment_2__c' => '=', 'Servicing_Division_Name__c' => 'LIKE', 'BillingState' => '='},
            'Lead' => new Map<String, String>{'Segment__c' => '=', 'State' => '='}
        }; 
            
        Test.startTest();
            Map<String, List<SObject>> results = LightningSearchComponentController.searchObjects(searchString, 
                JSON.serialize(metadata.displayFormats), JSON.serialize(filters), JSON.serialize(filterOperators));
        Test.stopTest();

        List<SObject> returnedAccounts = results.get('Account');
        List<SObject> returnedLeads = results.get('Lead');


        UnitTest.analyze('Matched Accounts').assertEquivalence(returnedAccounts, 'We expect the proper Accounts to be returned');
        UnitTest.analyze('Matched Leads').assertEquivalence(returnedLeads, 'We expect the proper Leads to be returned');
    }

}