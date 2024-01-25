public class DnBCompanyProfileResponse {
	public TransactionDetail transactionDetail;
	public InquiryDetail inquiryDetail;
	public Organization organization;

	public class TradeStyleNames {
		public String name;
		public Integer priority;
	}

	public class YearlyRevenue {
		public Double value;
		public List<Trend> trend;
	}

	public class PremisesArea {
		public Double measurement;
		public String unitDescription;
		public Integer unitDnBCode;
		public String reliabilityDescription;
		public Integer reliabilityDnBCode;
	}

	public class PrimaryAddress {
		public OperatingStatus language;
		public AddressCountry addressCountry;
		public ContinentalRegion continentalRegion;
		public ContinentalRegion addressLocality;
		public String minorTownName;
		public AddressRegion addressRegion;
		public AddressCounty addressCounty;
		public String postalCode;
		public OperatingStatus postalCodePosition;
		public String streetNumber;
		public String streetName;
		public StreetAddress streetAddress;
		public PostOfficeBox postOfficeBox;
		public Double latitude;
		public Double longitude;
		public OperatingStatus geographicalPrecision;
		public Boolean isRegisteredAddress;
		public StatisticalArea statisticalArea;
		public OperatingStatus locationOwnership;
		public PremisesArea premisesArea;
		public Boolean isManufacturingLocation;
	}

	public class EmployeeCategories {
		public String employmentBasisDescription;
		public Integer employmentBasisDnBCode;
	}

	public class Organization {
		public String duns;
		public DunsControlStatus dunsControlStatus;
		public String primaryName;
		public List<TradeStyleNames> tradeStyleNames;
		public List<WebsiteAddress> websiteAddress;
		public List<Telephone> telephone;
		public List<Fax> fax;
		public PrimaryAddress primaryAddress;
		public RegisteredAddress registeredAddress;
		public MailingAddress mailingAddress;
		public List<StockExchanges> stockExchanges;
		public List<ThirdPartyAssessment> thirdPartyAssessment;
		public List<RegistrationNumbers> registrationNumbers;
		public List<IndustryCodes> industryCodes;
		public OperatingStatus businessEntityType;
		public String controlOwnershipDate;
		public OperatingStatus controlOwnershipType;
		public Boolean isAgent;
		public Boolean isImporter;
		public Boolean isExporter;
		public List<NumberOfEmployees> numberOfEmployees;
		public List<Financials> financials;
		public List<MostSeniorPrincipals> mostSeniorPrincipals;
		public List<MostSeniorPrincipals> currentPrincipals;
		public SocioEconomicInformation socioEconomicInformation;
		public Boolean isStandalone;
		public CorporateLinkage corporateLinkage;
		public String startDate;
	}

	public class Telephone {
		public String telephoneNumber;
		public String isdCode;
		public Boolean isUnreachable;
	}

	public class ExchangeCountry {
		public String isoAlpha2Code;
	}

	public class StreetAddress_Z {
		public String line1;
		public String line2;
		public String line3;
		public String line4;
	}

	public class AddressCountry {
		public String name;
		public String isoAlpha2Code;
		public String fipsCode;
	}

	public class IndustryCodes {
		public String code;
		public String description;
		public String typeDescription;
		public Integer typeDnBCode;
		public Integer priority;
	}

	public class NumberOfEmployees {
		public Integer value;
		public String informationScopeDescription;
		public Integer informationScopeDnBCode;
		public String reliabilityDescription;
		public Integer reliabilityDnBCode;
		public List<EmployeeCategories> employeeCategories;
		public List<Trend> trend;
	}

	public class AddressRegion_Z {
		public String name;
		public String abbreviatedName;
	}

	public class AddressCounty {
		public String name;
		public String fipsCode;
	}

	public class OperatingStatus {
		public String description;
		public Integer dnbCode;
	}

	public class PostOfficeBox {
		public String postOfficeBoxNumber;
		public String typeDescription;
		public Integer typeDnBCode;
	}

	public class GlobalUltimate {
		public String duns;
		public String primaryName;
		public PrimaryAddress_Z primaryAddress;
	}

	public class Financials {
		public String financialStatementToDate;
		public String financialStatementDuration;
		public String informationScopeDescription;
		public Integer informationScopeDnBCode;
		public String reliabilityDescription;
		public Integer reliabilityDnBCode;
		public String unitCode;
		public String accountantName;
		public List<YearlyRevenue> yearlyRevenue;
	}

	public class StatisticalArea {
		public String cbsaName;
		public String cbsaCode;
		public String economicAreaOfInfluenceCode;
		public PopulationRank populationRank;
	}

	public class TransactionDetail {
		public String transactionID;
		public String transactionTimestamp;
		public String inLanguage;
		public String productID;
		public String productVersion;
	}

	public class AddressRegion {
		public String name;
		public String abbreviatedName;
		public String fipsCode;
	}

	public class RegistrationNumbers {
		public String registrationNumber;
		public String typeDescription;
		public Integer typeDnBCode;
	}

	public class AddressCounty_Z {
	}

	public class AddressCountry_Z {
		public String name;
		public String isoAlpha2Code;
	}

	public class StockExchanges {
		public String tickerName;
		public ExchangeName exchangeName;
		public ExchangeCountry exchangeCountry;
		public Boolean isPrimary;
	}

	public class PopulationRank {
		public String rankNumber;
		public Integer rankDnBCode;
		public String rankDescription;
	}

	public class DunsControlStatus {
		public OperatingStatus operatingStatus;
		public Boolean isMarketable;
		public Boolean isMailUndeliverable;
		public Boolean isTelephoneDisconnected;
		public Boolean isDelisted;
		public List<OperatingStatus> subjectHandlingDetails;
		public String fullReportDate;
	}

	public class Trend {
		public OperatingStatus timePeriod;
		public Double growthRate;
	}

	public class ContinentalRegion {
		public String name;
	}

	public class MailingAddress {
		public OperatingStatus language;
		public AddressCountry_Z addressCountry;
		public ContinentalRegion continentalRegion;
		public ContinentalRegion addressLocality;
		public String minorTownName;
		public AddressRegion_Z addressRegion;
		public ContinentalRegion addressCounty;
		public String postalCode;
		public OperatingStatus postalCodePosition;
		public String postalRoute;
		public String streetNumber;
		public String streetName;
		public StreetAddress streetAddress;
		public PostOfficeBox postOfficeBox;
	}

	public class MostSeniorPrincipals {
		public String givenName;
		public String familyName;
		public String fullName;
		public String namePrefix;
		public String nameSuffix;
		public String gender;
		public List<JobTitles> jobTitles;
		public List<ManagementResponsibilities> managementResponsibilities;
	}

	public class WebsiteAddress {
		public String url;
		public String domainName;
	}

	public class ExchangeName {
		public String description;
	}

	public class PrimaryAddress_Z {
		public AddressCountry addressCountry;
		public ContinentalRegion continentalRegion;
		public ContinentalRegion addressLocality;
		public AddressRegion_Z addressRegion;
		public AddressCounty_Z addressCounty;
		public String postalCode;
		public StreetAddress streetAddress;
	}

	public class StreetAddress {
		public String line1;
		public String line2;
	}

	public class InquiryDetail {
		public String duns;
		public String productID;
		public String productVersion;
		public String tradeUp;
	}

	public class RegisteredAddress {
		public OperatingStatus language;
		public AddressCountry_Z addressCountry;
		public ContinentalRegion addressLocality;
		public String minorTownName;
		public AddressRegion_Z addressRegion;
		public ContinentalRegion addressCounty;
		public String postalCode;
		public OperatingStatus postalCodePosition;
		public String streetNumber;
		public String streetName;
		public StreetAddress_Z streetAddress;
		public PostOfficeBox postOfficeBox;
	}

	public class ThirdPartyAssessment {
		public String description;
		public Integer dnbCode;
		public String assessmentDate;
		public String value;
	}

	public class CorporateLinkage {
		public List<OperatingStatus> familytreeRolesPlayed;
		public Integer hierarchyLevel;
		public Integer globalUltimateFamilyTreeMembersCount;
		public GlobalUltimate globalUltimate;
		public GlobalUltimate domesticUltimate;
		public GlobalUltimate parent;
		public GlobalUltimate headQuarter;
	}

	public class JobTitles {
		public String title;
	}

	public class ManagementResponsibilities {
		public String description;
		public String mrcCode;
	}

	public class SocioEconomicInformation {
		public Boolean isMinorityOwned;
		public Boolean isSmallBusiness;
		public Boolean isFemaleOwned;
	}

	public class Fax {
		public String faxNumber;
		public String isdCode;
	}
}