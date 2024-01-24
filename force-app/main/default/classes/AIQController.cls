global class AIQController {

    @TestVisible
    private static AIQServiceInterface service;

    /*
    public static void setService(IAIQService aService)
    {
        service = aService;
    }
	*/
    
    global static AIQServiceInterface getAIQService()
    {
        if(service == null)
        {
            service = new AIQService();
        }
        
        return service;
    }
    
    
}