/**
 Objective: Template class that outlines the services provided by Search
 Developer: Hiremath, Naveen - Bluewolf     
*/

/**
 Class formerly named Search. Renamed due to default Salesforce "Search" object
*/
public interface SearchInterface {
    
    /**
     All the logic that needs to be implemented 
     on invoking non-wild card based search 
    */
    void exact();   
    
    /**
     All the logic that needs to be implemented 
     on invoking a wild card based search 
    */
    void wild();
    
    /**
     Indicates the (non)availability of search results 
    */
    Boolean matches();
    
    /**
     Provides the number of search matches
    */
    Integer count(); 
    
    /**
     Contract to clear the search results
    */
    void clear();
    
}