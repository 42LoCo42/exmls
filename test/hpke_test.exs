defmodule HPKETest do
  use ExUnit.Case, async: true

  test "HPKE keygen" do
    ExMLS.HPKE.KEM.enums()
    |> Enum.map(fn kem ->
      %{sk: sk, pk: pk} = ExMLS.HPKE.gen_kp(kem.value)

      dbg(%{
        kem: kem,
        sk: :base64.encode_to_string(sk),
        pk: :base64.encode_to_string(pk)
      })
    end)
  end
end
