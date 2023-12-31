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

  @type err :: {:err, String.t()}

  @spec gen_kp(KEM.t()) :: {:ok, %{sk: binary(), pk: binary()}} | err
  @doc """
  Generate a random HPKE keypair for the selected KEM.
  """
  def gen_kp(kem), do: nif_gen_kp(kem.value())

  @spec drv_kp(KEM.t(), binary()) :: {:ok, binary()} | err
  @doc """
  Derive a public from a secret key for the selected KEM.
  """
  def drv_kp(kem, pk), do: nif_drv_kp(kem.value(), pk)

  @spec setup_s(
          %{mode: Mode.t(), kem: KEM.t(), kdf: KDF.t(), aead: AEAD.t()},
          binary(),
          String.t()
        ) :: {:ok, %{ctx: binary(), enc: binary()}} | err
  @doc """
  Set up the sender context.
  TODO: Currently, no pre-shared keys are supported.
  """
  def setup_s(suite, pk, info) do
    nif_setup_s(
      %{
        mode: suite.mode.value(),
        kem: suite.kem.value(),
        kdf: suite.kdf.value(),
        aead: suite.aead.value()
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
        ) :: {:ok, binary()} | err
  @doc """
  Set up the receiver context.
  TODO: Currently, no pre-shared keys are supported.
  """
  def setup_r(suite, enc, sk, info) do
    nif_setup_r(
      %{
        mode: suite.mode.value(),
        kem: suite.kem.value(),
        kdf: suite.kdf.value(),
        aead: suite.aead.value()
      },
      enc,
      sk,
      info
    )
  end

  def seal_base(suite, pk, info, aad, msg) do
    {:ok, %{ctx: ctx, enc: enc}} = setup_s(suite, pk, info)
    {:ok, ct} = seal(ctx, aad, msg)
    %{enc: enc, ct: ct}
  end

  def open_base(suite, enc, sk, info, aad, ct) do
    {:ok, ctx} = setup_r(suite, enc, sk, info)
    {:ok, msg} = open(ctx, aad, ct)
    msg
  end

  @spec seal(binary(), String.t(), String.t()) :: {:ok, binary()} | err
  @doc """
  Encrypt a message.
  The given context `ctx` must have been created by `setup_s`.
  """
  def seal(_ctx, _aad, _msg), do: :erlang.nif_error("Load NIF!")

  @spec open(binary(), String.t(), binary()) :: {:ok, String.t()} | err
  @doc """
  Decrypt a message.
  The given context `ctx` must have been created by `setup_r`.
  """
  def open(_ctx, _aad, _ct), do: :erlang.nif_error("Load NIF!")

  @nif_loc Application.compile_env!(:exmls, :nif_loc)

  defp load_nif() do
    @nif_loc
    |> String.to_charlist()
    |> :erlang.load_nif(nil)
  end

  defp nif_gen_kp(_kem_id), do: :erlang.nif_error("Load NIF!")
  defp nif_drv_kp(_kem_id, _pk), do: :erlang.nif_error("Load NIF!")
  defp nif_setup_s(_suite, _pk, _info), do: :erlang.nif_error("Load NIF!")
  defp nif_setup_r(_suite, _enc, _sk, _info), do: :erlang.nif_error("Load NIF!")
end
