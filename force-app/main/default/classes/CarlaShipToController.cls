public class CarlaShipToController {
public String searchText;
public String selectedShipToId {get; set;}
public String objectType;
public String accountNumber;
public Id recordId;
public Id accountId;

List<Ship_To__c> results;

public Boolean calledFromQuoteScreen = true;

public Quote__c currentQuote {get; set;}
public List<shipToWrapper> shipToMatches {get; set;} 
public ShipToWrapper noneOptionShipToWrapper{get; set;}

public ShipToWrapper selectedShipToWrapper {
        get{
                if (selectedShipToWrapper == null)
                {
                    selectedShipToWrapper = new shipToWrapper();
                        
                    for(shipToWrapper sw : shipToMatches)
                    {
                        if(sw.selected)
                        {
                            selectedShipToWrapper = sw;
                        }
                    }
                }
                return selectedShipToWrapper;   
        }       
        set;
        
}
/*
	Called from the Quote Screen
*/
public CarlaShipToController( ApexPages.StandardController stdController )
{
        currentQuote = (Quote__c) stdController.getRecord();
        shipToMatches = new List<shipToWrapper>();
        
        noneOptionShipToWrapper = new ShipToWrapper ();
        noneOptionShipToWrapper.shipTo.Name = 'None';
        shipToMatches.add(noneOptionShipToWrapper);
        searchText ='';
        doSearch();
}

/*
  Called from the Case and Contact Screen
*/
public CarlaShipToController()
{
        calledFromQuoteScreen = false;
        
        /*
        	Lets bring over the parameters
        */
        Map<String,String> params = ApexPages.currentPage().getParameters();
		recordId = params.get('recordId');
		accountId = (params.containsKey('accountId') && params.get('accountId') != '') ? params.get('accountId') : null;
		objectType = params.get('type');
		String name = params.get('name');
		accountNumber = params.get('accountNumber');
		String accountName = params.get('accountName');
        
        shipToMatches = new List<shipToWrapper>();
        
        noneOptionShipToWrapper = new ShipToWrapper ();
        noneOptionShipToWrapper.shipTo.Name = 'None';
        shipToMatches.add(noneOptionShipToWrapper);
        
        searchText ='';
        doSearch();
        
}

public String getSearchText () {
return searchText;
}
public void setSearchText (String s) {
searchText = s;
}
public List<shipToWrapper> getResults() {
return shipToMatches;
}
public PageReference doSearch() {

shipToMatches.clear();
shipToMatches.add (noneOptionShipToWrapper);
//Wrap the variable search term in percents 

//if (searchText==null||searchText=='')
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Search Term'));

Id searchAccountId = calledFromQuoteScreen ? currentQuote.Account__c : accountId;
String searchAccountNumber = calledFromQuoteScreen ? currentQuote.Account__r.AccountNumber : accountNumber;

String searchCriteria = '%'+searchtext+'%';

   if(searchText=='')
   {
	//Show all results if a search term has not been specified, called on page load
   results = [SELECT ID, Name, Bill_To_Number__c,
                                  Address_Line1__c, Address_Line2__c, Legacy_Division_Desc__c,
                                  City__c, State__c, Postal_Code__c, Ship_To_Code__c, Account_Owner__c
                   FROM Ship_To__c
                   WHERE Bill_To_Account__c = :searchAccountId
                   AND ( Ship_To_Code__c != :searchAccountNumber )
                   AND Active__c = 'Yes'
                   ORDER BY Ship_To_Code__c 
                   LIMIT 999];
   }else {
        
//SOQL
//12/182019 BAcklog#1797 Updated to display Servicing Div and Account owner(Ship to PSR)
results = [SELECT ID, Name, Bill_To_Number__c,
                                  Address_Line1__c, Address_Line2__c, Legacy_Division_Desc__c,
                                  City__c, State__c, Postal_Code__c, Ship_To_Code__c, Account_Owner__c
                   FROM Ship_To__c
                   WHERE Bill_To_Account__c = :searchAccountId
                   AND ( Ship_To_Code__c != :searchAccountNumber )
                   AND Active__c = 'Yes'
                   AND (Name like : searchCriteria 
                            OR Bill_To_Number__c like :searchCriteria
                            OR Ship_To_Code__c like :searchCriteria
                            OR Address_Line1__c like :searchCriteria
                            OR Address_Line2__c like :searchCriteria
                            OR City__c like :searchCriteria
                            OR State__c like :searchCriteria
                            OR Postal_Code__c like :searchCriteria) 
                  ORDER BY Ship_To_Code__c 
                  LIMIT 999 ];

   }
for( Ship_To__c resultFound : results)
        shipToMatches.add(new shipToWrapper( resultFound ));

return null;
}

 public PageReference saveShipToAddress()
    {
       if( !calledFromQuoteScreen )
       	return saveContactOrCase();
       
       //Get address
        String shipToAddress = '';
        
            if( selectedShipToWrapper.shipTo.Id != null)
            {
                try
                {
                       Integer.valueOf(selectedShipToWrapper.getAddress().substring(0, 6));
                }
                catch(Exception e)
                {
                        shipToAddress = selectedShipToWrapper.getAddress().substring(3);
                }
                shipToAddress = selectedShipToWrapper.getAddress().substring(9);
            }

         Savepoint sp = Database.setSavepoint();


        try
        {
            Quote__c quoteToUpdate = new Quote__c(Id=currentQuote.Id,
                                                  Ship_To_Address__c=shipToAddress);
                                                                                  

            // if the ship to is to be nulled, the primary sales rep comes from the quote's account
            if( selectedShipToWrapper.shipTo.Id == null )
            {
                quoteToUpdate.Ship_To__c = null;
            
                List<Account> quoteAccount = [ SELECT Id, Primary_Sales_Rep_Name__c 
                                                                           FROM Account 
                                                                           WHERE Id = :currentQuote.Account__c 
                                                                           LIMIT 1 ];
                if( !quoteAccount.isEmpty() )
                {
                        quoteToUpdate.Primary_Sales_Rep__c = quoteAccount[0].Primary_Sales_Rep_Name__c;
                }
            }
                        // otherwise pull the primary sales rep from the ship to itself
            else
            {
                quoteToUpdate.Ship_To__c = selectedShipToWrapper.shipTo.Id;
                List<Primary_Sales_Rep__c> primarySalesRep = [ SELECT Id 
                                                               FROM Primary_Sales_Rep__c 
                                                               WHERE sf_userid__c = :selectedShipToWrapper.shipTo.Account_Owner__c 
                                                               LIMIT 1 ];
                if( !primarySalesRep.isEmpty() )
                {
                        quoteToUpdate.Primary_Sales_Rep__c = primarySalesRep[0].Id;
                }
            }
            update quoteToUpdate;
        }
        catch(DmlException dmle)
        {
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));

            Database.rollback(sp);
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }

        return new pageReference ('/'+currentQuote.Id);
        
    }

