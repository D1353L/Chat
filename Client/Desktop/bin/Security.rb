include Java

java_import Java::javax.crypto.Cipher
java_import Java::javax.crypto.spec.SecretKeySpec
java_import Java::sun.misc.BASE64Encoder
java_import Java::sun.misc.BASE64Decoder

class Security
  @key = "TheBestSecretKey"

  def self.encrypt(data)
    aes = javax.crypto.spec.SecretKeySpec.new(@key.to_java_bytes, "AES")
    cipher = javax.crypto.Cipher.getInstance("AES")
    cipher.init(javax.crypto.Cipher::ENCRYPT_MODE, aes)
    bytes = cipher.doFinal(data.to_java_bytes)
    encryptedValue = BASE64Encoder.new.encode(bytes)
    encryptedValue.gsub!("\r\n", "")
    return encryptedValue.to_java_string
  end

  def self.decrypt(encryptedData)
    aes = javax.crypto.spec.SecretKeySpec.new(@key.to_java_bytes, "AES")
    cipher = javax.crypto.Cipher.getInstance("AES")
    cipher.init(javax.crypto.Cipher::DECRYPT_MODE, aes)
    decodedValue = BASE64Decoder.new.decodeBuffer(encryptedData)
    decValue = cipher.doFinal(decodedValue)
    return decValue.to_s
  end
end