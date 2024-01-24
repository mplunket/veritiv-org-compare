@isTest
private class TestCarouselController {

    private static testMethod void testConstructor_noMessages(){

        List<CarouselController.AnnouncementModel> actualAnnouncements;

        Test.startTest();

            CarouselController controller = new CarouselController();
            actualAnnouncements = controller.announcements;

        Test.stopTest();

        System.assertEquals( 1, actualAnnouncements.size(), 'There should be only one annoucement in the list' );
        System.assertEquals( Label.Carousel_no_messages, actualAnnouncements[0].content, 'The announcement should be the no announcements label' );
    }
    private static testMethod void testConstructor_ExistingAnnoucement_SalesUser()
    {
        final Date TODAY = Date.today();
        final Date PAST = Date.today()-4;
        final Date FUTURE = Date.today()+4;
        
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', true );
        String salesUserType = [Select Id, User_Type__c From User Where ID=:testingUser.ID].User_Type__c;
        String marketingUserType = salesUserType + 'M';
        UnitTest.addData(TestingUtils.createCarouselAnnouncements(300,false)).tag('Announcements').divide(7)
                .part('Active Sales Announcements').part('Active Sales and Marketing Announcements')
                .part('Active Marketing Announcements').part('Inactive Sales Announcements')
                .part('Inactive Marketing Announcements').part('Inactive Uncategorized Announcements')
                .part('Active Uncategorized Announcements');
                
        UnitTest.get('Active Sales Announcements').assign('Active__c',true).assign('User_Type_Visibility__c',salesUserType).assign('Country__c',testingUser.Country);
        UnitTest.get('Active Sales and Marketing Announcements').assign('Active__c',true).assign('User_Type_Visibility__c',salesUserType+';'+marketingUserType).assign('Country__c',testingUser.Country);       
        UnitTest.get('Active Marketing Announcements').assign('Active__c',true).assign('User_Type_Visibility__c',marketingUserType).assign('Country__c',testingUser.Country);       
        UnitTest.get('Inactive Sales Announcements').assign('Active__c',false).assign('User_Type_Visibility__c',salesUserType).assign('Country__c',testingUser.Country);
        UnitTest.get('Inactive Marketing Announcements').assign('Active__c',false).assign('User_Type_Visibility__c',marketingUserType).assign('Country__c',testingUser.Country);        
        UnitTest.get('Inactive Uncategorized Announcements').assign('Active__c',false).assign('Country__c',testingUser.Country);        
        UnitTest.get('Active Uncategorized Announcements').assign('Active__c',true).assign('Country__c',testingUser.Country);
        
        UnitTest.get('Active Sales Announcements').divide(2).part('Upcoming Announcements')
                                                            .part('Present Announcements');
        UnitTest.get('Active Sales and Marketing Announcements').divide(2).part('Upcoming Announcements')
                                                            .part('Present Announcements');
        UnitTest.get('Active Marketing Announcements').divide(2).part('Upcoming Announcements')
                                                            .part('Present Announcements');                                                 
        UnitTest.get('Inactive Sales Announcements').divide(2).part('Upcoming Announcements')
                                                            .part('Present Announcements');                                                                                                         
        UnitTest.get('Upcoming Announcements').divide(2).part('Announcements With Future End Date, Future Start Date')
                                                        .part('Announcements With No End Date, Future Start Date'); 
        UnitTest.get('Present Announcements').divide(9).part('Announcements With Future End Date, Start Date Today')
                                                        .part('Announcements With Future End Date, Past Start Date')
                                                        .part('Announcements With Future End Date, No Start Date')
                                                        .part('Announcements With End Date Today, Start Date Today')
                                                        .part('Announcements With End Date Today, Past Start Date')
                                                        .part('Announcements With End Date Today, No Start Date')
                                                        .part('Announcements With No End Date, Start Date Today')   
                                                        .part('Announcements With No End Date, Past Start Date')    
                                                        .part('Announcements With No End Date, No Start Date');
                                                                                                                                                                                                                                                                                                                                           
        UnitTest.get('Announcements With Future End Date, Future Start Date').assign('End_Date__c',FUTURE).assign('Start_Date__c',FUTURE);                                                                                              
        UnitTest.get('Announcements With No End Date, Future Start Date').assign('End_Date__c',null).assign('Start_Date__c',FUTURE);                                                                
        UnitTest.get('Announcements With Future End Date, Start Date Today').assign('End_Date__c',FUTURE).assign('Start_Date__c',TODAY);
        UnitTest.get('Announcements With Future End Date, Past Start Date').assign('End_Date__c',FUTURE).assign('Start_Date__c',PAST);
        UnitTest.get('Announcements With Future End Date, No Start Date').assign('End_Date__c',FUTURE).assign('Start_Date__c',null);
        UnitTest.get('Announcements With End Date Today, Start Date Today').assign('End_Date__c',TODAY).assign('Start_Date__c',TODAY);
        UnitTest.get('Announcements With End Date Today, Past Start Date').assign('End_Date__c',TODAY).assign('Start_Date__c',PAST);
        UnitTest.get('Announcements With End Date Today, No Start Date').assign('End_Date__c',TODAY).assign('Start_Date__c',null);
        UnitTest.get('Announcements With No End Date, Start Date Today').assign('End_Date__c',null).assign('Start_Date__c',TODAY);  
        UnitTest.get('Announcements With No End Date, Past Start Date').assign('End_Date__c',null).assign('Start_Date__c',PAST);    
        UnitTest.get('Announcements With No End Date, No Start Date').assign('End_Date__c',null).assign('Start_Date__c',null);
        
        UnitTest.get('Announcements').insertAll();
        
        UnitTest.get('Active Sales Announcements').filter('Present Announcements').tag('Expected Announcements For Sales User');
        UnitTest.get('Active Sales and Marketing Announcements').filter('Present Announcements').tag('Expected Announcements For Sales User');
        
        
        Map<String, String> expectedMapURLToHTML = new Map<String, String>();
        for(Announcement__c a : (List<Announcement__c>) UnitTest.get('Expected Announcements For Sales User').getList())
        {
            expectedMapURLToHTML.put(a.URL_Link__c,a.Announcement_HTML__c);
        }
        
        CarouselController controller;
        
        System.runAs(testingUser)
        {
            Test.startTest();
                controller = new CarouselController();
            Test.stopTest();
        }
        
        Map<String, String> actualMapURLToHTML = new Map<String, String>();
        for(CarouselController.AnnouncementModel a : controller.announcements)
        {
            actualMapURLToHTML.put(a.url,a.content);
        }
        String t = '\nExpected size ' + expectedMapURLToHTML.size() + 'vs ' + actualMapURLToHTML.size();
        System.assertEquals(expectedMapURLToHTML,actualMapURLToHTML,'We expect to get back only those announcements which are active and include the user\'s type. We must correctly get back the content and url of those announcements'+t);
    }
    
