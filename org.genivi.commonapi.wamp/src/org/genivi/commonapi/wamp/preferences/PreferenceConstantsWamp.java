package org.genivi.commonapi.wamp.preferences;

import org.genivi.commonapi.core.preferences.PreferenceConstants;

public interface PreferenceConstantsWamp extends PreferenceConstants
{
    public static final String SCOPE                 	= "org.genivi.commonapi.wamp.ui";
    public static final String PROJECT_PAGEID        	= "org.genivi.commonapi.wamp.ui.preferences.CommonAPIWampPreferencePage";

    // preference keys
    public static final String P_LICENSE_WAMP        	= P_LICENSE;
    public static final String P_OUTPUT_PROXIES_WAMP 	= P_OUTPUT_PROXIES;
    public static final String P_OUTPUT_STUBS_WAMP   	= P_OUTPUT_STUBS;
	public static final String P_OUTPUT_COMMON_WAMP     = P_OUTPUT_COMMON;
	public static final String P_OUTPUT_DEFAULT_WAMP	= P_OUTPUT_DEFAULT;
	public static final String P_OUTPUT_SUBDIRS_WAMP	= P_OUTPUT_SUBDIRS;
    public static final String P_GENERATE_COMMON_WAMP	= P_GENERATE_COMMON;
    public static final String P_GENERATE_PROXY_WAMP	= P_GENERATE_PROXY;
    public static final String P_GENERATE_STUB_WAMP     = P_GENERATE_STUB;
	public static final String P_LOGOUTPUT_WAMP        	= P_LOGOUTPUT;
	public static final String P_USEPROJECTSETTINGS_WAMP= P_USEPROJECTSETTINGS;
	public static final String P_GENERATE_CODE_WAMP     = P_GENERATE_CODE;
	public static final String P_GENERATE_DEPENDENCIES_WAMP = P_GENERATE_DEPENDENCIES;
	public static final String P_GENERATE_SYNC_CALLS_WAMP = P_GENERATE_SYNC_CALLS;
	public static final String P_ENABLE_WAMP_VALIDATOR  = "enableWampValidator";
}
