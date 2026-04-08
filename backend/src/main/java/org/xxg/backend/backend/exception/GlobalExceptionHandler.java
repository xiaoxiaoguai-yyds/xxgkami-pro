package org.xxg.backend.backend.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.xxg.backend.backend.dto.LoginResponse;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<LoginResponse> handleRuntimeException(RuntimeException e) {
        return ResponseEntity.badRequest().body(LoginResponse.error(e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<LoginResponse> handleException(Exception e) {
        e.printStackTrace(); // Log the full stack trace for debugging
        return ResponseEntity.internalServerError().body(LoginResponse.error("系统错误: " + e.getMessage()));
    }
}
