defmodule ExMLS.HPKE do
  use EnumType

  @on_load :load_nif

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

  @spec gen_kp(KEM.t()) :: %{sk: binary(), pk: binary()}
  @doc """
  Generate a random HPKE keypair for the selected KEM.
  """
  def gen_kp(kem), do: nif_gen_kp(kem.value())

  @spec setup_s(
          %{mode: Mode.t(), kem: KEM.t(), kdf: KDF.t(), aead: AEAD.t()},
          binary(),
          String.t()
        ) :: %{ctx: binary(), enc: binary()}
  @doc """
  Set up the sender context.
  TODO: Currently, no pre-shared keys are supported.
  """
  def setup_s(%{mode: mode, kem: kem, kdf: kdf, aead: aead}, pk, info) do
    nif_setup_s(
      %{
        mode: mode.value(),
        kem: kem.value(),
        kdf: kdf.value(),
        aead: aead.value()
      },
      pk,
      info
    )
  end

  @spec setup_r(
          %{mode: Mode.t(), kem: KEM.t(), kdf: KDF.t(), aead: AEAD.t()},
          binary(),
          binary(),
          String.t()
        ) :: binary()
  @doc """
  Set up the receiver context.
  TODO: Currently, no pre-shared keys are supported.
  """
  def setup_r(%{mode: mode, kem: kem, kdf: kdf, aead: aead}, enc, sk, info) do
    nif_setup_r(
      %{
        mode: mode.value(),
        kem: kem.value(),
        kdf: kdf.value(),
        aead: aead.value()
      },
      enc,
      sk,
      info
    )
  end

  @spec seal(binary(), String.t(), String.t()) :: binary()
  @doc """
  Encrypt a message.
  The given context `ctx` must have been created by `setup_s`.
  """
  def seal(_ctx, _aad, _msg), do: :erlang.nif_error("Load NIF!")

  @spec open(binary(), String.t(), binary()) :: String.t()
  @doc """
  Decrypt a message.
  The given context `ctx` must have been created by `setup_r`.
  """
  def open(_ctx, _aad, _ct), do: :erlang.nif_error("Load NIF!")

  defp load_nif() do
    System.get_env("NIF") |> String.to_charlist() |> :erlang.load_nif(nil)
  end

  defp nif_gen_kp(_kem_id), do: :erlang.nif_error("Load NIF!")
  defp nif_setup_s(_suite, _pk, _info), do: :erlang.nif_error("Load NIF!")
  defp nif_setup_r(_suite, _enc, _sk, _info), do: :erlang.nif_error("Load NIF!")
end
