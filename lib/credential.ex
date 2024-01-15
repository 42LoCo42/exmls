defmodule ExMLS.Credential do
  alias ExMLS.Credential.Credential
  alias ExMLS.Credential.BasicCredential
  alias ExMLS.Credential.CredentialBinding

  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Crypto.SignaturePrivateKey
  alias ExMLS.Crypto.SignaturePublicKey
  alias ExMLS.Crypto.SignatureScheme

  use EnumType
  use TypedStruct

  typedstruct(module: BasicCredential, enforce: true) do
    field(:identity, binary())
  end

  defmodule X509Credential do
    typedstruct(module: CertData, enforce: true) do
      field(:data, binary())
    end

    typedstruct(enforce: true) do
      field(:der_chain, [CertData.t()], default: [])
      field(:public_key, SignaturePublicKey.t())
      field(:signature_scheme, SignatureScheme.t())
    end

    def signature_scheme(_self), do: TODO
    def public_key(_self), do: TODO
    def valid_for(_self, _pub), do: TODO
  end

  # TODO UserInfoVCCredential

  defenum(CredentialType) do
    value(Reserved, 0)
    value(Basic, 1)
    value(X509, 2)
  end

  defmodule CredentialBinding do
    typedstruct(enforce: true) do
      field(:cipher_suite, CipherSuite.t())
      field(:credential, Credential.t())
      field(:credential_key, SignaturePublicKey.t())
      field(:signature, binary())
    end

    def valid_for(_self, _pub), do: TODO

    defp to_be_signed(_self, _signature_key), do: TODO
  end

  typedstruct(module: CredentialBindingInput, enforce: true) do
    field(:cipher_suite, CipherSuite.t())
    field(:credential, Credential.t())
    field(:credential_priv, SignaturePrivateKey.t())
  end

  defmodule MultiCredential do
    typedstruct(enforce: true) do
      field(:bindings, [CredentialBinding.t()])
    end

    def new(_binding_inputs, _signature_key), do: TODO
    def valid_for(_self, _pub), do: TODO
  end

  defmodule Credential do
    typedstruct(enforce: true) do
      field(:cred, BasicCredential.t() | X509Credential.t() | MultiCredential.t())
    end

    def basic(_identity), do: TODO
    def x509(_der_chain), do: TODO
    def multi(_binding_inputs, _signature_key), do: TODO

    def type(_self), do: TODO
    def valid_for(_self, _pub), do: TODO
  end
end
