/**get Opp specialist mapping info to display*/
public class OsmInfo
{
	public Opportunity opp {get; set;}
	public List<OpportunitySpecialistMapping__c> specialistMapping {get; set;}
	
	
	public List<String> mappingStrings {get; set;}
	
	private Map<Id, UserRole> roleId2Role;
	
	public static final String ADMIN_PREFIX = 'Admin -';
	public static final String BM_PREFIX = 'BM -';
	public static final String SALES_PREFIX = 'Sales Rep';
	
	public static List<RoleNameMapping__c> roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];
	
	public OsmInfo()
	{
		//All roles
		roleId2Role = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
		opp = new Opportunity();
	}
	
	public void calcMapping()
	{
		User u = [SELECT Id, Name, UserRoleId, OSM_Override__c FROM User where Id = :opp.OwnerId ];
		
		
		UserRole role = roleId2Role.get(u.UserRoleId);
		UserRole topRole = (u.OSM_Override__c) ? role : getTopRoleInHierarchy(roleId2Role, role);
		
		specialistMapping = [SELECT Role_ID__c, Group_ID__c, Id 
							  FROM OpportunitySpecialistMapping__c
							   WHERE Role_ID__c = :topRole.Id ];
							   
		System.debug(specialistMapping);
		
		Map<String, List<User>> category2Specialists = getCategoryToSpecialistsMapping(specialistMapping, categories);	
		System.debug(category2Specialists);
		
		mappingStrings = new List<String>();
		for(String category : category2Specialists.keySet())
		{
			if(!category2Specialists.get(category).isEmpty())
			{
				for(User user : category2Specialists.get(category))
				{
					mappingStrings.add(category +' : ' +user.Name);
				}
			}
		}
	}
	
	private static UserRole getTopRoleInHierarchy(Map<Id, UserRole> roleId2Role, UserRole startRole)
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
				currentRole = roleId2Role.get(currentRole.ParentRoleId);
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
				if(isSpecialistMatch(u.UserRole.Name, category))
				{
					List<User> specialists = category2specialists.get(category);
					specialists.add(u); 
					category2specialists.put(category, specialists);
				}
			}				
		}
		
		System.debug('cat2specialists:'+category2specialists);		
		return category2specialists;
	}
	
	public static Boolean isSpecialistMatch(String roleName, String productCategory)
	{
		for(RoleNameMapping__c rm : roleNameMapping)
		{
			if(productCategory == rm.Product_Category__c && rm.Role_Name__c == roleName )
				return true;
		}  
		
		return false;
	}
	
			public static Set<String> categories = new Set<String> {'CARBONLESS', 'COATED - ROLLS',
'COATED BOARD - ROLLS',
'COATED BOARD - SHEETS',
'COATED DOMESTIC - SHEETS',
'COATED IMPORT - SHEETS',
'ENVELOPES',
'IMAGING - CUT/SHEETS/ROLLS',
'OTHER PAPER',
'TCW',
'UNCOATED BOARD - CUT/SHEETS',
'UNCOATED BOARD - ROLLS',
'UNCOATED OFFSET - CUT/SHEETS',
'UNCOATED OFFSET - ROLLS',
'UNCOATED OPAQUE - CUT/SHEETS',
'CAN LINERS',
'CAN LINERS-PRIVATE BRAND',
'CHEMICALS',
'CHEMICALS-PRIVATE BRAND',
'EQUIPMENT-FACILITY SUPPLIES',
'EQUIPMENT-FACILITY SUPPLY-PRIVATE BRAND',
'FOOD SERVICE',
'OTHER SUPPLY',
'SANITARY MAINTENANCE',
'SANITARY MAINTENANCE-PRIVATE BRAND',
'TOWEL & TISSUE',
'TOWEL & TISSUE PRIVATE BRAND',
'UNCOATED OPAQUE - ROLLS',
'CORRUGATED',
'CUSHIONING',
'EQUIPMENT - PACKAGING',
'FOOD PACKAGING',
'OTHER PACKAGING',
'PACKAGES',
'PACKAGING MATERIALS',
'PARTS',
'SHRINK FILM',
'SPECIALTY FILM',
'STRETCH FILM',
'STRETCH FILM-PRIVATE BRAND',
'TAPES',
'TAPES-PRIVATE BRAND',
'TECHNICAL PLASTICS',
'3PL',
'KITTING',
'REVERSE LOGISTICS',
'INVENTORY MGT'};
	
}