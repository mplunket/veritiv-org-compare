public class workOrderLineTriggerHandler{

    public static void beforeInsert(list<WorkOrderLineItem> newWOL){
        for (WorkOrderLineItem wol:newWOL){
            wol.Servicing_Division__c = sortServicingDivision(wol.Servicing_Division__c);
        }
    }
    
    public static void beforeUpdate(map<id,WorkOrderLineItem> newWOLMap, map<id,WorkOrderLineItem> oldWOLMap ){
        for (WorkOrderLineItem wol:newWOLMap.values()){
            wol.Servicing_Division__c = sortServicingDivision(wol.Servicing_Division__c);
        }
    }

    public static string sortServicingDivision(string servicingDivisionValues){
    
        //convert to list
        list<string> sdList = new list<string>();
        if (string.isblank(servicingDivisionValues)==false){
            sdList = servicingDivisionValues.split(',');
        }
        //add the codes to a string and map to values
        list<string> sdCode = new list <string>();
        map <string, string> sdCodeValueMap = new map <string, string>();
        
        for (string sdVal: sdList){
            //get code
            system.debug('value = '+sdVal);
            system.debug('length = '+sdVal.length());
            string code = '';
            
            if(sdVal.length()<=6){
                
                code = sdVal.right(5);
            }else{
                code = sdVal.right(4);
            }    
            system.debug('code = '+code);
            sdCodeValueMap.put(code,sdVal);
            sdCode.add(code);
        }
        //sort codes alphabetically
        sdCode.sort();
        
        string sortedSDVal='';
        for (string sdVal:sdCode){
            if(sdCodeValueMap.containskey(sdVal)){
                sortedSDVal+= sdCodeValueMap.get(sdVal) + ','; 
            }
        }
        //remove extra comma at the end
        sortedSDVal = sortedSDVal.removeEnd(',');
        return sortedSDVal;
    }

}