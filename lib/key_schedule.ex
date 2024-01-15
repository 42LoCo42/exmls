defmodule ExMLS.KeySchedule do
  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Crypto.HPKEPrivateKey
  alias ExMLS.Crypto.KeyAndNonce

  use EnumType
  use TypedStruct

  defmodule HashRatchet do
    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:next_secret, binary())
      field(:next_generation, non_neg_integer())
      field(:cache, %{non_neg_integer => KeyAndNonce.t()})

      field(:key_size, non_neg_integer())
      field(:nonce_size, non_neg_integer())
      field(:secret_size, non_neg_integer())
    end

    def next(_self), do: TODO
    def get(_self, _generation), do: TODO
    def erase(_self, _generation), do: TODO
  end

  defmodule SecretTree do
    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:group_size, LeafCount.t())
      field(:root, NodeIndex.t())
      field(:secrets, %{NodeIndex.t() => binary()})
      field(:secret_size, non_neg_integer())
    end

    @spec has_leaf(SecretTree.t(), LeafIndex.t()) :: boolean()
    def has_leaf(self, sender), do: sender < self.group_size

    def get(_self, _sender), do: TODO
  end

  defmodule GroupKeySource do
    alias ExMLS.KeySchedule.GroupKeySource.RatchetType

    defenum(RatchetType) do
      value(Handshake, 0)
      value(Application, 1)
    end

    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:secret_tree, SecretTree.t())

      @type key :: {RatchetType.t(), LeafIndex.t()}
      field(:chains, %{key => HashRatchet.t()})
    end

    def has_leaf(_self, _sender), do: TODO
    def next(_self, _content_type, _sender), do: TODO

    def get(
          _self,
          _content_type,
          _sender,
          _generation,
          _reuse_guard
        ),
        do: TODO

    def erase(_self, _type, _sender, _generation), do: TODO
  end

  defmodule KeyScheduleEpoch do
    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())

      field(:joiner_secret, binary())
      field(:epoch_secret, binary())
      field(:sender_data_secret, binary())
      field(:encryption_secret, binary())
      field(:exporter_secret, binary())
      field(:epoch_authenticator, binary())
      field(:external_secret, binary())
      field(:confirmation_key, binary())
      field(:membership_key, binary())
      field(:resumption_psk, binary())
      field(:init_secret, binary())

      field(:external_priv, HPKEPrivateKey.t())
    end

    def joiner(
          _suite,
          _joiner_secret,
          _psks,
          _context
        ),
        do: TODO

    def external_init(_suite, _external_pub), do: TODO
    def receive_external_init(_self, _kem_output), do: TODO

    def next(_self, _commit_secret, _psks, _force_init_secret, _context), do: TODO

    def encryption_keys(_self, _size), do: TODO
    def confirmation_tag(_self, _confirmed_transcript_hash), do: TODO
    def do_export(_self, _label, _context, _size), do: TODO
    def resumption_psk_w_secret(_self, _usage, _group_id, _epoch), do: TODO

    def make_psk_secret(_suite, _psks), do: TODO
    def welcome_secret(_suite, _joiner_secret, _psks), do: TODO
    def sender_data_keys(_suite, _sender_data_secret, _ciphertext), do: TODO

    def next_raw(_self, _commit_secret, _psk_secret, _force_init_secret, _context), do: TODO
    def welcome_secret_raw(_suite, _joiner_secret, _psk_secret), do: TODO
  end

  defmodule TranscriptHash do
    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:confirmed, binary())
      field(:interim, binary())

      def update(_self, _content_auth), do: TODO
      def update_confirmed(_self, _content_auth), do: TODO
      def update_interim_tag(_self, _confirmation_tag), do: TODO
      def update_interim_auth(_self, _content_auth), do: TODO
    end
  end
end
