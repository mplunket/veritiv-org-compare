public class DnBIdentityResolutionResponse {
	public List<MatchCandidate> matchCandidates;

	public class Organization {
        public String duns {get;}
        public String primaryName {get;}
        public List<Telephone> telephone {get;}
        public List<WebsiteAddress> websiteAddress {get;}
        public PrimaryAddress primaryAddress {get;}
	}

	public class MatchQualityInformation {
        public Integer confidenceCode {get;}
	}

	public class MatchCandidate {
        public Organization organization {get;}
        public MatchQualityInformation matchQualityInformation {get;}
	}
    
    public class Telephone {
        public String telephoneNumber {get;}
    }
    
    public class WebsiteAddress {
        public String url {get;}
    }
    
    public class PrimaryAddress {
        public AddressCountry addressCountry {get;}
        public AddressLocality addressLocality {get;}
        public AddressRegion addressRegion {get;}
        public String postalCode {get;}
        public StreetAddress streetAddress {get;}
    }
    
    public class AddressCountry {
        public String isoAlpha2Code {get;}
    }
    
    public class AddressLocality {
        public String name {get;}
    }
    
    public class AddressRegion {
        public String abbreviatedName {get;}
    }
    
    public class StreetAddress {
        public String line1 {get;}
    }
}