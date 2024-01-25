public class PrimarySalesRepServices
{
    public static String errors = '';
    public static Boolean batchRunning = false; 
    public static List<Opportunity> getOpportunitiesByPSR( List<Primary_Sales_Rep__c> psrs )
    {   

        List<Opportunity> opportunitiesToReturn = [ SELECT iRep__c, Primary_Sales_Rep_Name__c, PSR_ZM_SM_Email__c, PSR_GSM_Email__c,
                                                        PSR_BDM_RVP_Email__c, Id, Email_iRep_ZM_SM__c, Email_iRep_VP__c,
                                                        Email_iRep_TL__c, Email_iRep_Pres__c, Email_iRep_GSM__c, Email_iRep_Dir__c,
                                                        Email_iRep_DMD__c, Email_iRep_BDM_RVP__c, Email_PSR_DMD__c
                                                    FROM Opportunity
                                                    WHERE ((Primary_Sales_Rep_Name__c != NULL AND Primary_Sales_Rep_Name__c IN :psrs )
                                                    OR (iRep__c != NULL AND iRep__c IN :psrs ))
                                                    AND IsClosed = false];
        return opportunitiesToReturn;
    }


    public static Opportunity copyPSREmailFields( Opportunity opportunity, Primary_Sales_Rep__c psr)
    {
        opportunity.PSR_ZM_SM_Email__c  = psr.email_zm_sm__c;
        opportunity.PSR_VP_Email__c     = psr.email_vp__c;
        opportunity.PSR_Pres_Email__c   = psr.email_pres__c;
        opportunity.Email_PSR_Dir__c    = psr.email_dir__c;
        opportunity.PSR_BDM_RVP_Email__c = psr.email_bdm_rvp__c;
        opportunity.PSR_GSM_Email__c    = psr.GSM_Email__c;
        opportunity.PSR_TL_Email__c     = psr.Email_TL__c;
        opportunity.Email_PSR_DMD__c    = psr.Email_DMD__c;

        return opportunity;
    }

    public static Opportunity copyIRepEmailFields( Opportunity opportunity, Primary_Sales_Rep__c iRep )
    {
        opportunity.Email_iRep_ZM_SM__c  = iRep.email_zm_sm__c;
        opportunity.Email_iRep_VP__c    = iRep.email_vp__c;
        opportunity.Email_iRep_Pres__c  = iRep.email_pres__c;
        opportunity.Email_iRep_Dir__c   = iRep.email_dir__c;
        opportunity.Email_iRep_BDM_RVP__c = iRep.email_bdm_rvp__c;
        opportunity.Email_iRep_GSM__c   = iRep.GSM_Email__c;
        opportunity.Email_iRep_TL__c    = iRep.Email_TL__c;
        opportunity.Email_iRep_DMD__c   = iRep.Email_DMD__c;

        return opportunity;
    }

    public static void updateOpportunityEmailFieldsFromPSRs( List<Primary_Sales_Rep__c> psrs )
    {

        List<Opportunity> opportunities = getOpportunitiesByPSR( psrs );

        Map<Id, Primary_Sales_Rep__c> psrMap = new Map<Id, Primary_Sales_Rep__c>( psrs );

        for(Opportunity opportunity : opportunities )
        {
            //System.debug(opportunity);
            if(opportunity.Primary_Sales_Rep_Name__c != null
                && psrMap.containsKey( opportunity.Primary_Sales_Rep_Name__c ))
            {
                copyPSREmailFields(opportunity, psrMap.get(opportunity.Primary_Sales_Rep_Name__c));
            }

            if(opportunity.iRep__c != null
                && psrMap.containsKey( opportunity.iRep__c ))
            {
                copyIRepEmailFields(opportunity, psrMap.get(opportunity.iRep__c));
            }
        }

        try
        {
            update opportunities;
        }
        catch(System.DMLException ex)
        { 
            for (Integer i = 0; i< ex.getNumDml(); i++)
            {
                Opportunity errorOpp = opportunities[ex.getDmlIndex(i)];
                if( errorOpp.Primary_Sales_Rep_Name__c != null
                    && psrMap.containsKey( errorOpp.Primary_Sales_Rep_Name__c ) )
                {
                    Primary_Sales_Rep__c errorPSR = psrMap.get(errorOpp.Primary_Sales_Rep_Name__c);
                    errorPSR.addError( 'There was a problem updating a related opportunity:'+ ex.getDmlMessage(i) );
                }
                if( errorOpp.iRep__c != null
                    && psrMap.containsKey( errorOpp.iRep__c ) )
                {
                    Primary_Sales_Rep__c errorPSR = psrMap.get(errorOpp.iRep__c);
                    errorPSR.addError( 'There was a problem updating a related opportunity:'+ ex.getDmlMessage(i) );
                }
            }
        }
    }
    public static Map<String, List<Primary_Sales_Rep__c>> filterPrimarySalesRepWithChangeVerticals( List<Primary_Sales_Rep__c> incomingPrimarySalesReps, Map<Id, Primary_Sales_Rep__c> oldPrimarySalesRepIdToOldPrimarySalesRep )
    {
        Map<String, List<Primary_Sales_Rep__c>> verticalNameToPrimarySalesRepList = new Map<String, List<Primary_Sales_Rep__c>>();

        //For All PrimarySalesReps that were sent to our trigger
        for( Primary_Sales_Rep__c incomingPrimarySalesRep : incomingPrimarySalesReps )
        {
            //Change conditions
            //1. Vertical is now being set
            //2. Vertical is being changed

            Boolean isChanged;
            Boolean isInsert = oldPrimarySalesRepIdToOldPrimarySalesRep == null;
            Primary_Sales_Rep__c oldPrimarySalesRep = isInsert ? null : oldPrimarySalesRepIdToOldPrimarySalesRep.get( incomingPrimarySalesRep.Id );

            isChanged = ( ( isInsert && incomingPrimarySalesRep.Vertical_Major__c != null )
            || ( !isInsert && oldPrimarySalesRep.Vertical_Major__c != incomingPrimarySalesRep.Vertical_Major__c) );

            if( isChanged )
            {
                if( !verticalNameToPrimarySalesRepList.containsKey( incomingPrimarySalesRep.Vertical_Major__c ) )
                {
                    verticalNameToPrimarySalesRepList.put( incomingPrimarySalesRep.Vertical_Major__c, new List<Primary_Sales_Rep__c>{ incomingPrimarySalesRep });
                }
                else
                {
                    verticalNameToPrimarySalesRepList.get( incomingPrimarySalesRep.Vertical_Major__c ).add( incomingPrimarySalesRep );
                }
            }
        }

        return verticalNameToPrimarySalesRepList;
    }

    public static void setPrimarySalesRepVerticalMajor(Map<String, List<Primary_Sales_Rep__c>> verticalNameToPrimarySalesRepList)
    {
        List<Primary_Sales_Rep__c> PrimarySalesRepsToUpdate = new List<Primary_Sales_Rep__c>();

        if( !verticalNameToPrimarySalesRepList.isEmpty())
        {
            for(Verticals__c verticalsFound : [SELECT Id, Name FROM Verticals__c WHERE Name in :verticalNameToPrimarySalesRepList.keySet()])
            {
              // Added by Sujitha
              if(verticalsFound!=null && verticalNameToPrimarySalesRepList.containsKey(verticalsFound.Name))
               {
                for( Primary_Sales_Rep__c primarySalesRepToUpdate : verticalNameToPrimarySalesRepList.get(verticalsFound.Name))
                {
                    Primary_Sales_Rep__c newPrimarySalesRepToUpdate = new Primary_Sales_Rep__c(Id = primarySalesRepToUpdate.id, Vertical_Major_Page__c = verticalsFound.id);
                    primarySalesRepsToUpdate.add( newPrimarySalesRepToUpdate );
                }
              }
            }
        }

        if( !primarySalesRepsToUpdate.isEmpty())
            update primarySalesRepsToUpdate;
    }

    public static Map<String, List<Primary_Sales_Rep__c>> filterPrimarySalesRepWithChangedMinorVerticals( List<Primary_Sales_Rep__c> incomingPrimarySalesReps, Map<Id, Primary_Sales_Rep__c> oldPrimarySalesRepIdToOldPrimarySalesRep )
    {

        Map<String, List<Primary_Sales_Rep__c>> verticalNameToPrimarySalesRepList = new Map<String, List<Primary_Sales_Rep__c>>();

        //For All PrimarySalesReps that were sent to our trigger
        for(Primary_Sales_Rep__c incomingPrimarySalesRep : incomingPrimarySalesReps )
        {
            //Change conditions
            //1. Vertical is now being set
            //2. Vertical is being changed

            Boolean isChanged;
            Boolean isInsert = oldPrimarySalesRepIdToOldPrimarySalesRep == null;
            Primary_Sales_Rep__c oldPrimarySalesRep = isInsert ? null : oldPrimarySalesRepIdToOldPrimarySalesRep.get( incomingPrimarySalesRep.Id );

            isChanged = ( ( isInsert && incomingPrimarySalesRep.Vertical_Minor__c != null)
            || ( !isInsert && oldPrimarySalesRep.Vertical_Minor__c != incomingPrimarySalesRep.Vertical_Minor__c) );

            if( isChanged )
            {
                if( !verticalNameToPrimarySalesRepList.containsKey ( incomingPrimarySalesRep.Vertical_Minor__c ) )
                {
                    verticalNameToPrimarySalesRepList.put( incomingPrimarySalesRep.Vertical_Minor__c, new List<Primary_Sales_Rep__c> { incomingPrimarySalesRep });
                }
                else
                {
                    verticalNameToPrimarySalesRepList.get( incomingPrimarySalesRep.Vertical_Minor__c ).add( incomingPrimarySalesRep );
                }
            }

        }
        return verticalNameToPrimarySalesRepList;
    }

    public static void setPrimarySalesRepVerticalMinors(Map<String, List<Primary_Sales_Rep__c>> verticalNameToPrimarySalesRepList)
    {

        List<Primary_Sales_Rep__c> PrimarySalesRepsToUpdate = new List<Primary_Sales_Rep__c>();

        if( !verticalNameToPrimarySalesRepList.isEmpty())
        {
            for(Verticals__c verticalsFound : [SELECT Id, Name FROM Verticals__c WHERE Name in :verticalNameToPrimarySalesRepList.keySet()])
            {
                for( Primary_Sales_Rep__c primarySalesRepToUpdate : verticalNameToPrimarySalesRepList.get(verticalsFound.Name))
                {
                    Primary_Sales_Rep__c newPrimarySalesRepToUpdate = new Primary_Sales_Rep__c(Id = primarySalesRepToUpdate.id, Vertical_Minor_Page__c = verticalsFound.id);
                    primarySalesRepsToUpdate.add( newPrimarySalesRepToUpdate );
                }
            }
        }

        if( !primarySalesRepsToUpdate.isEmpty())
            update primarySalesRepsToUpdate;
    }
    
    public static List<Primary_Sales_Rep__c> getRelatedPSRs(List<Opportunity> opps)
    {
        Set<Id> primarySalessAndiRepIds = Pluck.ids('Primary_Sales_Rep_Name__c', opps );
        primarySalessAndiRepIds.addAll(Pluck.ids('iRep__c', opps));
                                                    
        return [SELECT email_zm_sm__c,email_vp__c, email_pres__c, email_dir__c, email_bdm_rvp__c, GSM_Email__c, Email_TL__c, Email_DMD__c FROM Primary_Sales_Rep__c WHERE Id IN:primarySalessAndiRepIds];
    }
    
    
    public static void updateOpportunityEmailFieldsFromPSRs( List<Opportunity> opportunities )
    {
        
        List<Primary_Sales_Rep__c> psrs = getRelatedPSRs( opportunities );

        Map<Id, Primary_Sales_Rep__c> psrMap = new Map<Id, Primary_Sales_Rep__c>( psrs );

        for(Opportunity opportunity : opportunities )
        {
            System.debug(opportunity);
            if(opportunity.Primary_Sales_Rep_Name__c != null
                && psrMap.containsKey( opportunity.Primary_Sales_Rep_Name__c ))
            {
                copyPSREmailFields(opportunity, psrMap.get(opportunity.Primary_Sales_Rep_Name__c));
            }

            if(opportunity.iRep__c != null
                && psrMap.containsKey( opportunity.iRep__c ))
            {
                copyIRepEmailFields(opportunity, psrMap.get(opportunity.iRep__c));
            }
            System.debug(opportunity);
        }

        try
        {
            update opportunities;
        }
        catch(System.DMLException ex)
        {
            for (Integer i = 0; i< ex.getNumDml(); i++)
            {
                Opportunity errorOpp = opportunities[ex.getDmlIndex(i)];
                if( errorOpp.Primary_Sales_Rep_Name__c != null
                    && psrMap.containsKey( errorOpp.Primary_Sales_Rep_Name__c ) )
                {
                    Primary_Sales_Rep__c errorPSR = psrMap.get(errorOpp.Primary_Sales_Rep_Name__c);
                    errorPSR.addError( 'There was a problem updating a related opportunity:'+ ex.getDmlMessage(i) );
                    errors +=  String.valueOf(ex.getDMLMessage(i));
                }
                if( errorOpp.iRep__c != null
                    && psrMap.containsKey( errorOpp.iRep__c ) )
                {
                    Primary_Sales_Rep__c errorPSR = psrMap.get(errorOpp.iRep__c);
                    errorPSR.addError( 'There was a problem updating a related opportunity:'+ ex.getDmlMessage(i) );
                    errors +=  String.valueOf(ex.getDMLMessage(i));
                }
            }
        }
    }
}