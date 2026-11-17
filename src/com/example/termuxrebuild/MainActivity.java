package com.example.termuxrebuild;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * Minimal original demo built entirely in Termux using:
 *  - javac / JDK 21
 *  - aapt2 extracted from Sketchware Pro's assets
 *  - android.jar extracted from Sketchware Pro's assets
 *  - D8 (R8) to produce classes.dex
 *  - uber-apk-signer for v1/v2/v3 signing
 */
public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        int pad = 40;
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(pad, pad, pad, pad);

        TextView heading = new TextView(this);
        heading.setText("Rebuilt in Termux");
        heading.setTextSize(22f);
        root.addView(heading);

        final TextView detail = new TextView(this);
        detail.setTextSize(15f);
        detail.setPadding(0, 24, 0, 24);
        detail.setText("Two on-device APK builders were inspected with REA.\nTap a button to see what each one bundles.");
        root.addView(detail);

        Button sketchButton = new Button(this);
        sketchButton.setText("Sketchware Pro toolchain");
        sketchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detail.setText("Sketchware Pro ships aapt2 for 4 ABIs, android.jar, "
                        + "16 multidex DEX files, pre-dexed dependencies, a test signing key, "
                        + "and project templates inside assets/.");
            }
        });
        root.addView(sketchButton);

        Button hopButton = new Button(this);
        hopButton.setText("HopWeb toolchain");
        hopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detail.setText("HopWeb ships an APK packaging template (android.jar + "
                        + "manifest variants + DEX stubs) and a native PHP runtime with "
                        + "SQLite, cURL and OpenSSL inside assets/.");
            }
        });
        root.addView(hopButton);

        setContentView(root);
    }
}
