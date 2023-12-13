defmodule ExMLS do
  use Application

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
        kem: ExMLS.HPKE.KEM.X25519,
        kdf: ExMLS.HPKE.KDF.SHA256,
        aead: ExMLS.HPKE.AEAD.AES128_GCM
      },
      hash: :sha256,
      mac: :hmac,
      sign: %{type: :eddsa, algo: :ed25519}
    }

    dbg(ciphersuite)

    {:ok, %{pk: hpke_pk, sk: hpke_sk}} = ExMLS.HPKE.gen_kp(ciphersuite.hpke.kem)
    dbg(%{pk: :base64.encode_to_string(hpke_pk), sk: :base64.encode_to_string(hpke_sk)})

    {sign_pk, sign_sk} = :crypto.generate_key(ciphersuite.sign.type, ciphersuite.sign.algo)
    dbg(%{pk: :base64.encode_to_string(sign_pk), sk: :base64.encode_to_string(sign_sk)})

    data = %ExMLS.Structs.SignContent{
      label: "label",
      content: "content"
    }

    signature = sign_with_label(ciphersuite.sign, ciphersuite.hash, sign_sk, data)
    dbg(:base64.encode_to_string(signature))
    dbg(verify_with_label(ciphersuite.sign, ciphersuite.hash, sign_pk, data, signature))

    {:ok, self()}
  end

  @sign_label "MLS 1.0 "

  def sign_with_label(sign, hash, sk, data) do
    :crypto.sign(
      sign.type,
      hash,
      @sign_label <> data.label <> data.content,
      [sk, sign.algo]
    )
  end

  def verify_with_label(sign, hash, pk, data, signature) do
    :crypto.verify(
      sign.type,
      hash,
      @sign_label <> data.label <> data.content,
      signature,
      [pk, sign.algo]
    )
  end
end
