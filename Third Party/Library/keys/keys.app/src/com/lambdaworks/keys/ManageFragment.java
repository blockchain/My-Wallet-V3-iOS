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

public class ManageFragment extends PreferenceFragment implements Preference.OnPreferenceClickListener {
    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        addPreferencesFromResource(R.xml.manage);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);
        PreferenceScreen screen = getPreferenceScreen();
        screen.findPreference("issue").setOnPreferenceClickListener(this);
    }

    @Override
    public boolean onPreferenceClick(Preference preference) {
        String key = preference.getKey();
        if ("issue".equals(key)) {
            new IssueCertTask().execute();
        }
        return true;
    }

    private class IssueCertTask extends ProgressTask<Void, Void, String> {
        public IssueCertTask() {
            super(getActivity(), R.string.generating);
        }

        @Override
        protected String doInBackground(Void... voids) {
            return KeysCore.issueCert(getActivity());
        }

        @Override
        protected void onPostExecute(String cert) {
            super.onPostExecute(cert);
            Intent intent = new Intent(getActivity(), IssueActivity.class);
            intent.putExtra("cert", cert);
            startActivity(intent);
        }
    }
}
