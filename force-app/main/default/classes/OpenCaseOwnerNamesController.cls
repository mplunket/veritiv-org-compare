public with sharing class OpenCaseOwnerNamesController {
    
    @testVisible
    private static String customerEnquiryRTDeveloperName = 'X30_ULS_Customer_Inquiry';
    private static String userKeyPrefix = User.SObjectType.getDescribe().getKeyPrefix();
    private static String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();
    
    static RecordType customerEnquiryRT {
        get {
            if (customerEnquiryRT == null){
                customerEnquiryRT = [Select Id From RecordType Where DeveloperName = :customerEnquiryRTDeveloperName AND SObjectType = 'Case' Limit 1];
            }
            return customerEnquiryRT;
        }
        set;
    }
    
    public Set<Id> openCaseOwnerIds {
        get{
            if (openCaseOwnerIds == null){
                List<Case> openCustomerEnquiryCases = getOpenCases(customerEnquiryRT.Id);
                openCaseOwnerIds = Pluck.ids('OwnerId', openCustomerEnquiryCases);
            }
            return openCaseOwnerIds;
        } 
        set;
    }
    
    public AggregateResult[] openCaseAggregate{
        get{
            AggregateResult[] openCaseAggregate = [Select OwnerId , COUNT(id) From Case Where RecordTypeId =: customerEnquiryRT.Id AND IsClosed = false GROUP BY OwnerId];
            return openCaseAggregate;
        }
        set;
    }
    
    public AggregateResult[] openCriticalCaseAggregate{
        get{
            AggregateResult[] openCriticalCaseAggregate = [Select OwnerId , COUNT(id) From Case Where RecordTypeId = :customerEnquiryRT.Id AND IsClosed = false AND Priority = 'Critical' GROUP BY OwnerId];
            return openCriticalCaseAggregate;
        }
        set;
    }
    
    static List<Case> getOpenCases(Id openRTId){
        return [Select Id, OwnerId From Case Where RecordTypeId =: customerEnquiryRT.Id AND IsClosed = false];
    }
    
    public Map<Id, Integer> openCaseOwnerIdToOpenCaseListSize{
        get{
            Map<Id, Integer> openCaseOwnerIdToOpenCaseListSize = new Map<Id, Integer>();
            for(AggregateResult openCaseAgg : openCaseAggregate){
                openCaseOwnerIdToOpenCaseListSize.put((ID) openCaseAgg.get('OwnerId'), (Integer) openCaseAgg.get('expr0'));
            }
            return openCaseOwnerIdToOpenCaseListSize;
        }
        set;        
    }
    
    public Map<Id, Integer> openCriticalCaseOwnerIdToOpenCaseListSize{
        get{
            Map<Id, Integer> openCriticalCaseOwnerIdToOpenCaseListSize = new Map<Id, Integer>();
            for(AggregateResult openCaseAgg : openCriticalCaseAggregate){
                openCriticalCaseOwnerIdToOpenCaseListSize.put((ID) openCaseAgg.get('OwnerId'), (Integer) openCaseAgg.get('expr0'));
            }
            return openCriticalCaseOwnerIdToOpenCaseListSize;
        }
        set;        
    }
    
    private void filterOpenCaseOwners(){
        openCaseGroupOwnerIds = new Set<Id>();
        openCaseUserOwnerIds = new Set<Id>();
        for (String ownerId : openCaseOwnerIds){
            if (ownerId.startsWith(groupKeyPrefix)){
                openCaseGroupOwnerIds.add(ownerId);
            }
            else if (ownerId.startsWith(userKeyPrefix)){
                openCaseUserOwnerIds.add(ownerId);
            }
        }
    }
    
    public Set<Id> openCaseGroupOwnerIds {
        get{
            if (openCaseGroupOwnerIds == null){
                filterOpenCaseOwners();
            }
            return openCaseGroupOwnerIds;
        } 
        set;
    }
    
    public Set<Id> openCaseUserOwnerIds {
        get{
            if (openCaseUserOwnerIds == null){
                filterOpenCaseOwners();
            }
            return openCaseUserOwnerIds;
        } 
        set;
    }
    
    public List<User> openCaseUsers{
        get{
            if (openCaseUsers == null){
                openCaseUsers = [SELECT Id ,Name, Working_Status__c FROM User WHERE Id IN: openCaseUserOwnerIds];
            }
            openCaseUsers.sort();
            return openCaseUsers;
        }
        set;
    }
    
    public List<nameToUrlWrapper> nameToUrlWrapperForUsers{
        get{
            if (nameToUrlWrapperForUsers == null){
                nameToUrlWrapperForUsers = new List<nameToUrlWrapper>();
                for(User ocs : openCaseUsers){
                    nameToUrlWrapperForUsers.add(new nameToUrlWrapper(ocs.Name, 
                                                                      ocs.Id, 
                                                                      openCaseOwnerIdToOpenCaseListSize.get(ocs.Id),
                                                                      openCriticalCaseOwnerIdToOpenCaseListSize.get(ocs.Id),
                                                                      ocs.Working_Status__c));
                }
            }
            return nameToUrlWrapperForUsers;
        }
        set;
    } 
    
    public List<Group> openCaseGroups{
        get{
            if (openCaseGroups == null){
                openCaseGroups = [SELECT Id ,Name FROM Group WHERE Id IN: openCaseGroupOwnerIds];
            }
            openCaseGroups.sort();
            return openCaseGroups;
        }
        set;
    }
    
    public List<nameToUrlWrapper> nameToUrlWrapperForGroups{
        get{
            if (nameToUrlWrapperForGroups == null){
                nameToUrlWrapperForGroups = new List<nameToUrlWrapper>();
                for(Group ocg : openCaseGroups){
                    nameToUrlWrapperForGroups.add(new nameToUrlWrapper(ocg.Name, 
                                                                       ocg.Id, 
                                                                       openCaseOwnerIdToOpenCaseListSize.get(ocg.Id),
                                                                       openCriticalCaseOwnerIdToOpenCaseListSize.get(ocg.Id),
                                                                       null));
                }
            }
            return nameToUrlWrapperForGroups;
        }
        set;
    }
    
    public class nameToUrlWrapper{
        public String name {get; set;}
        public Id ownerId{get; set;}
        public Integer numberOfOpenCases{
            get{
            if(numberOfOpenCases == null){
                numberOfOpenCases = 0;
            }
            return numberOfOpenCases;
         }
         set;
        }
        
        public Integer numberOfCriticalOpenCases{
            get{
            if(numberOfCriticalOpenCases == null){
                numberOfCriticalOpenCases = 0;
            }
            return numberOfCriticalOpenCases;
         }
         set;
        }
        
        public String workingStatus{get; set;}
        
        public String reportUrl{
            get{
                Open_Case_Report_ID__c cs = Open_Case_Report_ID__c.getOrgDefaults();
                if (cs != null){
                    reportUrl = '/' + cs.Report_Id__c + '?pv0=' + name;
                }
                return reportUrl;
            }
            set;
        }
        
        public nameToUrlWrapper(String name, Id ownerId, Integer openCaseSize, Integer openCriticalCaseSize, String workStatus){
            this.name = name;
            this.ownerId = ownerId;
            this.numberOfOpenCases = openCaseSize;
            this.numberOfCriticalOpenCases = openCriticalCaseSize;
            this.workingStatus = workStatus;
        }
    }
}