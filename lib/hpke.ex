defmodule ExMLS.HPKE do
  use EnumType

  @on_load :load_nifs

  defenum(Mode) do
    value(Base, 0)
    value(PSK, 1)
    value(Auth, 2)
    value(AuthPSK, 3)
  end

  defenum(KEM) do
    value(P256, 0)
    value(P384, 1)
    value(P512, 2)
    value(X25519, 3)
  end

  defenum(KDF) do
    value(SHA256, 0)
    value(SHA384, 1)
    value(SHA512, 2)
  end

  defenum(AEAD) do
    value(AES128_GCM, 0)
    value(AES256_GCM, 1)
    value(ChaCha20_Poly1305, 2)
  end

  def load_nifs() do
    System.get_env("NIF") |> String.to_charlist() |> :erlang.load_nif(nil)
  end

  @spec gen_kp(non_neg_integer()) :: %{sk: binary(), pk: binary()}
  def gen_kp(_kem_id), do: :erlang.nif_error("Load NIF!")
end
