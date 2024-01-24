global class AIQAgrLineRejection {
    
    @InvocableMethod(label='RejectAgreementLine')
    global static List<AIQApproveRejectLineResponse> rejectAgrLine(List<Id> agrLineIds)
    {
        AIQServiceInterface intf = new AIQService();        
        return intf.rejectAgrLine(agrLineIds);
    }
}