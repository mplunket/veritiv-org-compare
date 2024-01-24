public class UnifyNAPricingTriggerHandler {
    
    public static void afterInsert(List<Unify_National_Accounts_Pricing__c> newList){
        set<string> uniqIds = new set<String>();
        Map<String, Unify_National_Accounts_Pricing__c> keyVsNationalPricing = new Map<String, Unify_National_Accounts_Pricing__c>();
        for(Unify_National_Accounts_Pricing__c uNA: newList){
            uniqIds.add(uNA.Unify_NA_National_Account_Pricing_ID__c);
            keyVsNationalPricing.put(uNA.Unify_NA_National_Account_Pricing_ID__c,uNA);
        }
        
        if(keyVsNationalPricing.keyset().size() > 0){
            List<NationalAccountsPricing__c> nationalAccPricing = new List<NationalAccountsPricing__c>();
            List<NationalAccountsPricing__c> listToUpdate = new List<NationalAccountsPricing__c>();
            
            nationalAccPricing = [SELECT Id, Name,
                                  CompositeKey__c,
                                  NationalAccountGroupID__c,
                                  Division__c,
                                  Vendor__c,
                                  Class__c,
                                  Brand__c,
                                  Set__c,
                                  Subset__c,
                                  PricingType__c,
                                  Price__c,
                                  AlternatePrice__c,
                                  QuantityBreak__c,
                                  QuantityBreakUnit__c,
                                  Break1Quantity__c,
                                  Break1Price__c,
                                  Break2Quantity__c,
                                  Break2Price__c,
                                  Break3Quantity__c,
                                  Break3Price__c,
                                  Break4Quantity__c,
                                  Break4Price__c,
                                  Break5Quantity__c,
                                  Break5Price__c,
                                  PriceUnit__c,
                                  DateBegin__c,
                                  DateEnd__c,
                                  CustomerSku__c,
                                  OrderType__c,
                                  QtyBreakFlag__c,
                                  Action__C,
                                  Description__c,
                                  NationalAccountPricingId__c	FROM NationalAccountsPricing__c where NationalAccountPricingId__c in: keyVsNationalPricing.keyset()];
            
            system.debug('nationalAccPricing'+nationalAccPricing);
            List<NationalAccountsPricing__c> nationalAccPriceToDelete = new List<NationalAccountsPricing__c>();
            if(nationalAccPricing.size() > 0){
                for(NationalAccountsPricing__c nAP: nationalAccPricing){
                    
                    uniqIds.remove(nAP.NationalAccountPricingId__c);
                    
                   
                    if((keyVsNationalPricing.get(nAP.NationalAccountPricingId__c).Unify_NAP_ActionCd__c == 'A' ||
                       keyVsNationalPricing.get(nAP.NationalAccountPricingId__c).Unify_NAP_ActionCd__c == null ||
                        keyVsNationalPricing.get(nAP.NationalAccountPricingId__c).Unify_NAP_ActionCd__c == ''
                       )&& keyVsNationalPricing.get(nAP.NationalAccountPricingId__c).Unify_NA_Contract_Group_ID__c  != '' ){
                         
                        
                        system.debug('inside A or blank');
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Item_CompositeKey__c != null){
                            nAP.CompositeKey__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Item_CompositeKey__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Contract_Group_ID__c != null){
                            nAP.NationalAccountGroupID__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Contract_Group_ID__c;
                            
                        } 
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Division__c != null){
                            nAP.Division__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Division__c;
                        }
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Vendor_Part_Number__c != null){
                            nAP.Vendor__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Vendor_Part_Number__c;
                        }
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Class__c != null){
                            nAP.Class__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Class__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Brand__c != null){
                            nAP.Brand__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Brand__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Sets__c != null){
                            nAP.Set__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Sets__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_SubSets__c != null){
                            nAP.Subset__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_SubSets__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_ShortItem__c != null){
                            nAP.Name= keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_ShortItem__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_PricingType__c != null){
                            nAP.PricingType__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_PricingType__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Price__c != null){
                            nAP.Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Price__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_AlternatePrice__c != null){
                            nAP.AlternatePrice__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_AlternatePrice__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_BreakQuantity__c != null){
                            nAP.QuantityBreak__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_BreakQuantity__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_QuantityBreakUnit__c != null){
                            nAP.QuantityBreakUnit__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_QuantityBreakUnit__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break1Quantity__c != null){
                            nAP.Break1Quantity__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break1Quantity__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break1Price__c != null){
                            nAP.Break1Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break1Price__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break2Quantity__c != null){
                            nAP.Break2Quantity__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break2Quantity__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break2Price__c != null){
                            nAP.Break2Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break2Price__c;
                        }
                        
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break3Quantity__c != null){
                            nAP.Break3Quantity__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break3Quantity__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break3Price__c != null){
                            nAP.Break3Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break3Price__c;
                        }
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break4Quantity__c != null){
                            nAP.Break4Quantity__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break4Quantity__c;
                        }
                        
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break4Price__c != null){
                            nAP.Break4Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break4Price__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break5Quantity__c != null){
                            nAP.Break5Quantity__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break5Quantity__c;
                        }
                        
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break5Price__c != null){
                            nAP.Break5Price__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_Break5Price__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_PriceUnit__c != null){
                            nAP.PriceUnit__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_PriceUnit__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_DateBegin__c != null){
                            nAP.DateBegin__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_DateBegin__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_DateEnd__c != null){
                            nAP.DateEnd__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_DateEnd__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_CustSKU__c != null){
                            nAP.CustomerSku__c  = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_CustSKU__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_OrderType__c != null){
                            nAP.OrderType__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_OrderType__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_QtyBreakFlag__c != null){
                            nAP.QtyBreakFlag__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_QtyBreakFlag__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NAP_ActionCd__c != null){
                            nAP.Action__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NAP_ActionCd__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_ItemDescription__c != null){
                            nAP.Description__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_ItemDescription__c;
                        }
                        
                        if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_National_Account_Pricing_ID__c != null){
                            nAP.NationalAccountPricingId__c = keyVsNationalPricing.get(nAP.NationalAccountPricingId__c ).Unify_NA_National_Account_Pricing_ID__c;
                        }
                        listToUpdate.add(nAP);
                    }
                    
                    
                    if(keyVsNationalPricing.get(nAP.NationalAccountPricingId__c).Unify_NAP_ActionCd__c == 'D'){
                        nationalAccPriceToDelete.add(nAP);
                        
                        
                    }
                    
                }
                
                //Delete the records with action D
                if(nationalAccPriceToDelete.size() > 0){
                    delete nationalAccPriceToDelete;
                }
                //End of logic to delete the record with action D
                if( listToUpdate.size() > 0){
                    system.debug('update acc A');
                    update listToUpdate;
                }
                
                
                // Insert the record if doesnt find with unique key
                if(uniqIds.size() > 0){
                    system.debug('inside uniqs');
                    List<NationalAccountsPricing__c> insertNap = new List<NationalAccountsPricing__c>();
                    for(string uniq : keyVsNationalPricing.keySet()){
                        if(uniqIds.contains(uniq)){
                            
                            system.debug('contains uniq');
                            NationalAccountsPricing__c obj = new NationalAccountsPricing__c();
                            obj.Name = keyVsNationalPricing.get(uniq).Unify_NA_ShortItem__c;
                            obj.CompositeKey__c = keyVsNationalPricing.get(uniq).Unify_NA_Item_CompositeKey__c;
                            obj.NationalAccountGroupID__c = keyVsNationalPricing.get(uniq).Unify_NA_Contract_Group_ID__c;
                            obj.Division__c = keyVsNationalPricing.get(uniq).Unify_NA_Division__c;
                            obj.Vendor__c = keyVsNationalPricing.get(uniq).Unify_NA_Vendor_Part_Number__c;
                            obj.Class__c = keyVsNationalPricing.get(uniq).Unify_NA_Class__c;
                            obj.Brand__c = keyVsNationalPricing.get(uniq).Unify_NA_Brand__c;
                            obj.Set__c = keyVsNationalPricing.get(uniq).Unify_NA_Sets__c;
                            obj.Subset__c = keyVsNationalPricing.get(uniq).Unify_NA_SubSets__c;
                            obj.PricingType__c = keyVsNationalPricing.get(uniq).Unify_NA_PricingType__c;
                            obj.Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Price__c;
                            obj.AlternatePrice__c =  keyVsNationalPricing.get(uniq).Unify_NA_AlternatePrice__c;
                            obj.QuantityBreak__c =  keyVsNationalPricing.get(uniq).Unify_NA_BreakQuantity__c;
                            obj.QuantityBreakUnit__c =  keyVsNationalPricing.get(uniq).Unify_NA_QuantityBreakUnit__c;
                            obj.Break1Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break1Quantity__c;
                            obj.Break1Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break1Price__c;
                            obj.Break2Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break2Quantity__c;
                            obj.Break2Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break2Price__c;
                            obj.Break3Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break3Quantity__c;
                            obj.Break3Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break3Price__c;
                            obj.Break4Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break4Quantity__c;
                            obj.Break4Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break4Price__c;
                            obj.Break5Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break5Quantity__c;
                            obj.Break5Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break5Price__c;
                            obj.PriceUnit__c =  keyVsNationalPricing.get(uniq).Unify_NA_PriceUnit__c;
                            obj.DateBegin__c =  keyVsNationalPricing.get(uniq).Unify_NA_DateBegin__c;
                            obj.DateEnd__c =  keyVsNationalPricing.get(uniq).Unify_NA_DateEnd__c;
                            obj.CustomerSku__c =  keyVsNationalPricing.get(uniq).Unify_NA_CustSKU__c;
                            obj.OrderType__c =  keyVsNationalPricing.get(uniq).Unify_NA_OrderType__c;
                            obj.QtyBreakFlag__c =  keyVsNationalPricing.get(uniq).Unify_NA_QtyBreakFlag__c;
                            obj.Action__c  = keyVsNationalPricing.get(uniq).Unify_NAP_ActionCd__c;
                            obj.Description__c =  keyVsNationalPricing.get(uniq).Unify_NA_ItemDescription__c;
                            obj.NationalAccountPricingId__c = keyVsNationalPricing.get(uniq).Unify_NA_National_Account_Pricing_ID__c;
                            
                            
                            insertNap.add(obj);
                            
                        }
                    }
                    system.debug('insertNap.size'+insertNap);
                    if(insertNap.size() > 0){
                        system.debug('insertNap.size');
                        insert insertNap;
                    }
                }
                // End of logic to Insert the record if doesnt find with unique key
            }
            else{
                List<NationalAccountsPricing__c> insertNap = new List<NationalAccountsPricing__c>();
                for(string uniq : keyVsNationalPricing.keySet()){
                    system.debug('contains uniq');
                    if(keyVsNationalPricing.get(uniq).Unify_NA_National_Account_Pricing_ID__c != 'D'){
                        NationalAccountsPricing__c obj = new NationalAccountsPricing__c();
                        
                        obj.CompositeKey__c = keyVsNationalPricing.get(uniq).Unify_NA_Item_CompositeKey__c;
                        obj.NationalAccountGroupID__c = keyVsNationalPricing.get(uniq).Unify_NA_Contract_Group_ID__c;
                    obj.Action__c  = keyVsNationalPricing.get(uniq).Unify_NAP_ActionCd__c;
                    obj.NationalAccountPricingId__c = keyVsNationalPricing.get(uniq).Unify_NA_National_Account_Pricing_ID__c;
                    obj.Name = keyVsNationalPricing.get(uniq).Unify_NA_ShortItem__c;
                    obj.Division__c = keyVsNationalPricing.get(uniq).Unify_NA_Division__c;
                    obj.Vendor__c = keyVsNationalPricing.get(uniq).Unify_NA_Vendor_Part_Number__c;
                    obj.Class__c = keyVsNationalPricing.get(uniq).Unify_NA_Class__c;
                    obj.Brand__c = keyVsNationalPricing.get(uniq).Unify_NA_Brand__c;
                    obj.Set__c = keyVsNationalPricing.get(uniq).Unify_NA_Sets__c;
                    obj.Subset__c = keyVsNationalPricing.get(uniq).Unify_NA_SubSets__c;
                    obj.PricingType__c = keyVsNationalPricing.get(uniq).Unify_NA_PricingType__c;
                    obj.Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Price__c;
                    obj.AlternatePrice__c =  keyVsNationalPricing.get(uniq).Unify_NA_AlternatePrice__c;
                    obj.QuantityBreak__c =  keyVsNationalPricing.get(uniq).Unify_NA_BreakQuantity__c;
                    obj.QuantityBreakUnit__c =  keyVsNationalPricing.get(uniq).Unify_NA_QuantityBreakUnit__c;
                    obj.Break1Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break1Quantity__c;
                    obj.Break1Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break1Price__c;
                    obj.Break2Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break2Quantity__c;
                    obj.Break2Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break2Price__c;
                    obj.Break3Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break3Quantity__c;
                    obj.Break3Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break3Price__c;
                    obj.Break4Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break4Quantity__c;
                    obj.Break4Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break4Price__c;
                    obj.Break5Quantity__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break5Quantity__c;
                    obj.Break5Price__c =  keyVsNationalPricing.get(uniq).Unify_NA_Break5Price__c;
                    obj.PriceUnit__c =  keyVsNationalPricing.get(uniq).Unify_NA_PriceUnit__c;
                    obj.DateBegin__c =  keyVsNationalPricing.get(uniq).Unify_NA_DateBegin__c;
                    obj.DateEnd__c =  keyVsNationalPricing.get(uniq).Unify_NA_DateEnd__c;
                    obj.CustomerSku__c =  keyVsNationalPricing.get(uniq).Unify_NA_CustSKU__c;
                    obj.OrderType__c =  keyVsNationalPricing.get(uniq).Unify_NA_OrderType__c;
                    obj.QtyBreakFlag__c =  keyVsNationalPricing.get(uniq).Unify_NA_QtyBreakFlag__c;
                    obj.Action__c  = keyVsNationalPricing.get(uniq).Unify_NAP_ActionCd__c;
                    obj.Description__c =  keyVsNationalPricing.get(uniq).Unify_NA_ItemDescription__c;
                    insertNap.add(obj);
                    }
                    
                    
                }
                if(insertNap.size() > 0){
                    insert insertNap;
                }
            }
        }
        
    }
}