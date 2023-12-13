defmodule HPKETest do
  use ExUnit.Case, async: true

  test "HPKE" do
    ExMLS.HPKE.KEM.enums()
    |> Enum.map(fn kem ->
      # create keypair
      {:ok, %{sk: sk, pk: pk}} = ExMLS.HPKE.gen_kp(kem)

      # derive public key
      {:ok, derived_pk} = ExMLS.HPKE.drv_kp(kem, sk)
      assert pk == derived_pk

      dbg(%{
        kem: kem,
        sk: :base64.encode_to_string(sk),
        pk: :base64.encode_to_string(pk)
      })

      suite = %{
        mode: ExMLS.HPKE.Mode.Base,
        kem: kem,
        kdf: ExMLS.HPKE.KDF.SHA512,
        aead: ExMLS.HPKE.AEAD.ChaCha20_Poly1305
      }

      # create sender context
      info = "info"
      {:ok, %{ctx: ctx_s, enc: enc}} = ExMLS.HPKE.setup_s(suite, pk, info)

      dbg(%{
        ctx: :base64.encode_to_string(ctx_s),
        enc: :base64.encode_to_string(enc)
      })

      # seal a message
      aad = "aad"
      msg = "msg"

      {:ok, ct} = ExMLS.HPKE.seal(ctx_s, aad, msg)
      dbg(:base64.encode_to_string(ct))

      # create receiver context
      {:ok, ctx_r} = ExMLS.HPKE.setup_r(suite, enc, sk, info)
      dbg(:base64.encode_to_string(ctx_r))

      # open a message
      {:ok, dec} = dbg(ExMLS.HPKE.open(ctx_r, aad, ct))
      assert msg == dec
    end)
  end
end
