public class PandAQLIControllerExtension
{
    private final ApexPages.StandardSetController qliSetController;

    public PandAQLIControllerExtension(ApexPages.StandardSetController stdSetController)
    {
        qliSetController = stdSetController;
        //Validation rules
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Check Availability" button on a quote record.'));
            return;
        }
        if(!hasSelectedRecords)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Quote Line Items have been selected. Please click the "Back" button and select at least one record.'));
            return;
        }
        //Validation rules passed, continue
        quote = [select Name, Account__r.Name, Account__r.RecordType.Name, Servicing_Division__c, Servicing_Division_Name__c, Account__r.AccountNumber, Account__r.Primary_Sales_Rep_Name__r.Contact__c, Ship_To_Number__c, Customer_Contact__c from Quote__c where Id = :ApexPages.currentPage().getParameters().get('id')];
        //Loop through selected rows
        for(Integer i=0; i < this.qliSetController.getSelected().size(); i++)
        {
            //Validation rule
            if(this.qliSetController.getSelected()[i].get('Special_Item__c') != null && (Boolean)this.qliSetController.getSelected()[i].get('Special_Item__c'))
            {
                String productCode = String.valueOf(this.qliSetController.getSelected()[i].get('Product_Code__c'));
                String productDescription = String.valueOf(this.qliSetController.getSelected()[i].get('Product_Description__c'));
                productCode = productCode == null? '': productCode;
                productDescription = productDescription == null? '': productDescription;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Pricing & Availability is not checked for special item ' + productCode + ' - ' + productDescription + '.'));
                continue;
            }
            Product2 product = [select p.System_ID__c, p.Pricing_Costing_UOM__c, p.Vendor_Product_Code__c, p.Description, p.ProductCode from Product2 p where ID = :(ID)this.qliSetController.getSelected()[i].get('Product__c')];
            ProductWrapper pw = new ProductWrapper(product);
                            
            pw.PandA = getPandAData(product);
            
            if(pw.PandA.Response.Errors.size() > 0)
            {
                for(PricingAndAvailability.ErrorsClass ec : pw.PandA.Response.Errors)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ec.description));
            }
                            
            pricingProducts.add(pw);
        }
    }
    //Properties
    public Quote__c quote {get; set;}
    
    @TestVisible
    public boolean isValidQuote
    {
        get
        {
            if(isValidQuote == null)
            {
                if(ApexPages.currentPage().getParameters().get('id') == null)
                {
                    isValidQuote = false;
                    return isValidQuote;
                }
                else
                {
                    isValidQuote = true;
                    return isValidQuote;
                }
            }
            return isValidQuote;
        }
        private set
        {
            isValidQuote = value;
        }
    }
    
    public Boolean hasSelectedRecords
    {
        get
        {
            if(this.qliSetController.getSelected().size() > 0)
                return true;
            else
                return false;
        }
    }
    
    public ProductWrapper[] pricingProducts
    {
        get
        {
            if(pricingProducts == null) pricingProducts = new ProductWrapper[0];
            return pricingProducts;
        }
        set {pricingProducts = value;}
    }
    //Methods
    private PricingAndAvailability getPandAData(Product2 product)
    {
        PricingAndAvailability paa = new PricingAndAvailability();
        
        paa.Request.SystemIdentifier = product.System_ID__c;
        paa.Request.DivisionID = this.quote.Servicing_Division__c;
        paa.Request.ShipToID = this.quote.Ship_To_Number__c;
        paa.Request.CIFItemID = product.ProductCode;
        paa.Request.Quantity = '1';
        paa.Request.QuantityUOM = product.Pricing_Costing_UOM__c;
        paa.Request.PricingUOM = product.Pricing_Costing_UOM__c;

        if(quote.Account__r.RecordType.Name == 'Prospect')
        {
            try
            {
                paa.Request.CustomerID = [select Dummy_Bill_To_Number__c from Servicing_Division__c where System_Code__c = :product.System_ID__c and Division_Code__c = :this.quote.Servicing_Division__c].Dummy_Bill_To_Number__c;
            }
            catch(Exception e)
            {
                paa.Request.CustomerID = null;
            }
        }
        else
            paa.Request.CustomerID = this.quote.Account__r.AccountNumber;

        paa.getData();
        
        return paa;
    }
    
    

}