@isTest
public class UnifyNationalAccountTriggerHandlerTest {
    
    @isTest
    public static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Account acc1  = new Account();
        acc1.name = 'testing';
        acc1.ParentId = acc.Id;
        acc1.Account_DW_Key__c = '123';
        acc1.Unify_Account_Type__c = 'N';
        Insert acc1;
        
        
        Unify_National_Account__C unA = new Unify_National_Account__C();
        uNa.name = 'test';
        uNa.Unify_NA_Account_DW_Key__c = '123';
        //uNa.Unify_NA_Parent_Name__c = 'test';
        uNa.Unify_NA_ActionCd__c = 'A';
        uNa.Unify_NA_Bill_To_Number__c = '123';
        uNa.Unify_NA_Legacy_System_Cd__c = 'atest';
        uNa.Unify_NA_Account_Type__c = 'N';
        uNa.Unify_NA_Account_Type_code_Definition__c ='qwe';
        uNa.Unify_NA_Service_TypeCd__c='test';
        //uNa.Unify_NA_ActionCd__c = 'wer';
       // uNa.Unify_NA_Parent_Name__c='test';
        uNa.Unify_NA_Segment__c = 'F = Fine Paper';
        uNa.Unify_NA_Account_Number__c=123;
        uNa.Unify_NA_CustAcctTypeDesc__c = 'test';
        uNa.Unify_NA_UniqueID__c = '123';
        insert uNa;
        
         
        Unify_National_Account__C unA1 = new Unify_National_Account__C();
        unA1.name = 'test';
        unA1.Unify_NA_Account_DW_Key__c = '123';
        //uNa.Unify_NA_Parent_Name__c = 'test';
        unA1.Unify_NA_ActionCd__c = 'D';
        unA1.Unify_NA_Bill_To_Number__c = '123';
        unA1.Unify_NA_Legacy_System_Cd__c = 'atest';
        unA1.Unify_NA_Account_Type__c = 'N';
        unA1.Unify_NA_Account_Type_code_Definition__c ='qwe';
        unA1.Unify_NA_Service_TypeCd__c='test';
        //uNa.Unify_NA_ActionCd__c = 'wer';
       // uNa.Unify_NA_Parent_Name__c='test';
        unA1.Unify_NA_Segment__c = 'F = Fine Paper';
        unA1.Unify_NA_Account_Number__c=123;
        unA1.Unify_NA_CustAcctTypeDesc__c = 'test';
        unA1.Unify_NA_UniqueID__c = '123';
        insert unA1;
        
    }
}