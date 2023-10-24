defmodule CryptoTest do
  use ExUnit.Case, async: true

  test "erlang crypto module" do
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
end
