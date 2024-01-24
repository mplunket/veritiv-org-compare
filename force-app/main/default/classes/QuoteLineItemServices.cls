/**
 Objective: Noninstantiable services class that collects all
 			static SOQL service methods operating on Quote_Line_Item__c object
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class QuoteLineItemServices {

	/**
	 Get a list of all the quote line items for a given quoteId
	*/
	public static List<Quote_Line_Item__c> getQuoteLineItems(Id quoteId) {

		return [SELECT Id, Price_Code__c, Cost_Code__c,
        			End_User_Agreement__c, Extended_Price__c,
        			Cost_Unit_Factor__c, Price_Unit_Factor__c,
        			Quantity_Unit_Factor__c, GTM_CAS__c,
        			GTM_percent__c, Bid_number_Contract_number__c,
        			mfg_tolerance__c, Vendor_Name__c, Vendor_Item__c,
        			Vendor_Contact__c, Quantity_unit_of_measure__c,
        			Qty__c, Projected_Delivery_Date__c,
        			Product_Description__c, Product__c,
        			Product_Code__c, Price__c, Start_Price__c, Target_Price__c, Floor_Price__c,
                    Minimum_mfg_quantity__c,
        			Last_Date_of_Change__c, Cost__c, Special_Product__c,
        			Special_Item__c, Price_unit_of_measure__c,
        			Costing_unit_of_measure__c, Product__r.System_ID__c,
        			Product__r.Division_Code__c, Unisource_Item__c,
        			Comments_Short__c, Comments__c,  Vendor_Name__r.Name, Item_Seq__c,
        			Extended_Cost__c, Locked__c, Quote__c,
        			// Web Center fields
        			Type_Of_Quote__c, Item_Origin__c, Roll_Size__c,
					Basis_Weight__c, Outer_Diameter__c, Core__c,
					Color__c, Brightness__c, Brand__c, Finish__c,
					Stock_Manufactured__c, Grade_Name_Class__c,
					Recycled_Content__c, PCW_Content__c,
					Coc_Required__c, Last_Date_To_Order__c,CostCommision__c, CurrencyIsoCode,
					Future_Dev_Cost__c,
                    // Update Pricing Details
                    Pricing_Start_Date__c,
                    List_Down_Percent__c, Cost_Up_Percent__c, Sent_To_Zilliant_Time__c,Quote__r.Account__r.Account_SysDivBillTo__c 
      			FROM Quote_Line_Item__c
        		WHERE Quote__c = :quoteId
        		ORDER BY Item_Seq__c ASC, CreatedDate ASC];

	}

	/**
	 Get the quote line item for the given quoteId and quoteLineItemId
	*/
	public static List<Quote_Line_Item__c> getQuoteLineItem(Id quoteId, Id qliId) {

		return [SELECT Id, Price_Code__c, Cost_Code__c,
        			End_User_Agreement__c, Extended_Price__c,
        			Cost_Unit_Factor__c, Price_Unit_Factor__c,
        			Quantity_Unit_Factor__c, GTM_CAS__c,
        			GTM_percent__c, Bid_number_Contract_number__c,
        			mfg_tolerance__c, Vendor_Name__c, Vendor_Item__c,
        			Vendor_Contact__c, Quantity_unit_of_measure__c,
        			Qty__c, Projected_Delivery_Date__c,
        			Product_Description__c, Product__c,
        			Product_Code__c, Price__c, Start_Price__c, Minimum_mfg_quantity__c,
        			Last_Date_of_Change__c, Cost__c, Special_Product__c,
        			Special_Item__c, Price_unit_of_measure__c,
        			Costing_unit_of_measure__c, Product__r.System_ID__c,
        			Product__r.Division_Code__c, Unisource_Item__c,
        			Comments_Short__c, Comments__c, Vendor_Name__r.Name, Item_Seq__c,
        			Extended_Cost__c, Locked__c, Quote__c,
        			// Web Center fields
        			Type_Of_Quote__c, Item_Origin__c, Roll_Size__c,
					Basis_Weight__c, Outer_Diameter__c, Core__c,
					Color__c, Brightness__c, Brand__c, Finish__c,
					Stock_Manufactured__c, Grade_Name_Class__c,
					Recycled_Content__c, PCW_Content__c,
					Coc_Required__c, Last_Date_To_Order__c,CostCommision__c, CurrencyIsoCode,
					// Additional Details
					Cust_Item_Code__c, Price_Origin__c, Contract_Price_Cd__c, Target_Price__c,
					Floor_Price__c, Future_Dev_Cost__c, Future_Dev_Cost_Starts__c,
					Rebate_Code_Desc__c, Rebate_Starts__c, Rebate_Ends__c,
                    // Update Pricing Details
                    Pricing_Start_Date__c,
                    List_Down_Percent__c, Cost_Up_Percent__c, Sent_To_Zilliant_Time__c, Updated_P_A__c, Quote__r.Account__r.Account_SysDivBillTo__c 
      			FROM Quote_Line_Item__c
        		WHERE Quote__c = :quoteId AND
        		Id = :qliId
        		ORDER BY Item_Seq__c ASC, CreatedDate ASC];

	}

	/**
	 Get the quote line item for the given quoteId and Set of quoteLineItemIds
	*/
	public static List<Quote_Line_Item__c> getQuoteLineItem(Id quoteId, Set<Id> qliIds) {

		System.debug('*** QiD: ' + quoteId + ' QLIiD: ' + qliIds);
		
		return [SELECT Id, Price_Code__c, Cost_Code__c,
        			End_User_Agreement__c, Extended_Price__c,
        			Cost_Unit_Factor__c, Price_Unit_Factor__c,
        			Quantity_Unit_Factor__c, GTM_CAS__c,
        			GTM_percent__c, Bid_number_Contract_number__c,
        			mfg_tolerance__c, Vendor_Name__c, Vendor_Item__c,
        			Vendor_Contact__c, Quantity_unit_of_measure__c,
        			Qty__c, Projected_Delivery_Date__c,
        			Product_Description__c, Product__c,
        			Product_Code__c, Price__c, Start_Price__c, Minimum_mfg_quantity__c,
        			Last_Date_of_Change__c, Cost__c, Special_Product__c,
        			Special_Item__c, Price_unit_of_measure__c,
        			Costing_unit_of_measure__c, Product__r.System_ID__c,
        			Product__r.Division_Code__c, Unisource_Item__c,
        			Comments_Short__c, Comments__c, Vendor_Name__r.Name, Item_Seq__c,
        			Extended_Cost__c, Locked__c, Quote__c, Duty__c, Exchange__c, Brokerage__c,
        			// Web Center fields
        			Type_Of_Quote__c, Item_Origin__c, Roll_Size__c,
					Basis_Weight__c, Outer_Diameter__c, Core__c,
					Color__c, Brightness__c, Brand__c, Finish__c,
					Stock_Manufactured__c, Grade_Name_Class__c,
					Recycled_Content__c, PCW_Content__c,
					Coc_Required__c, Last_Date_To_Order__c,CostCommision__c, CurrencyIsoCode,
					// Additional Details
					Cust_Item_Code__c, Price_Origin__c, Contract_Price_Cd__c, Target_Price__c,
					Floor_Price__c, Future_Dev_Cost__c, Future_Dev_Cost_Starts__c,
					Rebate_Code_Desc__c, Rebate_Starts__c, Rebate_Ends__c,
					// Related Product2
					Product__r.Set__c, Product__r.Subset__c, Product__r.Class__c, Product__r.Brand__c, Product__r.Segment__c,
					Product__r.CWT_Item_Level_Pricing_Allowed__c, Product__r.CWT_Set_Level_Pricing_Allowed__c, Product__r.CWT_Subset_Level_Pricing_Allowed__c,
					//Product__r.List_Down_Percent__c, Product__r.Cost_Up_Percent__c, Pricing_Start_Date__c
					// Update Pricing Details
					Pricing_Start_Date__c,
					List_Down_Percent__c, Cost_Up_Percent__c, Sent_To_Zilliant_Time__c, Quote__r.Account__r.Account_SysDivBillTo__c 
      			FROM Quote_Line_Item__c
        		WHERE Quote__c = :quoteId AND
        		Id IN :qliIds
        		ORDER BY Item_Seq__c ASC, CreatedDate ASC];

	}

	/**
	 Suppress default constructor for noninstantiability
	*/
	private QuoteLineItemServices() { }

}