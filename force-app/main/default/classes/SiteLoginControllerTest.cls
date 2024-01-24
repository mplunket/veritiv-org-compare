@isTest
global class SiteLoginControllerTest {

    @IsTest(SeeAllData=true) global static void SiteLoginControllerTest () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }
}