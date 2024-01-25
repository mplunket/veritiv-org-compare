/**
 Objective: Ability to update additional field details on a Quote_Line_Item__c object
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class ViewAdditionalDetailsQuoteContExt {

	public Quote__c quote { get; private set; }

	public QuoteLineItemModel qliModel { get; private set; }

	private String quoteId;
	private String qliIds;

	public Boolean isValidQuote {
        get
        {
            if(isValidQuote == null)
            {
                if(quoteId == null)
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
        set
        {
            isValidQuote = value;
        }
    }

    public void saveQLI() {

    	List<Quote_Line_Item__c> qliList = new List<Quote_Line_Item__c>();
    	Quote_Line_Item__c qli;

    	for(QuoteLineItemModel qliModel : this.qliModel.getSelectedProducts()) {
    		qli = qliModel.getQuoteLineItem();
    		qli.Costing_unit_of_measure__c = qli.Price_unit_of_measure__c;
    		qliList.add(qli);
    	}
    	try {
    		update qliList;
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, 'Records updated successfully' ) );
    	} catch(DMLException dmle) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error while updating the records.', Consts.EMPTY_STRING));
    	}

    }


    public ViewAdditionalDetailsQuoteContExt(ApexPages.StandardController standardController) {

		this.quote          = (Quote__c)standardController.getRecord();

		this.quoteId        = ApexPages.currentPage().getParameters().get('id');
		this.qliIds         = ApexPages.currentPage().getParameters().get('qliIds');

		if(this.quoteId  == null || this.quoteId == Consts.EMPTY_STRING ||
		   this.qliIds == null || this.qliIds == Consts.EMPTY_STRING) {

		   	this.quoteId = null;
			 return;

		}

    	Set<Id> setOfQliIds = new Set<Id>();
    	for(String qliId :qliIds.split(','))
    	{
    		if( qliId != null && qliId != '' )
    		{
    			setOfQliIds.add(qliId);
    		}
    	}

		QuotesModel quoteModel = new QuotesModel(this.quote);
		this.qliModel = new QuoteLineItemModel(
											quoteModel,
											new Quote_Line_Item__c(),
											QuoteLineItemServices.getQuoteLineItem(quoteId, setOfQliIds));

    }

}