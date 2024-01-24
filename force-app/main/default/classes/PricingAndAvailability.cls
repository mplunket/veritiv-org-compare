public class PricingAndAvailability
{
    public static List<Servicing_Division__c> ServicingDivisions {
        get {
            if(ServicingDivisions == null) {
                ServicingDivisions = [SELECT Name, Division_Composite_Key__c, System_Code__c, Division_Code__c, Dummy_Bill_To_Number__c FROM Servicing_Division__c];
            }
            return ServicingDivisions; 
        }
        set;
    }
    public static WebService__c PAEndpoint {
        get {
            if(PAEndpoint == null) {
                PAEndpoint = [SELECT URL__c FROM WebService__c WHERE Type__c = 'P&A'];
            }
            return PAEndpoint;
        }
        set;
    }
        //Classes
    public class RequestClass
    {
        public String Computer
        {
            get
            {
                return 'Salesforce';
            }
        }
        public String WebServiceUser
        {
            get
            {
                return UserInfo.getUserName();
            }
        }
        public String SystemIdentifier {get; set;}
        public String DivisionID {get; set;}
        public String CustomerID {get; set;}
        public String ShipToID {get; set;}
        public String CIFItemID {get; set;}
        public String Quantity {get; set;}
        public String QuantityUOM {get; set;}
        public String PricingUOM {get; set;}
    }
    
    public class ResponseClass
    {
        public UnitsOfMeasureClass[] UnitsOfMeasure
        {
            get
            {
                if(UnitsOfMeasure == null) UnitsOfMeasure = new UnitsOfMeasureClass[0];
                return UnitsOfMeasure;
            }
            set
            {
                UnitsOfMeasure = value;
            }
        }
        public AvailabilityDescriptionsClass[] AvailabilityDescriptions
        {
            get
            {
                if(AvailabilityDescriptions == null) AvailabilityDescriptions = new AvailabilityDescriptionsClass[0];
                return AvailabilityDescriptions;
            }
            set
            {
                AvailabilityDescriptions = value;
            }
        }
        public AvailabilityClass[] Availability
        {
            get
            {
                if(Availability == null) Availability = new AvailabilityClass[0];
                return Availability;
            }
            set
            {
                Availability = value;
            }
        }
        public PriceBreaksClass[] PriceBreaks
        {
            get
            {
                if(PriceBreaks == null) PriceBreaks = new PriceBreaksClass[0];
                return PriceBreaks;
            }
            set
            {
                PriceBreaks = value;
            }
        }
        public ItemDetailsClass[] ItemDetails
        {
            get
            {
                if(ItemDetails == null) ItemDetails = new ItemDetailsClass[0];
                return ItemDetails;
            }
            set
            {
                ItemDetails = value;
            }
        }
        public TaxInformationClass[] TaxInformation
        {
            get
            {
                if(TaxInformation == null) TaxInformation = new TaxInformationClass[0];
                return TaxInformation;
            }
            set
            {
                TaxInformation = value;
            }
        }
        public ErrorsClass[] Errors
        {
            get
            {
                if(Errors == null) Errors = new ErrorsClass[0];
                return Errors;
            }
            set
            {
                Errors = value;
            }
        }
        public ItemEligibilityClass[] ItemEligibility
        {
            get
            {
                if(ItemEligibility == null) ItemEligibility = new ItemEligibilityClass[0];
                return ItemEligibility;
            }
            set
            {
                ItemEligibility = value;
            }
        }


    }

    public class UnitsOfMeasureClass
    {
        public String RecordID {get; set;}
        public String ParentID {get; set;}
        public String UOMName {get; set;}
        public String UOMDescription {get; set;}
        public String UOMFactor {get; set;}
        public String UOMIsCustomerDefaultForQuantity {get; set;}
        public String UOMIsCustomerDefaultForPrice {get; set;}
        public String UOMIsItemDefaultForQuantity {get; set;}
        public String UOMIsItemDefaultForPrice {get; set;}
        public String UOMDisplayForPriceOrQuantity {get; set;}
    } 

    public class ItemEligibilityClass
    {
        public String EligibilityFlag {get; set;}
        public String ExceptionFlag {get; set;}
    }

    public class AvailabilityDescriptionsClass
    {
        public String RecordID {get; set;}
        public String ParentID {get; set;}
        public String Line {get; set;}
        public String ItemStatus {get; set;}
        public String CertType {get; set;}
        public String ItemDescription {get; set;}
    }

    public class AvailabilityClass
    {
        @TestVisible
        private Map<String, String> divisions = new Map<String, String>();
        //Constructor
        public AvailabilityClass()
        {
            for(Servicing_Division__c servicingDivision : ServicingDivisions) {
                divisions.put(servicingDivision.Division_Composite_Key__c, servicingDivision.Name);
            }
        }
        public String Division
        {
            get
            {
                return divisions.get(ItemSystemId + ItemDivisionId);
            }
        }
        public String ItemSystemId
        {
            get
            {
                return ItemSystemId;
            }
            set
            {
                ItemSystemId = value;
            }
        }
        public String ItemDivisionId
        {
            get
            {
                return ItemDivisionId;
            }
            set
            {
                ItemDivisionId = value;
            }
        }
        public String ItemIncrement {get; set;}
        public String ItemMinimumPurchase {get; set;}
        public String ItemPriceType {get; set;}
        public String ItemQuantityOnhand {get; set;}
        public String ItemStockingUOM {get; set;}
        public String ItemTransferCutoffTime {get; set;}
        public String ItemTransferDays {get; set;}
    }
    
    public class PriceBreaksClass
    {
        public String PriceBracket {get; set;}
        public String SystemBreakQuantity {get; set;}
        public String DisplayBreakPrice {get; set;}
        public String DisplayBreakQuantity {get; set;}
    }
    
    public class ItemDetailsClass
    {
        public String ItemPricePerUOM {get; set;}
        public String ItemPricingUOM {get; set;}
        public String ItemCTSDisplayPrice {get; set;}
        public String ItemQuantity {get; set;}
        public String ItemQuantityUOM {get; set;}
        public String ItemCostStandard {get; set;}
        public String ItemPriceCode {get; set;}
        public String ItemCostCode {get;set;}
        
        //Added 4/25 : MH
        public String PriceOrigin {get;set;}
        public String ContractPriceCode {get;set;}
        public String TargetPrice {get;set;}
        public String FloorPrice {get;set;}
        public String CustomerItemNumber {get;set;}
        public String RebateGroupDescr {get;set;}
        public String DateBegin {get;set;}
        public String DateEnd {get;set;}
        public String FutureDevCost {get;set;}
        public String FutureDevCostEffDate {get;set;}
        
    }
    
    public class TaxInformationClass
    {
        public String ItemTaxable {get; set;}
        public String ItemTaxRate {get; set;}
    }
    
    public class ErrorsClass
    {
        public String name {get; set;}
        public String description {get; set;}
        public String code {get; set;}
    }
    //Methods
    @TestVisible
    private void serializeXML(XmlStreamReader xsr)
    {
        system.debug('##xsr: ' + xsr);
        while(xsr.hasNext())
        {
            if(xsr.isStartElement())
            {
                system.debug('##xsr.getLocalName(): ' + xsr.getLocalName());
                if(xsr.isStartElement() && xsr.getLocalName() == 'UnitsOfMeasure')
                    parseUnitsOfMeasure(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'Availability.Descriptions')
                    parseAvailabilityDescriptions(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'Availability')
                    parseAvailability(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'PriceBreaks')
                    parsePriceBreaks(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'ItemDetails')
                    parseItemDetails(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'TaxInformation')
                    parseTaxInformation(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'ItemEligibility')
                    parseItemEligibility(xsr);
                else if(xsr.isStartElement() && xsr.getLocalName() == 'Errors')
                    parseErrors(xsr);
            }
            xsr.next();
        }
        
    }
    @TestVisible
    private void parseUnitsOfMeasure(XmlStreamReader xsr)
    {
        UnitsOfMeasureClass uomc = new UnitsOfMeasureClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'UnitsOfMeasure')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'RecordID')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.RecordID = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'ParentID')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.ParentID = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.Name')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMName = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.Description')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMDescription = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.Factor')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMFactor = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.IsCustomerDefaultForQuantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMIsCustomerDefaultForQuantity = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.IsCustomerDefaultForPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMIsCustomerDefaultForPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.IsItemDefaultForQuantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMIsItemDefaultForQuantity = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.IsItemDefaultForPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMIsItemDefaultForPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'UOM.DisplayForPriceOrQuantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    uomc.UOMDisplayForPriceOrQuantity = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.UnitsOfMeasure.add(uomc);
    }
    @TestVisible
    private void parseAvailabilityDescriptions(XmlStreamReader xsr)
    {
        AvailabilityDescriptionsClass adc = new AvailabilityDescriptionsClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'Availability.Descriptions')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'RecordID')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.RecordID = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'ParentID')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.ParentID = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Line')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.Line = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.Status')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.ItemStatus = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'CertType')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.CertType = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.Description')
            {
                xsr.next();
                if(xsr.isCharacters())
                    adc.ItemDescription = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.AvailabilityDescriptions.add(adc);
    }
    @TestVisible
    private void parseAvailability(XmlStreamReader xsr)
    {
        AvailabilityClass ac = new AvailabilityClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'Availability')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.DivisionId')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemDivisionId = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.Increment')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemIncrement = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.MinimumPurchase')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemMinimumPurchase = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.PriceType')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemPriceType = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.QuantityOnhand')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemQuantityOnhand = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.StockingUOM')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemStockingUOM = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.SystemId')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemSystemId = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.TransferCutoffTime')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemTransferCutoffTime = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.TransferDays')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ac.ItemTransferDays = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.Availability.add(ac);
    }
    @TestVisible
    private void parsePriceBreaks(XmlStreamReader xsr)
    {
        PriceBreaksClass pbc = new PriceBreaksClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'PriceBreaks')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'PriceBracket')
            {
                xsr.next();
                if(xsr.isCharacters())
                    pbc.PriceBracket = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'SystemBreakQuantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    pbc.SystemBreakQuantity = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'DisplayBreakPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    pbc.DisplayBreakPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'DisplayBreakQuantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    pbc.DisplayBreakQuantity = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.PriceBreaks.add(pbc);
    }
    @TestVisible
    private void parseItemDetails(XmlStreamReader xsr)
    {
        ItemDetailsClass idc = new ItemDetailsClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'ItemDetails')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.PricePerUOM')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemPricePerUOM = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.PricingUOM')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemPricingUOM = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.CTSDisplayPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemCTSDisplayPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.Quantity')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemQuantity = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.QuantityUOM')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemQuantityUOM = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.CostStandard')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemCostStandard = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.CostCode')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemCostCode = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.PriceCode')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ItemPriceCode = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.PriceOrigin')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.PriceOrigin = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.ContractPriceCode')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.ContractPriceCode = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.TargetPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.TargetPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.FloorPrice')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.FloorPrice = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.CustomerItemNumber')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.CustomerItemNumber = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.RebateGroupDescr')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.RebateGroupDescr = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.DateBegin')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.DateBegin = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.DateEnd')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.DateEnd = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.FutureDevCost')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.FutureDevCost = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.FutureDevCostEffDate')
            {
                xsr.next();
                if(xsr.isCharacters())
                    idc.FutureDevCostEffDate = xsr.getText().trim();
            }            
            xsr.next();
        }
        Response.ItemDetails.add(idc);
    }
    @TestVisible
    private void parseTaxInformation(XmlStreamReader xsr)
    {
        TaxInformationClass tic = new TaxInformationClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'TaxInformation')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.Taxable')
            {
                xsr.next();
                if(xsr.isCharacters())
                    tic.ItemTaxable = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Item.TaxRate')
            {
                xsr.next();
                if(xsr.isCharacters())
                    tic.ItemTaxRate = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.TaxInformation.add(tic);
    }
@TestVisible
    private void parseItemEligibility (XmlStreamReader xsr)
    {
        ItemEligibilityClass iec = new ItemEligibilityClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'ItemEligibility')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'EligibilityFlag')
            {
                xsr.next();
                if(xsr.isCharacters())
                    iec.EligibilityFlag = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'ExceptionFlag')
            {
                xsr.next();
                if(xsr.isCharacters())
                    iec.ExceptionFlag = xsr.getText().trim();
            }
                        
            xsr.next();
        }
        Response.ItemEligibility.add(iec);
    }
    @TestVisible
    private void parseErrors(XmlStreamReader xsr)
    {
        ErrorsClass ec = new ErrorsClass();
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'Errors')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'name')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ec.name = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'description')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ec.description = xsr.getText().trim();
            }
            else if(xsr.isStartElement() && xsr.getLocalName() == 'code')
            {
                xsr.next();
                if(xsr.isCharacters())
                    ec.code = xsr.getText().trim();
            }
            xsr.next();
        }
        Response.Errors.add(ec);
    }
    
    public void getData()
    {
        //Clear previous response
        Response = new ResponseClass();
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        //Get URL from custom object
        String endPoint = '';
        
        try{
            endPoint = PAEndpoint.URL__c;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The URL for the P&A web service has not been configured in the WebService object.'));
            return;
        }
        endPoint += '?Computer=' + this.Request.Computer;
        endPoint += '&WebServiceUser=' + this.Request.WebServiceUser;
        if(this.Request.SystemIdentifier != null)
            endPoint += '&SystemIdentifier=' + this.Request.SystemIdentifier;
        if(this.Request.DivisionID != null)
            endPoint += '&DivisionID=' + this.Request.DivisionID;
        if(this.Request.CustomerID != null)
            endPoint += '&CustomerID=' + this.Request.CustomerID;
        if(this.Request.ShipToID != null)
            endPoint += '&ShipToID=' + this.Request.ShipToID;
        if(this.Request.CIFItemID != null)
            endPoint += '&CIFItemID=' + this.Request.CIFItemID;
        if(this.Request.Quantity != null)
            endPoint += '&Quantity=' + this.Request.Quantity;
        if(this.Request.QuantityUOM != null)
            endPoint += '&QuantityUOM=' + this.Request.QuantityUOM;
        if(this.Request.PricingUOM != null)
            endPoint += '&PricingUOM=' + this.Request.PricingUOM;
        req.setEndpoint(endPoint);
        System.debug('endPoint='+endPoint);
        req.setMethod('GET');
        
        HttpResponse res = null;
        XmlStreamReader xsr = null;
        
        try
        {
            res = h.send(req);
            xsr = new XmlStreamReader(res.getBody());
            System.debug('P&A Response=' + res.getBody());
            System.debug('P&A Response=' + xsr);
        }
        catch(Exception e)
        {
            ErrorsClass ec = new ErrorsClass();
            ec.description = e.getMessage();
            Response.Errors.add(ec);
            return;
        }
        system.debug('##xsr'+ xsr);
        //system.debug('##serialized data' + serializeXML(xsr));
        serializeXML(xsr);
        
    }

     public map<string,string> getDataForGetPrice()
    {
        //Clear previous response
        Response = new ResponseClass();
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        //Get URL from custom object
        String endPoint = '';
        try
        {
            endPoint = PAEndpoint.URL__c;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The URL for the P&A web service has not been configured in the WebService object.'));
            return null;
        }
        endPoint += '?Computer=' + this.Request.Computer;
        endPoint += '&WebServiceUser=' + this.Request.WebServiceUser;
        if(this.Request.SystemIdentifier != null)
            endPoint += '&SystemIdentifier=' + this.Request.SystemIdentifier;
        if(this.Request.DivisionID != null)
            endPoint += '&DivisionID=' + this.Request.DivisionID;
        if(this.Request.CustomerID != null)
            endPoint += '&CustomerID=' + this.Request.CustomerID;
        if(this.Request.ShipToID != null)
            endPoint += '&ShipToID=' + this.Request.ShipToID;
        if(this.Request.CIFItemID != null)
            endPoint += '&CIFItemID=' + this.Request.CIFItemID;
        if(this.Request.Quantity != null)
            endPoint += '&Quantity=' + this.Request.Quantity;
        if(this.Request.QuantityUOM != null)
            endPoint += '&QuantityUOM=' + this.Request.QuantityUOM;
        if(this.Request.PricingUOM != null)
            endPoint += '&PricingUOM=' + this.Request.PricingUOM;
        req.setEndpoint(endPoint);
        System.debug('endPoint='+endPoint);
        req.setMethod('GET');
        
        HttpResponse res = null;
        XmlStreamReader xsr = null;
map<string,string> finResultMap = new map<string,string>();
    try
        {
            res = h.send(req);
            xsr = new XmlStreamReader(res.getBody());
            System.debug('P&A Response=' + res.getBody());
            System.debug('P&A Response=' + xsr);
            
             Dom.Document doc = res.getBodyDocument();
        
        //Retrieve the root element for this document.
        Dom.XMLNode address = doc.getRootElement();
        
            
            //Added for UOM picklist
            string picklistValues = 'None';
            for(dom.XmlNode node:  address.getChildElements()){
                if(node.getName() == 'UnitsOfMeasure'){
                    string pick = node.getChildElement('UOM.Name', null).getText();
                    picklistValues = picklistValues +','+ pick;
                }
            }
            System.debug('picklistValues'+picklistValues);
             
            //End
            
            
            
        Dom.XmlNode a = address.getChildElement('ItemDetails', null);
   string fPrice =  a.getChildElement('Item.FloorPrice', null).getText();
             string PCode =  a.getChildElement('Item.PriceCode', null).getText();
             string TPrice =  a.getChildElement('Item.TargetPrice', null).getText();
            string PPU =  a.getChildElement('Item.PricePerUOM', null).getText();
             string PU =  a.getChildElement('Item.PricingUOM', null).getText();
                      string QU =  a.getChildElement('Item.QuantityUOM', null).getText();
 string SP =  a.getChildElement('Item.CTSDisplayPrice', null).getText();
            
             finResultMap.put('fPrice',fprice);
            
            if(PCode == 'BN'){
                PCode = 'BN-Brand Z';
            }else if(PCode == 'CN'){
                 PCode = 'CN-Item Z';
            }
            else if(PCode == 'DN'){
                 PCode = 'DN-Pric Book for Minimum GTM Customer';
            }else if(PCode == 'EN'){
                 PCode = 'EN-Set Z';
            }else if(PCode == 'GN'){
                 PCode = 'GN-Segment Z';
            }else if(PCode == 'KN'){
                 PCode = 'KN-Class Z';
            }else if(PCode == 'IN'){
                 PCode = 'Item with Quantity Breaks Z';
            }else if(PCode == 'MN'){
                 PCode = 'MN-Minimum GTM% Required';
            }else if(PCode == 'PN'){
                 PCode = 'PN-Pricebook';
            }else if(PCode == 'RN'){
                 PCode = 'RN-Regular usually broken carton';
            }else if(PCode == 'SBN'){
                 PCode = 'SN-Feature/Dead & Excess Item';
            }else if(PCode == 'TF'){
                 PCode = 'TF-Target Floor default, no pricebook or list Z';
            }else if(PCode == 'UN'){
                 PCode = 'UN-Subset Z';
            }else if(PCode == 'V'){
                 PCode = 'V_-Item Quantity Break National Account Z';
            }
            
            
             finResultMap.put('PCode',PCode);
             finResultMap.put('TPrice',TPrice);
             finResultMap.put('PPU',PPU);
             finResultMap.put('PU',PU);
             finResultMap.put('QU',QU);
             finResultMap.put('SP',SP);
            finResultMap.put('UOMPicklist',picklistValues);
            return finResultMap;
            
        }
        catch(Exception e)
        {
            ErrorsClass ec = new ErrorsClass();
            ec.description = e.getMessage();
            Response.Errors.add(ec);
            return null;
        }
        
       //  return finResultMap;
    }
    //Properties
    public RequestClass Request
    {
        get
        {
            if(Request == null) Request = new RequestClass();
            return Request;
        }
        set
        {
            Request = value;
        }
    }

    public ResponseClass Response
    {
        get
        {
            if(Response == null) Response = new ResponseClass();
            return Response;
        }
        set
        {
            Response = value;
        }
    }

}