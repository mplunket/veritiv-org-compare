//@isTest
public class ProductWrapper
{
    public ProductWrapper(Product2 productIn)
    {
        product = productIn;
    }

    public Product2 product
    {
        get
        {
            if(product == null) product = new Product2();
            return product;
        }
        set {product = value;}
    }
    
    public Boolean isSelected
    {
        get
        {
            if(isSelected == null) isSelected = false;
            return isSelected;
        }
        set {isSelected = value;}
    }
    
    public PricingAndAvailability PandA
    {
        get
        {
            if(PandA == null) PandA = new PricingAndAvailability();
            return PandA;
        }
        set {PandA = value;}
    }
    
    public Opportunity cost
    {
        get
        {
            if(PandA.Response.ItemDetails.size() > 0)
                return new Opportunity(Amount=Double.valueOf(PandA.Response.ItemDetails[0].ItemCostStandard));
            else
                return new Opportunity(Amount=0);
        }
    }
    
    public String uom
    {
        get
        {
            if(PandA.Response.ItemDetails.size() > 0)
                return PandA.Response.ItemDetails[0].ItemPricingUOM;
            else
                return '';
        }
    }
    
    public Opportunity price
    {
        get
        {   if(price != null) return  price;
            else  
                if(PandA.Response.ItemDetails.size() > 0)
                    return new Opportunity(Amount=Double.valueOf(PandA.Response.ItemDetails[0].ItemPricePerUOM));
            else
                return new Opportunity(Amount=0);
        }

        set;
    }

    public Opportunity startPrice
    {
        get
        {
            System.debug('%%% Start Price Product Wrapper: ' + PandA.Response.ItemDetails[0].ItemCTSDisplayPrice);
            if(PandA.Response.ItemDetails.size() > 0)
                return new Opportunity(Amount=Double.valueOf(PandA.Response.ItemDetails[0].ItemCTSDisplayPrice));
            else
                return new Opportunity(Amount=0);
        }
    }

    public Opportunity targetPrice
    {
        get
        {
            if(PandA.Response.ItemDetails.size() > 0)
            {
                return new Opportunity(
                    Amount=Double.valueOf(PandA.Response.ItemDetails[0].TargetPrice));
            }
            else
            {
                return new Opportunity(Amount = 0);
            }
        }
    }

    public Opportunity floorPrice
    {
        get
        {
            if(PandA.Response.ItemDetails.size() > 0)
            {
                return new Opportunity(
                    Amount = Double.valueOf(PandA.Response.ItemDetails[0].FloorPrice));
            }
            else
            {
                return new Opportunity(Amount = 0);
            }
        }
    }
    
    public String[] systemDivisions
    {
        get
        {
            String[] sysDivs = new String[0];
            for(PricingAndAvailability.AvailabilityClass ac : PandA.Response.Availability)
                sysDivs.add(ac.ItemSystemId + '-' + ac.ItemDivisionId);
            return sysDivs;
        }
    }
    
    public String[] quantityOnhand
    {
        get
        {
            String[] qtyOnhand = new String[0];
            for(PricingAndAvailability.AvailabilityClass ac : PandA.Response.Availability)
                qtyOnhand.add(ac.ItemQuantityOnhand);
            return qtyOnhand;
        }
    }
    
    public String[] stockingUOMs
    {
        get
        {
            String[] stockUOMs = new String[0];
            for(PricingAndAvailability.AvailabilityClass ac : PandA.Response.Availability)
                stockUOMs.add(ac.ItemStockingUOM);
            return stockUOMs;
        }
    }
    
    public String[] divisions
    {
        get
        {
            String[] divs = new String[0];
            for(PricingAndAvailability.AvailabilityClass ac : PandA.Response.Availability)
                divs.add(ac.Division);
            return divs;
        }
    }
    
    public String[] transferDays
    {
        get
        {
            String[] xferDays = new String[0];
            for(PricingAndAvailability.AvailabilityClass ac : PandA.Response.Availability)
                xferDays.add(ac.ItemTransferDays);
            return xferDays;
        }
    }
    /*
    public static testmethod void testProductWrapper()
    {
        Test.startTest();
        ProductWrapper pw = new ProductWrapper(null);
        Product2 p = pw.product;
        pw = new ProductWrapper(p);
        
        Boolean testSelect = pw.isSelected;
        System.assert(!testSelect);
        pw.isSelected = true; 
        testSelect = pw.isSelected;
        System.assert(testSelect);
        
        PricingAndAvailability paa = pw.PandA;
        System.assertNotEquals(null, paa);
        pw.PandA = paa;
        System.assertEquals(paa, pw.PandA);
        
        Opportunity opp = pw.cost;
        System.assertEquals(0, opp.Amount);
        String str = pw.uom;
        System.assertEquals('',str);
        
        opp = pw.price;
        System.assertEquals(0, opp.Amount);
        PricingAndAvailability.ItemDetailsClass idc = new PricingAndAvailability.ItemDetailsClass();
        idc.ItemCostStandard = String.valueOf(10.95);
        idc.ItemPricingUOM = 'EA';
        idc.ItemPricePerUOM = String.valueOf(10.95);
        pw.PandA.Response.ItemDetails.add(idc);
        opp = pw.cost;
        System.assertEquals(10.95, opp.Amount);
        str = pw.uom;
        System.assertEquals('EA', str);
        opp = pw.price;
        System.assertEquals(10.95, opp.Amount);
        String[] strs = pw.systemDivisions;
        System.assert(strs.size() == 0);
        strs = pw.quantityOnhand;
        System.assert(strs.size() == 0);
        strs = pw.stockingUOMs;
        System.assert(strs.size() == 0);
        strs = pw.divisions;
        System.assert(strs.size() == 0);
        strs = pw.transferDays;
        System.assert(strs.size() == 0);
        
        PricingAndAvailability.AvailabilityClass ac = new PricingAndAvailability.AvailabilityClass();
        ac.ItemSystemId = 'MA';
        ac.ItemDivisionId = '01';
        ac.ItemQuantityOnhand = '10';
        ac.ItemStockingUOM = 'CS';
        ac.ItemTransferDays = '1';
        pw.PandA.Response.Availability.add(ac);
        strs = pw.systemDivisions;
        System.assert(strs.size() == 1);
        System.assertEquals('MA-01', strs[0]);
        strs = pw.stockingUOMs;
        System.assert(strs.size() == 1);
        System.assertEquals('CS', strs[0]);
        strs = pw.quantityOnhand;
        System.assert(strs.size() == 1);
        System.assertEquals('10', strs[0]);
//        strs = pw.divisions;
//        System.assert(strs.size() == 1);
//        System.assertEquals('UNISOURCE - DES MOINES', strs[0]);
        strs = pw.transferDays;
        System.assert(strs.size() == 1);
        System.assertEquals('1', strs[0]);
        Test.stopTest();
    }*/
}