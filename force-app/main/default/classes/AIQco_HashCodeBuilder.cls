public without sharing class AIQco_HashCodeBuilder {
    private static Integer DEFAULT_INITIAL_VALUE = 17;
    private static Integer DEFAULT_MULTIPLIER_VALUE = 37;
    private Integer result;

    public AIQco_HashCodeBuilder() {
        result = DEFAULT_INITIAL_VALUE;
    }

    public AIQco_HashCodeBuilder append(Object obj) {
        if (obj == null) {
            result = DEFAULT_MULTIPLIER_VALUE * result;
        } else {
            result = DEFAULT_MULTIPLIER_VALUE * result + System.hashCode(obj);
        }
        return this;
    }

    public Integer toHashCode() {
        return result;
    }
}