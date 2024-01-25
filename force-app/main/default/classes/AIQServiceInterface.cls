global interface AIQServiceInterface {
	AIQAddLineResponse addAgreementLine(
		String customerId,
		String level,
		String vendorId,
		String divisionId, 
		String systemId, 
		String segmentId,
		String classId,
		String brandId,
		String setId,
		String subsetId,
		String productCode,
		String policyType,
		Decimal policyValue,
		String priceUnit,
		Date effectiveDate
		);
    
    AIQPriceRecommendation getRecommendationForProspect (
        String distributionChannel,
        String systemId,
        String primaryDivision,
        String division,
        String customerSpend,
        String averageOrderSize,
        String naics,
        String productCode,
        Decimal lineSizePR,
		String qtyUom);
    
    List<AIQApproveRejectLineResponse> approveAgrLine(Id agrLineId);
    List<AIQApproveRejectLineResponse> approveAgrLine(List<Id> agrLineIds);
    List<AIQApproveRejectLineResponse> rejectAgrLine(Id agrLineId);
    List<AIQApproveRejectLineResponse> rejectAgrLine(List<Id> agrLineIds);
    
    
}