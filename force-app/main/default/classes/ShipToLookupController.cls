public class ShipToLookupController {

	public Target target {get; set;}
	public List<SelectOption> shipTos {get; set;}
	public Id shipToId {get; set;}

	public Boolean showShipTos {get {return (shipTos.isEmpty()) ? false : true;} set;}

	public ShipToLookupController() {

		Map<String,String> params = ApexPages.currentPage().getParameters();
		Id recordId = params.get('id');
		Id accountId = (params.containsKey('accountId') && params.get('accountId') != '') ? params.get('accountId') : null;
		String objectType = params.get('type');
		String name = params.get('name');
		String accountName = params.get('accountName');
		target = new Target(recordId, accountId, objectType, name, accountName);
		shipTos = target.queryShipTos();
	}

	public PageReference saveShipTo()
	{
		if(shipToId == null)
		{
			if(target.objectType == 'Case' || target.objectType == 'Contact')
			{
				target.saveShipTo( shipToId );
				return new PageReference('/' + target.recordId);
			}

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You need to select a Ship To in order to save.'));
			return null;
		}
		else
		{
			target.saveShipTo(shipToId);
			return new PageReference('/' + target.recordId);
		}
	}

	public PageReference cancel()
	{
		return new PageReference('/' + target.recordId);
	}

	public class Target {
		public Id recordId {get; set;}
		public Id accountId {get; set;}
		public String objectType {get; set;}
		public String name {get; set;}
		public String accountName {get; set;}

		public Target(Id recordId, Id accountId, String objectType, String name, String accountName) {
			this.recordId = recordId;
			this.accountId = accountId;
			this.objectType = objectType;
			this.name = name;
			this.accountName = accountName;
		}

		public List<SelectOption> queryShipTos()
		{
	        List<SelectOption> shipTos = new List<SelectOption>();
	        for(Ship_To__c shipToAccount : [select State__c, Ship_To_Code__c, Postal_Code__c, Name, Id, City__c, Address_Line2__c, Address_Line1__c
	                                        from Ship_To__c
	                                        where Bill_To_Account__c = :this.accountId
	                                        and Active__c = 'Yes'
	                                        order by Ship_To_Code__c
	                                        limit 999])
	        {
	            String curShipToAddress = '';
	            if(shipToAccount.Ship_To_Code__c != null && shipToAccount.Ship_To_Code__c.length() >= 12 )
	            	curShipToAddress = shipToAccount.Ship_To_Code__c.length() == 12 ? shipToAccount.Ship_To_Code__c.substring(6) + ' - ' : shipToAccount.Ship_To_Code__c.substring(10) + ' - ';

	            curShipToAddress += shipToAccount.Name != null? shipToAccount.Name: '';
	            curShipToAddress += shipToAccount.Address_Line1__c != null? '\n' + shipToAccount.Address_Line1__c: '';
	            curShipToAddress += shipToAccount.Address_Line2__c != null? '\n' + shipToAccount.Address_Line2__c: '';
	            curShipToAddress += shipToAccount.City__c != null? '\n' + shipToAccount.City__c: '';
	            curShipToAddress += shipToAccount.State__c != null? ', ' + shipToAccount.State__c: '';
	            curShipToAddress += shipToAccount.Postal_Code__c != null? ', ' + shipToAccount.Postal_Code__c: '';
	            shipTos.add(new SelectOption(shipToAccount.Id, curShipToAddress));
	        }

	        if(!shipTos.isEmpty())
	        	shipTos.add( 0, new SelectOption( '', 'None' ) );
	        else
	        	shipTos.add( new SelectOption( '', 'None' ) );

	        return shipTos;
		}

		public void saveShipTo(Id shipToId)
		{
			if(objectType == 'Contact')
			{
				Contact c = new Contact(Id = recordId, Ship_To__c = shipToId);
				update c;
			}
			else if(objectType == 'Case')
			{
				Case c = new Case(Id = recordId, ShipToAccount__c = shipToId);
				update c;
			}
			else if(objectType == 'Quote')
			{
				Quote__c q = new Quote__c(Id = recordId, Ship_To__c = shipToId);
				update q;
			}
		}
	}
}