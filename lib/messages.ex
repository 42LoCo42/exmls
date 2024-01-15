defmodule ExMLS.Messages do
  alias ExMLS.Messages.ContentType
  alias ExMLS.CoreTypes.ExtensionList
  alias ExMLS.Messages.ApplicationData
  alias ExMLS.CoreTypes.KeyPackage
  alias ExMLS.CoreTypes.LeafNode
  alias ExMLS.CoreTypes.ProtocolVersion
  alias ExMLS.CoreTypes.UpdatePath
  alias ExMLS.Credential.Credential
  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Crypto.HPKECiphertext
  alias ExMLS.Crypto.HPKEPublicKey
  alias ExMLS.Crypto.SignaturePublicKey
  alias ExMLS.Messages.Add
  alias ExMLS.Messages.EncryptedGroupSecrets
  alias ExMLS.Messages.ExternalInit
  alias ExMLS.Messages.ExternalPSK
  alias ExMLS.Messages.ExternalSender
  alias ExMLS.Messages.ExternalSenderIndex
  alias ExMLS.Messages.GroupContext
  alias ExMLS.Messages.GroupContextExtensions
  alias ExMLS.Messages.GroupSecrets
  alias ExMLS.Messages.MemberSender
  alias ExMLS.Messages.NewMemberCommitSender
  alias ExMLS.Messages.NewMemberProposalSender
  alias ExMLS.Messages.PreSharedKey
  alias ExMLS.Messages.PreSharedKeyID
  alias ExMLS.Messages.PreSharedKeys
  alias ExMLS.Messages.ProposalOrRef
  alias ExMLS.Messages.ProposalType
  alias ExMLS.Messages.ReInit
  alias ExMLS.Messages.Remove
  alias ExMLS.Messages.ResumptionPSK
  alias ExMLS.Messages.ResumptionPSKUsage
  alias ExMLS.Messages.Update
  alias ExMLS.Messages.WireFormat
  alias ExMLS.Messages.GroupContentAuthData

  use EnumType
  use TypedStruct

  typedstruct(module: ExternalPubExtension, enforce: true) do
    field(:external_pub, HPKEPublicKey.t())
  end

  typedstruct(module: RatchetTreeExtension, enforce: true) do
    field(:tree, TreeKEMPublicKey.t())
  end

  typedstruct(module: ExternalSender, enforce: true) do
    field(:signature_key, SignaturePublicKey.t())
    field(:credential, Credential.t())
  end

  typedstruct(module: ExternalSendersExtension, enforce: true) do
    field(:senders, [ExternalSender.t()], default: [])
  end

  typedstruct(module: SFrameParameters, enforce: true) do
    field(:cipher_suite, non_neg_integer())
    field(:epoch_bits, non_neg_integer())
  end

  defmodule SFrameCapabilities do
    typedstruct(enforce: true) do
      field(:cipher_suites, [non_neg_integer()], default: [])
    end

    def compatible(_self, _params), do: TODO
  end

  defenum(PSKType) do
    value(Reserved, 0)
    value(External, 1)
    value(Resumption, 2)
  end

  typedstruct(module: ExternalPSK, enforce: true) do
    field(:psk_id, binary())
  end

  defenum(ResumptionPSKUsage) do
    value(Reserved, 0)
    value(Application, 1)
    value(Reinit, 2)
    value(Branch, 3)
  end

  typedstruct(module: ResumptionPSK, enforce: true) do
    field(:usage, ResumptionPSKUsage.t())
    field(:psk_group_id, binary())
    field(:psk_epoch, non_neg_integer())
  end

  typedstruct(module: PreSharedKeyID, enforce: true) do
    field(:content, ExternalPSK.t() | ResumptionPSK.t())
    field(:psk_nonce, binary())
  end

  typedstruct(module: PreSharedKeys, enforce: true) do
    field(:psks, [PreSharedKeyID.t()], default: [])
  end

  typedstruct(module: PSKWithSecret, enforce: true) do
    field(:id, PreSharedKeyID.t())
    field(:secret, binary())
  end

  typedstruct(module: GroupContext, enforce: true) do
    field(:version, ProtocolVersion.t(), default: ProtocolVersion.MLS10)
    field(:cipher_suite, CipherSuite.t())
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:tree_hash, binary())
    field(:confirmed_transcript_hash, binary())
    field(:extensions, ExtensionList.t())
  end

  defmodule GroupInfo do
    typedstruct(enforce: true) do
      field(:group_context, GroupContext.t())
      field(:extensions, ExtensionList.t())
      field(:confirmation_tag, binary())
      field(:signer, LeafIndex.t())
      field(:signature, binary())
    end

    def to_be_signed(_self), do: TODO
    def sign(_self, _tree, _signer_index, _priv), do: TODO
    def verify(_self, _tree), do: TODO
  end

  typedstruct(module: GroupSecrets, enforce: true) do
    typedstruct(module: PathSecret, enforce: true) do
      field(:secret, binary())
    end

    alias GroupSecrets.PathSecret

    field(:joiner_secret, binary())
    field(:path_secret, PathSecret.t(), enforce: false)
    field(:psks, PreSharedKeys.t())
  end

  typedstruct(module: EncryptedGroupSecrets, enforce: true) do
    field(:new_member, binary())
    field(:encrypted_group_secrets, HPKECiphertext.t())
  end

  defmodule Welcome do
    typedstruct(enforce: true) do
      field(:cipher_suite, CipherSuite.t())
      field(:secrets, [EncryptedGroupSecrets.t()], default: [])
      field(:encrypted_group_info, binary())

      field(:joiner_secret, binary())
      field(:psks, PreSharedKeys.t())
    end

    def encrypt(_self, _kp, _path_secret), do: TODO
    def find(_self, _kp), do: TODO
    def decrypt_secrets(_self, _kp_index, _init_priv), do: TODO
    def decrypt(_self, _joiner_secret, _psks), do: TODO

    defp group_info_key_nonce(_suite, _joiner_secret, _psks), do: TODO
  end

  typedstruct(module: Add, enforce: true) do
    field(:key_package, KeyPackage.t())
  end

  typedstruct(module: Update, enforce: true) do
    field(:leaf_node, LeafNode.t())
  end

  typedstruct(module: Remove, enforce: true) do
    field(:removed, LeafIndex.t())
  end

  typedstruct(module: PreSharedKey, enforce: true) do
    field(:psk, PreSharedKeyID.t())
  end

  typedstruct(module: ReInit, enforce: true) do
    field(:group_id, binary())
    field(:version, ProtocolVersion.t())
    field(:cipher_suite, CipherSuite.t())
    field(:extensions, ExtensionList.t())
  end

  typedstruct(module: ExternalInit, enforce: true) do
    field(:kem_output, binary())
  end

  typedstruct(module: GroupContextExtensions, enforce: true) do
    field(:group_context_extensions, ExtensionList.t())
  end

  defenum(ProposalType) do
    value(Invalid, 0)
    value(Add, 1)
    value(Update, 2)
    value(Remove, 3)
    value(PSK, 4)
    value(ReInit, 5)
    value(ExternalInit, 6)
    value(GroupContextExtensions, 7)
  end

  defmodule Proposal do
    typedstruct(enforce: true) do
      field(
        :content,
        Add.t()
        | Update.t()
        | Remove.t()
        | PreSharedKey.t()
        | ReInit.t()
        | ExternalInit.t()
        | GroupContextExtensions.t()
      )
    end

    def proposal_type(_self), do: TODO
  end

  defenum(ProposalOrRefType) do
    value(Reserved, 0)
    value(Value, 1)
    value(Reference, 2)
  end

  typedstruct(module: ProposalOrRef, enforce: true) do
    field(:content, Proposal.t() | binary())
  end

  defmodule Commit do
    typedstruct(enforce: true) do
      field(:proposals, [ProposalOrRef.t()], default: [])
      field(:path, UpdatePath.t(), enforce: false)
    end

    def valid_external(_self), do: TODO
  end

  typedstruct(module: ApplicationData, enforce: true) do
    field(:data, binary())
  end

  defenum(WireFormat) do
    value(Reserved, 0)
    value(PublicMessage, 1)
    value(PrivateMessage, 2)
    value(Welcome, 3)
    value(GroupInfo, 4)
    value(KeyPackage, 5)
  end

  defenum(ContentType) do
    value(Invalid, 0)
    value(Application, 1)
    value(Proposal, 2)
    value(Commit, 3)
  end

  defenum(SenderType) do
    value(Invalid, 0)
    value(Member, 1)
    value(External, 2)
    value(NewMemberProposal, 3)
    value(NewMemberCommit, 4)
  end

  typedstruct(module: MemberSender, enforce: true) do
    field(:sender, LeafIndex.t())
  end

  typedstruct(module: ExternalSenderIndex, enforce: true) do
    field(:sender_index, non_neg_integer())
  end

  typedstruct(module: NewMemberProposalSender, enforce: true) do
  end

  typedstruct(module: NewMemberCommitSender, enforce: true) do
  end

  defmodule Sender do
    typedstruct(enforce: true) do
      field(
        :sender,
        MemberSender.t()
        | ExternalSenderIndex.t()
        | NewMemberProposalSender.t()
        | NewMemberCommitSender.t()
      )
    end

    def sender_type(_self), do: TODO
  end

  defmodule GroupContent do
    typedstruct(enforce: true) do
      field(:group_id, binary())
      field(:epoch, non_neg_integer())
      field(:sender, Sender.t())
      field(:authenticated_data, binary())
      field(:content, ApplicationData.t() | Proposal.t() | Commit.t())
    end

    def content_type(_self), do: TODO
  end

  typedstruct(module: GroupContentAuthData, enforce: true) do
    field(:content_type, ContentType.t(), default: ContentType.Invalid)
    field(:signature, binary())
    field(:confirmation_tag, binary(), enforce: false)
  end

  defmodule AuthenticatedContent do
    typedstruct(enforce: true) do
      field(:wire_format, WireFormat.t())
      field(:content, GroupContent.t())
      field(:auth, GroupContentAuthData.t())
    end

    def sign(_wire_format, _content, _suite, _sig_priv, _context), do: TODO
    def verify(_self, _suite, _sig_pub, _context), do: TODO

    def confirmed_transcript_hash_input(_self), do: TODO
    def interim_transcript_hash_input(_self), do: TODO

    def set_confirmation_tag(_self, _confirmation_tag), do: TODO
    def check_confirmation_tag(_self, _confirmation_tag), do: TODO

    defp to_be_signed(_self, _context), do: TODO
  end

  defmodule PublicMessage do
    typedstruct(enforce: true) do
      field(:content, GroupContent.t())
      field(:auth, GroupContentAuthData.t())
      field(:membership_tag, binary(), enforce: false)
    end

    def protect(_content_auth, _suite, _membership_key, _context), do: TODO
    def unprotect(_self, _suite, _membership_key, _context), do: TODO

    def contains(_self, _content_auth), do: TODO

    def authenticated_content(_self), do: TODO

    defp membership_mac(_self, _suite, _membership_key, _context), do: TODO
  end

  defmodule PrivateMessage do
    typedstruct(enforce: true) do
      field(:groupid, binary())
      field(:epoch, non_neg_integer())
      field(:content_type, ContentType.t())
      field(:authenticated_data, binary())
      field(:encrypted_sender_data, binary())
      field(:ciphertext, binary())
    end

    def protect(
          _content_auth,
          _suite,
          _key,
          _sender_data_secret,
          _padding_size
        ),
        do: TODO

    def unprotect(_self, _suite, _keys, _sender_data_secret), do: TODO
  end

  defmodule MLSMessage do
    typedstruct(enforce: true) do
      field(:version, ProtocolVersion.t(), default: ProtocolVersion.MLS10)

      field(
        :message,
        PublicMessage.t()
        | PrivateMessage.t()
        | Welcome.t()
        | GroupInfo.t()
        | KeyPackage.t()
      )
    end

    def epoch(_self), do: TODO
    def wire_format(_self), do: TODO
  end

  def external_proposal(
        _suite,
        _group_id,
        _epoch,
        _proposal,
        _signer_index,
        _sig_priv
      ),
      do: TODO
end
