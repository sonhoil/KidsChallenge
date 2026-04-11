package com.kidspoint.api.kids.family.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UpdateFamilyMemberNicknameRequest {

    @NotBlank(message = "이름을 입력해주세요")
    @Size(max = 40, message = "이름은 40자 이하로 입력해주세요")
    private String nickname;

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
}
