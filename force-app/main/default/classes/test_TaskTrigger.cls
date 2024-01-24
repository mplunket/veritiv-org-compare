@isTest
public class test_TaskTrigger {

    @isTest
    public static void testTask(){
        lead l = new lead ();
        l.firstname = 'test';
        l.lastname ='test';
        l.email = 'test.test@test.com';
            l.company = 'test';
        insert l;
        
        task ts = new task();
        ts.whoId = l.id;
        ts.subject = 'testing';
        insert ts;
        task ts2 = new task();
        ts2.whoId = l.id;
        ts2.subject = 'testing2';
        insert ts2;
        
       
    }
}