package org.xxg.backend.backend;

import org.junit.jupiter.api.Test;
import org.xxg.backend.backend.util.CustomCardObfuscator;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class DecryptTest {

    @Test
    public void testDecryption() {
        CustomCardObfuscator obfuscator = new CustomCardObfuscator();
        String encrypted = "RDMlRDMlZzEyM2JoYlhITEgyS00zcXJqTTVHWWZjb3lCMFhlNFpaMG8yc1JFbVl2QjIlY3Vt-XVx-Wxs*D-2ZVpyMGl1MFVKRE1DT-IyJVk0QjIlaWJB*Gs4bXZZ-1o1NXkyS-ttYzg1NDhxbGRqWG-2Wmc0WXdzOG-3Qm9kdGNVbTR1d-N3N0-5NjdVZHJE--1DV-dNNDIld0hiRGNIT3BoQm9vM3lwdGN0Tmh5bjlMM1Q5V-ZzVHBQVGVCNnY4bnVLZ09ET-YyJXJCc0xNWnR3Z-Zq-1dYS2hBN3hHV0NZbVJSWXJ6YzJDV0NiNTBI*mNBQ0Zm-mtkSENzTDFqO-VCSVh5b3JCMi-zS-d6WVoyN0dMMzFudkFNRjIlNTRvSWo5a1k0QkYyJTlFcVlmN3VYZ3dPdzJv-VJTd3VxO-pLb09Ba3pFSXlDSzVHdnpCaWI2d2VuR0JzbENI-HNTcGlVbG9JdWJiRVdL*ERSMG1GMiVqRXFx*WxGMi-xVkNmVzQyJ-hGbXVtTG5Wd-IyJ-JpW-tsWg"; // Removed ==
        String original = "ZlKYiB+uVnLmumFH$WfCV1/lyqqEj/m0RDxKWEbbuIolUipSsPHClsBGnew6biBzvG5KCyIEzkAOoKJ9quwSRQo2wOwgXu7fYqE9/B4Yk9jIo45/MAvn13LG72ZYzGI3+royXIBE9j1LsCHdkRfFCAczH05bCWC2czrYRRmYCWGx7AhKXWSjFewtZMLsBr/MDOgKun8v6BeTPpTsFU9T3L9nyhNtctpy3ooBhpOHcDbHw$MGUCMQDrdU769E7wCuu4mUctdoB7e8swY4gZ6eXjdlq8458cmKI2y55ZSYvm8kxAbi+4Y+MCMDJU0ui0rZe65xllQquQmuc+vYmERs2o0ZZ4eX0ByocfYG5Mjrq3MK2HLHXbhb321g==";

        try {
            String decrypted = obfuscator.deobfuscate(encrypted);
            System.out.println("Decrypted: " + decrypted);
            System.out.println("Original:  " + original);
            
            if (!decrypted.equals(original)) {
                System.out.println("Length Diff: " + (decrypted.length() - original.length()));
                for (int i = 0; i < Math.min(decrypted.length(), original.length()); i++) {
                    if (decrypted.charAt(i) != original.charAt(i)) {
                        System.out.println("Diff at index " + i + ": " + (int)decrypted.charAt(i) + " vs " + (int)original.charAt(i));
                        System.out.println("Char at index " + i + ": " + decrypted.charAt(i) + " vs " + original.charAt(i));
                        break;
                    }
                }
            }
            assertEquals(original, decrypted);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
