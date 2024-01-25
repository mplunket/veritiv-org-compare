public without sharing class AIQ_CommonUtil {
    public static List<Id> setToListIds(Set<Id> elements) {
        return new List<Id>(elements);
    }

    public static List<String> setToListStrings(Set<String> elements) {
        return new List<String>(elements);
    }

    public static Set<Id> toIdSet(List<SObject> records) {
        return new Map<Id, SObject>(records).keySet();
    }

    public static List<Id> toIdList(List<SObject> records) {
        return setToListIds(new Map<Id, SObject>(records).keySet());
    }

    public static Decimal nullToZero(Decimal value) {
        return value != null ? value : 0.00;
    }

    public static String nullToString(String value) {
        return value != null ? value : '';
    }

    public static String getGuid() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid =
            h.substring(0, 8) +
            '-' +
            h.substring(8, 12) +
            '-' +
            h.substring(12, 16) +
            '-' +
            h.substring(16, 20) +
            '-' +
            h.substring(20);
        return guid;
    }
}