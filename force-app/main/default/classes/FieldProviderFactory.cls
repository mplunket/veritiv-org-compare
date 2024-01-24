/*
DEPRECATED.
    For standardProfileProvider, please use:
        SObjectFieldProviders.standardProfileProvider

    For other field providers, please call the constructors directly.

 */
public class FieldProviderFactory {
    public static IFieldProvider standardProfileProvider {
        get { return SObjectParentProviders.standardProfileProvider; }
    }

    public static IFieldProvider provideList(List<Object> values) {
        return new SObjectFieldProviders.ListProvider(values);
    }
    public static IFieldProvider provideList(Set<Id> ids) {
        return new SObjectFieldProviders.ListProvider(new List<Id>(ids));
    }

    public static IFieldProvider provideUniqueString() {
        return new SObjectFieldProviders.UniqueStringProvider();
    }
    public static IFieldProvider provideUniqueString(String base) {
        return new SObjectFieldProviders.UniqueStringProvider(base);
    }
    public static IFieldProvider provideUniqueFixedLengthString(Integer length) {
        return new SObjectFieldProviders.UniqueFixedLengthStringProvider(length);
    }

    public static IFieldProvider provideUniqueFixedLengthString(String base, Integer length) {
        return new SObjectFieldProviders.UniqueFixedLengthStringProvider(base, length);
    }

    public static IFieldProvider provideGenericId(Schema.SObjectType sObjectType) {
        return new SObjectParentProviders.GenericParentProvider(sObjectType);
    }
}