/**
 Objective: Container that holds all the business logic attached with Product2
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class ProductModel implements SearchInterface{

	private static final String  DIVISION_CODE_NAME_SEPERATOR = ' - ';
	private static final Integer DEFAULT_SIZE_NO_RESULTS = 35;
	private static final Integer DEFAULT_SIZE_MULTIPLIER_EACH_RESULT = 60;
	private static final Integer DEFAULT_SIZE_LIMIT_ON_RESULTS = 360;

	/**
	 Maintain a reference to the Product2 object
	*/
	private final Product2 product;

	/**
	 Holds a reference to a list of available freight lines
	*/
	private final Map<String, Freight_Lines__c> freightLines;

	/**
	 Retain the user selected freight
	*/
	private String selectedFreight;

	/**
	 Maintain a composition to Vendor_Detail__c;
	 A product can sometimes be associated to a vendor
	*/
	private final Vendor_Detail__c vendor = new Vendor_Detail__c();

	/**
	 Determines if a product was selected
	*/
	private Boolean isSelected = false;

	/**
	 Determines whether deleted products should be filtered
	*/
	private Boolean showDeleted = false;

	/**
	 Maintain a collection of the searched products
	*/
    private final List<ProductModel> searchResults;

	/**
	 Maintain a list of active service divisions
	*/
	private final List<Servicing_Division__c> activeServiceDivisions;

	/**
     Retain the list of selected divisions
    */
    private final List<String> selectedDivisions = new List<String>();

    /**
     Calculate the display size for the product search results
     container
    */
    public Integer getProductsPixelSize() {

    	 return (this.matches()) ?
                Math.min(DEFAULT_SIZE_LIMIT_ON_RESULTS, this.count() * DEFAULT_SIZE_MULTIPLIER_EACH_RESULT) :
                DEFAULT_SIZE_NO_RESULTS;

    }

	/**
	 Returns a reference to Product2
	*/
	public Product2 getProduct() {

		return product;
	}

	/**
	 Returns a set of all the available freight codes
	*/
	public Set<String> getFreightCodes() {

		Set<String> freightCodes = new Set<String>();

		for(String freightName :this.freightLines.keySet()) {

			Freight_Lines__c currentFreightLine = this.freightLines.get(freightName);
			freightCodes.add(currentFreightLine.Code__c);

		}

		return freightCodes;

	}

	/**
	 Accessor to return a list of available freight lines
	*/
	public List<SelectOption> getFreightLines() {

		List<String> freightLineNames = new List<String>();
		List<SelectOption> options = new List<SelectOption>();
		Freight_Lines__c currentFreightLine;

		options.add(new SelectOption(Consts.SELECT_OPTION_NONE, Consts.SELECT_OPTION_NONE));

		freightLineNames.addAll(freightLines.keySet());
		freightLineNames.sort();

		for(String freightLineName :freightLineNames) {

			currentFreightLine = freightLines.get(freightLineName);
			options.add(new SelectOption(currentFreightLine.Name, currentFreightLine.Name));

		}

		return options;

	}

	/**
	 Accessor method that returns the selected freight's Code__c
	*/
	public String getSelectedFreightCode() {

		return  (freightLines.containsKey(this.selectedFreight)) ?
				freightLines.get(this.selectedFreight).Code__c:
				Consts.SELECT_OPTION_NONE;

	}

	/**
	 Returns a reference to Vendor
	*/
	public Vendor_Detail__c getVendor() {

		return vendor;

	}

	/**
	 Returns the state of product selection
	*/
	public Boolean getIsSelected() {

		return isSelected;

	}

	/**
	 Accessor that returns the selected freight
	*/
	public String getSelectedFreight() {

		return this.selectedFreight;

	}

	/*
	 Accessor to return a list of active service divisions
	*/
	public List<Servicing_Division__c> getServiceDivisions() {

		return this.activeServiceDivisions;

	}

	/**
	 Accessor to return a list of available divisions
	*/
	public List<SelectOption> getAvailableDivisions() {

		List<SelectOption> options = new List<SelectOption>();

		for(Servicing_Division__c activeDivision :activeServiceDivisions) {

			options.add(new SelectOption(activeDivision.Id, activeDivision.Division_Code__c +
							DIVISION_CODE_NAME_SEPERATOR + activeDivision.Name));

		}

		return options;

	}
	/**
	 Accessor that hands over the search results reference
	*/
	public List<ProductModel> getSearchResults() {

		return this.searchResults;

	}

	/**
	 Flags the availability of any available results
	*/
	public Boolean getMatches() {

		return matches();

	}

	/**
	 Returns the size of search results
	*/
	public Integer getCount() {

		return count();
	}

	/**
	 Accessor to return a list of selected divisions
	*/
	public List<String> getSelectedDivisions() {

		return this.selectedDivisions;

	}

	/**
	 Mutates the state for a given product
	*/
	public void setIsSelected(Boolean value) {

		isSelected = value;

	}

	/**
	 Mutator method that sets the value for a
	 product's Item Number
	*/
	public void setItemNumber(final String itemNumber) {

		if(product != null) {

			product.ProductCode = itemNumber;

		}
	}

	/**
	 Mutator method that sets the value for a
	 product's description
	*/
	public void setDescription(final String description) {

		if(product != null) {

			product.Description = description;

		}
	}

	/**
	 Mutator method that sets the value for a
	 product's vendor product code
	*/
	public void setVendorProductCode(final String vendorProductCode) {

		if(product != null) {

			product.Vendor_Product_Code__c = vendorProductCode;

		}

	}

	/**
	 Mutator method that sets the value for a
	 product's Stocking status
	*/
	public void setIsStocked(final Boolean isStocked) {

		if(product != null) {

			product.stocking_flag__c = isStocked;

		}

	}

	/**
	 Mutator method that sets the value for whether
	 to search among deleted items during a search
	*/
	public void setShowDeleted(final Boolean showDeleted) {

		this.showDeleted = showDeleted;
	}

	/**
	 Mutator method that sets the value for a
	 product's vendor name
	*/
	public void setVendorName(final String vendorName) {

		this.getVendor().Name = vendorName;

	}

	/**
	 Mutator method for setting a freight
	*/
	public void setSelectedFreight(final String freight) {

		this.selectedFreight = freight;

	}

	/**
	 Mutator to set the selected divisions
	*/
	public void setSelectedDivisions(List<String> selectedDivisions) {

		this.selectedDivisions.clear();
		this.selectedDivisions.addAll(selectedDivisions);

	}

	/**
	 Overriden wild search that constructs searched results
	 of List<ProductModels>
	*/
	public void wild() {

		if(product != null) {
			buildSearchResults(ProductServices.getProducts(
			   					product.ProductCode,
			   					product.Description,
			   					vendor.Name,
			   					product.Vendor_Product_Code__c,
			   					selectedDivisions,
			   					product.stocking_flag__c,
			   					Consts.WILD_CARD_OPERATOR,
			   					this.showDeleted)
			   				   );
		}

	}

	/**
	 Overriden non-wild card based search that constructs
	 searched results of List<ProductModels>
	*/
	public void exact() {

		if(product != null) {
			buildSearchResults(ProductServices.getProducts(
			   				    product.ProductCode,
			   					product.Description,
			   					vendor.Name,
			   					product.Vendor_Product_Code__c,
			   					selectedDivisions,
			   					product.stocking_flag__c)
			   				   );
		}

	}

	/**
	 Validate true for any available products
	 that matched the search criteria
	*/
	public Boolean matches() {

		return !searchResults.isEmpty();

	}

	/**
	 Returns the number of matched entries
	*/
	public Integer count() {

		return searchResults.size();
	}

	/**
	 Facilitates clearing of current searchResults
	*/
	public void clear() {

		searchResults.clear();
	}

	/**
	 Add the products to the immutable list of Search Results
	*/
	private void buildSearchResults(List<Product2> products) {

		searchResults.clear();

		for(Product2 product :products) {

			searchResults.add(new ProductModel(product));

		}

	}

	/**
	 Overloaded constructor that accepts product, freight lines
	 and active service divisions
	*/
	public ProductModel(Product2 product,
						Map<String, Freight_Lines__c> freightLines,
						List<Servicing_Division__c> activeServiceDivisions) {

		this(product);

		/**
		 Build the map of available freight lines as
		 part of object instantiation
		*/
		this.freightLines = freightLines;

		/**
		 Retain the list of available service divisions
		*/
		this.activeServiceDivisions = activeServiceDivisions;

	}

	/**
	 Explicit constructor that takes a reference to Product2
	*/
	public ProductModel(Product2 product) {

		this.product       = product;

		/*
		 Instantiate the searchResults container
		*/
		this.searchResults = new List<ProductModel>();

	}

}