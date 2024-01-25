public class QuickPriceLookupController {

/* @AuraEnabled
 public static List < String > getselectOptions1(sObject objObject, string fld) {
  system.debug('objObject --->' + objObject);
  system.debug('fld --->' + fld);
  List < String > allOpts = new list < String > ();
  // Get the object type of the SObject.
  Schema.sObjectType objType = objObject.getSObjectType();
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  // Get the list of picklist values for this field.
  list < Schema.PicklistEntry > values =
   fieldMap.get(fld).getDescribe().getPickListValues();
 
  // Add these values to the selectoption list.
  for (Schema.PicklistEntry a: values) {
   allOpts.add(a.getValue());
  }
  system.debug('allOpts ---->' + allOpts);
  allOpts.sort();
  return allOpts;
 }*/
    
    
    @AuraEnabled
    public static account getCurAccData(string recId){
        system.debug('recId'+recId);
        account a = [select id,Legacy_Division_Desc__c,Legacy_System_Cd__c,Legacy_Division_Cd__c , AccountNumber ,Name  from account where id=:recId ];
        return a;
    }
   
    
     @AuraEnabled
    public static map<string,string> getPriceFromWebService(Account accRec, Product2 prodRec, string quom, string qty, string puom){
        system.debug('quom'+quom);
        System.debug('accRec'+accRec);
        System.debug('prodRec'+prodRec);
        string errAccId = 'Please fill the product Infomation';
        
        if( prodRec.Id == null){
            AuraHandledException ex = new AuraHandledException(errAccId);
            ex.setMessage(errAccId);
            throw ex;
        }
        
        PricingAndAvailability paa = new PricingAndAvailability();
        
        paa.Request.SystemIdentifier = prodRec.System_ID__c;
        paa.Request.DivisionID = prodRec.division_code__c;
        paa.Request.ShipToID = accRec.Ship_To_Number__c;
        paa.Request.CIFItemID = prodRec.ProductCode;
        if(qty !=null){
            paa.Request.Quantity = qty;
        }else{
        paa.Request.Quantity = '1';
        }
        if(quom != null){
            paa.Request.QuantityUOM = quom;
        }else{
            paa.Request.QuantityUOM = '1';
        }
         if(puom != null){
            paa.Request.PricingUOM = puom;
        }else{
            paa.Request.PricingUOM = prodRec.Pricing_Costing_UOM__c;
        }
        
       
        
        
        paa.Request.CustomerID = accRec.AccountNumber;

        return paa.getDataForGetPrice();
        //System.debug(paa.getData());
       // return paa;
       // 
       
      
    }
}