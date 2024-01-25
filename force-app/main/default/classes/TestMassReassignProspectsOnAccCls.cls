@isTest
public class TestMassReassignProspectsOnAccCls {

    
    @isTest
    public static void testMassUpdateProspectsRecords(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.OwnerId = userinfo.getUserId();
       // insert acc;
        List<Account> tsList = new List<Account>();
        tsList.add(acc);
        insert tsList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(tsList);
        sc.setSelected(tsList);
  MassReassignProspectsOnAccountsCLs msr = new MassReassignProspectsOnAccountsCLs(sc);
       // MassReassignProspectsOnAccountsCLs msr = new MassReassignProspectsOnAccountsCLs(sc);
        msr.accountListing = tsList;
        // newAccountPlan testAccPlan = new newAccountPlan(sc);
        msr.massUpdateProspectsRecords();
        msr.getUserLookup();
        msr.updateSelected();
    }
    
    
    
    
    
    
     @isTest
    public static void testMassUpdateProspectsRecords2(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.OwnerId = userinfo.getUserId();
       // insert acc;
        List<Account> tsList = new List<Account>();
        tsList.add(acc);
        insert tsList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(tsList);
       // sc.setSelected(tsList);
  MassReassignProspectsOnAccountsCLs msr = new MassReassignProspectsOnAccountsCLs(sc);
       // MassReassignProspectsOnAccountsCLs msr = new MassReassignProspectsOnAccountsCLs(sc);
        msr.accountListing = tsList;
        // newAccountPlan testAccPlan = new newAccountPlan(sc);
        msr.massUpdateProspectsRecords();
        msr.getUserLookup();
        msr.updateSelected();
    }
    
}