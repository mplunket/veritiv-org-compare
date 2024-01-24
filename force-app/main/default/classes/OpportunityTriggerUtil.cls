public class OpportunityTriggerUtil {

    public static final String ADMIN_PREFIX = 'Admin -';
    public static final String BM_PREFIX = 'BM -';
    public static final String SALES_PREFIX = 'Sales Rep';
    public static final String SALES_REP_PROFILE = 'Sales Professional - Lightning';

    public static final String EMAIL_TEMPLATE_NAME = 'Specialist_Team_Add';
    public static final Id DEU_RECORD_TYPEID = '012700000009SzG';
	//Added by sujitha date 10/02/18
	public static final Id Pros_RECORD_TYPEID = '012700000009OvZAAU';
    public static final String ALL_ACCESS_LEVEL = 'All';
    public static final String REP_SHARE_ACCESS_LEVEL = 'Edit';
    public static final String REP_SHARE_ROW_CAUSE = 'Team';
    public static final String REP_IREP_TEAM_ROLE = 'Auto iRep';
    public static final String REP_PSR_TEAM_ROLE = 'Auto PSR';
    public static final String REP_IREP_LOOKUP_FIELD = 'iRep__c';
    public static final String REP_PSR_LOOKUP_FIELD = 'Primary_Sales_Rep_Name__c';
    public static final Map<String, String> REP_FIELD_NAME_TO_TEAM_ROLE = new Map<String, String>{ REP_PSR_LOOKUP_FIELD => REP_PSR_TEAM_ROLE,
                                                                                                    REP_IREP_LOOKUP_FIELD => REP_IREP_TEAM_ROLE };
    public static final List<String> FIELD_NAMES = new List<String>{ /*'Primary_Sales_Rep_Name__c',*/ 'Account_Manager__c', 'Project_Manager__c', 'Transportation_Manager__c' };
     
    public static final String CARRY_OVER_SALES_TEAM_ERROR = 'Could not carry over Sales Team.';
    public static final String INACTIVE_OWNER_SALESFORCE_MESG = 'operation performed with inactive user';
    public static final String INACTIVE_OWNER_SALESFORCE_MESG_2 = 'owner is inactive, cannot reparent record';

    private static List<OpportunityTeamMember> teamMembersToCarryOver;
    public static List<OpportunityShare> teamSharesToCarryOver;

    //public static List<RoleNameMapping__c> roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];

    
    //Commented on 22/08/2018 as per request we removed since it is not used anymore
    /**
    *   Populate the ACCOUNT_DEU__c opportunity field for Opportunities
    *   with DEU Accounts
    *//*
    public static void updateAccountDEUField(List<Opportunity> opportunities)
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> DEUAcountIds = new Set<Id>();
        for(Opportunity opp : opportunities)
        {
            if(opp.AccountId != null && checkCurrencyCode(opp))
            {
                accountIds.add(opp.AccountId);
            }
        }

        for(Account acc : [SELECT Id, Name, RecordTypeId FROM Account WHERE Id IN :accountIds])
        {
            if(acc.RecordTypeId == DEU_RECORD_TYPEID)
            {
                DEUAcountIds.add(acc.Id);
            }
        }

        for(Opportunity opp : opportunities)
        {
            if(DEUAcountIds.contains(opp.AccountId) && checkCurrencyCode(opp))
            {
                opp.ACCOUNT_DEU__c = opp.AccountId;
            }
        }
    }*/

    public static void updateExistingOpportunitiesSalesTeam(List<Opportunity> opportunities)
    {

        Set<String> categories = getCategorySet(opportunities);
        Map<String, List<User>> category2specialists;

        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<User> specialistsAdded = new List<User>();

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.allowFieldTruncation = true;

            //Updates are based on opportunity owner
        opportunities = [SELECT Id, Owner.UserRoleId, Owner.OSM_Override__c, Prod_Category__c, CurrencyIsoCode FROM Opportunity WHERE Id IN :opportunities];
    map<Opportunity,id> oppWithNoSpecialCat = new map<Opportunity,id>();
        for(Opportunity o : opportunities)
        {
            if ( checkCurrencyCode( o ) )
            {
                
                UserRole role = RoleMap.getInstance().getRoleId2Role().get(o.Owner.UserRoleId);

                //ensure role name doesn't contain specialist
                if(role != null && !role.Name.contains('Specialist')){
                    UserRole topRole = (o.Owner.OSM_Override__c) ? role : getTopRoleInHierarchy(role);
                    oppWithNoSpecialCat.put(o,topRole.Id);
                }
            }
        }
        
        map<string, OpportunitySpecialistMapping__c> roleIDOppSpeMap = new map<string, OpportunitySpecialistMapping__c>();                          
        for(OpportunitySpecialistMapping__c opMap : [SELECT Role_ID__c, Group_ID__c, Id
                                  FROM OpportunitySpecialistMapping__c]){
            roleIDOppSpeMap.put(opMap.Role_ID__c , opMap);
        }
        list<OpportunitySpecialistMapping__c> finalSpecMappingPassList = new  list<OpportunitySpecialistMapping__c>();
        for(opportunity op : oppWithNoSpecialCat.keyset()){
            //Will optimize later
            If(roleIDOppSpeMap.keyset().contains(oppWithNoSpecialCat.get(op))){
                finalSpecMappingPassList.add(roleIDOppSpeMap.get(oppWithNoSpecialCat.get(op)));
            }
        }
        
        for(OpportunitySpecialistMapping__c opMSpMa  : finalSpecMappingPassList){
            List<OpportunitySpecialistMapping__c> pasList = new List<OpportunitySpecialistMapping__c>();
            pasList.add(opMSpMa);
            category2specialists = getCategoryToSpecialistsMapping(pasList, categories);
        }
        
        //continue;
/*
                UserRole topRole = (o.Owner.OSM_Override__c) ? role : getTopRoleInHierarchy(role);
                System.debug('TopRole:'+topRole);

                List<OpportunitySpecialistMapping__c> specialistMapping = new List<OpportunitySpecialistMapping__c>();

                specialistMapping = [SELECT Role_ID__c, Group_ID__c, Id
                                  FROM OpportunitySpecialistMapping__c
                                   WHERE Role_ID__c = :topRole.Id ];

                if(specialistMapping.isEmpty())
                    continue;

                category2specialists = getCategoryToSpecialistsMapping(specialistMapping, categories);

                if(o.Prod_Category__c != null)
                {
                    for(String category : o.Prod_Category__c.split(';'))
                    {
                        for(User specialist : category2specialists.get(category))
                        {
                            specialistsAdded.add(specialist);
                            OpportunityTeamMember otm = new OpportunityTeamMember( UserId = specialist.Id,
                                                                      TeamMemberRole = specialist.Title,
                                                                      OpportunityId = o.Id
                                                                      );
                            //allow field truncation
                            otm.setOptions(dmlOptions);
                            oppTeamMembers.add(otm);
                            oppShares.add(new OpportunityShare(UserOrGroupId = specialist.Id,
                                                         OpportunityId = o.Id,
                                                         OpportunityAccessLevel = 'Edit'));
                        }
                    }
                }
            }//check for currency code
        }

            System.debug('Team Members:'+oppTeamMembers);
            System.debug('shares:'+oppShares);
            try
            {
                if ( !oppTeamMembers.isEmpty() && !oppShares.isEmpty())
                {
                    insert oppTeamMembers;
                    insert oppShares;
                }
            }
            catch(System.DmlException ex)
            {
                System.debug(ex);
            }

            sendEmails(oppTeamMembers, specialistsAdded);
*/
    }

    public static void carryOverSalesTeamOnOwnerChange( Map<Id, Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities )
    {
        Set<Id> opportunitiesWithChangedOwners = new Set<Id>();

        for( Opportunity opportunity : newOpportunities.values() )
        {
            if( opportunity.OwnerId != oldOpportunities.get( opportunity.Id ).OwnerId )
            {
                opportunitiesWithChangedOwners.add( opportunity.Id );
            }
        }

        if( !opportunitiesWithChangedOwners.isEmpty() )
        {
            List<Opportunity> opportunitiesWithRelatedTeam = [ SELECT Id, OwnerId,
                                                                    ( SELECT Id, OpportunityId, TeamMemberRole, User.IsActive FROM OpportunityTeamMembers ),
                                                                    ( SELECT Id, OpportunityAccessLevel, OpportunityId, UserOrGroupId FROM Shares WHERE RowCause =: REP_SHARE_ROW_CAUSE AND OpportunityAccessLevel != :ALL_ACCESS_LEVEL )
                                                                FROM Opportunity
                                                                WHERE Id IN :opportunitiesWithChangedOwners ];

            teamMembersToCarryOver = new List<OpportunityTeamMember>();
            teamSharesToCarryOver = new List<OpportunityShare>();

            for( Opportunity opportunityWithTeam : opportunitiesWithRelatedTeam )
            {
                for( OpportunityTeamMember teamMember : opportunityWithTeam.OpportunityTeamMembers )
                {
                    if( teamMember.User.IsActive )
                    {
                        // create a share for the old owner if the old owner was a team member
                        if( teamMember.UserId == opportunityWithTeam.OwnerId )
                        {
                            OpportunityShare newShare = new OpportunityShare();
                            newShare.OpportunityAccessLevel = REP_SHARE_ACCESS_LEVEL;
                            newShare.OpportunityId = teamMember.OpportunityId;
                            newShare.UserOrGroupId = opportunityWithTeam.OwnerId;
                            teamSharesToCarryOver.add( newShare );
                        }
                        teamMembersToCarryOver.add( teamMember );
                    }
                }
                for( OpportunityShare teamShare : opportunityWithTeam.Shares )
                {
                    System.debug('** Team.Shares: ' + teamShare);
                    // only create a share if the new owner is not a team member
                    if( teamShare.UserOrGroupId != newOpportunities.get( opportunityWithTeam.Id ).OwnerId )
                    {
                        System.debug('ADDING TO LIST');
                        teamSharesToCarryOver.add( teamShare.clone( false, true ) );
                    }
                }
            }

        }

        System.debug('### carryOverSalesTeamOnOwnerChange ###');
        System.debug('### teamSharesToCarryOver: ' + teamSharesToCarryOver);
        System.debug('### teamMembersToCarryOver: ' + teamMembersToCarryOver);
    }

    public static void createTeamMembersAfterTriggerFires( Map<Id, Opportunity> newOpportunities )
    {
        System.debug('### createTeamMembersAfterTriggerFires ###');
        System.debug('### teamSharesToCarryOver: ' + teamSharesToCarryOver);
        System.debug('### teamMembersToCarryOver: ' + teamMembersToCarryOver);
        
        if( teamMembersToCarryOver != null && !teamMembersToCarryOver.isEmpty() )
        {
            try
            {
                insert teamMembersToCarryOver.deepClone( false );
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    Id opptyId = teamMembersToCarryOver[ ex.getDmlIndex( index ) ].OpportunityId;
                    Id userid = teamMembersToCarryOver[ ex.getDmlIndex( index ) ].UserId;
                    newOpportunities.get( opptyId ).addError( 'creating member for ' + userid + ex.getMessage() );

/*                  if(newOpportunities.containsKey(opptyId))
                    {
                        newOpportunities.get( opptyId ).addError( 'creating member for ' + userid + ex.getMessage() );
                    }
                    else
                    {
                        System.debug('Error creating member for ' + userid + ex.getMessage());
                    }
*/                  
                }
            }

            try
            {
                teamSharesToCarryOver = OpportunityTeamMemberServices.filterOutOwnerOpportunityShares(teamSharesToCarryOver);
                insert teamSharesToCarryOver;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    Id opptyId = teamSharesToCarryOver[ ex.getDmlIndex( index ) ].OpportunityId;
                    Id userid = teamSharesToCarryOver[ ex.getDmlIndex( index ) ].UserOrGroupId;
                    newOpportunities.get( opptyId ).addError( 'creating share for ' + userid + ex.getMessage() + ' Opp Share: ' + teamSharesToCarryOver[ ex.getDmlIndex( index ) ] );
                }
            }
        }

        teamMembersToCarryOver = NULL;
        teamSharesToCarryOver = NULL;
    }

    public static void updateRepFieldsOnAccountFieldChange( Map<Id, Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities )
    {
        List<Opportunity> changedOpportunities = new List<Opportunity>();

        for( Opportunity newOpportunity : newOpportunities.values() )
        {
            Opportunity oldOpportunity = oldOpportunities.get( newOpportunity.Id );
            if( newOpportunity.AccountId != oldOpportunity.AccountId && newOpportunity.AccountId != null )
            {
                changedOpportunities.add( newOpportunity );
            }
        }

        if( !changedOpportunities.isEmpty() )
        {
            updateRepFields( changedOpportunities, newOpportunities );
        }
    }

    private static void updateRepFields( List<Opportunity> opportunitiesToChange, Map<Id, Opportunity> newOpportunities )
    {
        Set<Id> accountIds = new Set<Id>();

        for( Opportunity opportunity : opportunitiesToChange )
        {
            accountIds.add( opportunity.AccountId );
        }

        Map<Id, Account> accounts = new Map<Id, Account>( [ SELECT Id, iRep__c, Primary_Sales_Rep_Name__c
                                                                FROM Account
                                                                WHERE Id IN :accountIds ] );

        for( Opportunity opportunity : opportunitiesToChange )
        {
            if( accounts.containsKey( opportunity.AccountId ) )
            {
                Account account = accounts.get( opportunity.AccountId );
                opportunity.iRep__c = account.iRep__c;
                opportunity.Primary_Sales_Rep_Name__c = account.Primary_Sales_Rep_Name__c;
            }
        }
    }

    public static void insertSalesTeamForPSRAndIRep( Map<Id, Opportunity> newOpportunities )
    {
        Map<Id, Map<String, Id>> opportunityIdToNewRepId = new Map<Id, Map<String, Id>>();
        Set<Id> referencedRepIds = new Set<Id>();

        for( Opportunity opportunity : newOpportunities.values() )
        {
            Map<String, Id> newRepIdsForOpportunity = new Map<String, Id>();

            if( opportunity.Primary_Sales_Rep_Name__c != null )
            {
                newRepIdsForOpportunity.put( REP_PSR_TEAM_ROLE, opportunity.Primary_Sales_Rep_Name__c );
                referencedRepIds.add( opportunity.Primary_Sales_Rep_Name__c );
            }
            if( opportunity.iRep__c != null )
            {
                newRepIdsForOpportunity.put( REP_IREP_TEAM_ROLE, opportunity.iRep__c );
                referencedRepIds.add( opportunity.iRep__c );
            }

            if( !newRepIdsForOpportunity.isEmpty() )
            {
                opportunityIdToNewRepId.put( opportunity.Id, newRepIdsForOpportunity );
            }
        }

        if( !referencedRepIds.isEmpty() )
        {
            insertAndDeleteRepTeamMembers( opportunityIdToNewRepId, null, referencedRepIds, newOpportunities );
        }
    }

    public static void updateSalesTeamForPSRAndIRep( Map<Id, Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities )
    {
        Map<Id, Map<String, Id>> opportunityIdToNewRepId = new Map<Id, Map<String, Id>>();
        Map<Id, Set<Id>> opportunityIdToExistingRepId = new Map<Id, Set<Id>>();

        Set<Id> referencedRepIds = new Set<Id>();

        for( Opportunity opportunity : newOpportunities.values() )
        {
            Set<Id> existingRepIdsForOpportunity = new Set<Id>();
            Map<String, Id> newRepIdsForOpportunity = new Map<String, Id>();

            Opportunity oldOpportunity = oldOpportunities.get( opportunity.Id );

            compareRepFields( newRepIdsForOpportunity, existingRepIdsForOpportunity, opportunity, oldOpportunity, REP_PSR_LOOKUP_FIELD, REP_IREP_LOOKUP_FIELD );
            compareRepFields( newRepIdsForOpportunity, existingRepIdsForOpportunity, opportunity, oldOpportunity, REP_IREP_LOOKUP_FIELD, REP_PSR_LOOKUP_FIELD );

            if( !existingRepIdsForOpportunity.isEmpty() )
            {
                opportunityIdToExistingRepId.put( opportunity.Id, existingRepIdsForOpportunity );
                referencedRepIds.addAll( existingRepIdsForOpportunity );
            }
            if( !newRepIdsForOpportunity.isEmpty() )
            {
                opportunityIdToNewRepId.put( opportunity.Id, newRepIdsForOpportunity );
                referencedRepIds.addAll( newRepIdsForOpportunity.values() );
            }
        }

        if( !referencedRepIds.isEmpty() )
        {
            insertAndDeleteRepTeamMembers( opportunityIdToNewRepId, opportunityIdToExistingRepId, referencedRepIds, newOpportunities );
        }

    }

    private static void compareRepFields( Map<String, Id> newRepIdSet,
                                          Set<Id> existingRepIdSet,
                                          Opportunity newOpportunity,
                                          Opportunity oldOpportunity,
                                          String fieldName,
                                          String relatedFieldName )
    {
        if( !( newOpportunity.get( fieldName ) instanceOf Id ) || !( newOpportunity.get( relatedFieldName ) instanceOf Id ) ) return;

        if( newOpportunity.get( fieldName ) != oldOpportunity.get( fieldName ) )
        {
            if( oldOpportunity.get( fieldName ) != null
                && oldOpportunity.get( fieldName ) != newOpportunity.get( relatedFieldName ) )
            {
                existingRepIdSet.add( (Id)oldOpportunity.get( fieldName ) );
            }
            if( newOpportunity.get( fieldName ) != null )
            {
                newRepIdSet.put( REP_FIELD_NAME_TO_TEAM_ROLE.get( fieldName ), (Id)newOpportunity.get( fieldName ) );
            }
        }
    }

    private static void insertAndDeleteRepTeamMembers( Map<Id, Map<String, Id>> opportunityIdToNewRepId,
                                                       Map<Id, Set<Id>> opportunityIdToExistingRepId,
                                                       Set<Id> referencedRepIds,
                                                       Map<Id, Opportunity> newOpportunities )
    {
        Map<Id, Id> repIdToUserId = new Map<Id, Id>();
        for( Primary_Sales_Rep__c referencedRep : [ SELECT Id, SF_userid__c
                                                    FROM Primary_Sales_Rep__c
                                                    WHERE Id IN :referencedRepIds
                                                        AND SF_userid__r.isActive = true ] )
        {
            if( referencedRep.SF_userid__c != null )
            {
                repIdToUserId.put( referencedRep.Id, referencedRep.SF_userid__c );
            }
        }

        if( opportunityIdToExistingRepId != null )
        {
            List<OpportunityTeamMember> existingMembers = getExistingRepMembers( opportunityIdToExistingRepId, repIdToUserId );

            if( !existingMembers.isEmpty() )
            {
                try{
                    delete existingMembers;
                }
                catch( System.DmlException ex )
                {
                    for( Integer index = 0; index < ex.getNumDml(); index++ )
                    {
                        Id errorOpptyId = existingMembers[ ex.getDmlIndex( index) ].OpportunityId;
                        newOpportunities.get( errorOpptyId ).addError( ex.getDmlMessage( index ) );
                        return;
                    }
                }
            }
        }

        if( !opportunityIdToNewRepId.isEmpty() )
        {
            createRepMembers( opportunityIdToNewRepId, repIdToUserId, newOpportunities );
        }
    }

    private static List<OpportunityTeamMember> getExistingRepMembers( Map<Id, Set<Id>> opportunityIdToRepId, Map<Id, Id> repIdToUserId )
    {
        List<OpportunityTeamMember> existingMembers = new List<OpportunityTeamMember>();

        // build map of oppty id to user ids, since we only have oppty to repid and repid to userid
        Map<Id, Set<Id>> opportunityIdToUserIds = new Map<Id, Set<Id>>();
        Set<Id> referencedUserIds = new Set<Id>();
        for( Id opportunityId : opportunityIdToRepId.keySet() )
        {
            Set<Id> userIdsForOpportunity = new Set<Id>();
            for( Id repId : opportunityIdToRepId.get( opportunityId ) )
            {
                userIdsForOpportunity.add( repIdToUserId.get( repId ) );
                referencedUserIds.add( repIdToUserId.get( repId ) );
            }
            opportunityIdToUserIds.put( opportunityId, userIdsForOpportunity );
        }

        if( !referencedUserIds.isEmpty() )
        {
            for( OpportunityTeamMember existingMember : [ SELECT Id, OpportunityId, UserId
                                                            FROM OpportunityTeamMember
                                                            WHERE OpportunityId IN :opportunityIdToRepId.keySet()
                                                                AND UserId IN :referencedUserIds
                                                                AND ( TeamMemberRole = :REP_PSR_TEAM_ROLE
                                                                    OR TeamMemberRole = :REP_IREP_TEAM_ROLE ) ] )
            {
                if( opportunityIdToUserIds.get( existingMember.OpportunityId ).contains( existingMember.UserId ) )
                {
                    existingMembers.add( existingMember );
                }
            }
        }

        return existingMembers;
    }

    private static void createRepMembers( Map<Id, Map<String, Id>> opportunityIdToRepId, Map<Id, Id> repIdToUserId, Map<Id, Opportunity> newOpportunities )
    {
        List<OpportunityTeamMember> newTeamMembers = new List<OpportunityTeamMember>();

        for( Id opportunityId : opportunityIdToRepId.keySet() )
        {
            Map<String, Id> repMemberTypeToRepId = opportunityIdToRepId.get( opportunityId );
            for( String repMemberType : repMemberTypeToRepId.keySet() )
            {
                if( repIdToUserId.containsKey( repMemberTypeToRepId.get( repMemberType ) ) )
                {
                    OpportunityTeamMember newMember = new OpportunityTeamMember();
                    newMember.OpportunityId = opportunityId;
                    newMember.UserId = repIdToUserId.get( repMemberTypeToRepId.get( repMemberType ) );
                    newMember.TeamMemberRole = repMemberType;
                    newTeamMembers.add( newMember );
                }
            }
        }

        if( !newTeamMembers.isEmpty() )
        {
            try
            {
                insert newTeamMembers;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    if( ex.getDmlType( index ) == System.StatusCode.INACTIVE_OWNER_OR_USER
                        && ex.getDmlMessage( index ).equals( INACTIVE_OWNER_SALESFORCE_MESG )
                        ||
                        ex.getDmlType( index ) == System.StatusCode.CANNOT_REPARENT_RECORD
                        && ex.getDmlMessage( index ).equals( INACTIVE_OWNER_SALESFORCE_MESG_2 ) )
                    {
                        continue;
                    }
                    else
                    {
                        Id errorOpptyId = newTeamMembers[ ex.getDmlIndex( index) ].OpportunityId;
                        newOpportunities.get( errorOpptyId ).addError( ex.getDmlMessage( index ) );
                        return;
                    }
                }
            }

            List<OpportunityShare> newTeamShares = createRepShares( newTeamMembers, newOpportunities );

            try
            {
                insert newTeamShares;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    Id errorOpptyId = newTeamShares[ ex.getDmlIndex( index) ].OpportunityId;
                    newOpportunities.get( errorOpptyId ).addError( ex.getDmlMessage( index ) );
                    return;
                }
            }
        }
    }

    private static List<OpportunityShare> createRepShares( List<OpportunityTeamMember> opportunityTeamMembers, Map<Id, Opportunity> opportunitiesMap )
    {
        List<OpportunityShare> newOpportunityShares = new List<OpportunityShare>();
        for( OpportunityTeamMember teamMember : opportunityTeamMembers )
        {
            if( opportunitiesMap.get( teamMember.opportunityId ).OwnerId != teamMember.UserId )
            {
                OpportunityShare newShare = new OpportunityShare();
                newShare.OpportunityAccessLevel = REP_SHARE_ACCESS_LEVEL;
                newShare.OpportunityId = teamMember.OpportunityId;
                newShare.UserOrGroupId = teamMember.UserId;
                newOpportunityShares.add( newShare );
            }
        }

        return newOpportunityShares;
    }

    private static void sendEmails(List<OpportunityTeamMember> oppTeamMembers, List<User> specialistsAdded)
    {
        Map<Id, List<User>> oppId2Users = new Map<Id, List<User>>();

        System.debug('oppTeamMembers'+oppTeamMembers);
        System.debug('specialistsAdded'+oppTeamMembers);
        //Map opportunities to Lists of users
        for(OpportunityTeamMember otm : oppTeamMembers)
        {
            if(!oppId2Users.containsKey(otm.OpportunityId))
            {
                oppId2Users.put(otm.OpportunityId, new List<User>());
            }

            List<User> users = oppId2Users.get(otm.OpportunityId);
            for(User u : specialistsAdded)
            {
                if(u.Id == otm.UserId && (u.FirstName != 'Skip' || u.LastName != 'Gigliotti'))
                {
                    users.add(u);
                    break;
                }
            }
            oppId2Users.put(otm.OpportunityId, users);
        }

        EmailConfig__c mailConfig;
        try
        {
            mailConfig = [SELECT IsDebug__c, IsActive__c, Id, EmailTemplateName__c, DebugUser__c,
                                     DebugUser__r.Email, DebugUser__r.FirstName, DebugUser__r.LastName
                            FROM EmailConfig__c
                             WHERE EmailTemplateName__c = :EMAIL_TEMPLATE_NAME];
        }
        catch(Exception ex)
        {
            System.debug(ex);
            return;
        }

        if(mailConfig == null || !mailConfig.IsActive__c)
            return;

        System.debug('EMAIL_TEMPLATE_NAME'+EMAIL_TEMPLATE_NAME);
System.debug('current user'+userInfo.getName());
        EmailTemplate template = [SELECT Subject, Name, Markup, Id, HtmlValue, FolderId, Encoding, DeveloperName,
                                          Description, BrandTemplateId, Body, ApiVersion
                                    FROM EmailTemplate
                                     WHERE DeveloperName = :EMAIL_TEMPLATE_NAME];
System.debug('template'+template);
        for(Id oppId : oppId2Users.keySet())
        {
            sendSpecialistAlertEmail(oppId2Users.get(oppId), oppId, template, mailConfig);
        } 
    }

    /**
    *   Send an email to the specialists on the sales team
    *
    *   @param  users           list of users to send the email to
    *   @param  opportunityId   opportunity to reference in the email
    *   @param  template        the email template
    *   @param  mailConfig      The email configuration.
    */
    public static void sendSpecialistAlertEmail(List<User> users, Id opportunityId, EmailTemplate template, EmailConfig__c mailConfig)
    {
        List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
        List<Contact> tmpContacts = new List<Contact>();
        for(User user : users)
        {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setSaveAsActivity(false);
            msg.setTemplateId(template.Id);
            msg.setWhatId(opportunityId);

            Messaging.SingleEmailMessage msgCC = new Messaging.SingleEmailMessage();
            msgCC.setSaveAsActivity(false);
            msgCC.setTemplateId(template.Id);
            msgCC.setWhatId(opportunityId);

            Contact tmpContact = new Contact();
            Contact tmpContactCC = new Contact();
            if(mailConfig.IsDebug__c)
            {
                tmpContact.Email = mailConfig.DebugUser__r.Email;
                tmpContact.FirstName = mailConfig.DebugUser__r.FirstName;
                tmpContact.LastName = mailConfig.DebugUser__r.LastName;

                tmpContactCC.Email = mailConfig.DebugUser__r.Email;
                tmpContactCC.FirstName = mailConfig.DebugUser__r.FirstName;
                tmpContactCC.LastName = mailConfig.DebugUser__r.LastName;
            }
            else
            {
                tmpContact.Email = user.Email;
                tmpContact.FirstName = user.FirstName;
                tmpContact.LastName = user.LastName;

                tmpContactCC.Email = 'salesforce@unisourcelink.com';
                tmpContactCC.FirstName = user.FirstName;
                tmpContactCC.LastName = user.LastName;
            }

            try
            {
                //ignore contact triggers.
                CaseNotification.isInsertingTempContacts = true;
                insert tmpContact;
                insert  tmpContactCC;
            }
            catch(System.DmlException ex)
            {
                System.debug(ex);
                return;
            }
            tmpContacts.add(tmpContact);
            tmpContacts.add(tmpContactCC);
            System.debug('Contact List --> ' + tmpContacts);
            msg.setTargetObjectId(tmpContact.Id);
            msgCC.setTargetObjectId(tmpContactCC.Id);

            msgs.add(msg);
            msgs.add(msgCC);
        }

        try
        {
            Messaging.sendEmail(msgs);
            System.debug(msgs);
        }
        catch(System.Exception ex)
        {
            System.debug(ex);
        }

        try
        {
            delete tmpContacts;
        }
        catch(System.DmlException ex)
        {
            System.debug(ex);
        }
        CaseNotification.isInsertingTempContacts = false;
    }

    /*private static UserRole getTopRoleInHierarchy(UserRole role, UserRole startRole)
    {
        System.debug('CurrentRole:'+role.Name);

        if(role.ParentRoleId == null)
            return role;
        else if(role.Name.startsWith(ADMIN_PREFIX) ||
                (!startRole.Name.startsWith(SALES_PREFIX) && !startRole.Name.startsWith(BM_PREFIX)))
            return role;
        else
            return getTopRoleInHierarchy([SELECT Id, Name, ParentRoleId FROM UserRole where Id = :role.ParentRoleId], startRole);
    }*/

    public static UserRole getTopRoleInHierarchy(UserRole startRole)
    {
        //System.debug('CurrentRole:'+role.Name);
        UserRole currentRole = startRole;
        UserRole topRoleInHierarchy;

        while(topRoleInHierarchy == null)
        {
            if(currentRole.ParentRoleId == null)
                topRoleInHierarchy = currentRole;
            else if(currentRole.Name.startsWith(ADMIN_PREFIX) ||
                    (!startRole.Name.startsWith(SALES_PREFIX) && !startRole.Name.startsWith(BM_PREFIX)))
                topRoleInHierarchy = currentRole;
            else
                currentRole = RoleMap.getInstance().getRoleId2Role().get(currentRole.ParentRoleId);
        }

        return topRoleInHierarchy;
    }

    private static Map<String, List<User>> getCategoryToSpecialistsMapping(List<OpportunitySpecialistMapping__c> specialistMapping, Set<String> categories)
    {
        Map<String, List<User>> category2specialists = new Map<String, List<User>>();
        Set<Id> groupMemberIds = new Set<Id>();
        Set<Id> specialistMappingGroupIds = new Set<Id>();


        for(OpportunitySpecialistMapping__c sm : specialistMapping)
        {
            specialistMappingGroupIds.add(sm.Group_ID__c);
        }

        //Get user Ids from group members
        for(GroupMember gm : [SELECT UserOrGroupId, GroupId
                               FROM GroupMember
                                WHERE GroupId IN :specialistMappingGroupIds])
        {
            if((gm.UserOrGroupId + '').startsWith('005'))
            {
                groupMemberIds.add(gm.UserOrGroupId);
            }
        }

        List<User> users = [SELECT Id, Title, UserRole.Name, IsActive, Name, Email, FirstName, LastName
         FROM User
          WHERE Id IN : groupMemberIds
           AND IsActive = true];

        for(String category : categories)
        {
            category2specialists.put(category, new List<User>());

            for(User u : users)
            {
                //if(isSpecialistMatch(u.UserRole.Name, category))
                //{
                    List<User> specialists = category2specialists.get(category);
                    specialists.add(u);
                    category2specialists.put(category, specialists);
                //}
            }
        }

        System.debug('cat2specialists:'+category2specialists);
        return category2specialists;
    }

    public static Set<String> getCategorySet(List<Opportunity> opportunities)
    {
        Set<String> categories = new Set<String>();

        for(Opportunity o : opportunities)
        {
            if(o.Prod_Category__c != null)
            {
                for(String category : o.Prod_Category__c.split(';'))
                {
                    categories.add(category);
                }
            }
        }

        return categories;
    }
    
    //Commented on 22-08-2018
