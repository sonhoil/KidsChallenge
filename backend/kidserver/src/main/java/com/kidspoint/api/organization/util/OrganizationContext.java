package com.kidspoint.api.organization.util;

import jakarta.servlet.http.HttpSession;

import java.util.Optional;
import java.util.UUID;

public class OrganizationContext {
    private static final String CURRENT_ORG_ID_KEY = "currentOrgId";

    public static Optional<UUID> getCurrentOrgId(HttpSession session) {
        if (session == null) {
            return Optional.empty();
        }
        Object orgIdObj = session.getAttribute(CURRENT_ORG_ID_KEY);
        if (orgIdObj == null) {
            return Optional.empty();
        }
        try {
            UUID orgId = UUID.fromString(orgIdObj.toString());
            return Optional.of(orgId);
        } catch (IllegalArgumentException e) {
            return Optional.empty();
        }
    }

    public static void setCurrentOrgId(HttpSession session, UUID orgId) {
        if (session != null) {
            session.setAttribute(CURRENT_ORG_ID_KEY, orgId.toString());
        }
    }

    public static void clearCurrentOrgId(HttpSession session) {
        if (session != null) {
            session.removeAttribute(CURRENT_ORG_ID_KEY);
        }
    }
}
