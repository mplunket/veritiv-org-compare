/**
 Objective: Custom Controller that responds with a
 			JSON response of all the products, matching
 			the client's search criteria
 Developer: Hiremath, Naveen - Bluewolf
*/
public class ProductSearchCont {

	/**
	 Returns true when client's search criteria is empty
	*/
	private static Boolean validateSearchInput(final String itemNumber,
										final String description,
										final String vendorName,
										final String vendorProductCode) {

		return (!Utils.isNonEmptyString(itemNumber) &&
		        !Utils.isNonEmptyString(description) &&
		        !Utils.isNonEmptyString(vendorName) &&
		        !Utils.isNonEmptyString(vendorProductCode));

	}

	/**
	 Immutable basket to hold all the product search results
	*/
	private final ProductModel productSearch;

	/**
	 Mandatory search criteria's
	*/
	private String productCode;
	private String productDesc;
	private String vendorName;
	private String vendorProductCode;
	private String divisions;
	private Boolean indicateStocked;
	private Boolean showDeleted;

	/**
	 JSON response
	*/
	public String json { get; private set; }

	/**
	 Handles the request for finding out
	 products that match the search criteria
	*/
	public void doSearch() {

		mapSearchRequest(ApexPages.currentPage().getParameters());

		/*
		 With no search criteria there is no point
		 in invoking product search
		*/
		if(validateSearchInput(productCode, productDesc, vendorName, vendorProductCode)){

			this.json = '{"total":"0", "results":[]}';

		} else {

			initalize();

			// Always do a wild search on products
			productSearch.wild();

			/*
			if(Utils.isWildSearch(productDesc, Consts.WILD_CARD_OPERATOR) ||
		   	   Utils.isWildSearch(vendorName, Consts.WILD_CARD_OPERATOR)) {

				productSearch.wild();

			} else {

		 		productSearch.exact();

			}
		    */

			this.json = jsonifySearchResults(productSearch.getSearchResults());

		}

	}

	private String jsonifySearchResults(final List<ProductModel> searchResults) {

		String jsonResults = Consts.EMPTY_STRING;
		Integer recordCounter = 0;

		for(ProductModel eachResult: searchResults) {

			recordCounter++;

			Product2 product   = eachResult.getProduct();
			String productCode = (product.Vendor_Product_Code__c != null) ?
								 product.Vendor_Product_Code__c.replaceAll('\\\\', '') :
								 product.Vendor_Product_Code__c;

			jsonResults += '{';
			jsonResults += '"id":' + '"' + product.Id + '",';
			jsonResults += '"itemSeq":' + '"' + recordCounter + '",';
			jsonResults += '"divCode":' + '"' + product.Division_Code__c + '",';
			jsonResults += '"prodCode":' + '"' + product.ProductCode + '",';
			jsonResults += '"desc":' + '"' + product.Description.replaceAll('"','') + '",';
			jsonResults += '"pricingCostUOM":' + '"' + product.Pricing_Costing_UOM__c + '",';
			jsonResults += '"venName":' + '"' + product.Vendor__r.Name + '",';
			jsonResults += '"UWWItem":' + '"' + product.Unisource_Item_Number_U_number__c + '",';
			jsonResults += '"venProdCode":' + '"' + productCode + '",';
			jsonResults += '"qtyUOM":' + '"' + product.Unit_of_Measure__c + '",';
			jsonResults += '"priceUnit":' + '"' + product.Conversion_Factor__c + '",';
			jsonResults += '"isStocked":' + '"' + ((product.stocking_flag__c) ? 'Yes' : 'No') + '"';
			jsonResults += '},';

		}

		String jsonString = '{"total":"' + searchResults.size() + '", "results":[' + jsonResults + ']}';
		jsonString = jsonString.replaceAll(',]',']');

		return jsonString;

	}

	private void mapSearchRequest(final Map<String, String> searchParams) {

		this.productCode          = searchParams.get('pcode');
		this.productDesc          = searchParams.get('pdesc');
		this.vendorName           = searchParams.get('vname');
		this.vendorProductCode    = searchParams.get('vpcode');
		this.indicateStocked      = (searchParams.get('isStocked') == '1') ? Consts.ENABLE : Consts.DISABLE;
		this.divisions			  = searchParams.get('divisions');
		this.showDeleted		  = (searchParams.get('showDeleted') == '1') ? Consts.ENABLE : Consts.DISABLE;

	}

	private void initalize() {

		productSearch.setItemNumber(this.productCode);
		productSearch.setDescription(this.productDesc);
		productSearch.setVendorName(this.vendorName);
		productSearch.setVendorProductCode(this.vendorProductCode);
		productSearch.setIsStocked(this.indicateStocked);
		productSearch.setShowDeleted(this.showDeleted);

		List<String> selectedDivisions = new List<String>();
		if(this.divisions != Consts.EMPTY_STRING){
			selectedDivisions.addAll(this.divisions.split(','));
		}
		productSearch.setSelectedDivisions(selectedDivisions);

	}

    public ProductSearchCont() {

    	/*
		 Hold on to productModel that has freight lines and
		 servicing division references
		*/
		this.productSearch  = new ProductModel(new Product2(),
							  	Freight_Lines__c.getAll(),
							  	ServicingDivisionServices.getActiveServiceDivisions());

    }

}