public inherited sharing class AIQ_CBSSIDecreaseFinder {
    public class AIQ_CBSSIDecreaseFinderException extends Exception {
    }
    // move to formula field
    public static final Decimal COMPARISON_PRECISION = (Decimal) AIQZilliantConfiguration__c.getInstance().ComparisonPrecision__c;

    public static final String FIXED_PRICE = 'fixedPrice';
    public static final String CWT_FIXED = 'cwtFixed';
    public static final String LIST_DOWN = 'listDown';
    public static final String MAINTAIN_GTM = 'maintainGTM';
    public static final String NATIONAL_ACCOUNT = 'nationalAccount';

    private static DecreaseFinder marginDecreaseFinder;
    private static DecreaseFinder fixedDecreaseFinder;
    private static DecreaseFinder discountDecreaseFinder;
    private static DecreaseFinder nationalAccountFinder;

    public static DecreaseFinder getInstance(String policyTypeId) {
        if (policyTypeId == FIXED_PRICE || policyTypeId == CWT_FIXED) {
            if (fixedDecreaseFinder == null) {
                fixedDecreaseFinder = new FixedDecreaseFinder();
            }
            return fixedDecreaseFinder;
        }

        if (policyTypeId == MAINTAIN_GTM) {
            if (marginDecreaseFinder == null) {
                marginDecreaseFinder = new MarginDecreaseFinder();
            }
            return marginDecreaseFinder;
        }

        if (policyTypeId == LIST_DOWN) {
            if (discountDecreaseFinder == null) {
                discountDecreaseFinder = new DiscountDecreaseFinder();
            }
            return discountDecreaseFinder;
        }

        if (policyTypeId == NATIONAL_ACCOUNT) {
            if (nationalAccountFinder == null) {
                nationalAccountFinder = new NationalAccountFinder();
            }
            return nationalAccountFinder;
        }

        return new NoDecreaseFinder();
    }

    public interface DecreaseFinder {
        Boolean hasDecrease(zpl__ContractLineItem__c currentLine);
    }

    private class FixedDecreaseFinder implements DecreaseFinder {
        public Boolean hasDecrease(zpl__ContractLineItem__c currentLine) {
            currentLine.PriceDecreaseFlag__c = (currentLine.Net_Price__c == 0 || hasPriceDecreased(currentLine));
            return currentLine.PriceDecreaseFlag__c;
        }
    }

    private class MarginDecreaseFinder implements DecreaseFinder {
        public Boolean hasDecrease(zpl__ContractLineItem__c currentLine) {   
            if (AIQ_CommonUtil.nullToZero(currentLine.Net_Price__c)!= 0 && AIQ_CommonUtil.nullToZero(currentLine.PreviousPrice__c)!=0) {
                // Item, Subset, Set
                currentLine.PriceDecreaseFlag__c = hasPriceDecreased(currentLine);
            } else {
                // band vendor, vendor, class vendor, class
                currentLine.PriceDecreaseFlag__c = (AIQ_CommonUtil.nullToZero(currentLine.zpl__PolicyValue__c) < AIQ_CommonUtil.nullToZero(currentLine.PreviousValue__c));
            }
            return currentLine.PriceDecreaseFlag__c;
        }
    }

    private class DiscountDecreaseFinder implements DecreaseFinder {
        public Boolean hasDecrease(zpl__ContractLineItem__c currentLine) {
            if (AIQ_CommonUtil.nullToZero(currentLine.Net_Price__c)!= 0 && AIQ_CommonUtil.nullToZero(currentLine.PreviousPrice__c)!=0) {
                // Item, Subset, Set
                currentLine.PriceDecreaseFlag__c = hasPriceDecreased(currentLine);
            } else {
                // band vendor, vendor, class vendor, class
                currentLine.PriceDecreaseFlag__c = (AIQ_CommonUtil.nullToZero(currentLine.zpl__PolicyValue__c) < AIQ_CommonUtil.nullToZero(currentLine.PreviousValue__c));
            }
            return currentLine.PriceDecreaseFlag__c;
        }
    }

    private class NationalAccountFinder implements DecreaseFinder {
        public Boolean hasDecrease(zpl__ContractLineItem__c currentLine) {
            return currentLine.PriceDecreaseFlag__c = false;
        }
    }

    private class NoDecreaseFinder implements DecreaseFinder {
        public Boolean hasDecrease(zpl__ContractLineItem__c currentLine) {
            return false;
        }
    }


    private static Boolean hasPriceDecreased(zpl__ContractLineItem__c currentLine){
        return Math.abs(AIQ_CommonUtil.nullToZero(currentLine.Net_Price__c) - AIQ_CommonUtil.nullToZero(currentLine.PreviousPrice__c)) >=
            COMPARISON_PRECISION &&
            AIQ_CommonUtil.nullToZero(currentLine.Net_Price__c) < AIQ_CommonUtil.nullToZero(currentLine.PreviousPrice__c);
    }
    
}