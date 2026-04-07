package com.kidspoint.api.item.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.organization.util.OrganizationContext;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/items")
public class FileUploadController extends ApiControllerBase {

    @Value("${app.upload.dir:uploads/items}")
    private String uploadDir;

    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<String>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("File is empty"));
        }

        // 파일 타입 검증
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("File must be an image"));
        }

        try {
            // 업로드 디렉토리 생성
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 고유한 파일명 생성
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString() + extension;

            // 파일 저장
            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath);

            // URL 반환 (로컬 테스트용)
            String imageUrl = "/api/uploads/items/" + filename;

            return ResponseEntity.ok(ApiResponse.ok(imageUrl, "Image uploaded successfully"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Failed to upload file: " + e.getMessage()));
        }
    }

    /**
     * 업로드된 이미지 파일 목록 조회 (디버깅/확인용)
     */
    @GetMapping("/upload/list")
    public ResponseEntity<ApiResponse<List<String>>> listUploadedImages() {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                return ResponseEntity.ok(ApiResponse.ok(new ArrayList<>(), "Upload directory does not exist"));
            }

            List<String> files = Files.list(uploadPath)
                .filter(Files::isRegularFile)
                .map(path -> {
                    String filename = path.getFileName().toString();
                    String fileUrl = "/api/uploads/items/" + filename;
                    long fileSize = 0;
                    try {
                        fileSize = Files.size(path);
                    } catch (IOException e) {
                        // 파일 크기 조회 실패 시 무시
                    }
                    return String.format("%s (size: %d bytes)", fileUrl, fileSize);
                })
                .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.ok(files, "Found " + files.size() + " files"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Failed to list files: " + e.getMessage()));
        }
    }

    /**
     * 업로드 디렉토리 정보 조회 (디버깅/확인용)
     */
    @GetMapping("/upload/info")
    public ResponseEntity<ApiResponse<Object>> getUploadDirInfo() {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            Path uploadPath = Paths.get(uploadDir);
            boolean exists = Files.exists(uploadPath);
            boolean isDirectory = exists && Files.isDirectory(uploadPath);
            long totalSize = 0;
            int fileCount = 0;

            if (isDirectory) {
                try {
                    List<Path> files = Files.list(uploadPath)
                        .filter(Files::isRegularFile)
                        .collect(Collectors.toList());
                    fileCount = files.size();
                    for (Path file : files) {
                        totalSize += Files.size(file);
                    }
                } catch (IOException e) {
                    // 파일 목록 조회 실패 시 무시
                }
            }

            java.util.Map<String, Object> info = new java.util.HashMap<>();
            info.put("uploadDir", uploadDir);
            info.put("absolutePath", uploadPath.toAbsolutePath().toString());
            info.put("exists", exists);
            info.put("isDirectory", isDirectory);
            info.put("fileCount", fileCount);
            info.put("totalSize", totalSize);
            info.put("totalSizeMB", String.format("%.2f", totalSize / (1024.0 * 1024.0)));

            return ResponseEntity.ok(ApiResponse.ok(info, "Upload directory info"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Failed to get upload dir info: " + e.getMessage()));
        }
    }
}
