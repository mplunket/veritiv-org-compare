/*
 Returns the sObjectName as referenced in the 'Work Order Sourcing Screenflow'
─────────────────────────────────────────────────────────────────────────────────────────────────
 @author         Adam Ross <adam.ross@veritivcorp.com>
 @modifiedBy     Adam Ross <adam.ross@veritivcorp.com>
 @version        1.0
 @created        2021-09-26
 @modified       2021-09-26
─────────────────────────────────────────────────────────────────────────────────────────────────
*/

global class GetObjectName {

 @InvocableMethod
 public static List<string> returnObjectName(List<string> recordIdStrings){
 // object Ids to return
 List<string> objectNames = new List<string>();
 // get record name
 Id recordId = Id.valueOf(recordIdStrings[0]);
 String objectName = recordId.getSobjectType().getDescribe().getName();
 // add object name to list
 objectNames.add(recordId.getSobjectType().getDescribe().getName());
 // return
 return objectNames;
 }
}