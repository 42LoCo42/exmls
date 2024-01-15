defmodule ExMLS.Session do
  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Crypto.SignaturePrivateKey
  alias ExMLS.Credential.Credential

  use TypedStruct

  defmodule Client do
    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:sig_priv, SignaturePrivateKey.t())
      field(:cred, Credential.t())
    end

    def begin_session(_self, _group_id), do: TODO
    def start_join(_self), do: TODO
  end

  defmodule PendingJoin do
    # TODO Inner

    def key_package(_self), do: TODO
    def complete(_self, _welcome), do: TODO
  end

  defmodule Session do
    # TODO Inner

    def encrypt_handshake(_self, _enabled), do: TODO

    def add(_self, _key_package_data), do: TODO
    def update(_self), do: TODO
    def remove(_self, _index), do: TODO
    def commit_proposal(_self, _proposal), do: TODO
    def commit_proposals(_self, _proposals), do: TODO
    def commit(_self), do: TODO

    def handle(_self, _handshake_data), do: TODO

    def epoch(_self), do: TODO
    def index(_self), do: TODO
    def cipher_suite(_self), do: TODO
    def extensions(_self), do: TODO
    def tree(_self), do: TODO
    def do_export(_self, _label, _context, _size), do: TODO
    def group_info(_self), do: TODO
    def roster(_self), do: TODO
    def epoch_authenticator(_self), do: TODO

    def protect(_self, _plaintext), do: TODO
    def unprotect(_self, _ciphertext), do: TODO
  end
end
