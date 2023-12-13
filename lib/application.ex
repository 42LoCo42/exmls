defmodule ExMLS do
  use Application

  @base_label "MLS 1.0 "

  @impl true
  def start(_type, _args) do
    # children = [
    #   {
    #     Bandit,
    #     plug: Web.Hello, port: 37812
    #   }
    # ]

    # opts = [strategy: :one_for_one, name: ExMLS.Supervisor]
    # Supervisor.start_link(children, opts)

    # may gog have mercy
    MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519

    ciphersuite = %{
      hpke: %{
        mode: ExMLS.HPKE.Mode.Base,
        kem: ExMLS.HPKE.KEM.X25519,
        kdf: ExMLS.HPKE.KDF.SHA256,
        aead: ExMLS.HPKE.AEAD.AES128_GCM
      },
      hash: :sha256,
      mac: :hmac,
      sign: %{type: :eddsa, algo: :ed25519}
    }

    dbg(ciphersuite)

    # generate & print HPKE keypair
    {:ok, %{pk: hpke_pk, sk: hpke_sk}} = ExMLS.HPKE.gen_kp(ciphersuite.hpke.kem)
    dbg(%{pk: :base64.encode_to_string(hpke_pk), sk: :base64.encode_to_string(hpke_sk)})

    # encrypt & decrypt
    %{enc: enc, ct: ct} = encrypt_with_label(ciphersuite.hpke, hpke_pk, "label", "msg")
    dbg(decrypt_with_label(ciphersuite.hpke, hpke_sk, "label", enc, ct))

    # generate & print sign keypair
    {sign_pk, sign_sk} = :crypto.generate_key(ciphersuite.sign.type, ciphersuite.sign.algo)
    dbg(%{pk: :base64.encode_to_string(sign_pk), sk: :base64.encode_to_string(sign_sk)})

    data = %ExMLS.Structs.SignContent{
      label: "label",
      content: "content"
    }

    # sign & verify
    signature = sign_with_label(ciphersuite.sign, ciphersuite.hash, sign_sk, data)
    dbg(verify_with_label(ciphersuite.sign, ciphersuite.hash, sign_pk, data, signature))

    {:ok, self()}
  end

  def sign_with_label(sign, hash, sk, data) do
    :crypto.sign(
      sign.type,
      hash,
      @base_label <> data.label <> data.content,
      [sk, sign.algo]
    )
  end

  def verify_with_label(sign, hash, pk, data, signature) do
    :crypto.verify(
      sign.type,
      hash,
      @base_label <> data.label <> data.content,
      signature,
      [pk, sign.algo]
    )
  end

  def encrypt_with_label(hpke, pk, label, msg) do
    ExMLS.HPKE.seal_base(hpke, pk, @base_label <> label, "", msg)
  end

  def decrypt_with_label(hpke, sk, label, enc, ct) do
    ExMLS.HPKE.open_base(hpke, enc, sk, @base_label <> label, "", ct)
  end
end
