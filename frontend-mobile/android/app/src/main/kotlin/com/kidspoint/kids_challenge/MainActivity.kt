package com.kidspoint.kids_challenge

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.kidspoint.kids_challenge/keyhash"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "MethodChannel called: method=${call.method}")
            if (call.method == "getKeyHash") {
                Log.d("MainActivity", "getKeyHash method called")
                try {
                    val keyHash = getKeyHash()
                    Log.d("MainActivity", "✅ Key Hash retrieved: $keyHash")
                    result.success(keyHash)
                } catch (e: Exception) {
                    Log.e("MainActivity", "❌ Error getting key hash", e)
                    result.error("ERROR", "Failed to get key hash: ${e.message}", null)
                }
            } else {
                Log.d("MainActivity", "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
        Log.d("MainActivity", "MethodChannel handler registered")
    }
    
    @Suppress("DEPRECATION")
    private fun getKeyHash(): String {
        Log.d("MainActivity", "getKeyHash() called, packageName=$packageName")
        try {
            // 모든 Android 버전에서 GET_SIGNATURES 사용 (deprecated이지만 호환성 좋음)
            Log.d("MainActivity", "Getting package info...")
            val packageInfo: PackageInfo = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
            Log.d("MainActivity", "Package info retrieved")
            
            val signatures = packageInfo.signatures
            Log.d("MainActivity", "Signatures count: ${signatures?.size ?: 0}")
            if (signatures != null && signatures.isNotEmpty()) {
                for ((index, signature) in signatures.withIndex()) {
                    Log.d("MainActivity", "Processing signature $index")
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val digest = md.digest()
                    
                    // SHA1을 Base64로 인코딩
                    val keyHash = Base64.encodeToString(digest, Base64.NO_WRAP)
                    
                    val hexDigest = digest.joinToString(":") { "%02X".format(it) }
                    Log.d("MainActivity", "✅ SHA1 Digest (hex): $hexDigest")
                    Log.d("MainActivity", "✅ Key Hash (Base64): $keyHash")
                    
                    return keyHash
                }
            } else {
                Log.w("MainActivity", "⚠️ No signatures found")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "❌ Error in getKeyHash", e)
            e.printStackTrace()
        }
        Log.w("MainActivity", "⚠️ Returning empty key hash")
        return ""
    }
}
