// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.*;
import android.widget.*;

public class KeysActivity extends Activity implements AdapterView.OnItemSelectedListener {
    private NetworkInterface[] interfaces;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(R.layout.main);

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(KeysActivity.this, android.R.layout.simple_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_item);

        Spinner spinner = (Spinner) findViewById(R.id.interfaces);
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(this);
    }

    @Override
    protected void onStart() {
        super.onStart();

        if (!KeysCore.databaseDir(getApplicationContext()).exists()) {
            PreferenceManager.setDefaultValues(this, R.xml.settings, false);
            Intent intent = new Intent(this, InitActivity.class);
            startActivity(intent);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void onResume() {
        super.onResume();

        Spinner spinner = (Spinner) findViewById(R.id.interfaces);
        ArrayAdapter<String> adapter = (ArrayAdapter<String>) spinner.getAdapter();
        adapter.clear();

        interfaces = KeysCore.interfaces();
        for (NetworkInterface i : interfaces) {
            adapter.add(i.name);
        }

        toggleWidgets(KeysService.running);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.manage:
                startActivity(new Intent(this, ManageActivity.class));
                break;
            case R.id.settings:
                startActivity(new Intent(this, SettingsActivity.class));
                break;
            default:
                return super.onOptionsItemSelected(item);
        }
        return true;
    }

    public void startServer(View view) {
        Intent intent = new Intent(this, KeysService.class);
        intent.putExtra("path", KeysCore.databaseDir(getApplicationContext()).getAbsolutePath());

        if (!KeysService.running) {
            Spinner spinner = (Spinner) findViewById(R.id.interfaces);
            intent.putExtra("interface", spinner.getSelectedItemPosition());
            startService(intent);
            toggleWidgets(true);
        } else {
            stopService(intent);
            toggleWidgets(false);
        }
    }

    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
        EditText addr = (EditText) findViewById(R.id.addr);
        addr.setText(interfaces[i].address.getHostAddress());
        findViewById(R.id.start).setEnabled(true);
    }

    public void onNothingSelected(AdapterView<?> adapterView) {
        ((EditText) findViewById(R.id.addr)).setText("");
        Switch start = (Switch) findViewById(R.id.start);
        start.setEnabled(false);
        start.setChecked(false);
    }

    private void toggleWidgets(boolean running) {
        ((Switch) findViewById(R.id.start)).setChecked(running);
        findViewById(R.id.interfaces).setEnabled(!running);
        findViewById(R.id.addr).setEnabled(running);
    }
}
