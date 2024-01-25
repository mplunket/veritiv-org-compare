public class DnBAccountCompanyProfileAPIService {
    public static void dnbCompanyProfileCallout(String accountId, String duns, Integer confidenceCode, string accName) {
        DnB_API_Settings__c dnbAPISettings = DnB_API_Settings__c.getOrgDefaults();        
        
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        acc.D_U_N_S__c = duns;
        acc.DnB_Confidence_Code__c = Integer.valueOf(confidenceCode);
        acc.Name = accName;
        system.debug(acc.Name +'acc.Name');
        HttpRequest request = new HttpRequest();
        request.setEndpoint(dnbAPISettings.Company_Profile_URL__c + '/' + duns + '?productId=cmpelk&versionId=v2');
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('authorization', 'Bearer ' + dnbAPISettings.DnB_API_Token__c);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            Map<String, Object> errorResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> error = (Map<String, Object>)errorResponse.get('error');
            
            String errorCode = (String)error.get('errorCode');
            String rawErrorMessage = (String)error.get('errorMessage');
            String labelErrorMessage;
            
            if (errorCode == '00040') {
                labelErrorMessage = Label.DnB_API_Error_00040;
            } else if (errorCode == '20502') {
                labelErrorMessage = Label.DnB_API_Error_20502;
            } else if (errorCode == '20504') {
                labelErrorMessage = Label.DnB_API_Error_20504;
            } else if (errorCode == '20505') {
                labelErrorMessage = Label.DnB_API_Error_20505;
            }
            
            if (labelErrorMessage != null) {
                throw new CalloutException(labelErrorMessage);
            } else {
                throw new CalloutException(errorCode + ': ' + rawErrorMessage);   
            }
        } else {
            System.debug('BODY'+response.getBody());
            //try{
                DnBCompanyProfileResponse responseBody = (DnbCompanyProfileResponse) System.JSON.deserialize(response.getBody(), DnBCompanyProfileResponse.class);
                mapCompanyProfileResponseToAccount(responseBody, acc);  
                System.debug('responseBody '+responseBody);
                System.debug('acc '+acc);
                update acc;
            //}catch(Exception e){
            //    System.debug(e.getMessage());
            //}
            
        }
    }
    
    @TestVisible
    private static void mapCompanyProfileResponseToAccount(DnBCompanyProfileResponse response, Account acc) {
        if (response.organization != null) {
            if (response.organization.industryCodes != null && response.organization.industryCodes.size() > 0) {
                List<String> dnbIndustryCodes = new List<String>();
                
                for (DnBCompanyProfileResponse.IndustryCodes industryCode : response.organization.industryCodes) {
                    dnbIndustryCodes.add(industryCode.code + ': ' + industryCode.description);
                    
                    if (industryCode.typeDescription.contains('North American Industry Classification System') && industryCode.priority == 1) {
                        acc.Naics_Code__c = industryCode.code;
                        acc.Naics_Description__c = industryCode.description; 
                        continue;
                    }
                    
                    if (industryCode.typeDescription.contains('D&B Standard Industry Code') && industryCode.priority == 1) {
                        acc.SIC = industryCode.code;
                        acc.SIC_Description__c = industryCode.description;
                        continue;
                    }
                }
                
                acc.DNB_Industry_Code__c = String.join(dnbIndustryCodes, '\n');         
            }
            
            List<DnBCompanyProfileResponse.Financials> financials = response.organization.financials;
            if (financials != null && financials.size() > 0) {
                if (financials[0].yearlyRevenue != null && financials[0].yearlyRevenue.size() > 0) {
                    acc.AnnualRevenue = response.organization.financials[0].yearlyRevenue[0].value; 
                    if (financials[0].yearlyRevenue[0].trend != null && financials[0].yearlyRevenue[0].trend.size() > 0) {
                        acc.D_B_Total_Sales_Growth_Percent__c = response.organization.financials[0].yearlyRevenue[0].trend[0].growthRate;                       
                    }       
                }
                /* commented out for Backlog item-3285. Might be leftover code as it doesn't do anything 
                if (response.organization.financials[0].yearlyRevenue.size() > 0 && response.organization.financials[0].yearlyRevenue[0].trend.size() > 0) {
                }*/
            }
            
            if (response.organization.telephone != null && response.organization.telephone.size() > 0) {
                acc.Phone = response.organization.telephone[0].telephoneNumber;
            }
            
            if (response.organization.corporateLinkage != null) {
                if (response.organization.corporateLinkage.parent != null) {
                    acc.Parent_Duns_Number__c = response.organization.corporateLinkage.parent.duns;             
                }
                if (response.organization.corporateLinkage.domesticUltimate != null) {
                    acc.Domestic_Ultimate_Duns_Number__c = response.organization.corporateLinkage.domesticUltimate.duns;
                }
                if (response.organization.corporateLinkage.globalUltimate != null) {
                    acc.Global_Ultimate_Duns_Number__c = response.organization.corporateLinkage.globalUltimate.duns;
                }
                if  (response.organization.corporateLinkage.familyTreeRolesPlayed != null
                     && response.organization.corporateLinkage.familyTreeRolesPlayed.size() > 0) {
                         acc.DC_Location_Type__c = response.organization.corporateLinkage.familyTreeRolesPlayed[0].description;
                     }
            }
            
            if (response.organization.numberOfEmployees != null && response.organization.numberOfEmployees.size() > 0) {
                for (DnBCompanyProfileResponse.NumberOfEmployees noe : response.organization.numberOfEmployees) {
                    if (noe.informationScopeDescription == 'Consolidated') {
                        acc.Employees_Hoovers__c = noe.value;
                    } else if (noe.informationScopeDescription == 'Individual') {
                        acc.DC_Number_of_Employees_Location__c = String.valueOf(noe.value);
                    }
                }
                if(response.organization.numberOfEmployees[0].trend != null){
                    if  (response.organization.numberOfEmployees[0].trend.size() > 0) {
                        System.debug('Number of employees trends size: ' + response.organization.numberOfEmployees[0].trend.size());
                        acc.D_B_Total_Employees_Growth_Percent__c = response.organization.numberOfEmployees[0].trend[0].growthRate;
                    }   
                }
            }
            
            if (response.organization.tradeStyleNames != null && response.organization.tradeStyleNames.size() > 0) {
                for (DnBCompanyProfileResponse.TradeStyleNames tsn : response.organization.tradeStyleNames) {
                    if (tsn.priority == 1) {
                        acc.D_B_Doing_Business_As__c = response.organization.tradeStyleNames[0].name;
                        break;
                    }
                }
            }
            
            if (response.organization.websiteAddress != null && response.organization.websiteAddress.size() > 0) {
                acc.Website = response.organization.websiteAddress[0].url;
                acc.D_B_Primary_Web_Site__c = response.organization.websiteAddress[0].url;
            }
            
            if (response.organization.socioEconomicInformation != null) {
                acc.D_B_Minority_Owned__c = response.organization.socioEconomicInformation.isMinorityOwned != null ? 
                    response.organization.socioEconomicInformation.isMinorityOwned : false;
                acc.D_B_Small_Business_Flag__c = response.organization.socioEconomicInformation.isSmallBusiness != null ? 
                    response.organization.socioEconomicInformation.isSmallBusiness : false;
                acc.D_B_Woman_Owned_Flag__c = response.organization.socioEconomicInformation.isFemaleOwned != null ? 
                    response.organization.socioEconomicInformation.isFemaleOwned : false;
            }
            
            if (response.organization.businessEntityType != null) {
                acc.D_B_Company_Type__c = response.organization.businessEntityType.description;
            }
            
            if (response.organization.primaryAddress != null) {
                acc.BillingStreet = response.organization.primaryAddress.streetAddress.line1;
                acc.BillingCity = response.organization.primaryAddress.addressLocality.name;
                acc.BillingState = response.organization.primaryAddress.addressRegion.abbreviatedName;
                acc.BillingPostalCode = response.organization.primaryAddress.postalCode;
                acc.BillingCountry = response.organization.primaryAddress.addressCountry.isoAlpha2Code;
                
                if (response.organization.primaryAddress.premisesArea != null) {
                    acc.D_B_Address_Space__c = String.valueOf(response.organization.primaryAddress.premisesArea.measurement);
                    acc.D_B_Address_Space_Unit_of_Measure__c = response.organization.primaryAddress.premisesArea.unitDescription;
                }
            }
            
            acc.D_B_Year_Founded__c = response.organization.startDate;
        }   
        
        acc.Is_Being_Updated_From_DnB__c = true;    
        
        acc.DnB_Sync_Status__c = 'API Success' + '\n' 
            + 'D&B Success' + '\n'
            + 'Updated: ' + DateTime.now();
    }
}