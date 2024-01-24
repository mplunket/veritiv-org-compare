public with sharing class UserService {

  public static final String STANDARD_USER_TYPE = 'Standard';
  public static final String REPORTING_HIERARCHY_FIELDSET = 'Reporting_Hierarchy';
  public static Boolean skipSyncingPSRsToUserNetwork = false;
  
  public class NoUserFieldSetDefinedException extends Exception {}
  
  public static List<User> managersTriggerNew; 
  public static Map<Id, User> oldUserMapTriggerOldMap;
  
  public static Boolean forceUserUpdate = false;
  
  public static void updateOutOfOfficeShadowStatus( List<User> users, Map<Id, User> oldUsersMap ) {

    Set<Id> changedStatusUserIds = new Set<Id>();

    for ( User user : users ) {

      String oldStatus = oldUsersMap.get( user.Id ).Working_Status__c;

      if ( user.Working_Status__c != oldStatus && user.IsActive )

        changedStatusUserIds.add( user.Id );
    }

    if ( !changedStatusUserIds.isEmpty() ) {

      futureUpdateFuture( changedStatusUserIds );

    }
  }
  
  public static List<String> reportingHierarchyFields {
    get {
      if (reportingHierarchyFields == null){
        reportingHierarchyFields = new List<String>();
        Schema.FieldSet fs1 = Schema.SObjectType.User.FieldSets.getMap().get(REPORTING_HIERARCHY_FIELDSET);
        if (fs1 != null){
          for (Schema.FieldSetMember fm : fs1.getFields()){
            reportingHierarchyFields.add(fm.getFieldPath());
          }
        } else {
          throw new NoUserFieldSetDefinedException('No User Field Set named ' + REPORTING_HIERARCHY_FIELDSET);
        }
      }
      return reportingHierarchyFields;
    }
    set;
        
    }
    
    public static List<User> filterUsersWithManagerChange(List<User> users, Map<Id, User> oldUserMap){
      
      List<User> changedManagers = new List<User>();
      
      for(User user : users)
      {
        // either manager changed or inherit reporting changed to true
        if( (oldUsermap != null && oldUsermap.containsKey(user.ID) && 
            (oldUsermap.get(user.Id).ManagerId != user.ManagerId || 
            oldUsermap.get(user.Id).Inherit_Reporting_Hierarch__c == false) && 
          user.Inherit_Reporting_Hierarch__c == true) || forceUserUpdate )
        {
          changedManagers.add(user);
        } 
        else if (oldUserMap == null && user.ManagerId != null && 
          user.Inherit_Reporting_Hierarch__c == true)
      {
          changedManagers.add(user);
        }
      }
      return changedManagers;
    } 
    
    
    public static Map<Id, Map<String, Object>> getManagerReportingHierarchyFields(List<User> users){
      
      Map<Id, Map<String, Object>> changedUserMap = new Map<Id, Map<String, String>>();
      
      Set<Id> userManagers = Pluck.ids('ManagerId', users);
      String managerQuery = 'Select Id, ' + String.join(reportingHierarchyFields, ',') + ' From User Where Id in :userManagers';
      List<User> managers = Database.query(managerQuery);
      
      for(User manager : managers)
      {
        Map<String, Object> changedFieldsMap = new Map<String, String>();
        for(String field : reportingHierarchyFields)
      {
        changedFieldsMap.put(field, manager.get(field));
      }
        if(!changedFieldsMap.isEmpty())  
        {
          changedUserMap.put(manager.Id, changedFieldsMap);
        }
      }
      
      return changedUserMap;
    } 
    
    public static List<User> syncFieldUpdatesFromManagers(List<User> users, Map<Id, Map<String, Object>> managerFieldMap){
      
      List<User> usersToUpdate = new List<User>();
      for (User usr : users){
        if (managerFieldMap.containsKey(usr.ManagerId)){
          Map<String, Object> managerFields = managerFieldMap.get(usr.ManagerId);
        for (String field : managerFields.keySet()){
          usr.put(field, managerFields.get(field));
        }
        usersToUpdate.add(usr);
        }
      }
      return usersToUpdate;
    }
    
    
    public static void processUserManagerChanges(List<User> users, Map<Id, User> oldUserMap){
      
      List<User> usersWithManagerChange = filterUsersWithManagerChange(users, oldUserMap);
      if (!usersWithManagerChange.isEmpty()){
        Map<Id, Map<String, Object>> managerFields = getManagerReportingHierarchyFields(usersWithManagerChange);
        List<User> updatedUsers = syncFieldUpdatesFromManagers(usersWithManagerChange, managerFields);
      }
    }
  
  @future ( callout=false )
  public static void futureUpdateFuture( Set<Id> userIds ) {

    //delete old user out of office records
    List<User_out_of_office__c> oldShadowStatuses = findOldShadowStatuses( userIds );
    delete oldShadowStatuses;

    //insert new out of office records
    List<User_out_of_office__c> newShadowStatues = generateNewShadowStatuses( userIds );
    insert newShadowStatues;

    //done-zo

  }

  private static List<User_out_of_office__c> findOldShadowStatuses( Set<Id> userIds ) {

    return [ SELECT Id FROM User_out_of_office__c WHERE User__c IN :userIds ];

  }

  private static List<User_out_of_office__c> generateNewShadowStatuses( Set<Id> userIds ) {

    List<User_out_of_office__c> shadowStatuses = new List<User_out_of_office__c>();

    for ( Id userId : userIds ) {

      User_out_of_office__c outOfOfficeStatus = new User_out_of_office__c( User__c = userId, OwnerId = userId );

      shadowStatuses.add( outOfOfficeStatus );

    }

    return shadowStatuses;

  }
    
    /**
    Call from UserManagerUpdateBatch
  */
    @future(callout=false)
    public static void updateRelatedPSRsFuture( Set<Id> userIds )
    {
        updateRelatedPSRs(userIds);
    }
    
  /**
    Update PSRs related to userIds with email and name info
  */
  
  /** Sujitha - In below function, changed the code in best practice to prevent from governer limit exception **/
  public static void updateRelatedPSRs( Set<Id> userIds )
  { 
    List<Primary_Sales_Rep__c> psrsToUpdate = [ SELECT Id, SF_userid__c
                          FROM Primary_Sales_Rep__c
                          WHERE SF_userid__c IN :userIds ];

    Set<String> sfUserIdSet = new Set<String>();
    Map<String,Primary_Sales_Rep__c> mapStringPrimarySalesRep = new Map<String,Primary_Sales_Rep__c>();

    if(!psrsToUpdate.isEmpty())
    {
        // Commented the code to to fix Null object reference so its not checking the if user is Active.
     /* Map<Id, User> users = new Map<Id, User>([SELECT Id, BDM_RVP_Email__c, Dir_Email__c, Email_DMD__c, GSM_Email__c,
                            Pres_Email__c, TL_Email__c, Vice_President_Email__c,
                            ZM_SM_Email__c, name_bdm_rvp__c, name_dir__c, name_dmd__c,
                            name_gsm__c, name_pres__c, name_team_lead__c, name_vp__c,
                            name_zm_sm__c, City, State, Country, Title,
                            Phone, IsActive, Department, Name, Email,ManagerId, Manager.Name,Manager.Network_Id__c
                            FROM User
                            WHERE Id IN :userIds and IsActive = true]);*/


              Map<Id, User> users = new Map<Id, User>([SELECT Id, BDM_RVP_Email__c, Dir_Email__c, Email_DMD__c, GSM_Email__c,
                            Pres_Email__c, TL_Email__c, Vice_President_Email__c,
                            ZM_SM_Email__c, name_bdm_rvp__c, name_dir__c, name_dmd__c,
                            name_gsm__c, name_pres__c, name_team_lead__c, name_vp__c,
                            name_zm_sm__c, City, State, Country, Title,
                            Phone, IsActive, Department, Name, Email,ManagerId, Manager.Name,Manager.Network_Id__c
                            FROM User
                            WHERE Id IN :userIds ]);
        


      for(Primary_Sales_Rep__c psr : psrsToUpdate )
      {
        User user = users.get( psr.SF_userid__c );
        copyUserEmailFieldsToPSR( psr, user );
        copyUserNameFieldsToPSR(  psr, user );
        copyUserOtherFieldsToPSR( psr, user );


         sfUserIdSet.add(user.Manager.Name);
      }


      if(sfUserIdSet!=null && sfUserIdSet.size()>0)
            {
          for(Primary_Sales_Rep__c primarySalesRepRecd : [Select Id,Name from Primary_Sales_Rep__c where Name IN : sfUserIdSet])
            {
                mapStringPrimarySalesRep.put(primarySalesRepRecd.Name,primarySalesRepRecd);

            }
          }


          for(Primary_Sales_Rep__c psr : psrsToUpdate)
           {
            
               if(users!=null && users.containsKey(psr.SF_userid__c) && users.get(psr.SF_userid__c) != null && mapStringPrimarySalesRep!=null && mapStringPrimarySalesRep.containsKey(users.get(psr.SF_userid__c).Manager.Name))
                    {
                        
                        Primary_Sales_Rep__c primarySalesRepRecord =  mapStringPrimarySalesRep.get(users.get(psr.SF_userid__c).Manager.Name);
                        psr.Reports_To__c = primarySalesRepRecord.id;

                    }


                if(users!=null && users.containsKey(psr.SF_userid__c) && users.get(psr.SF_userid__c) != null) 
                       psr.Reports_To_Network_ID_Text__c = users.get(psr.SF_userid__c).Manager.Network_Id__c;
        }






       // copyUserManagertoPSR( psr, user);
      }


      try
      {
        update psrsToUpdate;
      }
      catch(System.DMLException ex)
      {
        System.debug('#DEBUGGGGG!!!!! ' + ex );
        //rethrow exception to notify admin of error in future method
        //System.assert(false, 'OHH IT FAILED :' + ex);
        throw ex;
      }
    }
  

  public static Boolean userEmailsNamesHaveChanged(User oldUser, User newUser)
  {
    if(oldUser.name_bdm_rvp__c != newUser.name_bdm_rvp__c
      || oldUser.name_dir__c != newUser.name_dir__c
      || oldUser.name_dmd__c != newUser.name_dmd__c
      || oldUser.name_gsm__c != newUser.name_gsm__c
      || oldUser.name_pres__c != newUser.name_pres__c
      || oldUser.name_team_lead__c != newUser.name_team_lead__c
      || oldUser.name_vp__c != newUser.name_vp__c
      || oldUser.name_zm_sm__c != newUser.name_zm_sm__c
      || oldUser.BDM_RVP_Email__c != newUser.BDM_RVP_Email__c
      || oldUser.Dir_Email__c != newUser.Dir_Email__c
      || oldUser.Email_DMD__c != newUser.Email_DMD__c
      || oldUser.GSM_Email__c != newUser.GSM_Email__c
      || oldUser.Pres_Email__c != newUser.Pres_Email__c
      || oldUser.TL_Email__c != newUser.TL_Email__c
      || oldUser.Vice_President_Email__c != newUser.Vice_President_Email__c
      || oldUser.ZM_SM_Email__c != newUser.ZM_SM_Email__c
      || oldUser.FirstName != newUser.FirstName
      || oldUser.LastName != newUser.LastName
      || oldUser.Email != newUser.Email
      || oldUser.City != newUser.City
      || oldUser.State != newUser.State
      || oldUser.Country != newUser.Country
      || oldUser.Title != newUser.Title
      || oldUser.Phone != newUser.Phone
      || oldUser.Department != newUser.Department
      || oldUser.IsActive != newUser.IsActive
      || oldUser.ManagerId != newUser.ManagerId)

    {
      return true;
    }
    else
    {
      return false;
    }
  }

  public static Primary_Sales_Rep__c copyUserEmailFieldsToPSR( Primary_Sales_Rep__c psrToUpdate, User user )
  {
  //added by sujitha to fix null object reference error.
   // psrToUpdate = new  Primary_Sales_Rep__c();
   // psrToUpdate.email_bdm_rvp__c    =   user.BDM_RVP_Email__c;
   System.debug('user'+user);
      System.debug('psr'+psrToUpdate);
    psrToUpdate.email_dir__c        =   user.Dir_Email__c;
    psrToUpdate.Email_DMD__c        =   user.Email_DMD__c;
    psrToUpdate.GSM_Email__c        =   user.GSM_Email__c;
    psrToUpdate.email_pres__c       =   user.Pres_Email__c;
    psrToUpdate.Email_TL__c         =   user.TL_Email__c;
    psrToUpdate.email_vp__c         =   user.Vice_President_Email__c;
    psrToUpdate.email_zm_sm__c      =   user.ZM_SM_Email__c;

    return psrToUpdate;
  }

  public static Primary_Sales_Rep__c copyUserNameFieldsToPSR( Primary_Sales_Rep__c psrToUpdate, User user )
  {
    psrToUpdate.name_bdm_rvp__c     =   user.name_bdm_rvp__c;
    psrToUpdate.name_dir__c         =   user.name_dir__c;
    psrToUpdate.Name_DMD__c         =   user.name_dmd__c;
    psrToUpdate.name_gsm__c         =   user.name_gsm__c;
    psrToUpdate.name_pres__c        =   user.name_pres__c;
    psrToUpdate.Name_TL__c          =   user.name_team_lead__c;
    psrToUpdate.name_vp__c          =   user.name_vp__c;
    psrToUpdate.name_zm_sm__c       =   user.name_zm_sm__c;

    return psrToUpdate;
  }

  public static Primary_Sales_Rep__c copyUserOtherFieldsToPSR( Primary_Sales_Rep__c psrToUpdate, User user )
  {
    psrToUpdate.City__c = user.City;
    psrToUpdate.State__c = user.State;
    psrToUpdate.Country__c = user.Country;
    psrToUpdate.Title__c = user.Title;
    psrToUpdate.Phone__c = user.Phone;
    psrToUpdate.Business_Unit__c = user.Department;
    psrToUpdate.deactivated_user__c = !user.IsActive;
    psrToUpdate.Name = user.Name;
    psrToUpdate.Email__c = user.Email;

    return psrToUpdate;
  }

/*
//Updated by Sujitha to  To populate  Managers  networkId and Reports To  in PSR record
  public static Primary_Sales_Rep__c copyUserManagertoPSR( Primary_Sales_Rep__c psrToUpdate, User user )
  {
    
     List<Primary_Sales_Rep__c> listprimarySalesRepRecd = new List<Primary_Sales_Rep__c>([Select Id,Name from Primary_Sales_Rep__c where Name=:user.Manager.Name ]);

     if(listprimarySalesRepRecd!=null && listprimarySalesRepRecd.size()>0)
       psrToUpdate.Reports_To__c = listprimarySalesRepRecd[0].Id;

     psrToUpdate.Reports_To_Network_ID_Text__c = user.Manager.Network_Id__c;


    return psrToUpdate;
  }
*/


  public static void syncUsersToPSRsByNetwork( List<User> users, Map<Id, User> oldUsers )
  {
    Map<String, Id> networkIdToUserId = new Map<String, Id>();

    for( User user : users )
    {
      if( !skipSyncingPSRsToUserNetwork && user.Network_Id__c != null && 
        user.UserType == STANDARD_USER_TYPE && user.isActive==true &&
        ( oldUsers == null ||
          (oldUsers.containsKey(user.Id) && !user.Network_Id__c.equals( oldUsers.get( user.Id ).Network_Id__c )) ||
          oldUsers.get( user.Id ).UserType != user.UserType
        ) )
      {
        networkIdToUserId.put( user.Network_Id__c, user.Id );
      }
    }

    if( !networkIdToUserId.isEmpty() )
    {
      syncPSRsToUserNetwork( networkIdToUserId );
    }
  }

  @future
  public static void syncPSRsToUserNetwork( Map<String, Id> networkIdToUserId )
  {
    List<Primary_Sales_Rep__c> primarySalesRepsToUpsert = new List<Primary_Sales_Rep__c>();
    Map<String, Primary_Sales_Rep__c> networkIdToPSR = new Map<String, Primary_Sales_Rep__c>();
    for( Primary_Sales_Rep__c aPSR :  [ SELECT Id, OwnerId, Network_ID__c FROM Primary_Sales_Rep__c WHERE Network_ID__c IN :networkIdToUserId.keySet() AND Network_ID__c <> NULL ] )
    {
      networkIdToPSR.put( aPSR.Network_ID__c.toLowerCase(), aPSR );
    }

    for( String networkId : networkIdToUserId.keySet() )
    {
      Primary_Sales_Rep__c targetPSR;
      // if there already is a PSR record, retrieve the existing record
      if( networkIdToPSR.containsKey( networkId.toLowerCase() ) )
      {
        targetPSR = networkIdToPSR.get( networkId.toLowerCase() );
      }
      // otherwise create a new PSR and rely on triggers to populate values
      else
      {
        targetPSR = new Primary_Sales_Rep__c();
        targetPSR.Network_ID__c = networkId;
      }
      targetPSR.SF_userid__c = networkIdToUserId.get( networkId );
      targetPSR.OwnerId = networkIdToUserId.get( networkId );

      primarySalesRepsToUpsert.add( targetPSR );
    }

    if( !primarySalesRepsToUpsert.isEmpty() )
    {
      try
      {
        upsert primarySalesRepsToUpsert;
      }
      catch( System.DmlException ex )
      {
        System.debug( ex );
        throw ex;
      }
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}