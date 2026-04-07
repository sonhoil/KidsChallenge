package com.kidspoint.api.kids.family.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public class JoinFamilyRequest {
    @NotBlank(message = "Invite code is required")
    private String inviteCode;
    
    private String nickname;
    private UUID memberId;

    public JoinFamilyRequest() {
    }

    public JoinFamilyRequest(String inviteCode, String nickname) {
        this.inviteCode = inviteCode;
        this.nickname = nickname;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public UUID getMemberId() {
        return memberId;
    }

    public void setMemberId(UUID memberId) {
        this.memberId = memberId;
    }
}
