global class AIQAddLineResponse {
	private String message;
	private Integer responseCode;
	
	public AIQAddLineResponse(Integer responseCode, String message) {
		this.message = message;
		this.responseCode = responseCode;
	}
	
	public String getMessage() {
		return message;
	}
	
	public Integer getResponseCode() {
		return responseCode;
	}
    
}