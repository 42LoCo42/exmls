defmodule ExMLS.CoreTypes do
  alias ExMLS.CoreTypes.UpdatePathNode
  alias ExMLS.CoreTypes.Empty
  alias ExMLS.CoreTypes.Extension
  alias ExMLS.CoreTypes.ExtensionType
  alias ExMLS.CoreTypes.Lifetime
  alias ExMLS.CoreTypes.ProtocolVersion

  alias ExMLS.Credential.Credential
  alias ExMLS.Credential.CredentialType

  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Crypto.HPKEPublicKey
  alias ExMLS.Crypto.SignaturePublicKey

  use EnumType
  use TypedStruct

  defenum(ProtocolVersion) do
    value(Reserved, 0)
    value(MLS10, 1)
  end

  typedstruct(module: Extension, enforce: true) do
    field(:type, ExtensionType.t())
    field(:data, binary())
  end

  defenum(ExtensionType) do
    value(Reserved, 0)
    value(ApplicationID, 1)
    value(RatchetTree, 2)
    value(RequiredCapabilities, 3)
    value(ExternalPub, 4)
    value(ExternalSenders, 5)
    value(SFrameParameters, 0xFF002)
  end

  defmodule ExtensionList do
    typedstruct(enforce: true) do
      field(:extensions, [Extension.t()], default: [])
    end

    @spec add(ExtensionList.t(), ExtensionType.t(), binary()) :: ExtensionList.t()
    def add(self, type, data) do
      %ExtensionList{self | extensions: [%Extension{type: type, data: data} | self.extensions]}
    end

    @spec find(ExtensionList.t(), ExtensionType.t()) :: {:ok, binary} | nil
    def find(self, type) do
      Enum.find_value(self.extensions, nil, &if(&1.type == type, do: {:ok, &1.data}, else: nil))
    end

    @spec has(ExtensionList.t(), ExtensionType.t()) :: boolean()
    def has(self, type) do
      Enum.any?(self.extensions, &(&1.type == type))
    end
  end

  defenum(LeafNodeSource) do
    value(Reserved, 0)
    value(KeyPackage, 1)
    value(Update, 2)
    value(Commit, 3)
  end

  defmodule Capabilities do
    typedstruct do
      field(:versions, [ProtocolVersion.t()], default: [])
      field(:cipher_suites, [CipherSuite.t()], default: [])
      field(:extensions, [ExtensionType.t()], default: [])
      field(:proposals, [non_neg_integer()], default: [])
      field(:credentials, [CredentialType.t()], default: [])
    end

    @spec extensions_supported(Capabilities.t(), [ExtensionType.t()]) :: any()
    def extensions_supported(_self, _required), do: TODO

    @spec proposals_supported(Capabilities.t(), [non_neg_integer()]) :: any()
    def proposals_supported(_self, _required), do: TODO

    @spec credential_supported(Capabilities.t(), Credential.t()) :: any()
    def credential_supported(_self, _credential), do: TODO
  end

  typedstruct(module: Lifetime, enforce: true) do
    field(:not_before, non_neg_integer())
    field(:not_after, non_neg_integer())
  end

  typedstruct(module: Empty) do
  end

  typedstruct(module: ParentHash, enforce: true) do
    field(:parent_hash, binary())
  end

  # all fields are optional
  typedstruct(module: LeafNodeOptions) do
    field(:credential, Credential.t())
    field(:capabilities, Capabilities.t())
    field(:extensions, ExtensionList.t())
  end

  defmodule LeafNode do
    typedstruct(enforce: true) do
      field(:encryption_key, HPKEPublicKey.t())
      field(:signature_key, SignaturePublicKey.t())
      field(:credential, Credential.t())
      field(:capabilities, Capabilities.t())

      field(:content, Lifetime.t() | Empty.t() | ParentHash.t())

      field(:extensions, ExtensionList.t())
      field(:signature, binary())
    end

    def new(
          _cipher_suite,
          _encryption_key,
          _signature_key,
          _credential,
          _capabilities,
          _lifetime,
          _extensions,
          _sig_priv
        ),
        do: TODO

    def for_update(
          # _self,
          _cipher_suite,
          _group_id,
          _leaf_index,
          _encryption_key,
          _opts,
          _sig_priv
        ),
        do: TODO

    def for_commit(
          # _self,
          _group_id,
          _leaf_index,
          _encryption_key,
          _parent_hash,
          _opts,
          _sig_priv
        ),
        do: TODO

    def set_capabilities(_self, _capabilities), do: TODO
    def source(_self), do: TODO

    typedstruct(module: MemberBinding, enforce: true) do
      field(:group_id, binary())
      field(:leaf_index, LeafIndex.t())
    end

    def sign(
          _self,
          _cipher_suite,
          _sig_priv,
          _binding
        ),
        do: TODO

    def verify(
          _self,
          _cipher_suite,
          _binding
        ),
        do: TODO

    def verify_expiry(_self, _now), do: TODO
    def verify_extensions_support(_self, _ext_list), do: TODO

    defp clone_with_options(_self, _encryption_key, _opts), do: TODO
    defp to_be_signed(_self, _binding), do: TODO
  end

  typedstruct(module: RequiredCapabilitiesExtension, enforce: true) do
    field(:extensions, [ExtensionType.t()], default: [])
    field(:proposals, [non_neg_integer()], default: [])
  end

  typedstruct(module: ApplicationIDExtension, enforce: true) do
    field(:id, binary())
  end

  defmodule ParentNode do
    typedstruct(enforce: true) do
      field(:public_key, HPKEPublicKey.t())
      field(:parent_hash, binary())
      field(:unmerged_leaves, [LeafIndex.t()])
    end

    def hash(_self, _suite), do: TODO
  end

  defmodule KeyPackage do
    typedstruct(enforce: true) do
      field(:version, ProtocolVersion.t())
      field(:cipher_suite, CipherSuite.t())
      field(:init_key, HPKEPublicKey.t())
      field(:leaf_node, LeafNode.t())
      field(:extensions, ExtensionList.t())
      field(:signature, binary())
    end

    def new(
          _suite,
          _init_key,
          _leaf_node,
          _extensions,
          _sig_priv
        ),
        do: TODO

    def ref(_self), do: TODO

    def sign(_self, _sig_priv), do: TODO
    def verify(_self), do: TODO

    defp to_be_signed(_self), do: TODO
  end

  typedstruct(module: UpdatePathNode, enforce: true) do
    field(:public_key, HPKEPublicKey.t())
    field(:encrypted_path_secret, nil)
  end

  typedstruct(module: UpdatePath, enforce: true) do
    field(:leaf_node, LeafNode.t())
    field(:nodes, [UpdatePathNode.t()], default: [])
  end
end
