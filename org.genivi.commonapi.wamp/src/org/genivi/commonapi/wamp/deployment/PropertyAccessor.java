package org.genivi.commonapi.wamp.deployment;

import java.util.List;

import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.core.FDeployedProvider;
import org.franca.deploymodel.core.FDeployedTypeCollection;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.deploymodel.dsl.fDeploy.FDString;
import org.franca.deploymodel.dsl.fDeploy.FDValue;
import org.genivi.commonapi.wamp.DeploymentInterfacePropertyAccessor;
import org.genivi.commonapi.wamp.DeploymentProviderPropertyAccessor;
import org.genivi.commonapi.wamp.DeploymentTypeCollectionPropertyAccessor;

public class PropertyAccessor extends org.genivi.commonapi.core.deployment.PropertyAccessor {

	DeploymentInterfacePropertyAccessor wampInterface_;
	DeploymentTypeCollectionPropertyAccessor wampTypeCollection_;
	DeploymentProviderPropertyAccessor wampProvider_;
	
	public PropertyAccessor() {
		wampInterface_ = null;
		wampTypeCollection_ = null;
		wampProvider_ = null;
	}
	
	public PropertyAccessor(FDeployedInterface _target) {
		super(_target);
		wampInterface_ = new DeploymentInterfacePropertyAccessor(_target);
		wampTypeCollection_ = null;
		wampProvider_ = null;
	}
	
	public PropertyAccessor(FDeployedTypeCollection _target) {
		super(_target);
		wampInterface_ = null;
		wampTypeCollection_ = new DeploymentTypeCollectionPropertyAccessor(_target);;
		wampProvider_ = null;
	}
	
	public PropertyAccessor(FDeployedProvider _target) {
		super(_target);
		wampInterface_ = null;
		wampTypeCollection_ = null;
		wampProvider_ = new DeploymentProviderPropertyAccessor(_target);
	}
	
	// TODO

	public String getWampInterfaceName (FDInterfaceInstance obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return wampProvider_.getWampInterfaceName(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	
	public String getWampObjectPath (FDInterfaceInstance obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return wampProvider_.getWampObjectPath(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	
	public String getWampServiceName (FDInterfaceInstance obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return wampProvider_.getWampServiceName(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

}
