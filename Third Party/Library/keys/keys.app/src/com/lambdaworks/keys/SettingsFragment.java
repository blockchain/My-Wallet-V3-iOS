// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.preference.PreferenceScreen;
import android.text.Html;
import android.util.Log;

public class SettingsFragment extends PreferenceFragment implements Preference.OnPreferenceClickListener {
    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        addPreferencesFromResource(R.xml.settings);

        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);

        try {
            Context context = getActivity().getApplicationContext();
            PackageInfo info = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            PreferenceScreen screen = getPreferenceScreen();

            Preference version = screen.findPreference("version");
            version.setSummary(info.versionName);

            version = screen.findPreference("openssl-version");
            version.setSummary(KeysCore.version().openssl);

            Preference license = screen.findPreference("license");
            license.setSummary(Html.fromHtml(getString(R.string.license)));
            license.setOnPreferenceClickListener(this);

            screen.findPreference("source").setOnPreferenceClickListener(this);
            screen.findPreference("oss").setOnPreferenceClickListener(this);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e("keys", "Error retrieving package info", e);
        }
    }

    @Override
    public boolean onPreferenceClick(Preference preference) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        String key = preference.getKey();
        if ("license".equals(key)) {
            intent = new Intent(getActivity(), WebViewActivity.class);
            intent.putExtra("title", preference.getTitle());
            intent.putExtra("url", "file:///android_res/raw/gplv3.html");
        } else if ("source".equals(key)) {
            intent.setData(Uri.parse(getString(R.string.source)));
        } else if ("oss".equals(key)) {
            intent = new Intent(getActivity(), WebViewActivity.class);
            intent.putExtra("title", preference.getTitle());
            intent.putExtra("url", "file:///android_res/raw/notice.html");
        }
        startActivity(intent);
        return true;
    }
}
