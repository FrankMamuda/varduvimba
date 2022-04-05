/*
 * Copyright (C) 2022 Armands Aleksejevs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 *
 */

/*
 * package
 */
package org.factory12.vardotajs;

/*
 * imports
 */

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

/*
 * gms imports
 */
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;

/*
 * java imports
 */
import java.util.concurrent.atomic.AtomicBoolean;


/**
 * AdBanner class
 */
public class AdBanner {
    public static void postOnUI( Runnable runnable ) {
        if ( Looper.getMainLooper().getThread() == Thread.currentThread() ) {
            runnable.run();
            return;
        }
        Handler uiHandler = new Handler( Looper.getMainLooper() );
        AtomicBoolean done = new AtomicBoolean( false );
        uiHandler.post( () -> {
            runnable.run();
            done.set( true );
        } );

        while ( !done.get() ) {
            try {
                Thread.sleep( 20 );
            } catch ( InterruptedException ignored ) {

            }
        }
    }

    /**
     * constructor
     *
     * @param activityInstance activity
     */
    public AdBanner( Activity activityInstance ) {
        MobileAds.initialize( activityInstance );
        this.activity = activityInstance;
        this.viewGroup = this.activity.getWindow().getDecorView().findViewById( android.R.id.content );
    }

    /**
     * setup
     */
    public void setup() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> {
            AdSize adSize;

            Display display = activity.getWindowManager().getDefaultDisplay();
            DisplayMetrics displayMetrics = new DisplayMetrics();

            display.getMetrics( displayMetrics );
            adSize = AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize( activity, ( int ) ( ( ( float ) displayMetrics.widthPixels ) / displayMetrics.density ) );

            adView.setAdSize( adSize );
            m_width = adSize.getWidthInPixels( activity );
            m_height = adSize.getHeightInPixels( activity );
        } );
    }

    /**
     * setPos
     *
     * @param x x position
     * @param y y position
     */
    public void setPos( final int x, final int y ) {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> {
            adView.setX( x );
            adView.setY( y );
        } );
    }

    /**
     * setId
     *
     * @param id admob id
     */
    public void setId( final String id ) {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> adView.setAdUnitId( id ) );
    }

    /**
     * show
     */
    public void show() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> {
            AdRequest.Builder adRequest = new AdRequest.Builder();
            adView.loadAd( adRequest.build() );
            adView.setVisibility( View.VISIBLE );
        } );
    }

    /**
     * hide
     */
    public void hide() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> {
            adView.setVisibility( View.GONE );
        } );
    }


    /**
     * repaint
     */
    public void repaint() {
        if ( this.adView == null )
            return;

        this.destroy();
        this.create();
    }

    /**
     * create
     */
    public void create() {
        AdBanner.postOnUI( () -> {
            final FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams( FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT );
            adView = new AdView( activity );
            adView.setLayoutParams( layoutParams );
            viewGroup.addView( adView );
        } );
    }

    /**
     * start
     */
    public void start() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> adView.resume() );
    }

    /**
     * stop
     */
    public void stop() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> adView.pause() );
    }

    /**
     * destroy
     */
    public void destroy() {
        if ( this.adView == null )
            return;

        AdBanner.postOnUI( () -> {
            viewGroup.removeView( adView );
            adView.destroy();
            adView = null;
        } );
    }

    /**
     * width
     *
     * @return width
     */
    public int width() {
        return this.m_width;
    }

    /**
     * height
     *
     * @return height
     */
    public int height() {
        return this.m_height;
    }

    final private ViewGroup viewGroup;
    private AdView adView = null;
    final private Activity activity;

    private int m_width = 0;
    private int m_height = 0;
}
