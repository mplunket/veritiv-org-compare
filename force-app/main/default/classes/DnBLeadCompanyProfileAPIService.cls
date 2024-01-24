public class DnBLeadCompanyProfileAPIService {
    public static void dnbCompanyProfileCallout(String leadId, String duns, Integer confidenceCode) {
        DnB_API_Settings__c dnbAPISettings = DnB_API_Settings__c.getOrgDefaults();        

        Lead lead = [SELECT Id FROM Lead WHERE Id = :leadId];
        lead.D_U_N_S__c = duns;
        lead.DnB_Confidence_Code__c = Integer.valueOf(confidenceCode);

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
            System.debug(response.getBody());
            DnBCompanyProfileResponse responseBody = (DnbCompanyProfileResponse) System.JSON.deserialize(response.getBody(), DnBCompanyProfileResponse.class);
            mapCompanyProfileResponseToLead(responseBody, lead);
            
            update lead;
        }
    }

    @TestVisible
    private static void mapCompanyProfileResponseToLead(DnBCompanyProfileResponse response, Lead lead) {
        if (response.organization != null) {
            if (response.organization.industryCodes != null && response.organization.industryCodes.size() > 0) {
                List<String> dnbIndustryCodes = new List<String>();

                for (DnBCompanyProfileResponse.IndustryCodes industryCode : response.organization.industryCodes) {
                    dnbIndustryCodes.add(industryCode.code + ': ' + industryCode.description);

                    if (industryCode.typeDescription.contains('North American Industry Classification System') && industryCode.priority == 1) {
                        lead.NAICS__c = industryCode.code;
                        lead.NAICSDescription__c = industryCode.description;
                        continue;
                    }

                    if (industryCode.typeDescription.contains('D&B Standard Industry Code') && industryCode.priority == 1) {
                        lead.SIC__c = industryCode.code;
                        lead.SICDescription__c = industryCode.description;
                        continue;
                    }
                }

                lead.DNB_Industry_Code__c = String.join(dnbIndustryCodes, '\n');            
            }

            List<DnBCompanyProfileResponse.Financials> financials = response.organization.financials;
            if (financials != null && financials.size() > 0) {
                if (financials[0].yearlyRevenue != null && financials[0].yearlyRevenue.size() > 0) {
                    lead.AnnualRevenue = response.organization.financials[0].yearlyRevenue[0].value;    
                    if (financials[0].yearlyRevenue[0].trend != null && financials[0].yearlyRevenue[0].trend.size() > 0) {
                        lead.D_B_Total_Sales_Growth_Percent__c = response.organization.financials[0].yearlyRevenue[0].trend[0].growthRate;                      
                    }       
                }
                /* commented out for Backlog Item-3355, similar to item-3285. Might be leftover code as it doesn't do anything 
                if (response.organization.financials[0].yearlyRevenue.size() > 0 && response.organization.financials[0].yearlyRevenue[0].trend.size() > 0) {
                }
                */
            }

            if (response.organization.telephone != null && response.organization.telephone.size() > 0) {
                lead.Phone = response.organization.telephone[0].telephoneNumber;
            }

            if (response.organization.corporateLinkage != null) {
                if (response.organization.corporateLinkage.parent != null) {
                    lead.ParentDunsNumber__c  = response.organization.corporateLinkage.parent.duns;             
                }
                if (response.organization.corporateLinkage.domesticUltimate != null) {
                    lead.DomesticUltimateDunsNumber__c = response.organization.corporateLinkage.domesticUltimate.duns;
                }
                if (response.organization.corporateLinkage.globalUltimate != null) {
                    lead.GlobalUltimateDunsNumber__c = response.organization.corporateLinkage.globalUltimate.duns;
                }
                if  (response.organization.corporateLinkage.familyTreeRolesPlayed != null
                        && response.organization.corporateLinkage.familyTreeRolesPlayed.size() > 0) {
                    lead.DC_Location_Type__c = response.organization.corporateLinkage.familyTreeRolesPlayed[0].description;
                }
            }

            if (response.organization.numberOfEmployees != null && response.organization.numberOfEmployees.size() > 0) {
                for (DnBCompanyProfileResponse.NumberOfEmployees noe : response.organization.numberOfEmployees) {
                    if (noe.informationScopeDescription == 'Consolidated') {
                        lead.Employees_Hoovers__c = noe.value;
                    } else if (noe.informationScopeDescription == 'Individual') {
                        lead.Number_of_Employees_Location__c  = String.valueOf(noe.value);
                    }
                }
                if(response.organization.numberOfEmployees[0].trend != null){
                    if  (response.organization.numberOfEmployees[0].trend.size() > 0) {
                        System.debug('Number of employees trends size: ' + response.organization.numberOfEmployees[0].trend.size());
                        lead.D_B_Total_Employees_Growth_Percent__c = response.organization.numberOfEmployees[0].trend[0].growthRate;
                    }   
                }
            }

            if (response.organization.tradeStyleNames != null && response.organization.tradeStyleNames.size() > 0) {
                lead.D_B_Doing_Business_As__c = response.organization.tradeStyleNames[0].name;
            }

            if (response.organization.websiteAddress != null && response.organization.websiteAddress.size() > 0) {
                lead.Website = response.organization.websiteAddress[0].url;
                lead.D_B_Primary_Web_Site__c = response.organization.websiteAddress[0].url;
            }
        
            if (response.organization.socioEconomicInformation != null) {
                lead.D_B_Minority_Owned__c = response.organization.socioEconomicInformation.isMinorityOwned != null ? 
                    response.organization.socioEconomicInformation.isMinorityOwned : false;
                lead.D_B_Small_Business_Flag__c = response.organization.socioEconomicInformation.isSmallBusiness != null ? 
                    response.organization.socioEconomicInformation.isSmallBusiness : false;
                lead.D_B_Woman_Owned_Flag__c = response.organization.socioEconomicInformation.isFemaleOwned != null ? 
                    response.organization.socioEconomicInformation.isFemaleOwned : false;
            }

            if (response.organization.businessEntityType != null) {
                lead.D_B_Company_Type__c = response.organization.businessEntityType.description;
            }

            if (response.organization.primaryAddress != null) {
                lead.Street = response.organization.primaryAddress.streetAddress.line1;
                lead.City = response.organization.primaryAddress.addressLocality.name;
                lead.State = response.organization.primaryAddress.addressRegion.abbreviatedName;
                lead.PostalCode = response.organization.primaryAddress.postalCode;
                lead.Country = response.organization.primaryAddress.addressCountry.isoAlpha2Code;

                if (response.organization.primaryAddress.premisesArea != null) {
                    lead.D_B_Address_Space__c = String.valueOf(response.organization.primaryAddress.premisesArea.measurement);
                    lead.D_B_Address_Space_Unit_of_Measure__c = response.organization.primaryAddress.premisesArea.unitDescription;
                }
            }


            lead.D_B_Year_Founded__c = response.organization.startDate; 
        }

        lead.Is_Being_Updated_From_DnB__c = true;   

        lead.DnB_Sync_Status__c = 'API Success' + '\n' 
            + 'D&B Success' + '\n'
            + 'Updated: ' + DateTime.now();
    }
}