public PageReference saveContactOrCase()
{
	Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectType);
	SObject testObject = targetType.newSObject(recordId);
	
	if( objectType == 'Case' )
		testObject.put('ShipToAccount__c', selectedShipToWrapper.shipTo.Id);
	else if( objectType == 'Contact')
		testObject.put('Ship_To__c', selectedShipToWrapper.shipTo.Id);
	
	try{
		database.update (testObject);
	}
	catch(DmlException dmle)
    {
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));

            return null;
    }	
    
    return new pageReference ('/'+recordId);
}
   
public class shipToWrapper
{
        public Ship_To__c shipTo {get; set;}
        public Boolean selected {get; set;}
        
        public shipToWrapper(){
        
                this.shipTo = new Ship_To__c();
                this.selected = false;
        
        }
        
        public shipToWrapper( Ship_To__c shipTo )
        {
                this.shipTo = shipTo;
                this.selected = false;
        }

        public String getAddress ()
        {
                         
                        String curShipToAddress = '';
            if(shipTo.Ship_To_Code__c != null && shipTo.Ship_To_Code__c.length() >= 12 )
                        curShipToAddress = shipTo.Ship_To_Code__c.length() == 12 ? shipTo.Ship_To_Code__c.substring(6) + ' - ' : shipTo.Ship_To_Code__c.substring(10) + ' - ';
           
            curShipToAddress += shipTo.Name != null? shipTo.Name: '';
            curShipToAddress += shipTo.Address_Line1__c != null? '\n' + shipTo.Address_Line1__c: '';
            curShipToAddress += shipTo.Address_Line2__c != null? '\n' + shipTo.Address_Line2__c: '';
            curShipToAddress += shipTo.City__c != null? '\n' + shipTo.City__c: '';
            curShipToAddress += shipTo.State__c != null? ', ' + shipTo.State__c: '';
            curShipToAddress += shipTo.Postal_Code__c != null? ', ' + shipTo.Postal_Code__c: '';
            
            return curShipToAddress;
        }
        
        
}
}