public class QLIWrapper
{
    public QLIWrapper(Quote_Line_Item__c qliIn)
    {
        qli = qliIn;
    }

    public Quote_Line_Item__c qli
    {
        get
        {
            if(qli == null) qli = new Quote_Line_Item__c();
            return qli;
        }
        set {qli = value;}
    }    
    
    public Opportunity extendedCost
    {
        get
        {
            if(extendedCost == null) extendedCost = new Opportunity(Amount=0);
            return extendedCost;
        }
        set {extendedCost = value;}
    }

    public Boolean showPandA
    {
        get
        {
            if(showPandA == null) showPandA = false;
            return showPandA;
        }
        set {showPandA = value;}
    }
    
    public Boolean enableUOM
    {
        get
        {
            if(enableUOM == null) enableUOM = false;
            return enableUOM;
        }
        set {enableUOM = value;}
    }
    
    public SelectOption[] quantityUOMs
    {
        get
        {
            if(quantityUOMs ==  null) quantityUOMs = new SelectOption[0];
            return quantityUOMs;
        }
        set {quantityUOMs = value;}
    }
    
    public SelectOption[] priceUOMs
    {
        get
        {
            if(priceUOMs ==  null) priceUOMs = new SelectOption[0];
            return priceUOMs;
        }
        set {priceUOMs = value;}
    }
    
   public String gtmPercent
   {
    	get
    	{
    		gtmPercent = '';
    		//qli.GTM_percent__c == null && 
    		System.debug('Cost: ' + qli.Cost__c);
    		System.debug('Cost: ' + qli.Price__c);
    		if(qli.Cost__c != null && qli.Price__c != null && qli.Price__c != 0)
    		{
    			Decimal cost = qli.Cost__c;
				Decimal percent =  (1 - cost.divide(qli.Price__c, 4, System.RoundingMode.HALF_UP)) * 100;
				System.debug('GTM Percent decimal value:'+ percent);
				percent = percent.setScale(1, System.RoundingMode.HALF_UP);
				gtmPercent = percent.toPlainString();
				gtmPercent += '%';

				System.debug('GTM_Percent String Value:'+gtmPercent);
				
				return gtmPercent;
    		}
    		else if(qli.GTM_percent__c == null)
    		{
    			return gtmPercent;
    		}
    		else
    		{
    			System.debug('GTM !Null or cost or price is null:'+qli.GTM_percent__c);
    			gtmPercent = String.valueOf(qli.GTM_percent__c) + '%';
    			return gtmPercent;
    		}
    	}
    	set;
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
    
    
}