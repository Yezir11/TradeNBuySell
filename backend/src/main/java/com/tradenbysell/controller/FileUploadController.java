package com.tradenbysell.controller;

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

@RestController
@RequestMapping("/api/upload")
@CrossOrigin(origins = "*")
public class FileUploadController {
    @Value("${app.upload.dir}")
    private String uploadDir;

    @Value("${app.base.url}")
    private String baseUrl;

    @PostMapping("/images")
    public ResponseEntity<List<String>> uploadImages(@RequestParam("files") MultipartFile[] files) {
        List<String> imageUrls = new ArrayList<>();

        try {
            File uploadDirectory = new File(uploadDir);
            if (!uploadDirectory.exists()) {
                uploadDirectory.mkdirs();
            }

            for (MultipartFile file : files) {
                if (file.isEmpty()) {
                    continue;
                }

                String originalFilename = file.getOriginalFilename();
                String extension = "";
                if (originalFilename != null && originalFilename.contains(".")) {
                    extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                }

                String uniqueFilename = UUID.randomUUID().toString() + extension;
                Path filePath = Paths.get(uploadDir, uniqueFilename);
                Files.write(filePath, file.getBytes());

                String imageUrl = baseUrl + "/images/" + uniqueFilename;
                imageUrls.add(imageUrl);
            }

            return ResponseEntity.ok(imageUrls);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}

