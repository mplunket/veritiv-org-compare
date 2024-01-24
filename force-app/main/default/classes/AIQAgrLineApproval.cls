global class AIQAgrLineApproval {
    
    @InvocableMethod(label='ApproveAgreementLine')
    global static List<AIQApproveRejectLineResponse> approveAgrLine(List<Id> agrLineIds)
    {       
        AIQServiceInterface intf = new AIQService();
		//system.debug(intf.approveAgrLine(agrLineIds));        
        return intf.approveAgrLine(agrLineIds);
    }
}