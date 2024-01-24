/**
*	Singleton class representing the role table. Call getInstance to access
*	the singleton instance.
*/
public class RoleMap
{
	private static RoleMap roleMapInstance;
	
	/*Map of all roles*/
	public Map<Id, UserRole> roleId2Role;
	
	private RoleMap()
	{
		updateRoleMap();
	}
	
	public static RoleMap getInstance()
	{
		if(roleMapInstance == null)
			roleMapInstance = new RoleMap();
		return roleMapInstance;
	}
	
	public Map<Id, UserRole> getRoleId2Role()
	{
		return roleId2Role;
	}
	
	/**
	*	Update roleId2Role from the database
	*/
	public void updateRoleMap()
	{
		roleId2Role = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
	}
}