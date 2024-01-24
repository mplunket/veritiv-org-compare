trigger Quote on Quote__c (before update, after insert, after update) {

    if( trigger.isAfter )
    {
        if( trigger.isInsert )
        {
            //Granting Access Level to newly created Quotes
            AccessLevelServices.grantQuoteAccessToATMs( trigger.newMap );
        }
        else if( trigger.isUpdate )
        {
            //Updating the Access Level for migrated Quotes
            AccessLevelServices.grantAccessForMigratedQuotes( trigger.newMap, trigger.oldMap );

            List<Id> qIds = new List<Id>();
            List<Quote__c> quotesToUpdate = new List<Quote__c>();
            List<Quote_Line_Item__c> allQlis = new List<Quote_Line_Item__c>();

            for(Quote__c q : trigger.new)
            {
                if(trigger.oldMap.get(q.Id).Requested_Delivery_Date__c != q.Requested_Delivery_Date__c)
                {
                    qIds.add(q.Id);
                }
            }

            allQlis = [ SELECT Id, Projected_Delivery_Date__c, Quote__c
                        FROM Quote_Line_Item__c
                        WHERE Quote__c IN :qIds ];

            for(Quote_Line_Item__c qli : allQlis)
            {
                qli.Projected_Delivery_Date__c = trigger.newMap.get(qli.Quote__c).Requested_Delivery_Date__c;
            }

            try
            {
                update allQlis;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    Id errorId = allQlis[ ex.getDmlIndex(index) ].Quote__c;
                    trigger.newMap.get( errorId ).addError( ex );
                }
            }

            if(!Test.isRunningTest())
                 quotesToUpdate = QuoteModel.returnQuoteToRequester(trigger.newMap, trigger.oldMap);

            if(!quotesToUpdate.isEmpty())
            try
            {
                update quotesToUpdate;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    Id errorId = quotesToUpdate[ ex.getDmlIndex(index) ].Id;
                    trigger.newMap.get( errorId ).addError( ex );
                }
            }
        }
    }
    else if( trigger.isBefore )
    {
        List<Quote__c> quotesWithChangedAccounts = QuoteServices.filterQuotesForPSRUpdate( trigger.oldMap, trigger.new );
        QuoteServices.populatePSRAndIRepFromAccount( quotesWithChangedAccounts );
    }
}