    static testMethod void test_CarouselControllerConstructor_DifferentCountries(){
        final Date PAST = Date.today().addDays(-4);
        final Date FUTURE = Date.today().addDays(4);
        final String expectedUSAContent = 'USA Content';
        final String expectedUSALink = 'usa@test.com';
        final String expectedCANContent = 'USA Content';
        final String expectedCANLink = 'usa@test.com';
        
        // Create Users
        List<User> testingUsers = TestingUtils.createUsers('RunningUser','Standard User', 2,false);
        testingUsers[0].Country = 'USA';
        testingUsers[1].Country = 'CAN';
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUsers;
        }
        
        String user_type = [SELECT Id, User_Type__c FROM User WHERE Id IN: testingUsers Limit 1].User_Type__c;
        // Create Announcements
        UnitTest.addData(TestingUtils.createCarouselAnnouncements(100,false)).tag('Announcements').divide(2).part('Announcements_Country_USA')
                                                                                                            .part('Announcements_Country_CAN');
        
        UnitTest.get('Announcements_Country_USA').assign('User_Type_Visibility__c',user_type)
                                                 .assign('Active__c',true)
                                                 .assign('Start_Date__c',PAST)
                                                 .assign('End_Date__c',FUTURE)
                                                 .assign('Country__c','USA')
                                                 .assign('Announcement_HTML__c',expectedUSAContent)
                                                 .assign('URL_Link__c',expectedUSALink);
        
        UnitTest.get('Announcements_Country_CAN').assign('User_Type_Visibility__c',user_type)
                                                 .assign('Active__c',true)
                                                 .assign('Start_Date__c',PAST)
                                                 .assign('End_Date__c',FUTURE)
                                                 .assign('Country__c','CAN')
                                                 .assign('Announcement_HTML__c',expectedCANContent)
                                                 .assign('URL_Link__c',expectedCANLink);
        
        UnitTest.get('Announcements').insertAll();
        
        CarouselController controller;
        
        Test.startTest();
            // Running as User with Coutnry USA
            System.runAs(testingUsers[0]){
                controller = new CarouselController();
            }
            System.assertEquals(UnitTest.get('Announcements_Country_USA').getList().size(),controller.announcements.size(),
                                'Incorrect number of announcements shown on home page of user with Country USA');
            
            for(CarouselController.AnnouncementModel eachAnnouncement : controller.announcements){
                System.assertEquals(expectedUSAContent, eachAnnouncement.content,
                                'Incorrect Content Populated in the announcement for user with country USA');
                System.assertEquals(expectedUSALink, eachAnnouncement.url,
                                'Incorrect URL Populated in the announcement for user with country USA');
            }
            
            // Running as User with Country CAN
            System.runAs(testingUsers[1]){
                controller = new CarouselController();
            }
            System.assertEquals(UnitTest.get('Announcements_Country_CAN').getList().size(),controller.announcements.size(),
                                'Incorrect number of announcements shown on home page of user with Country CAN');
            
            for(CarouselController.AnnouncementModel eachAnnouncement : controller.announcements){
                System.assertEquals(expectedCANContent, eachAnnouncement.content,
                                'Incorrect Content Populated in the announcement for user with country CAN');
                System.assertEquals(expectedCANLink, eachAnnouncement.url,
                                'Incorrect URL Populated in the announcement for user with country CAN');
            }
        Test.stopTest();
        
    }
    
}