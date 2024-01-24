public with sharing class CarouselController {

    public List<AnnouncementModel> announcements { get; private set; }
    private static final String COUNTRY_OPTION_ALL = 'All';
    private String ANNOUNCEMENT_CALENDAR_DEV_NAME = 'Home_Carousel_Calendar';
    private List<String> allowedAnnouncementRecordTypes { get; private set; }
    /*
        Constructor
    */
    public CarouselController(){
        allowedAnnouncementRecordTypes = new List<String>{
            ANNOUNCEMENT_CALENDAR_DEV_NAME,
            'Home_Carousel_Announcement'
        };
        announcements =  new List<AnnouncementModel>();
        
        for ( Announcement__c announcement : [SELECT Announcement_HTML__c, URL_Link__c, RecordTypeId, RecordType.DeveloperName
                                                    FROM Announcement__c
                                                    WHERE Active__c = true
                                                    AND User_Type_Visibility__c includes (:runningUser.User_Type__c)
                                                    AND (Start_Date__c = null OR Start_Date__c <= TODAY)
                                                    AND (End_Date__c = null OR End_Date__c >= TODAY)
                                                    AND RecordTypeId in :allowedCarouselRecordTypeIds.keySet()
                                                    AND (Country__c =: runningUser.Country OR Country__c =: COUNTRY_OPTION_ALL)
                                                    ORDER BY Order__c,CreatedDate ASC] ){
            AnnouncementModel am = new AnnouncementModel( announcement.Announcement_HTML__c, announcement.URL_Link__c );
            if (announcement.RecordType.DeveloperName == ANNOUNCEMENT_CALENDAR_DEV_NAME){
                am.showCalendar = true;
            }
            announcements.add( am );
        }

        if ( announcements.isEmpty() ){
            announcements.add( new AnnouncementModel( Label.Carousel_no_messages, null ) );
        }
    }
    
    private User runningUser{
        get{
            if(runningUser == null)
              runningUser = [Select Id, User_Type__c, Country From User Where ID=:UserInfo.getUserID()];
            return runningUser;
        }set;
    }
    
    private Id CalendarAnnouncementRecordTypeId {
        get {
            if (CalendarAnnouncementRecordTypeId == null){
                for (RecordType rt : allowedCarouselRecordTypeIds.values()){
                    if (rt.DeveloperName == ANNOUNCEMENT_CALENDAR_DEV_NAME){
                        CalendarAnnouncementRecordTypeId = rt.Id; 
                        break;
                    }
                } 
            }
            return CalendarAnnouncementRecordTypeId;
        }
        set;
    }
    
    private Map<Id, RecordType> allowedCarouselRecordTypeIds{
        
        get {
            if (allowedCarouselRecordTypeIds == null){
                allowedCarouselRecordTypeIds = new Map<Id, RecordType>([Select Id, DeveloperName From RecordType Where SObjectType = 'Announcement__c' And DeveloperName in :allowedAnnouncementRecordTypes]);
            }
            return allowedCarouselRecordTypeIds;
        }
        set;
    }
    
    public class AnnouncementModel {

        public String content { get; set; }
        public String url     { get; set; }
        public Boolean showCalendar { get; set; }
      
        public AnnouncementModel( String content, String url ){
            this.content = content;//.replace('&', '&amp;');
            this.url = url;
            this.showCalendar = false;
        }
    }
}