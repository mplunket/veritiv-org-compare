@RestResource(urlMapping='/swRest')
global with sharing class SWRestResource {
    
   
  
    @HttpGet
    global static list<sObject> doGet() {
        RestRequest req = RestContext.request;
       
        String uniqueId = req.params.get('accDWKey');
        String accName = req.params.get('accName');
        String accType = req.params.get('accType');
        String employeeId = req.params.get('employeeId');
        String returnVal = req.params.get('returnVal');
        
        //get user via employee id
        user userRec = [select id, email, Employee_ID__c  from user where Employee_ID__c = :employeeId and IsActive = true and UserType ='Standard' limit 1];
        
        //return user detail if only needed for user checking
        if(returnVal == 'user'){
            list<user> uList = new list<user>();
            uList.add(userRec);
            return uList;    
        }else{

            Map <id,Account> accList;
            //check if customer or Prospect
            if (accType == 'Customer'){
                accList = new Map<id,account>([SELECT Id, Name, Primary_Sales_Rep_Name__r.Name, BillingAddress, Prospect_Segment__c, Account_Vertical__c FROM Account WHERE Account_DW_Key__c = :uniqueId AND  RecordType.Name = 'Customer']);
            }else{
            //prospect
                accList = new Map<id,account>([SELECT Id, Name, Primary_Sales_Rep_Name__r.Name, BillingAddress, Prospect_Segment__c, Account_Vertical__c FROM Account WHERE Name = :accName AND  RecordType.Name = 'Prospect']);
            }
            
            //check if user has access   
            list <UserRecordAccess> userAccessList = new list <UserRecordAccess>([select RecordId FROM UserRecordAccess WHERE UserId =:userRec.id AND Recordid IN :accList.keyset() AND HasReadAccess = true ]);
            list <account> readAccList = new list<Account>();
            for (UserRecordAccess uAcc : userAccessList ){
                if(accList.containsKey(uAcc.RecordId)){
                    //add readable account to the list to be returned
                    readAccList.add(accList.get(uAcc.RecordId)); 
                }
            }
            
            return readAccList ;
        }
    }
  
  @HttpPost
    global static Product_Analysis__c  doPost(SWRestResource.pAWrapper pAWrap ) {
    
        if(pAWrap != null){
                                
            Product_Analysis__c pA = new Product_Analysis__c();
            pA.account__c = pAWrap.accId;
            pA.Current_Bottom_Load_Force__c = pAWrap.currentBottomLoadForce;
            pA.Current_Estimated_Annual_Cost__c = pAWrap.currentEstimatedAnnualCost;
            pA.Current_Film_Thickness_ga__c  = pAWrap.currentFilmThicknessGA;
            pA.Current_Film_Width_in__c = pAWrap.currentFilmWidthIN; 
            pA.Current_Item__c = pAWrap.currentItem;
            pA.Current_Manufacturer__c = pAWrap.currentManufacturer;
            pA.Current_Middle_Load_Force__c = pAWrap.currentMiddleLoadForce;
            pA.Current_Roll_Length_ft__c = pAWrap.currentRollLengthFT;
            pA.Current_Roll_Price__c = pAWrap.currentRollPrice;
            pA.Current_Rotations__c = pAWrap.currentRotations;
            pA.Current_Top_Load_Force__c = pAWrap.currentTopLoadForce;
            pA.Current_Total_Stretch__c = pAWrap.currentTotalStretch;
            pA.Current_Weight_oz__c = pAWrap.currentWeightOz;
            pA.Equipment_Type__c = pAWrap.equipmentType;
            pA.externalID__c = pAWrap.externalID;
            pA.Manufacturer_Model__c = pAWrap.manufacturerModel;
            pA.Pallet_Height_in__c = pAWrap.palletHeightInC;
            pA.Pallet_Length_in__c = pAWrap.palletLengthtInC;
            pA.Pallets_Per_Year__c = pAWrap.palletsPerYear;
            pA.Pallet_Type__c = pAWrap.palletType;
            pA.Pallet_Weight_lbs__c = pAWrap.palletWeightLbs;
            pA.Pallet_Width_in__c = pAWrap.palletWidthIn;
            pA.Proposed_Annual_Savings__c = pAWrap.proposedAnnualSavings; 
            pA.Proposed_Bottom_Load_Force__c = pAWrap.proposedBottomLoadForce; 
            pA.Proposed_Estimated_Annual_Cost__c = pAWrap.proposedEstimatedAnnualCost;
            pA.Proposed_Film_Thickness_ga__c = pAWrap.proposedFilmThicknessGa; 
            pA.Proposed_Film_Width_in__c = pAWrap.proposedFilmWidthIn;
            pA.Proposed_Item__c = pAWrap.proposedItem;
            pA.Proposed_Middle_Load_Force__c = pAWrap.proposedMiddleLoadForce;
            pA.Proposed_Percent_Savings__c = pAWrap.proposedPercentSavings;
            pA.Proposed_Roll_Length_ft__c = pAWrap.proposedRollLengthFt;
            pA.Proposed_Roll_Price__c = pAWrap.proposedRollPrice; 
            pA.Proposed_Rotations__c = pAWrap.proposedRotations;
            pA.Proposed_Top_Load_Force__c= pAWrap.proposedTopLoadForce;
            pA.Proposed_Total_Stretch__c= pAWrap.proposedTotalStretch;
            pA.Proposed_Weight_oz__c= pAWrap.proposedWeightOz;
            pA.Serial_Number__c= pAWrap.serialNumber;
            pA.Waste_Stream_Pounds_Reduction__c= pAWrap.wasteStream;
            pA.Plastic_Straws_Saved__c = pAWrap.plasticStraws;
            pA.Plastic_Bags_Saved__c = pAWrap.plasticBags;
            pA.Plastic_Bottles_Saved__c = pAWrap.plasticBottles;
            pA.Personal_Vehicle_Emissions__c = pAWrap.personalVehicleEmissions;
            pA.Barrels_of_Oil__c = pAWrap.barrelsOil;
            pA.Homes_Powered__c = pAWrap.homesPowered;
            pA.Film__c = pAWrap.film;
            pA.Pallets__c = pAWrap.pallets;
            pA.Truckloads__c = pAWrap.truckloads;
/*removed the following for initial release and will be included in a later release if it is determined to use
            pA.BarrelInd__c = pAWrap.barrelInd;
            pA.CarInd__c = pAWrap.carInd;
            pA.CoreInd__c = pAWrap.coreInd;
            pA.HomeInd__c = pAWrap.homeInd;
            pA.PalletInd__c = pAWrap.palletInd;
            pA.PlasticBagInd__c = pAWrap.plasticBagInd;
            pA.PlasticBottleInd__c = pAWrap.plasticBottleInd;
            pA.PlasticStrawInd__c = pAWrap.plasticStrawInd;
            pA.TruckInd__c = pAWrap.truckInd;
*/
            pA.ownerId = pAWrap.ownerId;
            pA.PDF_Link__c = pAWrap.pdfLink;
            
            insert pA;
            
            //requery to get the name
            Product_Analysis__c newPA = new Product_Analysis__c ();
            newPA = [select id, name, Account__r.Name from Product_Analysis__c where id = :pA.id limit 1];
                       
/*removed the following for initial release and will be included in a later release if it is determined to use
            //system.debug('The product analysis run:'+ pA);
            System.enqueueJob(new RenderPAPDFQueueable(newPA.Id));
*/
            
            
            return newPA ;
            //return pA.id;
            //return pA;
        }
        return null;
        
    }
    
    global class pAWrapper {
        public String accId; 
        public double currentBottomLoadForce; 
        public double currentEstimatedAnnualCost;
        public double currentFilmThicknessGA;
        public double currentFilmWidthIN;
        public String currentItem;
        public String currentManufacturer;
        public double currentMiddleLoadForce; 
        public double currentRollLengthFT;
        public double currentRollPrice;
        public double currentRotations;
        public double currentTopLoadForce;
        public double currentTotalStretch;
        public double currentWeightOz;
        public String equipmentType;
        public String externalID;
        public String manufacturerModel;
        public double palletHeightInC;
        public double palletLengthtInC;
        public double palletsPerYear;
        public String palletType;
        public double palletWeightLbs;
        public double palletWidthIn;
        public double proposedAnnualSavings;
        public double proposedBottomLoadForce;
        public double proposedEstimatedAnnualCost;
        public double proposedFilmThicknessGa;
        public double proposedFilmWidthIn;
        public String proposedItem;
        public double proposedMiddleLoadForce;
        public double proposedPercentSavings;
        public double proposedRollLengthFt;
        public double proposedRollPrice;
        public double proposedRotations;
        public double proposedTopLoadForce;
        public double proposedTotalStretch;
        public double proposedWeightOz;
        public String serialNumber;
        public double wasteStream;
        public double plasticStraws;
        public double plasticBags;
        public double plasticBottles;
        public double personalVehicleEmissions;
        public double barrelsOil;
        public double homesPowered;
        public double film;
        public double pallets;
        public double truckloads;
/*removed the following for initial release and will be included in a later release if it is determined to use
        public boolean barrelInd;
        public boolean carInd;
        public boolean coreInd;
        public boolean homeInd;
        public boolean palletInd;
        public boolean plasticBagInd;
        public boolean plasticBottleInd;
        public boolean plasticStrawInd;
        public boolean truckInd;
*/
        public String ownerId;
        public String pdfLink;
        
        }
    
}