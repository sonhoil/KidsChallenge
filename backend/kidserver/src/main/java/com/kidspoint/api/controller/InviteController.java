package com.kidspoint.api.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@RestController
@RequestMapping("/invite")
public class InviteController {

    @GetMapping(value = "/link", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> openInviteLink(
            @RequestParam String inviteCode,
            @RequestParam(required = false) UUID memberId) {
        String encodedInviteCode = URLEncoder.encode(inviteCode, StandardCharsets.UTF_8);
        String encodedMemberId = memberId != null
            ? URLEncoder.encode(memberId.toString(), StandardCharsets.UTF_8)
            : null;

        String deepLink = encodedMemberId != null
            ? "kidspoint://app/login?inviteCode=" + encodedInviteCode + "&memberId=" + encodedMemberId
            : "kidspoint://app/login?inviteCode=" + encodedInviteCode;

        String html = """
            <!doctype html>
            <html lang="ko">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>우리아이 첫 지갑 초대</title>
              <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 0; background: #f8fafc; color: #0f172a; }
                .wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
                .card { max-width: 420px; width: 100%%; background: white; border-radius: 24px; padding: 28px; box-shadow: 0 10px 30px rgba(15,23,42,0.08); }
                h1 { margin: 0 0 12px; font-size: 24px; }
                p { margin: 0 0 20px; color: #475569; line-height: 1.5; }
                a.button { display: inline-block; width: 100%%; box-sizing: border-box; text-align: center; background: #3b82f6; color: white; text-decoration: none; padding: 14px 16px; border-radius: 14px; font-weight: 700; }
                .hint { margin-top: 14px; font-size: 13px; color: #64748b; text-align: center; }
              </style>
            </head>
            <body>
              <div class="wrap">
                <div class="card">
                  <h1>초대 링크를 열고 있어요</h1>
                  <p>앱이 설치되어 있으면 자동으로 열립니다. 자동으로 열리지 않으면 아래 버튼을 눌러주세요.</p>
                  <a class="button" href="%s">앱에서 초대 열기</a>
                  <div class="hint">앱이 없다면 먼저 설치 후 다시 링크를 열어주세요.</div>
                </div>
              </div>
              <script>
                window.location.replace(%s);
              </script>
            </body>
            </html>
            """.formatted(deepLink, "\"" + deepLink + "\"");

        return ResponseEntity.ok(html);
    }
}

