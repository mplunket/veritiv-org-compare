global class AIQPriceRecommendation {
    private Decimal startMarkup;
    private Decimal targetMarkup;
    private Decimal floorMarkup;    
    private String recommendationId;
    private String status; // added to facilitate troubleshooting
    public AIQPriceRecommendation(String recommendationId, Decimal startMarkup, Decimal targetMarkup, Decimal floorMarkup, String status ) {
        this.recommendationId = recommendationId;
        this.startMarkup = startMarkup;
        this.targetMarkup = targetMarkup;
        this.floorMarkup = floorMarkup;
        this.status = status;
    }
    
    public Decimal getStartMarkup() {
        return startMarkup;
    }
        
    public Decimal getTargetMarkup() {
        return targetMarkup;
    }
    
    public Decimal getFloorMarkup() {
        return floorMarkup;
    }
        
    public String getRecommendationId() {
        return recommendationId;
    }
    
    public String getStatus() {
        return status;
    }
    
        
}