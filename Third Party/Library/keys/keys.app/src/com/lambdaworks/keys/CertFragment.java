// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ShareActionProvider;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringWriter;
import java.io.Writer;

public class CertFragment extends Fragment implements View.OnClickListener {
    private static String CLIENT_PEM = "client.pem";
    TextView text;
    File file;
    ShareActionProvider provider;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setHasOptionsMenu(true);
        provider = new ShareActionProvider(getActivity());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle state) {
        View view = inflater.inflate(R.layout.cert, container, false);
        text = (TextView) view.findViewById(R.id.cert);
        text.setKeyListener(null);
        view.findViewById(R.id.ok).setOnClickListener(this);
        return view;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.cert, menu);
        MenuItem item = menu.findItem(R.id.send);
        item.setActionProvider(provider);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.copy) {
            File dst = new File(Environment.getExternalStorageDirectory(), CLIENT_PEM);
            try {
                writeCert(file, new FileWriter(dst));
                String msg = getResources().getString(R.string.certCopied, dst.getPath());
                Toast.makeText(getActivity(), msg, Toast.LENGTH_LONG).show();
            } catch (IOException e) {
                Log.e("keys", "Unable to copy cert", e);
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View view) {
        file.delete();
        getActivity().finish();
    }

    public void setCert(File cert) {
        StringWriter str = new StringWriter();
        try {
            writeCert(cert, str);
            setCert(str.toString());
        } catch (Exception e) {
            Log.e("keys", "Unable to read cert", e);
        }
    }

    public void setCert(String cert) {
        Activity activity = getActivity();
        try {
            text.setText(cert);
            FileOutputStream os = activity.openFileOutput(CLIENT_PEM, Activity.MODE_PRIVATE);
            os.write(cert.getBytes("ASCII"));
            os.close();

            file = activity.getFileStreamPath(CLIENT_PEM);
            file.setReadable(true, false);

            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("text/plain");
            intent.addFlags(Intent.FLAG_ACTIVITY_FORWARD_RESULT);
            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));

            provider.setShareIntent(intent);
        } catch (IOException e) {
            Log.e("keys", "Failed to write", e);
        }
    }

    private void writeCert(File cert, Writer dst) throws IOException {
        Reader src = new InputStreamReader(new FileInputStream(cert), "ASCII");
        try {
            char[] buf = new char[2048];
            int len;
            while ((len = src.read(buf)) != -1) {
                dst.write(buf, 0, len);
            }
        } finally {
            src.close();
            dst.close();
        }
    }
}
