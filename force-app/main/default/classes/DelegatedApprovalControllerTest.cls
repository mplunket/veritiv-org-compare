/***
 * Created by Eduardo Carvalho on 2019-11-15.
 */
@isTest
public class DelegatedApprovalControllerTest {
    
    static testMethod void fetchUserTest(){   
        
		UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
			.tag('User');
		insert UnitTest.get('User').getList();        
		User user = (User) UnitTest.get('User').getList()[0];
        
        User userInserted = [Select id from User where Id = :user.Id];
        User userResult = DelegatedApprovalController.fetchUser(String.valueOf(user.id)); 
        System.assertEquals(userInserted.id, userResult.id); //return same user
    }
}