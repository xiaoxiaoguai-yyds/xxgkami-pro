package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.util.AdvancedCryptoUtil;

import jakarta.annotation.PostConstruct;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.nio.file.Files;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

@Service
public class KeyManagerService {

    @Autowired
    private AdvancedCryptoUtil cryptoUtil;

    private SecretKey aesKey;
    private KeyPair eccKeyPair;
    private String pepper;
    
    private static final String KEY_DIR = "keys";
    private static final String AES_KEY_FILE = "keys/aes.key";
    private static final String ECC_PUB_FILE = "keys/ecc_pub.key";
    private static final String ECC_PRIV_FILE = "keys/ecc_priv.key";
    private static final String PEPPER_FILE = "keys/pepper.key";

    @PostConstruct
    public void init() throws Exception {
        File dir = new File(KEY_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File aesFile = new File(AES_KEY_FILE);
        File eccPubFile = new File(ECC_PUB_FILE);
        File eccPrivFile = new File(ECC_PRIV_FILE);
        File pepperFile = new File(PEPPER_FILE);

        if (aesFile.exists() && eccPubFile.exists() && eccPrivFile.exists() && pepperFile.exists()) {
            // Load keys
            byte[] aesBytes = Base64.getDecoder().decode(Files.readString(aesFile.toPath()));
            this.aesKey = new SecretKeySpec(aesBytes, "AES");

            byte[] pubBytes = Base64.getDecoder().decode(Files.readString(eccPubFile.toPath()));
            byte[] privBytes = Base64.getDecoder().decode(Files.readString(eccPrivFile.toPath()));

            KeyFactory kf = KeyFactory.getInstance("EC");
            PublicKey pub = kf.generatePublic(new X509EncodedKeySpec(pubBytes));
            PrivateKey priv = kf.generatePrivate(new PKCS8EncodedKeySpec(privBytes));
            this.eccKeyPair = new KeyPair(pub, priv);
            
            this.pepper = Files.readString(pepperFile.toPath());
        } else {
            // Generate and save keys
            this.aesKey = cryptoUtil.generateAESKey();
            this.eccKeyPair = cryptoUtil.generateECCKeyPair();
            this.pepper = cryptoUtil.generateSalt(); // Use salt generator for pepper

            Files.writeString(aesFile.toPath(), Base64.getEncoder().encodeToString(aesKey.getEncoded()));
            Files.writeString(eccPubFile.toPath(), Base64.getEncoder().encodeToString(eccKeyPair.getPublic().getEncoded()));
            Files.writeString(eccPrivFile.toPath(), Base64.getEncoder().encodeToString(eccKeyPair.getPrivate().getEncoded()));
            Files.writeString(pepperFile.toPath(), this.pepper);
        }
    }

    public SecretKey getAesKey() {
        return aesKey;
    }

    public KeyPair getEccKeyPair() {
        return eccKeyPair;
    }
    
    public String getPepper() {
        return pepper;
    }
}
