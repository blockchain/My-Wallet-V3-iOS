// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;

public class IssueActivity extends Activity {
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(R.layout.issue);
        setTitle(getString(R.string.certificate));

        String cert = getIntent().getStringExtra("cert");
        CertFragment fragment = (CertFragment) getFragmentManager().findFragmentByTag("cert");
        fragment.setCert(cert);
    }
}