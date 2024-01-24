global class AIQApproveRejectLineResponse {
    @InvocableVariable
    global String lineId;
    @InvocableVariable
	global String message;
    @InvocableVariable
	global String responseCode;
	
	public AIQApproveRejectLineResponse(String lineId, String responseCode, String message) {
        this.lineId = lineId;
		this.message = message;
		this.responseCode = responseCode;
	}
	
    public String getLineId() {
		return lineId;
	}
    
	public String getMessage() {
		return message;
	}
	
	public String getResponseCode() {
		return responseCode;
	}
}