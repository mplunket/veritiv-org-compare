@IsTest
private class OpportunityDurationsTest {

    @IsTest
    static void testTriggerInsertAndUpdate() {
        Primary_Sales_Rep__c rep = new Primary_Sales_Rep__c(Name='Test Name', Network_ID__c='TestTest', Email__c='test@test.com');
        insert rep;

        Account testAccount = new Account(Name='Test', Primary_Sales_Rep_Name__c=rep.Id, Account_Vertical__c='Education',Prospect_Segment__c='Print');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(AccountId=testAccount.Id, Name='testOpp', CloseDate=System.TODAY(), StageName='testOppStage');
        insert testOpportunity;

        Opportunity_Durations__c od = new Opportunity_Durations__c(Parent__c=testOpportunity.Id, StageName__c='Insert');

        try {
            insert od;
        } catch (Exception e) {
            System.assert(false, 'Before insert trigger should successfully run, but failed with this error: ' + e.getMessage());
        }

        od.StageName__c = 'Update';

        try {
            update od;
        } catch (Exception e) {
            System.assert(false, 'Before update trigger should successfully run, but failed with this error: ' + e.getMessage());
        }
    }
}