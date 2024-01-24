public class PipelineReviewsComponentController {

    @AuraEnabled
    public static Primary_Sales_Rep__c getCurrentPSR() {
        List<Primary_Sales_Rep__c> psrs = [SELECT Id, Name
                FROM Primary_Sales_Rep__c 
                WHERE SF_UserId__c = :UserInfo.getUserId()];
                
        if (psrs.size() > 0) {
            return psrs[0];
        }

        return null;
    }

    @AuraEnabled
    public static List<Primary_Sales_Rep__c> getDirectReportsAndMostRecentPipelineReviews() {
        List<Primary_Sales_Rep__c> directReports = 
            [SELECT Id, Name, (SELECT Id, Name FROM Pipeline_Reviews__r ORDER BY CreatedDate DESC LIMIT 1)
             FROM Primary_Sales_Rep__c 
             WHERE SF_userid__r.ManagerId = :UserInfo.getUserId() AND SF_userid__r.IsActive = true
             ORDER BY Name];

        return directReports;
    }

    @AuraEnabled 
    public static List<Pipeline_Review__c> getMyPipelineReviews() {
        List<Pipeline_Review__c> myPipelineReviews = 
            [SELECT Id, Name, Primary_Sales_Rep__r.Name, Primary_Sales_Rep__r.Id, Month_Reviewed__c, Year__c, CreatedDate
             FROM Pipeline_Review__c
             WHERE Primary_Sales_Rep__r.SF_UserId__c = :UserInfo.getUserId()
             ORDER BY CreatedDate DESC];
        return myPipelineReviews;
    }
}