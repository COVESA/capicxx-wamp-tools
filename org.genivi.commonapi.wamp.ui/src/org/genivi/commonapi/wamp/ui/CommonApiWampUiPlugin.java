package org.genivi.commonapi.wamp.ui;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

public class CommonApiWampUiPlugin extends AbstractUIPlugin
{
    public static final String           PLUGIN_ID = "org.genivi.commonapi.wamp.ui"; //$NON-NLS-1$

    private static CommonApiWampUiPlugin INSTANCE;

    public CommonApiWampUiPlugin()
    {
    }

    @Override
    public void start(final BundleContext context) throws Exception
    {
        super.start(context);
        INSTANCE = this;
    }

    @Override
    public void stop(final BundleContext context) throws Exception
    {
        INSTANCE = null;
        super.stop(context);
    }

    public static CommonApiWampUiPlugin getInstance()
    {
        return INSTANCE;
    }

    public static CommonApiWampUiPlugin getDefault()
    {
        return INSTANCE;
    }
    
	public static IPreferenceStore getValidatorPreferences() {
		return INSTANCE.getPreferenceStore();
	}
}
