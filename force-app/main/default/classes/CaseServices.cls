public with sharing class CaseServices {

    public static final String INBOUND_CASE_IDENTIFIER = 'Incoming_Fax';
    public static final String INFORMATION_ONLY_CASE_IDENTIFIER = 'Information_Email'; 
    public static final String SPAM_CASE_IDENTIFIER = 'Spam';
    public static final String ULS_CASE_IDENTIFIER = 'X30_ULS_Customer_Inquiry';
    public static final String SALES_SUPPORT_CASE_IDENTIFIER = 'Sales_Support';
    public static final String PREV_OWNER_TEAMROLE_NAME = 'Past Owner';
    public static final String IN_OFFICE_STATUS = 'In Office';
    public static final String RECEIVED_CASE_WHILE_OUT_STATUS = 'Out of Office Received';
    public static final List<String> OOO_STATUSES = new List<String>{RECEIVED_CASE_WHILE_OUT_STATUS, 'Away From Desk','End of Day', 'Lunch', 'Meeting', 'Vacation'};
    public static final String NO_ROLE_FOUND = 'Cannot complete assignment - no "Previous Owner" team role found. Please contact administrator.';
    public static final RecordType EBUSINESS_RECORD_TYPE = CaseModel.getRecordType( 'eBusiness' );
    public static final String EBUSINESS_RT_NAME = 'eBusiness';
    public static final String CLOSED_STATUS = 'Closed';

    public static final Set <String> CASE_RECORD_TYPES = new Set<String>{INBOUND_CASE_IDENTIFIER, INFORMATION_ONLY_CASE_IDENTIFIER, SPAM_CASE_IDENTIFIER,ULS_CASE_IDENTIFIER,
                                                                            SALES_SUPPORT_CASE_IDENTIFIER};
    public static final List <String> ULS_CASES = new List<String> {ULS_CASE_IDENTIFIER};
    
    
    
    public static CaseTeamRole previousOwnerRole {
        get 
        {
            if(previousOwnerRole == null ) 
            {
                previousOwnerRole = [SELECT Id FROM CaseTeamRole WHERE Name = :PREV_OWNER_TEAMROLE_NAME LIMIT 1 ];
            }
            return previousOwnerRole;
        } set;
    }
    
    public static String eBusiness_RecordType_Id {
        get
        {
            if( eBusiness_RecordType_Id == null )
            {
                eBusiness_RecordType_Id = InactiveRecordTypes__c.getInstance( EBUSINESS_RT_NAME ).Record_Type_Id__c;
            }
            return eBusiness_RecordType_Id;
        }
        set;
    }

    public static String userPrefix {
        get
        {
            if( userPrefix == null )
            {
                userPrefix = Schema.SObjectType.User.getKeyPrefix();
            }
            return userPrefix;
        }
        set;
    }

    public static void createCaseTeamMembersForOldOwners(List<Case>updatedCases, Map<Id, Case>oldCaseMap)
    {
        List<Case> changedCases = casesWithChangedOwners(updatedCases, oldCaseMap);

        if ( !changedCases.isEmpty() )
        {
            try
            {
                
                try
                {
                    List<CaseTeamMember> caseTeamMembersToUpsert = buildCaseTeamMemberForCurrentUser(changedCases);
                    caseTeamMembersToUpsert.addall(buildCaseTeamMemberForPreviousOwner(changedCases, oldCaseMap));
                    if(!caseTeamMembersToUpsert.isEmpty()) {
                       upsert caseTeamMembersToUpsert;
                    }
                }
                catch( System.Exception anEx )
                {
                    for ( Case changedCase : changedCases )
                        changedCase.addError( anEx.getMessage() );
                }
            }
            catch( System.Exception anEx )
            {
                for ( Case changedCase : changedCases )
                    changedCase.addError( NO_ROLE_FOUND );
            }
        }
    }
    
    public static List<CaseTeamMember> buildCaseTeamMemberForPreviousOwner(List<Case> filteredCases, Map<Id, Case> oldCaseMap)  {
        List<CaseTeamMember> caseTeamMembersToUpsert = new List<CaseTeamMember>();
        Set<ID> caseOwnerIds = Pluck.ids('OwnerId', oldCaseMap.values());
        
        //check if user is active
        map<id,user> activeUserMap = new map<id,user>([select id, isactive from user where id in:caseOwnerIds]);
        
        List<CaseTeamMember> members = [Select parentID, memberID, teamRoleID, ID from CaseTeamMember 
                                        where parentID IN : filteredCases AND member.isactive = true and memberID IN : caseOwnerIds];
                                        
                                        
                                        
        Map<String, ID> parentAndOwnerToCaseMap = new Map<String, ID>();
        
        for( CaseTeamMember member : members ) {         
               parentAndOwnerToCaseMap.put(String.valueof(member.parentID) + String.valueOf(member.memberID), member.id);
           
        }

        for (Case newCase : filteredCases) {

            if (oldCaseMap.containsKey(newCase.id)) {
                Case oldCase = oldCaseMap.get(newCase.id);
                user oldOwner = activeUserMap.get(oldCase.ownerID);
                //The CaseTeamMember for the current user is already handled in buildCaseTeamMemberForCurrentUser
                if(oldCase.ownerID != UserInfo.getUserId() && !String.valueOf(oldCase.ownerID).startsWith('00G')&&oldOwner.isactive) {
                    CaseTeamMember member = new CaseTeamMember( ParentId = oldCase.Id,
                                                            MemberId = oldCase.OwnerId,
                                                            TeamRoleId = previousOwnerRole.Id
                                                           );


                    if(parentAndOwnerToCaseMap.containsKey(String.valueOf(oldCase.id) + String.valueOf(oldCase.ownerID)) ){
                        member.id = parentAndOwnerToCaseMap.get(String.valueOf(oldCase.id) + String.valueOf(oldCase.ownerID));
                    }
                    caseTeamMembersToUpsert.add(member);
                }
            }
        }
        
        
        return caseTeamMembersToUpsert;
    }
    
    
    public static List<Case> casesWithChangedOwners(List<Case>updatedCases, Map<Id, Case>oldCaseMap)
    {
        //Set<Id>caseRecordTypeIds = new Set<Id>();
        List<Case>validCases = new List<Case>();

        if( eBusiness_RecordType_Id == null )
            return validCases;

        for(Case updatedCase : updatedCases)
        {
            Case oldCase = oldCaseMap.get(updatedCase.Id);

            String ownerId = (String)updatedCase.OwnerId;
            String previousOwnerId = (String)oldCase.OwnerId;

            Boolean ownerChanged = ownerId != previousOwnerId;

            if( !( eBusiness_RecordType_Id != null && updatedCase.RecordTypeId == eBusiness_RecordType_Id ) && ownerChanged )
            {
                validCases.add(updatedCase);
            }
        }

        return validCases;
    }

    public static List<CaseTeamMember> buildCaseTeamMemberForCurrentUser(List<Case>cases)
    {
        Set<Id>casesToIgnore = new Set<Id>();
        List<CaseTeamMember> caseTeamMembersToUpsert = new List<CaseTeamMember>();

        //deterime if a case team member already exists for this user
        for(CaseTeamMember found : [SELECT TeamRoleId, ParentId, MemberId, member.isactive
                                FROM CaseTeamMember
                                WHERE MemberId =: UserInfo.getUserId()
                                AND member.isactive = true 
                                AND ParentId in : cases])
        {
            if(found.TeamRoleId != previousOwnerRole.id)
            {
                found.TeamRoleId = previousOwnerRole.Id;
                caseTeamMembersToUpsert.add(found);
            }

            casesToIgnore.add(found.ParentId);
        }

        for(Case caseTeamMemberNeeded : cases)
        {
            if(!casesToIgnore.contains(caseTeamMemberNeeded.Id))
            {
                CaseTeamMember caseTeamMemberToInsert = new CaseTeamMember(ParentId = caseTeamMemberNeeded.Id,
                                                            MemberId = UserInfo.getUserId(),
                                                            TeamRoleId = previousOwnerRole.Id );
                caseTeamMembersToUpsert.add(caseTeamMemberToInsert);
            }
        }

        return caseTeamMembersToUpsert;
    }

    public static List<Case> filterUpdatedCaseOwner( Map<Id, Case> oldCases, List<Case> newCases )
    {
        List<Case> filteredCases = new List<Case>();

        for( Case newCase : newCases )
        {
            if( newCase.OwnerId != oldCases.get( newCase.Id ).OwnerId )
            {
                filteredCases.add( newCase );
            }
        }

        return filteredCases;
    }

    public static List<Case> populateCaseFieldsUponOwnerChange( List<Case> newCases )
    {
        system.debug('inside method of before insert');
        Set<Id> caseOwnerIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();

        for( Case aCase : newCases )
        {
            if( !String.valueOf( aCase.OwnerId ).startsWith( userPrefix ) )
            {
                caseOwnerIds.add( aCase.OwnerId );
            }
        }

        List<Fax_To_Case_Queue_Assignment__c> queueAssignments = [ SELECT Id, OwnerId, Team_Lead_Name__c, Team_Lead_Email__c FROM Fax_To_Case_Queue_Assignment__c WHERE OwnerId IN :caseOwnerIds ];
system.debug('queueAssignments'+queueAssignments);
        for( Case newCase : newCases )
        {
            // String.valueOf() needed because using startsWith for Id to (String or Id) doesn't work.
            if( String.valueOf( newCase.OwnerId ).startsWith( userPrefix ) )
            { 
                system.debug('inside if of owner '+ newCase.OwnerId);
                newCase.Owner_Clone__c = newCase.OwnerId;
                casesToUpdate.add( newCase );
            }
            else
            {
                system.debug('inside else before insert');
                if( newCase.Status != CLOSED_STATUS )
                {
                    for( Fax_To_Case_Queue_Assignment__c queueAssignment : queueAssignments )
                    {
                        if( newCase.OwnerId == queueAssignment.OwnerId )
                        {
                            newCase.Team_Lead_Name__c = queueAssignment.Team_Lead_Name__c;
                            newCase.Team_Lead_Email__c = queueAssignment.Team_Lead_Email__c;
                            casesToUpdate.add( newCase );
                        }
                    }
                }
            }
        }

        return casesToUpdate;
    }
}