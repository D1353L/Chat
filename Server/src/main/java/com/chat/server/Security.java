package com.chat.server;

import java.security.*;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import sun.misc.*;

public class Security {
	private static final String ALGO = "AES";
	private static final byte[] keyValue = "TheBestSecretKey".getBytes();

	public static String encrypt(String Data) throws Exception {
		try{
		Key key = new SecretKeySpec(keyValue, ALGO);
        Cipher c = Cipher.getInstance(ALGO);
        c.init(Cipher.ENCRYPT_MODE, key);
        byte[] encVal = c.doFinal(Data.getBytes());
        String encryptedValue = new BASE64Encoder().encode(encVal);
        return encryptedValue;
		}catch(Exception e){System.out.println("encryption error: "+e); return "";}
    }

    public static String decrypt(String encryptedData) throws Exception {
    	try{
    	Key key = new SecretKeySpec(keyValue, ALGO);
        Cipher c = Cipher.getInstance(ALGO);
        c.init(Cipher.DECRYPT_MODE, key);
        byte[] decodedValue = new BASE64Decoder().decodeBuffer(encryptedData);
        byte[] decValue = c.doFinal(decodedValue);
        String decryptedValue = new String(decValue);
        return decryptedValue;
    	}catch(Exception e){System.out.println("decryption error: "+e); return "";}
    }
}
