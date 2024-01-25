@isTest
public class TestOpenCaseOwnerNamesController {
  
  static {
    
    InactiveRecordTypes__c inactiveCS = new InactiveRecordTypes__c(Name= 'eBusiness', Record_Type_Id__c = '012700000009YpU');
    insert inactiveCS;
    
  }
  
  static testMethod void testGetOwnerIds(){
    
    RecordType otherRT = [SELECT Id, Name FROM RecordType WHERE IsActive = true AND DeveloperName = 'Spam'];
    RecordType inquiryRT = [SELECT Id FROM RecordType WHERE DeveloperName =: OpenCaseOwnerNamesController.customerEnquiryRTDeveloperName];
    
    List<Case> cases = TestingUtils.createCases(otherRT.ID, 50);
    UnitTest.addData(cases).tag('All Cases').divide(2).part('cases with other Record Types')
                 .part('cases with customer inquiry Record Type');

    UnitTest.get('cases with customer inquiry Record Type').property('RecordTypeId').assign(inquiryRT.Id);
    
     
    
    OpenCaseOwnerNamesController testOpenCaseCtrl = new OpenCaseOwnerNamesController();
    
    Test.startTest();
      Set<Id> actualIds = testOpenCaseCtrl.openCaseOwnerIds;
    Test.stopTest();
    
    List<Case> expectedOpenCases = [Select Id, OwnerId From Case Where Id in :UnitTest.get('cases with customer inquiry Record Type').getList()];
    
    Set<Id> expectedOwnerIds = Pluck.ids('OwnerId', expectedOpenCases);
    
    System.assertEquals(expectedOwnerIds, actualIds, 'Only owner Ids of the cases with the inquiry record type should be retreived');
  
  }
  
  static testMethod void testGetValidOwnerIds(){
    
    RecordType inquiryRT = [SELECT Id FROM RecordType WHERE DeveloperName =: OpenCaseOwnerNamesController.customerEnquiryRTDeveloperName];
    
    List<User> users = TestingUtils.createUsers('testuser', 'Standard User', 50, true);
    List<Group> groups = TestingUtils.createGroups(50, 'testgroup', 'Queue', true);
    
    UnitTest.addData(users).tag('Users');
    UnitTest.addData(groups).tag('Groups');
    
    UnitTest.get('Users').tag('Valid Open Case User Owner Ids');
    UnitTest.get('Groups').tag('Valid Open Case Group Owner Ids');
    
    Set<Id> allOwnerIds = new Set<Id>();
    allOwnerIds.addAll(Pluck.ids(users));
    allOwnerIds.addAll(Pluck.ids(groups));
                    
    Set<Id> expectedUserIds = UnitTest.getIds('Valid Open Case User Owner Ids');
    Set<Id> expectedGroupIds = UnitTest.getIds('Valid Open Case Group Owner Ids');
                    
    
    OpenCaseOwnerNamesController testOpenCaseCtrl = new OpenCaseOwnerNamesController();
    testOpenCaseCtrl.openCaseOwnerIds = allOwnerIds;
    
    Test.startTest();
      Set<Id> actualGroupIds = testOpenCaseCtrl.openCaseGroupOwnerIds;
      Set<Id> actualUserIds = testOpenCaseCtrl.openCaseUserOwnerIds;
    Test.stopTest();
    
    System.assertEquals(expectedUserIds.size(), actualUserIds.size(), 'We expect the correct number of user Ids of the cases with the inquiry record type should be retreived');
    System.assertEquals(expectedGroupIds.size(), actualGroupIds.size(), 'We expect the correct number of group Ids of the cases with the inquiry record type should be retreived');
    System.assertEquals(expectedUserIds, actualUserIds, 'Only user Ids of the cases with the inquiry record type should be retreived');
    System.assertEquals(expectedGroupIds, actualGroupIds, 'Only group Ids of the cases with the inquiry record type should be retreived');
  
  }
  
  static testMethod void testNameToUrlWrapper(){
    
    Open_Case_Report_ID__c testCaseReportId = new Open_Case_Report_ID__c(Name = 'test', Report_Id__c = '00OQ0000000GcnD');
    insert testCaseReportId;
    RecordType inquiryRT = [SELECT Id FROM RecordType WHERE DeveloperName =: OpenCaseOwnerNamesController.customerEnquiryRTDeveloperName];
    
    User testUser = TestingUtils.createUsers('testuser', 'Standard User', 1, true)[0];
    Group testGroup = TestingUtils.createGroups(1, 'testgroup', 'Queue', true)[0];
    
    test.startTest();
      OpenCaseOwnerNamesController.nameToUrlWrapper testNameToUrlWrapperForUser = new OpenCaseOwnerNamesController.nameToUrlWrapper(testUser.Name, testUser.Id, 1, 0, 'In Office');
      OpenCaseOwnerNamesController.nameToUrlWrapper testNameToUrlWrapperForGroup = new OpenCaseOwnerNamesController.nameToUrlWrapper(testGroup.Name, testGroup.Id, 1, 0, 'In Office');
    test.stopTest();
    
    String expectedUserUrl = '/' + testCaseReportId.Report_Id__c + '?pv0=' + testUser.Name;
    String expectedGroupUrl = '/' + testCaseReportId.Report_Id__c + '?pv0=' + testGroup.Name;
    
    System.assertEquals(expectedUserUrl, testNameToUrlWrapperForUser.reportUrl, 
              'report url that the user needs to be redirected to should be constructed by the wrapper class');
    System.assertEquals(testUser.Id, testNameToUrlWrapperForUser.ownerId, 
              'user Id that needs to be populated on the report page should be constructed by the wrapper class');
    System.assertEquals(testUser.Name, testNameToUrlWrapperForUser.name, 
              'user name that needs to be populated on the detail page should be constructed by the wrapper class');
    System.assertEquals(expectedGroupUrl, testNameToUrlWrapperForGroup.reportUrl, 
              'report url that the group needs to be redirected to should be constructed by the wrapper class');
    System.assertEquals(testGroup.Id, testNameToUrlWrapperForGroup.ownerId, 
              'group Id that needs to be populated on the report page should be constructed by the wrapper class');
    System.assertEquals(testGroup.Name, testNameToUrlWrapperForGroup.name, 
              'group name that needs to be populated on the detail page should be constructed by the wrapper class');
  }
  
