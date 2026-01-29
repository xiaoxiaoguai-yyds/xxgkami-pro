package org.xxg.backend.backend.service;

import dev.samstevens.totp.code.CodeVerifier;
import dev.samstevens.totp.code.DefaultCodeGenerator;
import dev.samstevens.totp.code.DefaultCodeVerifier;
import dev.samstevens.totp.code.HashingAlgorithm;
import dev.samstevens.totp.exceptions.QrGenerationException;
import dev.samstevens.totp.qr.QrData;
import dev.samstevens.totp.qr.QrDataFactory;
import dev.samstevens.totp.qr.QrGenerator;
import dev.samstevens.totp.qr.ZxingPngQrGenerator;
import dev.samstevens.totp.secret.DefaultSecretGenerator;
import dev.samstevens.totp.secret.SecretGenerator;
import dev.samstevens.totp.time.SystemTimeProvider;
import dev.samstevens.totp.time.TimeProvider;
import org.springframework.stereotype.Service;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.BarcodeFormat;
import java.io.ByteArrayOutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import static dev.samstevens.totp.util.Utils.getDataUriForImage;

@Service
public class TotpService {

    private final SecretGenerator secretGenerator;
    private final QrDataFactory qrDataFactory;
    private final QrGenerator qrGenerator;
    private final CodeVerifier codeVerifier;
    private final SettingsService settingsService;

    public TotpService(SettingsService settingsService) {
        this.settingsService = settingsService;
        this.secretGenerator = new DefaultSecretGenerator();
        this.qrDataFactory = new QrDataFactory(HashingAlgorithm.SHA1, 6, 30);
        this.qrGenerator = new ZxingPngQrGenerator();
        TimeProvider timeProvider = new SystemTimeProvider();
        DefaultCodeGenerator codeGenerator = new DefaultCodeGenerator();
        this.codeVerifier = new DefaultCodeVerifier(codeGenerator, timeProvider);
    }

    public String generateSecret() {
        return secretGenerator.generate();
    }

    public String getQrCodeImageUri(String secret, String username) {
        QrData data = qrDataFactory.newBuilder()
                .label(username)
                .secret(secret)
                .issuer("XXG-KAMI")
                .build();
        
        String uri = data.getUri();
        
        // Add image parameter if site_url is configured
        String siteUrl = settingsService.getSetting("site_url");
        
        if (siteUrl != null && !siteUrl.isEmpty()) {
             // Remove trailing slash
             if (siteUrl.endsWith("/")) siteUrl = siteUrl.substring(0, siteUrl.length() - 1);
             
             // Check if it's a valid URL (basic check)
             if (siteUrl.startsWith("http")) {
                 String imageUrl = siteUrl + "/icon.png";
                 try {
                     // Append image parameter
                     uri += "&image=" + URLEncoder.encode(imageUrl, StandardCharsets.UTF_8);
                     System.out.println("TOTP QR Code URI with image: " + uri);
                 } catch (Exception e) {
                     e.printStackTrace();
                 }
             }
        }

        try {
            byte[] imageData = generateQrCode(uri);
            return getDataUriForImage(imageData, qrGenerator.getImageMimeType());
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate QR code", e);
        }
    }

    private byte[] generateQrCode(String uri) throws Exception {
        QRCodeWriter writer = new QRCodeWriter();
        BitMatrix bitMatrix = writer.encode(uri, BarcodeFormat.QR_CODE, 300, 300);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
        return outputStream.toByteArray();
    }

    public boolean verifyCode(String secret, String code) {
        return codeVerifier.isValidCode(secret, code);
    }
}
