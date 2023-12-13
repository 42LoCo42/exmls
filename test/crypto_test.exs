defmodule CryptoTest do
  use ExUnit.Case, async: true

  test "erlang crypto -> AEAD" do
    cipher = :chacha20_poly1305
    dbg(cipher)

    dbg(info = :crypto.cipher_info(cipher))

    key = :crypto.strong_rand_bytes(info.key_length)
    dbg(:base64.encode_to_string(key))

    iv = :crypto.strong_rand_bytes(info.iv_length)
    dbg(:base64.encode_to_string(iv))

    txt = ["this is ", "secret data ", "that needs to be ", "encrypted"]
    dbg(txt)

    aad = ["some", "stuff"]
    dbg(aad)

    {ctxt, caad} = :crypto.crypto_one_time_aead(cipher, key, iv, txt, aad, true)
    dbg(:base64.encode_to_string(ctxt))
    dbg(:base64.encode_to_string(caad))

    dbg(out = :crypto.crypto_one_time_aead(cipher, key, iv, ctxt, aad, caad, false))
    assert Enum.join(txt) == out
  end

  test "erlang crypto -> sign/verify" do
    msg = "foobar"

    algorithm = :eddsa
    curve = :ed25519
    hash = :sha512

    {public, secret} = :crypto.generate_key(algorithm, curve)

    dbg(%{
      public: :base64.encode_to_string(public),
      secret: :base64.encode_to_string(secret)
    })

    signature = :crypto.sign(algorithm, hash, msg, [secret, curve])
    dbg(:base64.encode_to_string(signature))

    assert :crypto.verify(algorithm, hash, msg, signature, [public, curve])
  end

  test "erlang crypto -> MAC" do
    info = :crypto.hash_info(:sha256)
    key = :crypto.strong_rand_bytes(info.size)

    mac1 = :crypto.mac(:hmac, :sha256, key, "data")
    mac2 = :crypto.mac(:hmac, :sha256, key, "data")
    mac3 = :crypto.mac(:hmac, :sha256, key, "fail")

    assert mac1 == mac2
    assert mac1 != mac3
    assert mac2 != mac3
  end
end