/*
    public static Boolean isSpecialistMatch(String roleName, String productCategory)
    {
        for(RoleNameMapping__c rm : roleNameMapping)
        {
            if(productCategory == rm.Product_Category__c && rm.Role_Name__c == roleName )
                return true;
        }

        return false;
    }
*/
    public static boolean checkCurrencyCode( Opportunity o )
    {
        if ( o.CurrencyIsoCode != null && !o.CurrencyIsoCode.equalsIgnoreCase('CAD'))
        {
            return true;
        }

        return false;
    }
    
    /* Removed for BL-3661
    public static List<Opportunity> filterBasedOnFieldUpdates( List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities )
    {
        List<Opportunity> filteredOpportunities = new List<Opportunity>();
        for( Opportunity newOpp : newOpportunities )
        {
            Opportunity oldOpp = oldOpportunities.get( newOpp.Id );
            if( isNotEqual( oldOpp, newOpp ) )
            {
                filteredOpportunities.add( newOpp );
            }
        }
        return filteredOpportunities;
    }
	*/
    
    /* Removed for BL-3661
    private static Boolean isNotEqual( Opportunity oldOpp, Opportunity newOpp )
    {
        for( String fieldName : FIELD_NAMES )
        {
            Id oldFieldValue = (Id)oldOpp.get( fieldName );
            Id newFieldValue = (Id)newOpp.get( fieldName );
            Boolean result = newFieldValue != NULL && newFieldValue != oldFieldValue ;
            if( result )
                return result;
        }
        return false;
    }
	*/
    
    /* Removed for BL-3661
    public static void updateAccounts(List<Account> accountsToBeUpdated, List<Opportunity> opps){
        if( !accountsToBeUpdated.isEmpty() )
        {
            try
            {
                update accountsToBeUpdated;
            }
            catch(  DmlException ex )
            {
                for ( Integer index = 0 ; index < ex.getNumDml() ; index++ )
                {
                    Id errorAccountId = accountsToBeUpdated[ ex.getDmlIndex( index ) ].Id;
                    for( Opportunity anOpportunity : opps )
                    {
                        if( anOpportunity.AccountId == errorAccountId )
                            anOpportunity.addError( ex.getDmlMessage( index ) );
                    }
                }
            }
        }
    }
	*/
    
    /* 10/12 - Taken out to remove Account Vertical field and functionality on Opportunity to remove an inconsistent error. */
    /*
    public static List<Account> populateAccountVerticalField( list<Opportunity> opps){
        
        Map<Id, List<Sobject>> accountIDToOpportunityMap = GroupBy.ids('AccountId', opps);
        List<Account> accountsToReturn = new List<Account>();
        
        for(Account a : [Select id, account_vertical__c from Account where ID IN : accountIDToOpportunityMap.keyset()]) {
            if(accountIDToOpportunityMap.containsKey(a.id) && (!accountIDToOpportunityMap.get(a.id).isEmpty()) ) {
                Opportunity firstOpp = (Opportunity) accountIDToOpportunityMap.get(a.id)[0]; 
                if( firstOpp.Account_Vertical_Update__c != null && a.Account_Vertical__c != firstOpp.Account_Vertical_Update__c ) {
                    a.Account_Vertical__c = firstOpp.Account_Vertical_Update__c;
                    accountsToReturn.add(a);
                }
            }
        }
        
        return accountsToReturn;
    }
    */
    
    /* Removed for BL-3661
    public static List<Account> updateAccountFields( List<Opportunity> opportunities )
    {
        List<Opportunity> filteredOpportunities = opportunities;
        List<Account> accountsToBeUpdated = new List<Account>();
        String query = 'SELECT ';
        query += String.join( FIELD_NAMES, ', '  );
        query += ', Account.Primary_Sales_Rep_Name__c, Account.Account_Manager__c, Account.Project_Manager__c, Account.Transportation_Manager__c, AccountId ';
        query += 'From Opportunity WHERE Id IN :filteredOpportunities ';
        query += 'AND ( Account.Primary_Sales_Rep_Name__c = NULL OR Account.Account_Manager__c = NULL OR Account.Project_Manager__c = NULL OR Account.Transportation_Manager__c = NULL )';
        
        List<Opportunity> oppsWithAccountFields = Database.query( query );
        for( Opportunity anOpportunity : oppsWithAccountFields )
        {
            Account account = new Account( Id = anOpportunity.AccountId );
            for( String fieldName : FIELD_NAMES )
            {
                if( String.isBlank( (Id)anOpportunity.Account.get( fieldName ) ) )
                {
                    account.put( fieldName, (Id)anOpportunity.get( fieldName ) );
                }
            }
            accountsToBeUpdated.add( account );
        }
        return accountsToBeUpdated;
    }
	*/
    
}