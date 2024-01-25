@isTest
public class workOrderLineTriggerHandlerTest {

    static testmethod void testmethod1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sourcing - Lightning']; 
        UserRole r = new UserRole(DeveloperName = 'FS_CATEGORY_MGMT_Leaderstest', Name = 'FS - CATEGORY MGMT - Leaders');
        insert r;
        User u = new User(Alias = 't74vdt', Email='sttesdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='standartes536r@tigorg.com',userRoleId = r.id,Network_Id__c ='t74vdt' );
        
        insert u;
        
        User u1= new User(Alias = 't7uydt', Email='sttkjhdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='stdjhgvartes536r@tigorg.com',Network_Id__c ='t7uydt' );
        
        insert u1;
        
        system.runAs(u){
            
            Primary_Sales_Rep__c aPSR = new Primary_Sales_Rep__c();
          
                aPSR.Name = 'testingPSR';
                aPSR.Network_ID__c = 't74vdt';
            aPSR.Email__c = 'test@testing.com';
            insert aPSR;
          
             Account acc1 = new Account ();
            acc1.Name = 'test23';
           // acc1.email
            //acc1.Primary_Sales_Rep_Email__c = 'test23@testing.com';
            insert acc1;
            
            Account acc = new Account ();
            acc.Name = 'test';
            acc.Primary_Sales_Rep_Name__c= aPSR.id;
           // acc.Primary_Sales_Rep_Email__c = 'test@testing.com';
           // acc.Primary_Sales_Rep_Name__c = acc1.id;
           insert acc;
            
            workorder  wo = new workorder();
            wo.Type_of_Maintenance__c = 'Alternate Source Add';
            wo.AccountId = acc.id;
            wo.WO_Submitted_By__c = u.id;
            wo.Type_of_Request__c = 'General Quote';
            insert wo;
            workorder  wo1 = new workorder();
            wo1.Type_of_Request__c = 'Cost Update';
            wo1.Type_of_Maintenance__c = 'Forced Substitute';
            wo1.AccountId = acc.id;
            wo1.WO_Submitted_By__c = u1.id;
            insert wo1;
            
            WorkOrderLineItem wOL = new WorkOrderLineItem();
            wol.WorkOrderId = wo.id;            
            wol.Servicing_Division__c = 'NE OMAHA - MA03, MO ST LOUIS/FENTON - MA06, All, MO COLUMBIA - MA08, MO JOPLIN - MA16, ND FARGO - MA35, MN MINNEAPOLIS/BROOKLYN PARK - MA38,MI DETROIT/ANNEX - MA73, MI PORT HURON - MA74, MI DETROIT/ROCHESTER HILL - MA75, MI GRAND RAPIDS/KENTWOOD - MA89, NJ BURLINGTON - NU47, NJ NEWARK/CLIFTON - NU55, NY BUFFALO/DEPEW - NU57, NY SYRACUSE - NU58, NV RENO/SPARKS - PC39, NV LAS VEGAS - PC45, NM ALBUQUERQUE - PC55, MT BILLINGS - PC71, NC CHARLOTTE - SW32, NC RALEIGH/GARNER - SW36, VOSSW';
            insert wol;
            
            wol.Servicing_Division__c = 'VOSSW, NE OMAHA - MA03, MO ST LOUIS/FENTON - MA06, All, MO COLUMBIA - MA08, MO JOPLIN - MA16, ND FARGO - MA35, MN MINNEAPOLIS/BROOKLYN PARK - MA38,MI DETROIT/ANNEX - MA73, MI PORT HURON - MA74, MI DETROIT/ROCHESTER HILL - MA75, MI GRAND RAPIDS/KENTWOOD - MA89, NJ BURLINGTON - NU47, NJ NEWARK/CLIFTON - NU55, NY BUFFALO/DEPEW - NU57, NY SYRACUSE - NU58, NV RENO/SPARKS - PC39, NV LAS VEGAS - PC45, NM ALBUQUERQUE - PC55, MT BILLINGS - PC71, NC CHARLOTTE - SW32, NC RALEIGH/GARNER - SW36';
            update wol;
        }
        
    }
    
}