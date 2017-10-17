package org.genivi.commonapi.wamp.verification;

public class Triple<FrancaPackage, TypeCollectionList, InterfaceList> {

    public final FrancaPackage packageName;
    public final TypeCollectionList typeCollectionList;
    public final InterfaceList interfaceList;

    public Triple(FrancaPackage packageName, TypeCollectionList typeCollectionList,
            InterfaceList interfaceList) {
        this.packageName = packageName;
        this.interfaceList = interfaceList;
        this.typeCollectionList = typeCollectionList;
    }

}