  static testMethod void testNameToUrlWrappers(){
    
    Open_Case_Report_ID__c testCaseReportId = new Open_Case_Report_ID__c(Name = 'test', Report_Id__c = '00OQ0000000GcnD');
    insert testCaseReportId;
    RecordType inquiryRT = [SELECT Id FROM RecordType WHERE DeveloperName =: OpenCaseOwnerNamesController.customerEnquiryRTDeveloperName];
    
    List<User> testUsers = TestingUtils.createUsers('testuser', 'Standard User', 20, true);
    List<Group> testGroups = TestingUtils.createGroups(20, 'testgroup', 'Queue', true);
    
    OpenCaseOwnerNamesController testController = new OpenCaseOwnerNamesController();
    
    testController.openCaseUsers = testUsers;
    testController.openCaseGroups = testGroups;
    
    test.startTest();
      List<OpenCaseOwnerNamesController.nameToUrlWrapper> actualTestUserWrapper = testController.nameToUrlWrapperForUsers;
      List<OpenCaseOwnerNamesController.nameToUrlWrapper> actualTestGroupWrapper = testController.nameToUrlWrapperForGroups;
    test.stopTest();
    
    System.assertEquals(testUsers.size(), actualTestUserWrapper.size(),
              'number of users that are wrapped must be same as the users given to the wrapper list');
    System.assertEquals(testGroups.size(), actualTestGroupWrapper.size(),
              'number of groups that are wrapped must be same as the groups given to the wrapper list');
    
    Set<Id> testUserIds = Pluck.ids(testUsers);
    Set<Id> testGroupIds = Pluck.ids(testGroups);

    for(OpenCaseOwnerNamesController.nameToUrlWrapper actUserTestWrap : actualTestUserWrapper){
      System.assert(testUserIds.contains(actUserTestWrap.ownerId),'the Ids returned by the wrapper should match the open case user OwnerIds');
    }
    
    for(OpenCaseOwnerNamesController.nameToUrlWrapper actGroupTestWrap : actualTestGroupWrapper){
      System.assert(testGroupIds.contains(actGroupTestWrap.ownerId),'the Ids returned by the wrapper should match the open case group OwnerIds');
    }
  }
  
  static testMethod void testNumberOfOpenCasesForEachUser(){
    User testUser;
    Group testGroup;
    String userWorkStatus = 'In Office';
    System.runAs(TestingUtils.ADMIN_USER){
      RecordType inquiryRT = [SELECT Id FROM RecordType WHERE DeveloperName =: OpenCaseOwnerNamesController.customerEnquiryRTDeveloperName];
      
      List<Case> cases = TestingUtils.createCases(inquiryRT.ID, 36);
      testUser = TestingUtils.createUser('userName', 'Standard User', false);
      testUser.Working_Status__c = userWorkStatus;
      insert testUser;
      
      testGroup = TestingUtils.createGroups(1, 'testgroup', 'Queue', true)[0];
      QueueSobject testQueue = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case');
      insert testQueue;
      UnitTest.addData(cases).tag('All Open Cases')
          .divide(2).part('Cases for users')
          .part('Cases for groups');
          
      UnitTest.get('Cases for users')
          .property('RecordTypeId').assign(inquiryRT.Id)
          .property('OwnerId').assign(testUser.Id)
          .divide(2).part('Critical Cases for Users')
          .part('Non Critical Cases for Users');
          
      UnitTest.get('Critical Cases for Users')
          .property('Priority')
          .assign('Critical');
      
      UnitTest.get('Cases for groups')
          .property('RecordTypeId').assign(inquiryRT.Id)
          .property('OwnerId').assign(testGroup.Id)
          .divide(2)
          .part('Critical Cases for Groups')
          .part('Non Critical Cases for Groups');
          
      UnitTest.get('Critical Cases for Groups')
          .property('Priority')
          .assign('Critical');
          
       
    }
    
    
    OpenCaseOwnerNamesController testController = new OpenCaseOwnerNamesController();
    
    testController.openCaseUsers = new List<User>{testUser};
    testController.openCaseGroups = new List<Group>{testGroup};
    
    Test.startTest();
      List<OpenCaseOwnerNamesController.nameToUrlWrapper> actualTestUserWrapper = testController.nameToUrlWrapperForUsers;
      List<OpenCaseOwnerNamesController.nameToUrlWrapper> actualTestGroupWrapper = testController.nameToUrlWrapperForGroups;
    Test.stopTest();
    
    for(OpenCaseOwnerNamesController.nameToUrlWrapper actUserTestWrap : actualTestUserWrapper){
       
       
       
      
      
  
    }
    
    for(OpenCaseOwnerNamesController.nameToUrlWrapper actGroupTestWrap : actualTestGroupWrapper){
       
     
     
     
    }
  }
}