@isTest
public class testOpportunityTeamMemberTrigger {
    @isTest
    public static void testSendEmail(){
           
        User testingUser = TestingUtils.createUser('bob', 'System Administrator', true );
        testinguser.email = 'test.test@test.com';
        update testingUser;
        List<Opportunity> opps;
        account acct = TestingUtils.createAccount('Test Account');
        insert acct;
        Test.startTest();
        opps = TestingUtils.createOpportunities(1,acct.ID, 'Test Opp',true);
        Test.stopTest();
        
       // System.runAs(testingUser){
        opportunityTeamMember optTeamMember = new opportunityTeamMember();
        optTeamMember.opportunityId = opps[0].id;
        optTeamMember.TeamMemberRole = 'Specialist Folding Carton';
        optTeamMember.userId = testingUser.Id;
        insert optTeamMember;
    //}
    }
}