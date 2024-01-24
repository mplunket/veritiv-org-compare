@isTest
//(SeeAllData=true) removed as this is against best practice. Only use when needed
public class CaseTriggerHandlerTest {
    
    
    
    @testSetup static void setup() {
        User consoleUser = new user();
        Account testAccount  = TestingUtils.createAccount( 'TestAccount' );    
        testAccount.Legacy_System_Cd__c='03';
        insert testAccount;
        Contact testContact;
        testContact = TestingUtils.createContact( 'John', 'Doe', true );
        testContact.Email = 'johndoe@test.com';
        testContact.accountid = testAccount.id;
        update testContact;
        consoleUser = TestingUtils.createUser('testuser', 'CS - Lightning Console', true);
        
        RecordType testRecordType = [ SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Incoming_Fax' AND SObjectType = 'Case' ];
        List<Case> nCases = new list<case>();
        nCases = TestingUtils.generateCases( 10, testAccount.Id, testContact.Id, testRecordType.Id, false);
        system.debug('consoleUser  = '+consoleUser);
        nCases[0].accountid = null;
        nCases[0].contactid = null;
        nCases[0].SuppliedEmail = 'johndoe@test.com';
        nCases[0].status= 'In Process';
        for (Case c : nCases){
            c.ownerid = consoleUser.id;
        }
        insert nCases ;
    }
    
    

    static testMethod void test1(){
        
        User u = [select id, lastname, username from user where email = 'testuser1@unisourcelink.com' limit 1];
        system.debug('user = '+u);
        List<Case> newCases = new list<case>();
        newCases = [select id from case];
        /*
        for( Case aCase : newCases ){
            aCase.OwnerId = u.Id;
            aCase.Status = 'TestStatus';
        }
        */
        
        Test.startTest();

            System.runAs(u){ 
                update newCases; 
            }

        Test.stopTest();
        
    }
    
    static testMethod void test2(){
        
        User u = [select id, lastname, username from user where email = 'testuser1@unisourcelink.com' limit 1];
        system.debug('user = '+u);
        List<Case> newCases = new list<case>();
        newCases = [select id from case];
        for(case c: newCases){
            c.customDescription__c = 'testdesc';
            c.description= 'testdesc';
            c.status='In Routing';
        }
        /*
        for( Case aCase : newCases ){
            aCase.OwnerId = u.Id;
            aCase.Status = 'TestStatus';
        }
        */
        
        Test.startTest();

            System.runAs(u){ 
                
                update newCases; 
            }

        Test.stopTest();
        
    }
    
    /*
    static testMethod void casetest() {
        user objUser = [SELECT Id, IsActive FROM User WHERE username = 'jennifer.bell@veritivcorp.com.ecom'];
        List<Case> objCase = [SELECT Id, CaseNumber, AccountId, Account.Name, Contact.Account_Name_Formula__c, recordtypeId, Last_Activity_Date__c, Is_Spam__c, OwnerId FROM Case WHERE CaseNumber = '10544613'];
        Test.startTest();
        system.RunAs(objUser)
        {
            update objCase;
        }        
        Test.stopTest();        
    } 
    */  
}