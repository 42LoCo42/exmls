defmodule ExMLS.Crypto do
  alias ExMLS.Crypto.SignatureScheme

  use EnumType
  use TypedStruct

  defenum(SignatureScheme) do
    value(ECDSA_SECP256R1_SHA256, 0x0403)
    value(ECDSA_SECP384R1_SHA384, 0x0805)
    value(ECDSA_SECP521R1_SHA512, 0x0603)
    value(ED25519, 0x0807)
    value(ED448, 0x0808)
    value(RSA_PKCS1_SHA256, 0x0401)
  end

  typedstruct(module: KeyAndNonce, enforce: true) do
    field(:key, binary())
    field(:nonce, binary())
  end

  defmodule CipherSuite do
    alias ExMLS.Crypto.CipherSuite.ID

    defenum(ID) do
      value(Unknown, 0)
      value(X25519_AES128GCM_SHA256_Ed25519, 0x0001)
      value(P256_AES128GCM_SHA256_P256, 0x0002)
      value(X25519_CHACHA20POLY1305_SHA256_Ed25519, 0x0003)
      value(X448_AES256GCM_SHA512_Ed448, 0x0004)
      value(P521_AES256GCM_SHA512_P521, 0x0005)
      value(X448_CHACHA20POLY1305_SHA512_Ed448, 0x0006)
      value(P384_AES256GCM_SHA384_P384, 0x0007)
    end

    typedstruct(enforce: true) do
      field(:id, ID.t())
    end

    typedstruct(module: Ciphers, enforce: true) do
      field(:hpke, HPKE.t())
      field(:digest, Digest.t())
      field(:sig, Signature.t())
    end

    @spec cipher_suite(CipherSuite.t()) :: ID.t()
    def cipher_suite(self), do: self.id

    def signature_scheme(_self), do: TODO

    defp get(_self), do: TODO
  end

  typedstruct(module: HPKECiphertext, enforce: true) do
    field(:kem_output, binary())
    field(:ciphertext, binary())
  end

  defmodule HPKEPublicKey do
    typedstruct(enforce: true) do
      field(:data, binary())
    end

    def encrypt(
          _self,
          _suite,
          _label,
          _context,
          _pt
        ),
        do: TODO

    def do_export(
          _self,
          _suite,
          _info,
          _label,
          _size
        ),
        do: TODO
  end

  defmodule HPKEPrivateKey do
    typedstruct(enforce: true) do
      field(:data, binary())
      field(:public_key, HPKEPublicKey.t())
    end

    def generate(_suite), do: TODO
    def parse(_suite, _data), do: TODO
    def derive(_suite, _secret), do: TODO

    def decrypt(
          _self,
          _suite,
          _label,
          _context,
          _ct
        ),
        do: TODO

    def do_export(
          _self,
          _suite,
          _info,
          _kem_output,
          _label,
          _size
        ),
        do: TODO

    def set_public_key(_self, _suite), do: TODO
  end

  defmodule SignaturePublicKey do
    typedstruct(enforce: true) do
      field(:data, binary())
    end

    def from_jwk(_suite, _json_str), do: TODO

    def verify(
          _self,
          _suite,
          _label,
          _message,
          _signature
        ),
        do: TODO

    def to_jwk(_self, _suite), do: TODO
  end

  defmodule PublicJWK do
    typedstruct(enforce: true) do
      field(:signature_scheme, SignatureScheme.t())
      field(:key_id, String.t(), enforce: false)
      field(:public_key, SignaturePublicKey.t())
    end

    def parse(_jwk_json), do: TODO
  end

  defmodule SignaturePrivateKey do
    typedstruct(enforce: true) do
      field(:data, binary())
      field(:public_key, SignaturePublicKey.t())
    end

    def generate(_suite), do: TODO
    def parse(_suite, _data), do: TODO
    def derive(_suite, _secret), do: TODO
    def from_jwk(_suite, _json_str), do: TODO

    def sign(
          _self,
          _suite,
          _label,
          _message
        ),
        do: TODO

    def set_public_key(_self, _suite), do: TODO
    def to_jwk(_self, _suite), do: TODO
  end
end
