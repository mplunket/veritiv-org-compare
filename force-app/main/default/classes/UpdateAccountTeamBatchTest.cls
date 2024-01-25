@isTest
public class UpdateAccountTeamBatchTest {
	public static testMethod void runTest(){
        
        UpdateAccountTeamBatch BC=new UpdateAccountTeamBatch();
        Account a = new Account(name='Test Account Batch');
        insert a;
        
        Account a2 = new Account(name='Test Account Batch 2');
        insert a2;
        
        Ship_To__c shp = new Ship_To__c();
        shp.Bill_To_Account__c = a.Id;
        shp.Name = 'Test Monday';
        shp.Account_Owner__c = UserInfo.getUserId();
        UpdateAccountTeamHelper.runTrigger = false;
        insert shp;
        
        Set<Id> shpIds = New Set<Id>();
        shpIds.add(shp.Id);
        UpdateAccountTeamBatch.run(shpIds);
        
    }
    
    public static testMethod void executeTest(){
        
        UpdateAccountTeamBatch BC=new UpdateAccountTeamBatch();
        Account a = new Account(name='Test Account Batch');
        insert a;
        
        Account a2 = new Account(name='Test Account Batch 2');
        insert a2;
        
        Ship_To__c shp = new Ship_To__c();
        shp.Bill_To_Account__c = a.Id;
        shp.Name = 'Test Monday';
        shp.Account_Owner__c = UserInfo.getUserId();
        UpdateAccountTeamHelper.runTrigger = false;
        insert shp;
        
        Set<Id> shpIds = New Set<Id>();
        shpIds.add(shp.Id);
        
        DataBase.executeBatch(BC,200);
    }
}