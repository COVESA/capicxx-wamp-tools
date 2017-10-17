package org.genivi.commonapi.wamp.ui.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp;
import org.genivi.commonapi.wamp.ui.CommonApiWampUiPlugin;

/**
 * Class used to initialize default preference values.
 */
public class PreferenceInitializerWamp extends AbstractPreferenceInitializer
{

    /*
     * (non-Javadoc)
     *
     * @see org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer#
     * initializeDefaultPreferences()
     */
    @Override
    public void initializeDefaultPreferences()
    {
        IPreferenceStore store = CommonApiWampUiPlugin.getDefault().getPreferenceStore();
        store.setDefault(PreferenceConstantsWamp.P_LICENSE_WAMP, PreferenceConstantsWamp.DEFAULT_LICENSE);
        store.setDefault(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
        store.setDefault(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
        store.setDefault(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP, true);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP, true);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP, true);
        store.setDefault(PreferenceConstantsWamp.P_USEPROJECTSETTINGS_WAMP, false);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP, true);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP, true);
        store.setDefault(PreferenceConstantsWamp.P_ENABLE_WAMP_VALIDATOR, true);
        store.setDefault(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP, true);
    }
}
