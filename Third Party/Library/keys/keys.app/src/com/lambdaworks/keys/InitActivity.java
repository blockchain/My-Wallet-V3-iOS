// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

public class InitActivity extends Activity implements SeekBar.OnSeekBarChangeListener, Button.OnClickListener {
    private static enum Param {  N, r, p }
    private long[] defaults = { 14, 8, 1 };
    private long N = defaults[0];
    private long r = defaults[1];
    private long p = defaults[2];

    public void onCreate(Bundle state) {
        super.onCreate(state);

        Resources resources = getResources();
        setTitle(getString(R.string.initTitle));
        setContentView(R.layout.init);

        for (Param p : Param.values()) {
            int id = resources.getIdentifier("seek" + p.ordinal(), "id", getPackageName());
            SeekBar seek = (SeekBar) findViewById(id);
            seek.setOnSeekBarChangeListener(this);
            seek.setTag(p);
            long value = (state != null ? state.getLong(p.name()) : defaults[p.ordinal()]);
            seek.setProgress((int) value - 1);
        }

        findViewById(R.id.init).setOnClickListener(this);
    }

    @Override
    protected void onSaveInstanceState(Bundle state) {
        super.onSaveInstanceState(state);
        state.putLong("N", N);
        state.putLong("r", r);
        state.putLong("p", p);
    }

    public void onProgressChanged(SeekBar seek, int progress, boolean fromUser) {
        Param param = (Param) seek.getTag();
        Resources resources = getResources();
        long value = progress + 1;

        switch (param) {
            case N:
                N = value;
                value = (long) Math.pow(2, value);
                break;
            case r:
                r = value;
                break;
            case p:
                p = value;
                break;
        }

        TextView text = (TextView) findViewById(resources.getIdentifier("value" + param.ordinal(), "id", getPackageName()));
        text.setText("" + value);
    }

    public void onStartTrackingTouch(SeekBar seek) { }
    public void onStopTrackingTouch(SeekBar seek) { }

    public void onClick(View v) {
        v.setEnabled(false);
        new InitTask().execute();
    }

    private class InitTask extends ProgressTask<Void, Void, String> {
        protected InitTask() {
            super(InitActivity.this, R.string.initializing);
        }

        @Override
        protected String doInBackground(Void... voids) {
            String path = KeysCore.databaseDir(getApplicationContext()).getAbsolutePath();
            return KeysCore.initialize(path, (long) Math.pow(2, N), r, p);
        }

        @Override
        protected void onPostExecute(String passwd) {
            super.onPostExecute(passwd);

            Intent intent = new Intent(InitActivity.this, ReadyActivity.class);
            intent.putExtra("password", passwd);
            startActivity(intent);

            finish();
        }
    }
}