@isTest
//(SeeAllData=true) removed as this is against best practice. Only use when needed
public class CaseTriggerHandlerTest {
    
    
    
    @testSetup static void setup() {
        User consoleUser = new user();
        //create the other ani users
        List<user> aniUsers = new list<user>();
        aniUsers = TestingUtils.createUsers('aniUser', 'CS - Lightning Console', 4, true);
        
        Account testAccount  = TestingUtils.createAccount( 'TestAccount' );    
        testAccount.Legacy_System_Cd__c='03';
        
        for(user anUser: [select id, lastname, username, email from user]){
            if(anUser.email == 'aniUser1@unisourcelink.com'){
                testaccount.ANI_Primary__c = anUser.id;
            }
            if(anUser.email == 'aniUser2@unisourcelink.com'){
                testaccount.ANI_Secondary__c =  anUser.id;
            }
            if(anUser.email == 'aniUser3@unisourcelink.com'){
                testaccount.ANI_Tertiary__c =  anUser.id;
            }
        }
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
        
        RecordType testRecordTypeLightning = [ SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Console_CS_Lightning' AND SObjectType = 'Case' ];
        List<Case> lCases = new list<case>();
        lCases = TestingUtils.generateCases( 10, testAccount.Id, testContact.Id, testRecordTypeLightning.Id, false);
        system.debug('consoleUser  = '+consoleUser);
        lCases[0].accountid = null;
        lCases[0].contactid = null;
        lCases[0].SuppliedEmail = 'johndoe@test.com';
        lCases[0].status= 'In Process';
        lCases[1].status= 'Closed';
        for (Case c : lCases){
            c.ownerid = consoleUser.id;
            nCases.add(c);
        }
        
        insert nCases ;
        
    }
    
    

    static testMethod void test1(){
        
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        system.debug('user = '+u);
        List<Case> newCases = new list<case>();
        newCases = [select id from case];
         
   
        Test.startTest();

            System.runAs(u){ 
                update newCases; 
            }

        Test.stopTest();
        
    }
    
    static testMethod void test2(){
        
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        system.debug('user = '+u);
        List<Case> newCases = new list<case>();
        newCases = [select id from case where status !='Closed'];
        for(case c: newCases){
            c.customDescription__c = 'testdesc';
            c.description= 'testdesc';
            c.status='In Routing';
        }
                
        Test.startTest();

            System.runAs(u){ 
                
                update newCases; 
            }

        Test.stopTest();
        
    }
    
    static testMethod void test3(){
        //active primary
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        system.debug('user = '+u);
   
        Test.startTest();
            u.isactive = false;
            u.Date_Deactivated__c=system.today();
            u.Deactivation_Reason__c='Other';
            update u;

        Test.stopTest();
        
    }
    
    static testMethod void test4(){
    
        //inactive primary, active secondary
        list <user> usersToDeac = new list <User>();
        for(user anUser: [select id, lastname, username, email from user]){
            if(anUser.email == 'aniUser1@unisourcelink.com'){
                anUser.isactive = false;
                anUser.Date_Deactivated__c=system.today();
                anUser.Deactivation_Reason__c='Other';
                usersToDeac.add(anUser);
            }
            
        }      
        update usersToDeac;
        
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        system.debug('user = '+u);
   
        Test.startTest();
            u.isactive = false;
            u.Date_Deactivated__c=system.today();
            u.Deactivation_Reason__c='Other';
            update u;

        Test.stopTest();
        
    }
    
    static testMethod void test5(){
    
        //inactive primary, secondary, active tertiary
        list <user> usersToDeac = new list <User>();
        for(user anUser: [select id, lastname, username, email from user]){
            if(anUser.email == 'aniUser1@unisourcelink.com' || anUser.email == 'aniUser2@unisourcelink.com'){
                anUser.isactive = false;
                anUser.Date_Deactivated__c=system.today();
                anUser.Deactivation_Reason__c='Other';
                usersToDeac.add(anUser);
            }
            
        }      
        update usersToDeac;
        
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        system.debug('user = '+u);
   
        Test.startTest();
            u.isactive = false;
            u.Date_Deactivated__c=system.today();
            u.Deactivation_Reason__c='Other';
            update u;

        Test.stopTest();
        
    }
    
    static testMethod void test6(){
    
        //inactive ANI, open case
        user managerUser = new user();
        list <user> usersToDeac = new list <User>();
        userrole uRole = new userrole();
        uRole = [select id from userrole where developername ='CS_CIN_PRINT_TM1' limit 1];
        system.debug('ROLE '+urole);
        for(user anUser: [select id, lastname, username, email from user]){
            if(anUser.email == 'aniUser1@unisourcelink.com' || anUser.email == 'aniUser2@unisourcelink.com'|| anUser.email == 'aniUser3@unisourcelink.com'){
                anUser.isactive = false;
                anUser.Date_Deactivated__c=system.today();
                anUser.Deactivation_Reason__c='Other';
                usersToDeac.add(anUser);
            }
            if(anUser.email == 'aniUser4@unisourcelink.com'){               
                managerUser = anUser;                
            }
            
        }      
        update usersToDeac;
        
        User u = [select id, lastname, username from user where email = 'testuser5@unisourcelink.com' limit 1];
        u.userroleid=uRole.id;
        update u; 
        system.debug('user = '+u);
   
        Test.startTest();
            u.managerid = managerUser.id;
            u.isactive = false;
            u.Date_Deactivated__c=system.today();
            u.Deactivation_Reason__c='Other';
            update u;

        Test.stopTest();
        
    }
    
    
    
    
}