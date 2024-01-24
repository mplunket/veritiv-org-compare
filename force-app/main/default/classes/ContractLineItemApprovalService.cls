global class ContractLineItemApprovalService {

    private static final String CLI_PREFIX = zpl__ContractLineItem__c.SObjectType.getDescribe().getKeyPrefix(); // 'a5He' in sandbox
    public static Map<Id, Contract_Line_Item_Approval__c> mNewCLIA = new Map<Id, Contract_Line_Item_Approval__c>();
    @TestVisible
    private static Date current_date = Date.today();
	
    @future
    public static void deleteContractLineItemApprovalsFuture(Set<Id> inactiveLineIds) {
        deleteContractLineItemApprovals(inactiveLineIds);
    }
    
    public static void deleteContractLineItemApprovals(Set<Id> inactiveLineIds) {
        List<Contract_Line_Item_Approval__c> deleteApprovals = [
            SELECT Id
            FROM Contract_Line_Item_Approval__c
            WHERE Contract_Line_Item__r.Id IN :inactiveLineIds];
        
        system.debug('##deleteApprovals: ' + deleteApprovals);
        system.debug('##deleteApprovals: ' + deleteApprovals.size());
        
        if (!deleteApprovals.isEmpty()) {delete deleteApprovals;}
    }

    @InvocableMethod(Label='CreateContractLineItemApprovals')
    public static void createContractLineItemApprovals(List<Id> ids) {

        system.debug('##HERE!');
        Map<Id, User> mapIdToUser;
        Map<String, String> mapLevelToField;
        Set<String> approvalsEmails = new Set<String>();
        Map<Contract_Line_Item_Approval__c, String> mapCliaToEmail = new Map<Contract_Line_Item_Approval__c, String>();
        List<Id> completedApprovals = new List<Id>();
        List<Contract_Line_Item_Approval__c> newClias = new List<Contract_Line_Item_Approval__c>();
        Id CLIAOpenRecordTypeId = Schema.SObjectType.Contract_Line_Item_Approval__c.getRecordTypeInfosByDeveloperName().get('CLIA_Open').getRecordTypeId();

        mapLevelToField = customSettingsFieldNames();

        if (mapLevelToField.isEmpty()) {
            return;
        }

        String idType = String.valueOf(ids[0]);

        Boolean isCli  = idType.startsWithIgnoreCase(CLI_PREFIX);

        Decimal timeFrameDays = SOQL_timeFrame();

        system.debug('##timeFrameDays: ' + timeFrameDays);

        List<Wrapper> wrappers = SOQL_Build(isCli, ids); // a wrapper of cli or clia

        mapIdToUser = SOQL_Users(
                String.join(mapLevelToField.values(), ','),
                buildOwnerIds(wrappers)
        );

        system.debug('##mapIdToUser: ' + mapIdToUser);
        system.debug('##mapIdToUser: ' + mapIdToUser.size());

        Integer numLevels = mapLevelToField.size();

        system.debug('##numLevels: ' + numLevels);

        Map<String, User> mapEmailToUser = new Map<String, User>();

        System.debug('##wrappers: ' + wrappers);
        System.debug('##wrappers: ' + wrappers.size());

        for (Wrapper wrapper : wrappers) {

            if (wrapper.isComplete(numLevels)) {
                System.debug('##Complete');
                completedApprovals.add(wrapper.getClia().Contract_Line_Item__c);

            } else {
                System.debug('##Not Complete');
                Contract_Line_Item_Approval__c newClia = wrapper.initClia(timeFrameDays);
                newClia.RecordTypeId = CLIAOpenRecordTypeId;

                // [cli, clia] --> source cli --> ownerId --> owner   -->|
                //                                                       |--> email
                // newClia --> approval sequence --> email field name -->|
        
                //String seq = V(newClia.Approval_Sequence__c);
                //String field = mapLevelToField.get(seq);
                //system.debug('@@' + field);
                zpl__ContractLineItem__c sourceCli = wrapper.SourceCli();
                Id ownerId = (Id) Validate(ownerId(sourceCli), 'No owner found for cli:' + wrapper);
                
                User owner = mapIdToUser.get(ownerId);                
                
                Id delegateId = DelegateId(owner, newClia.Approval_Sequence__c);                
                
                if (delegateId != null){
                    newClia.ownerId = delegateId;
                    system.debug('##delegated: ' + delegateId);
                }
                else{
                    // If the PSR have the field Contract_Line_Approver_Override__c filled on your user, use this manager
                    system.debug('##newClia.Approval_Sequence__c: ' + newClia.Approval_Sequence__c);
                    if (newClia.Approval_Sequence__c == 1 ){
                        
                        if(owner.Manager.Contract_Line_Approver_Override__c != null){
                            newClia.ownerId = owner.Manager.Contract_Line_Approver_Override__c;
                        }
                        else{
                            newClia.ownerId = owner.ManagerId;
                        }
                    }
                    //[START 02/03/2021] Simplus Case 26214 (Deal Manager - 1 step approval) - Commented out 
                    // for the second level use manager of manager from field Contract_Line_Approver_Override__r.Contract_Line_Approver_Override__c of PSR user
                    /*if (newClia.Approval_Sequence__c == 2 ){
                        system.debug('##newClia.Approval_Sequence__c: ' + newClia.Approval_Sequence__c);
                        if(owner.Manager.Manager.Contract_Line_Approver_Override__c != null){
                            newClia.ownerId = owner.Manager.Manager.Contract_Line_Approver_Override__c;
                        }
                        else{
                            newClia.ownerId = owner.Manager.ManagerId;
                        }
                    }*///[END 02/03/2021] Simplus Case 26214 (Deal Manager - 1 step approval) - Commented out 
                    
                }
                system.debug('RODNEY DEBUG @@@@'+newClia);
                system.debug('RODNEY DEBUG newClia ownerid, @@@@'+newClia.ownerid);
                system.debug('RODNEY DEBUG newClia ownername@@@@'+newClia.owner.name);
                system.debug('RODNEY DEBUG newClia owner email@@@@'+newClia.owner.email);
                newClias.add(newClia);

                //String email = V(owner.get(field));
                //mapCliaToEmail.put(newClia, email);

                //Validate(email, 'Email is missing for the cli: ' + wrapper + ' by looking into the field ' + field + ' of the user:' + ownerId + '-' + owner.Name);

                //pprovalsEmails.add(makeExampleEmail(email));
                //approvalsEmails.add(email);
            }
        }

        //for (User user : SOQL_UsersByEmails(approvalsEmails)) {
        //    mapEmailToUser.put(
        //            fixExampleEmail(user.Email),
        //            user
        //    );
        //}
        

        //List<Contract_Line_Item_Approval__c> newClias = new List<Contract_Line_Item_Approval__c>(mapCliaToEmail.keySet());

        //Map<Id, Id> userToDelegateMap = new Map<Id, Id>{};

        //for (Contract_Line_Item_Approval__c clia : newClias) {

            // clia --> email --> owner --> delegate --> id
          // String email = (String) Validate(mapCliaToEmail.get(clia),  'Email missing for the clia: ' + clia.Name);
          //  User owner   = (User)   Validate(mapEmailToUser.get(email), 'No user corresponding to the email: ' + email);

           // Id delegateId = DelegateId(owner);
           // if (delegateId != null){
           //     clia.OwnerId = delegateId;
           // }
            // If the PSR don't have the field Contract_Line_Approver_Override__c filled on your user, use owner by email
            //else if(clia.OwnerId == null){
            //    clia.OwnerId = owner.Id;                
            //}

            /*
            clia.OwnerId =
                  delegateId != null
                ? delegateId
                : owner.Id;
      */
       // }

        system.debug('##newClias: ' + newClias);
        system.debug('##newClias: ' + newClias.size());
        insert newClias;
        
        system.debug('##completedApprovals: ' + completedApprovals);
        system.debug('##completedApprovals: ' + completedApprovals.size());
        if (completedApprovals.size()>0) {
            // IMPORTANT
            AIQAgrLineApproval.approveAgrLine(completedApprovals);
        }

    }

    private static Id DelegateId(User owner, Decimal seq) {

        if (owner == null) return null;

        // system.debug('@@@ owner: ' + owner);
        // system.debug('@@@ Dates: ' + owner.Delegation_Start_Date__c + ' - ' + owner.Delegation_End_Date__c);
        //  system.debug('@@@ Delegated Appr: ' + owner.Pricing_Delegated_Approver__c);

        if (seq == 1 && owner.Manager.Delegation_Start_Date__c <= current_date &&
                                              current_date <= owner.Manager.Delegation_End_Date__c)
        {
            return owner.Manager.Pricing_Delegated_Approver__c; 
        }

        if (seq == 2 && owner.Manager.Manager.Delegation_Start_Date__c <= current_date &&
                                                current_date <= owner.Manager.Manager.Delegation_End_Date__c)
        {
            return owner.Manager.Manager.Pricing_Delegated_Approver__c; 
        }

        return null;

    }

    private static Object Validate(Object obj, String errorMessage) {
        if (obj == null) {
            throw new ContractLineItemApprovalServiceException(errorMessage);
        }
        return obj;
    }

    // private static String V(Object obj) {
    //     return String.valueOf(obj);
    // }

    // private static String makeExampleEmail(String email) {
    //     return ('' + email).replace('@', '=') + '@example.com';
    // }
    // private static String fixExampleEmail(String email) {
    //     return ('' + email).replace('=', '@').replace('@example.com','');
    // }

    private static Decimal SOQL_timeFrame(){
        List<Zilliant_Approval_Variables__c> variables = [SELECT SM_Timeframe_2__c FROM Zilliant_Approval_Variables__c];
        if (variables.size()==0) {
            throw new ContractLineItemApprovalServiceException('Veritiv Internal Error: Zilliant_Approval_Variables__c table is empty.');
        }
        return variables[0].SM_Timeframe_2__c;
    }

    public class ContractLineItemApprovalServiceException extends Exception {

    }

    private static Contract_Line_Item_Approval__c initCLIA(zpl__ContractLineItem__c cli, Decimal timeFrameDays) {
        Contract_Line_Item_Approval__c newClia = new Contract_Line_Item_Approval__c(
                Agreement_Score__c = cli.zpl__Contract__r.Score__c,
                Approval_Sequence__c = 1,
                Brand__c = cli.Brand__c,
                Campaign_Recommended_Cost__c = cli.FuturePricingCost__c,
                Campaign_Recommended_Price__c = cli.CampaignProposedValue__c,
                Class__c = cli.Class__c,
                Contract_Line_Item__c = cli.Id,
                Created_From_Quote__c = cli.LineSource__c == 'Q' ? true : false,
                Division__c = cli.Division_Code__c,
                Floor_Price__c = cli.Floor_Price__c,
                Item_Description__c = cli.Description__c,
                Item_Number__c = cli.zpl__Product__r.ProductCode,
                Item_Score__c = cli.CurrentScore__c,
                Sales_Requested_Price__c = cli.zpl__PolicyValue__c,
                Set__c = cli.Set__c,
                Status__c = 'Pending',
                Subset__c = cli.Subset__c,
                Target_Price__c = cli.Target_Price__c
        );

        newClia.Timeframe_days__c = timeFrameDays;

        return newClia;
    }


    private static Contract_Line_Item_Approval__c initCLIA(Contract_Line_Item_Approval__c clia) {
        return new Contract_Line_Item_Approval__c(
                Agreement_Score__c = clia.Agreement_Score__c,
                Approval_Sequence__c = clia.Approval_Sequence__c + 1,
                Brand__c = clia.Brand__c,
                Campaign_Recommended_Cost__c = clia.Campaign_Recommended_Cost__c,
                Campaign_Recommended_Price__c = clia.Campaign_Recommended_Price__c,
                Class__c = clia.Class__c,
                Contract_Line_Item__c = clia.Contract_Line_Item__c,
                Created_From_Quote__c = clia.Created_From_Quote__c,
                Division__c = clia.Division__c,
                Floor_Price__c = clia.Floor_Price__c,
                Item_Description__c = clia.Item_Description__c,
                Item_Number__c = clia.Item_Number__c,
                Item_Score__c = clia.Item_Score__c,
                Previous_Comments__c = mNewCLIA.containsKey(clia.Id) ? mNewCLIA.get(clia.Id).Comments__c : clia.Comments__c,
                Previous_Approval__c = clia.Id,
                Sales_Requested_Price__c = clia.Sales_Requested_Price__c,
                Set__c = clia.Set__c,
                Status__c = 'Pending',
                Subset__c = clia.Subset__c,
                Target_Price__c = clia.Target_Price__c
        );
    }

    private static List<Contract_Line_Item_Approval__c> SOQL_CLIA(List<Id> ids) {
        return [SELECT ID, Name, Contract_Line_Item__r.Name, Agreement_Score__c, Approval_Sequence__c, Brand__c, Campaign_Recommended_Cost__c, Campaign_Recommended_Price__c,
                Class__c, Contract_Line_Item__c, Created_From_Quote__c, Division__c, Floor_Price__c, Item_Description__c,
                Item_Number__c, Item_Score__c, Sales_Requested_Price__c, Comments__c, Set__c, Status__c, Subset__c, Target_Price__c, OwnerId,
                Contract_Line_Item__r.zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id,
                Contract_Line_Item__r.Published_By__c, Contract_Line_Item__r.Published_By__r.Id
        FROM Contract_Line_Item_Approval__c
        WHERE Id IN :ids];
    }

    private static List<zpl__ContractLineItem__c> SOQL_CLI(List<Id> ids) {
        return [SELECT zpl__Contract__r.Score__c, Name, zpl__Product__r.ProductCode, zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id, Brand__c,
                FuturePricingCost__c, CampaignProposedValue__c, Class__c, LineSource__c, Division_Code__c,
                Floor_Price__c, Description__c, CurrentScore__c, zpl__PolicyValue__c, Set__c, Subset__c,
                Target_Price__c, Published_By__c, Published_By__r.Id
        FROM zpl__ContractLineItem__c
        WHERE Id IN :ids];
    }

    public static Map<String, String> customSettingsFieldNames() {

        Map<String, String> mp = new Map<String, String>();

        for (CLIA_Levels__mdt s : [SELECT Level__c, Field_Name__c FROM CLIA_Levels__mdt]) {
            mp.put('' + Integer.valueOf(s.Level__c), s.Field_Name__c);
        }

        return mp;

    }

    private static Map<Id, User> SOQL_Users(String field, List<Id> contractAccountOwnerIds) {

        List<User> users = Database.query('SELECT ' + field + ', Name, ' +
        'Manager.Delegation_Start_Date__c, Manager.Delegation_End_Date__c, Manager.Pricing_Delegated_Approver__c , ' +
        'Manager.Manager.Delegation_Start_Date__c, Manager.Manager.Delegation_End_Date__c, Manager.Manager.Pricing_Delegated_Approver__c , ' +
        'Manager.Contract_Line_Approver_Override__c, Manager.Manager.Contract_Line_Approver_Override__c, Contract_Line_Approver_Override__r.Contract_Line_Approver_Override__c FROM User WHERE Id IN :contractAccountOwnerIds');

        return new Map<Id, User>(users);
    }

    // private static List<User> SOQL_UsersByEmails(Set<String> approvalsEmails) {
    //     return [
    //             SELECT Name, Email, Delegation_Start_Date__c, Delegation_End_Date__c, Pricing_Delegated_Approver__c
    //             FROM User
    //             WHERE Email IN :approvalsEmails
    //     ];
    // }
    

    private static List<Id> buildOwnerIds(List<Wrapper> cs) {
        List<Id> ownerIds = new List<Id>();
        for (Wrapper c : cs) {
            ownerIds.add(c.OwnerId());
        }
        return ownerIds;
    }

    private static Id ownerId(zpl__ContractLineItem__c cli) {
        //return cli.zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id;
        return cli.Published_By__r.Id;
    }

    public static List<Wrapper> SOQL_Build(Boolean isCli, List<Id> ids) {
        List<Wrapper> cs = new List<Wrapper>();

        if (isCli) {
            system.debug('##CLI');
            for (zpl__ContractLineItem__c cli :        SOQL_CLI(ids))  cs.add(new CliWrapper(cli));
        } else {
            system.debug('##CLIA');
            for (Contract_Line_Item_Approval__c clia : SOQL_CLIA(ids)) cs.add(new CliaWrapper(clia));
        }
        system.debug('##cs: ' + cs);
        system.debug('##cs: ' + cs.size());
        return cs;
    }


    public abstract class Wrapper {
        public abstract Id OwnerId();
        public abstract Contract_Line_Item_Approval__c initClia(Decimal timeDelay);
        public abstract String Seq();
        public abstract zpl__ContractLineItem__c SourceCli();
        public abstract Boolean isComplete(Integer mapLevelToFieldSize);
        public abstract Contract_Line_Item_Approval__c getClia();

    }

    public class CliWrapper extends Wrapper {
        private zpl__ContractLineItem__c cli;
        public CliWrapper(zpl__ContractLineItem__c cli) {
            this.cli = cli;
        }
        public override  Id OwnerId() {
            //return cli.zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id;
            return cli.Published_By__r.Id;
        }
        public override Contract_Line_Item_Approval__c initClia(Decimal timeDelay) {
            return ContractLineItemApprovalService.initCLIA(cli, timeDelay);
        }
        public override String Seq() {
            return '1';
        }
        public override zpl__ContractLineItem__c SourceCli() {
            return cli;
        }
        public override Boolean isComplete(Integer mapLevelToFieldSize) {
            return false;
        }
        public override Contract_Line_Item_Approval__c getClia() {
            return null; // not possible
        }
        public override String ToString() {
            return '(CLA - ' + cli.Id + ' ' + cli.Name + ')';
        }
    }

    public class CliaWrapper extends Wrapper {
        private Contract_Line_Item_Approval__c clia;
        public CliaWrapper(Contract_Line_Item_Approval__c clia) {
            this.clia = clia;
        }
        public override Id OwnerId() {
            //return clia.Contract_Line_Item__r.zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id;
            return clia.Contract_Line_Item__r.Published_By__r.Id;
        }
        public override Contract_Line_Item_Approval__c initClia(Decimal timeDelay) {
            return ContractLineItemApprovalService.initCLIA(clia);
        }
        public override String Seq() {
            return String.valueOf(clia.Approval_Sequence__c);
        }
        public override zpl__ContractLineItem__c SourceCli() {
            return clia.Contract_Line_Item__r;
        }
        public override Boolean isComplete(Integer totalNumOfSettings) {
            return clia.Approval_Sequence__c + 1 > totalNumOfSettings; // totalNumOfSettings is currently 2
        }
        public override Contract_Line_Item_Approval__c getClia() {
            return clia;
        }
        public override String ToString() {
            return '(CLA - ' + clia.Id + ' ' + clia.Name + ')';
        }

    }


}