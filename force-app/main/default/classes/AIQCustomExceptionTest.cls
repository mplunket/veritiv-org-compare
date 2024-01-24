@isTest
public class AIQCustomExceptionTest {
	@isTest
    public static void testAIQCustomException(){
        AIQCustomException ex = new AIQCustomException();
        ex.setMessage('testing error message');
    }
}