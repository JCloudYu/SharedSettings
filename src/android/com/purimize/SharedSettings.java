/*
 The MIT License (MIT)
 
	Copyright (c) 2014 J. Cloud Yu
 
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
 
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
 */
package com.purimize;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.Exception;
import java.lang.Override;
import java.util.Iterator;

/**
 * This class echoes a string called from JavaScript.
 */
public class SharedSettings extends CordovaPlugin
{
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException
	{
		if ( action.equals("getSetting") )
		{
			this.GetSetting(args, callbackContext);
			return true;
		}
		else
		if ( action.equals("setSetting") )
		{
			this.SetSetting(args, callbackContext);
			return true;
		}
		else
		if ( action.equals("querySettings") )
		{
			this.QuerySettings(args, callbackContext);
			return true;
		}
		else
		if ( action.equals("patchSettings") )
		{
			this.PatchSettings(args, callbackContext);
			return true;
		}
		else
		if ( action.equals("clearSettings") )
		{
			this.ClearSettings(args, callbackContext);
			return true;
		}
		return false;
	}

	public void GetSetting(JSONArray args, CallbackContext callbackContext)
	{
		SharedPreferences pref = this.cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
		String key = "", val = "";

		try
		{
			key = args.getString(0);
			val = pref.getString(key, "");
		}
		catch(Exception e)
		{
			key = val = "";
		}

		callbackContext.success(val);
	}

	public void SetSetting(JSONArray args, CallbackContext callbackContext)
	{
		SharedPreferences pref = this.cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
		SharedPreferences.Editor writer = pref.edit();


		String key;
		try
		{
			key = args.getString(0);
		}
		catch(Exception e)
		{
			callbackContext.error("Given key is invalid");
			return;
		}

		String prevVal = "";
		try
		{
			prevVal = pref.getString(key, "");
			String val = args.getString(1);

			if ( val == "" )
				writer.remove(key);
			else
				writer.putString(key, val);
		}
		catch(Exception e)
		{
			writer.remove(key);
		}

		writer.commit();

		callbackContext.success(prevVal);
	}

	public void QuerySettings(JSONArray args, CallbackContext callbackContext) throws JSONException
	{
		SharedPreferences pref = this.cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
		JSONObject result = new JSONObject();
		JSONArray reqTarget = null;

		try
		{
			reqTarget = args.getJSONArray(0);
		}
		catch(Exception e)
		{
			callbackContext.error("Given keys are invalid");
			return;
		}


		int length = reqTarget.length();
		for ( int i=0; i<length; i++ )
		{
			String key = "";
			try
			{
				key = reqTarget.getString(i);
				result.put(key, pref.getString(key, ""));
			}
			catch (Exception e)
			{
				result.put(key, "");
			}
		}

		callbackContext.success(result);
	}

	public void PatchSettings(JSONArray args, CallbackContext callbackContext)
	{
		SharedPreferences pref = this.cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
		SharedPreferences.Editor writer = pref.edit();
		JSONObject prev = new JSONObject(), reqTarget = null;

		try
		{
			reqTarget = args.getJSONObject(0);
		}
		catch(Exception e)
		{
			callbackContext.error("Given key/value pairs are invalid");
			return;
		}


		Iterator<String> keyIter = reqTarget.keys();
		while ( keyIter.hasNext() )
		{
			String key = keyIter.next();

			try
			{
				prev.put(key, pref.getString(key, ""));
				String val = reqTarget.getString(key);

				if ( val == "" )
					writer.remove(key);
				else
					writer.putString(key, val);
			}
			catch(Exception e)
			{
				writer.remove(key);
			}
		}

		writer.commit();

		callbackContext.success(prev);
	}

	public void ClearSettings(JSONArray args, CallbackContext callbackContext)
	{
		SharedPreferences pref = this.cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
		SharedPreferences.Editor writer = pref.edit();

		writer.clear();
		writer.commit();

	}


}
