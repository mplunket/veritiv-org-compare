public class batchTouch implements Database.Batchable<sObject>{ 
   private String query;
    
   public batchTouch(String objectName){
       this.query = 'SELECT Id FROM ' + objectName;
   }
   
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
   public void execute(Database.BatchableContext info, List<Contract> scope){
       update scope; 
   }     
   
    public void finish(Database.BatchableContext info){     
   } 
}