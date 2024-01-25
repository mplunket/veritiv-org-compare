@isTest
private class TestTaskTriggerUtils {

  private static Account testAccount;
   
  private static String SERVER_URL;

  private static void setupData(Integer numberChats)
  {
     
     
     
     
    
    SERVER_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    
    testAccount = new Account(Name='Test Account');
    insert testAccount;
    
     
     
     
     
      
     
  }

  private static testmethod void test_processInstantServiceTasks_Account()
  {
    setupData(1);
    Task task = new Task(WhatId = testAccount.Id, Type = 'Via IS Chat');
    insert task;
    
    task = [select Id, Related_Chat__c from Task where Id = :task.Id];
    
     
  }
  
  private static testmethod void test_processInstantServiceTasks_Account_null()
  {
    setupData(1);
    Task task = new Task(WhatId = testAccount.Id, Type = 'Call');
    insert task;
    
    task = [select Id, Related_Chat__c from Task where Id = :task.Id];
    
    System.assertEquals(null, task.Related_Chat__c);
    
    Task taskNullWhat = new Task( Type = 'Via IS Chat');
    insert taskNullWhat;
    
    taskNullWhat = [select Id, WhatId, Related_Chat__c from Task where Id = :taskNullWhat.Id];
    System.debug(taskNullWhat);
    System.assertEquals(null, taskNullWhat.Related_Chat__c);
    
  }

  private static testmethod void test_attachmentReparent()
  {
    Id recordTypeToReparent = [SELECT Id FROM RecordType WHERE Name='Console Case'].Id;

    UnitTest.addData(SObjectFactory.build(2, Case.sObjectType))
        .tag('All Cases')
        .branch('Case With Attachment | Case Without Attachment');

    UnitTest.get('Case With Attachment')
      .assign('RecordTypeId', recordTypeToReparent);

    UnitTest.get('All Cases').insertAll();

    UnitTest.addData(SObjectFactory.build(2, Task.sObjectType))
      .tag('All Tasks')
      .branch('Task To Reparent | Task To Not Reparent');

    UnitTest.get('Task To Reparent')
      .property('WhatId')
      .assignFrom('Case With Attachment');

    UnitTest.get('Task To Not Reparent')
      .property('WhatId')
      .assignFrom('Case Without Attachment');

    UnitTest.get('All Tasks').insertAll();

    UnitTest.addData(SObjectFactory.build(2, Attachment.sObjectType))
      .tag('All Attachments')
      .branch('Attachment To Reparent | Attachment To Not Reparent');

    UnitTest.get('Attachment To Reparent')
      .property('ParentId')
      .assignFrom('Task To Reparent')
      .assign('Name', 'reparent.txt')
      .assign('Body', Blob.valueOf('reparented'));

    UnitTest.get('Attachment To Not Reparent')
      .property('ParentId')
      .assignFrom('Task To Not Reparent')
      .assign('Name', 'test.txt')
      .assign('Body', Blob.valueOf('test'));


    UnitTest.get('All Attachments').insertAll();

    Test.startTest();
      TaskTriggerUtils.reparentAttachments(UnitTest.get('All Tasks').getList());
    Test.stopTest();

    Case caseWithAttachment = (Case) UnitTest.get('Case With Attachment').getList()[0];
    Case caseWithoutAttachment = (Case) UnitTest.get('Case Without Attachment').getList()[0];
    Attachment attBeforeReparent = (Attachment) UnitTest.get('Attachment To Reparent').getList()[0];
    Attachment attAfterReparent = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId =:caseWithAttachment.Id][0];

    System.assertEquals(attBeforeReparent.Name, attAfterReparent.Name, 'We expect the proper attachment to be reparented');
    System.assertEquals(0, [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId =:caseWithoutAttachment.Id].size(),
      'We expect no attachment to exist on this case');

  }

}