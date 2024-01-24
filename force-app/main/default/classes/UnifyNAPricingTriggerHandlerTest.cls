@isTest
public class UnifyNAPricingTriggerHandlerTest {
    
    @isTest
    public static void testMethod1(){
        NationalAccountsPricing__c nAP = new NationalAccountsPricing__c();
        nAp.name = 'test';
        nAp.NationalAccountPricingId__c ='abc';
        insert nAP; 
        
        List<Unify_National_Accounts_Pricing__c> objList = new List<Unify_National_Accounts_Pricing__c>();
        
        Unify_National_Accounts_Pricing__c obj = new Unify_National_Accounts_Pricing__c();
        obj.Name = 'test';
        obj.Unify_NA_AlternatePrice__c = 1.1;
        obj.Unify_NA_Item_CompositeKey__c = 'test'; 
        obj.Unify_NA_Contract_Group_ID__c = 't123';
        obj.Unify_NA_Division__c = 'cu';
        obj.Unify_NA_Vendor_Part_Number__c = 'test';
        obj.Unify_NA_Class__c = 'Cl';
        obj.Unify_NA_Brand__c = 'B';
        obj.Unify_NA_Sets__c = 's';
        obj.Unify_NA_SubSets__c = 'su';
        obj.Unify_NA_ShortItem__c = 'st';
        obj.Unify_NA_PricingType__c = '1';
        obj.Unify_NA_Price__c= 10;
        obj.Unify_NA_AlternatePrice__c = 10;
        obj.Unify_NA_BreakQuantity__c = 12;
        obj.Unify_NA_QuantityBreakUnit__c = '15';
        obj.Unify_NA_Break1Quantity__c = 11;
        obj.Unify_NA_Break1Price__c= 12;
        obj.Unify_NA_Break2Quantity__c =12;
        obj.Unify_NA_Break2Price__c=12; 
        obj.Unify_NA_Break3Quantity__c=12;
        obj.Unify_NA_Break3Price__c=12;
        obj.Unify_NA_Break4Quantity__c=12;
        obj.Unify_NA_Break4Price__c=12;
        obj.Unify_NA_Break5Quantity__c=12;
        obj.Unify_NA_Break5Price__c=12;
        obj.Unify_NA_PriceUnit__c='12';
        obj.Unify_NA_DateBegin__c = 'dat';
        obj.Unify_NA_DateEnd__c = 'enddate';
        obj.Unify_NA_CustSKU__c = '1224etst';
        obj.Unify_NA_OrderType__c = 'te';
        obj.Unify_NA_QtyBreakFlag__c = 'y';
        obj.Unify_NAP_ActionCd__c ='A';
        obj.Unify_NA_ItemDescription__c = 'test';
        obj.Unify_NA_National_Account_Pricing_ID__c = 'abc';
        
        objList.add(obj);
        
        Unify_National_Accounts_Pricing__c obj1 = new Unify_National_Accounts_Pricing__c();
        obj1.Name = 'test1';
        obj1.Unify_NA_AlternatePrice__c = 1.1;
        obj1.Unify_NA_Item_CompositeKey__c = 'test'; 
        obj1.Unify_NA_Contract_Group_ID__c = 't123';
        obj1.Unify_NA_Division__c = 'cu';
        obj1.Unify_NA_Vendor_Part_Number__c = 'test';
        obj1.Unify_NA_Class__c = 'Cl';
        obj1.Unify_NA_Brand__c = 'B';
        obj1.Unify_NA_Sets__c = 's';
        obj1.Unify_NA_SubSets__c = 'su';
        obj1.Unify_NA_ShortItem__c = 'st';
        obj1.Unify_NA_PricingType__c = '1';
        obj1.Unify_NA_Price__c= 10;
        obj1.Unify_NA_AlternatePrice__c = 10;
        obj1.Unify_NA_BreakQuantity__c = 12;
        obj1.Unify_NA_QuantityBreakUnit__c = '15';
        obj1.Unify_NA_Break1Quantity__c = 11;
        obj1.Unify_NA_Break1Price__c= 12;
        obj1.Unify_NA_Break2Quantity__c =12;
        obj1.Unify_NA_Break2Price__c=12; 
        obj1.Unify_NA_Break3Quantity__c=12;
        obj1.Unify_NA_Break3Price__c=12;
        obj1.Unify_NA_Break4Quantity__c=12;
        obj1.Unify_NA_Break4Price__c=12;
        obj1.Unify_NA_Break5Quantity__c=12;
        obj1.Unify_NA_Break5Price__c=12;
        obj1.Unify_NA_PriceUnit__c='12';
        obj1.Unify_NA_DateBegin__c = 'dat';
        obj1.Unify_NA_DateEnd__c = 'enddate';
        obj1.Unify_NA_CustSKU__c = '1224etst';
        obj1.Unify_NA_OrderType__c = 'te';
        obj1.Unify_NA_QtyBreakFlag__c = 'y';
        obj1.Unify_NAP_ActionCd__c ='A';
        obj1.Unify_NA_ItemDescription__c = 'test';
        obj1.Unify_NA_National_Account_Pricing_ID__c = 'abcd';
        
        objList.add(obj1);
        
        Unify_National_Accounts_Pricing__c obj2 = new Unify_National_Accounts_Pricing__c();
        obj2.Name = 'test';
        obj2.Unify_NA_AlternatePrice__c = 1.1;
        obj2.Unify_NA_Item_CompositeKey__c = 'test'; 
        obj2.Unify_NA_Contract_Group_ID__c = 't123';
        obj2.Unify_NA_Division__c = 'cu';
        obj2.Unify_NA_Vendor_Part_Number__c = 'test';
        obj2.Unify_NA_Class__c = 'Cl';
        obj2.Unify_NA_Brand__c = 'B';
        obj2.Unify_NA_Sets__c = 's';
        obj2.Unify_NA_SubSets__c = 'su';
        obj2.Unify_NA_ShortItem__c = 'st';
        obj2.Unify_NA_PricingType__c = '1';
        obj2.Unify_NA_Price__c= 10;
        obj2.Unify_NA_AlternatePrice__c = 10;
        obj2.Unify_NA_BreakQuantity__c = 12;
        obj2.Unify_NA_QuantityBreakUnit__c = '15';
        obj2.Unify_NA_Break1Quantity__c = 11;
        obj2.Unify_NA_Break1Price__c= 12;
        obj2.Unify_NA_Break2Quantity__c =12;
        obj2.Unify_NA_Break2Price__c=12; 
        obj2.Unify_NA_Break3Quantity__c=12;
        obj2.Unify_NA_Break3Price__c=12;
        obj2.Unify_NA_Break4Quantity__c=12;
        obj2.Unify_NA_Break4Price__c=12;
        obj2.Unify_NA_Break5Quantity__c=12;
        obj2.Unify_NA_Break5Price__c=12;
        obj2.Unify_NA_PriceUnit__c='12';
        obj2.Unify_NA_DateBegin__c = 'dat';
        obj2.Unify_NA_DateEnd__c = 'enddate';
        obj2.Unify_NA_CustSKU__c = '1224etst';
        obj2.Unify_NA_OrderType__c = 'te';
        obj2.Unify_NA_QtyBreakFlag__c = 'y';
        obj2.Unify_NAP_ActionCd__c ='A';
        obj2.Unify_NA_ItemDescription__c = 'test';
        obj2.Unify_NA_National_Account_Pricing_ID__c = 'abcde';
         
        objList.add(obj2);
        
        insert objList;

        Unify_National_Accounts_Pricing__c obj3 = new Unify_National_Accounts_Pricing__c();
        obj3.Name = 'test';
        obj3.Unify_NA_AlternatePrice__c = 1.1;
        obj3.Unify_NA_Item_CompositeKey__c = 'test'; 
        obj3.Unify_NA_Contract_Group_ID__c = 't123';
        obj3.Unify_NA_Division__c = 'cu';
        obj3.Unify_NA_Vendor_Part_Number__c = 'test';
        obj3.Unify_NA_Class__c = 'Cl';
        obj3.Unify_NA_Brand__c = 'B';
        obj3.Unify_NA_Sets__c = 's';
        obj3.Unify_NA_SubSets__c = 'su';
        obj3.Unify_NA_ShortItem__c = 'st';
        obj3.Unify_NA_PricingType__c = '1';
        obj3.Unify_NA_Price__c= 10;
        obj3.Unify_NA_AlternatePrice__c = 10;
        obj3.Unify_NA_BreakQuantity__c = 12;
        obj3.Unify_NA_QuantityBreakUnit__c = '15';
        obj3.Unify_NA_Break1Quantity__c = 11;
        obj3.Unify_NA_Break1Price__c= 12;
        obj3.Unify_NA_Break2Quantity__c =12;
        obj3.Unify_NA_Break2Price__c=12; 
        obj3.Unify_NA_Break3Quantity__c=12;
        obj3.Unify_NA_Break3Price__c=12;
        obj3.Unify_NA_Break4Quantity__c=12;
        obj3.Unify_NA_Break4Price__c=12;
        obj3.Unify_NA_Break5Quantity__c=12;
        obj3.Unify_NA_Break5Price__c=12;
        obj3.Unify_NA_PriceUnit__c='12';
        obj3.Unify_NA_DateBegin__c = 'dat';
        obj3.Unify_NA_DateEnd__c = 'enddate';
        obj3.Unify_NA_CustSKU__c = '1224etst';
        obj3.Unify_NA_OrderType__c = 'te';
        obj3.Unify_NA_QtyBreakFlag__c = 'y';
        obj3.Unify_NAP_ActionCd__c ='A';
        obj3.Unify_NA_ItemDescription__c = 'test';
        obj3.Unify_NA_National_Account_Pricing_ID__c = 'abcefg';
        
        insert obj3;
    }
    
}