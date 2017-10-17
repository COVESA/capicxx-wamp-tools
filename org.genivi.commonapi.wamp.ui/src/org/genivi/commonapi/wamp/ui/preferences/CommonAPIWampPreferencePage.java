package org.genivi.commonapi.wamp.ui.preferences;

import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.jface.preference.FieldEditor;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.StringFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.genivi.commonapi.core.ui.preferences.FieldEditorOverlayPage;
import org.genivi.commonapi.core.ui.preferences.MultiLineStringFieldEditor;
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp;
import org.genivi.commonapi.wamp.ui.CommonApiWampUiPlugin;

/**
 * This class represents a preference page that is contributed to the
 * Preferences dialog. By subclassing <samp>FieldEditorOverlayPage</samp>..
 * <p>
 * This page is used to modify preferences. They are stored in the preference store that
 * belongs to the main plug-in class.
 */

public class CommonAPIWampPreferencePage extends FieldEditorOverlayPage implements IWorkbenchPreferencePage
{
    private FieldEditor license     = null;
    private FieldEditor proxyOutput = null;
    private FieldEditor stubOutput  = null;
    private FieldEditor commonOutput  = null;


    public CommonAPIWampPreferencePage()
    {
        super(GRID);
    }

    /**
     * Creates the field editors. Field editors are abstractions of the common
     * GUI blocks needed to manipulate various types of preferences. Each field
     * editor knows how to save and restore itself.
     */
    @Override
    public void createFieldEditors()
    {
        license = new MultiLineStringFieldEditor(PreferenceConstantsWamp.P_LICENSE_WAMP, "The header to insert for all generated files", 60,
                getFieldEditorParent());
        license.setLabelText(""); // need to set this parameter (seems to be a bug)
        addField(license);
        // output directory definitions
        commonOutput = new StringFieldEditor(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, "Output directory for the common part", 30,
        		getFieldEditorParent());
        addField(commonOutput);
        proxyOutput = new StringFieldEditor(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, "Output directory for proxies inside project",
                30, getFieldEditorParent());
        addField(proxyOutput);
        stubOutput = new StringFieldEditor(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, "Output directory for stubs inside project", 30,
                getFieldEditorParent());
        addField(stubOutput);

    }

    @Override
    protected void performDefaults()
    {
    	if(!projectSettingIsActive) {
    		DefaultScope.INSTANCE.getNode(PreferenceConstantsWamp.SCOPE).put(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP,
    				PreferenceConstantsWamp.DEFAULT_OUTPUT);
    		DefaultScope.INSTANCE.getNode(PreferenceConstantsWamp.SCOPE).put(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
    				PreferenceConstantsWamp.DEFAULT_OUTPUT);
    		DefaultScope.INSTANCE.getNode(PreferenceConstantsWamp.SCOPE).put(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP,
    				PreferenceConstantsWamp.DEFAULT_OUTPUT);

    		super.performDefaults();
    	}
    }

    @Override
    public void init(IWorkbench workbench)
    {
        if (!isPropertyPage())
            setPreferenceStore(CommonApiWampUiPlugin.getDefault().getPreferenceStore());
    }

    @Override
    protected String getPageId()
    {
        return PreferenceConstantsWamp.PROJECT_PAGEID;
    }

    @Override
    protected IPreferenceStore doGetPreferenceStore()
    {
        return CommonApiWampUiPlugin.getDefault().getPreferenceStore();
    }

    @Override
    public boolean performOk()
    {
    	if(!projectSettingIsActive) {
    		boolean result = super.performOk();

    		return result;
    	}
    	return true;
    }

}
