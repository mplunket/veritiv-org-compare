/**
 Objective: Noninstantiable services class that collects all
 			static SOQL service methods operating on Product2 object
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class ProductServices {

	private static final String productSearchQueryFields = 'SELECT Id, Division_Code__c, ProductCode, Description,  Conversion_Factor__c, Pricing_Costing_UOM__c, Unit_of_Measure__c, Vendor__r.Name, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Stocking_Flag__c, ' +
	'CWT_Item_Level_Pricing_Allowed__c, CWT_Set_Level_Pricing_Allowed__c, CWT_Subset_Level_Pricing_Allowed__c, Brand__c, Class__c, Set__c, Subset__c ' + 
	'FROM Product2 WHERE ';

	public static List<Product2> getProducts(final String productCode,
											 final String productDescription,
											 final String vendorName,
											 final String vendorProductCode,
											 final List<String> divisionNames,
											 final Boolean isStocked,
											 final String wildCard,
											 final Boolean showDeleted) {

		String dynamicQuery = productSearchQueryFields;

		if(isStocked)
			dynamicQuery += ' Stocking_Flag__c = ' + isStocked;
		else
			dynamicQuery += ' (Stocking_Flag__c = true OR Stocking_Flag__c = false) ';

		if(!showDeleted)
			dynamicQuery += ' AND IsActive = true ';

		dynamicQuery += buildProductCode(productCode);

		dynamicQuery += buildProductDescription(productDescription, wildCard);

		dynamicQuery += buildVendorName(vendorName, wildCard);

		dynamicQuery += buildVendorProductCode(vendorProductCode);

		dynamicQuery += buildProductDivisionNames(divisionNames);

		dynamicQuery += Utils.getOrderByFilter('Vendor__r.Name') + Utils.getLimitExpression(null);

		return Database.query(dynamicQuery);

	}

	public static List<Product2> getProducts(final String productCode,
											 final String productDescription,
											 final String vendorName,
											 final String vendorProductCode,
											 final List<String> divisionNames,
											 final Boolean isStocked) {

		String dynamicQuery = productSearchQueryFields;

		if(isStocked)
			dynamicQuery += ' Stocking_Flag__c = ' + isStocked;
		else
			dynamicQuery += ' (Stocking_Flag__c = true OR Stocking_Flag__c = false) ';

		dynamicQuery += buildProductCode(productCode);

		dynamicQuery += buildProductDescription(productDescription, null);

		dynamicQuery += buildVendorName(vendorName, null);

		dynamicQuery += buildVendorProductCode(vendorProductCode);

		dynamicQuery += buildProductDivisionNames(divisionNames);

		dynamicQuery += Utils.getOrderByFilter('Vendor__r.Name') + Utils.getLimitExpression(null);

		return Database.query(dynamicQuery);

	}

	private static String buildProductCode(final String productCode) {

		return (Utils.isNonEmptyString(productCode)) ?
				Utils.getExactAndQueryFilter('ProductCode', productCode):
				Consts.EMPTY_STRING;

	}

	private static String buildVendorProductCode(final String vendorProductCode) {

		return (Utils.isNonEmptyString(vendorProductCode)) ?
				Utils.getExactAndQueryFilter('Vendor_Product_Code__c', vendorProductCode):
				Consts.EMPTY_STRING;

	}

	private static String buildVendorName(final String vendorName, final String wildCard) {

		return buildWildQueryStub('Vendor__r.Name', vendorName, wildCard);

		/*
		return (Utils.isNonEmptyString(vendorName)) ?
					((wildCard != null && (Utils.getWildSearchType(vendorName, wildCard) != null)) ?
						Utils.getLikeANDQueryFilter('Vendor__r.Name', Utils.getWildSearchType(vendorName, wildCard)):
						Utils.getExactAndQueryFilter('Vendor__r.Name', vendorName)):
				Consts.EMPTY_STRING;
		*/
	}

	private static String buildProductDescription(final String productDescription, final String wildCard) {

		return buildWildQueryStub('Description', productDescription, wildCard);

		/*
		return (Utils.isNonEmptyString(productDescription)) ?
					((wildCard != null && (Utils.getWildSearchType(productDescription, wildCard) != null)) ?
						Utils.getLikeANDQueryFilter('Description', Utils.getWildSearchType(productDescription, wildCard)):
						Utils.getExactAndQueryFilter('Description', productDescription)):
				Consts.EMPTY_STRING;
		*/
	}

	private static String buildProductDivisionNames(final List<String> divisionIds) {

		return (divisionIds.size() > 0) ?
				Utils.getInAndQueryFilter('Division_Name__c', divisionIds) :
				Consts.EMPTY_STRING;

	}

	private static String buildWildQueryStub(final String fieldName, final String fieldValue, final String wildCard){

		String wildQueryStub = Consts.EMPTY_STRING;

		if(Utils.isNonEmptyString(fieldValue)) {

			String[] searchTerms = fieldValue.split(wildCard);

			for(String searchStub :searchTerms) {
				if(searchStub != Consts.EMPTY_STRING)
					wildQueryStub += Utils.getLikeANDQueryFilter(fieldName, Utils.getContainsWith(searchStub));
			}

		}

		return wildQueryStub;

	}

	/**
	 Get a list of all the matching products for the given
	 wild card based search terms
	*/
	/*
	public static List<Product2> getProducts(final String productCode,
											 final String productDescription,
											 final String wildCard) {

		String validatedWildSearchType = Utils.getWildSearchType(productDescription, wildCard);

		List<Product2> products = [SELECT
									Id,
									Division_Code__c,
									ProductCode,
									Description,
									Pricing_Costing_UOM__c,
									Vendor__r.Name,
									Unisource_Item_Number_U_number__c,
									Vendor_Product_Code__c,
									Stocking_Flag__c
								   FROM Product2
								   WHERE (ProductCode != null AND ProductCode = :productCode) OR
								   Description LIKE :validatedWildSearchType
								   ORDER BY Vendor__r.Name
								   LIMIT :Consts.VF_COLLECTION_LIMIT];

		return products;

	}
	*/
	/**
	 Get a list of all the matching products for an exact match
	 with the search criteria
	*/
	/*
	public static List<Product2> getProducts(final String productCode,
											 final String productDescription) {

		List<Product2> products = [SELECT
									Id,
									Division_Code__c,
									ProductCode,
									Description,
									Pricing_Costing_UOM__c,
									Vendor__r.Name,
									Unisource_Item_Number_U_number__c,
									Vendor_Product_Code__c,
									Stocking_Flag__c
								   FROM Product2
								   WHERE (ProductCode != null AND ProductCode =:productCode) OR
								   (Description != null AND Description = :productDescription)
								   ORDER BY Vendor__r.Name
								   LIMIT :Consts.VF_COLLECTION_LIMIT];

		return products;

	}
	*/

	/**
	 Suppress default constructor for noninstantiability
	*/
	private ProductServices() { }

}