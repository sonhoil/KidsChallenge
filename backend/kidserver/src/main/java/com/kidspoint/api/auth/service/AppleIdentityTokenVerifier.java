package com.kidspoint.api.auth.service;

import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.crypto.ECDSAVerifier;
import com.nimbusds.jose.jwk.ECKey;
import com.nimbusds.jose.jwk.JWK;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.URL;
import java.util.Date;
import java.util.Objects;

/**
 * Sign in with Apple identity token (JWT, ES256) 검증.
 * aud = iOS 번들 ID (예: com.kidspoint.kidsChallenge)
 */
@Component
public class AppleIdentityTokenVerifier {

    private static final String APPLE_ISSUER = "https://appleid.apple.com";
    private static final String KEYS_URL = "https://appleid.apple.com/auth/keys";

    @Value("${apple.signin.bundle-id:com.kidspoint.kidsChallenge}")
    private String bundleId;

    public JWTClaimsSet verifyAndParseClaims(String identityToken) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(identityToken);
        JWKSet jwkSet = JWKSet.load(new URL(KEYS_URL).openStream());
        String kid = signedJWT.getHeader().getKeyID();
        JWK jwk = null;
        for (JWK k : jwkSet.getKeys()) {
            if (Objects.equals(kid, k.getKeyID())) {
                jwk = k;
                break;
            }
        }
        if (jwk == null) {
            throw new IllegalArgumentException("Apple JWK not found for kid=" + kid);
        }
        ECKey ecKey = (ECKey) jwk;
        JWSVerifier verifier = new ECDSAVerifier(ecKey.toECPublicKey());
        if (!signedJWT.verify(verifier)) {
            throw new IllegalArgumentException("Apple identity token signature invalid");
        }
        JWTClaimsSet claims = signedJWT.getJWTClaimsSet();
        if (!APPLE_ISSUER.equals(claims.getIssuer())) {
            throw new IllegalArgumentException("Invalid Apple token issuer");
        }
        if (claims.getExpirationTime() != null
            && claims.getExpirationTime().before(new Date())) {
            throw new IllegalArgumentException("Apple identity token expired");
        }
        if (claims.getAudience() == null || !claims.getAudience().contains(bundleId)) {
            throw new IllegalArgumentException("Invalid Apple token audience (expected bundle id " + bundleId + ")");
        }
        return claims;
    }
}
