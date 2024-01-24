({
    getCode: function (component, event) {
        let country = event.getParam("arguments").country;
        if(country) {
            country = country.toUpperCase();
            if(["CANADA", "CAN", "CA"].includes(country)) {
                return "CA";
            } else if(["MEXICO", "MEX", "MX"].includes(country)) {
                return "MX";
            }
        }
        return "US";
    }
})